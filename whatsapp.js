import express from "express"
import { exec } from "child_process"
import fs from "fs"
import path from "path"
import https from "https"
import { fileURLToPath } from "url"
import multer from "multer"

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

if (!fs.existsSync("temp")) fs.mkdirSync("temp")
if (!fs.existsSync("cookies")) fs.mkdirSync("cookies")

app.get("/", (req, res) => {
  res.send(`<!DOCTYPE html>
<html>
<head>
    <title>YouTube Tester</title>
    <style>
        body { font-family: Arial; margin: 20px; }
        .container { max-width: 600px; margin: 0 auto; }
        input, button, textarea { width: 100%; padding: 10px; margin: 10px 0; }
        button { background: #007cba; color: white; border: none; cursor: pointer; }
        .log { background: #f5f5f5; padding: 10px; font-family: monospace; white-space: pre-wrap; max-height: 400px; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>YouTube Cookie Tester</h1>
        
        <h3>Upload Cookies</h3>
        <input type="file" id="cookieFile" accept=".json">
        <button onclick="uploadCookies()">Upload</button>
        
        <h3>Test URL</h3>
        <input type="text" id="url" placeholder="YouTube URL" value="https://youtu.be/eypt-w22cto">
        <button onclick="testInfo()">Test Info</button>
        <button onclick="testDownload()">Test Download</button>
        
        <h3>Results</h3>
        <div id="results" class="log">No tests run</div>
    </div>

    <script>
        async function uploadCookies() {
            const file = document.getElementById('cookieFile').files[0];
            if (!file) return alert('Select file');
            
            const formData = new FormData();
            formData.append('cookies', file);
            
            const response = await fetch('/upload', { method: 'POST', body: formData });
            const result = await response.json();
            document.getElementById('results').textContent = result.message;
        }
        
        async function testInfo() {
            await runTest('info');
        }
        
        async function testDownload() {
            await runTest('download');
        }
        
        async function runTest(type) {
            const url = document.getElementById('url').value;
            if (!url) return alert('Enter URL');
            
            document.getElementById('results').textContent = 'Testing...';
            
            const response = await fetch('/test', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url, type })
            });
            
            const result = await response.json();
            document.getElementById('results').textContent = result.log;
        }
    </script>
</body>
</html>`)
})

app.post("/upload", upload.single("cookies"), (req, res) => {
  try {
    const data = JSON.parse(fs.readFileSync(req.file.path, "utf8"))
    const cookies = data.cookies || data
    
    let netscape = ""
    cookies.forEach(c => {
      if (c.domain && c.name && c.value) {
        const domain = c.domain.startsWith(".") ? c.domain : "." + c.domain
        const secure = c.secure ? "TRUE" : "FALSE"
        const expiry = c.expirationDate ? Math.floor(c.expirationDate) : "0"
        netscape += `${domain}\tTRUE\t${c.path || "/"}\t${secure}\t${expiry}\t${c.name}\t${c.value}\n`
      }
    })
    
    fs.writeFileSync("cookies/youtube.txt", netscape)
    fs.unlinkSync(req.file.path)
    
    const required = ["SAPISID", "APISID", "SID", "HSID", "SSID"]
    const found = cookies.map(c => c.name)
    const missing = required.filter(r => !found.includes(r))
    
    let message = `Processed ${cookies.length} cookies\n`
    message += `Found: ${found.join(", ")}\n`
    if (missing.length > 0) {
      message += `Missing: ${missing.join(", ")}\n`
    }
    
    res.json({ success: true, message })
  } catch (error) {
    res.json({ success: false, message: error.message })
  }
})

app.post("/test", (req, res) => {
  const { url, type } = req.body
  
  if (!fs.existsSync("cookies/youtube.txt")) {
    return res.json({ success: false, log: "No cookies file found" })
  }
  
  const timestamp = Date.now()
  let command = `yt-dlp --cookies "cookies/youtube.txt" --user-agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"`
  
  if (type === "info") {
    command += ` --dump-json --no-download "${url}"`
  } else {
    command += ` --format "best[height<=720]/best" -o "temp/${timestamp}.%(ext)s" "${url}"`
  }
  
  exec(command, { timeout: 60000 }, (error, stdout, stderr) => {
    let log = `Command: ${command}\n\n`
    
    if (error) {
      log += `Error: ${error.message}\n\n`
    }
    
    if (stdout) {
      log += `Output:\n${stdout}\n\n`
    }
    
    if (stderr) {
      log += `Stderr:\n${stderr}\n\n`
    }
    
    if (type === "download" && !error) {
      const files = fs.readdirSync("temp").filter(f => f.startsWith(timestamp.toString()))
      if (files.length > 0) {
        log += `Downloaded: ${files.join(", ")}\n`
      }
    }
    
    res.json({ success: !error, log })
  })
})

const httpsOptions = {
  key: fs.readFileSync(CONFIG.SSL_KEY),
  cert: fs.readFileSync(CONFIG.SSL_CERT),
  ca: fs.readFileSync(CONFIG.SSL_CA)
}

https.createServer(httpsOptions, app).listen(CONFIG.PORT, () => {
  console.log(`Server: https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
})
