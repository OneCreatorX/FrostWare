import express from "express"
import multer from "multer"
import { exec } from "child_process"
import fs from "fs"
import path from "path"
import https from "https"
import { fileURLToPath } from "url"

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const CONFIG = {
  PORT: 8433,
  DOMAIN: "system.heatherx.site",
  SSL_KEY: `/etc/letsencrypt/live/system.heatherx.site/privkey.pem`,
  SSL_CERT: `/etc/letsencrypt/live/system.heatherx.site/cert.pem`,
  SSL_CA: `/etc/letsencrypt/live/system.heatherx.site/chain.pem`,
}

const app = express()
const upload = multer({ dest: "uploads/" })

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

const tempDir = path.join(__dirname, "temp")
const cookiesDir = path.join(__dirname, "cookies")

if (!fs.existsSync(tempDir)) fs.mkdirSync(tempDir, { recursive: true })
if (!fs.existsSync(cookiesDir)) fs.mkdirSync(cookiesDir, { recursive: true })

const htmlContent = `<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>YouTube Cookie Tester</title>
    <style>
        body { font-family: Arial; margin: 20px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; }
        .section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        input, textarea, button { width: 100%; padding: 10px; margin: 5px 0; border: 1px solid #ccc; border-radius: 4px; }
        button { background: #007cba; color: white; cursor: pointer; width: auto; padding: 10px 20px; }
        button:hover { background: #005a87; }
        .log { background: #f8f8f8; padding: 10px; border-radius: 4px; font-family: monospace; white-space: pre-wrap; max-height: 300px; overflow-y: auto; }
        .error { color: red; }
        .success { color: green; }
        .warning { color: orange; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎬 YouTube Cookie Tester</h1>
        
        <div class="section">
            <h3>📁 Upload Cookies (JSON)</h3>
            <input type="file" id="cookieFile" accept=".json">
            <button onclick="uploadCookies()">Upload & Analyze Cookies</button>
        </div>

        <div class="section">
            <h3>🔗 Test YouTube URL</h3>
            <input type="text" id="youtubeUrl" placeholder="https://youtu.be/..." value="https://youtu.be/eypt-w22cto">
            <button onclick="testInfo()">Test Info Only</button>
            <button onclick="testDownload()">Test Download</button>
        </div>

        <div class="section">
            <h3>📊 Cookie Analysis</h3>
            <div id="cookieAnalysis" class="log">No cookies uploaded yet</div>
        </div>

        <div class="section">
            <h3>📝 Test Results</h3>
            <div id="testResults" class="log">No tests run yet</div>
        </div>
    </div>

    <script>
        async function uploadCookies() {
            const fileInput = document.getElementById('cookieFile');
            if (!fileInput.files[0]) {
                alert('Please select a cookie file');
                return;
            }

            const formData = new FormData();
            formData.append('cookies', fileInput.files[0]);

            try {
                const response = await fetch('/upload-cookies', {
                    method: 'POST',
                    body: formData
                });
                const result = await response.json();
                document.getElementById('cookieAnalysis').innerHTML = result.analysis;
            } catch (error) {
                document.getElementById('cookieAnalysis').innerHTML = 'Error: ' + error.message;
            }
        }

        async function testInfo() {
            await runTest('info');
        }

        async function testDownload() {
            await runTest('download');
        }

        async function runTest(type) {
            const url = document.getElementById('youtubeUrl').value;
            if (!url) {
                alert('Please enter a YouTube URL');
                return;
            }

            document.getElementById('testResults').innerHTML = 'Running test...';

            try {
                const response = await fetch('/test-download', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ url, type })
                });
                const result = await response.json();
                document.getElementById('testResults').innerHTML = result.log;
            } catch (error) {
                document.getElementById('testResults').innerHTML = 'Error: ' + error.message;
            }
        }
    </script>
</body>
</html>`

app.get("/", (req, res) => {
  res.send(htmlContent)
})

app.post("/upload-cookies", upload.single("cookies"), (req, res) => {
  try {
    const cookieData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))
    const cookies = cookieData.cookies || cookieData

    const requiredCookies = ["SAPISID", "APISID", "SID", "HSID", "SSID", "LOGIN_INFO"]
    const foundCookies = cookies.map((c) => c.name)
    const missingCookies = requiredCookies.filter((name) => !foundCookies.includes(name))

    let netscapeContent = ""
    let validCount = 0

    cookies.forEach((cookie) => {
      if (cookie.domain && cookie.name && cookie.value) {
        const domain = cookie.domain.startsWith(".") ? cookie.domain : "." + cookie.domain
        const secure = cookie.secure ? "TRUE" : "FALSE"
        const httpOnly = cookie.httpOnly ? "TRUE" : "FALSE"
        const expiry = cookie.expirationDate ? Math.floor(cookie.expirationDate) : "0"

        netscapeContent += `${domain}\tTRUE\t${cookie.path || "/"}\t${secure}\t${expiry}\t${cookie.name}\t${cookie.value}\n`
        validCount++
      }
    })

    const cookieFilePath = path.join(cookiesDir, "youtube_cookies.txt")
    fs.writeFileSync(cookieFilePath, netscapeContent)

    let analysis = `✅ Cookies processed: ${validCount} valid cookies\n`
    analysis += `📁 Saved to: ${cookieFilePath}\n\n`
    analysis += `🔍 Found cookies:\n${foundCookies.join(", ")}\n\n`

    if (missingCookies.length > 0) {
      analysis += `⚠️ Missing important cookies:\n${missingCookies.join(", ")}\n\n`
      analysis += `💡 These cookies are usually needed for YouTube authentication.\n`
      analysis += `Try using EditThisCookie extension or export from DevTools.\n`
    } else {
      analysis += `✅ All important cookies found!\n`
    }

    fs.unlinkSync(req.file.path)

    res.json({ success: true, analysis })
  } catch (error) {
    res.json({ success: false, analysis: `❌ Error: ${error.message}` })
  }
})

app.post("/test-download", (req, res) => {
  const { url, type } = req.body
  const cookieFile = path.join(cookiesDir, "youtube_cookies.txt")

  if (!fs.existsSync(cookieFile)) {
    return res.json({ success: false, log: "❌ No cookies file found. Please upload cookies first." })
  }

  const timestamp = Date.now()
  const outputTemplate = path.join(tempDir, `test_${timestamp}.%(ext)s`)

  let command = "yt-dlp"
  command += " --no-warnings"
  command += " --ignore-errors"
  command += ` --cookies "${cookieFile}"`
  command +=
    ' --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"'

  if (type === "info") {
    command += " --dump-json"
    command += " --no-download"
  } else {
    command += ' --format "best[height<=720]/best"'
    command += ` -o "${outputTemplate}"`
  }

  command += ` "${url}"`

  let log = `🔧 Command: ${command}\n\n`
  log += `📊 Cookie file size: ${fs.statSync(cookieFile).size} bytes\n`
  log += `📄 Cookie lines: ${
    fs
      .readFileSync(cookieFile, "utf8")
      .split("\n")
      .filter((line) => line.trim() && !line.startsWith("#")).length
  }\n\n`
  log += `⏳ Executing...\n\n`

  exec(command, { timeout: 60000 }, (error, stdout, stderr) => {
    if (error) {
      log += `❌ Error: ${error.message}\n\n`
    }

    if (stdout) {
      log += `📤 Output:\n${stdout}\n\n`
    }

    if (stderr) {
      log += `⚠️ Stderr:\n${stderr}\n\n`
    }

    if (type === "download" && !error) {
      const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(`test_${timestamp}`))
      if (files.length > 0) {
        log += `✅ Downloaded files:\n${files.join("\n")}\n`
      }
    }

    res.json({ success: !error, log })
  })
})

try {
  const httpsOptions = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(httpsOptions, app)

  server.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🔒 HTTPS Server running at https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
  })
} catch (error) {
  console.error("Error starting HTTPS server:", error)
  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🌐 HTTP Server running at http://0.0.0.0:${CONFIG.PORT}`)
  })
}
