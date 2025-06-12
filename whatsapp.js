const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys")
import express from "express"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
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

const activeSessions = new Map()
const sessionStates = new Map()
const waitingQueue = []
const mediaCache = new Map()
const cookiesStorage = new Map()
const formatCache = new Map()

const userAgents = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0",
]

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
  return userAgents[Math.floor(Math.random() * userAgents.length)]
}

function createBrowserHeaders(userAgent, referer = null) {
  const headers = {
    "User-Agent": userAgent,
    Accept: "text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8",
    "Accept-Language": "en-US,en;q=0.9,es;q=0.8",
    "Accept-Encoding": "gzip, deflate, br",
    DNT: "1",
    Connection: "keep-alive",
    "Upgrade-Insecure-Requests": "1",
    "Sec-Fetch-Dest": "document",
    "Sec-Fetch-Mode": "navigate",
    "Sec-Fetch-Site": "none",
    "Sec-Fetch-User": "?1",
    "Cache-Control": "max-age=0",
  }
  if (referer) headers["Referer"] = referer
  return headers
}

function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n"
  netscapeFormat += "# This is a generated file! Do not edit.\n\n"

  cookies.forEach((cookie) => {
    const domain = cookie.domain || ""
    const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
    const path = cookie.path || "/"
    const secure = cookie.secure === true || cookie.secure === "true" ? "TRUE" : "FALSE"

    let expiration = cookie.expirationDate || cookie.expires || Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
    expiration = Math.floor(Number(expiration))

    const name = cookie.name || ""
    const value = cookie.value || ""

    if (domain && name) {
      netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
    }
  })

  return netscapeFormat
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionId = req.headers["session-id"] || req.query.session
    const sessionDir = join(__dirname, "uploads", sessionId || "temp")
    fs.mkdirSync(sessionDir, { recursive: true })
    cb(null, sessionDir)
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + "-" + file.originalname)
  },
})

const upload = multer({ storage: storage })

app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

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

const htmlContent = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>WhatsApp Personal Interface</title><style>*{margin:0;padding:0;box-sizing:border-box;font-family:"Segoe UI",Tahoma,Geneva,Verdana,sans-serif}body{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh}.container{max-width:1400px;margin:0 auto;height:100vh;display:flex;flex-direction:column;padding:20px}header{background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);color:white;padding:20px;border-radius:15px;margin-bottom:20px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.session-info{font-size:12px;opacity:0.8;max-width:300px;word-break:break-all}.settings-btn{background:rgba(255,255,255,0.2);border:none;color:white;padding:8px 12px;border-radius:8px;cursor:pointer;font-size:14px;margin-left:10px}.settings-btn:hover{background:rgba(255,255,255,0.3)}.status-connected{background:linear-gradient(45deg,#4CAF50,#45a049);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(76,175,80,0.3)}.status-disconnected{background:linear-gradient(45deg,#f44336,#d32f2f);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(244,67,54,0.3)}.status-waiting{background:linear-gradient(45deg,#ff9800,#f57c00);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(255,152,0,0.3)}.status-downloading{background:linear-gradient(45deg,#2196F3,#1976D2);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(33,150,243,0.3)}.main-content{display:flex;height:calc(100vh - 140px);gap:20px}.sidebar{width:350px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.cookies-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.cookies-section h3{color:white;margin-bottom:15px;font-size:18px}.cookies-upload-area{border:2px dashed rgba(255,255,255,0.3);border-radius:10px;padding:20px;text-align:center;cursor:pointer;transition:all 0.3s ease;margin-bottom:15px}.cookies-upload-area:hover{border-color:rgba(255,255,255,0.6);background:rgba(255,255,255,0.1)}.cookies-upload-area.dragover{border-color:#4CAF50;background:rgba(76,175,80,0.1)}.cookies-status{font-size:12px;color:rgba(255,255,255,0.8);text-align:center;margin-top:10px;padding:8px;border-radius:8px;background:rgba(255,255,255,0.1)}.cookies-status.loaded{background:rgba(76,175,80,0.2);color:#4CAF50}.file-upload-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.file-upload-section h3{color:white;margin-bottom:15px;font-size:18px}.upload-area{border:2px dashed rgba(255,255,255,0.3);border-radius:10px;padding:20px;text-align:center;cursor:pointer;transition:all 0.3s ease;margin-bottom:15px}.upload-area:hover{border-color:rgba(255,255,255,0.6);background:rgba(255,255,255,0.1)}.upload-area.dragover{border-color:#4CAF50;background:rgba(76,175,80,0.1)}.upload-text{color:white;font-size:14px}.file-input{display:none}.url-section{margin-top:15px}.url-input{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;placeholder-color:rgba(255,255,255,0.7);margin-bottom:10px}.url-input::placeholder{color:rgba(255,255,255,0.7)}.btn{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:12px 20px;border-radius:8px;cursor:pointer;font-size:14px;transition:all 0.3s ease;width:100%}.btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.btn:disabled{opacity:0.6;cursor:not-allowed;transform:none}.auto-download-info{font-size:12px;color:rgba(255,255,255,0.7);margin-top:5px;text-align:center}.download-progress{width:100%;height:4px;background:rgba(255,255,255,0.2);border-radius:2px;margin:10px 0;overflow:hidden}.download-progress-bar{height:100%;background:linear-gradient(45deg,#4CAF50,#45a049);width:0%;transition:width 0.3s ease}.message-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.message-section h3{color:white;margin-bottom:15px;font-size:18px}.message-input{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;resize:none;height:80px;margin-bottom:10px}.message-input::placeholder{color:rgba(255,255,255,0.7)}.chat-area{flex:1;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.chat-header{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2);color:white}.messages{flex:1;padding:20px;overflow-y:auto;display:flex;flex-direction:column}.message{max-width:70%;padding:15px 20px;margin-bottom:15px;border-radius:18px;position:relative;word-wrap:break-word;align-self:flex-end;background:linear-gradient(45deg,#667eea,#764ba2);color:white;box-shadow:0 4px 15px rgba(102,126,234,0.3)}.message-time{font-size:11px;opacity:0.8;text-align:right;margin-top:8px}.message-media{max-width:100%;max-height:300px;margin:10px 0;border-radius:10px;box-shadow:0 4px 15px rgba(0,0,0,0.2)}.message-file{background:rgba(255,255,255,0.2);padding:15px;border-radius:10px;margin:10px 0;display:flex;align-items:center;gap:10px}.file-icon{width:40px;height:40px;background:rgba(255,255,255,0.3);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:18px}.file-info{flex:1}.file-name{font-weight:bold;margin-bottom:5px}.file-size{font-size:12px;opacity:0.8}.download-btn{background:rgba(255,255,255,0.2);border:none;color:white;padding:8px 15px;border-radius:6px;cursor:pointer;font-size:12px}.qr-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.qr-container h1{color:white;margin-bottom:20px;font-size:24px}.qr-container img{max-width:300px;border-radius:15px;margin:20px 0;box-shadow:0 8px 25px rgba(0,0,0,0.3)}.qr-container button{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:15px 30px;border-radius:10px;cursor:pointer;font-size:16px;transition:all 0.3s ease}.qr-container button:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.loading-spinner{border:3px solid rgba(255,255,255,0.3);border-radius:50%;border-top:3px solid white;width:40px;height:40px;animation:spin 1s linear infinite;margin:20px auto}@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}.waiting-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37);color:white}.queue-position{font-size:48px;font-weight:bold;margin:20px 0;color:#ff9800}.url-type-indicator{font-size:12px;color:rgba(255,255,255,0.8);margin-top:5px;padding:5px 10px;background:rgba(255,255,255,0.1);border-radius:15px;display:inline-block}.settings-modal{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:none;justify-content:center;align-items:center;z-index:1000}.settings-content{background:rgba(255,255,255,0.1);backdrop-filter:blur(20px);border-radius:20px;padding:30px;max-width:500px;width:90%;color:white}.settings-content h2{margin-bottom:20px;text-align:center}.setting-item{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding:15px;background:rgba(255,255,255,0.1);border-radius:10px}.setting-label{flex:1;margin-right:15px}.setting-description{font-size:12px;opacity:0.8;margin-top:5px}.toggle-switch{position:relative;width:60px;height:30px;background:rgba(255,255,255,0.3);border-radius:15px;cursor:pointer;transition:all 0.3s ease}.toggle-switch.active{background:#4CAF50}.toggle-slider{position:absolute;top:3px;left:3px;width:24px;height:24px;background:white;border-radius:50%;transition:all 0.3s ease}.toggle-switch.active .toggle-slider{transform:translateX(30px)}.close-settings{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:12px 30px;border-radius:10px;cursor:pointer;font-size:16px;width:100%;margin-top:20px}.no-messages{text-align:center;color:rgba(255,255,255,0.7);padding:50px;font-size:16px}.youtube-cookies-required{background:rgba(255,193,7,0.2);border:1px solid rgba(255,193,7,0.5);border-radius:10px;padding:15px;margin:10px 0;color:#ffc107;font-size:14px;text-align:center}.format-modal{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:none;justify-content:center;align-items:center;z-index:1000}.format-content{background:rgba(255,255,255,0.1);backdrop-filter:blur(20px);border-radius:20px;padding:30px;max-width:600px;width:90%;color:white;max-height:80vh;overflow-y:auto}.format-content h2{margin-bottom:20px;text-align:center}.format-tabs{display:flex;margin-bottom:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.format-tab{padding:10px 20px;cursor:pointer;border-bottom:3px solid transparent;transition:all 0.3s ease;flex:1;text-align:center}.format-tab.active{border-bottom:3px solid #4CAF50;background:rgba(76,175,80,0.1)}.format-list{max-height:50vh;overflow-y:auto;padding-right:10px}.format-item{padding:15px;margin-bottom:10px;background:rgba(255,255,255,0.1);border-radius:10px;cursor:pointer;transition:all 0.3s ease;display:flex;flex-direction:column}.format-item:hover{background:rgba(255,255,255,0.2)}.format-item.selected{background:rgba(76,175,80,0.2);border:1px solid #4CAF50}.format-info{display:flex;justify-content:space-between;margin-bottom:5px}.format-quality{font-weight:bold}.format-size{opacity:0.8;font-size:12px}.format-details{font-size:12px;opacity:0.8}.format-buttons{display:flex;gap:10px;margin-top:20px}.format-button{flex:1;padding:12px;border:none;border-radius:10px;cursor:pointer;font-size:14px;transition:all 0.3s ease}.format-cancel{background:rgba(255,255,255,0.2);color:white}.format-download{background:linear-gradient(45deg,#4CAF50,#45a049);color:white}.format-download:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(76,175,80,0.4)}.format-cancel:hover{background:rgba(255,255,255,0.3)}.format-loading{text-align:center;padding:30px}.format-error{background:rgba(244,67,54,0.2);border:1px solid rgba(244,67,54,0.5);border-radius:10px;padding:15px;margin:20px 0;color:#f44336;text-align:center}@media (max-width:768px){.main-content{flex-direction:column}.sidebar{width:100%;height:auto}.session-info{max-width:200px;font-size:10px}}</style></head><body><div class="container"><header><div><h1>📱 Personal WhatsApp Interface</h1><div class="session-info" id="session-info">Session: Loading...</div></div><div style="display: flex; align-items: center;"><div id="status" class="status-disconnected">Disconnected</div><button class="settings-btn" onclick="openSettings()">⚙️</button></div></header><div id="waiting-section" class="waiting-container" style="display: none;"><h1>⏳ Queue Full</h1><div class="queue-position" id="queue-position">0</div><p>You are in position <span id="position-text">0</span> in the queue</p><p>Maximum <span id="max-sessions">10</span> sessions allowed simultaneously</p><div class="loading-spinner"></div></div><div id="qr-section" class="qr-container" style="display: none;"><h1>📱 Scan with WhatsApp</h1><div id="qr-image"></div><p>Open WhatsApp → Linked Devices → Link Device</p><button onclick="location.reload()">Refresh QR</button></div><div id="loading-section" class="qr-container"><h1>⏳ Initializing...</h1><div class="loading-spinner"></div><p>Please wait while we set up your WhatsApp interface</p></div><div id="main-content" class="main-content" style="display: none;"><div class="sidebar"><div class="cookies-section"><h3>🍪 YouTube Cookies</h3><div class="cookies-upload-area" id="cookies-upload-area"><div class="upload-text"><div style="font-size: 24px; margin-bottom: 10px;">🍪</div><div>Drop J2Team cookies.json here</div><div style="font-size: 12px; margin-top: 5px;">Required for YouTube downloads</div></div><input type="file" id="cookies-input" class="file-input" accept=".json"></div><div id="cookies-status" class="cookies-status">No cookies loaded - YouTube downloads disabled</div></div><div class="file-upload-section"><h3>📎 Send Files</h3><div class="upload-area" id="upload-area"><div class="upload-text"><div style="font-size: 24px; margin-bottom: 10px;">📁</div><div>Drop files here or click to select</div><div style="font-size: 12px; margin-top: 5px;">Images, videos, audio, documents</div></div><input type="file" id="file-input" class="file-input" multiple accept="*/*"></div><div class="url-section"><input type="text" id="url-input" class="url-input" placeholder="Enter URL to auto-download and send..."><div id="url-type" class="url-type-indicator" style="display: none;"></div><div id="youtube-cookies-warning" class="youtube-cookies-required" style="display: none;">🍪 YouTube cookies required. Upload J2Team cookies.json above.</div><div class="download-progress" id="download-progress" style="display: none;"><div class="download-progress-bar" id="download-progress-bar"></div></div><button id="download-send-btn" class="btn">📥 Download & Send</button><div class="auto-download-info">Auto-download starts in 7 seconds after URL entry</div></div></div><div class="message-section"><h3>💬 Send Message</h3><textarea id="message-input" class="message-input" placeholder="Type your message..."></textarea><button id="send-message-btn" class="btn">📤 Send Message</button></div></div><div class="chat-area"><div class="chat-header"><h2>💬 My Messages</h2><p id="user-info">Personal chat with myself</p></div><div class="messages" id="messages"><div class="no-messages" id="no-messages">📱 Messages disabled by default to save data<br>Enable in settings to view messages</div></div></div></div></div><div id="settings-modal" class="settings-modal"><div class="settings-content"><h2>⚙️ Settings</h2><div class="setting-item"><div class="setting-label"><strong>Show Messages</strong><div class="setting-description">Display sent/received messages in chat area</div></div><div class="toggle-switch" id="show-messages-toggle"><div class="toggle-slider"></div></div></div><div class="setting-item"><div class="setting-label"><strong>Download Media</strong><div class="setting-description">Download and display media files in browser</div></div><div class="toggle-switch" id="download-media-toggle"><div class="toggle-slider"></div></div></div><div class="setting-item"><div class="setting-label"><strong>Auto-Delete Files</strong><div class="setting-description">Automatically delete files after sending (Always enabled)</div></div><div class="toggle-switch active"><div class="toggle-slider"></div></div></div><button class="close-settings" onclick="closeSettings()">Close Settings</button></div></div><div id="format-modal" class="format-modal"><div class="format-content"><h2>Select Format</h2><div class="format-tabs"><div class="format-tab active" data-tab="video">Video</div><div class="format-tab" data-tab="audio">Audio</div></div><div id="format-loading" class="format-loading"><div class="loading-spinner"></div><p>Loading available formats...</p></div><div id="format-error" class="format-error" style="display: none;">Error loading formats. Please try again.</div><div id="video-formats" class="format-list"></div><div id="audio-formats" class="format-list" style="display: none;"></div><div class="format-buttons"><button class="format-button format-cancel" id="format-cancel">Cancel</button><button class="format-button format-download" id="format-download">Download & Send</button></div></div></div><script>function updateUrlWithSession(sessionId){const url=new URL(window.location);url.searchParams.set('session',sessionId);window.history.replaceState({},'',url)}function getSessionFromUrl(){const urlParams=new URLSearchParams(window.location.search);return urlParams.get('session')}function generateSecureSessionId(){const timestamp=Date.now().toString(36),randomBytes=Array.from(crypto.getRandomValues(new Uint8Array(32)),b=>b.toString(16).padStart(2,'0')).join(''),combined=timestamp+randomBytes;return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g,'').substring(0,48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)),b=>b.toString(16).padStart(2,'0')).join('')}\`}let sessionId=getSessionFromUrl()||generateSecureSessionId();updateUrlWithSession(sessionId);let settings={showMessages:${CONFIG.SHOW_MESSAGES_BY_DEFAULT},downloadMedia:${CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT},autoDelete:${CONFIG.AUTO_DELETE_AFTER_SEND}};let hasCookies=false,currentUrl="",selectedFormat=null,availableFormats={video:[],audio:[]};function loadSettings(){const saved=localStorage.getItem('whatsapp-settings');if(saved)settings={...settings,...JSON.parse(saved)};updateSettingsUI()}function saveSettings(){localStorage.setItem('whatsapp-settings',JSON.stringify(settings))}function updateSettingsUI(){const showMessagesToggle=document.getElementById('show-messages-toggle'),downloadMediaToggle=document.getElementById('download-media-toggle');if(settings.showMessages)showMessagesToggle.classList.add('active');else showMessagesToggle.classList.remove('active');if(settings.downloadMedia)downloadMediaToggle.classList.add('active');else downloadMediaToggle.classList.remove('active');updateMessagesDisplay()}function updateMessagesDisplay(){const messagesContainer=document.getElementById('messages'),noMessagesDiv=document.getElementById('no-messages');if(!settings.showMessages){messagesContainer.innerHTML='';messagesContainer.appendChild(noMessagesDiv);noMessagesDiv.style.display='block'}else{noMessagesDiv.style.display='none';loadMessages()}}function openSettings(){document.getElementById('settings-modal').style.display='flex'}function closeSettings(){document.getElementById('settings-modal').style.display='none'}document.getElementById('show-messages-toggle').addEventListener('click',function(){settings.showMessages=!settings.showMessages;saveSettings();updateSettingsUI()});document.getElementById('download-media-toggle').addEventListener('click',function(){settings.downloadMedia=!settings.downloadMedia;saveSettings();updateSettingsUI()});document.getElementById('format-cancel').addEventListener('click',function(){closeFormatModal()});document.getElementById('format-download').addEventListener('click',function(){downloadAndSendFormat()});function closeFormatModal(){document.getElementById('format-modal').style.display='none'}function downloadAndSendFormat(){// Function implementation here}function loadMessages(){// Function implementation here}</script></body></html>`

app.get("/", (req, res) => {
  res.send(htmlContent)
})

app.listen(CONFIG.PORT, () => {
  console.log(`Server running on https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
})
