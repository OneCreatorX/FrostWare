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
import { execSync } from "child_process"

const CONFIG = {
  PORT: 443,
  DOMAIN: "system.heatherx.site",
  SSL_KEY: `/etc/letsencrypt/live/system.heatherx.site/privkey.pem`,
  SSL_CERT: `/etc/letsencrypt/live/system.heatherx.site/cert.pem`,
  SSL_CA: `/etc/letsencrypt/live/system.heatherx.site/chain.pem`,
  MAX_SESSIONS: 10,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const qrCodes = new Map()
const cookiesStorage = new Map()

app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

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

const tempDir = join(__dirname, "temp")
const cookiesDir = join(__dirname, "cookies")
const downloadsDir = join(__dirname, "downloads")

try {
  fs.mkdirSync("public", { recursive: true })
  fs.mkdirSync("sessions", { recursive: true })
  fs.mkdirSync(tempDir, { recursive: true })
  fs.mkdirSync(cookiesDir, { recursive: true })
  fs.mkdirSync(downloadsDir, { recursive: true })
} catch (err) {
  console.error("Error creating directories:", err)
}

function generateSecureSessionId() {
  const timestamp = Date.now().toString(36)
  const randomBytes = crypto.randomBytes(32).toString("hex")
  const hash = crypto
    .createHash("sha256")
    .update(timestamp + randomBytes)
    .digest("hex")
  return `ws_${timestamp}_${hash.substring(0, 48)}_${crypto.randomBytes(16).toString("hex")}`
}

function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n# This is a generated file! Do not edit.\n\n"
  let validCookies = 0

  cookies.forEach((cookie) => {
    try {
      const domain = cookie.domain || cookie.Domain || ""
      if (!domain) return

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
      }

      const name = cookie.name || cookie.Name || ""
      const value = cookie.value || cookie.Value || ""

      if (!name) return

      netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
      validCookies++
    } catch (error) {
      console.error(`Error processing cookie:`, error)
    }
  })

  console.log(`✅ Converted ${validCookies} cookies successfully`)
  return netscapeFormat
}

function extractVideoId(url) {
  const regex = /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/
  const match = url.match(regex)
  return match ? match[1] : url.length === 11 ? url : null
}

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp YouTube Lite</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; }
    body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; }
    .container { max-width: 800px; margin: 0 auto; padding: 20px; }
    .card { background: rgba(255,255,255,0.1); backdrop-filter: blur(10px); border-radius: 15px; padding: 20px; margin-bottom: 20px; box-shadow: 0 8px 32px rgba(31, 38, 135, 0.37); }
    .header { text-align: center; color: white; margin-bottom: 20px; }
    .status-connected { background: linear-gradient(45deg, #4CAF50, #45a049); padding: 8px 16px; border-radius: 20px; color: white; display: inline-block; }
    .status-disconnected { background: linear-gradient(45deg, #f44336, #d32f2f); padding: 8px 16px; border-radius: 20px; color: white; display: inline-block; }
    .qr-container { text-align: center; padding: 30px; }
    .qr-container img { max-width: 250px; border-radius: 10px; margin: 15px 0; }
    .loading-spinner { border: 3px solid rgba(255,255,255,0.3); border-radius: 50%; border-top: 3px solid white; width: 30px; height: 30px; animation: spin 1s linear infinite; margin: 15px auto; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .upload-area { border: 2px dashed rgba(255,255,255,0.3); border-radius: 10px; padding: 20px; text-align: center; cursor: pointer; transition: all 0.3s ease; color: white; margin-bottom: 15px; }
    .upload-area:hover { border-color: rgba(255,255,255,0.6); background: rgba(255,255,255,0.1); }
    .upload-area.dragover { border-color: #4CAF50; background: rgba(76, 175, 80, 0.1); }
    .file-input { display: none; }
    .input { width: 100%; padding: 12px; border: none; border-radius: 8px; background: rgba(255,255,255,0.2); color: white; margin-bottom: 10px; }
    .input::placeholder { color: rgba(255,255,255,0.7); }
    .btn { background: linear-gradient(45deg, #667eea, #764ba2); color: white; border: none; padding: 12px 20px; border-radius: 8px; cursor: pointer; font-size: 14px; transition: all 0.3s ease; width: 100%; margin-bottom: 10px; }
    .btn:hover { transform: translateY(-2px); box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4); }
    .btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    .btn-danger { background: linear-gradient(45deg, #f44336, #d32f2f); }
    .cookies-status { font-size: 12px; color: rgba(255,255,255,0.8); text-align: center; margin-top: 10px; padding: 10px; border-radius: 8px; background: rgba(255,255,255,0.1); }
    .cookies-status.loaded { background: rgba(76, 175, 80, 0.2); color: #4CAF50; }
    .cookies-status.error { background: rgba(244, 67, 54, 0.2); color: #f44336; }
    .video-info { background: rgba(255,255,255,0.1); padding: 15px; border-radius: 10px; margin: 15px 0; color: white; }
    .download-options { display: flex; gap: 10px; margin-top: 15px; }
    .download-options .btn { flex: 1; }
    h2, h3 { color: white; margin-bottom: 15px; }
    .session-info { font-size: 12px; color: rgba(255,255,255,0.8); margin-bottom: 10px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📱 WhatsApp YouTube Lite</h1>
      <div class="session-info" id="session-info">Session: Loading...</div>
      <div id="status" class="status-disconnected">Disconnected</div>
    </div>
    
    <div id="qr-section" class="card" style="display: none;">
      <div class="qr-container">
        <h2>📱 Scan with WhatsApp</h2>
        <div id="qr-image"></div>
        <p style="color: white;">Open WhatsApp → Linked Devices → Link Device</p>
        <button class="btn" onclick="location.reload()">Refresh QR</button>
      </div>
    </div>
    
    <div id="loading-section" class="card">
      <div class="qr-container">
        <h2>⏳ Initializing...</h2>
        <div class="loading-spinner"></div>
        <p style="color: white;">Please wait while we set up your interface</p>
      </div>
    </div>
    
    <div id="main-content" style="display: none;">
      <div class="card">
        <h3>🍪 YouTube Cookies</h3>
        <div class="upload-area" id="cookies-upload-area">
          <div style="font-size: 24px; margin-bottom: 10px;">🍪</div>
          <div>Drop J2Team cookies.json here</div>
          <input type="file" id="cookies-input" class="file-input" accept=".json">
        </div>
        <div id="cookies-status" class="cookies-status">❌ No cookies loaded</div>
      </div>
      
      <div class="card">
        <h3>🎬 YouTube Download & Send</h3>
        <input type="text" id="url-input" class="input" placeholder="Paste YouTube URL or Video ID...">
        <button id="get-info-btn" class="btn">📋 Get Video Info</button>
        <div id="video-info" style="display: none;"></div>
      </div>
      
      <div class="card">
        <h3>💬 Send Message</h3>
        <textarea id="message-input" class="input" placeholder="Type your message..." style="height: 80px; resize: none;"></textarea>
        <button id="send-message-btn" class="btn">📤 Send Message</button>
      </div>
      
      <div class="card">
        <h3>⚙️ Session Control</h3>
        <button id="disconnect-btn" class="btn btn-danger">🚪 Disconnect & Free Session</button>
        <p style="color: rgba(255,255,255,0.7); font-size: 12px; margin-top: 10px;">
          Disconnect to allow others to use this service (Max: 10 sessions)
        </p>
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

    const elements = {
      status: document.getElementById("status"),
      sessionInfo: document.getElementById("session-info"),
      qrSection: document.getElementById("qr-section"),
      loadingSection: document.getElementById("loading-section"),
      mainContent: document.getElementById("main-content"),
      qrImage: document.getElementById("qr-image"),
      cookiesUploadArea: document.getElementById("cookies-upload-area"),
      cookiesInput: document.getElementById("cookies-input"),
      cookiesStatus: document.getElementById("cookies-status"),
      urlInput: document.getElementById("url-input"),
      getInfoBtn: document.getElementById("get-info-btn"),
      videoInfo: document.getElementById("video-info"),
      messageInput: document.getElementById("message-input"),
      sendMessageBtn: document.getElementById("send-message-btn"),
      disconnectBtn: document.getElementById("disconnect-btn")
    };

    let hasCookies = false;

    elements.sessionInfo.textContent = \`Session: \${sessionId.substring(3, 15)}...\`;

    elements.cookiesUploadArea.addEventListener('click', () => elements.cookiesInput.click());
    elements.cookiesUploadArea.addEventListener('dragover', (e) => {
      e.preventDefault();
      elements.cookiesUploadArea.classList.add('dragover');
    });
    elements.cookiesUploadArea.addEventListener('dragleave', () => {
      elements.cookiesUploadArea.classList.remove('dragover');
    });
    elements.cookiesUploadArea.addEventListener('drop', (e) => {
      e.preventDefault();
      elements.cookiesUploadArea.classList.remove('dragover');
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
        elements.cookiesStatus.textContent = '⏳ Processing cookies...';
        elements.cookiesStatus.className = 'cookies-status';
        
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
            elements.cookiesStatus.textContent = \`✅ \${result.message}\`;
            elements.cookiesStatus.classList.add('loaded');
          } else {
            throw new Error(result.error);
          }
        } else {
          throw new Error('Invalid J2Team cookies format');
        }
      } catch (error) {
        elements.cookiesStatus.textContent = '❌ Error: ' + error.message;
        elements.cookiesStatus.classList.add('error');
        hasCookies = false;
      }
    }

    elements.getInfoBtn.addEventListener('click', async () => {
      const url = elements.urlInput.value.trim();
      if (!url) return;

      if (!hasCookies) {
        alert('⚠️ Please upload YouTube cookies first!');
        return;
      }

      elements.getInfoBtn.textContent = '⏳ Getting info...';
      elements.getInfoBtn.disabled = true;

      try {
        const response = await fetch(\`/api/video-info?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        });
        
        const result = await response.json();
        if (result.success) {
          displayVideoInfo(result);
        } else {
          alert('❌ Error: ' + result.error);
        }
      } catch (error) {
        alert('❌ Error: ' + error.message);
      } finally {
        elements.getInfoBtn.textContent = '📋 Get Video Info';
        elements.getInfoBtn.disabled = false;
      }
    });

    function displayVideoInfo(info) {
      elements.videoInfo.innerHTML = \`
        <div class="video-info">
          <h4>\${info.title}</h4>
          <p>Duration: \${info.duration} | Views: \${info.views}</p>
          <div class="download-options">
            <button class="btn" onclick="downloadAndSend('video480', '\${info.videoId}')">📹 480p Video</button>
            <button class="btn" onclick="downloadAndSend('video720', '\${info.videoId}')">🎬 720p Video</button>
            <button class="btn" onclick="downloadAndSend('audio', '\${info.videoId}')">🎵 MP3 Audio</button>
          </div>
        </div>
      \`;
      elements.videoInfo.style.display = 'block';
    }

    window.downloadAndSend = async function(type, videoId) {
      try {
        const response = await fetch(\`/api/download-send?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ type, videoId })
        });
        
        const result = await response.json();
        if (result.success) {
          alert('✅ Downloaded and sent successfully!');
          elements.videoInfo.style.display = 'none';
          elements.urlInput.value = '';
        } else {
          alert('❌ Error: ' + result.error);
        }
      } catch (error) {
        alert('❌ Error: ' + error.message);
      }
    };

    elements.sendMessageBtn.addEventListener('click', async () => {
      const message = elements.messageInput.value.trim();
      if (!message) return;

      try {
        const response = await fetch(\`/api/send?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ message })
        });
        
        const result = await response.json();
        if (result.success) {
          elements.messageInput.value = '';
          alert('✅ Message sent!');
        } else {
          alert('❌ Error: ' + result.error);
        }
      } catch (error) {
        alert('❌ Error: ' + error.message);
      }
    });

    elements.disconnectBtn.addEventListener('click', async () => {
      if (confirm('Are you sure you want to disconnect? This will free your session for others to use.')) {
        try {
          const response = await fetch(\`/api/disconnect?session=\${sessionId}\`, {
            method: 'POST'
          });
          
          const result = await response.json();
          if (result.success) {
            localStorage.removeItem('whatsapp-session-id');
            alert('✅ Disconnected successfully! Refreshing page...');
            location.reload();
          } else {
            alert('❌ Error: ' + result.error);
          }
        } catch (error) {
          alert('❌ Error: ' + error.message);
        }
      }
    });

    async function checkStatus() {
      try {
        const response = await fetch(\`/api/status?session=\${sessionId}\`);
        const result = await response.json();

        if (result.status === 'connected') {
          elements.status.textContent = 'Connected';
          elements.status.className = 'status-connected';
          elements.qrSection.style.display = 'none';
          elements.loadingSection.style.display = 'none';
          elements.mainContent.style.display = 'block';
        } else if (result.status === 'qr') {
          elements.status.textContent = 'Scan QR Code';
          elements.status.className = 'status-disconnected';
          elements.loadingSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          elements.qrSection.style.display = 'block';
          
          if (result.qr) {
            elements.qrImage.innerHTML = \`<img src="\${result.qr}" alt="QR Code" />\`;
          }
        } else if (result.status === 'waiting') {
          elements.status.textContent = \`Waiting (Position: \${result.position})\`;
          elements.status.className = 'status-disconnected';
          elements.qrSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          elements.loadingSection.style.display = 'block';
          elements.loadingSection.querySelector('h2').textContent = \`⏳ Waiting in queue (Position: \${result.position})\`;
        } else {
          elements.status.textContent = 'Initializing...';
          elements.status.className = 'status-disconnected';
          elements.qrSection.style.display = 'none';
          elements.mainContent.style.display = 'none';
          elements.loadingSection.style.display = 'block';
        }
      } catch (error) {
        console.error('Error checking status:', error);
        elements.status.textContent = 'Connection Error';
        elements.status.className = 'status-disconnected';
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

    if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
      throw new Error("Invalid cookies format")
    }

    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    cookiesStorage.set(sessionId, cookiesData)
    fs.unlinkSync(req.file.path)

    res.json({
      success: true,
      message: `Cookies loaded: ${cookiesData.cookies.length} cookies`,
    })
  } catch (error) {
    console.error("Error processing cookies:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/video-info", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    if (!url) {
      return res.json({ success: false, error: "URL required" })
    }

    const videoId = extractVideoId(url)
    if (!videoId) {
      return res.json({ success: false, error: "Invalid YouTube URL or ID" })
    }

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (!fs.existsSync(sessionCookiesPath)) {
      return res.json({ success: false, error: "No cookies found for session" })
    }

    const videoUrl = `https://www.youtube.com/watch?v=${videoId}`
    const cmd = `yt-dlp --no-warnings --cookies "${sessionCookiesPath}" --print "%(title)s" --print "%(duration_string)s" --print "%(view_count)s" --print "%(upload_date)s" "${videoUrl}"`

    const result = execSync(cmd, { encoding: "utf8", timeout: 30000 })
    const lines = result.trim().split("\n")

    const info = {
      success: true,
      videoId: videoId,
      title: lines[0] || "Title not available",
      duration: lines[1] || "N/A",
      views: lines[2] || "N/A",
      uploadDate: lines[3] || "N/A",
    }

    res.json(info)
  } catch (error) {
    console.error("Error getting video info:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download-send", async (req, res) => {
  try {
    const { type, videoId } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!type || !videoId) {
      return res.json({ success: false, error: "Type and videoId required" })
    }

    const sock = activeSessions.get(sessionId)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)

    if (!fs.existsSync(sessionCookiesPath)) {
      return res.json({ success: false, error: "No cookies found" })
    }

    const url = `https://www.youtube.com/watch?v=${videoId}`
    let cmd, outputTemplate, mimetype

    if (type === "video480") {
      const format = "best[height<=480]/worst"
      outputTemplate = `${downloadsDir}/%(title)s_480p.%(ext)s`
      cmd = `yt-dlp --no-warnings --cookies "${sessionCookiesPath}" --format "${format}" -o "${outputTemplate}" "${url}"`
      mimetype = "video/mp4"
    } else if (type === "video720") {
      const format = "best[height<=720]/best"
      outputTemplate = `${downloadsDir}/%(title)s_720p.%(ext)s`
      cmd = `yt-dlp --no-warnings --cookies "${sessionCookiesPath}" --format "${format}" -o "${outputTemplate}" "${url}"`
      mimetype = "video/mp4"
    } else if (type === "audio") {
      outputTemplate = `${downloadsDir}/%(title)s.mp3`
      cmd = `yt-dlp --no-warnings --cookies "${sessionCookiesPath}" --extract-audio --audio-format mp3 -o "${outputTemplate}" "${url}"`
      mimetype = "audio/mpeg"
    } else {
      return res.json({ success: false, error: "Invalid download type" })
    }

    execSync(cmd, { encoding: "utf8", timeout: 300000 })

    const filenameCmd = cmd.replace(/-o "[^"]*"/, '--get-filename -o "' + outputTemplate + '"')
    const filename = execSync(filenameCmd, { encoding: "utf8" }).trim()

    if (!fs.existsSync(filename)) {
      return res.json({ success: false, error: "File not found after download" })
    }

    const fileBuffer = fs.readFileSync(filename)
    const basename = path.basename(filename)

    let messageOptions = {}
    if (type.startsWith("video")) {
      messageOptions = {
        video: fileBuffer,
        caption: `Downloaded from YouTube: ${basename}`,
        mimetype: mimetype,
      }
    } else {
      messageOptions = {
        audio: fileBuffer,
        mimetype: mimetype,
      }
    }

    await sock.sendMessage(sock.user.id, messageOptions)

    setTimeout(() => {
      if (fs.existsSync(filename)) {
        fs.unlinkSync(filename)
      }
    }, 5000)

    console.log(`✅ Downloaded and sent: ${basename}`)
    res.json({ success: true, message: "Downloaded and sent successfully", filename: basename })
  } catch (error) {
    console.error("Error downloading and sending:", error)
    res.json({ success: false, error: error.message })
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
      return res.json({ success: false, error: "Message required" })
    }

    const sock = activeSessions.get(sessionId)
    await sock.sendMessage(sock.user.id, { text: message })

    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/disconnect", async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      try {
        await sock.logout()
      } catch (err) {
        console.error("Error during logout:", err)
      }
      activeSessions.delete(sessionId)
    }

    qrCodes.delete(sessionId)
    cookiesStorage.delete(sessionId)

    try {
      const sessionDir = join(__dirname, "sessions", sessionId)
      const cookiesPath = join(cookiesDir, `${sessionId}.txt`)

      if (fs.existsSync(sessionDir)) {
        fs.rmSync(sessionDir, { recursive: true, force: true })
      }
      if (fs.existsSync(cookiesPath)) {
        fs.unlinkSync(cookiesPath)
      }
    } catch (err) {
      console.error("Error cleaning session files:", err)
    }

    console.log(`🚪 Session ${sessionId} disconnected voluntarily`)
    res.json({ success: true, message: "Session disconnected successfully" })
  } catch (error) {
    console.error("Error disconnecting session:", error)
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
      return res.json({
        status: "waiting",
        position: Math.floor(Math.random() * 5) + 1,
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
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    console.error("Error checking status:", error)
    res.json({ success: false, error: error.message })
  }
})

function createWhatsAppSession(sessionId) {
  const sessionDir = join(__dirname, "sessions", sessionId)
  fs.mkdirSync(sessionDir, { recursive: true })

  console.log(`📱 Creating WhatsApp session: ${sessionId}`)

  const { state, saveCreds } = useMultiFileAuthState(sessionDir)
  const sock = makeWASocket({
    auth: state,
    printQRInTerminal: false,
    browser: Browsers.macOS("Desktop"),
  })

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update

    if (qr) {
      const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
      qrCodes.set(sessionId, qrDataURL)
    }

    if (connection === "close") {
      const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
      console.log(`❌ Connection closed for session ${sessionId}`)

      activeSessions.delete(sessionId)
      qrCodes.delete(sessionId)

      if (shouldReconnect) {
        setTimeout(() => createWhatsAppSession(sessionId), 5000)
      } else {
        try {
          fs.rmSync(sessionDir, { recursive: true, force: true })
        } catch (err) {
          console.error("Error cleaning session directory:", err)
        }
      }
    } else if (connection === "open") {
      console.log(`✅ WhatsApp connected: ${sessionId}`)
      console.log(`👤 User: ${sock.user.name} (${sock.user.id})`)
      qrCodes.delete(sessionId)
    }
  })

  sock.ev.on("creds.update", saveCreds)
  activeSessions.set(sessionId, sock)
}

try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(options, app)
  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 WhatsApp YouTube Lite running on https://${CONFIG.DOMAIN}`)
    console.log(`⚙️ Max sessions: ${CONFIG.MAX_SESSIONS}`)
  })
} catch (error) {
  console.error("❌ HTTPS error, falling back to HTTP")
  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🚀 HTTP Server running on port ${CONFIG.PORT}`)
  })
}

process.on("uncaughtException", (err) => console.error("❌ Uncaught exception:", err))
process.on("unhandledRejection", (err) => console.error("❌ Unhandled rejection:", err))

console.log("🎉 WhatsApp YouTube Lite initialized!")
