const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys");

import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
import https from "https"
import bodyParser from "body-parser"
import multer from "multer"
import path from "path"
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

const htmlContent = `<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0"><title>WhatsApp Personal Interface</title><style>*{margin:0;padding:0;box-sizing:border-box;font-family:"Segoe UI",Tahoma,Geneva,Verdana,sans-serif}body{background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);min-height:100vh}.container{max-width:1400px;margin:0 auto;height:100vh;display:flex;flex-direction:column;padding:20px}header{background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);color:white;padding:20px;border-radius:15px;margin-bottom:20px;display:flex;justify-content:space-between;align-items:center;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.session-info{font-size:12px;opacity:0.8;max-width:300px;word-break:break-all}.settings-btn{background:rgba(255,255,255,0.2);border:none;color:white;padding:8px 12px;border-radius:8px;cursor:pointer;font-size:14px;margin-left:10px}.settings-btn:hover{background:rgba(255,255,255,0.3)}.status-connected{background:linear-gradient(45deg,#4CAF50,#45a049);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(76,175,80,0.3)}.status-disconnected{background:linear-gradient(45deg,#f44336,#d32f2f);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(244,67,54,0.3)}.status-waiting{background:linear-gradient(45deg,#ff9800,#f57c00);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(255,152,0,0.3)}.status-downloading{background:linear-gradient(45deg,#2196F3,#1976D2);padding:8px 16px;border-radius:20px;font-size:14px;box-shadow:0 4px 15px rgba(33,150,243,0.3)}.main-content{display:flex;height:calc(100vh - 140px);gap:20px}.sidebar{width:350px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.cookies-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.cookies-section h3{color:white;margin-bottom:15px;font-size:18px}.cookies-upload-area{border:2px dashed rgba(255,255,255,0.3);border-radius:10px;padding:20px;text-align:center;cursor:pointer;transition:all 0.3s ease;margin-bottom:15px}.cookies-upload-area:hover{border-color:rgba(255,255,255,0.6);background:rgba(255,255,255,0.1)}.cookies-upload-area.dragover{border-color:#4CAF50;background:rgba(76,175,80,0.1)}.cookies-status{font-size:12px;color:rgba(255,255,255,0.8);text-align:center;margin-top:10px;padding:8px;border-radius:8px;background:rgba(255,255,255,0.1)}.cookies-status.loaded{background:rgba(76,175,80,0.2);color:#4CAF50}.file-upload-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.file-upload-section h3{color:white;margin-bottom:15px;font-size:18px}.upload-area{border:2px dashed rgba(255,255,255,0.3);border-radius:10px;padding:20px;text-align:center;cursor:pointer;transition:all 0.3s ease;margin-bottom:15px}.upload-area:hover{border-color:rgba(255,255,255,0.6);background:rgba(255,255,255,0.1)}.upload-area.dragover{border-color:#4CAF50;background:rgba(76,175,80,0.1)}.upload-text{color:white;font-size:14px}.file-input{display:none}.url-section{margin-top:15px}.url-input{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;placeholder-color:rgba(255,255,255,0.7);margin-bottom:10px}.url-input::placeholder{color:rgba(255,255,255,0.7)}.btn{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:12px 20px;border-radius:8px;cursor:pointer;font-size:14px;transition:all 0.3s ease;width:100%}.btn:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.btn:disabled{opacity:0.6;cursor:not-allowed;transform:none}.auto-download-info{font-size:12px;color:rgba(255,255,255,0.7);margin-top:5px;text-align:center}.download-progress{width:100%;height:4px;background:rgba(255,255,255,0.2);border-radius:2px;margin:10px 0;overflow:hidden}.download-progress-bar{height:100%;background:linear-gradient(45deg,#4CAF50,#45a049);width:0%;transition:width 0.3s ease}.message-section{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.message-section h3{color:white;margin-bottom:15px;font-size:18px}.message-input{width:100%;padding:12px;border:none;border-radius:8px;background:rgba(255,255,255,0.2);color:white;resize:none;height:80px;margin-bottom:10px}.message-input::placeholder{color:rgba(255,255,255,0.7)}.chat-area{flex:1;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);border-radius:15px;display:flex;flex-direction:column;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.chat-header{padding:20px;border-bottom:1px solid rgba(255,255,255,0.2);color:white}.messages{flex:1;padding:20px;overflow-y:auto;display:flex;flex-direction:column}.message{max-width:70%;padding:15px 20px;margin-bottom:15px;border-radius:18px;position:relative;word-wrap:break-word;align-self:flex-end;background:linear-gradient(45deg,#667eea,#764ba2);color:white;box-shadow:0 4px 15px rgba(102,126,234,0.3)}.message-time{font-size:11px;opacity:0.8;text-align:right;margin-top:8px}.message-media{max-width:100%;max-height:300px;margin:10px 0;border-radius:10px;box-shadow:0 4px 15px rgba(0,0,0,0.2)}.message-file{background:rgba(255,255,255,0.2);padding:15px;border-radius:10px;margin:10px 0;display:flex;align-items:center;gap:10px}.file-icon{width:40px;height:40px;background:rgba(255,255,255,0.3);border-radius:8px;display:flex;align-items:center;justify-content:center;font-size:18px}.file-info{flex:1}.file-name{font-weight:bold;margin-bottom:5px}.file-size{font-size:12px;opacity:0.8}.download-btn{background:rgba(255,255,255,0.2);border:none;color:white;padding:8px 15px;border-radius:6px;cursor:pointer;font-size:12px}.qr-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37)}.qr-container h1{color:white;margin-bottom:20px;font-size:24px}.qr-container img{max-width:300px;border-radius:15px;margin:20px 0;box-shadow:0 8px 25px rgba(0,0,0,0.3)}.qr-container button{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:15px 30px;border-radius:10px;cursor:pointer;font-size:16px;transition:all 0.3s ease}.qr-container button:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(102,126,234,0.4)}.loading-spinner{border:3px solid rgba(255,255,255,0.3);border-radius:50%;border-top:3px solid white;width:40px;height:40px;animation:spin 1s linear infinite;margin:20px auto}@keyframes spin{0%{transform:rotate(0deg)}100%{transform:rotate(360deg)}}.waiting-container{text-align:center;padding:50px;background:rgba(255,255,255,0.1);backdrop-filter:blur(10px);margin:20px;border-radius:15px;box-shadow:0 8px 32px rgba(31,38,135,0.37);color:white}.queue-position{font-size:48px;font-weight:bold;margin:20px 0;color:#ff9800}.url-type-indicator{font-size:12px;color:rgba(255,255,255,0.8);margin-top:5px;padding:5px 10px;background:rgba(255,255,255,0.1);border-radius:15px;display:inline-block}.settings-modal{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:none;justify-content:center;align-items:center;z-index:1000}.settings-content{background:rgba(255,255,255,0.1);backdrop-filter:blur(20px);border-radius:20px;padding:30px;max-width:500px;width:90%;color:white}.settings-content h2{margin-bottom:20px;text-align:center}.setting-item{display:flex;justify-content:space-between;align-items:center;margin-bottom:20px;padding:15px;background:rgba(255,255,255,0.1);border-radius:10px}.setting-label{flex:1;margin-right:15px}.setting-description{font-size:12px;opacity:0.8;margin-top:5px}.toggle-switch{position:relative;width:60px;height:30px;background:rgba(255,255,255,0.3);border-radius:15px;cursor:pointer;transition:all 0.3s ease}.toggle-switch.active{background:#4CAF50}.toggle-slider{position:absolute;top:3px;left:3px;width:24px;height:24px;background:white;border-radius:50%;transition:all 0.3s ease}.toggle-switch.active .toggle-slider{transform:translateX(30px)}.close-settings{background:linear-gradient(45deg,#667eea,#764ba2);color:white;border:none;padding:12px 30px;border-radius:10px;cursor:pointer;font-size:16px;width:100%;margin-top:20px}.no-messages{text-align:center;color:rgba(255,255,255,0.7);padding:50px;font-size:16px}.youtube-cookies-required{background:rgba(255,193,7,0.2);border:1px solid rgba(255,193,7,0.5);border-radius:10px;padding:15px;margin:10px 0;color:#ffc107;font-size:14px;text-align:center}.format-modal{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.8);display:none;justify-content:center;align-items:center;z-index:1000}.format-content{background:rgba(255,255,255,0.1);backdrop-filter:blur(20px);border-radius:20px;padding:30px;max-width:600px;width:90%;color:white;max-height:80vh;overflow-y:auto}.format-content h2{margin-bottom:20px;text-align:center}.format-tabs{display:flex;margin-bottom:20px;border-bottom:1px solid rgba(255,255,255,0.2)}.format-tab{padding:10px 20px;cursor:pointer;border-bottom:3px solid transparent;transition:all 0.3s ease;flex:1;text-align:center}.format-tab.active{border-bottom:3px solid #4CAF50;background:rgba(76,175,80,0.1)}.format-list{max-height:50vh;overflow-y:auto;padding-right:10px}.format-item{padding:15px;margin-bottom:10px;background:rgba(255,255,255,0.1);border-radius:10px;cursor:pointer;transition:all 0.3s ease;display:flex;flex-direction:column}.format-item:hover{background:rgba(255,255,255,0.2)}.format-item.selected{background:rgba(76,175,80,0.2);border:1px solid #4CAF50}.format-info{display:flex;justify-content:space-between;margin-bottom:5px}.format-quality{font-weight:bold}.format-size{opacity:0.8;font-size:12px}.format-details{font-size:12px;opacity:0.8}.format-buttons{display:flex;gap:10px;margin-top:20px}.format-button{flex:1;padding:12px;border:none;border-radius:10px;cursor:pointer;font-size:14px;transition:all 0.3s ease}.format-cancel{background:rgba(255,255,255,0.2);color:white}.format-download{background:linear-gradient(45deg,#4CAF50,#45a049);color:white}.format-download:hover{transform:translateY(-2px);box-shadow:0 8px 25px rgba(76,175,80,0.4)}.format-cancel:hover{background:rgba(255,255,255,0.3)}.format-loading{text-align:center;padding:30px}.format-error{background:rgba(244,67,54,0.2);border:1px solid rgba(244,67,54,0.5);border-radius:10px;padding:15px;margin:20px 0;color:#f44336;text-align:center}@media (max-width:768px){.main-content{flex-direction:column}.sidebar{width:100%;height:auto}.session-info{max-width:200px;font-size:10px}}</style></head><body><div class="container"><header><div><h1>📱 Personal WhatsApp Interface</h1><div class="session-info" id="session-info">Session: Loading...</div></div><div style="display: flex; align-items: center;"><div id="status" class="status-disconnected">Disconnected</div><button class="settings-btn" onclick="openSettings()">⚙️</button></div></header><div id="waiting-section" class="waiting-container" style="display: none;"><h1>⏳ Queue Full</h1><div class="queue-position" id="queue-position">0</div><p>You are in position <span id="position-text">0</span> in the queue</p><p>Maximum <span id="max-sessions">10</span> sessions allowed simultaneously</p><div class="loading-spinner"></div></div><div id="qr-section" class="qr-container" style="display: none;"><h1>📱 Scan with WhatsApp</h1><div id="qr-image"></div><p>Open WhatsApp → Linked Devices → Link Device</p><button onclick="location.reload()">Refresh QR</button></div><div id="loading-section" class="qr-container"><h1>⏳ Initializing...</h1><div class="loading-spinner"></div><p>Please wait while we set up your WhatsApp interface</p></div><div id="main-content" class="main-content" style="display: none;"><div class="sidebar"><div class="cookies-section"><h3>🍪 YouTube Cookies</h3><div class="cookies-upload-area" id="cookies-upload-area"><div class="upload-text"><div style="font-size: 24px; margin-bottom: 10px;">🍪</div><div>Drop J2Team cookies.json here</div><div style="font-size: 12px; margin-top: 5px;">Required for YouTube downloads</div></div><input type="file" id="cookies-input" class="file-input" accept=".json"></div><div id="cookies-status" class="cookies-status">No cookies loaded - YouTube downloads disabled</div></div><div class="file-upload-section"><h3>📎 Send Files</h3><div class="upload-area" id="upload-area"><div class="upload-text"><div style="font-size: 24px; margin-bottom: 10px;">📁</div><div>Drop files here or click to select</div><div style="font-size: 12px; margin-top: 5px;">Images, videos, audio, documents</div></div><input type="file" id="file-input" class="file-input" multiple accept="*/*"></div><div class="url-section"><input type="text" id="url-input" class="url-input" placeholder="Enter URL to auto-download and send..."><div id="url-type" class="url-type-indicator" style="display: none;"></div><div id="youtube-cookies-warning" class="youtube-cookies-required" style="display: none;">🍪 YouTube cookies required. Upload J2Team cookies.json above.</div><div class="download-progress" id="download-progress" style="display: none;"><div class="download-progress-bar" id="download-progress-bar"></div></div><button id="download-send-btn" class="btn">📥 Download & Send</button><div class="auto-download-info">Auto-download starts in 7 seconds after URL entry</div></div></div><div class="message-section"><h3>💬 Send Message</h3><textarea id="message-input" class="message-input" placeholder="Type your message..."></textarea><button id="send-message-btn" class="btn">📤 Send Message</button></div></div><div class="chat-area"><div class="chat-header"><h2>💬 My Messages</h2><p id="user-info">Personal chat with myself</p></div><div class="messages" id="messages"><div class="no-messages" id="no-messages">📱 Messages disabled by default to save data<br>Enable in settings to view messages</div></div></div></div></div><div id="settings-modal" class="settings-modal"><div class="settings-content"><h2>⚙️ Settings</h2><div class="setting-item"><div class="setting-label"><strong>Show Messages</strong><div class="setting-description">Display sent/received messages in chat area</div></div><div class="toggle-switch" id="show-messages-toggle"><div class="toggle-slider"></div></div></div><div class="setting-item"><div class="setting-label"><strong>Download Media</strong><div class="setting-description">Download and display media files in browser</div></div><div class="toggle-switch" id="download-media-toggle"><div class="toggle-slider"></div></div></div><div class="setting-item"><div class="setting-label"><strong>Auto-Delete Files</strong><div class="setting-description">Automatically delete files after sending (Always enabled)</div></div><div class="toggle-switch active"><div class="toggle-slider"></div></div></div><button class="close-settings" onclick="closeSettings()">Close Settings</button></div></div><div id="format-modal" class="format-modal"><div class="format-content"><h2>Select Format</h2><div class="format-tabs"><div class="format-tab active" data-tab="video">Video</div><div class="format-tab" data-tab="audio">Audio</div></div><div id="format-loading" class="format-loading"><div class="loading-spinner"></div><p>Loading available formats...</p></div><div id="format-error" class="format-error" style="display: none;">Error loading formats. Please try again.</div><div id="video-formats" class="format-list"></div><div id="audio-formats" class="format-list" style="display: none;"></div><div class="format-buttons"><button class="format-button format-cancel" id="format-cancel">Cancel</button><button class="format-button format-download" id="format-download">Download & Send</button></div></div></div><script>let sessionId=getSessionFromUrl()||generateSecureSessionId();updateUrlWithSession(sessionId);let settings={showMessages:${CONFIG.SHOW_MESSAGES_BY_DEFAULT},downloadMedia:${CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT},autoDelete:${CONFIG.AUTO_DELETE_AFTER_SEND}};let hasCookies=false,currentUrl="",selectedFormat=null,availableFormats={video:[],audio:[]};function loadSettings(){const saved=localStorage.getItem('whatsapp-settings');if(saved)settings={...settings,...JSON.parse(saved)};updateSettingsUI()}function saveSettings(){localStorage.setItem('whatsapp-settings',JSON.stringify(settings))}function updateSettingsUI(){const showMessagesToggle=document.getElementById('show-messages-toggle'),downloadMediaToggle=document.getElementById('download-media-toggle');if(settings.showMessages)showMessagesToggle.classList.add('active');else showMessagesToggle.classList.remove('active');if(settings.downloadMedia)downloadMediaToggle.classList.add('active');else downloadMediaToggle.classList.remove('active');updateMessagesDisplay()}function updateMessagesDisplay(){const messagesContainer=document.getElementById('messages'),noMessagesDiv=document.getElementById('no-messages');if(!settings.showMessages){messagesContainer.innerHTML='';messagesContainer.appendChild(noMessagesDiv);noMessagesDiv.style.display='block'}else{noMessagesDiv.style.display='none';loadMessages()}}function openSettings(){document.getElementById('settings-modal').style.display='flex'}function closeSettings(){document.getElementById('settings-modal').style.display='none'}document.getElementById('show-messages-toggle').addEventListener('click',function(){settings.showMessages=!settings.showMessages;saveSettings();updateSettingsUI()});document.getElementById('download-media-toggle').addEventListener('click',function(){settings.downloadMedia=!settings.downloadMedia;saveSettings();updateSettingsUI()});function getSessionFromUrl(){const urlParams=new URLSearchParams(window.location.search);return urlParams.get('session')}function generateSecureSessionId(){const timestamp=Date.now().toString(36),randomBytes=Array.from(crypto.getRandomValues(new Uint8Array(32)),b=>b.toString(16).padStart(2,'0')).join(''),combined=timestamp+randomBytes;return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g,'').substring(0,48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)),b=>b.toString(16).padStart(2,'0')).join('')}\`}function updateUrlWithSession(sessionId){const url=new URL(window.location);url.searchParams.set('session',sessionId);window.history.replaceState({},'',url)}
const statusElement=document.getElementById("status"),sessionInfoElement=document.getElementById("session-info"),messagesList=document.getElementById("messages"),messageInput=document.getElementById("message-input"),sendMessageBtn=document.getElementById("send-message-btn"),qrSection=document.getElementById("qr-section"),loadingSection=document.getElementById("loading-section"),waitingSection=document.getElementById("waiting-section"),mainContent=document.getElementById("main-content"),qrImage=document.getElementById("qr-image"),uploadArea=document.getElementById("upload-area"),fileInput=document.getElementById("file-input"),urlInput=document.getElementById("url-input"),downloadSendBtn=document.getElementById("download-send-btn"),userInfo=document.getElementById("user-info"),queuePosition=document.getElementById("queue-position"),positionText=document.getElementById("position-text"),maxSessions=document.getElementById("max-sessions"),urlType=document.getElementById("url-type"),downloadProgress=document.getElementById("download-progress"),downloadProgressBar=document.getElementById("download-progress-bar"),cookiesUploadArea=document.getElementById("cookies-upload-area"),cookiesInput=document.getElementById("cookies-input"),cookiesStatus=document.getElementById("cookies-status"),youtubeCookiesWarning=document.getElementById("youtube-cookies-warning"),formatModal=document.getElementById("format-modal"),formatCancel=document.getElementById("format-cancel"),formatDownload=document.getElementById("format-download"),videoFormats=document.getElementById("video-formats"),audioFormats=document.getElementById("audio-formats"),formatLoading=document.getElementById("format-loading"),formatError=document.getElementById("format-error"),formatTabs=document.querySelectorAll(".format-tab");let autoDownloadTimer=null;sessionInfoElement.textContent=\`Session: \${sessionId.substring(3,15)}...\`;formatTabs.forEach(tab=>{tab.addEventListener('click',()=>{const tabType=tab.dataset.tab;formatTabs.forEach(t=>t.classList.remove('active'));tab.classList.add('active');if(tabType==='video'){videoFormats.style.display='block';audioFormats.style.display='none'}else{videoFormats.style.display='none';audioFormats.style.display='block'}})});formatCancel.addEventListener('click',()=>{formatModal.style.display='none';selectedFormat=null});formatDownload.addEventListener('click',()=>{if(selectedFormat){formatModal.style.display='none';downloadWithFormat(currentUrl,selectedFormat)}else{alert('Please select a format first')}});function showFormatModal(url){currentUrl=url;selectedFormat=null;formatLoading.style.display='block';formatError.style.display='none';videoFormats.innerHTML='';audioFormats.innerHTML='';videoFormats.style.display='block';audioFormats.style.display='none';formatTabs[0].classList.add('active');formatTabs[1].classList.remove('active');formatModal.style.display='flex';fetchAvailableFormats(url)}async function fetchAvailableFormats(url){try{const response=await fetch('/api/formats',{method:'POST',headers:{'Content-Type':'application/json','session-id':sessionId},body:JSON.stringify({url})});const result=await response.json();if(result.success){availableFormats={video:result.formats.filter(f=>f.hasVideo),audio:result.formats.filter(f=>!f.hasVideo&&f.hasAudio)};renderFormats();formatLoading.style.display='none'}else{throw new Error(result.error)}}catch(error){formatLoading.style.display='none';formatError.style.display='block';formatError.textContent='Error: '+(error.message||'Failed to load formats')}}function renderFormats(){videoFormats.innerHTML='';audioFormats.innerHTML='';if(availableFormats.video.length===0)videoFormats.innerHTML='<div class="format-error">No video formats available</div>';if(availableFormats.audio.length===0)audioFormats.innerHTML='<div class="format-error">No audio formats available</div>';availableFormats.video.forEach(format=>{const formatItem=document.createElement('div');formatItem.className='format-item';formatItem.dataset.formatId=format.formatId;const resolution=format.height?\`\${format.height}p\`:'Unknown',size=format.filesize?formatFileSize(format.filesize):'Unknown size';formatItem.innerHTML=\`<div class="format-info"><div class="format-quality">\${resolution} \${format.qualityLabel||''}</div><div class="format-size">\${size}</div></div><div class="format-details">\${format.container||''} | \${format.fps||'?'}fps | \${format.vcodec||'Unknown codec'}</div>\`;formatItem.addEventListener('click',()=>{document.querySelectorAll('.format-item').forEach(item=>{item.classList.remove('selected')});formatItem.classList.add('selected');selectedFormat=format});videoFormats.appendChild(formatItem)});availableFormats.audio.forEach(format=>{const formatItem=document.createElement('div');formatItem.className='format-item';formatItem.dataset.formatId=format.formatId;const size=format.filesize?formatFileSize(format.filesize):'Unknown size';formatItem.innerHTML=\`<div class="format-info"><div class="format-quality">\${format.acodec||'Audio'} \${format.abr?format.abr+'kbps':''}</div><div class="format-size">\${size}</div></div><div class="format-details">\${format.container||''} | \${format.asr?(format.asr/1000)+'kHz':'Unknown sample rate'}</div>\`;formatItem.addEventListener('click',()=>{document.querySelectorAll('.format-item').forEach(item=>{item.classList.remove('selected')});formatItem.classList.add('selected');selectedFormat=format});audioFormats.appendChild(formatItem)});if(availableFormats.video.length>0){const bestVideo=videoFormats.querySelector('.format-item');if(bestVideo)bestVideo.click()}if(availableFormats.audio.length>0&&availableFormats.video.length===0){const bestAudio=audioFormats.querySelector('.format-item');if(bestAudio){formatTabs[1].click();bestAudio.click()}}}function formatFileSize(bytes){if(bytes===0)return '0 Bytes';const k=1024,sizes=['Bytes','KB','MB','GB'],i=Math.floor(Math.log(bytes)/Math.log(k));return parseFloat((bytes/Math.pow(k,i)).toFixed(2))+' '+sizes[i]}cookiesUploadArea.addEventListener('click',()=>cookiesInput.click());cookiesUploadArea.addEventListener('dragover',(e)=>{e.preventDefault();cookiesUploadArea.classList.add('dragover')});cookiesUploadArea.addEventListener('dragleave',()=>{cookiesUploadArea.classList.remove('dragover')});cookiesUploadArea.addEventListener('drop',(e)=>{e.preventDefault();cookiesUploadArea.classList.remove('dragover');const files=e.dataTransfer.files;if(files.length>0&&files[0].name.endsWith('.json'))handleCookiesFile(files[0])});cookiesInput.addEventListener('change',(e)=>{if(e.target.files.length>0)handleCookiesFile(e.target.files[0])});async function handleCookiesFile(file){try{const text=await file.text(),cookiesData=JSON.parse(text);if(cookiesData.cookies&&Array.isArray(cookiesData.cookies)){const formData=new FormData();formData.append('cookiesFile',file);const response=await fetch(\`/api/cookies?session=\${sessionId}\`,{method:'POST',body:formData});const result=await response.json();if(result.success){hasCookies=true;cookiesStatus.textContent=\`✅ Cookies loaded - \${cookiesData.cookies.length} cookies from \${cookiesData.url}\`;cookiesStatus.classList.add('loaded')}else{throw new Error(result.error)}}else{throw new Error('Invalid cookies format')}}catch(error){cookiesStatus.textContent='❌ Error loading cookies: '+error.message;cookiesStatus.classList.remove('loaded')}}function detectUrlType(url){try{const urlObj=new URL(url),hostname=urlObj.hostname.toLowerCase();if(hostname.includes('youtube.com')||hostname.includes('youtu.be'))return{type:'YouTube Video',icon:'🎥',color:'#ff0000',needsCookies:true,needsFormatSelection:true};else if(hostname.includes('instagram.com'))return{type:'Instagram Media',icon:'📸',color:'#e4405f'};else if(hostname.includes('tiktok.com'))return{type:'TikTok Video',icon:'🎵',color:'#000000'};else if(hostname.includes('twitter.com')||hostname.includes('x.com'))return{type:'Twitter Media',icon:'🐦',color:'#1da1f2'};else if(hostname.includes('facebook.com')||hostname.includes('fb.watch'))return{type:'Facebook Video',icon:'📘',color:'#1877f2'};else if(hostname.includes('reddit.com'))return{type:'Reddit Media',icon:'🔴',color:'#ff4500'};else if(hostname.includes('pinterest.com'))return{type:'Pinterest Image',icon:'📌',color:'#bd081c'};else if(hostname.includes('linkedin.com'))return{type:'LinkedIn Media',icon:'💼',color:'#0077b5'};else if(url.match(/\\.(jpg|jpeg|png|gif|webp)$/i))return{type:'Image File',icon:'🖼️',color:'#4caf50'};else if(url.match(/\\.(mp4|avi|mov|mkv|webm)$/i))return{type:'Video File',icon:'🎬',color:'#2196f3'};else if(url.match(/\\.(mp3|wav|ogg|m4a|flac)$/i))return{type:'Audio File',icon:'🎵',color:'#ff9800'};else if(url.match(/\\.(pdf|doc|docx|txt|zip|rar)$/i))return{type:'Document',icon:'📄',color:'#9c27b0'};else return{type:'Web Content',icon:'🌐',color:'#607d8b'}}catch{return{type:'Invalid URL',icon:'❌',color:'#f44336'}}}urlInput.addEventListener('input',(e)=>{const url=e.target.value.trim();if(autoDownloadTimer)clearTimeout(autoDownloadTimer);if(url){const urlInfo=detectUrlType(url);urlType.innerHTML=\`\${urlInfo.icon} \${urlInfo.type}\`;urlType.style.backgroundColor=urlInfo.color+'20';urlType.style.borderLeft=\`3px solid \${urlInfo.color}\`;urlType.style.display='inline-block';if(urlInfo.needsCookies&&!hasCookies){youtubeCookiesWarning.style.display='block';downloadSendBtn.disabled=true;downloadSendBtn.textContent='🍪 Cookies Required';return}else{youtubeCookiesWarning.style.display='none';downloadSendBtn.disabled=false}downloadSendBtn.textContent='⏳ Auto-download in 7s...';downloadSendBtn.disabled=true;let countdown=7;const countdownInterval=setInterval(()=>{countdown--;downloadSendBtn.textContent=\`⏳ Auto-download in \${countdown}s...\`;if(countdown<=0)clearInterval(countdownInterval)},1000);autoDownloadTimer=setTimeout(()=>{clearInterval(countdownInterval);if(urlInput.value.trim()===url&&(!urlInfo.needsCookies||hasCookies)){if(urlInfo.needsFormatSelection){downloadSendBtn.textContent='📥 Download & Send';downloadSendBtn.disabled=false;showFormatModal(url)}else{downloadAndSend(url)}}},7000)}else{urlType.style.display='none';youtubeCookiesWarning.style.display='none';downloadSendBtn.textContent='📥 Download & Send';downloadSendBtn.disabled=false}});uploadArea.addEventListener('click',()=>fileInput.click());uploadArea.addEventListener('dragover',(e)=>{e.preventDefault();uploadArea.classList.add('dragover')});uploadArea.addEventListener('dragleave',()=>{uploadArea.classList.remove('dragover')});uploadArea.addEventListener('drop',(e)=>{e.preventDefault();uploadArea.classList.remove('dragover');const files=e.dataTransfer.files;handleFiles(files)});fileInput.addEventListener('change',(e)=>{handleFiles(e.target.files)});async function handleFiles(files){for(let file of files)await uploadFile(file)}async function uploadFile(file){const formData=new FormData();formData.append('file',file);try{const response=await fetch(\`/api/upload?session=\${sessionId}\`,{method:'POST',body:formData});const result=await response.json();if(result.success&&settings.showMessages)setTimeout(loadMessages,1000)}catch(error){}}async function downloadAndSend(url){if(!url)return;const urlInfo=detectUrlType(url);if(urlInfo.needsCookies&&!hasCookies){alert('YouTube cookies are required. Please upload J2Team cookies.json file first.');return}if(urlInfo.needsFormatSelection){showFormatModal(url);return}downloadSendBtn.textContent='⏳ Downloading...';downloadSendBtn.disabled=true;downloadProgress.style.display='block';statusElement.textContent='Downloading...';statusElement.className='status-downloading';try{const response=await fetch(\`/api/download?session=\${sessionId}\`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({url})});const result=await response.json();if(result.success){urlInput.value='';urlType.style.display='none';youtubeCookiesWarning.style.display='none';if(settings.showMessages)setTimeout(loadMessages,1000)}else{alert('Download failed: '+result.error)}}catch(error){alert('Download failed: '+(error.message||'Unknown error'))}finally{downloadSendBtn.textContent='📥 Download & Send';downloadSendBtn.disabled=false;downloadProgress.style.display='none';downloadProgressBar.style.width='0%';statusElement.textContent='Connected';statusElement.className='status-connected'}}async function downloadWithFormat(url,format){if(!url||!format)return;downloadSendBtn.textContent='⏳ Downloading...';downloadSendBtn.disabled=true;downloadProgress.style.display='block';statusElement.textContent='Downloading...';statusElement.className='status-downloading';try{const response=await fetch(\`/api/download-format?session=\${sessionId}\`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({url,formatId:format.formatId})});const result=await response.json();if(result.success){urlInput.value='';urlType.style.display='none';youtubeCookiesWarning.style.display='none';if(settings.showMessages)setTimeout(loadMessages,1000)}else{alert('Download failed: '+result.error)}}catch(error){alert('Download failed: '+(error.message||'Unknown error'))}finally{downloadSendBtn.textContent='📥 Download & Send';downloadSendBtn.disabled=false;downloadProgress.style.display='none';downloadProgressBar.style.width='0%';statusElement.textContent='Connected';statusElement.className='status-connected'}}downloadSendBtn.addEventListener('click',()=>{const url=urlInput.value.trim();if(autoDownloadTimer)clearTimeout(autoDownloadTimer);const urlInfo=detectUrlType(url);if(urlInfo.needsFormatSelection)showFormatModal(url);else downloadAndSend(url)});sendMessageBtn.addEventListener('click',async()=>{const message=messageInput.value.trim();if(!message)return;try{const response=await fetch(\`/api/send?session=\${sessionId}\`,{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify({message})});const result=await response.json();if(result.success){messageInput.value='';if(settings.showMessages)setTimeout(loadMessages,1000)}}catch(error){}});messageInput.addEventListener('keypress',(e)=>{if(e.key==='Enter'&&!e.shiftKey){e.preventDefault();sendMessageBtn.click()}});async function loadMessages(){if(!settings.showMessages)return;try{const response=await fetch(\`/api/messages?session=\${sessionId}\`);const result=await response.json();if(result.success)displayMessages(result.messages)}catch(error){}}function displayMessages(messages){messagesList.innerHTML='';messages.forEach(msg=>{const messageDiv=document.createElement('div');messageDiv.className='message';let content=\`<div>\${msg.text||''}</div>\`;if(msg.media&&settings.downloadMedia){if(msg.media.type==='image')content+=\`<img src="/media/\${msg.media.filename}" alt="Image" class="message-media">\`;else if(msg.media.type==='video')content+=\`<video src="/media/\${msg.media.filename}" controls class="message-media"></video>\`;else if(msg.media.type==='audio')content+=\`<audio src="/media/\${msg.media.filename}" controls class="message-media"></audio>\`;else content+=\`<div class="message-file"><div class="file-icon">📄</div><div class="file-info"><div class="file-name">\${msg.media.filename}</div><div class="file-size">\${msg.media.size||'Unknown size'}</div></div><button class="download-btn" onclick="window.open('/media/\${msg.media.filename}')">📥</button></div>\`}content+=\`<div class="message-time">\${new Date(msg.timestamp).toLocaleTimeString()}</div>\`;messageDiv.innerHTML=content;messagesList.appendChild(messageDiv)});messagesList.scrollTop=messagesList.scrollHeight}async function checkStatus(){try{const response=await fetch(\`/api/status?session=\${sessionId}\`);const result=await response.json();if(result.status==='waiting'){qrSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='none';waitingSection.style.display='block';queuePosition.textContent=result.position;positionText.textContent=result.position;maxSessions.textContent=result.maxSessions;statusElement.textContent=\`Waiting (Position \${result.position})\`;statusElement.className='status-waiting'}else if(result.status==='qr'){waitingSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='none';qrSection.style.display='block';if(result.qr)qrImage.innerHTML=\`<img src="\${result.qr}" alt="QR Code">\`;statusElement.textContent='Scan QR Code';statusElement.className='status-disconnected'}else if(result.status==='connected'){waitingSection.style.display='none';qrSection.style.display='none';loadingSection.style.display='none';mainContent.style.display='flex';statusElement.textContent='Connected';statusElement.className='status-connected';if(result.user)userInfo.textContent=\`Connected as: \${result.user.name||result.user.id}\`;if(settings.showMessages)loadMessages()}else{statusElement.textContent='Initializing...';statusElement.className='status-disconnected'}}catch(error){statusElement.textContent='Connection Error';statusElement.className='status-disconnected'}}loadSettings();checkStatus();setInterval(checkStatus,3000)</script></body></html>`

fs.writeFileSync("public/index.html", htmlContent)

app.get("/", (req, res) => res.sendFile(join(__dirname, "public", "index.html")))

app.post("/api/cookies", upload.single("cookiesFile"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session
    if (!sessionId) return res.json({ success: false, error: "Session ID required" })
    if (!req.file) return res.json({ success: false, error: "No cookies file uploaded" })

    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))
    if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies))
      return res.json({ success: false, error: "Invalid cookies format" })

    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    const sessionJsonPath = join(cookiesDir, `${sessionId}.json`)
    fs.writeFileSync(sessionJsonPath, JSON.stringify(cookiesData, null, 2))
    cookiesStorage.set(sessionId, cookiesData)

    fs.unlinkSync(req.file.path)
    res.json({
      success: true,
      message: `Cookies loaded successfully - ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/formats", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session
    if (!url) return res.json({ success: false, error: "URL is required" })

    const cacheKey = `${sessionId}_${url}`
    if (formatCache.has(cacheKey)) return res.json({ success: true, formats: formatCache.get(cacheKey) })

    const userAgent = getRandomUserAgent()
    let ytDlpCommand = `yt-dlp --no-warnings --dump-json --user-agent "${userAgent}"`

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) ytDlpCommand += ` --cookies "${sessionCookiesPath}"`

    ytDlpCommand += ` "${url}"`
    const { stdout } = await execAsync(ytDlpCommand)
    const videoInfo = JSON.parse(stdout.trim())

    if (!videoInfo.formats) return res.json({ success: false, error: "No formats available" })

    const formats = videoInfo.formats
      .filter((f) => f.url && (f.vcodec !== "none" || f.acodec !== "none"))
      .map((f) => ({
        formatId: f.format_id,
        container: f.ext,
        qualityLabel: f.format_note || f.quality,
        hasVideo: f.vcodec && f.vcodec !== "none",
        hasAudio: f.acodec && f.acodec !== "none",
        width: f.width,
        height: f.height,
        fps: f.fps,
        vcodec: f.vcodec,
        acodec: f.acodec,
        abr: f.abr,
        asr: f.asr,
        filesize: f.filesize || f.filesize_approx,
        url: f.url,
      }))
      .sort((a, b) => {
        if (a.hasVideo && b.hasVideo) return (b.height || 0) - (a.height || 0)
        if (a.hasAudio && b.hasAudio) return (b.abr || 0) - (a.abr || 0)
        return 0
      })

    formatCache.set(cacheKey, formats)
    setTimeout(() => formatCache.delete(cacheKey), 300000)
    res.json({ success: true, formats })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download-format", async (req, res) => {
  try {
    const { url, formatId } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) return res.json({ success: false, error: "Invalid session" })

    if (!url || !formatId) return res.json({ success: false, error: "URL and format ID are required" })

    const sock = activeSessions.get(sessionId)
    const userAgent = getRandomUserAgent()
    const tempFilePath = join(tempDir, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    let ytDlpCommand = `yt-dlp --no-warnings -f "${formatId}" --user-agent "${userAgent}"`

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) ytDlpCommand += ` --cookies "${sessionCookiesPath}"`

    ytDlpCommand += ` -o "${tempFilePath}.%(ext)s" "${url}"`
    await execAsync(ytDlpCommand)

    const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(path.basename(tempFilePath)))
    if (files.length === 0) throw new Error("Download failed - no file created")

    const downloadedFile = join(tempDir, files[0])
    const fileBuffer = fs.readFileSync(downloadedFile)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: files[0],
      mimetype: getMimeType(files[0]),
    })

    if (CONFIG.AUTO_DELETE_AFTER_SEND) fs.unlinkSync(downloadedFile)

    res.json({ success: true, message: "Downloaded and sent successfully" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) return res.json({ success: false, error: "Invalid session" })

    if (!url) return res.json({ success: false, error: "URL is required" })

    const sock = activeSessions.get(sessionId)
    const userAgent = getRandomUserAgent()
    const tempFilePath = join(tempDir, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    let ytDlpCommand = `yt-dlp --no-warnings --user-agent "${userAgent}"`

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) ytDlpCommand += ` --cookies "${sessionCookiesPath}"`

    ytDlpCommand += ` -o "${tempFilePath}.%(ext)s" "${url}"`
    await execAsync(ytDlpCommand)

    const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(path.basename(tempFilePath)))
    if (files.length === 0) throw new Error("Download failed")

    const downloadedFile = join(tempDir, files[0])
    const fileBuffer = fs.readFileSync(downloadedFile)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: files[0],
      mimetype: getMimeType(files[0]),
    })

    if (CONFIG.AUTO_DELETE_AFTER_SEND) fs.unlinkSync(downloadedFile)

    res.json({ success: true, message: "Downloaded and sent successfully" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) return res.json({ success: false, error: "Invalid session" })

    const sock = activeSessions.get(sessionId)
    const file = req.file
    const fileBuffer = fs.readFileSync(file.path)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: file.originalname,
      mimetype: file.mimetype,
    })

    if (CONFIG.AUTO_DELETE_AFTER_SEND) fs.unlinkSync(file.path)

    res.json({ success: true, message: "File sent successfully" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/send", async (req, res) => {
  try {
    const { message } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) return res.json({ success: false, error: "Invalid session" })

    const sock = activeSessions.get(sessionId)
    await sock.sendMessage(sock.user.id, { text: message })

    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.get("/api/messages", async (req, res) => {
  try {
    const sessionId = req.query.session

    if (!sessionId) return res.json({ success: false, error: "Session ID required" })

    const messagesFile = join(__dirname, "sessions", sessionId, "messages.json")

    if (!fs.existsSync(messagesFile)) return res.json({ success: true, messages: [] })

    const messages = JSON.parse(fs.readFileSync(messagesFile, "utf8"))
    res.json({ success: true, messages: messages.slice(-50) })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session

    if (!sessionId) return res.json({ success: false, error: "Session ID required" })

    if (activeSessions.size >= CONFIG.MAX_SESSIONS && !activeSessions.has(sessionId)) {
      const position = waitingQueue.indexOf(sessionId)
      if (position === -1) waitingQueue.push(sessionId)
      return res.json({
        status: "waiting",
        position: waitingQueue.indexOf(sessionId) + 1,
        maxSessions: CONFIG.MAX_SESSIONS,
      })
    }

    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      if (sock.user)
        return res.json({ status: "connected", user: { id: sock.user.id, name: sock.user.name || sock.user.id } })
    }

    const qrFile = join(__dirname, "sessions", sessionId, "qr.png")
    if (fs.existsSync(qrFile)) {
      const qrData = fs.readFileSync(qrFile, "base64")
      return res.json({ status: "qr", qr: `data:image/png;base64,${qrData}` })
    }

    if (!activeSessions.has(sessionId)) {
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.use("/media", express.static(mediaDir))

function getMimeType(filename) {
  const ext = path.extname(filename).toLowerCase()
  const mimeTypes = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".mp4": "video/mp4",
    ".avi": "video/x-msvideo",
    ".mov": "video/quicktime",
    ".mkv": "video/x-matroska",
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".pdf": "application/pdf",
    ".doc": "application/msword",
    ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ".txt": "text/plain",
    ".zip": "application/zip",
    ".rar": "application/x-rar-compressed",
  }
  return mimeTypes[ext] || "application/octet-stream"
}

async function createWhatsAppSession(sessionId) {
  try {
    if (activeSessions.has(sessionId)) return

    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      browser: Browsers.macOS("Desktop"),
      syncFullHistory: false,
    })

    activeSessions.set(sessionId, sock)

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        try {
          const qrImage = await qrcode.toDataURL(qr)
          const base64Data = qrImage.replace(/^data:image\/png;base64,/, "")
          const qrPath = join(sessionDir, "qr.png")
          fs.writeFileSync(qrPath, base64Data, "base64")
        } catch (err) {
          console.error(`Error saving QR for ${sessionId}:`, err)
        }
      }

      if (connection === "close") {
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401

        activeSessions.delete(sessionId)

        if (shouldReconnect) {
          setTimeout(() => createWhatsAppSession(sessionId), 5000)
        } else {
          try {
            fs.rmSync(sessionDir, { recursive: true, force: true })
          } catch (err) {
            console.error(`Error removing session dir:`, err)
          }
        }
      } else if (connection === "open") {
        const qrPath = join(sessionDir, "qr.png")
        if (fs.existsSync(qrPath)) fs.unlinkSync(qrPath)

        const waitingIndex = waitingQueue.indexOf(sessionId)
        if (waitingIndex > -1) waitingQueue.splice(waitingIndex, 1)
      }
    })

    sock.ev.on("creds.update", saveCreds)

    sock.ev.on("messages.upsert", async ({ messages, type }) => {
      if (type !== "notify") return

      for (const message of messages) {
        try {
          const messagesFile = join(sessionDir, "messages.json")
          let existingMessages = []

          if (fs.existsSync(messagesFile)) {
            existingMessages = JSON.parse(fs.readFileSync(messagesFile, "utf8"))
          }

          const formattedMessage = {
            id: message.key.id,
            fromMe: message.key.fromMe,
            text: message.message?.conversation || message.message?.extendedTextMessage?.text || "Media message",
            timestamp: Date.now(),
          }

          if (
            message.message?.documentMessage ||
            message.message?.imageMessage ||
            message.message?.videoMessage ||
            message.message?.audioMessage
          ) {
            try {
              const buffer = await downloadMediaMessage(
                message,
                "buffer",
                {},
                { logger: console, reuploadRequest: sock.updateMediaMessage },
              )

              const mediaType = message.message?.documentMessage
                ? "document"
                : message.message?.imageMessage
                  ? "image"
                  : message.message?.videoMessage
                    ? "video"
                    : "audio"

              const extension =
                mediaType === "image" ? "jpg" : mediaType === "video" ? "mp4" : mediaType === "audio" ? "mp3" : "bin"

              const filename = `${sessionId}_${message.key.id}.${extension}`
              const filePath = join(mediaDir, filename)

              fs.writeFileSync(filePath, buffer)

              formattedMessage.media = {
                type: mediaType,
                filename: filename,
                size: buffer.length,
              }
            } catch (err) {
              console.error(`Error downloading media for ${sessionId}:`, err)
            }
          }

          existingMessages.push(formattedMessage)

          if (existingMessages.length > 100) {
            existingMessages = existingMessages.slice(-100)
          }

          fs.writeFileSync(messagesFile, JSON.stringify(existingMessages, null, 2))
        } catch (err) {
          console.error(`Error processing message for ${sessionId}:`, err)
        }
      }
    })
  } catch (error) {
    console.error(`Error creating session ${sessionId}:`, error)
    activeSessions.delete(sessionId)
  }
}

setInterval(() => {
  if (activeSessions.size < CONFIG.MAX_SESSIONS && waitingQueue.length > 0) {
    const nextSessionId = waitingQueue.shift()
    createWhatsAppSession(nextSessionId)
  }
}, 5000)

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
    console.error("Error cleaning temp files:", error)
  }
}, 600000)

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
