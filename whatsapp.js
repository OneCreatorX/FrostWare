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
  MAX_SESSIONS: 50,
  SESSION_DURATION: 5 * 60 * 1000,
  COOLDOWN_DURATION: 60 * 60 * 1000,
  MAX_FILES_PER_SESSION: 2,
  MAX_SIZE_PER_SESSION: 500 * 1024 * 1024,
  MAX_FILE_SIZE: 250 * 1024 * 1024,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const qrCodes = new Map()
const cookiesStorage = new Map()
const sessionTimers = new Map()
const whatsappCooldowns = new Map()
const deviceFingerprints = new Map()
const sessionStats = new Map()
const sessionQueue = []
const sessionCreationLocks = new Set()

app.use(express.static("public"))
app.use(bodyParser.json({ limit: "10mb" }))
app.use(bodyParser.urlencoded({ extended: true, limit: "10mb" }))

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

const upload = multer({
  storage: storage,
  limits: { fileSize: 5 * 1024 * 1024 },
})

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

function generateDeviceFingerprint(req) {
  const userAgent = req.headers["user-agent"] || ""
  const acceptLanguage = req.headers["accept-language"] || ""
  const acceptEncoding = req.headers["accept-encoding"] || ""
  const ip = req.ip || req.connection.remoteAddress || ""

  const fingerprint = crypto
    .createHash("sha256")
    .update(userAgent + acceptLanguage + acceptEncoding + ip)
    .digest("hex")
    .substring(0, 32)

  return fingerprint
}

function generateSecureSessionId() {
  const timestamp = Date.now().toString(36)
  const randomBytes = crypto.randomBytes(32).toString("hex")
  const hash = crypto
    .createHash("sha256")
    .update(timestamp + randomBytes)
    .digest("hex")
  return `ws_${timestamp}_${hash.substring(0, 32)}`
}

function convertJsonToNetscape(cookies) {
  let netscapeFormat = "# Netscape HTTP Cookie File\n"
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

  return netscapeFormat
}

function extractVideoId(url) {
  const patterns = [
    /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/,
    /(?:instagram\.com\/p\/|instagram\.com\/reel\/)([^/\n?#]+)/,
    /(?:tiktok\.com\/@[^/]+\/video\/|vm\.tiktok\.com\/)([^/\n?#]+)/,
    /(?:twitter\.com\/[^/]+\/status\/|x\.com\/[^/]+\/status\/)([^/\n?#]+)/,
  ]

  for (const pattern of patterns) {
    const match = url.match(pattern)
    if (match) return match[1]
  }

  return url.length >= 10 && url.length <= 15 ? url : null
}

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp Media Sender - Optimized</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; }
    body { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; overflow-x: hidden; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .card { background: rgba(255,255,255,0.95); backdrop-filter: blur(20px); border-radius: 20px; padding: 30px; margin-bottom: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); border: 1px solid rgba(255,255,255,0.2); }
    .header { text-align: center; margin-bottom: 30px; }
    .header h1 { font-size: 2.5em; margin-bottom: 10px; background: linear-gradient(135deg, #667eea, #764ba2); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
    .header p { color: #666; font-size: 1.1em; line-height: 1.6; }
    .limits { background: linear-gradient(135deg, #ff9a9e, #fecfef); color: white; padding: 20px; border-radius: 15px; margin-bottom: 20px; text-align: center; }
    .limits h3 { margin-bottom: 15px; font-size: 1.3em; }
    .limits ul { list-style: none; }
    .limits li { margin: 8px 0; font-size: 0.95em; }
    .status-bar { display: flex; justify-content: space-between; align-items: center; padding: 15px; background: #f8f9fa; border-radius: 10px; margin-bottom: 20px; }
    .status-connected { background: linear-gradient(45deg, #4CAF50, #45a049); padding: 8px 16px; border-radius: 20px; color: white; font-size: 0.9em; }
    .status-disconnected { background: linear-gradient(45deg, #f44336, #d32f2f); padding: 8px 16px; border-radius: 20px; color: white; font-size: 0.9em; }
    .status-waiting { background: linear-gradient(45deg, #ff9800, #f57c00); padding: 8px 16px; border-radius: 20px; color: white; font-size: 0.9em; }
    .timer { font-size: 1.2em; font-weight: bold; color: #333; }
    .qr-container { text-align: center; padding: 40px 20px; }
    .qr-container img { max-width: 280px; border-radius: 15px; margin: 20px 0; box-shadow: 0 10px 30px rgba(0,0,0,0.2); }
    .loading-spinner { border: 3px solid #f3f3f3; border-radius: 50%; border-top: 3px solid #667eea; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 20px auto; }
    @keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }
    .upload-area { border: 2px dashed #ddd; border-radius: 15px; padding: 30px; text-align: center; cursor: pointer; transition: all 0.3s ease; margin-bottom: 20px; }
    .upload-area:hover { border-color: #667eea; background: rgba(102, 126, 234, 0.05); }
    .upload-area.dragover { border-color: #4CAF50; background: rgba(76, 175, 80, 0.1); }
    .file-input { display: none; }
    .input { width: 100%; padding: 15px; border: 2px solid #e1e5e9; border-radius: 12px; font-size: 1em; margin-bottom: 15px; transition: all 0.3s ease; }
    .input:focus { outline: none; border-color: #667eea; box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1); }
    .btn { background: linear-gradient(135deg, #667eea, #764ba2); color: white; border: none; padding: 15px 25px; border-radius: 12px; cursor: pointer; font-size: 1em; font-weight: 600; transition: all 0.3s ease; width: 100%; margin-bottom: 10px; }
    .btn:hover:not(:disabled) { transform: translateY(-2px); box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3); }
    .btn:disabled { opacity: 0.6; cursor: not-allowed; transform: none; }
    .btn-danger { background: linear-gradient(135deg, #f44336, #d32f2f); }
    .btn-success { background: linear-gradient(135deg, #4CAF50, #45a049); }
    .progress-bar { width: 100%; height: 8px; background: #e1e5e9; border-radius: 4px; overflow: hidden; margin: 15px 0; }
    .progress-fill { height: 100%; background: linear-gradient(90deg, #667eea, #764ba2); transition: width 0.3s ease; }
    .stats { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 15px; margin: 20px 0; }
    .stat { text-align: center; padding: 15px; background: #f8f9fa; border-radius: 10px; }
    .stat-value { font-size: 1.5em; font-weight: bold; color: #333; }
    .stat-label { font-size: 0.9em; color: #666; margin-top: 5px; }
    .video-info { background: linear-gradient(135deg, #e3f2fd, #f3e5f5); padding: 20px; border-radius: 15px; margin: 20px 0; }
    .video-title { font-size: 1.1em; font-weight: bold; margin-bottom: 10px; color: #333; }
    .video-details { font-size: 0.9em; color: #666; margin-bottom: 15px; }
    .download-options { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; }
    .cookies-status { padding: 15px; border-radius: 10px; text-align: center; margin: 15px 0; font-size: 0.9em; }
    .cookies-status.loaded { background: rgba(76, 175, 80, 0.1); color: #4CAF50; border: 1px solid rgba(76, 175, 80, 0.3); }
    .cookies-status.error { background: rgba(244, 67, 54, 0.1); color: #f44336; border: 1px solid rgba(244, 67, 54, 0.3); }
    .cookies-status.default { background: rgba(158, 158, 158, 0.1); color: #666; border: 1px solid rgba(158, 158, 158, 0.3); text-align: center; }
    .session-info { font-size: 0.8em; color: #666; text-align: center; margin-bottom: 15px; }
    .warning { background: rgba(255, 152, 0, 0.1); color: #ff9800; padding: 15px; border-radius: 10px; margin: 15px 0; border: 1px solid rgba(255, 152, 0, 0.3); text-align: center; }
    .hidden { display: none !important; }
    .server-stats { background: rgba(102, 126, 234, 0.1); padding: 15px; border-radius: 10px; margin-bottom: 20px; text-align: center; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📱 WhatsApp Media Sender</h1>
      <p>Send media from YouTube, Instagram, TikTok & more directly to your WhatsApp</p>
    </div>
    
    <div class="server-stats">
      <div style="font-size: 0.9em; color: #666;">
        <span id="active-sessions">0</span>/50 Active Sessions | 
        <span id="queue-length">0</span> in Queue
      </div>
    </div>
    
    <div class="limits">
      <h3>⚡ Service Limits</h3>
      <ul>
        <li>🕐 5 minutes per session</li>
        <li>📁 2 files maximum per session</li>
        <li>💾 500MB total per session</li>
        <li>⏰ 1 hour cooldown between sessions</li>
        <li>🔒 One session per device</li>
      </ul>
    </div>
    
    <div id="waiting-section" class="card">
      <div class="qr-container">
        <h2>⏳ Service Full</h2>
        <div class="loading-spinner"></div>
        <p>All sessions are busy. Please wait...</p>
        <div id="queue-position" style="margin-top: 15px; font-weight: bold;"></div>
        <button class="btn" onclick="location.reload()" style="margin-top: 20px;">🔄 Refresh</button>
      </div>
    </div>
    
    <div id="cooldown-section" class="card hidden">
      <div class="qr-container">
        <h2>⏰ Cooldown Active</h2>
        <div class="warning">
          <p>You recently used this service. Please wait before starting a new session.</p>
          <div id="cooldown-timer" style="font-size: 1.2em; font-weight: bold; margin-top: 10px;"></div>
        </div>
        <button class="btn" onclick="location.reload()" style="margin-top: 20px;">🔄 Check Again</button>
      </div>
    </div>
    
    <div id="qr-section" class="card hidden">
      <div class="qr-container">
        <h2>📱 Scan QR Code</h2>
        <div id="qr-image"></div>
        <p>Open WhatsApp → Linked Devices → Link Device</p>
        <div id="qr-timer" class="timer" style="margin-top: 15px;"></div>
      </div>
    </div>
    
    <div id="main-content" class="card hidden">
      <div class="status-bar">
        <div id="status" class="status-disconnected">Disconnected</div>
        <div id="session-timer" class="timer">5:00</div>
      </div>
      
      <div class="session-info" id="session-info">Session: Loading...</div>
      
      <div class="stats">
        <div class="stat">
          <div id="files-used" class="stat-value">0/2</div>
          <div class="stat-label">Files Used</div>
        </div>
        <div class="stat">
          <div id="data-used" class="stat-value">0/500MB</div>
          <div class="stat-label">Data Used</div>
        </div>
        <div class="stat">
          <div id="time-left" class="stat-value">5:00</div>
          <div class="stat-label">Time Left</div>
        </div>
      </div>
      
      <h3>🍪 Upload Cookies (Optional)</h3>
      <div class="upload-area" id="cookies-upload-area">
        <div style="font-size: 2em; margin-bottom: 10px;">🍪</div>
        <div>Drop J2Team cookies.json here or click to browse</div>
        <input type="file" id="cookies-input" class="file-input" accept=".json">
      </div>
      <div id="cookies-status" class="cookies-status default">No cookies loaded - some content may be restricted</div>
      
      <h3>🎬 Send Media</h3>
      <input type="text" id="url-input" class="input" placeholder="Paste URL from YouTube, Instagram, TikTok, Twitter...">
      <button id="get-info-btn" class="btn">📋 Get Media Info</button>
      
      <div id="video-info" class="hidden"></div>
      <div id="progress-container" class="hidden">
        <div class="progress-bar">
          <div id="progress-fill" class="progress-fill" style="width: 0%;"></div>
        </div>
        <div id="progress-text" style="text-align: center; margin-top: 10px;"></div>
      </div>
    </div>
  </div>
  
  <script>
    let sessionId = localStorage.getItem('whatsapp-session-id') || generateSecureSessionId();
    let sessionStartTime = null;
    let sessionTimer = null;
    let qrTimer = null;
    let filesUsed = 0;
    let dataUsed = 0;
    let hasCookies = false;

    const elements = {
      waitingSection: document.getElementById("waiting-section"),
      cooldownSection: document.getElementById("cooldown-section"),
      qrSection: document.getElementById("qr-section"),
      mainContent: document.getElementById("main-content"),
      status: document.getElementById("status"),
      sessionInfo: document.getElementById("session-info"),
      sessionTimer: document.getElementById("session-timer"),
      qrTimer: document.getElementById("qr-timer"),
      qrImage: document.getElementById("qr-image"),
      filesUsed: document.getElementById("files-used"),
      dataUsed: document.getElementById("data-used"),
      timeLeft: document.getElementById("time-left"),
      cookiesUploadArea: document.getElementById("cookies-upload-area"),
      cookiesInput: document.getElementById("cookies-input"),
      cookiesStatus: document.getElementById("cookies-status"),
      urlInput: document.getElementById("url-input"),
      getInfoBtn: document.getElementById("get-info-btn"),
      videoInfo: document.getElementById("video-info"),
      progressContainer: document.getElementById("progress-container"),
      progressFill: document.getElementById("progress-fill"),
      progressText: document.getElementById("progress-text"),
      queuePosition: document.getElementById("queue-position"),
      cooldownTimer: document.getElementById("cooldown-timer"),
      activeSessions: document.getElementById("active-sessions"),
      queueLength: document.getElementById("queue-length")
    };

    function generateSecureSessionId() {
      const timestamp = Date.now().toString(36);
      const randomBytes = Array.from(crypto.getRandomValues(new Uint8Array(32)), 
        b => b.toString(16).padStart(2, '0')).join('');
      const combined = timestamp + randomBytes;
      return \`ws_\${timestamp}_\${btoa(combined).replace(/[+/=]/g, '').substring(0, 32)}\`;
    }

    function formatTime(seconds) {
      const mins = Math.floor(seconds / 60);
      const secs = seconds % 60;
      return \`\${mins}:\${secs.toString().padStart(2, '0')}\`;
    }

    function formatBytes(bytes) {
      if (bytes === 0) return '0B';
      const k = 1024;
      const sizes = ['B', 'KB', 'MB', 'GB'];
      const i = Math.floor(Math.log(bytes) / Math.log(k));
      return parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + sizes[i];
    }

    function startSessionTimer() {
      if (sessionTimer) clearInterval(sessionTimer);
      sessionStartTime = Date.now();
      
      sessionTimer = setInterval(() => {
        const elapsed = Math.floor((Date.now() - sessionStartTime) / 1000);
        const remaining = Math.max(0, 300 - elapsed);
        
        elements.sessionTimer.textContent = formatTime(remaining);
        elements.timeLeft.textContent = formatTime(remaining);
        
        if (remaining === 0) {
          clearInterval(sessionTimer);
          alert('⏰ Session expired! Redirecting...');
          location.reload();
        }
      }, 1000);
    }

    function startQRTimer() {
      if (qrTimer) clearInterval(qrTimer);
      let qrTime = 300;
      
      qrTimer = setInterval(() => {
        qrTime--;
        elements.qrTimer.textContent = \`QR expires in: \${formatTime(qrTime)}\`;
        
        if (qrTime === 0) {
          clearInterval(qrTimer);
          location.reload();
        }
      }, 1000);
    }

    function updateStats() {
      elements.filesUsed.textContent = \`\${filesUsed}/2\`;
      elements.dataUsed.textContent = \`\${formatBytes(dataUsed)}/500MB\`;
    }

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

      if (filesUsed >= 2) {
        alert('⚠️ Maximum files per session reached (2/2)');
        return;
      }

      elements.getInfoBtn.textContent = '⏳ Analyzing...';
      elements.getInfoBtn.disabled = true;

      try {
        const response = await fetch(\`/api/media-info?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ url })
        });
        
        const result = await response.json();
        if (result.success) {
          displayMediaInfo(result);
        } else {
          alert('❌ Error: ' + result.error);
        }
      } catch (error) {
        alert('❌ Error: ' + error.message);
      } finally {
        elements.getInfoBtn.textContent = '📋 Get Media Info';
        elements.getInfoBtn.disabled = false;
      }
    });

    function displayMediaInfo(info) {
      const sizeWarning = info.estimatedSize > 250 * 1024 * 1024 ? 
        '<div class="warning">⚠️ File is large and may take time to process</div>' : '';
      
      elements.videoInfo.innerHTML = \`
        <div class="video-info">
          <div class="video-title">\${info.title}</div>
          <div class="video-details">
            Duration: \${info.duration || 'N/A'} | 
            Size: ~\${formatBytes(info.estimatedSize || 0)} |
            Platform: \${info.platform || 'Unknown'}
          </div>
          \${sizeWarning}
          <div class="download-options">
            <button class="btn btn-success" onclick="downloadAndSend('best', '\${info.id}', \${info.estimatedSize || 0})">
              📹 Best Quality
            </button>
            <button class="btn" onclick="downloadAndSend('audio', '\${info.id}', \${Math.floor((info.estimatedSize || 0) * 0.1)})">
              🎵 Audio Only
            </button>
          </div>
        </div>
      \`;
      elements.videoInfo.classList.remove('hidden');
    }

    window.downloadAndSend = async function(type, mediaId, estimatedSize) {
      if (filesUsed >= 2) {
        alert('⚠️ Maximum files per session reached');
        return;
      }

      if (dataUsed + estimatedSize > 500 * 1024 * 1024) {
        alert('⚠️ This would exceed your session data limit');
        return;
      }

      elements.progressContainer.classList.remove('hidden');
      elements.progressText.textContent = 'Starting download...';
      
      const progressInterval = setInterval(() => {
        const currentWidth = parseInt(elements.progressFill.style.width) || 0;
        if (currentWidth < 90) {
          elements.progressFill.style.width = (currentWidth + Math.random() * 10) + '%';
        }
      }, 1000);

      try {
        const response = await fetch(\`/api/download-send?session=\${sessionId}\`, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ type, mediaId, url: elements.urlInput.value.trim() })
        });
        
        const result = await response.json();
        
        clearInterval(progressInterval);
        elements.progressFill.style.width = '100%';
        
        if (result.success) {
          filesUsed++;
          dataUsed += result.fileSize || estimatedSize;
          updateStats();
          
          elements.progressText.textContent = '✅ Sent successfully!';
          elements.videoInfo.classList.add('hidden');
          elements.urlInput.value = '';
          
          setTimeout(() => {
            elements.progressContainer.classList.add('hidden');
            elements.progressFill.style.width = '0%';
          }, 3000);
        } else {
          elements.progressText.textContent = '❌ Error: ' + result.error;
        }
      } catch (error) {
        clearInterval(progressInterval);
        elements.progressText.textContent = '❌ Error: ' + error.message;
      }
    };

    async function checkStatus() {
      try {
        const response = await fetch(\`/api/status?session=\${sessionId}\`);
        const result = await response.json();

        if (result.serverStats) {
          elements.activeSessions.textContent = result.serverStats.activeSessions;
          elements.queueLength.textContent = result.serverStats.queueLength;
        }

        if (result.status === 'connected') {
          elements.status.textContent = '✅ Connected';
          elements.status.className = 'status-connected';
          showSection('main-content');
          if (!sessionTimer) startSessionTimer();
          
          filesUsed = result.filesUsed || 0;
          dataUsed = result.dataUsed || 0;
          updateStats();
          
        } else if (result.status === 'qr') {
          elements.status.textContent = '📱 Scan QR';
          elements.status.className = 'status-disconnected';
          showSection('qr-section');
          
          if (result.qr) {
            elements.qrImage.innerHTML = \`<img src="\${result.qr}" alt="QR Code" />\`;
            if (!qrTimer) startQRTimer();
          }
          
        } else if (result.status === 'waiting') {
          showSection('waiting-section');
          elements.queuePosition.textContent = \`Position in queue: \${result.position || 'Unknown'}\`;
          
        } else if (result.status === 'cooldown') {
          showSection('cooldown-section');
          const remaining = Math.ceil(result.remainingTime / 1000 / 60);
          elements.cooldownTimer.textContent = \`\${remaining} minutes remaining\`;
          
        } else if (result.status === 'device_limit') {
          alert('⚠️ You already have an active session from this device');
          
        } else {
          elements.status.textContent = '⏳ Initializing';
          elements.status.className = 'status-disconnected';
        }
      } catch (error) {
        console.error('Error checking status:', error);
        elements.status.textContent = '❌ Connection Error';
        elements.status.className = 'status-disconnected';
      }
    }

    function showSection(sectionId) {
      const sections = ['waiting-section', 'cooldown-section', 'qr-section', 'main-content'];
      sections.forEach(id => {
        const element = document.getElementById(id);
        if (id === sectionId) {
          element.classList.remove('hidden');
        } else {
          element.classList.add('hidden');
        }
      });
    }

    localStorage.setItem('whatsapp-session-id', sessionId);
    checkStatus();
    setInterval(checkStatus, 2000);
  </script>
</body>
</html>`

fs.writeFileSync("public/index.html", htmlContent)

app.get("/", (req, res) => {
  const deviceFingerprint = generateDeviceFingerprint(req)

  if (deviceFingerprints.has(deviceFingerprint)) {
    const existingSessionId = deviceFingerprints.get(deviceFingerprint)
    if (activeSessions.has(existingSessionId)) {
      return res.redirect(`/?session=${existingSessionId}`)
    }
  }

  res.sendFile(join(__dirname, "public", "index.html"))
})

app.post("/api/cookies", upload.single("cookiesFile"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session
    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
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
      message: `${cookiesData.cookies.length} cookies loaded`,
    })
  } catch (error) {
    console.error("Error processing cookies:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/media-info", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!url) {
      return res.json({ success: false, error: "URL required" })
    }

    const mediaId = extractVideoId(url)
    if (!mediaId) {
      return res.json({ success: false, error: "Invalid media URL" })
    }

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    const cookiesFlag = fs.existsSync(sessionCookiesPath) ? `--cookies "${sessionCookiesPath}"` : ""

    const cmd = `yt-dlp --no-warnings ${cookiesFlag} --print "%(title)s" --print "%(duration_string)s" --print "%(filesize,filesize_approx)s" --print "%(extractor)s" "${url}"`

    const result = execSync(cmd, { encoding: "utf8", timeout: 20000 })
    const lines = result.trim().split("\n")

    const estimatedSize = Number.parseInt(lines[2]) || 50 * 1024 * 1024

    const info = {
      success: true,
      id: mediaId,
      title: lines[0] || "Media file",
      duration: lines[1] || "Unknown",
      estimatedSize: estimatedSize,
      platform: lines[3] || "Unknown",
    }

    res.json(info)
  } catch (error) {
    console.error("Error getting media info:", error)
    res.json({ success: false, error: "Unable to analyze media. Try with cookies if content is restricted." })
  }
})

app.post("/api/download-send", async (req, res) => {
  try {
    const { type, mediaId, url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    const stats = sessionStats.get(sessionId) || { filesUsed: 0, dataUsed: 0 }

    if (stats.filesUsed >= CONFIG.MAX_FILES_PER_SESSION) {
      return res.json({ success: false, error: "Maximum files per session reached" })
    }

    const sock = activeSessions.get(sessionId)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    const cookiesFlag = fs.existsSync(sessionCookiesPath) ? `--cookies "${sessionCookiesPath}"` : ""

    let cmd, outputTemplate, mimetype

    if (type === "best") {
      const format = "best[filesize<250M]/best[height<=720]/best"
      outputTemplate = `${downloadsDir}/${sessionId}_%(title)s.%(ext)s`
      cmd = `yt-dlp --no-warnings ${cookiesFlag} --format "${format}" -o "${outputTemplate}" "${url}"`
      mimetype = "video/mp4"
    } else if (type === "audio") {
      outputTemplate = `${downloadsDir}/${sessionId}_%(title)s.mp3`
      cmd = `yt-dlp --no-warnings ${cookiesFlag} --extract-audio --audio-format mp3 -o "${outputTemplate}" "${url}"`
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

    const fileStats = fs.statSync(filename)
    const fileSize = fileStats.size

    if (stats.dataUsed + fileSize > CONFIG.MAX_SIZE_PER_SESSION) {
      fs.unlinkSync(filename)
      return res.json({ success: false, error: "File too large for remaining session quota" })
    }

    const fileBuffer = fs.readFileSync(filename)
    const basename = path.basename(filename)

    let messageOptions = {}
    if (type === "best") {
      messageOptions = {
        video: fileBuffer,
        caption: `Downloaded: ${basename}`,
        mimetype: mimetype,
      }
    } else {
      messageOptions = {
        audio: fileBuffer,
        mimetype: mimetype,
      }
    }

    await sock.sendMessage(sock.user.id, messageOptions)

    stats.filesUsed++
    stats.dataUsed += fileSize
    sessionStats.set(sessionId, stats)

    fs.unlinkSync(filename)

    console.log(`✅ Sent: ${basename} (${formatBytes(fileSize)})`)
    res.json({
      success: true,
      message: "Sent successfully",
      filename: basename,
      fileSize: fileSize,
    })
  } catch (error) {
    console.error("Error downloading and sending:", error)
    res.json({ success: false, error: error.message })
  }
})

app.get("/api/status", async (req, res) => {
  try {
    const sessionId = req.query.session
    const deviceFingerprint = generateDeviceFingerprint(req)

    if (!sessionId) {
      return res.json({ success: false, error: "Session ID required" })
    }

    const serverStats = {
      activeSessions: activeSessions.size,
      queueLength: sessionQueue.length,
    }

    if (deviceFingerprints.has(deviceFingerprint)) {
      const existingSessionId = deviceFingerprints.get(deviceFingerprint)
      if (existingSessionId !== sessionId && activeSessions.has(existingSessionId)) {
        return res.json({ status: "device_limit", serverStats })
      }
    }

    if (whatsappCooldowns.has(sessionId)) {
      const cooldownEnd = whatsappCooldowns.get(sessionId)
      if (Date.now() < cooldownEnd) {
        return res.json({
          status: "cooldown",
          remainingTime: cooldownEnd - Date.now(),
          serverStats,
        })
      } else {
        whatsappCooldowns.delete(sessionId)
      }
    }

    if (activeSessions.size >= CONFIG.MAX_SESSIONS && !activeSessions.has(sessionId)) {
      if (!sessionQueue.includes(sessionId)) {
        sessionQueue.push(sessionId)
      }
      const position = sessionQueue.indexOf(sessionId) + 1
      return res.json({
        status: "waiting",
        position: position,
        serverStats,
      })
    }

    if (activeSessions.has(sessionId)) {
      const sock = activeSessions.get(sessionId)
      if (sock.user) {
        const stats = sessionStats.get(sessionId) || { filesUsed: 0, dataUsed: 0 }
        return res.json({
          status: "connected",
          user: {
            id: sock.user.id,
            name: sock.user.name || sock.user.id,
          },
          filesUsed: stats.filesUsed,
          dataUsed: stats.dataUsed,
          serverStats,
        })
      }
    }

    if (qrCodes.has(sessionId)) {
      return res.json({
        status: "qr",
        qr: qrCodes.get(sessionId),
        serverStats,
      })
    }

    if (!activeSessions.has(sessionId) && !sessionCreationLocks.has(sessionId)) {
      createWhatsAppSession(sessionId, deviceFingerprint)
    }

    res.json({ status: "initializing", serverStats })
  } catch (error) {
    console.error("Error checking status:", error)
    res.json({ success: false, error: error.message })
  }
})

async function createWhatsAppSession(sessionId, deviceFingerprint) {
  if (sessionCreationLocks.has(sessionId)) {
    return
  }

  sessionCreationLocks.add(sessionId)

  try {
    const sessionDir = join(__dirname, "sessions", sessionId)
    fs.mkdirSync(sessionDir, { recursive: true })

    console.log(`📱 Creating session: ${sessionId}`)

    const { state, saveCreds } = await useMultiFileAuthState(sessionDir)

    const sock = makeWASocket({
      auth: state,
      browser: Browsers.macOS("Desktop"),
      connectTimeoutMs: 60000,
      defaultQueryTimeoutMs: 0,
      keepAliveIntervalMs: 10000,
      logger: {
        level: "silent",
        child: () => ({ level: "silent" }),
      },
    })

    sock.ev.on("connection.update", async (update) => {
      const { connection, lastDisconnect, qr } = update

      if (qr) {
        try {
          const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
          qrCodes.set(sessionId, qrDataURL)
        } catch (qrError) {
          console.error(`QR generation error for ${sessionId}:`, qrError)
        }
      }

      if (connection === "close") {
        console.log(`❌ Connection closed: ${sessionId}`)
        cleanupSession(sessionId, deviceFingerprint)
      } else if (connection === "open") {
        console.log(`✅ Connected: ${sessionId} - ${sock.user?.name || "Unknown"}`)
        qrCodes.delete(sessionId)
        deviceFingerprints.set(deviceFingerprint, sessionId)

        if (sock.user?.id) {
          whatsappCooldowns.set(sock.user.id, Date.now() + CONFIG.COOLDOWN_DURATION)
        }

        sessionTimers.set(
          sessionId,
          setTimeout(() => {
            console.log(`⏰ Session expired: ${sessionId}`)
            cleanupSession(sessionId, deviceFingerprint)
          }, CONFIG.SESSION_DURATION),
        )

        const queueIndex = sessionQueue.indexOf(sessionId)
        if (queueIndex > -1) {
          sessionQueue.splice(queueIndex, 1)
        }
      }
    })

    sock.ev.on("creds.update", saveCreds)
    activeSessions.set(sessionId, sock)
  } catch (error) {
    console.error(`Error creating session ${sessionId}:`, error)
    cleanupSession(sessionId, deviceFingerprint)
  } finally {
    sessionCreationLocks.delete(sessionId)
  }
}

function cleanupSession(sessionId, deviceFingerprint) {
  if (activeSessions.has(sessionId)) {
    try {
      const sock = activeSessions.get(sessionId)
      if (sock && typeof sock.end === "function") {
        sock.end()
      }
    } catch (error) {
      console.error(`Error ending socket for ${sessionId}:`, error)
    }
    activeSessions.delete(sessionId)
  }

  if (sessionTimers.has(sessionId)) {
    clearTimeout(sessionTimers.get(sessionId))
    sessionTimers.delete(sessionId)
  }

  qrCodes.delete(sessionId)
  cookiesStorage.delete(sessionId)
  sessionStats.delete(sessionId)
  sessionCreationLocks.delete(sessionId)

  const queueIndex = sessionQueue.indexOf(sessionId)
  if (queueIndex > -1) {
    sessionQueue.splice(queueIndex, 1)
  }

  if (deviceFingerprint) {
    deviceFingerprints.delete(deviceFingerprint)
  }

  setTimeout(() => {
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
      console.error("Error cleaning files:", err)
    }
  }, 5000)
}

function formatBytes(bytes) {
  if (bytes === 0) return "0B"
  const k = 1024
  const sizes = ["B", "KB", "MB", "GB"]
  const i = Math.floor(Math.log(bytes) / Math.log(k))
  return Number.parseFloat((bytes / Math.pow(k, i)).toFixed(1)) + sizes[i]
}

try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(options, app)
  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 WhatsApp Optimized: https://${CONFIG.DOMAIN}`)
    console.log(
      `⚙️ Limits: ${CONFIG.MAX_SESSIONS} sessions, ${CONFIG.SESSION_DURATION / 1000 / 60}min each, ${CONFIG.MAX_FILES_PER_SESSION} files, ${formatBytes(CONFIG.MAX_SIZE_PER_SESSION)}`,
    )
  })
} catch (error) {
  console.error("❌ HTTPS error, falling back to HTTP")
  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🚀 HTTP Server: port ${CONFIG.PORT}`)
  })
}

setInterval(() => {
  const now = Date.now()
  for (const [key, expiry] of whatsappCooldowns.entries()) {
    if (now > expiry) {
      whatsappCooldowns.delete(key)
    }
  }

  while (sessionQueue.length > 0 && activeSessions.size < CONFIG.MAX_SESSIONS) {
    const nextSessionId = sessionQueue.shift()
    console.log(`🔄 Processing queued session: ${nextSessionId}`)
  }
}, 30000)

process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("❌ Unhandled:", err)
})

console.log("🎉 WhatsApp Optimized initialized!")
