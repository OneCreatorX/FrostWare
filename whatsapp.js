const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys")
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

const activeSessions = new Map()
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
const cookiesDir = join(__dirname, "cookies")

try {
  await fs.promises.mkdir(mediaDir, { recursive: true })
  await fs.promises.mkdir(uploadsDir, { recursive: true })
  await fs.promises.mkdir("public", { recursive: true })
  await fs.promises.mkdir("sessions", { recursive: true })
  await fs.promises.mkdir(tempDir, { recursive: true })
  await fs.promises.mkdir(cookiesDir, { recursive: true })
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
    .settings-btn {
      background: rgba(255,255,255,0.2);
      border: none;
      color: white;
      padding: 8px 12px;
      border-radius: 8px;
      cursor: pointer;
      font-size: 14px;
      margin-left: 10px;
    }
    .settings-btn:hover {
      background: rgba(255,255,255,0.3);
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
    .cookies-section {
      padding: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
    }
    .cookies-section h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .cookies-upload-area {
      border: 2px dashed rgba(255,255,255,0.3);
      border-radius: 10px;
      padding: 20px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s ease;
      margin-bottom: 15px;
    }
    .cookies-upload-area:hover {
      border-color: rgba(255,255,255,0.6);
      background: rgba(255,255,255,0.1);
    }
    .cookies-upload-area.dragover {
      border-color: #4CAF50;
      background: rgba(76, 175, 80, 0.1);
    }
    .cookies-status {
      font-size: 12px;
      color: rgba(255,255,255,0.8);
      text-align: center;
      margin-top: 10px;
      padding: 8px;
      border-radius: 8px;
      background: rgba(255,255,255,0.1);
    }
    .cookies-status.loaded {
      background: rgba(76, 175, 80, 0.2);
      color: #4CAF50;
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
    .settings-modal {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.8);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .settings-content {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(20px);
      border-radius: 20px;
      padding: 30px;
      max-width: 500px;
      width: 90%;
      color: white;
    }
    .settings-content h2 {
      margin-bottom: 20px;
      text-align: center;
    }
    .setting-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding: 15px;
      background: rgba(255,255,255,0.1);
      border-radius: 10px;
    }
    .setting-label {
      flex: 1;
      margin-right: 15px;
    }
    .setting-description {
      font-size: 12px;
      opacity: 0.8;
      margin-top: 5px;
    }
    .toggle-switch {
      position: relative;
      width: 60px;
      height: 30px;
      background: rgba(255,255,255,0.3);
      border-radius: 15px;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    .toggle-switch.active {
      background: #4CAF50;
    }
    .toggle-slider {
      position: absolute;
      top: 3px;
      left: 3px;
      width: 24px;
      height: 24px;
      background: white;
      border-radius: 50%;
      transition: all 0.3s ease;
    }
    .toggle-switch.active .toggle-slider {
      transform: translateX(30px);
    }
    .close-settings {
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      border: none;
      padding: 12px 30px;
      border-radius: 10px;
      cursor: pointer;
      font-size: 16px;
      width: 100%;
      margin-top: 20px;
    }
    .no-messages {
      text-align: center;
      color: rgba(255,255,255,0.7);
      padding: 50px;
      font-size: 16px;
    }
    .youtube-cookies-required {
      background: rgba(255, 193, 7, 0.2);
      border: 1px solid rgba(255, 193, 7, 0.5);
      border-radius: 10px;
      padding: 15px;
      margin: 10px 0;
      color: #ffc107;
      font-size: 14px;
      text-align: center;
    }
    .format-modal {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0,0,0,0.8);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 1000;
    }
    .format-content {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(20px);
      border-radius: 20px;
      padding: 30px;
      max-width: 600px;
      width: 90%;
      color: white;
      max-height: 80vh;
      overflow-y: auto;
    }
    .format-content h2 {
      margin-bottom: 20px;
      text-align: center;
    }
    .format-tabs {
      display: flex;
      margin-bottom: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.2);
    }
    .format-tab {
      padding: 10px 20px;
      cursor: pointer;
      border-bottom: 3px solid transparent;
      transition: all 0.3s ease;
      flex: 1;
      text-align: center;
    }
    .format-tab.active {
      border-bottom: 3px solid #4CAF50;
      background: rgba(76, 175, 80, 0.1);
    }
    .format-list {
      max-height: 50vh;
      overflow-y: auto;
      padding-right: 10px;
    }
    .format-item {
      padding: 15px;
      margin-bottom: 10px;
      background: rgba(255,255,255,0.1);
      border-radius: 10px;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      flex-direction: column;
    }
    .format-item:hover {
      background: rgba(255,255,255,0.2);
    }
    .format-item.selected {
      background: rgba(76, 175, 80, 0.2);
      border: 1px solid #4CAF50;
    }
    .format-info {
      display: flex;
      justify-content: space-between;
      margin-bottom: 5px;
    }
    .format-quality {
      font-weight: bold;
    }
    .format-size {
      opacity: 0.8;
      font-size: 12px;
    }
    .format-details {
      font-size: 12px;
      opacity: 0.8;
    }
    .format-buttons {
      display: flex;
      gap: 10px;
      margin-top: 20px;
    }
    .format-button {
      flex: 1;
      padding: 12px;
      border: none;
      border-radius: 10px;
      cursor: pointer;
      font-size: 14px;
      transition: all 0.3s ease;
    }
    .format-cancel {
      background: rgba(255,255,255,0.2);
      color: white;
    }
    .format-download {
      background: linear-gradient(45deg, #4CAF50, #45a049);
      color: white;
    }
    .format-download:hover {
      transform: translateY(-2px);
      box-shadow: 0 8px 25px rgba(76, 175, 80, 0.4);
    }
    .format-cancel:hover {
      background: rgba(255,255,255,0.3);
    }
    .format-loading {
      text-align: center;
      padding: 30px;
    }
    .format-error {
      background: rgba(244, 67, 54, 0.2);
      border: 1px solid rgba(244, 67, 54, 0.5);
      border-radius: 10px;
      padding: 15px;
      margin: 20px 0;
      color: #f44336;
      text-align: center;
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
      <div style="display: flex; align-items: center;">
        <div id="status" class="status-disconnected">Disconnected</div>
        <button class="settings-btn" onclick="openSettings()">⚙️</button>
      </div>
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
        <div class="cookies-section">
          <h3>🍪 YouTube Cookies</h3>
          <div class="cookies-upload-area" id="cookies-upload-area">
            <div class="upload-text">
              <div style="font-size: 24px; margin-bottom: 10px;">🍪</div>
              <div>Drop J2Team cookies.json here</div>
              <div style="font-size: 12px; margin-top: 5px;">Required for YouTube downloads</div>
            </div>
            <input type="file" id="cookies-input" class="file-input" accept=".json">
          </div>
          <div id="cookies-status" class="cookies-status">
            No cookies loaded - YouTube downloads disabled
          </div>
        </div>
        
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
            <div id="youtube-cookies-warning" class="youtube-cookies-required" style="display: none;">
              🍪 YouTube cookies required. Upload J2Team cookies.json above.
            </div>
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
        <div class="messages" id="messages">
          <div class="no-messages" id="no-messages">
            📱 Messages disabled by default to save data<br>
            Enable in settings to view messages
          </div>
        </div>
      </div>
    </div>
  </div>

  <div id="settings-modal" class="settings-modal">
    <div class="settings-content">
      <h2>⚙️ Settings</h2>
      
      <div class="setting-item">
        <div class="setting-label">
          <strong>Show Messages</strong>
          <div class="setting-description">Display sent/received messages in chat area</div>
        </div>
        <div class="toggle-switch" id="show-messages-toggle">
          <div class="toggle-slider"></div>
        </div>
      </div>
      
      <div class="setting-item">
        <div class="setting-label">
          <strong>Download Media</strong>
          <div class="setting-description">Download and display media files in browser</div>
        </div>
        <div class="toggle-switch" id="download-media-toggle">
          <div class="toggle-slider"></div>
        </div>
      </div>
      
      <div class="setting-item">
        <div class="setting-label">
          <strong>Auto-Delete Files</strong>
          <div class="setting-description">Automatically delete files after sending (Always enabled)</div>
        </div>
        <div class="toggle-switch active">
          <div class="toggle-slider"></div>
        </div>
      </div>
      
      <button class="close-settings" onclick="closeSettings()">Close Settings</button>
    </div>
  </div>

  <div id="format-modal" class="format-modal">
    <div class="format-content">
      <h2>Select Format</h2>
      
      <div class="format-tabs">
        <div class="format-tab active" data-tab="video">Video</div>
        <div class="format-tab" data-tab="audio">Audio</div>
      </div>
      
      <div id="format-loading" class="format-loading">
        <div class="loading-spinner"></div>
        <p>Loading available formats...</p>
      </div>
      
      <div id="format-error" class="format-error" style="display: none;">
        Error loading formats. Please try again.
      </div>
      
      <div id="video-formats" class="format-list">
        <!-- Video formats will be populated here -->
      </div>
      
      <div id="audio-formats" class="format-list" style="display: none;">
        <!-- Audio formats will be populated here -->
      </div>
      
      <div class="format-buttons">
        <button class="format-button format-cancel" id="format-cancel">Cancel</button>
        <button class="format-button format-download" id="format-download">Download & Send</button>
      </div>
    </div>
  </div>

  <script>
    let sessionId = getSessionFromUrl() || generateSecureSessionId()
    updateUrlWithSession(sessionId)
    
    let settings = {
      showMessages: ${CONFIG.SHOW_MESSAGES_BY_DEFAULT},
      downloadMedia: ${CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT},
      autoDelete: ${CONFIG.AUTO_DELETE_AFTER_SEND}
    }
    
    let hasCookies = false
    let currentUrl = ""
    let selectedFormat = null
    let availableFormats = {
      video: [],
      audio: []
    }
    
    function loadSettings() {
      const saved = localStorage.getItem('whatsapp-settings')
      if (saved) {
        settings = { ...settings, ...JSON.parse(saved) }
      }
      updateSettingsUI()
    }
    
    function saveSettings() {
      localStorage.setItem('whatsapp-settings', JSON.stringify(settings))
    }
    
    function updateSettingsUI() {
      const showMessagesToggle = document.getElementById('show-messages-toggle')
      const downloadMediaToggle = document.getElementById('download-media-toggle')
      
      if (settings.showMessages) {
        showMessagesToggle.classList.add('active')
      } else {
        showMessagesToggle.classList.remove('active')
      }
      
      if (settings.downloadMedia) {
        downloadMediaToggle.classList.add('active')
      } else {
        downloadMediaToggle.classList.remove('active')
      }
      
      updateMessagesDisplay()
    }
    
    function updateMessagesDisplay() {
      const messagesContainer = document.getElementById('messages')
      const noMessagesDiv = document.getElementById('no-messages')
      
      if (!settings.showMessages) {
        messagesContainer.innerHTML = ''
        messagesContainer.appendChild(noMessagesDiv)
        noMessagesDiv.style.display = 'block'
      } else {
        noMessagesDiv.style.display = 'none'
        loadMessages()
      }
    }
    
    function openSettings() {
      document.getElementById('settings-modal').style.display = 'flex'
    }
    
    function closeSettings() {
      document.getElementById('settings-modal').style.display = 'none'
    }
    
    document.getElementById('show-messages-toggle').addEventListener('click', function() {
      settings.showMessages = !settings.showMessages
      saveSettings()
      updateSettingsUI()
    })
    
    document.getElementById('download-media-toggle').addEventListener('click', function() {
      settings.downloadMedia = !settings.downloadMedia
      saveSettings()
      updateSettingsUI()
    })
    
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
    const cookiesUploadArea = document.getElementById("cookies-upload-area")
    const cookiesInput = document.getElementById("cookies-input")
    const cookiesStatus = document.getElementById("cookies-status")
    const youtubeCookiesWarning = document.getElementById("youtube-cookies-warning")
    const formatModal = document.getElementById("format-modal")
    const formatCancel = document.getElementById("format-cancel")
    const formatDownload = document.getElementById("format-download")
    const videoFormats = document.getElementById("video-formats")
    const audioFormats = document.getElementById("audio-formats")
    const formatLoading = document.getElementById("format-loading")
    const formatError = document.getElementById("format-error")
    const formatTabs = document.querySelectorAll(".format-tab")

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

    // Format selection modal
    formatTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        const tabType = tab.dataset.tab
        
        formatTabs.forEach(t => t.classList.remove('active'))
        tab.classList.add('active')
        
        if (tabType === 'video') {
          videoFormats.style.display = 'block'
          audioFormats.style.display = 'none'
        } else {
          videoFormats.style.display = 'none'
          audioFormats.style.display = 'block'
        }
      })
    })
    
    formatCancel.addEventListener('click', () => {
      formatModal.style.display = 'none'
      selectedFormat = null
    })
    
    formatDownload.addEventListener('click', () => {
      if (selectedFormat) {
        formatModal.style.display = 'none'
        downloadWithFormat(currentUrl, selectedFormat)
      } else {
        alert('Please select a format first')
      }
    })
    
    function showFormatModal(url) {
      currentUrl = url
      selectedFormat = null
      formatLoading.style.display = 'block'
      formatError.style.display = 'none'
      videoFormats.innerHTML = ''
      audioFormats.innerHTML = ''
      videoFormats.style.display = 'block'
      audioFormats.style.display = 'none'
      formatTabs[0].classList.add('active')
      formatTabs[1].classList.remove('active')
      formatModal.style.display = 'flex'
      
      fetchAvailableFormats(url)
    }
    
    async function fetchAvailableFormats(url) {
      try {
        const response = await fetch('/api/formats', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'session-id': sessionId
          },
          body: JSON.stringify({ url })
        })
        
        const result = await response.json()
        
        if (result.success) {
          availableFormats = {
            video: result.formats.filter(f => f.hasVideo),
            audio: result.formats.filter(f => !f.hasVideo && f.hasAudio)
          }
          
          renderFormats()
          formatLoading.style.display = 'none'
        } else {
          throw new Error(result.error)
        }
      } catch (error) {
        console.error('Error fetching formats:', error)
        formatLoading.style.display = 'none'
        formatError.style.display = 'block'
        formatError.textContent = 'Error: ' + (error.message || 'Failed to load formats')
      }
    }
    
    function renderFormats() {
      videoFormats.innerHTML = ''
      audioFormats.innerHTML = ''
      
      if (availableFormats.video.length === 0) {
        videoFormats.innerHTML = '<div class="format-error">No video formats available</div>'
      }
      
      if (availableFormats.audio.length === 0) {
        audioFormats.innerHTML = '<div class="format-error">No audio formats available</div>'
      }
      
      availableFormats.video.forEach(format => {
        const formatItem = document.createElement('div')
        formatItem.className = 'format-item'
        formatItem.dataset.formatId = format.formatId
        
        const resolution = format.height ? \`\${format.height}p\` : 'Unknown'
        const size = format.filesize ? formatFileSize(format.filesize) : 'Unknown size'
        
        formatItem.innerHTML = \`
          <div class="format-info">
            <div class="format-quality">\${resolution} \${format.qualityLabel || ''}</div>
            <div class="format-size">\${size}</div>
          </div>
          <div class="format-details">
            \${format.container || ''} | \${format.fps || '?'}fps | \${format.vcodec || 'Unknown codec'}
          </div>
        \`
        
        formatItem.addEventListener('click', () => {
          document.querySelectorAll('.format-item').forEach(item => {
            item.classList.remove('selected')
          })
          formatItem.classList.add('selected')
          selectedFormat = format
        })
        
        videoFormats.appendChild(formatItem)
      })
      
      availableFormats.audio.forEach(format => {
        const formatItem = document.createElement('div')
        formatItem.className = 'format-item'
        formatItem.dataset.formatId = format.formatId
        
        const size = format.filesize ? formatFileSize(format.filesize) : 'Unknown size'
        
        formatItem.innerHTML = \`
          <div class="format-info">
            <div class="format-quality">\${format.acodec || 'Audio'} \${format.abr ? format.abr + 'kbps' : ''}</div>
            <div class="format-size">\${size}</div>
          </div>
          <div class="format-details">
            \${format.container || ''} | \${format.asr ? (format.asr/1000) + 'kHz' : 'Unknown sample rate'}
          </div>
        \`
        
        formatItem.addEventListener('click', () => {
          document.querySelectorAll('.format-item').forEach(item => {
            item.classList.remove('selected')
          })
          formatItem.classList.add('selected')
          selectedFormat = format
        })
        
        audioFormats.appendChild(formatItem)
      })
      
      // Auto-select first format in each category
      if (availableFormats.video.length > 0) {
        const bestVideo = videoFormats.querySelector('.format-item')
        if (bestVideo) {
          bestVideo.click()
        }
      }
      
      if (availableFormats.audio.length > 0 && availableFormats.video.length === 0) {
        const bestAudio = audioFormats.querySelector('.format-item')
        if (bestAudio) {
          formatTabs[1].click()
          bestAudio.click()
        }
      }
    }
    
    function formatFileSize(bytes) {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    }

    // Cookies handling
    cookiesUploadArea.addEventListener('click', () => cookiesInput.click())
    cookiesUploadArea.addEventListener('dragover', (e) => {
      e.preventDefault()
      cookiesUploadArea.classList.add('dragover')
    })
    cookiesUploadArea.addEventListener('dragleave', () => {
      cookiesUploadArea.classList.remove('dragover')
    })
    cookiesUploadArea.addEventListener('drop', (e) => {
      e.preventDefault()
      cookiesUploadArea.classList.remove('dragover')
      const files = e.dataTransfer.files
      if (files.length > 0 && files[0].name.endsWith('.json')) {
        handleCookiesFile(files[0])
      }
    })

    cookiesInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        handleCookiesFile(e.target.files[0])
      }
    })

    async function handleCookiesFile(file) {
      try {
        const text = await file.text()
        const cookiesData = JSON.parse(text)
        
        if (cookiesData.cookies && Array.isArray(cookiesData.cookies)) {
          const formData = new FormData()
          formData.append('cookies', text)
          
          const response = await fetch('/api/upload-cookies', {
            method: 'POST',
            headers: {
              'session-id': sessionId
            },
            body: formData
          })
          
          const result = await response.json()
          if (result.success) {
            hasCookies = true
            cookiesStatus.textContent = \`✅ Cookies loaded - \${cookiesData.cookies.length} cookies from \${cookiesData.url}\`
            cookiesStatus.classList.add('loaded')
            console.log('Cookies uploaded successfully')
          } else {
            throw new Error(result.error)
          }
        } else {
          throw new Error('Invalid cookies format')
        }
      } catch (error) {
        console.error('Error uploading cookies:', error)
        cookiesStatus.textContent = '❌ Error loading cookies: ' + error.message
        cookiesStatus.classList.remove('loaded')
      }
    }

    function detectUrlType(url) {
      try {
        const urlObj = new URL(url)
        const hostname = urlObj.hostname.toLowerCase()
        
        if (hostname.includes('youtube.com') || hostname.includes('youtu.be')) {
          return { type: 'YouTube Video', icon: '🎥', color: '#ff0000', needsCookies: true, needsFormatSelection: true }
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
        
        if (urlInfo.needsCookies && !hasCookies) {
          youtubeCookiesWarning.style.display = 'block'
          downloadSendBtn.disabled = true
          downloadSendBtn.textContent = '🍪 Cookies Required'
          return
        } else {
          youtubeCookiesWarning.style.display = 'none'
          downloadSendBtn.disabled = false
        }
        
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
          if (urlInput.value.trim() === url && (!urlInfo.needsCookies || hasCookies)) {
            if (urlInfo.needsFormatSelection) {
              downloadSendBtn.textContent = '📥 Download & Send'
              downloadSendBtn.disabled = false
              showFormatModal(url)
            } else {
              downloadAndSend(url)
            }
          }
        }, 7000)
      } else {
        urlType.style.display = 'none'
        youtubeCookiesWarning.style.display = 'none'
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
            'browser-info': JSON.stringify(browserInfo),
            'show-messages': settings.showMessages,
            'download-media': settings.downloadMedia
          },
          body: formData
        })
        const result = await response.json()
        if (result.success) {
          console.log('File uploaded and sent:', result.filename)
          if (settings.showMessages) {
            setTimeout(loadMessages, 1000)
          }
        }
      } catch (error) {
        console.error('Error uploading file:', error)
      }
    }

    async function downloadAndSend(url) {
      if (!url) return

      const urlInfo = detectUrlType(url)
      if (urlInfo.needsCookies && !hasCookies) {
        alert('YouTube cookies are required. Please upload J2Team cookies.json file first.')
        return
      }
      
      if (urlInfo.needsFormatSelection) {
        showFormatModal(url)
        return
      }

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
            'browser-info': JSON.stringify(browserInfo),
            'show-messages': settings.showMessages,
            'download-media': settings.downloadMedia
          },
          body: JSON.stringify({ url, userAgent, browserInfo })
        })
        
        const result = await response.json()
        if (result.success) {
          urlInput.value = ''
          urlType.style.display = 'none'
          youtubeCookiesWarning.style.display = 'none'
          if (settings.showMessages) {
            setTimeout(loadMessages, 1000)
          }
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
    
    async function downloadWithFormat(url, format) {
      if (!url || !format) return

      downloadSendBtn.textContent = '⏳ Downloading...'
      downloadSendBtn.disabled = true
      downloadProgress.style.display = 'block'
      
      statusElement.textContent = 'Downloading...'
      statusElement.className = 'status-downloading'

      try {
        const response = await fetch('/api/download-format', {
          method: 'POST',
          headers: { 
            'Content-Type': 'application/json',
            'session-id': sessionId,
            'user-agent': userAgent,
            'browser-info': JSON.stringify(browserInfo),
            'show-messages': settings.showMessages,
            'download-media': settings.downloadMedia
          },
          body: JSON.stringify({ 
            url, 
            formatId: format.formatId,
            userAgent, 
            browserInfo 
          })
        })
        
        const result = await response.json()
        if (result.success) {
          urlInput.value = ''
          urlType.style.display = 'none'
          youtubeCookiesWarning.style.display = 'none'
          if (settings.showMessages) {
            setTimeout(loadMessages, 1000)
          }
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
      
      const urlInfo = detectUrlType(url)
      if (urlInfo.needsFormatSelection) {
        showFormatModal(url)
      } else {
        downloadAndSend(url)
      }
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
            'user-agent': userAgent,
            'show-messages': settings.showMessages
          },
          body: JSON.stringify({ message })
        })
        const result = await response.json()
        if (result.success) {
          messageInput.value = ''
          if (settings.showMessages) {
            setTimeout(loadMessages, 1000)
          }
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

    async function loadMessages() {
      if (!settings.showMessages) return
      
      try {
        const response = await fetch(\`/api/messages?session=\${sessionId}\`)
        const result = await response.json()
        if (result.success) {
          displayMessages(result.messages)
        }
      } catch (error) {
        console.error('Error loading messages:', error)
      }
    }

    function displayMessages(messages) {
      messagesList.innerHTML = ''
      messages.forEach(msg => {
        const messageDiv = document.createElement('div')
        messageDiv.className = 'message'
        
        let content = \`<div>\${msg.text || ''}</div>\`
        
        if (msg.media && settings.downloadMedia) {
          if (msg.media.type === 'image') {
            content += \`<img src="/media/\${msg.media.filename}" alt="Image" class="message-media">\`
          } else if (msg.media.type === 'video') {
            content += \`<video src="/media/\${msg.media.filename}" controls class="message-media"></video>\`
          } else if (msg.media.type === 'audio') {
            content += \`<audio src="/media/\${msg.media.filename}" controls class="message-media"></audio>\`
          } else {
            content += \`
              <div class="message-file">
                <div class="file-icon">📄</div>
                <div class="file-info">
                  <div class="file-name">\${msg.media.filename}</div>
                  <div class="file-size">\${msg.media.size || 'Unknown size'}</div>
                </div>
                <button class="download-btn" onclick="window.open('/media/\${msg.media.filename}')">📥</button>
              </div>
            \`
          }
        }
        
        content += \`<div class="message-time">\${new Date(msg.timestamp).toLocaleTimeString()}</div>\`
        messageDiv.innerHTML = content
        messagesList.appendChild(messageDiv)
      })
      messagesList.scrollTop = messagesList.scrollHeight
    }

    async function checkStatus() {
      try {
        const response = await fetch(\`/api/status?session=\${sessionId}\`)
        const result = await response.json()
        
        if (result.waiting) {
          showWaitingScreen(result.position, result.maxSessions)
          return
        }
        
        if (result.qr) {
          showQRCode(result.qr)
        } else if (result.connected) {
          showMainInterface(result.user)
        } else {
          showLoadingScreen()
        }
        
        if (result.connected) {
          statusElement.textContent = 'Connected'
          statusElement.className = 'status-connected'
        } else {
          statusElement.textContent = 'Disconnected'
          statusElement.className = 'status-disconnected'
        }
      } catch (error) {
        console.error('Error checking status:', error)
        statusElement.textContent = 'Error'
        statusElement.className = 'status-disconnected'
      }
    }

    function showWaitingScreen(position, maxSessions) {
      qrSection.style.display = 'none'
      loadingSection.style.display = 'none'
      mainContent.style.display = 'none'
      waitingSection.style.display = 'block'
      
      queuePosition.textContent = position
      positionText.textContent = position
      maxSessions.textContent = maxSessions
      
      statusElement.textContent = \`Waiting (Position \${position})\`
      statusElement.className = 'status-waiting'
    }

    function showQRCode(qrData) {
      qrSection.style.display = 'block'
      loadingSection.style.display = 'none'
      mainContent.style.display = 'none'
      waitingSection.style.display = 'none'
      qrImage.innerHTML = \`<img src="\${qrData}" alt="QR Code">\`
    }

    function showMainInterface(user) {
      qrSection.style.display = 'none'
      loadingSection.style.display = 'none'
      waitingSection.style.display = 'none'
      mainContent.style.display = 'flex'
      
      if (user) {
        userInfo.textContent = \`Connected as: \${user.name || user.id}\`
      }
      
      if (settings.showMessages) {
        loadMessages()
      }
    }

    function showLoadingScreen() {
      qrSection.style.display = 'none'
      loadingSection.style.display = 'block'
      mainContent.style.display = 'none'
      waitingSection.style.display = 'none'
    }

    loadSettings()
    checkStatus()
    setInterval(checkStatus, 3000)
  </script>
</body>
</html>`

await fs.promises.writeFile("public/index.html", htmlContent)

app.get("/", (req, res) => {
  res.sendFile(join(__dirname, "public", "index.html"))
})

app.get("/api/status", async (req, res) => {
  const sessionId = req.query.session
  if (!sessionId) {
    return res.json({ error: "Session ID required" })
  }

  const session = activeSessions.get(sessionId)
  if (!session) {
    const queueIndex = waitingQueue.findIndex((q) => q.sessionId === sessionId)
    if (queueIndex !== -1) {
      return res.json({
        waiting: true,
        position: queueIndex + 1,
        maxSessions: CONFIG.MAX_SESSIONS,
      })
    }

    if (activeSessions.size >= CONFIG.MAX_SESSIONS) {
      if (!waitingQueue.find((q) => q.sessionId === sessionId)) {
        waitingQueue.push({ sessionId, timestamp: Date.now() })
      }
      const position = waitingQueue.findIndex((q) => q.sessionId === sessionId) + 1
      return res.json({
        waiting: true,
        position,
        maxSessions: CONFIG.MAX_SESSIONS,
      })
    }

    try {
      const sessionDir = join(__dirname, "sessions", sessionId)
      await fs.promises.mkdir(sessionDir, { recursive: true })

      const { state, saveCreds } = await useMultiFileAuthState(sessionDir)
      let sock
      try {
        sock = makeWASocket({
          auth: state,
          printQRInTerminal: false,
          browser: Browsers.macOS("Desktop"),
          generateHighQualityLinkPreview: true,
        })
      } catch (e) {
        console.log(e)
      }

      const sessionData = {
        sock,
        saveCreds,
        qr: null,
        connected: false,
        user: null,
        messages: [],
        lastActivity: Date.now(),
      }

      sock.ev.on("creds.update", saveCreds)

      sock.ev.on("connection.update", async (update) => {
        const { connection, lastDisconnect, qr } = update

        if (qr) {
          try {
            const qrImage = await qrcode.toDataURL(qr)
            sessionData.qr = qrImage
          } catch (err) {
            console.error("QR generation error:", err)
          }
        }

        if (connection === "close") {
          const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
          console.log("Connection closed due to", lastDisconnect?.error, ", reconnecting", shouldReconnect)

          if (shouldReconnect) {
            setTimeout(() => {
              if (activeSessions.has(sessionId)) {
                activeSessions.delete(sessionId)
                processQueue()
              }
            }, 3000)
          } else {
            activeSessions.delete(sessionId)
            processQueue()
          }
        } else if (connection === "open") {
          console.log("WhatsApp connection opened for session:", sessionId)
          sessionData.connected = true
          sessionData.qr = null
          sessionData.user = sock.user
        }
      })

      sock.ev.on("messages.upsert", async (m) => {
        sessionData.lastActivity = Date.now()
        const message = m.messages[0]
        if (!message.key.fromMe) return

        const messageData = {
          id: message.key.id,
          text: message.message?.conversation || message.message?.extendedTextMessage?.text || "",
          timestamp: Date.now(),
          media: null,
        }

        if (
          message.message?.imageMessage ||
          message.message?.videoMessage ||
          message.message?.audioMessage ||
          message.message?.documentMessage
        ) {
          try {
            const mediaType = message.message.imageMessage
              ? "image"
              : message.message.videoMessage
                ? "video"
                : message.message.audioMessage
                  ? "audio"
                  : "document"

            const mediaMessage = message.message[mediaType + "Message"]
            const buffer = await downloadMediaMessage(message, "buffer", {})

            const extension =
              mediaType === "image" ? "jpg" : mediaType === "video" ? "mp4" : mediaType === "audio" ? "mp3" : "bin"
            const filename = `${Date.now()}-${sessionId}.${extension}`
            const filepath = join(mediaDir, filename)

            await fs.promises.writeFile(filepath, buffer)

            messageData.media = {
              type: mediaType,
              filename,
              size: buffer.length,
              mimetype: mediaMessage.mimetype,
            }

            if (CONFIG.AUTO_DELETE_AFTER_SEND) {
              setTimeout(async () => {
                try {
                  await fs.promises.unlink(filepath)
                  console.log(`Auto-deleted file: ${filename}`)
                } catch (err) {
                  console.error(`Error auto-deleting file ${filename}:`, err)
                }
              }, 300000)
            }
          } catch (err) {
            console.error("Error processing media:", err)
          }
        }

        sessionData.messages.push(messageData)
        if (sessionData.messages.length > 100) {
          sessionData.messages = sessionData.messages.slice(-50)
        }
      })

      activeSessions.set(sessionId, sessionData)
      processQueue()
    } catch (error) {
      console.error("Error creating session:", error)
      return res.json({ error: "Failed to create session" })
    }
  }

  const sessionData = activeSessions.get(sessionId)
  if (!sessionData) {
    return res.json({ error: "Session not found" })
  }

  res.json({
    connected: sessionData.connected,
    qr: sessionData.qr,
    user: sessionData.user,
    waiting: false,
  })
})

function processQueue() {
  while (waitingQueue.length > 0 && activeSessions.size < CONFIG.MAX_SESSIONS) {
    const next = waitingQueue.shift()
    console.log(`Processing queued session: ${next.sessionId}`)
  }
}

app.get("/api/messages", (req, res) => {
  const sessionId = req.query.session
  const session = activeSessions.get(sessionId)

  if (!session) {
    return res.json({ error: "Session not found" })
  }

  res.json({
    success: true,
    messages: session.messages || [],
  })
})

app.post("/api/send", async (req, res) => {
  const sessionId = req.headers["session-id"]
  const { message } = req.body
  const session = activeSessions.get(sessionId)

  if (!session || !session.connected) {
    return res.json({ error: "Session not connected" })
  }

  try {
    const userJid = session.user.id
    await session.sock.sendMessage(userJid, { text: message })

    session.lastActivity = Date.now()
    res.json({ success: true })
  } catch (error) {
    console.error("Error sending message:", error)
    res.json({ error: "Failed to send message" })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  const sessionId = req.headers["session-id"]
  const session = activeSessions.get(sessionId)

  if (!session || !session.connected) {
    return res.json({ error: "Session not connected" })
  }

  if (!req.file) {
    return res.json({ error: "No file uploaded" })
  }

  try {
    const userJid = session.user.id
    const filePath = req.file.path
    const mimeType = req.file.mimetype

    let messageContent = {}

    if (mimeType.startsWith("image/")) {
      messageContent = {
        image: { url: filePath },
        caption: req.file.originalname,
      }
    } else if (mimeType.startsWith("video/")) {
      messageContent = {
        video: { url: filePath },
        caption: req.file.originalname,
      }
    } else if (mimeType.startsWith("audio/")) {
      messageContent = {
        audio: { url: filePath },
        mimetype: mimeType,
      }
    } else {
      messageContent = {
        document: { url: filePath },
        mimetype: mimeType,
        fileName: req.file.originalname,
      }
    }

    await session.sock.sendMessage(userJid, messageContent)

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      setTimeout(async () => {
        try {
          await fs.promises.unlink(filePath)
          console.log(`Auto-deleted uploaded file: ${req.file.filename}`)
        } catch (err) {
          console.error(`Error auto-deleting uploaded file ${req.file.filename}:`, err)
        }
      }, 5000)
    }

    session.lastActivity = Date.now()
    res.json({ success: true, filename: req.file.filename })
  } catch (error) {
    console.error("Error sending file:", error)
    res.json({ error: "Failed to send file" })
  }
})

app.post("/api/upload-cookies", upload.single("cookies"), async (req, res) => {
  const sessionId = req.headers["session-id"]

  if (!req.file) {
    return res.json({ error: "No cookies file uploaded" })
  }

  try {
    const cookiesText = await fs.promises.readFile(req.file.path, "utf8")
    const cookiesData = JSON.parse(cookiesText)

    if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
      throw new Error("Invalid cookies format")
    }

    const netscapeCookies = cookiesData.cookies
      .map((cookie) => {
        const domain = cookie.domain.startsWith(".") ? cookie.domain : "." + cookie.domain
        const flag = cookie.httpOnly ? "TRUE" : "FALSE"
        const path = cookie.path || "/"
        const secure = cookie.secure ? "TRUE" : "FALSE"
        const expiration = cookie.expirationDate ? Math.floor(cookie.expirationDate) : 0
        const name = cookie.name
        const value = cookie.value

        return `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}`
      })
      .join("\n")

    const cookiesFilePath = join(cookiesDir, `${sessionId}_cookies.txt`)
    await fs.promises.writeFile(cookiesFilePath, `# Netscape HTTP Cookie File\n${netscapeCookies}`)

    cookiesStorage.set(sessionId, {
      path: cookiesFilePath,
      count: cookiesData.cookies.length,
      domain: cookiesData.url,
      timestamp: Date.now(),
    })

    await fs.promises.unlink(req.file.path)

    res.json({
      success: true,
      message: `Cookies saved successfully`,
      count: cookiesData.cookies.length,
    })
  } catch (error) {
    console.error("Error processing cookies:", error)
    res.json({ error: "Failed to process cookies: " + error.message })
  }
})

app.post("/api/formats", async (req, res) => {
  const sessionId = req.headers["session-id"]
  const { url } = req.body

  if (!url) {
    return res.json({ error: "URL is required" })
  }

  try {
    const cookiesInfo = cookiesStorage.get(sessionId)
    let cookiesArg = ""
    if (cookiesInfo) {
      cookiesArg = `--cookies "${cookiesInfo.path}"`
    }

    const { stdout } = await execAsync(`yt-dlp --dump-json --no-download ${cookiesArg} "${url}"`, { timeout: 30000 })

    const videoInfo = JSON.parse(stdout.trim())
    const formats = []

    if (videoInfo.formats) {
      videoInfo.formats.forEach((format) => {
        if (format.format_id && (format.vcodec !== "none" || format.acodec !== "none")) {
          formats.push({
            formatId: format.format_id,
            container: format.ext,
            qualityLabel: format.format_note || format.quality,
            height: format.height,
            width: format.width,
            fps: format.fps,
            vcodec: format.vcodec,
            acodec: format.acodec,
            filesize: format.filesize || format.filesize_approx,
            abr: format.abr,
            asr: format.asr,
            hasVideo: format.vcodec && format.vcodec !== "none",
            hasAudio: format.acodec && format.acodec !== "none",
          })
        }
      })
    }

    // Sort formats by quality
    const videoFormats = formats.filter((f) => f.hasVideo).sort((a, b) => (b.height || 0) - (a.height || 0))

    const audioFormats = formats.filter((f) => !f.hasVideo && f.hasAudio).sort((a, b) => (b.abr || 0) - (a.abr || 0))

    res.json({
      success: true,
      formats: [...videoFormats, ...audioFormats],
      title: videoInfo.title,
      duration: videoInfo.duration,
    })
  } catch (error) {
    console.error("Error fetching formats:", error)
    res.json({ error: "Failed to fetch formats: " + error.message })
  }
})

app.post("/api/download-format", async (req, res) => {
  const sessionId = req.headers["session-id"]
  const { url, formatId, userAgent, browserInfo } = req.body
  const session = activeSessions.get(sessionId)

  if (!session || !session.connected) {
    return res.json({ error: "Session not connected" })
  }

  if (!url || !formatId) {
    return res.json({ error: "URL and format ID are required" })
  }

  try {
    const tempFilename = `download_${Date.now()}_${sessionId}`
    const tempPath = join(tempDir, tempFilename)

    const cookiesInfo = cookiesStorage.get(sessionId)
    let cookiesArg = ""
    if (cookiesInfo) {
      cookiesArg = `--cookies "${cookiesInfo.path}"`
    }

    const command = `yt-dlp -f "${formatId}" ${cookiesArg} --user-agent "${userAgent || getRandomUserAgent()}" -o "${tempPath}.%(ext)s" "${url}"`

    console.log(`Downloading with format ${formatId}:`, url)
    const { stdout, stderr } = await execAsync(command, { timeout: 300000 })

    const files = await fs.promises.readdir(tempDir)
    const downloadedFile = files.find((file) => file.startsWith(tempFilename))

    if (!downloadedFile) {
      throw new Error("Downloaded file not found")
    }

    const filePath = join(tempDir, downloadedFile)
    const stats = await fs.promises.stat(filePath)
    const mimeType = downloadedFile.includes(".mp4")
      ? "video/mp4"
      : downloadedFile.includes(".mp3")
        ? "audio/mp3"
        : "application/octet-stream"

    const userJid = session.user.id
    let messageContent = {}

    if (mimeType.startsWith("video/")) {
      messageContent = {
        video: { url: filePath },
        caption: `Downloaded: ${url}`,
      }
    } else if (mimeType.startsWith("audio/")) {
      messageContent = {
        audio: { url: filePath },
        mimetype: mimeType,
      }
    } else {
      messageContent = {
        document: { url: filePath },
        mimetype: mimeType,
        fileName: downloadedFile,
      }
    }

    await session.sock.sendMessage(userJid, messageContent)

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      setTimeout(async () => {
        try {
          await fs.promises.unlink(filePath)
          console.log(`Auto-deleted downloaded file: ${downloadedFile}`)
        } catch (err) {
          console.error(`Error auto-deleting downloaded file ${downloadedFile}:`, err)
        }
      }, 5000)
    }

    session.lastActivity = Date.now()
    res.json({ success: true, filename: downloadedFile, size: stats.size })
  } catch (error) {
    console.error("Error downloading with format:", error)
    res.json({ error: "Download failed: " + error.message })
  }
})

app.post("/api/download-send", async (req, res) => {
  const sessionId = req.headers["session-id"]
  const { url, userAgent, browserInfo } = req.body
  const session = activeSessions.get(sessionId)

  if (!session || !session.connected) {
    return res.json({ error: "Session not connected" })
  }

  if (!url) {
    return res.json({ error: "URL is required" })
  }

  try {
    const tempFilename = `download_${Date.now()}_${sessionId}`
    const tempPath = join(tempDir, tempFilename)

    let command = ""
    const urlLower = url.toLowerCase()

    const cookiesInfo = cookiesStorage.get(sessionId)
    let cookiesArg = ""
    if (cookiesInfo) {
      cookiesArg = `--cookies "${cookiesInfo.path}"`
    }

    if (urlLower.includes("youtube.com") || urlLower.includes("youtu.be")) {
      if (!cookiesInfo) {
        return res.json({ error: "YouTube downloads require cookies. Please upload J2Team cookies.json file." })
      }
      command = `yt-dlp ${cookiesArg} --user-agent "${userAgent || getRandomUserAgent()}" -o "${tempPath}.%(ext)s" "${url}"`
    } else if (urlLower.includes("instagram.com")) {
      command = `gallery-dl --user-agent "${userAgent || getRandomUserAgent()}" -d "${tempDir}" "${url}"`
    } else if (urlLower.includes("tiktok.com")) {
      command = `yt-dlp --user-agent "${userAgent || getRandomUserAgent()}" -o "${tempPath}.%(ext)s" "${url}"`
    } else if (urlLower.includes("twitter.com") || urlLower.includes("x.com")) {
      command = `gallery-dl --user-agent "${userAgent || getRandomUserAgent()}" -d "${tempDir}" "${url}"`
    } else if (urlLower.includes("facebook.com") || urlLower.includes("fb.watch")) {
      command = `yt-dlp --user-agent "${userAgent || getRandomUserAgent()}" -o "${tempPath}.%(ext)s" "${url}"`
    } else if (urlLower.includes("reddit.com")) {
      command = `gallery-dl --user-agent "${userAgent || getRandomUserAgent()}" -d "${tempDir}" "${url}"`
    } else if (
      url.match(/\.(jpg|jpeg|png|gif|webp|mp4|avi|mov|mkv|webm|mp3|wav|ogg|m4a|flac|pdf|doc|docx|txt|zip|rar)$/i)
    ) {
      const response = await fetch(url, {
        headers: createBrowserHeaders(userAgent || getRandomUserAgent()),
      })
      if (!response.ok) throw new Error(`HTTP ${response.status}`)

      const buffer = await response.arrayBuffer()
      const extension = url.split(".").pop().toLowerCase()
      const filename = `${tempFilename}.${extension}`
      const filePath = join(tempDir, filename)

      await fs.promises.writeFile(filePath, Buffer.from(buffer))

      const stats = await fs.promises.stat(filePath)
      const mimeType = response.headers.get("content-type") || "application/octet-stream"

      const userJid = session.user.id
      let messageContent = {}

      if (mimeType.startsWith("image/")) {
        messageContent = {
          image: { url: filePath },
          caption: `Downloaded: ${url}`,
        }
      } else if (mimeType.startsWith("video/")) {
        messageContent = {
          video: { url: filePath },
          caption: `Downloaded: ${url}`,
        }
      } else if (mimeType.startsWith("audio/")) {
        messageContent = {
          audio: { url: filePath },
          mimetype: mimeType,
        }
      } else {
        messageContent = {
          document: { url: filePath },
          mimetype: mimeType,
          fileName: filename,
        }
      }

      await session.sock.sendMessage(userJid, messageContent)

      if (CONFIG.AUTO_DELETE_AFTER_SEND) {
        setTimeout(async () => {
          try {
            await fs.promises.unlink(filePath)
            console.log(`Auto-deleted downloaded file: ${filename}`)
          } catch (err) {
            console.error(`Error auto-deleting downloaded file ${filename}:`, err)
          }
        }, 5000)
      }

      session.lastActivity = Date.now()
      return res.json({ success: true, filename, size: stats.size })
    } else {
      command = `yt-dlp --user-agent "${userAgent || getRandomUserAgent()}" -o "${tempPath}.%(ext)s" "${url}"`
    }

    console.log("Downloading:", url)
    const { stdout, stderr } = await execAsync(command, { timeout: 300000 })

    const files = await fs.promises.readdir(tempDir)
    const downloadedFiles = files.filter((file) => file.startsWith(tempFilename) || file.includes(sessionId))

    if (downloadedFiles.length === 0) {
      throw new Error("No files downloaded")
    }

    for (const filename of downloadedFiles) {
      const filePath = join(tempDir, filename)
      const stats = await fs.promises.stat(filePath)

      if (stats.isFile()) {
        const mimeType = filename.includes(".mp4")
          ? "video/mp4"
          : filename.includes(".jpg") || filename.includes(".jpeg") || filename.includes(".png")
            ? "image/jpeg"
            : filename.includes(".mp3")
              ? "audio/mp3"
              : "application/octet-stream"

        const userJid = session.user.id
        let messageContent = {}

        if (mimeType.startsWith("image/")) {
          messageContent = {
            image: { url: filePath },
            caption: `Downloaded: ${url}`,
          }
        } else if (mimeType.startsWith("video/")) {
          messageContent = {
            video: { url: filePath },
            caption: `Downloaded: ${url}`,
          }
        } else if (mimeType.startsWith("audio/")) {
          messageContent = {
            audio: { url: filePath },
            mimetype: mimeType,
          }
        } else {
          messageContent = {
            document: { url: filePath },
            mimetype: mimeType,
            fileName: filename,
          }
        }

        await session.sock.sendMessage(userJid, messageContent)

        if (CONFIG.AUTO_DELETE_AFTER_SEND) {
          setTimeout(async () => {
            try {
              await fs.promises.unlink(filePath)
              console.log(`Auto-deleted downloaded file: ${filename}`)
            } catch (err) {
              console.error(`Error auto-deleting downloaded file ${filename}:`, err)
            }
          }, 5000)
        }
      }
    }

    session.lastActivity = Date.now()
    res.json({ success: true, files: downloadedFiles.length })
  } catch (error) {
    console.error("Error downloading file:", error)
    res.json({ error: "Download failed: " + error.message })
  }
})

app.use("/media", express.static(mediaDir))

setInterval(
  () => {
    const now = Date.now()
    const inactiveThreshold = 30 * 60 * 1000

    for (const [sessionId, session] of activeSessions.entries()) {
      if (now - session.lastActivity > inactiveThreshold) {
        console.log(`Cleaning up inactive session: ${sessionId}`)
        try {
          session.sock.end()
        } catch (err) {
          console.error("Error ending socket:", err)
        }
        activeSessions.delete(sessionId)

        const cookiesInfo = cookiesStorage.get(sessionId)
        if (cookiesInfo) {
          try {
            fs.promises.unlink(cookiesInfo.path).catch(() => {})
          } catch (err) {
            console.error("Error deleting cookies file:", err)
          }
          cookiesStorage.delete(sessionId)
        }

        processQueue()
      }
    }

    const oldCacheEntries = []
    for (const [key, entry] of mediaCache.entries()) {
      if (now - entry.timestamp > 10 * 60 * 1000) {
        oldCacheEntries.push(key)
      }
    }

    oldCacheEntries.forEach((key) => {
      const entry = mediaCache.get(key)
      if (entry && entry.filePath) {
        fs.promises.unlink(entry.filePath).catch(() => {})
      }
      mediaCache.delete(key)
    })
  },
  5 * 60 * 1000,
)

const sslOptions = {
  key: fs.readFileSync(CONFIG.SSL_KEY),
  cert: fs.readFileSync(CONFIG.SSL_CERT),
  ca: fs.readFileSync(CONFIG.SSL_CA),
}

const server = https.createServer(sslOptions, app)

server.listen(CONFIG.PORT, () => {
  console.log(`🚀 WhatsApp Personal Interface running on https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
  console.log(`📱 Maximum concurrent sessions: ${CONFIG.MAX_SESSIONS}`)
  console.log(`⏱️  Auto-download delay: ${CONFIG.AUTO_DOWNLOAD_DELAY / 1000}s`)
  console.log(`🗑️  Auto-delete after send: ${CONFIG.AUTO_DELETE_AFTER_SEND ? "Enabled" : "Disabled"}`)
  console.log(`💬 Show messages by default: ${CONFIG.SHOW_MESSAGES_BY_DEFAULT ? "Enabled" : "Disabled"}`)
  console.log(`📥 Download media by default: ${CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT ? "Enabled" : "Disabled"}`)
})
