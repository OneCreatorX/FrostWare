// Importación dinámica de Baileys para compatibilidad
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
import crypto from "crypto"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)

// Configuración del servidor
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

// Almacenamiento de sesiones y estados
const activeSessions = new Map() // Sesiones activas de WhatsApp
const sessionStates = new Map() // Estados de configuración por sesión
const waitingQueue = [] // Cola de espera cuando se alcanza el máximo
const mediaCache = new Map() // Cache de archivos multimedia
const cookiesStorage = new Map() // Almacenamiento de cookies por sesión
const formatCache = new Map() // Cache de formatos de video/audio
const qrCodes = new Map() // Almacenamiento de códigos QR por sesión

// User agents para rotación y evitar detección
const userAgents = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:121.0) Gecko/20100101 Firefox/121.0",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:121.0) Gecko/20100101 Firefox/121.0",
]

/**
 * Genera un ID de sesión seguro y único
 * @returns {string} ID de sesión único
 */
function generateSecureSessionId() {
  const timestamp = Date.now().toString(36)
  const randomBytes = crypto.randomBytes(32).toString("hex")
  const hash = crypto
    .createHash("sha256")
    .update(timestamp + randomBytes)
    .digest("hex")
  return `ws_${timestamp}_${hash.substring(0, 48)}_${crypto.randomBytes(16).toString("hex")}`
}

/**
 * Obtiene un user agent aleatorio para evitar detección
 * @returns {string} User agent aleatorio
 */
function getRandomUserAgent() {
  return userAgents[Math.floor(Math.random() * userAgents.length)]
}

/**
 * Convierte cookies de formato J2Team a formato Netscape para yt-dlp
 * @param {Array} cookies - Array de cookies en formato J2Team
 * @returns {string} Cookies en formato Netscape
 */
function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n"
  netscapeFormat += "# This is a generated file! Do not edit.\n\n"

  cookies.forEach((cookie) => {
    // Extraer datos de la cookie con valores por defecto
    const domain = cookie.domain || ""
    const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
    const path = cookie.path || "/"
    const secure = cookie.secure === true || cookie.secure === "true" ? "TRUE" : "FALSE"

    // Manejar fecha de expiración - convertir a entero Unix timestamp
    let expiration = cookie.expirationDate || cookie.expires || Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60

    // Si la fecha viene como decimal, convertir a entero
    if (typeof expiration === "number") {
      expiration = Math.floor(expiration)
    } else if (typeof expiration === "string") {
      expiration = Math.floor(Number.parseFloat(expiration))
    }

    const name = cookie.name || ""
    const value = cookie.value || ""

    // Agregar línea en formato Netscape
    netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
  })

  return netscapeFormat
}

// Configuración de multer para subida de archivos
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

// Middleware de Express
app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Crear directorios necesarios
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

// HTML de la interfaz (versión compacta para el ejemplo)
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
      width: 350px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      display: flex;
      flex-direction: column;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
      padding: 20px;
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
      padding: 8px;
      border-radius: 8px;
      background: rgba(255,255,255,0.1);
    }
    .cookies-status.loaded {
      background: rgba(76, 175, 80, 0.2);
      color: #4CAF50;
    }
    h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
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
        <div>
          <h3>🍪 YouTube Cookies</h3>
          <div class="upload-area" id="cookies-upload-area">
            <div>🍪</div>
            <div>Drop J2Team cookies.json here</div>
            <input type="file" id="cookies-input" class="file-input" accept=".json">
          </div>
          <div id="cookies-status" class="cookies-status">No cookies loaded</div>
        </div>
        
        <div style="margin-top: 20px;">
          <h3>📎 Send Files</h3>
          <div class="upload-area" id="upload-area">
            <div>📁</div>
            <div>Drop files here or click to select</div>
            <input type="file" id="file-input" class="file-input" multiple accept="*/*">
          </div>
          <input type="text" id="url-input" class="url-input" placeholder="Enter URL to download and send...">
          <button id="download-send-btn" class="btn">📥 Download & Send</button>
        </div>
        
        <div style="margin-top: 20px;">
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
            📱 Ready to send messages and files!
          </div>
        </div>
      </div>
    </div>
  </div>
  
  <script>
    // Generar ID de sesión único
    let sessionId = localStorage.getItem('whatsapp-session-id') || generateSecureSessionId();
    localStorage.setItem('whatsapp-session-id', sessionId);
    
    function generateSecureSessionId() {
      const timestamp = Date.now().toString(36);
      const randomBytes = Array.from(crypto.getRandomValues(new Uint8Array(32)), 
        b => b.toString(16).padStart(2, '0')).join('');
      const combined = timestamp + randomBytes;
      return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g, '').substring(0, 48)}_\${Array.from(crypto.getRandomValues(new Uint8Array(16)), b => b.toString(16).padStart(2, '0')).join('')}\`;
    }

    // Elementos del DOM
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
    const userInfo = document.getElementById("user-info");
    const cookiesUploadArea = document.getElementById("cookies-upload-area");
    const cookiesInput = document.getElementById("cookies-input");
    const cookiesStatus = document.getElementById("cookies-status");

    let hasCookies = false;

    // Mostrar información de sesión
    sessionInfoElement.textContent = \`Session: \${sessionId.substring(3, 15)}...\`;

    // Manejo de cookies
    cookiesUploadArea.addEventListener('click', () => cookiesInput.click());
    cookiesUploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      cookiesUploadArea.style.borderColor = '#4CAF50';
    });
    cookiesUploadArea.addEventListener('dragleave', () => {
      cookiesUploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
    });
    cookiesUploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      cookiesUploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
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

    // Función para manejar archivo de cookies
    async function handleCookiesFile(file) {
      try {
        const text = await file.text();
        const cookiesData = JSON.parse(text);
        
        // Verificar formato J2Team
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
            cookiesStatus.textContent = \`✅ Cookies loaded - \${cookiesData.cookies.length} cookies from \${cookiesData.url}\`;
            cookiesStatus.classList.add('loaded');
          } else {
            throw new Error(result.error);
          }
        } else {
          throw new Error('Invalid J2Team cookies format. Expected {url, cookies} structure.');
        }
      } catch (error) {
        cookiesStatus.textContent = '❌ Error: ' + error.message;
        cookiesStatus.classList.remove('loaded');
      }
    }

    // Manejo de archivos
    uploadArea.addEventListener('click', () => fileInput.click());
    uploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      uploadArea.style.borderColor = '#4CAF50';
    });
    uploadArea.addEventListener('dragleave', () => {
      uploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
    });
    uploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      uploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
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
        }
      } catch (error) {
        console.error('Error uploading file:', error);
      }
    }

    // Descargar y enviar URL
    downloadSendBtn.addEventListener('click', async () => {
      const url = urlInput.value.trim();
      if (!url) return;

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
          console.log('Downloaded and sent successfully');
        } else {
          alert('Download failed: ' + result.error);
        }
      } catch (error) {
        alert('Download failed: ' + error.message);
      } finally {
        downloadSendBtn.textContent = '📥 Download & Send';
        downloadSendBtn.disabled = false;
      }
    });

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
          console.log('Message sent successfully');
        }
      } catch (error) {
        console.error('Error sending message:', error);
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
        } else if (result.status === 'waiting') {
          statusElement.textContent = \`Waiting (Position \${result.position})\`;
          statusElement.className = 'status-waiting';
          // Mostrar interfaz de espera si es necesario
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

    // Inicializar y verificar estado cada 3 segundos
    checkStatus();
    setInterval(checkStatus, 3000);
  </script>
</body>
</html>`

// Escribir el archivo HTML
fs.writeFileSync("public/index.html", htmlContent)

// Ruta principal
app.get("/", (req, res) => res.sendFile(join(__dirname, "public", "index.html")))

/**
 * Endpoint para subir cookies de J2Team
 */
app.post("/api/cookies", upload.single("cookiesFile"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session
    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    if (!req.file) {
      return res.json({ success: false, error: "No cookies file uploaded" })
    }

    // Leer y parsear el archivo de cookies
    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))

    // Verificar formato J2Team: debe tener url y cookies array
    if (!cookiesData.url || !cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
      return res.json({
        success: false,
        error: "Invalid J2Team cookies format. Expected {url, cookies} structure.",
      })
    }

    // Convertir a formato Netscape para yt-dlp
    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    // Guardar también el JSON original para referencia
    const sessionJsonPath = join(cookiesDir, `${sessionId}.json`)
    fs.writeFileSync(sessionJsonPath, JSON.stringify(cookiesData, null, 2))

    // Almacenar en memoria para acceso rápido
    cookiesStorage.set(sessionId, cookiesData)

    // Limpiar archivo temporal
    fs.unlinkSync(req.file.path)

    console.log(
      `✅ Cookies loaded for session ${sessionId}: ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    )

    res.json({
      success: true,
      message: `Cookies loaded successfully - ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    })
  } catch (error) {
    console.error("Error processing cookies:", error)
    res.json({ success: false, error: error.message })
  }
})

/**
 * Endpoint para subir archivos
 */
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

    // Enviar archivo a WhatsApp (a mí mismo)
    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: file.originalname,
      mimetype: file.mimetype,
    })

    // Eliminar archivo temporal si está configurado
    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      fs.unlinkSync(file.path)
    }

    console.log(`📎 File sent successfully: ${file.originalname}`)
    res.json({ success: true, message: "File sent successfully", filename: file.originalname })
  } catch (error) {
    console.error("Error uploading file:", error)
    res.json({ success: false, error: error.message })
  }
})

/**
 * Endpoint para descargar y enviar URLs
 */
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

    const sock = activeSessions.get(sessionId)
    const userAgent = getRandomUserAgent()
    const tempFilePath = join(tempDir, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    // Construir comando yt-dlp
    let ytDlpCommand = `yt-dlp --no-warnings --user-agent "${userAgent}"`

    // Agregar cookies si existen para esta sesión
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) {
      ytDlpCommand += ` --cookies "${sessionCookiesPath}"`
      console.log(`🍪 Using cookies for session ${sessionId}`)
    }

    ytDlpCommand += ` -o "${tempFilePath}.%(ext)s" "${url}"`

    console.log(`⬇️ Downloading: ${url}`)
    await execAsync(ytDlpCommand)

    // Buscar archivo descargado
    const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(path.basename(tempFilePath)))
    if (files.length === 0) {
      throw new Error("Download failed - no file created")
    }

    const downloadedFile = join(tempDir, files[0])
    const fileBuffer = fs.readFileSync(downloadedFile)

    // Enviar archivo a WhatsApp
    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: files[0],
      mimetype: getMimeType(files[0]),
    })

    // Limpiar archivo temporal
    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      fs.unlinkSync(downloadedFile)
    }

    console.log(`✅ Downloaded and sent: ${files[0]}`)
    res.json({ success: true, message: "Downloaded and sent successfully", filename: files[0] })
  } catch (error) {
    console.error("Error downloading:", error)
    res.json({ success: false, error: error.message })
  }
})

/**
 * Endpoint para enviar mensajes de texto
 */
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

    // Enviar mensaje a mí mismo
    await sock.sendMessage(sock.user.id, { text: message })

    console.log(`💬 Message sent: ${message.substring(0, 50)}...`)
    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.json({ success: false, error: error.message })
  }
})

/**
 * Endpoint para verificar estado de la sesión
 */
app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    // Verificar si hay espacio para nuevas sesiones
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

    // Si la sesión está activa y conectada
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

    // Verificar si hay QR disponible
    if (qrCodes.has(sessionId)) {
      return res.json({
        status: "qr",
        qr: qrCodes.get(sessionId),
      })
    }

    // Si no existe la sesión, crearla
    if (!activeSessions.has(sessionId)) {
      console.log(`🔄 Creating new WhatsApp session: ${sessionId}`)
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    console.error("Error checking status:", error)
    res.json({ success: false, error: error.message })
  }
})

// Servir archivos multimedia
app.use("/media", express.static(mediaDir))

/**
 * Obtiene el tipo MIME basado en la extensión del archivo
 * @param {string} filename - Nombre del archivo
 * @returns {string} Tipo MIME
 */
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

/**
 * Crea una nueva sesión de WhatsApp
 * @param {string} sessionId - ID único de la sesión
 */
async function createWhatsAppSession(sessionId) {
  try {
    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    console.log(`📱 Initializing WhatsApp session: ${sessionId}`)

    // Configurar autenticación persistente
    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    // Crear socket de WhatsApp
    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      browser: Browsers.macOS("Desktop"),
      defaultQueryTimeoutMs: 60000,
    })

    // Manejar actualizaciones de conexión
    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        console.log(`📱 QR code generated for session: ${sessionId}`)
        // Convertir QR a data URL y almacenar
        const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
        qrCodes.set(sessionId, qrDataURL)
      }

      if (connection === "close") {
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
        console.log(`❌ Connection closed for session ${sessionId}:`, lastDisconnect?.error)

        // Limpiar sesión
        activeSessions.delete(sessionId)
        qrCodes.delete(sessionId)

        if (shouldReconnect) {
          console.log(`🔄 Reconnecting session ${sessionId} in 5 seconds...`)
          setTimeout(() => createWhatsAppSession(sessionId), 5000)
        } else {
          console.log(`🚫 Session ${sessionId} permanently closed (logout)`)
          // Limpiar archivos de sesión si es logout
          try {
            fs.rmSync(sessionDir, { recursive: true, force: true })
          } catch (err) {
            console.error("Error cleaning session directory:", err)
          }
        }
      } else if (connection === "open") {
        console.log(`✅ WhatsApp connected successfully for session: ${sessionId}`)
        console.log(`👤 User: ${sock.user.name} (${sock.user.id})`)

        // Limpiar QR code ya que estamos conectados
        qrCodes.delete(sessionId)

        // Remover de cola de espera si estaba
        const queueIndex = waitingQueue.indexOf(sessionId)
        if (queueIndex !== -1) {
          waitingQueue.splice(queueIndex, 1)
        }
      }
    })

    // Guardar credenciales cuando cambien
    sock.ev.on("creds.update", saveCreds)

    // Manejar mensajes (opcional, para logging)
    sock.ev.on("messages.upsert", async (m) => {
      if (m.type !== "notify") return

      for (const msg of m.messages) {
        if (msg.key.fromMe) {
          console.log(`📤 Message sent from session ${sessionId}: ${msg.message?.conversation || "Media"}`)
        }
      }
    })

    // Almacenar sesión activa
    activeSessions.set(sessionId, sock)

    // Inicializar estado de sesión
    sessionStates.set(sessionId, {
      lastActivity: Date.now(),
      messagesEnabled: CONFIG.SHOW_MESSAGES_BY_DEFAULT,
      mediaEnabled: CONFIG.DOWNLOAD_MEDIA_BY_DEFAULT,
    })

    console.log(`🎯 Session ${sessionId} initialized successfully`)
  } catch (error) {
    console.error(`❌ Error creating WhatsApp session ${sessionId}:`, error)

    // Limpiar en caso de error
    activeSessions.delete(sessionId)
    qrCodes.delete(sessionId)

    // Reintentar después de un tiempo
    setTimeout(() => {
      console.log(`🔄 Retrying session creation for ${sessionId}`)
      createWhatsAppSession(sessionId)
    }, 10000)
  }
}

// Configurar servidor HTTPS
try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(options, app)

  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 HTTPS Server running on https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
    console.log(`📱 WhatsApp Personal Interface available`)
    console.log(`⚙️  Max sessions: ${CONFIG.MAX_SESSIONS}`)
    console.log(`🔧 Auto-delete files: ${CONFIG.AUTO_DELETE_AFTER_SEND}`)
  })
} catch (error) {
  console.error("❌ Error starting HTTPS server:", error)
  console.log("⚠️  Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🚀 HTTP Server running on http://0.0.0.0:${CONFIG.PORT}`)
    console.log("⚠️  WARNING: Running without HTTPS - not recommended for production")
  })
}

// Limpieza periódica de sesiones inactivas (cada hora)
setInterval(
  () => {
    const now = Date.now()
    const maxInactiveTime = 24 * 60 * 60 * 1000 // 24 horas

    for (const [sessionId, sessionState] of sessionStates) {
      if (now - sessionState.lastActivity > maxInactiveTime) {
        console.log(`🧹 Cleaning up inactive session: ${sessionId}`)

        // Cerrar conexión si existe
        if (activeSessions.has(sessionId)) {
          try {
            const sock = activeSessions.get(sessionId)
            sock.end()
          } catch (err) {
            console.error("Error closing socket:", err)
          }
          activeSessions.delete(sessionId)
        }

        // Limpiar estados
        sessionStates.delete(sessionId)
        qrCodes.delete(sessionId)

        // Limpiar archivos de cookies
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
) // Cada hora

// Manejo de errores globales
process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("❌ Unhandled rejection:", err)
})

// Manejo de cierre graceful
process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down gracefully...")

  // Cerrar todas las sesiones activas
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

console.log("🎉 WhatsApp Advanced Session Server initialized!")
console.log("📋 Features enabled:")
console.log("   ✅ Multi-session support")
console.log("   ✅ J2Team cookies support")
console.log("   ✅ YouTube downloads with yt-dlp")
console.log("   ✅ File uploads and URL downloads")
console.log("   ✅ Auto-cleanup and session management")
console.log("   ✅ HTTPS support")
