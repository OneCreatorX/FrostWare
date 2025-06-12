import express from "express"
import https from "https"
import fs from "fs"
import multer from "multer"
import { exec } from "child_process"
import { promisify } from "util"

const execAsync = promisify(exec)
const app = express()
const upload = multer({ dest: 'uploads/' })

app.use(express.json())
app.use(express.urlencoded({ extended: true }))

const htmlContent = `<!DOCTYPE html>
<html>
<head>
    <title>YouTube Tester</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .section { margin: 30px 0; padding: 20px; border: 1px solid #ddd; }
        input, button, textarea { padding: 10px; margin: 5px; }
        button { background: #007cba; color: white; border: none; cursor: pointer; }
        .result { background: #f5f5f5; padding: 15px; margin: 10px 0; white-space: pre-wrap; }
    </style>
</head>
<body>
    <h1>YouTube Download Tester</h1>
    
    <div class="section">
        <h3>1. Upload Cookies JSON</h3>
        <input type="file" id="cookieFile" accept=".json">
        <button onclick="uploadCookies()">Upload Cookies</button>
        <div id="cookieStatus"></div>
    </div>
    
    <div class="section">
        <h3>2. Test Download</h3>
        <input type="url" id="videoUrl" placeholder="YouTube URL" value="https://youtu.be/eypt-w22cto" style="width: 400px;">
        <br>
        <button onclick="testDownload()">Test Download</button>
        <div id="downloadResult" class="result"></div>
    </div>

    <script>
        async function uploadCookies() {
            const file = document.getElementById('cookieFile').files[0];
            if (!file) return;
            
            const formData = new FormData();
            formData.append('cookies', file);
            
            try {
                const response = await fetch('/upload-cookies', {
                    method: 'POST',
                    body: formData
                });
                const result = await response.json();
                document.getElementById('cookieStatus').innerHTML = result.success ? 
                    '<span style="color: green;">✓ Cookies uploaded</span>' : 
                    '<span style="color: red;">✗ ' + result.error + '</span>';
            } catch (error) {
                document.getElementById('cookieStatus').innerHTML = '<span style="color: red;">✗ Upload failed</span>';
            }
        }
        
        async function testDownload() {
            const url = document.getElementById('videoUrl').value;
            if (!url) return;
            
            document.getElementById('downloadResult').textContent = 'Testing...';
            
            try {
                const response = await fetch('/test-download', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ url })
                });
                const result = await response.json();
                document.getElementById('downloadResult').textContent = result.output || result.error;
            } catch (error) {
                document.getElementById('downloadResult').textContent = 'Request failed: ' + error.message;
            }
        }
    </script>
</body>
</html>`

app.get('/', (req, res) => {
    res.send(htmlContent)
})

app.post('/upload-cookies', upload.single('cookies'), (req, res) => {
    try {
        if (!req.file) {
            return res.json({ success: false, error: 'No file uploaded' })
        }
        
        const cookiesData = JSON.parse(fs.readFileSync(req.file.path, 'utf8'))
        
        let netscapeFormat = "# Netscape HTTP Cookie File\n\n"
        
        cookiesData.cookies.forEach(cookie => {
            const domain = cookie.domain || ""
            const flag = domain.startsWith(".") ? "TRUE" : "FALSE"
            const path = cookie.path || "/"
            const secure = cookie.secure ? "TRUE" : "FALSE"
            const expiration = cookie.expirationDate || Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
            const name = cookie.name || ""
            const value = cookie.value || ""
            
            if (domain && name) {
                netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
            }
        })
        
        fs.writeFileSync('cookies.txt', netscapeFormat)
        fs.unlinkSync(req.file.path)
        
        res.json({ success: true, message: `Processed ${cookiesData.cookies.length} cookies` })
    } catch (error) {
        res.json({ success: false, error: error.message })
    }
})

app.post('/test-download', async (req, res) => {
    try {
        const { url } = req.body
        
        const command = [
            'yt-dlp',
            '--no-warnings',
            '--cookies cookies.txt',
            '--format "best[height<=720]/best"',
            '--get-title',
            '--get-duration',
            '--get-filename',
            `"${url}"`
        ].join(' ')
        
        const { stdout, stderr } = await execAsync(command, { timeout: 30000 })
        
        res.json({ 
            success: true, 
            output: `Command: ${command}\n\nOutput:\n${stdout}\n\nErrors:\n${stderr}` 
        })
    } catch (error) {
        res.json({ 
            success: false, 
            error: `Command failed:\n${error.message}\n\nStdout: ${error.stdout}\nStderr: ${error.stderr}` 
        })
    }
})

const options = {
    key: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/cert.pem'),
    ca: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/chain.pem')
}

https.createServer(options, app).listen(443, () => {
    console.log('YouTube Tester running on https://system.heatherx.site')
})
