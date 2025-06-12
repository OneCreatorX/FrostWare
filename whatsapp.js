import { makeWASocket, useMultiFileAuthState, Browsers } from "@whiskeysockets/baileys"
import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
import https from "https"
import bodyParser from "body-parser"
import multer from "multer"
import crypto from "crypto"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)

const CONFIG = {
  PORT: 443,
  DOMAIN: "system.heatherx.site",
  SSL_KEY: `/etc/letsencrypt/live/system.heatherx.site/privkey.pem`,
  SSL_CERT: `/etc/letsencrypt/live/system.heatherx.site/cert.pem`,
  SSL_CA: `/etc/letsencrypt/live/system.heatherx.site/chain.pem`,
  MAX_SESSIONS: 10,
  AUTO_DOWNLOAD_DELAY: 7000,
  AUTO_DELETE_AFTER_SEND: true,
  SHOW_MESSAGES_BY_DEFAULT: false,
  DOWNLOAD_MEDIA_BY_DEFAULT: false,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

// Session management
const activeSessions = new Map()
const sessionStates = new Map() // Para trackear el estado de cada sesión
const waitingQueue = []
const cookiesStorage = new Map()
const formatCache = new Map()

// Utility functions
function generateSecureSessionId() {
  const timestamp = Date.now().toString(36)
  const randomBytes = crypto.randomBytes(32).toString("hex")
  const hash = crypto
    .createHash("sha256")
    .update(timestamp + randomBytes)
    .digest("hex")
  return `ws_${timestamp}_${hash.substring(0, 48)}_${crypto.randomBytes(16).toString("hex")}`
}

function getRandomUserAgent() {
  const userAgents = [
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  ]
  return userAgents[Math.floor(Math.random() * userAgents.length)]
}

function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n"
  netscapeFormat += "# This is a generated file! Do not edit.\n\n"

  cookies.forEach((cookie) => {
    const domain = cookie.domain || cookie.Domain || ""
    const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
    const path = cookie.path || cookie.Path || "/"
    const secure = cookie.secure || cookie.Secure ? "TRUE" : "FALSE"
    const expiration = cookie.expirationDate || cookie.expires || Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
    const name = cookie.name || cookie.Name || ""
    const value = cookie.value || cookie.Value || ""

    netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
  })

  return netscapeFormat
}

// Multer setup
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionId = req.headers["session-id"] || req.query.session
    const sessionDir = join(__dirname, "uploads", sessionId || "temp")
    fs.mkdirSync(sessionDir, { recursive: true })
    cb(null, sessionDir)
  },
  filename: (req, file, cb) => cb(null, Date.now() + "-" + file.originalname),
})

const upload = multer({ storage: storage })

// Express setup
app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Create directories
const mediaDir = join(__dirname, "media")
const uploadsDir = join(__dirname, "uploads")
const tempDir = join(__dirname, "temp")
const cookiesDir = join(__dirname, "cookies")

try {
  fs.mkdirSync(mediaDir, { recursive: true })
  fs.mkdirSync(uploadsDir, { recursive: true })
  fs.mkdirSync("public", { recursive: true })
  fs.mkdirSync("sessions", { recursive: true })
  fs.mkdirSync(tempDir, { recursive: true })
  fs.mkdirSync(cookiesDir, { recursive: true })
} catch (err) {
  console.error("Error creating directories:", err)
}

// HTML content (same as before)
const htmlContent = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>WhatsApp Personal Interface</title><style>*{margin:0;padding:0;box-sizing:border-box;font-family:"Segoe UI",Tahoma,Geneva,Verdana,sans-serif}body{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh}.container{max-width:1400px;margin:0 auto;height:100vh;display:flex;flex-direction:column;padding:20px}header{background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);color:white;padding:20px;border-radius:15px;margin-bottom:20px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.session-info{font-size:12px;opacity:0.8;max-width:300px;word-break:break-all}.settings-btn{background:rgba(255,255,255,0.2);border:none;color:white;padding:8px 12px;border-radius:8px;cursor:pointer;font-size:14px;margin-left:10px}.settings-btn:hover{background:rgba(255,255,255,0.3)}.status-connected{background:linear-gradient(45deg,#4CAF50,#45a049);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(76,175,80,0.3)}.status-disconnected{background:linear-gradient(45deg,#f44336,#d32f2f);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(244,67,54,0.3)}.status-waiting{background:linear-gradient(45deg,#ff9800,#f57c00);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(255,152,0,0.3)}.status-downloading{background:linear-gradient(45deg,#2196F3,#1976D2);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(33,150,243,0.3)}.qr-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.qr-container h1{color:white;margin-bottom:20px;font-size:24px}.qr-container img{max-width:300px;border-radius:15px;margin:20px 0;box-shadow:0 8px 25px rgba(0,0,0,0.3)}.qr-container button{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:15px 30px;border-radius:10px;cursor:pointer;font-size:16px;transition:all 0.3s ease}.qr-container button:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.loading-spinner{border:3px solid rgba(255,255,255,0.3);border-radius:50%;border-top:3px solid white;width:40px;height:40px;animation:spin 1s linear infinite;margin:20px auto}@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}.waiting-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37);color:white}.queue-position{font-size:48px;font-weight:bold;margin:20px 0;color:#ff9800}.main-content{display:flex;height:calc(100vh - 140px);gap:20px}.sidebar{width:350px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.message-section{padding:20px}.message-section h3{color:white;margin-bottom:15px;font-size:18px}.message-input{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;resize:none;height:80px;margin-bottom:10px}.message-input::placeholder{color:rgba(255,255,255,0.7)}.btn{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:12px 20px;border-radius:8px;cursor:pointer;font-size:14px;transition:all 0.3s ease;width:100%}.btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.btn:disabled{opacity:0.6;cursor:not-allowed;transform:none}.chat-area{flex:1;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.chat-header{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2);color:white}.messages{flex:1;padding:20px;overflow-y:auto;display:flex;flex-direction:column}.no-messages{text-align:center;color:rgba(255,255,255,0.7);padding:50px;font-size:16px}@media (max-width:768px){.main-content{flex-direction:column}.sidebar{width:100%;height:auto}}</style></head><body><div class="container"><header><div><h1>📱 Personal WhatsApp Interface</h1><div class="session-info" id="session-info">Session: Loading...</div></div><div style="display: flex; align-items: center;"><div id="status" class="status-disconnected">Disconnected</div></div></header><div id="waiting-section" class="waiting-container" style="display: none;"><h1>⏳ Queue Full</h1><div class="queue-position" id="queue-position">0</div><p>You are in position <span id="position-text">0</span> in the queue</p><p>Maximum <span id="max-sessions">10</span> sessions allowed simultaneously</p><div class="loading-spinner"></div></div><div id="qr-section" class="qr-container" style="display: none;"><h1>📱 Scan with WhatsApp</h1><div id="qr-image"></div><p>Open WhatsApp → Linked Devices → Link Device</p><button onclick="location.reload()">Refresh QR</button></div><div id="loading-section" class="qr-container"><h1>⏳ Initializing...</h1><div class="loading-spinner"></div><p>Please wait while we set up your WhatsApp interface</p></div><div id="main-content" class="main-content" style="display: none;"><div class="sidebar"><div class="message-section"><h3>💬 Send Message</h3><textarea id="message-input" class="message-input" placeholder="Type your message..."></textarea><button id="send-message-btn" class="btn">📤 Send Message</button></div></div><div class="chat-area"><div class="chat-header"><h2>💬 My Messages</h2><p id="user-info">Personal chat with myself</p></div><div class="messages" id="messages"><div class="no-messages" id="no-messages">📱 Ready to send messages!</div></div></div></div></div><script>let sessionId=getSessionFromUrl()||generateSecureSessionId();updateUrlWithSession(sessionId);function getSessionFromUrl(){const urlParams=new URLSearchParams(window.location.search);return urlParams.get('session')}function generateSecureSessionId(){const timestamp=Date.now().toString(36),randomBytes=Array.from(crypto.getRandomValues(new Uint8Array(32)),b=>b.toString(16).padStart(2,'0')).join(''),combined=timestamp+randomBytes;return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g,'').substring(0,48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)),b=>b.toString(16).padStart(2,'0')).join('')}\`}function updateUrlWithSession(sessionId){const url=new URL(window.location);url.searchParams.set('session',sessionId);window.history.replaceState({},'',url)}const statusElement=document.getElementById("status"),sessionInfoElement=document.getElementById("session-info"),messagesList=document.getElementById("messages"),messageInput=document.getElementById("message-input"),sendMessageBtn=document.getElementById("send-message-btn"),qrSection=document.getElementById("qr-section"),loadingSection=document.getElementById("loading-section"),waitingSection=document.getElementById("waiting-section"),mainContent=document.getElementById("main-content"),qrImage=document.getElementById("qr-image"),userInfo=document.getElementById("user-info"),queuePosition=document.getElementById("queue-position"),positionText=document.getElementById("position-text"),maxSessions=document.getElementById("max-sessions");sessionInfoElement.textContent=\`Session: \${sessionId.substring(3,15)}...\`;sendMessageBtn.addEventListener('click',async()=>{const message=messageInput.value.trim();if(!message)return;try{const response=await fetch(\`/api/send?session=\${sessionId}\`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message})});const result=await response.json();if(result.success){messageInput.value='';console.log('Message sent successfully')}}catch(error){console.error('Error sending message:',error)}});messageInput.addEventListener('keypress',(e)=>{if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();sendMessageBtn.click()}});async function checkStatus(){try{console.log('Checking status for session:',sessionId);const response=await fetch(\`/api/status?session=\${sessionId}\`);const result=await response.json();console.log('Status response:',result);if(result.status==='waiting'){console.log('Status: waiting');qrSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='none';waitingSection.style.display='block';queuePosition.textContent=result.position;positionText.textContent=result.position;maxSessions.textContent=result.maxSessions;statusElement.textContent=\`Waiting (Position \${result.position})\`;statusElement.className='status-waiting'}else if(result.status==='qr'){console.log('Status: qr');waitingSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='none';qrSection.style.display='block';if(result.qr){console.log('QR code received');qrImage.innerHTML=\`<img src="\${result.qr}" alt="QR Code">\`}statusElement.textContent='Scan QR Code';statusElement.className='status-disconnected'}else if(result.status==='connected'){console.log('Status: connected');waitingSection.style.display='none';qrSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='flex';statusElement.textContent='Connected';statusElement.className='status-connected';if(result.user){console.log('User info:',result.user);userInfo.textContent=\`Connected as: \${result.user.name||result.user.id}\`}}else{console.log('Status: initializing');statusElement.textContent='Initializing...';statusElement.className='status-disconnected'}}catch(error){console.error('Error checking status:',error);statusElement.textContent='Connection Error';statusElement.className='status-disconnected'}}console.log('Starting status check...');checkStatus();setInterval(checkStatus,3000)</script></body></html>`

fs.writeFileSync("public/index.html", htmlContent)

// Routes
app.get("/", (req, res) => res.sendFile(join(__dirname, "public", "index.html")))

app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session
    console.log(`[STATUS] Checking status for session: ${sessionId}`)

    if (!sessionId) {
      console.log(`[STATUS] No session ID provided`)
      return res.json({ success: false, error: "Session ID required" })
    }

    // Check if we're at max capacity and this session isn't active
    if (activeSessions.size >= CONFIG.MAX_SESSIONS && !activeSessions.has(sessionId)) {
      let position = waitingQueue.indexOf(sessionId)
      if (position === -1) {
        waitingQueue.push(sessionId)
        position = waitingQueue.length - 1
      }
      console.log(`[STATUS] Session ${sessionId} is waiting, position: ${position + 1}`)
      return res.json({
        status: "waiting",
        position: position + 1,
        maxSessions: CONFIG.MAX_SESSIONS,
      })
    }

    // Check if session is already active and connected
    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      if (sock && sock.user) {
        console.log(`[STATUS] Session ${sessionId} is connected`)
        return res.json({
          status: "connected",
          user: {
            id: sock.user.id,
            name: sock.user.name || sock.user.id,
          },
        })
      }
    }

    // Check for QR code
    const sessionDir = join(__dirname, "sessions", sessionId)
    const qrFile = join(sessionDir, "qr.png")

    if (fs.existsSync(qrFile)) {
      console.log(`[STATUS] QR code exists for session ${sessionId}`)
      const qrData = fs.readFileSync(qrFile, "base64")
      return res.json({
        status: "qr",
        qr: `data:image/png;base64,${qrData}`,
      })
    }

    // If no active session and no QR, create new session
    if (!activeSessions.has(sessionId) && !sessionStates.has(sessionId)) {
      console.log(`[STATUS] Creating new session for ${sessionId}`)
      sessionStates.set(sessionId, "initializing")
      createWhatsAppSession(sessionId)
    }

    console.log(`[STATUS] Session ${sessionId} is initializing`)
    res.json({ status: "initializing" })
  } catch (error) {
    console.error(`[STATUS] Error:`, error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/send", async (req, res) => {
  try {
    const { message } = req.body
    const sessionId = req.query.session

    console.log(`[SEND] Sending message for session: ${sessionId}`)

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    const sock = activeSessions.get(sessionId)
    if (!sock || !sock.user) {
      return res.json({ success: false, error: "Session not connected" })
    }

    await sock.sendMessage(sock.user.id, { text: message })
    console.log(`[SEND] Message sent successfully for session: ${sessionId}`)
    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    console.error(`[SEND] Error:`, error)
    res.json({ success: false, error: error.message })
  }
})

app.use("/media", express.static(mediaDir))

// WhatsApp session creation
async function createWhatsAppSession(sessionId) {
  try {
    console.log(`[SESSION] Creating WhatsApp session for: ${sessionId}`)

    if (activeSessions.has(sessionId)) {
      console.log(`[SESSION] Session ${sessionId} already exists`)
      return
    }

    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      browser: Browsers.macOS("Desktop"),
      generateHighQualityLinkPreview: true,
      markOnlineOnConnect: false,
      syncFullHistory: false,
      defaultQueryTimeoutMs: 60000,
      connectTimeoutMs: 60000,
      keepAliveIntervalMs: 30000,
      emitOwnEvents: true,
      fireInitQueries: true,
      shouldSyncHistoryMessage: () => false,
    })

    activeSessions.set(sessionId, sock)
    sessionStates.set(sessionId, "connecting")

    console.log(`[SESSION] Socket created for session: ${sessionId}`)

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update
      console.log(`[SESSION] Connection update for ${sessionId}:`, { connection, qr: !!qr })

      if (qr) {
        try {
          console.log(`[SESSION] Generating QR for session: ${sessionId}`)
          const qrImage = await qrcode.toDataURL(qr, { width: 300, margin: 2 })
          const base64Data = qrImage.replace(/^data:image\/png;base64,/, "")
          const qrPath = join(sessionDir, "qr.png")
          fs.writeFileSync(qrPath, base64Data, "base64")
          sessionStates.set(sessionId, "qr_ready")
          console.log(`[SESSION] QR saved for session: ${sessionId}`)
        } catch (err) {
          console.error(`[SESSION] Error saving QR for ${sessionId}:`, err)
        }
      }

      if (connection === "close") {
        console.log(`[SESSION] Connection closed for ${sessionId}:`, lastDisconnect?.error)
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401

        activeSessions.delete(sessionId)
        sessionStates.delete(sessionId)

        if (shouldReconnect) {
          console.log(`[SESSION] Reconnecting session: ${sessionId}`)
          setTimeout(() => createWhatsAppSession(sessionId), 5000)
        } else {
          console.log(`[SESSION] Not reconnecting session: ${sessionId}`)
          try {
            fs.rmSync(sessionDir, { recursive: true, force: true })
          } catch (err) {
            console.error(`[SESSION] Error removing session dir:`, err)
          }
        }
      } else if (connection === "open") {
        console.log(`[SESSION] Connected successfully: ${sessionId}`)
        sessionStates.set(sessionId, "connected")

        // Remove QR file
        const qrPath = join(sessionDir, "qr.png")
        if (fs.existsSync(qrPath)) {
          fs.unlinkSync(qrPath)
        }

        // Remove from waiting queue
        const waitingIndex = waitingQueue.indexOf(sessionId)
        if (waitingIndex > -1) {
          waitingQueue.splice(waitingIndex, 1)
        }
      }
    })

    sock.ev.on("creds.update", saveCreds)

    sock.ev.on("messages.upsert", async ({ messages, type }) => {
      if (type !== "notify") return

      for (const message of messages) {
        if (message.key.fromMe) {
          console.log(`[SESSION] Message sent from session: ${sessionId}`)
        }
      }
    })
  } catch (error) {
    console.error(`[SESSION] Error creating session ${sessionId}:`, error)
    activeSessions.delete(sessionId)
    sessionStates.delete(sessionId)
  }
}

// Queue processing
setInterval(() => {
  if (activeSessions.size < CONFIG.MAX_SESSIONS && waitingQueue.length > 0) {
    const nextSessionId = waitingQueue.shift()
    console.log(`[QUEUE] Processing next session from queue: ${nextSessionId}`)
    createWhatsAppSession(nextSessionId)
  }
}, 5000)

// Cleanup intervals
setInterval(() => {
  try {
    const tempFiles = fs.readdirSync(tempDir)
    const now = Date.now()

    tempFiles.forEach((file) => {
      const filePath = join(tempDir, file)
      const stats = fs.statSync(filePath)
      const ageInMinutes = (now - stats.mtime.getTime()) / (1000 * 60)

      if (ageInMinutes > 30) {
        fs.unlinkSync(filePath)
      }
    })
  } catch (error) {
    console.error("[CLEANUP] Error cleaning temp files:", error)
  }
}, 600000)

// SSL Server
try {
  const sslOptions = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(sslOptions, app)

  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 WhatsApp server running on https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
    console.log(`📱 Max sessions: ${CONFIG.MAX_SESSIONS}`)
    console.log(`⚙️ Auto-delete: ${CONFIG.AUTO_DELETE_AFTER_SEND}`)
    console.log(`💬 Show messages: ${CONFIG.SHOW_MESSAGES_BY_DEFAULT}`)
    console.log(`📥 Download media: ${CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT}`)
  })
} catch (error) {
  console.error("❌ SSL Error, falling back to HTTP:", error)

  app.listen(CONFIG.PORT, () => {
    console.log(`🚀 WhatsApp server running on http://localhost:${CONFIG.PORT}`)
  })
}

// Graceful shutdown
process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down gracefully...")
  activeSessions.forEach((sock, sessionId) => {
    try {
      sock.end()
    } catch (error) {
      console.error(`Error closing session ${sessionId}:`, error)
    }
  })
  process.exit(0)
})

process.on("uncaughtException", (error) => {
  console.error("❌ Uncaught Exception:", error.message)
})

process.on("unhandledRejection", (reason, promise) => {
  console.error("❌ Unhandled Rejection at:", promise, "reason:", reason)
})
