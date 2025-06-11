const { makeWASocket, useMultiFileAuthState, Browsers, downloadMediaMessage } = await import("@whiskeysockets/baileys");

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
let qrCodeDataURL = null
let isConnected = false
let whatsappClient = null
const messageHistory = []
let state, saveCreds
let myNumber = null

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "uploads/")
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

try {
  await fs.promises.mkdir(mediaDir, { recursive: true })
  await fs.promises.mkdir(uploadsDir, { recursive: true })
  await fs.promises.mkdir("public", { recursive: true })
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
    .progress-bar {
      width: 100%;
      height: 4px;
      background: rgba(255,255,255,0.2);
      border-radius: 2px;
      margin: 10px 0;
      overflow: hidden;
    }
    .progress-fill {
      height: 100%;
      background: linear-gradient(45deg, #4CAF50, #45a049);
      width: 0%;
      transition: width 0.3s ease;
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
    @media (max-width: 768px) {
      .main-content {
        flex-direction: column;
      }
      .sidebar {
        width: 100%;
        height: auto;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>📱 Personal WhatsApp Interface</h1>
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
            <input type="text" id="url-input" class="url-input" placeholder="Enter URL to download and send...">
            <button id="download-send-btn" class="btn">📥 Download & Send</button>
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
          <p>Personal chat with myself</p>
        </div>
        <div class="messages" id="messages"></div>
      </div>
    </div>
  </div>
  
  <script>
    const statusElement = document.getElementById("status")
    const messagesList = document.getElementById("messages")
    const messageInput = document.getElementById("message-input")
    const sendMessageBtn = document.getElementById("send-message-btn")
    const qrSection = document.getElementById("qr-section")
    const loadingSection = document.getElementById("loading-section")
    const mainContent = document.getElementById("main-content")
    const qrImage = document.getElementById("qr-image")
    const uploadArea = document.getElementById("upload-area")
    const fileInput = document.getElementById("file-input")
    const urlInput = document.getElementById("url-input")
    const downloadSendBtn = document.getElementById("download-send-btn")

    let myNumber = null

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

    downloadSendBtn.addEventListener('click', async () => {
      const url = urlInput.value.trim()
      if (!url) return

      downloadSendBtn.textContent = '⏳ Downloading...'
      downloadSendBtn.disabled = true

      try {
        const response = await fetch('/api/download-send', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        })
        const result = await response.json()
        if (result.success) {
          urlInput.value = ''
          setTimeout(loadMessages, 1000)
        }
      } catch (error) {
        console.error('Error downloading file:', error)
      } finally {
        downloadSendBtn.textContent = '📥 Download & Send'
        downloadSendBtn.disabled = false
      }
    })

    sendMessageBtn.addEventListener('click', async () => {
      const message = messageInput.value.trim()
      if (!message || !myNumber) return

      try {
        const response = await fetch('/api/send', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ to: myNumber, message })
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
        const response = await fetch("/api/status")
        const data = await response.json()

        if (data.connected) {
          statusElement.textContent = "Connected"
          statusElement.className = "status-connected"
          qrSection.style.display = "none"
          loadingSection.style.display = "none"
          mainContent.style.display = "flex"
          
          if (!myNumber) {
            myNumber = data.myNumber
          }
          
          loadMessages()
        } else if (data.hasQR) {
          statusElement.textContent = "Scan QR Code"
          statusElement.className = "status-disconnected"
          loadingSection.style.display = "none"
          mainContent.style.display = "none"
          qrSection.style.display = "block"
          
          const qrResponse = await fetch("/api/qr")
          const qrData = await qrResponse.json()
          if (qrData.qr) {
            qrImage.innerHTML = \`<img src="\${qrData.qr}" alt="QR Code" />\`
          }
        } else {
          statusElement.textContent = "Generating QR..."
          statusElement.className = "status-disconnected"
          qrSection.style.display = "none"
          mainContent.style.display = "none"
          loadingSection.style.display = "block"
        }
      } catch (error) {
        console.error("Error checking status:", error)
      }
    }

    async function loadMessages() {
      try {
        const response = await fetch("/api/messages")
        const messages = await response.json()
        
        const myMessages = messages.filter(msg => 
          msg.from === myNumber || msg.to === myNumber
        )

        messagesList.innerHTML = ""
        myMessages.forEach(displayMessage)
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

let sock
// Removing redeclaration of saveCreds
// let saveCreds

async function startWhatsApp() {
  const auth = await useMultiFileAuthState("auth_info")
  state = auth.state
  saveCreds = auth.saveCreds

  sock = makeWASocket({
    auth: state,
    browser: Browsers.ubuntu("WhatsApp-Web-Interface"),
    printQRInTerminal: false,
  })

  sock.ev.on("creds.update", saveCreds)

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update

    if (qr) {
      console.log("New QR code generated")
      qrCodeDataURL = await qrcode.toDataURL(qr)
    }

    if (connection === "close") {
      const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
      console.log("Connection closed:", lastDisconnect?.error)

      if (shouldReconnect) {
        console.log("Reconnecting...")
        whatsappClient = await startWhatsApp()
      }
      isConnected = false
    } else if (connection === "open") {
      console.log("WhatsApp connected successfully!")
      isConnected = true
      qrCodeDataURL = null
      myNumber = sock.user.id.split(":")[0] + "@s.whatsapp.net"
      console.log("My number:", myNumber)
    }
  })

  sock.ev.on("messages.upsert", async ({ messages }) => {
    for (const message of messages) {
      if (message.message) {
        console.log("Message received:", message.key.id)

        const formattedMessage = {
          id: message.key.id,
          from: message.key.remoteJid,
          to: message.key.participant || message.key.remoteJid,
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

            const fileName = `${message.key.id}.${extension}`
            const filePath = join(mediaDir, fileName)

            const writeStream = createWriteStream(filePath)
            writeStream.write(buffer)
            writeStream.end()

            formattedMessage.mediaPath = `/media/${fileName}`
          } catch (error) {
            console.error("Error downloading media:", error)
          }
        }

        messageHistory.unshift(formattedMessage)
        if (messageHistory.length > 200) messageHistory.pop()
      }
    }
  })

  whatsappClient = sock
  return sock
}

async function downloadFileFromUrl(url) {
  try {
    const response = await fetch(url)
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
        filename = urlFilename
      } else {
        const ext = contentType.includes("image")
          ? ".jpg"
          : contentType.includes("video")
            ? ".mp4"
            : contentType.includes("audio")
              ? ".mp3"
              : contentType.includes("pdf")
                ? ".pdf"
                : ".bin"
        filename = `download-${Date.now()}${ext}`
      }
    }

    const buffer = await response.arrayBuffer()
    const filePath = join(uploadsDir, filename)

    await fs.promises.writeFile(filePath, Buffer.from(buffer))

    return { filename, filePath, size: buffer.byteLength }
  } catch (error) {
    console.error("Error downloading file:", error)
    throw error
  }
}

async function sendFileToMyself(filePath, filename) {
  if (!isConnected || !myNumber) {
    throw new Error("WhatsApp not connected or number not detected")
  }

  try {
    const fileBuffer = await fs.promises.readFile(filePath)
    const fileExtension = path.extname(filename).toLowerCase()

    let messageOptions = {}

    if ([".jpg", ".jpeg", ".png", ".gif", ".webp"].includes(fileExtension)) {
      messageOptions = {
        image: fileBuffer,
        caption: filename,
      }
    } else if ([".mp4", ".avi", ".mov", ".mkv"].includes(fileExtension)) {
      messageOptions = {
        video: fileBuffer,
        caption: filename,
      }
    } else if ([".mp3", ".wav", ".ogg", ".m4a"].includes(fileExtension)) {
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

    await sock.sendMessage(myNumber, messageOptions)
    console.log("File sent successfully:", filename)

    await fs.promises.unlink(filePath)

    return true
  } catch (error) {
    console.error("Error sending file:", error)
    throw error
  }
}

await startWhatsApp()

app.get("/", (req, res) => {
  res.sendFile(join(__dirname, "public", "index.html"))
})

app.use("/media", express.static(mediaDir))
app.use("/uploads", express.static(uploadsDir))

app.get("/api/status", (req, res) => {
  res.json({
    connected: isConnected,
    hasQR: !!qrCodeDataURL,
    myNumber: myNumber,
  })
})

app.get("/api/qr", (req, res) => {
  res.json({
    qr: qrCodeDataURL,
  })
})

app.get("/api/messages", (req, res) => {
  const myMessages = messageHistory.filter((msg) => msg.from === myNumber || msg.to === myNumber)
  res.json(myMessages.reverse())
})

app.post("/api/send", async (req, res) => {
  if (!isConnected || !whatsappClient) {
    return res.status(400).json({ success: false, error: "WhatsApp not connected" })
  }

  try {
    const { to, message } = req.body

    if (!to || !message) {
      return res.status(400).json({ success: false, error: "Missing parameters" })
    }

    await sock.sendMessage(to, { text: message })
    res.json({ success: true, message: "Message sent" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: "No file uploaded" })
    }

    await sendFileToMyself(req.file.path, req.file.originalname)

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
    const { url } = req.body

    if (!url) {
      return res.status(400).json({ success: false, error: "URL is required" })
    }

    const downloadResult = await downloadFileFromUrl(url)
    await sendFileToMyself(downloadResult.filePath, downloadResult.filename)

    res.json({
      success: true,
      filename: downloadResult.filename,
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
    console.log(`WhatsApp Personal Interface available at https://${CONFIG.DOMAIN}`)
  })
} catch (error) {
  console.error("Error starting HTTPS server:", error)
  console.log("Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTP Server running at http://0.0.0.0:${CONFIG.PORT}`)
  })
}

process.on("uncaughtException", (err) => {
  console.error("Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err)
})
