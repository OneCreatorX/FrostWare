const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys")
import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
import https from "https"
import bodyParser from "body-parser"
import multer from "multer"
import path from "path"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)

const CONFIG = {
  PORT: 443,
  DOMAIN: "system.heatherx.site",
  SSL_KEY: `/etc/letsencrypt/live/system.heatherx.site/privkey.pem`,
  SSL_CERT: `/etc/letsencrypt/live/system.heatherx.site/cert.pem`,
  SSL_CA: `/etc/letsencrypt/live/system.heatherx.site/chain.pem`,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const sessions = new Map()
const qrCodes = new Map()
const sessionLocks = new Map()

function convertJ2TeamToNetscape(cookiesData) {
  if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
    throw new Error("Invalid cookies format - expected {url, cookies} structure")
  }

  let netscape = "# Netscape HTTP Cookie File\n"
  netscape += "# This is a generated file! Do not edit.\n\n"

  cookiesData.cookies.forEach((cookie) => {
    const domain = cookie.domain || ""
    const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
    const path = cookie.path || "/"
    const secure = cookie.secure === true || cookie.secure === "true" ? "TRUE" : "FALSE"

    let expiration = cookie.expirationDate || cookie.expires
    if (typeof expiration === "number") {
      expiration = Math.floor(expiration)
    } else if (typeof expiration === "string") {
      expiration = Math.floor(Number.parseFloat(expiration))
    } else {
      expiration = Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
    }

    const name = cookie.name || ""
    const value = cookie.value || ""

    netscape += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
  })

  return netscape
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionId = req.headers["session-id"] || req.query.session || "default"
    const dir = join(__dirname, "uploads", sessionId)
    fs.mkdirSync(dir, { recursive: true })
    cb(null, dir)
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname)
  },
})

const upload = multer({ storage })

app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const dirs = ["public", "sessions", "media", "uploads", "temp", "cookies"]
dirs.forEach((dir) => {
  try {
    fs.mkdirSync(join(__dirname, dir), { recursive: true })
  } catch (err) {}
})

const htmlContent = `<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>WhatsApp Interface</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;font-family:Arial,sans-serif}
body{background:linear-gradient(135deg,#667eea,#764ba2);min-height:100vh;color:white}
.container{max-width:1200px;margin:0 auto;padding:20px}
.header{background:rgba(255,255,255,0.1);padding:20px;border-radius:15px;margin-bottom:20px;display:flex;justify-content:space-between;align-items:center}
.status{padding:8px 16px;border-radius:20px;font-size:14px}
.status-connected{background:#4CAF50}
.status-disconnected{background:#f44336}
.qr-container{text-align:center;background:rgba(255,255,255,0.1);padding:50px;border-radius:15px;margin:20px 0}
.qr-container img{max-width:300px;border-radius:10px;margin:20px 0}
.qr-container button{background:#667eea;color:white;border:none;padding:15px 30px;border-radius:10px;cursor:pointer;font-size:16px}
.main-content{display:flex;gap:20px}
.sidebar{width:350px;background:rgba(255,255,255,0.1);border-radius:15px;padding:20px}
.chat-area{flex:1;background:rgba(255,255,255,0.1);border-radius:15px;display:flex;flex-direction:column}
.chat-header{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}
.messages{flex:1;padding:20px;overflow-y:auto;min-height:400px}
.upload-area{border:2px dashed rgba(255,255,255,0.3);border-radius:10px;padding:20px;text-align:center;cursor:pointer;margin:10px 0}
.upload-area:hover{border-color:rgba(255,255,255,0.6);background:rgba(255,255,255,0.1)}
.file-input{display:none}
.input-field{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;margin:10px 0}
.input-field::placeholder{color:rgba(255,255,255,0.7)}
.btn{background:#667eea;color:white;border:none;padding:12px 20px;border-radius:8px;cursor:pointer;width:100%;margin:5px 0}
.btn:hover{background:#5a6fd8}
.btn:disabled{opacity:0.6;cursor:not-allowed}
.section{margin:20px 0}
.section h3{margin-bottom:15px}
.status-text{font-size:12px;padding:8px;background:rgba(255,255,255,0.1);border-radius:8px;margin:10px 0;text-align:center}
.status-text.success{background:rgba(76,175,80,0.2);color:#4CAF50}
.loading{border:3px solid rgba(255,255,255,0.3);border-top:3px solid white;border-radius:50%;width:40px;height:40px;animation:spin 1s linear infinite;margin:20px auto}
@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}
</style>
</head>
<body>
<div class="container">
  <div class="header">
    <div>
      <h1>📱 WhatsApp Interface</h1>
      <div id="session-info">Session: Loading...</div>
    </div>
    <div id="status" class="status status-disconnected">Disconnected</div>
  </div>
  
  <div id="qr-section" class="qr-container" style="display:none">
    <h2>📱 Scan QR Code</h2>
    <div id="qr-image"></div>
    <p>Open WhatsApp → Linked Devices → Link Device</p>
    <button onclick="location.reload()">Refresh</button>
  </div>
  
  <div id="loading-section" class="qr-container">
    <h2>⏳ Initializing...</h2>
    <div class="loading"></div>
    <p>Setting up WhatsApp connection...</p>
  </div>
  
  <div id="main-content" class="main-content" style="display:none">
    <div class="sidebar">
      <div class="section">
        <h3>🍪 YouTube Cookies</h3>
        <div class="upload-area" id="cookies-area">
          <div>🍪 Drop J2Team cookies.json</div>
          <input type="file" id="cookies-input" class="file-input" accept=".json">
        </div>
        <div id="cookies-status" class="status-text">No cookies loaded</div>
      </div>
      
      <div class="section">
        <h3>📎 Files</h3>
        <div class="upload-area" id="files-area">
          <div>📁 Drop files or click</div>
          <input type="file" id="files-input" class="file-input" multiple>
        </div>
        <input type="text" id="url-input" class="input-field" placeholder="Enter URL...">
        <button id="download-btn" class="btn">📥 Download & Send</button>
      </div>
      
      <div class="section">
        <h3>💬 Message</h3>
        <textarea id="message-input" class="input-field" placeholder="Type message..." rows="3"></textarea>
        <button id="send-btn" class="btn">📤 Send</button>
      </div>
    </div>
    
    <div class="chat-area">
      <div class="chat-header">
        <h2>💬 Chat</h2>
        <p id="user-info">Ready to send messages</p>
      </div>
      <div class="messages" id="messages">
        <div style="text-align:center;opacity:0.7;padding:50px">Ready to chat!</div>
      </div>
    </div>
  </div>
</div>

<script>
let sessionId = localStorage.getItem('session-id') || 'session-' + Math.random().toString(36).substr(2, 9) + '-' + Date.now()
localStorage.setItem('session-id', sessionId)

const elements = {
  status: document.getElementById('status'),
  sessionInfo: document.getElementById('session-info'),
  qrSection: document.getElementById('qr-section'),
  loadingSection: document.getElementById('loading-section'),
  mainContent: document.getElementById('main-content'),
  qrImage: document.getElementById('qr-image'),
  cookiesArea: document.getElementById('cookies-area'),
  cookiesInput: document.getElementById('cookies-input'),
  cookiesStatus: document.getElementById('cookies-status'),
  filesArea: document.getElementById('files-area'),
  filesInput: document.getElementById('files-input'),
  urlInput: document.getElementById('url-input'),
  downloadBtn: document.getElementById('download-btn'),
  messageInput: document.getElementById('message-input'),
  userInfo: document.getElementById('user-info'),
  messages: document.getElementById('messages')
}

elements.sessionInfo.textContent = 'Session: ' + sessionId.substr(-8)

elements.cookiesArea.onclick = () => elements.cookiesInput.click()
elements.filesArea.onclick = () => elements.filesInput.click()

elements.cookiesInput.onchange = async (e) => {
  if (!e.target.files[0]) return
  
  try {
    const text = await e.target.files[0].text()
    const data = JSON.parse(text)
    
    if (!data.url || !data.cookies) {
      throw new Error('Invalid format. Need {url, cookies}')
    }
    
    const formData = new FormData()
    formData.append('cookies', e.target.files[0])
    
    const response = await fetch('/api/cookies?session=' + sessionId, {
      method: 'POST',
      body: formData
    })
    
    const result = await response.json()
    if (result.success) {
      elements.cookiesStatus.textContent = '✅ Cookies loaded: ' + data.cookies.length
      elements.cookiesStatus.className = 'status-text success'
    } else {
      throw new Error(result.error)
    }
  } catch (error) {
    elements.cookiesStatus.textContent = '❌ Error: ' + error.message
    elements.cookiesStatus.className = 'status-text'
  }
}

elements.filesInput.onchange = async (e) => {
  for (const file of e.target.files) {
    const formData = new FormData()
    formData.append('file', file)
    
    try {
      await fetch('/api/upload?session=' + sessionId, {
        method: 'POST',
        body: formData
      })
    } catch (error) {
      console.error('Upload error:', error)
    }
  }
}

elements.downloadBtn.onclick = async () => {
  const url = elements.urlInput.value.trim()
  if (!url) return
  
  elements.downloadBtn.textContent = '⏳ Downloading...'
  elements.downloadBtn.disabled = true
  
  try {
    const response = await fetch('/api/download?session=' + sessionId, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({url})
    })
    
    const result = await response.json()
    if (result.success) {
      elements.urlInput.value = ''
    } else {
      alert('Error: ' + result.error)
    }
  } catch (error) {
    alert('Error: ' + error.message)
  } finally {
    elements.downloadBtn.textContent = '📥 Download & Send'
    elements.downloadBtn.disabled = false
  }
}

elements.sendBtn.onclick = async () => {
  const message = elements.messageInput.value.trim()
  if (!message) return
  
  try {
    const response = await fetch('/api/send?session=' + sessionId, {
      method: 'POST',
      headers: {'Content-Type': 'application/json'},
      body: JSON.stringify({message})
    })
    
    const result = await response.json()
    if (result.success) {
      elements.messageInput.value = ''
    }
  } catch (error) {
    console.error('Send error:', error)
  }
}

elements.messageInput.onkeypress = (e) => {
  if (e.key === 'Enter' && !e.shiftKey) {
    e.preventDefault()
    elements.sendBtn.click()
  }
}

async function checkStatus() {
  try {
    const response = await fetch('/api/status?session=' + sessionId)
    const result = await response.json()
    
    if (result.status === 'connected') {
      elements.status.textContent = 'Connected'
      elements.status.className = 'status status-connected'
      elements.qrSection.style.display = 'none'
      elements.loadingSection.style.display = 'none'
      elements.mainContent.style.display = 'flex'
      
      if (result.user) {
        elements.userInfo.textContent = 'Connected as: ' + (result.user.name || result.user.id)
      }
    } else if (result.status === 'qr') {
      elements.status.textContent = 'Scan QR'
      elements.status.className = 'status status-disconnected'
      elements.loadingSection.style.display = 'none'
      elements.mainContent.style.display = 'none'
      elements.qrSection.style.display = 'block'
      
      if (result.qr) {
        elements.qrImage.innerHTML = '<img src="' + result.qr + '" alt="QR Code">'
      }
    } else {
      elements.status.textContent = 'Initializing'
      elements.status.className = 'status status-disconnected'
      elements.qrSection.style.display = 'none'
      elements.mainContent.style.display = 'none'
      elements.loadingSection.style.display = 'block'
    }
  } catch (error) {
    console.error('Status error:', error)
  }
}

checkStatus()
setInterval(checkStatus, 5000)
</script>
</body>
</html>`

fs.writeFileSync("public/index.html", htmlContent)

app.get("/", (req, res) => res.sendFile(join(__dirname, "public", "index.html")))

app.post("/api/cookies", upload.single("cookies"), async (req, res) => {
  try {
    const sessionId = req.query.session || "default"

    if (!req.file) {
      return res.json({ success: false, error: "No file uploaded" })
    }

    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))

    if (!cookiesData.url || !cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
      return res.json({ success: false, error: "Invalid J2Team format - expected {url, cookies} structure" })
    }

    const netscapeCookies = convertJ2TeamToNetscape(cookiesData)
    const cookiesPath = join(__dirname, "cookies", sessionId + ".txt")
    fs.writeFileSync(cookiesPath, netscapeCookies)

    fs.unlinkSync(req.file.path)

    console.log(`Cookies loaded for ${sessionId}: ${cookiesData.cookies.length} cookies from ${cookiesData.url}`)

    res.json({
      success: true,
      message: `Loaded ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    })
  } catch (error) {
    console.error("Cookies error:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    const sessionId = req.query.session || "default"

    if (!sessions.has(sessionId)) {
      return res.json({ success: false, error: "Session not found" })
    }

    const sock = sessions.get(sessionId)
    if (!sock.user) {
      return res.json({ success: false, error: "Not connected" })
    }

    const fileBuffer = fs.readFileSync(req.file.path)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: req.file.originalname,
      mimetype: req.file.mimetype,
    })

    fs.unlinkSync(req.file.path)

    console.log(`File sent: ${req.file.originalname}`)
    res.json({ success: true })
  } catch (error) {
    console.error("Upload error:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.query.session || "default"

    if (!sessions.has(sessionId)) {
      return res.json({ success: false, error: "Session not found" })
    }

    const sock = sessions.get(sessionId)
    if (!sock.user) {
      return res.json({ success: false, error: "Not connected" })
    }

    const tempFile = join(__dirname, "temp", Date.now() + "_download")
    const cookiesPath = join(__dirname, "cookies", sessionId + ".txt")

    let command = `yt-dlp --no-warnings --no-check-certificates --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36" -o "${tempFile}.%(ext)s"`

    if (fs.existsSync(cookiesPath)) {
      command += ` --cookies "${cookiesPath}"`
      console.log(`Using cookies for download: ${sessionId}`)
    }

    command += ` "${url}"`

    console.log(`Downloading: ${url}`)
    await execAsync(command)

    const files = fs.readdirSync(join(__dirname, "temp")).filter((f) => f.startsWith(path.basename(tempFile)))

    if (files.length === 0) {
      throw new Error("Download failed - no file created")
    }

    const downloadedFile = join(__dirname, "temp", files[0])
    const fileBuffer = fs.readFileSync(downloadedFile)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: files[0],
      mimetype: "application/octet-stream",
    })

    fs.unlinkSync(downloadedFile)

    console.log(`Downloaded and sent: ${files[0]}`)
    res.json({ success: true })
  } catch (error) {
    console.error("Download error:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/send", async (req, res) => {
  try {
    const { message } = req.body
    const sessionId = req.query.session || "default"

    if (!sessions.has(sessionId)) {
      return res.json({ success: false, error: "Session not found" })
    }

    const sock = sessions.get(sessionId)
    if (!sock.user) {
      return res.json({ success: false, error: "Not connected" })
    }

    await sock.sendMessage(sock.user.id, { text: message })

    console.log(`Message sent: ${message.substring(0, 50)}...`)
    res.json({ success: true })
  } catch (error) {
    console.error("Send error:", error)
    res.json({ success: false, error: error.message })
  }
})

app.get("/api/status", (req, res) => {
  try {
    const sessionId = req.query.session || "default"

    if (sessions.has(sessionId)) {
      const sock = sessions.get(sessionId)
      if (sock.user) {
        return res.json({
          status: "connected",
          user: { id: sock.user.id, name: sock.user.name },
        })
      }
    }

    if (qrCodes.has(sessionId)) {
      return res.json({
        status: "qr",
        qr: qrCodes.get(sessionId),
      })
    }

    if (!sessions.has(sessionId) && !sessionLocks.has(sessionId)) {
      createSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    console.error("Status error:", error)
    res.json({ status: "error", error: error.message })
  }
})

async function createSession(sessionId) {
  if (sessions.has(sessionId) || sessionLocks.has(sessionId)) {
    return
  }

  sessionLocks.set(sessionId, true)

  try {
    console.log(`Creating session: ${sessionId}`)

    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      browser: Browsers.macOS("Desktop"),
      connectTimeoutMs: 120000,
      defaultQueryTimeoutMs: 120000,
      keepAliveIntervalMs: 30000,
      markOnlineOnConnect: false,
      syncFullHistory: false,
      generateHighQualityLinkPreview: false,
      patchMessageBeforeSending: (message) => {
        const requiresPatch = !!(message.buttonsMessage || message.templateMessage || message.listMessage)
        if (requiresPatch) {
          message = {
            viewOnceMessage: {
              message: {
                messageContextInfo: {
                  deviceListMetadataVersion: 2,
                  deviceListMetadata: {},
                },
                ...message,
              },
            },
          }
        }
        return message
      },
    })

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        console.log(`QR generated for ${sessionId}`)
        try {
          const qrDataURL = await qrcode.toDataURL(qr, { scale: 8, margin: 2 })
          qrCodes.set(sessionId, qrDataURL)
        } catch (qrError) {
          console.error("QR generation error:", qrError)
        }
      }

      if (connection === "close") {
        const statusCode = lastDisconnect?.error?.output?.statusCode
        console.log(`Connection closed for ${sessionId}: ${lastDisconnect?.error?.message} (${statusCode})`)

        sessions.delete(sessionId)
        qrCodes.delete(sessionId)
        sessionLocks.delete(sessionId)

        if (statusCode === 401) {
          console.log(`Session ${sessionId} logged out - cleaning up`)
          try {
            fs.rmSync(sessionDir, { recursive: true, force: true })
          } catch (cleanupError) {
            console.error("Cleanup error:", cleanupError)
          }
        } else if (statusCode !== 440) {
          console.log(`Reconnecting ${sessionId} in 30 seconds...`)
          setTimeout(() => {
            if (!sessions.has(sessionId) && !sessionLocks.has(sessionId)) {
              createSession(sessionId)
            }
          }, 30000)
        }
      } else if (connection === "open") {
        console.log(`Connected: ${sessionId} - ${sock.user.name} (${sock.user.id})`)
        qrCodes.delete(sessionId)
        sessionLocks.delete(sessionId)
      }
    })

    sock.ev.on("creds.update", saveCreds)

    sessions.set(sessionId, sock)
  } catch (error) {
    console.error(`Error creating session ${sessionId}:`, error)
    sessions.delete(sessionId)
    qrCodes.delete(sessionId)
    sessionLocks.delete(sessionId)
  }
}

try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  https.createServer(options, app).listen(CONFIG.PORT, () => {
    console.log(`Server running on https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
  })
} catch (error) {
  console.error("HTTPS error:", error)
  app.listen(CONFIG.PORT, () => {
    console.log(`HTTP server on port ${CONFIG.PORT}`)
  })
}

setInterval(() => {
  const tempDir = join(__dirname, "temp")
  try {
    const files = fs.readdirSync(tempDir)
    const now = Date.now()
    files.forEach((file) => {
      const filePath = join(tempDir, file)
      const stats = fs.statSync(filePath)
      if (now - stats.mtime.getTime() > 3600000) {
        fs.unlinkSync(filePath)
      }
    })
  } catch (error) {}
}, 3600000)

process.on("uncaughtException", (err) => {
  console.error("Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err)
})

process.on("SIGINT", () => {
  console.log("Shutting down...")
  for (const [sessionId, sock] of sessions) {
    try {
      sock.end()
    } catch (error) {}
  }
  process.exit(0)
})
