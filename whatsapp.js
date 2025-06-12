const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys")
import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
import https from "https"
import { createWriteStream } from "fs"
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
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const waitingQueue = []
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

  if (referer) {
    headers["Referer"] = referer
  }

  return headers
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionId = req.headers["session-id"]
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

try {
  await fs.promises.mkdir(mediaDir, { recursive: true })
  await fs.promises.mkdir(uploadsDir, { recursive: true })
  await fs.promises.mkdir("public", { recursive: true })
  await fs.promises.mkdir("sessions", { recursive: true })
  await fs.promises.mkdir(tempDir, { recursive: true })
} catch (err) {
  console.error("Error creating directories:", err)
}

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp Personal Interface</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    }
    body {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
    }
    .container {
      max-width: 1400px;
      margin: 0 auto;
      height: 100vh;
      display: flex;
      flex-direction: column;
      padding: 20px;
    }
    header {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      color: white;
      padding: 20px;
      border-radius: 15px;
      margin-bottom: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .session-info {
      font-size: 12px;
      opacity: 0.8;
      max-width: 300px;
      word-break: break-all;
    }
    .status-connected {
      background: linear-gradient(45deg, #4CAF50, #45a049);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      box-shadow: 0 4px 15px rgba(76, 175, 80, 0.3);
    }
    .status-disconnected {
      background: linear-gradient(45deg, #f44336, #d32f2f);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      box-shadow: 0 4px 15px rgba(244, 67, 54, 0.3);
    }
    .status-waiting {
      background: linear-gradient(45deg, #ff9800, #f57c00);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      box-shadow: 0 4px 15px rgba(255, 152, 0, 0.3);
    }
    .status-downloading {
      background: linear-gradient(45deg, #2196F3, #1976D2);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      box-shadow: 0 4px 15px rgba(33, 150, 243, 0.3);
    }
    .main-content {
      display: flex;
      height: calc(100vh - 140px);
      gap: 20px;
    }
    .sidebar {
      width: 350px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .file-upload-section {
      padding: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
    }
    .file-upload-section h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .upload-area {
      border: 2px dashed rgba(255,255,255,0.3);
      border-radius: 10px;
      padding: 20px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s ease;
      margin-bottom: 15px;
    }
    .upload-area:hover {
      border-color: rgba(255,255,255,0.6);
      background: rgba(255,255,255,0.1);
    }
    .upload-area.dragover {
      border-color: #4CAF50;
      background: rgba(76, 175, 80, 0.1);
    }
    .upload-text {
      color: white;
      font-size: 14px;
    }
    .file-input {
      display: none;
    }
    .url-section {
      margin-top: 15px;
    }
    .url-input {
      width: 100%;
      padding: 12px;
      border: none;
      border-radius: 8px;
      background: rgba(255,255,255,0.2);
      color: white;
      placeholder-color: rgba(255,255,255,0.7);
      margin-bottom: 10px;
    }
    .url-input::placeholder {
      color: rgba(255,255,255,0.7);
    }
    .btn {
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      border: none;
      padding: 12px 20px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
      transition: all 0.3s ease;
      width: 100%;
    }
    .btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
    }
    .btn:disabled {
      opacity: 0.6;
      cursor: not-allowed;
      transform: none;
    }
    .auto-download-info {
      font-size: 12px;
      color: rgba(255,255,255,0.7);
      margin-top: 5px;
      text-align: center;
    }
    .download-progress {
      width: 100%;
      height: 4px;
      background: rgba(255,255,255,0.2);
      border-radius: 2px;
      margin: 10px 0;
      overflow: hidden;
    }
    .download-progress-bar {
      height: 100%;
      background: linear-gradient(45deg, #4CAF50, #45a049);
      width: 0%;
      transition: width 0.3s ease;
    }
    .message-section {
      padding: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
    }
    .message-section h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .message-input {
      width: 100%;
      padding: 12px;
      border: none;
      border-radius: 8px;
      background: rgba(255,255,255,0.2);
      color: white;
      resize: none;
      height: 80px;
      margin-bottom: 10px;
    }
    .message-input::placeholder {
      color: rgba(255,255,255,0.7);
    }
    .chat-area {
      flex: 1;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .chat-header {
      padding: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
      color: white;
    }
    .messages {
      flex: 1;
      padding: 20px;
      overflow-y: auto;
      display: flex;
      flex-direction: column;
    }
    .message {
      max-width: 70%;
      padding: 15px 20px;
      margin-bottom: 15px;
      border-radius: 18px;
      position: relative;
      word-wrap: break-word;
      align-self: flex-end;
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      box-shadow: 0 4px 15px rgba(102, 126, 234, 0.3);
    }
    .message-time {
      font-size: 11px;
      opacity: 0.8;
      text-align: right;
      margin-top: 8px;
    }
    .message-media {
      max-width: 100%;
      max-height: 300px;
      margin: 10px 0;
      border-radius: 10px;
      box-shadow: 0 4px 15px rgba(0,0,0,0.2);
    }
    .message-file {
      background: rgba(255,255,255,0.2);
      padding: 15px;
      border-radius: 10px;
      margin: 10px 0;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    .file-icon {
      width: 40px;
      height: 40px;
      background: rgba(255,255,255,0.3);
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 18px;
    }
    .file-info {
      flex: 1;
    }
    .file-name {
      font-weight: bold;
      margin-bottom: 5px;
    }
    .file-size {
      font-size: 12px;
      opacity: 0.8;
    }
    .download-btn {
      background: rgba(255,255,255,0.2);
      border: none;
      color: white;
      padding: 8px 15px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 12px;
    }
    .qr-container {
      text-align: center;
      padding: 50px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      margin: 20px;
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .qr-container h1 {
      color: white;
      margin-bottom: 20px;
      font-size: 24px;
    }
    .qr-container img {
      max-width: 300px;
      border-radius: 15px;
      margin: 20px 0;
      box-shadow: 0 8px 25px rgba(0,0,0,0.3);
    }
    .qr-container button {
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      border: none;
      padding: 15px 30px;
      border-radius: 10px;
      cursor: pointer;
      font-size: 16px;
      transition: all 0.3s ease;
    }
    .qr-container button:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);
    }
    .loading-spinner {
      border: 3px solid rgba(255,255,255,0.3);
      border-radius: 50%;
      border-top: 3px solid white;
      width: 40px;
      height: 40px;
      animation: spin 1s linear infinite;
      margin: 20px auto;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .audio-player {
      background: rgba(255,255,255,0.2);
      border-radius: 25px;
      padding: 15px;
      margin: 10px 0;
      display: flex;
      align-items: center;
      gap: 15px;
    }
    .play-btn {
      width: 50px;
      height: 50px;
      border-radius: 50%;
      background: rgba(255,255,255,0.3);
      border: none;
      color: white;
      font-size: 20px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .audio-info {
      flex: 1;
    }
    .audio-duration {
      font-size: 12px;
      opacity: 0.8;
    }
    .video-player {
      border-radius: 15px;
      overflow: hidden;
      margin: 10px 0;
      box-shadow: 0 8px 25px rgba(0,0,0,0.3);
    }
    .waiting-container {
      text-align: center;
      padding: 50px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      margin: 20px;
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
      color: white;
    }
    .queue-position {
      font-size: 48px;
      font-weight: bold;
      margin: 20px 0;
      color: #ff9800;
    }
    .url-type-indicator {
      font-size: 12px;
      color: rgba(255,255,255,0.8);
      margin-top: 5px;
      padding: 5px 10px;
      background: rgba(255,255,255,0.1);
      border-radius: 15px;
      display: inline-block;
    }
    @media (max-width: 768px) {
      .main-content {
        flex-direction: column;
      }
      .sidebar {
        width: 100%;
        height: auto;
      }
      .session-info {
        max-width: 200px;
        font-size: 10px;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div>
        <h1>📱 Personal WhatsApp Interface</h1>
        <div class="session-info" id="session-info">Session: Loading...</div>
      </div>
      <div id="status" class="status-disconnected">Disconnected</div>
    </header>
    
    <div id="waiting-section" class="waiting-container" style="display: none;">
      <h1>⏳ Queue Full</h1>
      <div class="queue-position" id="queue-position">0</div>
      <p>You are in position <span id="position-text">0</span> in the queue</p>
      <p>Maximum <span id="max-sessions">10</span> sessions allowed simultaneously</p>
      <div class="loading-spinner"></div>
    </div>
    
    <div id="qr-section" class="qr-container" style="display: none;">
      <h1>📱 Scan with WhatsApp</h1>
      <div id="qr-image"></div>
      <p>Open WhatsApp → Linked Devices → Link Device</p>
      <button onclick="location.reload()">Refresh QR</button>
    </div>
    
    <div id="loading-section" class="qr-container">
      <h1>⏳ Initializing...</h1>
      <div class="loading-spinner"></div>
      <p>Please wait while we set up your WhatsApp interface</p>
    </div>
    
    <div id="main-content" class="main-content" style="display: none;">
      <div class="sidebar">
        <div class="file-upload-section">
          <h3>📎 Send Files</h3>
          <div class="upload-area" id="upload-area">
            <div class="upload-text">
              <div style="font-size: 24px; margin-bottom: 10px;">📁</div>
              <div>Drop files here or click to select</div>
              <div style="font-size: 12px; margin-top: 5px;">Images, videos, audio, documents</div>
            </div>
            <input type="file" id="file-input" class="file-input" multiple accept="*/*">
          </div>
          <div class="url-section">
            <input type="text" id="url-input" class="url-input" placeholder="Enter URL to auto-download and send...">
            <div id="url-type" class="url-type-indicator" style="display: none;"></div>
            <div class="download-progress" id="download-progress" style="display: none;">
              <div class="download-progress-bar" id="download-progress-bar"></div>
            </div>
            <button id="download-send-btn" class="btn">📥 Download & Send</button>
            <div class="auto-download-info">Auto-download starts in 7 seconds after URL entry</div>
          </div>
        </div>
        
        <div class="message-section">
          <h3>💬 Send Message</h3>
          <textarea id="message-input" class="message-input" placeholder="Type your message..."></textarea>
          <button id="send-message-btn" class="btn">📤 Send Message</button>
        </div>
      </div>
      
      <div class="chat-area">
        <div class="chat-header">
          <h2>💬 My Messages</h2>
          <p id="user-info">Personal chat with myself</p>
        </div>
        <div class="messages" id="messages"></div>
      </div>
    </div>
  </div>
  
  <script>
    let sessionId = getSessionFromUrl() || generateSecureSessionId()
    updateUrlWithSession(sessionId)
    
    function getSessionFromUrl() {
      const urlParams = new URLSearchParams(window.location.search)
      return urlParams.get('session')
    }
    
    function generateSecureSessionId() {
      const timestamp = Date.now().toString(36)
      const randomBytes = Array.from(crypto.getRandomValues(new Uint8Array(32)), b => b.toString(16).padStart(2, '0')).join('')
      const combined = timestamp + randomBytes
      return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g, '').substring(0, 48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)), b => b.toString(16).padStart(2, '0')).join('')}\`
    }
    
    function updateUrlWithSession(sessionId) {
      const url = new URL(window.location)
      url.searchParams.set('session', sessionId)
      window.history.replaceState({}, '', url)
    }

    const statusElement = document.getElementById("status")
    const sessionInfoElement = document.getElementById("session-info")
    const messagesList = document.getElementById("messages")
    const messageInput = document.getElementById("message-input")
    const sendMessageBtn = document.getElementById("send-message-btn")
    const qrSection = document.getElementById("qr-section")
    const loadingSection = document.getElementById("loading-section")
    const waitingSection = document.getElementById("waiting-section")
    const mainContent = document.getElementById("main-content")
    const qrImage = document.getElementById("qr-image")
    const uploadArea = document.getElementById("upload-area")
    const fileInput = document.getElementById("file-input")
    const urlInput = document.getElementById("url-input")
    const downloadSendBtn = document.getElementById("download-send-btn")
    const userInfo = document.getElementById("user-info")
    const queuePosition = document.getElementById("queue-position")
    const positionText = document.getElementById("position-text")
    const maxSessions = document.getElementById("max-sessions")
    const urlType = document.getElementById("url-type")
    const downloadProgress = document.getElementById("download-progress")
    const downloadProgressBar = document.getElementById("download-progress-bar")

    let autoDownloadTimer = null
    let userAgent = navigator.userAgent
    let browserInfo = {
      language: navigator.language,
      platform: navigator.platform,
      cookieEnabled: navigator.cookieEnabled,
      onLine: navigator.onLine,
      screen: {
        width: screen.width,
        height: screen.height,
        colorDepth: screen.colorDepth
      },
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone
    }

    sessionInfoElement.textContent = \`Session: \${sessionId.substring(3, 15)}...\`

    function detectUrlType(url) {
      try {
        const urlObj = new URL(url)
        const hostname = urlObj.hostname.toLowerCase()
        
        if (hostname.includes('youtube.com') || hostname.includes('youtu.be')) {
          return { type: 'YouTube Video', icon: '🎥', color: '#ff0000' }
        } else if (hostname.includes('instagram.com')) {
          return { type: 'Instagram Media', icon: '📸', color: '#e4405f' }
        } else if (hostname.includes('tiktok.com')) {
          return { type: 'TikTok Video', icon: '🎵', color: '#000000' }
        } else if (hostname.includes('twitter.com') || hostname.includes('x.com')) {
          return { type: 'Twitter Media', icon: '🐦', color: '#1da1f2' }
        } else if (hostname.includes('facebook.com') || hostname.includes('fb.watch')) {
          return { type: 'Facebook Video', icon: '📘', color: '#1877f2' }
        } else if (hostname.includes('reddit.com')) {
          return { type: 'Reddit Media', icon: '🔴', color: '#ff4500' }
        } else if (hostname.includes('pinterest.com')) {
          return { type: 'Pinterest Image', icon: '📌', color: '#bd081c' }
        } else if (hostname.includes('linkedin.com')) {
          return { type: 'LinkedIn Media', icon: '💼', color: '#0077b5' }
        } else if (url.match(/\\.(jpg|jpeg|png|gif|webp)$/i)) {
          return { type: 'Image File', icon: '🖼️', color: '#4caf50' }
        } else if (url.match(/\\.(mp4|avi|mov|mkv|webm)$/i)) {
          return { type: 'Video File', icon: '🎬', color: '#2196f3' }
        } else if (url.match(/\\.(mp3|wav|ogg|m4a|flac)$/i)) {
          return { type: 'Audio File', icon: '🎵', color: '#ff9800' }
        } else if (url.match(/\\.(pdf|doc|docx|txt|zip|rar)$/i)) {
          return { type: 'Document', icon: '📄', color: '#9c27b0' }
        } else {
          return { type: 'Web Content', icon: '🌐', color: '#607d8b' }
        }
      } catch {
        return { type: 'Invalid URL', icon: '❌', color: '#f44336' }
      }
    }

    urlInput.addEventListener('input', (e) => {
      const url = e.target.value.trim()
      
      if (autoDownloadTimer) {
        clearTimeout(autoDownloadTimer)
      }
      
      if (url) {
        const urlInfo = detectUrlType(url)
        urlType.innerHTML = \`\${urlInfo.icon} \${urlInfo.type}\`
        urlType.style.backgroundColor = urlInfo.color + '20'
        urlType.style.borderLeft = \`3px solid \${urlInfo.color}\`
        urlType.style.display = 'inline-block'
        
        downloadSendBtn.textContent = '⏳ Auto-download in 7s...'
        downloadSendBtn.disabled = true
        
        let countdown = 7
        const countdownInterval = setInterval(() => {
          countdown--
          downloadSendBtn.textContent = \`⏳ Auto-download in \${countdown}s...\`
          if (countdown <= 0) {
            clearInterval(countdownInterval)
          }
        }, 1000)
        
        autoDownloadTimer = setTimeout(() => {
          clearInterval(countdownInterval)
          if (urlInput.value.trim() === url) {
            downloadAndSend(url)
          }
        }, 7000)
      } else {
        urlType.style.display = 'none'
        downloadSendBtn.textContent = '📥 Download & Send'
        downloadSendBtn.disabled = false
      }
    })

    uploadArea.addEventListener('click', () => fileInput.click())
    uploadArea.addEventListener('dragover', (e) => {
      e.preventDefault()
      uploadArea.classList.add('dragover')
    })
    uploadArea.addEventListener('dragleave', () => {
      uploadArea.classList.remove('dragover')
    })
    uploadArea.addEventListener('drop', (e) => {
      e.preventDefault()
      uploadArea.classList.remove('dragover')
      const files = e.dataTransfer.files
      handleFiles(files)
    })

    fileInput.addEventListener('change', (e) => {
      handleFiles(e.target.files)
    })

    async function handleFiles(files) {
      for (let file of files) {
        await uploadFile(file)
      }
    }

    async function uploadFile(file) {
      const formData = new FormData()
      formData.append('file', file)

      try {
        const response = await fetch('/api/upload', {
          method: 'POST',
          headers: {
            'session-id': sessionId,
            'user-agent': userAgent,
            'browser-info': JSON.stringify(browserInfo)
          },
          body: formData
        })
        const result = await response.json()
        if (result.success) {
          console.log('File uploaded and sent:', result.filename)
          setTimeout(loadMessages, 1000)
        }
      } catch (error) {
        console.error('Error uploading file:', error)
      }
    }

    async function downloadAndSend(url) {
      if (!url) return

      downloadSendBtn.textContent = '⏳ Downloading...'
      downloadSendBtn.disabled = true
      downloadProgress.style.display = 'block'
      
      statusElement.textContent = 'Downloading...'
      statusElement.className = 'status-downloading'

      try {
        const response = await fetch('/api/download-send', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'session-id': sessionId,
            'user-agent': userAgent,
            'browser-info': JSON.stringify(browserInfo)
          },
          body: JSON.stringify({ url, userAgent, browserInfo })
        })
        
        const result = await response.json()
        if (result.success) {
          urlInput.value = ''
          urlType.style.display = 'none'
          setTimeout(loadMessages, 1000)
        } else {
          alert('Download failed: ' + result.error)
        }
      } catch (error) {
        console.error('Error downloading file:', error)
        alert('Download failed: ' + error.message)
      } finally {
        downloadSendBtn.textContent = '📥 Download & Send'
        downloadSendBtn.disabled = false
        downloadProgress.style.display = 'none'
        downloadProgressBar.style.width = '0%'
        statusElement.textContent = 'Connected'
        statusElement.className = 'status-connected'
      }
    }

    downloadSendBtn.addEventListener('click', () => {
      const url = urlInput.value.trim()
      if (autoDownloadTimer) {
        clearTimeout(autoDownloadTimer)
      }
      downloadAndSend(url)
    })

    sendMessageBtn.addEventListener('click', async () => {
      const message = messageInput.value.trim()
      if (!message) return

      try {
        const response = await fetch('/api/send', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'session-id': sessionId,
            'user-agent': userAgent
          },
          body: JSON.stringify({ message })
        })
        const result = await response.json()
        if (result.success) {
          messageInput.value = ''
          setTimeout(loadMessages, 1000)
        }
      } catch (error) {
        console.error('Error sending message:', error)
      }
    })

    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault()
        sendMessageBtn.click()
      }
    })

    async function checkStatus() {
      try {
        const response = await fetch("/api/status", {
          headers: {
            'session-id': sessionId,
            'user-agent': userAgent,
            'browser-info': JSON.stringify(browserInfo)
          }
        })
        const data = await response.json()

        if (data.waiting) {
          statusElement.textContent = \`Waiting (\${data.position}/\${data.maxSessions})\`
          statusElement.className = "status-waiting"
          qrSection.style.display = "none"
          loadingSection.style.display = "none"
          mainContent.style.display = "none"
          waitingSection.style.display = "block"
          queuePosition.textContent = data.position
          positionText.textContent = data.position
          maxSessions.textContent = data.maxSessions
        } else if (data.connected) {
          statusElement.textContent = "Connected"
          statusElement.className = "status-connected"
          qrSection.style.display = "none"
          loadingSection.style.display = "none"
          waitingSection.style.display = "none"
          mainContent.style.display = "flex"
          
          if (data.userNumber) {
            userInfo.textContent = \`Connected as: +\${data.userNumber}\`
          }
          
          loadMessages()
        } else if (data.hasQR) {
          statusElement.textContent = "Scan QR Code"
          statusElement.className = "status-disconnected"
          loadingSection.style.display = "none"
          waitingSection.style.display = "none"
          mainContent.style.display = "none"
          qrSection.style.display = "block"
          
          const qrResponse = await fetch("/api/qr", {
            headers: {
              'session-id': sessionId
            }
          })
          const qrData = await qrResponse.json()
          if (qrData.qr) {
            qrImage.innerHTML = \`<img src="\${qrData.qr}" alt="QR Code" />\`
          }
        } else {
          statusElement.textContent = "Generating QR..."
          statusElement.className = "status-disconnected"
          qrSection.style.display = "none"
          waitingSection.style.display = "none"
          mainContent.style.display = "none"
          loadingSection.style.display = "block"
        }
      } catch (error) {
        console.error("Error checking status:", error)
      }
    }

    async function loadMessages() {
      try {
        const response = await fetch("/api/messages", {
          headers: {
            'session-id': sessionId
          }
        })
        const messages = await response.json()

        messagesList.innerHTML = ""
        messages.forEach(displayMessage)
        messagesList.scrollTop = messagesList.scrollHeight
      } catch (error) {
        console.error("Error loading messages:", error)
      }
    }

    function displayMessage(message) {
      const messageElement = document.createElement("div")
      messageElement.classList.add("message")

      const date = new Date(message.timestamp * 1000)
      const timeString = date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

      let content = \`<div class="message-text">\${escapeHtml(message.text)}</div>\`

      if (message.hasMedia && message.mediaPath) {
        if (message.mediaType === "image") {
          content += \`<img src="\${message.mediaPath}" class="message-media" alt="Image" onclick="window.open('\${message.mediaPath}', '_blank')" style="cursor: pointer;" />\`
        } else if (message.mediaType === "audio") {
          content += \`
            <div class="audio-player">
              <button class="play-btn" onclick="toggleAudio(this, '\${message.mediaPath}')">▶️</button>
              <div class="audio-info">
                <div>Audio Message</div>
                <div class="audio-duration">Click to play</div>
              </div>
            </div>
          \`
        } else if (message.mediaType === "video") {
          content += \`
            <div class="video-player">
              <video controls class="message-media" style="width: 100%;">
                <source src="\${message.mediaPath}" type="video/mp4">
                Your browser does not support the video tag.
              </video>
            </div>
          \`
        } else {
          const fileName = message.mediaPath.split('/').pop()
          const fileExt = fileName.split('.').pop().toUpperCase()
          content += \`
            <div class="message-file">
              <div class="file-icon">📄</div>
              <div class="file-info">
                <div class="file-name">\${fileName}</div>
                <div class="file-size">\${fileExt} file</div>
              </div>
              <button class="download-btn" onclick="window.open('\${message.mediaPath}', '_blank')">📥</button>
            </div>
          \`
        }
      }

      content += \`<div class="message-time">\${timeString}</div>\`
      messageElement.innerHTML = content

      messagesList.appendChild(messageElement)
    }

    function toggleAudio(button, audioSrc) {
      const existingAudio = document.querySelector('audio')
      if (existingAudio) {
        existingAudio.pause()
        existingAudio.remove()
      }

      if (button.textContent === '▶️') {
        const audio = new Audio(audioSrc)
        audio.play()
        button.textContent = '⏸️'
        
        audio.onended = () => {
          button.textContent = '▶️'
        }
        
        audio.onerror = () => {
          button.textContent = '❌'
        }
      } else {
        button.textContent = '▶️'
      }
    }

    function escapeHtml(text) {
      const div = document.createElement("div")
      div.textContent = text
      return div.innerHTML
    }

    checkStatus()
    setInterval(checkStatus, 3000)
  </script>
</body>
</html>`

await fs.promises.writeFile("public/index.html", htmlContent)

class SessionManager {
  constructor() {
    this.sessions = new Map()
    this.waitingQueue = []
    this.maxSessions = CONFIG.MAX_SESSIONS
  }

  createSession(sessionId) {
    if (this.sessions.size >= this.maxSessions) {
      if (!this.waitingQueue.includes(sessionId)) {
        this.waitingQueue.push(sessionId)
      }
      return {
        waiting: true,
        position: this.waitingQueue.indexOf(sessionId) + 1,
        maxSessions: this.maxSessions,
      }
    }

    if (!this.sessions.has(sessionId)) {
      this.sessions.set(sessionId, {
        id: sessionId,
        sock: null,
        qrCode: null,
        isConnected: false,
        userNumber: null,
        messageHistory: [],
        createdAt: Date.now(),
        userAgent: null,
        browserInfo: null,
      })
    }

    return { waiting: false, session: this.sessions.get(sessionId) }
  }

  getSession(sessionId) {
    return this.sessions.get(sessionId)
  }

  removeSession(sessionId) {
    this.sessions.delete(sessionId)
    this.processQueue()
  }

  processQueue() {
    if (this.waitingQueue.length > 0 && this.sessions.size < this.maxSessions) {
      const nextSessionId = this.waitingQueue.shift()
      this.createSession(nextSessionId)
    }
  }

  getQueuePosition(sessionId) {
    const position = this.waitingQueue.indexOf(sessionId)
    return position >= 0 ? position + 1 : 0
  }
}

const sessionManager = new SessionManager()

async function startWhatsAppSession(sessionId) {
  const sessionData = sessionManager.getSession(sessionId)
  if (!sessionData) return null

  try {
    const authDir = join(__dirname, "sessions", sessionId)
    await fs.promises.mkdir(authDir, { recursive: true })

    const auth = await useMultiFileAuthState(authDir)
    const state = auth.state
    const saveCreds = auth.saveCreds

    const sock = makeWASocket({
      auth: state,
      browser: Browsers.ubuntu("WhatsApp-Web-Interface"),
      printQRInTerminal: false,
    })

    sessionData.sock = sock

    sock.ev.on("creds.update", saveCreds)

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        console.log(`New QR code generated for session ${sessionId}`)
        sessionData.qrCode = await qrcode.toDataURL(qr)
      }

      if (connection === "close") {
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
        console.log(`Connection closed for session ${sessionId}:`, lastDisconnect?.error)

        if (shouldReconnect) {
          console.log(`Reconnecting session ${sessionId}...`)
          setTimeout(() => startWhatsAppSession(sessionId), 3000)
        } else {
          sessionManager.removeSession(sessionId)
        }
        sessionData.isConnected = false
      } else if (connection === "open") {
        console.log(`WhatsApp connected successfully for session ${sessionId}!`)
        sessionData.isConnected = true
        sessionData.qrCode = null
        sessionData.userNumber = sock.user.id.split(":")[0]
        console.log(`User number for session ${sessionId}:`, sessionData.userNumber)
      }
    })

    sock.ev.on("messages.upsert", async ({ messages }) => {
      for (const message of messages) {
        if (message.message) {
          const userJid = sessionData.userNumber + "@s.whatsapp.net"

          if (message.key.remoteJid === userJid || message.key.participant === userJid) {
            console.log(`Message received for session ${sessionId}:`, message.key.id)

            const formattedMessage = {
              id: message.key.id,
              from: message.key.remoteJid,
              timestamp: message.messageTimestamp,
              text:
                message.message.conversation ||
                (message.message.extendedTextMessage && message.message.extendedTextMessage.text) ||
                "Multimedia content",
              hasMedia:
                !!message.message.imageMessage ||
                !!message.message.documentMessage ||
                !!message.message.audioMessage ||
                !!message.message.videoMessage,
              mediaType: message.message.imageMessage
                ? "image"
                : message.message.documentMessage
                  ? "document"
                  : message.message.audioMessage
                    ? "audio"
                    : message.message.videoMessage
                      ? "video"
                      : null,
            }

            if (formattedMessage.hasMedia) {
              try {
                const buffer = await downloadMediaMessage(
                  message,
                  "buffer",
                  {},
                  {
                    logger: console,
                    reuploadRequest: sock.updateMediaMessage,
                  },
                )

                const extension =
                  formattedMessage.mediaType === "image"
                    ? "jpg"
                    : formattedMessage.mediaType === "video"
                      ? "mp4"
                      : formattedMessage.mediaType === "audio"
                        ? "ogg"
                        : "bin"

                const fileName = `${sessionId}-${message.key.id}.${extension}`
                const filePath = join(mediaDir, fileName)

                const writeStream = createWriteStream(filePath)
                writeStream.write(buffer)
                writeStream.end()

                formattedMessage.mediaPath = `/media/${fileName}`
              } catch (error) {
                console.error("Error downloading media:", error)
              }
            }

            sessionData.messageHistory.unshift(formattedMessage)
            if (sessionData.messageHistory.length > 200) {
              sessionData.messageHistory.pop()
            }
          }
        }
      }
    })

    return sock
  } catch (error) {
    console.error(`Error starting WhatsApp session ${sessionId}:`, error)
    return null
  }
}

function detectPlatform(url) {
  const hostname = new URL(url).hostname.toLowerCase()

  if (hostname.includes("youtube.com") || hostname.includes("youtu.be")) {
    return "youtube"
  } else if (hostname.includes("instagram.com")) {
    return "instagram"
  } else if (hostname.includes("tiktok.com")) {
    return "tiktok"
  } else if (hostname.includes("twitter.com") || hostname.includes("x.com")) {
    return "twitter"
  } else if (hostname.includes("facebook.com") || hostname.includes("fb.watch")) {
    return "facebook"
  } else if (hostname.includes("reddit.com")) {
    return "reddit"
  } else if (hostname.includes("pinterest.com")) {
    return "pinterest"
  } else if (hostname.includes("linkedin.com")) {
    return "linkedin"
  }

  return "generic"
}

async function downloadWithYtDlp(url, userAgent) {
  try {
    const outputDir = tempDir
    const outputTemplate = join(outputDir, "%(title)s.%(ext)s")

    const command = `yt-dlp --user-agent "${userAgent}" --format "best[height<=720]/best" --output "${outputTemplate}" "${url}"`

    console.log(`Executing: ${command}`)
    const { stdout, stderr } = await execAsync(command, {
      timeout: 120000,
      maxBuffer: 1024 * 1024 * 50,
    })

    if (stderr && !stderr.includes("WARNING")) {
      console.error("yt-dlp stderr:", stderr)
    }

    const files = await fs.promises.readdir(outputDir)
    const downloadedFile = files.find(
      (file) =>
        file.includes(".mp4") ||
        file.includes(".webm") ||
        file.includes(".mkv") ||
        file.includes(".mp3") ||
        file.includes(".m4a") ||
        file.includes(".jpg") ||
        file.includes(".png"),
    )

    if (!downloadedFile) {
      throw new Error("No file downloaded")
    }

    const filePath = join(outputDir, downloadedFile)
    const buffer = await fs.promises.readFile(filePath)

    await fs.promises.unlink(filePath)

    return {
      filename: downloadedFile,
      buffer: buffer,
      size: buffer.length,
    }
  } catch (error) {
    console.error("yt-dlp download error:", error)
    throw error
  }
}

async function downloadWithGalleryDl(url, userAgent) {
  try {
    const outputDir = tempDir

    const command = `gallery-dl --user-agent "${userAgent}" --dest "${outputDir}" "${url}"`

    console.log(`Executing: ${command}`)
    const { stdout, stderr } = await execAsync(command, {
      timeout: 60000,
      maxBuffer: 1024 * 1024 * 20,
    })

    if (stderr && !stderr.includes("WARNING")) {
      console.error("gallery-dl stderr:", stderr)
    }

    const findFiles = async (dir) => {
      const files = []
      const items = await fs.promises.readdir(dir, { withFileTypes: true })

      for (const item of items) {
        const fullPath = join(dir, item.name)
        if (item.isDirectory()) {
          files.push(...(await findFiles(fullPath)))
        } else if (item.isFile() && !item.name.startsWith(".")) {
          files.push(fullPath)
        }
      }

      return files
    }

    const allFiles = await findFiles(outputDir)
    const mediaFiles = allFiles.filter((file) => {
      const ext = path.extname(file).toLowerCase()
      return [".jpg", ".jpeg", ".png", ".gif", ".webp", ".mp4", ".webm", ".mkv", ".mp3", ".m4a"].includes(ext)
    })

    if (mediaFiles.length === 0) {
      throw new Error("No media files downloaded")
    }

    const filePath = mediaFiles[0]
    const buffer = await fs.promises.readFile(filePath)
    const filename = path.basename(filePath)

    for (const file of mediaFiles) {
      try {
        await fs.promises.unlink(file)
      } catch (e) {}
    }

    return {
      filename: filename,
      buffer: buffer,
      size: buffer.length,
    }
  } catch (error) {
    console.error("gallery-dl download error:", error)
    throw error
  }
}

async function downloadFileFromUrl(url, userAgent, browserInfo) {
  try {
    const platform = detectPlatform(url)

    if (platform === "youtube") {
      return await downloadWithYtDlp(url, userAgent)
    } else if (["instagram", "tiktok", "twitter", "facebook", "reddit", "pinterest"].includes(platform)) {
      try {
        return await downloadWithGalleryDl(url, userAgent)
      } catch (error) {
        console.log("gallery-dl failed, trying yt-dlp...")
        return await downloadWithYtDlp(url, userAgent)
      }
    }

    const headers = createBrowserHeaders(userAgent)

    const response = await fetch(url, {
      headers,
      redirect: "follow",
      timeout: 30000,
    })

    if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`)

    const contentType = response.headers.get("content-type") || ""
    const contentDisposition = response.headers.get("content-disposition") || ""

    let filename = "downloaded-file"
    if (contentDisposition.includes("filename=")) {
      filename = contentDisposition.split("filename=")[1].replace(/"/g, "")
    } else {
      const urlPath = new URL(url).pathname
      const urlFilename = urlPath.split("/").pop()
      if (urlFilename && urlFilename.includes(".")) {
        filename = decodeURIComponent(urlFilename)
      } else {
        const ext = contentType.includes("image")
          ? ".jpg"
          : contentType.includes("video")
            ? ".mp4"
            : contentType.includes("audio")
              ? ".mp3"
              : contentType.includes("pdf")
                ? ".pdf"
                : contentType.includes("text")
                  ? ".txt"
                  : ".bin"
        filename = `download-${Date.now()}${ext}`
      }
    }

    const buffer = await response.arrayBuffer()
    return { filename, buffer: Buffer.from(buffer), size: buffer.byteLength }
  } catch (error) {
    console.error("Error downloading file:", error)
    throw error
  }
}

async function sendFileToUser(sessionId, fileBuffer, filename) {
  const sessionData = sessionManager.getSession(sessionId)
  if (!sessionData || !sessionData.isConnected || !sessionData.userNumber) {
    throw new Error("Session not connected or user number not detected")
  }

  try {
    const userJid = sessionData.userNumber + "@s.whatsapp.net"
    const fileExtension = path.extname(filename).toLowerCase()

    let messageOptions = {}

    if ([".jpg", ".jpeg", ".png", ".gif", ".webp"].includes(fileExtension)) {
      messageOptions = {
        image: fileBuffer,
        caption: filename,
      }
    } else if ([".mp4", ".avi", ".mov", ".mkv", ".webm"].includes(fileExtension)) {
      messageOptions = {
        video: fileBuffer,
        caption: filename,
      }
    } else if ([".mp3", ".wav", ".ogg", ".m4a", ".aac"].includes(fileExtension)) {
      messageOptions = {
        audio: fileBuffer,
        mimetype: "audio/mp4",
      }
    } else {
      messageOptions = {
        document: fileBuffer,
        mimetype: "application/octet-stream",
        fileName: filename,
      }
    }

    await sessionData.sock.sendMessage(userJid, messageOptions)
    console.log(`File sent successfully to session ${sessionId}:`, filename)

    return true
  } catch (error) {
    console.error("Error sending file:", error)
    throw error
  }
}

app.get("/", (req, res) => {
  const sessionId = req.query.session
  if (sessionId && /^ws_[a-zA-Z0-9_]{60,}$/.test(sessionId)) {
    res.sendFile(join(__dirname, "public", "index.html"))
  } else {
    const newSessionId = generateSecureSessionId()
    res.redirect(`/?session=${newSessionId}`)
  }
})

app.use("/media", express.static(mediaDir))
app.use("/uploads", express.static(uploadsDir))

app.get("/api/status", (req, res) => {
  const sessionId = req.headers["session-id"]
  const userAgent = req.headers["user-agent"]
  const browserInfo = req.headers["browser-info"]

  if (!sessionId) {
    return res.status(400).json({ error: "Session ID required" })
  }

  const result = sessionManager.createSession(sessionId)

  if (result.waiting) {
    return res.json({
      waiting: true,
      position: result.position,
      maxSessions: result.maxSessions,
    })
  }

  const sessionData = result.session

  if (userAgent) sessionData.userAgent = userAgent
  if (browserInfo) sessionData.browserInfo = JSON.parse(browserInfo)

  res.json({
    waiting: false,
    connected: sessionData.isConnected,
    hasQR: !!sessionData.qrCode,
    userNumber: sessionData.userNumber,
  })

  if (!sessionData.sock && !sessionData.qrCode) {
    startWhatsAppSession(sessionId)
  }
})

app.get("/api/qr", (req, res) => {
  const sessionId = req.headers["session-id"]
  const sessionData = sessionManager.getSession(sessionId)

  if (!sessionData) {
    return res.status(404).json({ error: "Session not found" })
  }

  res.json({
    qr: sessionData.qrCode,
  })
})

app.get("/api/messages", (req, res) => {
  const sessionId = req.headers["session-id"]
  const sessionData = sessionManager.getSession(sessionId)

  if (!sessionData) {
    return res.status(404).json({ error: "Session not found" })
  }

  res.json(sessionData.messageHistory.slice().reverse())
})

app.post("/api/send", async (req, res) => {
  const sessionId = req.headers["session-id"]
  const sessionData = sessionManager.getSession(sessionId)

  if (!sessionData || !sessionData.isConnected) {
    return res.status(400).json({ success: false, error: "Session not connected" })
  }

  try {
    const { message } = req.body

    if (!message) {
      return res.status(400).json({ success: false, error: "Message is required" })
    }

    const userJid = sessionData.userNumber + "@s.whatsapp.net"
    await sessionData.sock.sendMessage(userJid, { text: message })
    res.json({ success: true, message: "Message sent" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"]

    if (!req.file) {
      return res.status(400).json({ success: false, error: "No file uploaded" })
    }

    const fileBuffer = await fs.promises.readFile(req.file.path)
    await sendFileToUser(sessionId, fileBuffer, req.file.originalname)
    await fs.promises.unlink(req.file.path)

    res.json({
      success: true,
      filename: req.file.originalname,
      message: "File uploaded and sent successfully",
    })
  } catch (error) {
    console.error("Error uploading file:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

app.post("/api/download-send", async (req, res) => {
  try {
    const sessionId = req.headers["session-id"]
    const userAgent = req.headers["user-agent"] || getRandomUserAgent()
    const browserInfo = req.headers["browser-info"] ? JSON.parse(req.headers["browser-info"]) : {}
    const { url } = req.body

    if (!url) {
      return res.status(400).json({ success: false, error: "URL is required" })
    }

    const downloadResult = await downloadFileFromUrl(url, userAgent, browserInfo)
    await sendFileToUser(sessionId, downloadResult.buffer, downloadResult.filename)

    res.json({
      success: true,
      filename: downloadResult.filename,
      size: downloadResult.size,
      message: "File downloaded and sent successfully",
    })
  } catch (error) {
    console.error("Error downloading and sending file:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

try {
  const httpsOptions = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(httpsOptions, app)

  server.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTPS Server running at https://${CONFIG.DOMAIN}`)
    console.log(`WhatsApp Advanced Session Interface available at https://${CONFIG.DOMAIN}`)
    console.log(`Maximum sessions: ${CONFIG.MAX_SESSIONS}`)
  })
} catch (error) {
  console.error("Error starting HTTPS server:", error)
  console.log("Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTP Server running at http://0.0.0.0:${CONFIG.PORT}`)
  })
}

setInterval(
  () => {
    const now = Date.now()
    for (const [sessionId, sessionData] of sessionManager.sessions) {
      if (now - sessionData.createdAt > 24 * 60 * 60 * 1000) {
        console.log(`Cleaning up old session: ${sessionId}`)
        sessionManager.removeSession(sessionId)
      }
    }
  },
  60 * 60 * 1000,
)

process.on("uncaughtException", (err) => {
  console.error("Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err)
})
