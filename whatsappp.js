const { makeWASocket, useMultiFileAuthState, Browsers } = await import("@whiskeysockets/baileys")
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
  MAX_SESSIONS: 100,
  SESSION_DURATION: 10 * 60 * 1000,
  COOLDOWN_DURATION: 30 * 60 * 1000,
  MAX_DATA_PER_SESSION: 1024 * 1024 * 1024,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const sessionData = new Map()
const userRegistry = new Map()
const qrCodes = new Map()
const cookiesStorage = new Map()

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const sessionId = req.headers["session-id"] || req.query.session
    const sessionDir = join(__dirname, "temp", sessionId || "default")
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

const tempDir = join(__dirname, "temp")
const cookiesDir = join(__dirname, "cookies")

try {
  fs.mkdirSync("public", { recursive: true })
  fs.mkdirSync("sessions", { recursive: true })
  fs.mkdirSync(tempDir, { recursive: true })
  fs.mkdirSync(cookiesDir, { recursive: true })
} catch (err) {}

function generateSessionId() {
  return crypto.randomBytes(32).toString("hex")
}

function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n# This is a generated file! Do not edit.\n\n"
  cookies.forEach((cookie) => {
    const domain = cookie.domain || ""
    const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
    const path = cookie.path || "/"
    const secure = cookie.secure === true || cookie.secure === "true" ? "TRUE" : "FALSE"
    let expiration = cookie.expirationDate || cookie.expires || Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
    if (typeof expiration === "number") {
      expiration = Math.floor(expiration)
    } else if (typeof expiration === "string") {
      expiration = Math.floor(Number.parseFloat(expiration))
    }
    const name = cookie.name || ""
    const value = cookie.value || ""
    netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
  })
  return netscapeFormat
}

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp Download Service</title>
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
      max-width: 800px;
      margin: 0 auto;
      padding: 20px;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      color: white;
      padding: 20px;
      border-radius: 15px;
      margin-bottom: 20px;
      text-align: center;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .status {
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 14px;
      margin-top: 10px;
      display: inline-block;
    }
    .status-connected { background: linear-gradient(45deg, #4CAF50, #45a049); }
    .status-disconnected { background: linear-gradient(45deg, #f44336, #d32f2f); }
    .status-waiting { background: linear-gradient(45deg, #ff9800, #f57c00); }
    .qr-container {
      text-align: center;
      padding: 50px;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
      color: white;
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
    .main-content {
      flex: 1;
      background: rgba(255,255,255,0.1);
      backdrop-filter: blur(10px);
      border-radius: 15px;
      padding: 30px;
      box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37);
    }
    .section {
      margin-bottom: 30px;
    }
    .section h3 {
      color: white;
      margin-bottom: 15px;
      font-size: 18px;
    }
    .upload-area {
      border: 2px dashed rgba(255,255,255,0.3);
      border-radius: 10px;
      padding: 30px;
      text-align: center;
      cursor: pointer;
      transition: all 0.3s ease;
      color: white;
      margin-bottom: 15px;
    }
    .upload-area:hover {
      border-color: rgba(255,255,255,0.6);
      background: rgba(255,255,255,0.1);
    }
    .file-input { display: none; }
    .url-input {
      width: 100%;
      padding: 15px;
      border: none;
      border-radius: 10px;
      background: rgba(255,255,255,0.2);
      color: white;
      font-size: 16px;
      margin-bottom: 15px;
    }
    .url-input::placeholder { color: rgba(255,255,255,0.7); }
    .btn {
      background: linear-gradient(45deg, #667eea, #764ba2);
      color: white;
      border: none;
      padding: 15px 25px;
      border-radius: 10px;
      cursor: pointer;
      font-size: 16px;
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
    .progress-container {
      background: rgba(255,255,255,0.1);
      border-radius: 10px;
      padding: 20px;
      margin-top: 20px;
      display: none;
    }
    .progress-bar {
      width: 100%;
      height: 8px;
      background: rgba(255,255,255,0.2);
      border-radius: 4px;
      overflow: hidden;
      margin-bottom: 10px;
    }
    .progress-fill {
      height: 100%;
      background: linear-gradient(45deg, #4CAF50, #45a049);
      width: 0%;
      transition: width 0.3s ease;
    }
    .progress-text {
      color: white;
      font-size: 14px;
      text-align: center;
    }
    .stats {
      display: flex;
      justify-content: space-between;
      color: rgba(255,255,255,0.8);
      font-size: 12px;
      margin-top: 10px;
    }
    .quality-options {
      display: flex;
      gap: 10px;
      margin-bottom: 15px;
    }
    .quality-btn {
      flex: 1;
      padding: 10px;
      background: rgba(255,255,255,0.2);
      border: none;
      border-radius: 8px;
      color: white;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    .quality-btn.active {
      background: linear-gradient(45deg, #667eea, #764ba2);
    }
    .loading-spinner {
      border: 3px solid rgba(255,255,255,0.3);
      border-radius: 50%;
      border-top: 3px solid white;
      width: 30px;
      height: 30px;
      animation: spin 1s linear infinite;
      margin: 0 auto;
    }
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
    .cooldown-notice {
      background: rgba(255, 152, 0, 0.2);
      border: 1px solid rgba(255, 152, 0, 0.5);
      border-radius: 10px;
      padding: 20px;
      color: white;
      text-align: center;
      margin: 20px 0;
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>📱 WhatsApp Download Service</h1>
      <div id="session-info">Session: Loading...</div>
      <div id="status" class="status status-disconnected">Disconnected</div>
      <div id="session-stats" class="stats" style="display: none;">
        <span>Time: <span id="time-left">10:00</span></span>
        <span>Data: <span id="data-used">0 MB</span> / 1 GB</span>
      </div>
    </header>
    
    <div id="cooldown-section" class="cooldown-notice" style="display: none;">
      <h2>⏰ Service Cooldown</h2>
      <p>You must wait <span id="cooldown-time">30:00</span> before using the service again.</p>
    </div>
    
    <div id="qr-section" class="qr-container" style="display: none;">
      <h1>📱 Scan QR Code</h1>
      <div id="qr-image"></div>
      <p>Open WhatsApp → Linked Devices → Link Device</p>
      <button onclick="location.reload()">Refresh QR</button>
    </div>
    
    <div id="loading-section" class="qr-container">
      <h1>⏳ Initializing...</h1>
      <div class="loading-spinner"></div>
      <p>Setting up your session...</p>
    </div>
    
    <div id="main-content" class="main-content" style="display: none;">
      <div class="section">
        <h3>🍪 YouTube Cookies (Optional)</h3>
        <div class="upload-area" id="cookies-upload-area">
          <div style="font-size: 24px; margin-bottom: 10px;">🍪</div>
          <div>Drop J2Team cookies.json here for YouTube downloads</div>
          <input type="file" id="cookies-input" class="file-input" accept=".json">
        </div>
        <div id="cookies-status" style="color: rgba(255,255,255,0.7); text-align: center; font-size: 12px;">No cookies loaded</div>
      </div>
      
      <div class="section">
        <h3>📥 Download & Send</h3>
        <div class="quality-options">
          <button class="quality-btn active" data-quality="480">480p</button>
          <button class="quality-btn" data-quality="720">720p</button>
          <button class="quality-btn" data-quality="audio">Audio</button>
        </div>
        <input type="text" id="url-input" class="url-input" placeholder="Paste URL here (YouTube, Instagram, TikTok, etc.)">
        <button id="download-btn" class="btn">📥 Download & Send</button>
        
        <div id="progress-container" class="progress-container">
          <div class="progress-bar">
            <div id="progress-fill" class="progress-fill"></div>
          </div>
          <div id="progress-text" class="progress-text">Preparing download...</div>
        </div>
      </div>
    </div>
  </div>
  
  <script>
    let sessionId = localStorage.getItem('ws-session-id') || generateSessionId();
    localStorage.setItem('ws-session-id', sessionId);
    
    function generateSessionId() {
      return Array.from(crypto.getRandomValues(new Uint8Array(32)), 
        b => b.toString(16).padStart(2, '0')).join('');
    }

    const elements = {
      status: document.getElementById("status"),
      sessionInfo: document.getElementById("session-info"),
      sessionStats: document.getElementById("session-stats"),
      timeLeft: document.getElementById("time-left"),
      dataUsed: document.getElementById("data-used"),
      cooldownSection: document.getElementById("cooldown-section"),
      cooldownTime: document.getElementById("cooldown-time"),
      qrSection: document.getElementById("qr-section"),
      loadingSection: document.getElementById("loading-section"),
      mainContent: document.getElementById("main-content"),
      qrImage: document.getElementById("qr-image"),
      cookiesUploadArea: document.getElementById("cookies-upload-area"),
      cookiesInput: document.getElementById("cookies-input"),
      cookiesStatus: document.getElementById("cookies-status"),
      urlInput: document.getElementById("url-input"),
      downloadBtn: document.getElementById("download-btn"),
      progressContainer: document.getElementById("progress-container"),
      progressFill: document.getElementById("progress-fill"),
      progressText: document.getElementById("progress-text")
    };

    let selectedQuality = '480';
    let sessionTimer = null;
    let cooldownTimer = null;

    elements.sessionInfo.textContent = \`Session: \${sessionId.substring(0, 8)}...\`;

    document.querySelectorAll('.quality-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.quality-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        selectedQuality = btn.dataset.quality;
      });
    });

    elements.cookiesUploadArea.addEventListener('click', () => elements.cookiesInput.click());
    elements.cookiesUploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      elements.cookiesUploadArea.style.borderColor = '#4CAF50';
    });
    elements.cookiesUploadArea.addEventListener('dragleave', () => {
      elements.cookiesUploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
    });
    elements.cookiesUploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      elements.cookiesUploadArea.style.borderColor = 'rgba(255,255,255,0.3)';
      const files = e.dataTransfer.files;
      if (files.length > 0 && files[0].name.endsWith('.json')) {
        handleCookiesFile(files[0]);
      }
    });

    elements.cookiesInput.addEventListener('change', (e) => {
      if (e.target.files.length > 0) {
        handleCookiesFile(e.target.files[0]);
      }
    });

    async function handleCookiesFile(file) {
      try {
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
            elements.cookiesStatus.textContent = \`✅ \${cookiesData.cookies.length} cookies loaded\`;
            elements.cookiesStatus.style.color = '#4CAF50';
          } else {
            throw new Error(result.error);
          }
        } else {
          throw new Error('Invalid J2Team cookies format');
        }
      } catch (error) {
        elements.cookiesStatus.textContent = '❌ ' + error.message;
        elements.cookiesStatus.style.color = '#f44336';
      }
    }

    elements.downloadBtn.addEventListener('click', async () => {
      const url = elements.urlInput.value.trim();
      if (!url) return;

      elements.downloadBtn.disabled = true;
      elements.downloadBtn.textContent = '⏳ Processing...';
      elements.progressContainer.style.display = 'block';
      elements.progressFill.style.width = '0%';
      elements.progressText.textContent = 'Starting download...';

      try {
        const response = await fetch(\`/api/download?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url, quality: selectedQuality })
        });

        if (!response.ok) throw new Error('Download failed');

        const reader = response.body.getReader();
        const decoder = new TextDecoder();
        let buffer = '';

        while (true) {
          const { done, value } = await reader.read();
          if (done) break;

          buffer += decoder.decode(value, { stream: true });
          const lines = buffer.split('\\n');
          buffer = lines.pop();

          for (const line of lines) {
            if (line.trim()) {
              try {
                const data = JSON.parse(line);
                if (data.progress) {
                  elements.progressFill.style.width = data.progress + '%';
                  elements.progressText.textContent = data.status || 'Processing...';
                }
                if (data.success) {
                  elements.progressText.textContent = '✅ Sent successfully!';
                  elements.urlInput.value = '';
                  setTimeout(() => {
                    elements.progressContainer.style.display = 'none';
                  }, 2000);
                }
                if (data.error) {
                  throw new Error(data.error);
                }
              } catch (e) {}
            }
          }
        }
      } catch (error) {
        elements.progressText.textContent = '❌ ' + error.message;
        elements.progressFill.style.width = '0%';
      } finally {
        elements.downloadBtn.disabled = false;
        elements.downloadBtn.textContent = '📥 Download & Send';
      }
    });

    elements.urlInput.addEventListener('keypress', (e) => {
      if (e.key === 'Enter') {
        elements.downloadBtn.click();
      }
    });

    function startSessionTimer(duration) {
      if (sessionTimer) clearInterval(sessionTimer);
      
      let timeLeft = duration;
      sessionTimer = setInterval(() => {
        timeLeft -= 1000;
        if (timeLeft <= 0) {
          clearInterval(sessionTimer);
          location.reload();
          return;
        }
        
        const minutes = Math.floor(timeLeft / 60000);
        const seconds = Math.floor((timeLeft % 60000) / 1000);
        elements.timeLeft.textContent = \`\${minutes}:\${seconds.toString().padStart(2, '0')}\`;
      }, 1000);
    }

    function startCooldownTimer(duration) {
      if (cooldownTimer) clearInterval(cooldownTimer);
      
      let timeLeft = duration;
      cooldownTimer = setInterval(() => {
        timeLeft -= 1000;
        if (timeLeft <= 0) {
          clearInterval(cooldownTimer);
          location.reload();
          return;
        }
        
        const minutes = Math.floor(timeLeft / 60000);
        const seconds = Math.floor((timeLeft % 60000) / 1000);
        elements.cooldownTime.textContent = \`\${minutes}:\${seconds.toString().padStart(2, '0')}\`;
      }, 1000);
    }

    async function checkStatus() {
      try {
        const response = await fetch(\`/api/status?session=\${sessionId}\`);
        const result = await response.json();

        if (result.status === 'cooldown') {
          elements.status.textContent = 'Cooldown Active';
          elements.status.className = 'status status-waiting';
          elements.cooldownSection.style.display = 'block';
          elements.qrSection.style.display = 'none';
          elements.loadingSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          startCooldownTimer(result.cooldownTime);
        } else if (result.status === 'connected') {
          elements.status.textContent = 'Connected';
          elements.status.className = 'status status-connected';
          elements.cooldownSection.style.display = 'none';
          elements.qrSection.style.display = 'none';
          elements.loadingSection.style.display = 'none';
          elements.mainContent.style.display = 'block';
          elements.sessionStats.style.display = 'flex';
          
          if (result.sessionTime) {
            startSessionTimer(result.sessionTime);
          }
          
          if (result.dataUsed !== undefined) {
            const dataUsedMB = Math.round(result.dataUsed / (1024 * 1024));
            elements.dataUsed.textContent = \`\${dataUsedMB} MB\`;
          }
        } else if (result.status === 'qr') {
          elements.status.textContent = 'Scan QR Code';
          elements.status.className = 'status status-disconnected';
          elements.cooldownSection.style.display = 'none';
          elements.loadingSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          elements.qrSection.style.display = 'block';
          
          if (result.qr) {
            elements.qrImage.innerHTML = \`<img src="\${result.qr}" alt="QR Code" />\`;
          }
        } else {
          elements.status.textContent = 'Initializing...';
          elements.status.className = 'status status-disconnected';
          elements.cooldownSection.style.display = 'none';
          elements.qrSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          elements.loadingSection.style.display = 'block';
        }
      } catch (error) {
        elements.status.textContent = 'Connection Error';
        elements.status.className = 'status status-disconnected';
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

    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))

    if (!cookiesData.url || !cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
      return res.json({ success: false, error: "Invalid J2Team cookies format" })
    }

    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    cookiesStorage.set(sessionId, cookiesData)
    fs.unlinkSync(req.file.path)

    res.json({ success: true, message: "Cookies loaded successfully" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download", async (req, res) => {
  const { url, quality } = req.body
  const sessionId = req.headers["session-id"] || req.query.session

  if (!sessionId || !activeSessions.has(sessionId)) {
    return res.json({ success: false, error: "Invalid session" })
  }

  const session = sessionData.get(sessionId)
  if (!session) {
    return res.json({ success: false, error: "Session not found" })
  }

  if (session.dataUsed >= CONFIG.MAX_DATA_PER_SESSION) {
    return res.json({ success: false, error: "Data limit exceeded" })
  }

  if (!url) {
    return res.json({ success: false, error: "URL is required" })
  }

  res.writeHead(200, {
    "Content-Type": "text/plain",
    "Transfer-Encoding": "chunked",
  })

  try {
    const sock = activeSessions.get(sessionId)
    const tempFilePath = join(tempDir, sessionId, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    res.write(JSON.stringify({ progress: 10, status: "Preparing download..." }) + "\n")

    let ytDlpCommand = `yt-dlp --no-warnings --newline`

    if (quality === "audio") {
      ytDlpCommand += ` -f "bestaudio[ext=m4a]/bestaudio"`
    } else if (quality === "480") {
      ytDlpCommand += ` -f "best[height<=480]/best"`
    } else if (quality === "720") {
      ytDlpCommand += ` -f "best[height<=720]/best"`
    }

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) {
      ytDlpCommand += ` --cookies "${sessionCookiesPath}"`
    }

    ytDlpCommand += ` -o "${tempFilePath}.%(ext)s" "${url}"`

    res.write(JSON.stringify({ progress: 30, status: "Starting download..." }) + "\n")

    const downloadProcess = exec(ytDlpCommand)
    let progressValue = 30

    downloadProcess.stdout.on("data", (data) => {
      const lines = data.toString().split("\n")
      for (const line of lines) {
        if (line.includes("[download]") && line.includes("%")) {
          const match = line.match(/(\d+\.?\d*)%/)
          if (match) {
            progressValue = Math.min(80, 30 + Number.parseFloat(match[1]) * 0.5)
            res.write(JSON.stringify({ progress: progressValue, status: "Downloading..." }) + "\n")
          }
        }
      }
    })

    downloadProcess.on("close", async (code) => {
      try {
        if (code !== 0) {
          throw new Error("Download failed")
        }

        res.write(JSON.stringify({ progress: 85, status: "Processing file..." }) + "\n")

        const files = fs.readdirSync(join(tempDir, sessionId)).filter((f) => f.startsWith(path.basename(tempFilePath)))
        if (files.length === 0) {
          throw new Error("No file downloaded")
        }

        const downloadedFile = join(tempDir, sessionId, files[0])
        const fileStats = fs.statSync(downloadedFile)
        const fileSize = fileStats.size

        if (session.dataUsed + fileSize > CONFIG.MAX_DATA_PER_SESSION) {
          fs.unlinkSync(downloadedFile)
          throw new Error("File too large - would exceed data limit")
        }

        res.write(JSON.stringify({ progress: 90, status: "Sending to WhatsApp..." }) + "\n")

        const fileBuffer = fs.readFileSync(downloadedFile)
        const fileExtension = path.extname(files[0]).toLowerCase()

        let messageOptions = {}
        if ([".jpg", ".jpeg", ".png", ".gif", ".webp"].includes(fileExtension)) {
          messageOptions = { image: fileBuffer, caption: files[0] }
        } else if ([".mp4", ".avi", ".mov", ".mkv", ".webm"].includes(fileExtension)) {
          messageOptions = { video: fileBuffer, caption: files[0] }
        } else if ([".mp3", ".wav", ".ogg", ".m4a", ".flac"].includes(fileExtension)) {
          messageOptions = { audio: fileBuffer, mimetype: "audio/mp4" }
        } else {
          messageOptions = { document: fileBuffer, mimetype: "application/octet-stream", fileName: files[0] }
        }

        await sock.sendMessage(sock.user.id, messageOptions)

        session.dataUsed += fileSize
        sessionData.set(sessionId, session)

        fs.unlinkSync(downloadedFile)

        res.write(JSON.stringify({ progress: 100, status: "Sent successfully!", success: true }) + "\n")
        res.end()
      } catch (error) {
        res.write(JSON.stringify({ error: error.message }) + "\n")
        res.end()
      }
    })

    downloadProcess.on("error", (error) => {
      res.write(JSON.stringify({ error: error.message }) + "\n")
      res.end()
    })
  } catch (error) {
    res.write(JSON.stringify({ error: error.message }) + "\n")
    res.end()
  }
})

app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    const userPhone = getUserPhoneFromSession(sessionId)
    if (userPhone && userRegistry.has(userPhone)) {
      const userRecord = userRegistry.get(userPhone)
      const now = Date.now()

      if (now - userRecord.lastUsed < CONFIG.COOLDOWN_DURATION) {
        const cooldownTime = CONFIG.COOLDOWN_DURATION - (now - userRecord.lastUsed)
        return res.json({
          status: "cooldown",
          cooldownTime: cooldownTime,
        })
      }
    }

    if (activeSessions.size >= CONFIG.MAX_SESSIONS && !activeSessions.has(sessionId)) {
      return res.json({ status: "waiting", message: "Server at capacity" })
    }

    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      const session = sessionData.get(sessionId)

      if (sock.user && session) {
        const timeLeft = CONFIG.SESSION_DURATION - (Date.now() - session.startTime)
        if (timeLeft <= 0) {
          cleanupSession(sessionId)
          return res.json({ status: "expired" })
        }

        return res.json({
          status: "connected",
          user: { id: sock.user.id, name: sock.user.name || sock.user.id },
          sessionTime: timeLeft,
          dataUsed: session.dataUsed,
        })
      }
    }

    if (qrCodes.has(sessionId)) {
      return res.json({ status: "qr", qr: qrCodes.get(sessionId) })
    }

    if (!activeSessions.has(sessionId)) {
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

function getUserPhoneFromSession(sessionId) {
  const session = sessionData.get(sessionId)
  return session ? session.userPhone : null
}

function cleanupSession(sessionId) {
  try {
    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      const session = sessionData.get(sessionId)

      if (session && session.userPhone) {
        userRegistry.set(session.userPhone, {
          lastUsed: Date.now(),
          sessionId: sessionId,
        })
      }

      try {
        sock.end()
      } catch (err) {}
      activeSessions.delete(sessionId)
    }

    sessionData.delete(sessionId)
    qrCodes.delete(sessionId)
    cookiesStorage.delete(sessionId)

    const sessionDir = join(tempDir, sessionId)
    if (fs.existsSync(sessionDir)) {
      fs.rmSync(sessionDir, { recursive: true, force: true })
    }

    const sessionAuthDir = join(__dirname, "sessions", sessionId)
    if (fs.existsSync(sessionAuthDir)) {
      fs.rmSync(sessionAuthDir, { recursive: true, force: true })
    }

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) {
      fs.unlinkSync(sessionCookiesPath)
    }
  } catch (error) {}
}

async function createWhatsAppSession(sessionId) {
  try {
    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    const tempSessionDir = join(tempDir, sessionId)
    fs.mkdirSync(tempSessionDir, { recursive: true })

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      printQRInTerminal: false,
      browser: Browsers.macOS("Desktop"),
      defaultQueryTimeoutMs: 60000,
    })

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
        qrCodes.set(sessionId, qrDataURL)
      }

      if (connection === "close") {
        const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
        cleanupSession(sessionId)
        if (shouldReconnect) {
          setTimeout(() => createWhatsAppSession(sessionId), 5000)
        }
      } else if (connection === "open") {
        qrCodes.delete(sessionId)

        const userPhone = sock.user.id.split(":")[0]

        sessionData.set(sessionId, {
          startTime: Date.now(),
          dataUsed: 0,
          userPhone: userPhone,
        })

        setTimeout(() => {
          cleanupSession(sessionId)
        }, CONFIG.SESSION_DURATION)
      }
    })

    sock.ev.on("creds.update", saveCreds)
    activeSessions.set(sessionId, sock)
  } catch (error) {
    cleanupSession(sessionId)
    setTimeout(() => createWhatsAppSession(sessionId), 10000)
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
    console.log(`Server running on https://${CONFIG.DOMAIN}`)
  })
} catch (error) {
  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTP Server running on port ${CONFIG.PORT}`)
  })
}

setInterval(() => {
  const now = Date.now()
  for (const [sessionId, session] of sessionData) {
    if (now - session.startTime > CONFIG.SESSION_DURATION) {
      cleanupSession(sessionId)
    }
  }
}, 60000)

setInterval(() => {
  const now = Date.now()
  for (const [userPhone, record] of userRegistry) {
    if (now - record.lastUsed > CONFIG.COOLDOWN_DURATION * 2) {
      userRegistry.delete(userPhone)
    }
  }
}, 300000)

process.on("uncaughtException", (err) => {})
process.on("unhandledRejection", (err) => {})
process.on("SIGINT", () => {
  for (const [sessionId] of activeSessions) {
    cleanupSession(sessionId)
  }
  process.exit(0)
})
