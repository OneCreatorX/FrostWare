const { makeWASocket, useMultiFileAuthState } = await import("@whiskeysockets/baileys");
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
  AUTO_DELETE_AFTER_SEND: true,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const sessionStates = new Map()
const waitingQueue = []
const cookiesStorage = new Map()
const qrCodes = new Map()

const userAgents = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
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

function convertJsonToNetscape(cookies) {
  console.log(`🍪 Converting ${cookies.length} cookies to Netscape format`)

  let netscapeFormat = "# Netscape HTTP Cookie File\n"
  netscapeFormat += "# This is a generated file! Do not edit.\n\n"

  let validCookies = 0

  cookies.forEach((cookie, index) => {
    try {
      const domain = cookie.domain || cookie.Domain || ""
      if (!domain) {
        console.log(`⚠️ Cookie ${index}: Missing domain, skipping`)
        return
      }

      const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
      const path = cookie.path || cookie.Path || "/"
      const secure = cookie.secure === true || cookie.secure === "true" || cookie.Secure === true ? "TRUE" : "FALSE"

      let expiration = cookie.expirationDate || cookie.expires || cookie.Expires || cookie.ExpirationDate

      if (!expiration || expiration === -1) {
        expiration = Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
      } else if (typeof expiration === "number") {
        if (expiration > 9999999999) {
          expiration = Math.floor(expiration / 1000)
        } else {
          expiration = Math.floor(expiration)
        }
      } else if (typeof expiration === "string") {
        expiration = Math.floor(Number.parseFloat(expiration))
        if (isNaN(expiration)) {
          expiration = Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
        }
      }

      const name = cookie.name || cookie.Name || ""
      const value = cookie.value || cookie.Value || ""

      if (!name) {
        console.log(`⚠️ Cookie ${index}: Missing name, skipping`)
        return
      }

      netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
      validCookies++

      if (name.includes("session") || name.includes("auth") || name.includes("login")) {
        console.log(`🔑 Found important cookie: ${name} for domain ${domain}`)
      }
    } catch (error) {
      console.error(`❌ Error processing cookie ${index}:`, error)
    }
  })

  console.log(`✅ Converted ${validCookies}/${cookies.length} cookies successfully`)
  return netscapeFormat
}

function validateCookies(cookiesData) {
  if (!cookiesData || typeof cookiesData !== "object") {
    throw new Error("Invalid cookies data: must be an object")
  }

  if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
    throw new Error("Invalid cookies format: missing cookies array")
  }

  if (cookiesData.cookies.length === 0) {
    throw new Error("No cookies found in the file")
  }

  const youtubeCookies = cookiesData.cookies.filter(
    (cookie) =>
      (cookie.domain || cookie.Domain || "").includes("youtube") ||
      (cookie.domain || cookie.Domain || "").includes("google"),
  )

  if (youtubeCookies.length === 0) {
    console.log("⚠️ Warning: No YouTube/Google cookies found")
  } else {
    console.log(`🎯 Found ${youtubeCookies.length} YouTube/Google cookies`)
  }

  const importantCookies = cookiesData.cookies.filter((cookie) => {
    const name = (cookie.name || cookie.Name || "").toLowerCase()
    return (
      name.includes("session") ||
      name.includes("auth") ||
      name.includes("login") ||
      name.includes("sapisid") ||
      name.includes("hsid") ||
      name.includes("ssid")
    )
  })

  console.log(`🔐 Found ${importantCookies.length} authentication cookies`)

  return true
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

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp YouTube Interface</title>
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
    .main-content {
      display: flex;
      height: calc(100vh - 140px);
      gap: 20px;
    }
    .sidebar {
      width: 400px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
      padding: 20px;
      overflow-y: auto;
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
    .upload-area {
      border: 2px dashed rgba(255,255,255,0.3);
      border-radius: 10px;
      padding: 20px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s ease;
      margin-bottom: 15px;
      color: white;
    }
    .upload-area:hover {
      border-color: rgba(255,255,255,0.6);
      background: rgba(255,255,255,0.1);
    }
    .upload-area.dragover {
      border-color: #4CAF50;
      background: rgba(76, 175, 80, 0.1);
    }
    .file-input {
      display: none;
    }
    .url-input {
      width: 100%;
      padding: 12px;
      border: none;
      border-radius: 8px;
      background: rgba(255,255,255,0.2);
      color: white;
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
      margin-bottom: 10px;
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
    .cookies-status {
      font-size: 12px;
      color: rgba(255,255,255,0.8);
      text-align: center;
      margin-top: 10px;
      padding: 12px;
      border-radius: 8px;
      background: rgba(255,255,255,0.1);
      border: 1px solid rgba(255,255,255,0.2);
    }
    .cookies-status.loaded {
      background: rgba(76, 175, 80, 0.2);
      color: #4CAF50;
      border-color: #4CAF50;
    }
    .cookies-status.error {
      background: rgba(244, 67, 54, 0.2);
      color: #f44336;
      border-color: #f44336;
    }
    h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .section {
      margin-bottom: 25px;
      padding-bottom: 20px;
      border-bottom: 1px solid rgba(255,255,255,0.1);
    }
    .section:last-child {
      border-bottom: none;
    }
    .cookies-info {
      font-size: 11px;
      color: rgba(255,255,255,0.6);
      margin-top: 8px;
      line-height: 1.4;
    }
    .test-section {
      margin-top: 15px;
    }
    .test-url {
      font-size: 11px;
      color: rgba(255,255,255,0.6);
      margin-bottom: 8px;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <div>
        <h1>📱 WhatsApp YouTube Interface</h1>
        <div class="session-info" id="session-info">Session: Loading...</div>
      </div>
      <div id="status" class="status-disconnected">Disconnected</div>
    </header>
    
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
        <div class="section">
          <h3>🍪 YouTube Cookies (Required)</h3>
          <div class="upload-area" id="cookies-upload-area">
            <div style="font-size: 24px; margin-bottom: 10px;">🍪</div>
            <div>Drop J2Team cookies.json here</div>
            <div style="font-size: 12px; margin-top: 5px;">Required for YouTube downloads</div>
            <input type="file" id="cookies-input" class="file-input" accept=".json">
          </div>
          <div id="cookies-status" class="cookies-status">
            ❌ No cookies loaded - YouTube downloads will fail
          </div>
          <div class="cookies-info">
            📋 Instructions:<br>
            1. Install J2Team Cookies extension<br>
            2. Login to YouTube<br>
            3. Click extension → Export as JSON<br>
            4. Upload the cookies.json file here
          </div>
        </div>
        
        <div class="section">
          <h3>📎 Send Files</h3>
          <div class="upload-area" id="upload-area">
            <div style="font-size: 24px; margin-bottom: 10px;">📁</div>
            <div>Drop files here or click to select</div>
            <div style="font-size: 12px; margin-top: 5px;">Images, videos, audio, documents</div>
            <input type="file" id="file-input" class="file-input" multiple accept="*/*">
          </div>
        </div>
        
        <div class="section">
          <h3>🎬 Download & Send URLs</h3>
          <input type="text" id="url-input" class="url-input" placeholder="Paste YouTube, TikTok, Instagram, etc. URL...">
          <button id="download-send-btn" class="btn">📥 Download & Send</button>
          <div class="test-section">
            <div class="test-url">Test with: https://youtu.be/dQw4w9WgXcQ</div>
            <button id="test-download-btn" class="btn" style="font-size: 12px; padding: 8px;">🧪 Test Download</button>
          </div>
        </div>
        
        <div class="section">
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
          <div style="text-align: center; color: rgba(255,255,255,0.7); padding: 50px;">
            📱 Ready to send messages and files!<br>
            🍪 Upload YouTube cookies first for video downloads
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <script>
    let sessionId = localStorage.getItem('whatsapp-session-id') || generateSecureSessionId();
    localStorage.setItem('whatsapp-session-id', sessionId);
    
    function generateSecureSessionId() {
      const timestamp = Date.now().toString(36);
      const randomBytes = Array.from(crypto.getRandomValues(new Uint8Array(32)), 
        b => b.toString(16).padStart(2, '0')).join('');
      const combined = timestamp + randomBytes;
      return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g, '').substring(0, 48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)), b => b.toString(16).padStart(2, '0')).join('')}\`;
    }

    const statusElement = document.getElementById("status");
    const sessionInfoElement = document.getElementById("session-info");
    const messagesList = document.getElementById("messages");
    const messageInput = document.getElementById("message-input");
    const sendMessageBtn = document.getElementById("send-message-btn");
    const qrSection = document.getElementById("qr-section");
    const loadingSection = document.getElementById("loading-section");
    const mainContent = document.getElementById("main-content");
    const qrImage = document.getElementById("qr-image");
    const uploadArea = document.getElementById("upload-area");
    const fileInput = document.getElementById("file-input");
    const urlInput = document.getElementById("url-input");
    const downloadSendBtn = document.getElementById("download-send-btn");
    const testDownloadBtn = document.getElementById("test-download-btn");
    const userInfo = document.getElementById("user-info");
    const cookiesUploadArea = document.getElementById("cookies-upload-area");
    const cookiesInput = document.getElementById("cookies-input");
    const cookiesStatus = document.getElementById("cookies-status");

    let hasCookies = false;

    sessionInfoElement.textContent = \`Session: \${sessionId.substring(3, 15)}...\`;

    // Manejo de cookies
    cookiesUploadArea.addEventListener('click', () => cookiesInput.click());
    cookiesUploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      cookiesUploadArea.classList.add('dragover');
    });
    cookiesUploadArea.addEventListener('dragleave', () => {
      cookiesUploadArea.classList.remove('dragover');
    });
    cookiesUploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      cookiesUploadArea.classList.remove('dragover');
      const files = e.dataTransfer.files;
      if (files.length > 0 && files[0].name.endsWith('.json')) {
        handleCookiesFile(files[0]);
      }
    });

    cookiesInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        handleCookiesFile(e.target.files[0]);
      }
    });

    async function handleCookiesFile(file) {
      try {
        cookiesStatus.textContent = '⏳ Processing cookies...';
        cookiesStatus.className = 'cookies-status';
        
        const text = await file.text();
        const cookiesData = JSON.parse(text);
        
        if (cookiesData.url && cookiesData.cookies && Array.isArray(cookiesData.cookies)) {
          const formData = new FormData();
          formData.append('cookiesFile', file);
          
          const response = await fetch(\`/api/cookies?session=\${sessionId}\`, {
            method: 'POST',
            body: formData
          });
          
          const result = await response.json();
          if (result.success) {
            hasCookies = true;
            cookiesStatus.textContent = \`✅ \${result.message}\`;
            cookiesStatus.classList.add('loaded');
          } else {
            throw new Error(result.error);
          }
        } else {
          throw new Error('Invalid J2Team cookies format. Expected {url, cookies} structure.');
        }
      } catch (error) {
        cookiesStatus.textContent = '❌ Error: ' + error.message;
        cookiesStatus.classList.add('error');
        hasCookies = false;
      }
    }

    // Manejo de archivos
    uploadArea.addEventListener('click', () => fileInput.click());
    uploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      uploadArea.classList.add('dragover');
    });
    uploadArea.addEventListener('dragleave', () => {
      uploadArea.classList.remove('dragover');
    });
    uploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      uploadArea.classList.remove('dragover');
      const files = e.dataTransfer.files;
      handleFiles(files);
    });

    fileInput.addEventListener('change', (e) => {
      handleFiles(e.target.files);
    });

    async function handleFiles(files) {
      for (let file of files) {
        await uploadFile(file);
      }
    }

    async function uploadFile(file) {
      const formData = new FormData();
      formData.append('file', file);

      try {
        const response = await fetch(\`/api/upload?session=\${sessionId}\`, {
          method: 'POST',
          body: formData
        });
        const result = await response.json();
        if (result.success) {
          console.log('File uploaded and sent:', result.filename);
        } else {
          alert('Upload failed: ' + result.error);
        }
      } catch (error) {
        console.error('Error uploading file:', error);
        alert('Upload failed: ' + error.message);
      }
    }

    // Descargar y enviar URL
    downloadSendBtn.addEventListener('click', () => downloadUrl(urlInput.value.trim()));
    testDownloadBtn.addEventListener('click', () => downloadUrl('https://youtu.be/dQw4w9WgXcQ'));

    async function downloadUrl(url) {
      if (!url) return;

      if (url.includes('youtube.com') || url.includes('youtu.be')) {
        if (!hasCookies) {
          alert('⚠️ YouTube cookies required! Please upload J2Team cookies first.');
          return;
        }
      }

      const originalText = downloadSendBtn.textContent;
      downloadSendBtn.textContent = '⏳ Downloading...';
      downloadSendBtn.disabled = true;

      try {
        const response = await fetch(\`/api/download?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        });
        const result = await response.json();
        if (result.success) {
          urlInput.value = '';
          alert('✅ Downloaded and sent successfully!');
        } else {
          alert('❌ Download failed: ' + result.error);
        }
      } catch (error) {
        alert('❌ Download failed: ' + error.message);
      } finally {
        downloadSendBtn.textContent = originalText;
        downloadSendBtn.disabled = false;
      }
    }

    // Enviar mensaje
    sendMessageBtn.addEventListener('click', async () => {
      const message = messageInput.value.trim();
      if (!message) return;

      try {
        const response = await fetch(\`/api/send?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message })
        });
        const result = await response.json();
        if (result.success) {
          messageInput.value = '';
        } else {
          alert('Send failed: ' + result.error);
        }
      } catch (error) {
        console.error('Error sending message:', error);
        alert('Send failed: ' + error.message);
      }
    });

    messageInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessageBtn.click();
      }
    });

    // Verificar estado de la sesión
    async function checkStatus() {
      try {
        const response = await fetch(\`/api/status?session=\${sessionId}\`);
        const result = await response.json();

        if (result.status === 'connected') {
          statusElement.textContent = 'Connected';
          statusElement.className = 'status-connected';
          qrSection.style.display = 'none';
          loadingSection.style.display = 'none';
          mainContent.style.display = 'flex';
          
          if (result.user) {
            userInfo.textContent = \`Connected as: \${result.user.name || result.user.id}\`;
          }
        } else if (result.status === 'qr') {
          statusElement.textContent = 'Scan QR Code';
          statusElement.className = 'status-disconnected';
          loadingSection.style.display = 'none';
          mainContent.style.display = 'none';
          qrSection.style.display = 'block';
          
          if (result.qr) {
            qrImage.innerHTML = \`<img src="\${result.qr}" alt="QR Code" />\`;
          }
        } else {
          statusElement.textContent = 'Initializing...';
          statusElement.className = 'status-disconnected';
          qrSection.style.display = 'none';
          mainContent.style.display = 'none';
          loadingSection.style.display = 'block';
        }
      } catch (error) {
        console.error('Error checking status:', error);
        statusElement.textContent = 'Connection Error';
        statusElement.className = 'status-disconnected';
      }
    }

    checkStatus();
    setInterval(checkStatus, 3000);
  </script>
</body>
</html>`

fs.writeFileSync("public/index.html", htmlContent)

app.get("/", (req, res) => res.sendFile(join(__dirname, "public", "index.html")))

app.post("/api/cookies", upload.single("cookiesFile"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session
    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    if (!req.file) {
      return res.json({ success: false, error: "No cookies file uploaded" })
    }

    console.log(`🍪 Processing cookies for session ${sessionId}`)

    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))

    validateCookies(cookiesData)

    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    const sessionJsonPath = join(cookiesDir, `${sessionId}.json`)
    fs.writeFileSync(sessionJsonPath, JSON.stringify(cookiesData, null, 2))

    cookiesStorage.set(sessionId, cookiesData)

    fs.unlinkSync(req.file.path)

    console.log(`✅ Cookies saved for session ${sessionId}`)
    console.log(`📄 Netscape file: ${sessionCookiesPath}`)

    res.json({
      success: true,
      message: `Cookies loaded: ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    })
  } catch (error) {
    console.error("❌ Error processing cookies:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!req.file) {
      return res.json({ success: false, error: "No file uploaded" })
    }

    const sock = activeSessions.get(sessionId)
    const file = req.file
    const fileBuffer = fs.readFileSync(file.path)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: file.originalname,
      mimetype: file.mimetype,
    })

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      fs.unlinkSync(file.path)
    }

    console.log(`📎 File sent: ${file.originalname}`)
    res.json({ success: true, message: "File sent successfully", filename: file.originalname })
  } catch (error) {
    console.error("❌ Error uploading file:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!url) {
      return res.json({ success: false, error: "URL is required" })
    }

    console.log(`⬇️ Download request for session ${sessionId}: ${url}`)

    const sock = activeSessions.get(sessionId)
    const userAgent = getRandomUserAgent()
    const tempFilePath = join(tempDir, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    const ytDlpCommand = [
      "yt-dlp",
      "--no-warnings",
      "--no-check-certificates",
      "--prefer-insecure",
      "--ignore-errors",
      "--no-abort-on-error",
      "--extract-flat",
      "--write-info-json",
      "--write-description",
      "--write-thumbnail",
      `--user-agent "${userAgent}"`,
      '--add-header "Accept-Language:en-US,en;q=0.9"',
      '--add-header "Accept-Encoding:gzip, deflate, br"',
      '--add-header "Accept:text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"',
      '--add-header "Cache-Control:no-cache"',
      '--add-header "Pragma:no-cache"',
      '--format "best[height<=720]/best"',
      "--merge-output-format mp4",
      "--embed-subs",
      "--write-auto-sub",
      "--sub-lang en,es",
      "--convert-subs srt",
    ]

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) {
      console.log(`🍪 Using cookies for session ${sessionId}`)

      const cookiesContent = fs.readFileSync(sessionCookiesPath, "utf8")
      console.log(`📄 Cookies file size: ${cookiesContent.length} bytes`)

      const cookieLines = cookiesContent.split("\n").filter((line) => line.trim() && !line.startsWith("#"))
      console.log(`🔢 Valid cookie lines: ${cookieLines.length}`)

      ytDlpCommand.push(`--cookies "${sessionCookiesPath}"`)
    } else {
      console.log(`⚠️ No cookies found for session ${sessionId}`)
      if (url.includes("youtube.com") || url.includes("youtu.be")) {
        return res.json({
          success: false,
          error: "YouTube cookies required. Please upload J2Team cookies first.",
        })
      }
    }

    ytDlpCommand.push(`-o "${tempFilePath}.%(ext)s"`)
    ytDlpCommand.push(`"${url}"`)

    const finalCommand = ytDlpCommand.join(" ")
    console.log(`🔧 Executing: ${finalCommand}`)

    const { stdout, stderr } = await execAsync(finalCommand, {
      timeout: 300000,
      maxBuffer: 1024 * 1024 * 10,
    })

    console.log(`📋 yt-dlp stdout:`, stdout)
    if (stderr) {
      console.log(`⚠️ yt-dlp stderr:`, stderr)
    }

    const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(path.basename(tempFilePath)))
    if (files.length === 0) {
      throw new Error("Download failed - no file created. Check if URL is valid and accessible.")
    }

    console.log(`📁 Downloaded files: ${files.join(", ")}`)

    const videoFile = files.find((f) => f.match(/\.(mp4|mkv|webm|avi|mov)$/i))
    const mainFile = videoFile || files[0]

    const downloadedFile = join(tempDir, mainFile)
    const fileStats = fs.statSync(downloadedFile)
    console.log(`📊 File size: ${(fileStats.size / 1024 / 1024).toFixed(2)} MB`)

    const fileBuffer = fs.readFileSync(downloadedFile)

    const fileExtension = path.extname(mainFile).toLowerCase()
    let messageOptions = {}

    if ([".mp4", ".mkv", ".webm", ".avi", ".mov"].includes(fileExtension)) {
      messageOptions = {
        video: fileBuffer,
        caption: `Downloaded from: ${url}`,
        mimetype: "video/mp4",
      }
    } else if ([".mp3", ".wav", ".ogg", ".m4a", ".aac"].includes(fileExtension)) {
      messageOptions = {
        audio: fileBuffer,
        mimetype: "audio/mp4",
      }
    } else if ([".jpg", ".jpeg", ".png", ".gif", ".webp"].includes(fileExtension)) {
      messageOptions = {
        image: fileBuffer,
        caption: `Downloaded from: ${url}`,
      }
    } else {
      messageOptions = {
        document: fileBuffer,
        fileName: mainFile,
        mimetype: getMimeType(mainFile),
      }
    }

    await sock.sendMessage(sock.user.id, messageOptions)

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      files.forEach((file) => {
        try {
          fs.unlinkSync(join(tempDir, file))
        } catch (err) {
          console.error(`Error deleting ${file}:`, err)
        }
      })
    }

    console.log(`✅ Downloaded and sent: ${mainFile}`)
    res.json({
      success: true,
      message: "Downloaded and sent successfully",
      filename: mainFile,
      size: `${(fileStats.size / 1024 / 1024).toFixed(2)} MB`,
    })
  } catch (error) {
    console.error("❌ Error downloading:", error)

    let errorMessage = error.message
    if (error.message.includes("Sign in to confirm")) {
      errorMessage = "YouTube requires authentication. Please upload valid J2Team cookies."
    } else if (error.message.includes("Video unavailable")) {
      errorMessage = "Video is unavailable or private."
    } else if (error.message.includes("No video formats found")) {
      errorMessage = "No downloadable video formats found."
    }

    res.json({ success: false, error: errorMessage })
  }
})

app.post("/api/send", async (req, res) => {
  try {
    const { message } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!message) {
      return res.json({ success: false, error: "Message is required" })
    }

    const sock = activeSessions.get(sessionId)
    await sock.sendMessage(sock.user.id, { text: message })

    console.log(`💬 Message sent: ${message.substring(0, 50)}...`)
    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    console.error("❌ Error sending message:", error)
    res.json({ success: false, error: error.message })
  }
})

app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    if (activeSessions.size >= CONFIG.MAX_SESSIONS && !activeSessions.has(sessionId)) {
      const position = waitingQueue.indexOf(sessionId)
      if (position === -1) {
        waitingQueue.push(sessionId)
      }
      return res.json({
        status: "waiting",
        position: waitingQueue.indexOf(sessionId) + 1,
        maxSessions: CONFIG.MAX_SESSIONS,
      })
    }

    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      if (sock.user) {
        return res.json({
          status: "connected",
          user: {
            id: sock.user.id,
            name: sock.user.name || sock.user.id,
          },
        })
      }
    }

    if (qrCodes.has(sessionId)) {
      return res.json({
        status: "qr",
        qr: qrCodes.get(sessionId),
      })
    }

    if (!activeSessions.has(sessionId)) {
      console.log(`🔄 Creating new WhatsApp session: ${sessionId}`)
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    console.error("❌ Error checking status:", error)
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
    ".webm": "video/webm",
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".m4a": "audio/mp4",
    ".flac": "audio/flac",
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
    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    console.log(`📱 Initializing WhatsApp session: ${sessionId}`)

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      defaultQueryTimeoutMs: 60000,
    })

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        console.log(`📱 QR code generated for session: ${sessionId}`)
        const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
        qrCodes.set(sessionId, qrDataURL)
      }

      if (connection === "close") {
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
        console.log(`❌ Connection closed for session ${sessionId}:`, lastDisconnect?.error)

        activeSessions.delete(sessionId)
        qrCodes.delete(sessionId)

        if (shouldReconnect) {
          console.log(`🔄 Reconnecting session ${sessionId} in 5 seconds...`)
          setTimeout(() => createWhatsAppSession(sessionId), 5000)
        } else {
          console.log(`🚫 Session ${sessionId} permanently closed (logout)`)
          try {
            fs.rmSync(sessionDir, { recursive: true, force: true })
          } catch (err) {
            console.error("Error cleaning session directory:", err)
          }
        }
      } else if (connection === "open") {
        console.log(`✅ WhatsApp connected successfully for session: ${sessionId}`)
        console.log(`👤 User: ${sock.user.name} (${sock.user.id})`)

        qrCodes.delete(sessionId)

        const queueIndex = waitingQueue.indexOf(sessionId)
        if (queueIndex !== -1) {
          waitingQueue.splice(queueIndex, 1)
        }
      }
    })

    sock.ev.on("creds.update", saveCreds)

    sock.ev.on("messages.upsert", async (m) => {
      if (m.type !== "notify") return

      for (const msg of m.messages) {
        if (msg.key.fromMe) {
          console.log(`📤 Message sent from session ${sessionId}: ${msg.message?.conversation || "Media"}`)
        }
      }
    })

    activeSessions.set(sessionId, sock)

    sessionStates.set(sessionId, {
      lastActivity: Date.now(),
    })

    console.log(`🎯 Session ${sessionId} initialized successfully`)
  } catch (error) {
    console.error(`❌ Error creating WhatsApp session ${sessionId}:`, error)

    activeSessions.delete(sessionId)
    qrCodes.delete(sessionId)

    setTimeout(() => {
      console.log(`🔄 Retrying session creation for ${sessionId}`)
      createWhatsAppSession(sessionId)
    }, 10000)
  }
}

try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(options, app)

  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 HTTPS Server running on https://${CONFIG.DOMAIN}`)
    console.log(`📱 WhatsApp YouTube Interface available`)
    console.log(`⚙️  Max sessions: ${CONFIG.MAX_SESSIONS}`)
    console.log(`🔧 Auto-delete files: ${CONFIG.AUTO_DELETE_AFTER_SEND}`)
    console.log(`🍪 Cookies directory: ${cookiesDir}`)
  })
} catch (error) {
  console.error("❌ Error starting HTTPS server:", error)
  console.log("⚠️  Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🚀 HTTP Server running on http://0.0.0.0:${CONFIG.PORT}`)
    console.log("⚠️  WARNING: Running without HTTPS")
  })
}

setInterval(
  () => {
    const now = Date.now()
    const maxInactiveTime = 24 * 60 * 60 * 1000

    for (const [sessionId, sessionState] of sessionStates) {
      if (now - sessionState.lastActivity > maxInactiveTime) {
        console.log(`🧹 Cleaning up inactive session: ${sessionId}`)

        if (activeSessions.has(sessionId)) {
          try {
            const sock = activeSessions.get(sessionId)
            sock.end()
          } catch (err) {
            console.error("Error closing socket:", err)
          }
          activeSessions.delete(sessionId)
        }

        sessionStates.delete(sessionId)
        qrCodes.delete(sessionId)

        try {
          const cookiesPath = join(cookiesDir, `${sessionId}.txt`)
          const jsonPath = join(cookiesDir, `${sessionId}.json`)
          if (fs.existsSync(cookiesPath)) fs.unlinkSync(cookiesPath)
          if (fs.existsSync(jsonPath)) fs.unlinkSync(jsonPath)
        } catch (err) {
          console.error("Error cleaning cookies:", err)
        }
      }
    }
  },
  60 * 60 * 1000,
)

process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("❌ Unhandled rejection:", err)
})

process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down gracefully...")

  for (const [sessionId, sock] of activeSessions) {
    try {
      console.log(`📱 Closing session: ${sessionId}`)
      sock.end()
    } catch (err) {
      console.error(`Error closing session ${sessionId}:`, err)
    }
  }

  process.exit(0)
})

console.log("🎉 WhatsApp YouTube Interface initialized!")
console.log("📋 Features:")
console.log("   ✅ Enhanced cookie validation")
console.log("   ✅ Improved yt-dlp parameters")
console.log("   ✅ Better error handling")
console.log("   ✅ YouTube authentication support")
console.log("   ✅ Multi-format downloads")
