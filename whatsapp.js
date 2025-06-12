import express from 'express'
import multer from 'multer'
import { execSync } from 'child_process'
import fs from 'fs'
import https from 'https'

const app = express()
app.use(express.static('.'))
app.use(express.json())

const upload = multer({ dest: 'uploads/' })

function convertCookies(cookiesJson) {
    const cookies = JSON.parse(cookiesJson)
    let netscapeFormat = '# Netscape HTTP Cookie File\n'
    
    cookies.cookies.forEach(cookie => {
        const expires = Math.floor(cookie.expirationDate || 0)
        const domain = cookie.domain.startsWith('.') ? cookie.domain : `.${cookie.domain}`
        const httpOnly = cookie.httpOnly ? 'TRUE' : 'FALSE'
        const secure = cookie.secure ? 'TRUE' : 'FALSE'
        const path = cookie.path || '/'
        
        netscapeFormat += `${domain}\tTRUE\t${path}\t${secure}\t${expires}\t${cookie.name}\t${cookie.value}\n`
    })
    
    return netscapeFormat
}

function analyzeCookies(cookiesJson) {
    const cookies = JSON.parse(cookiesJson)
    const required = ['SAPISID', 'APISID', 'SID', 'HSID', 'SSID', '__Secure-1PSID', '__Secure-3PSID']
    const found = cookies.cookies.map(c => c.name)
    const missing = required.filter(name => !found.includes(name))
    
    return {
        total: found.length,
        found: found,
        missing: missing,
        hasAuth: missing.length === 0
    }
}

app.get('/', (req, res) => {
    res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>YouTube Cookie Tester</title>
    <style>
        body { font-family: Arial; margin: 40px; }
        .container { max-width: 800px; }
        textarea { width: 100%; height: 100px; }
        button { background: #007cba; color: white; padding: 10px 20px; border: none; margin: 10px 0; }
        .result { background: #f5f5f5; padding: 15px; margin: 10px 0; }
        .error { background: #ffebee; color: #c62828; }
        .success { background: #e8f5e8; color: #2e7d32; }
    </style>
</head>
<body>
    <div class="container">
        <h1>YouTube Cookie Tester</h1>
        
        <h3>1. Subir Cookies JSON</h3>
        <input type="file" id="cookieFile" accept=".json,.txt">
        <button onclick="uploadCookies()">Analizar Cookies</button>
        
        <div id="cookieResult"></div>
        
        <h3>2. Probar Descarga</h3>
        <input type="text" id="youtubeUrl" placeholder="https://youtu.be/..." style="width: 60%;">
        <button onclick="testDownload()">Probar</button>
        
        <div id="testResult"></div>
    </div>

    <script>
        async function uploadCookies() {
            const file = document.getElementById('cookieFile').files[0]
            if (!file) return alert('Selecciona un archivo')
            
            const formData = new FormData()
            formData.append('cookies', file)
            
            const response = await fetch('/analyze-cookies', {
                method: 'POST',
                body: formData
            })
            
            const result = await response.json()
            
            let html = '<div class="result">'
            html += '<h4>Análisis de Cookies:</h4>'
            html += '<p>Total cookies: ' + result.total + '</p>'
            html += '<p>Cookies encontradas: ' + result.found.join(', ') + '</p>'
            
            if (result.missing.length > 0) {
                html += '<p class="error">Cookies faltantes (CRÍTICAS): ' + result.missing.join(', ') + '</p>'
                html += '<p class="error">⚠️ No tienes las cookies de autenticación necesarias</p>'
            } else {
                html += '<p class="success">✅ Tienes todas las cookies necesarias</p>'
            }
            
            html += '</div>'
            document.getElementById('cookieResult').innerHTML = html
        }
        
        async function testDownload() {
            const url = document.getElementById('youtubeUrl').value
            if (!url) return alert('Ingresa una URL')
            
            document.getElementById('testResult').innerHTML = '<div class="result">Probando...</div>'
            
            const response = await fetch('/test-download', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url })
            })
            
            const result = await response.json()
            
            let html = '<div class="result ' + (result.success ? 'success' : 'error') + '">'
            html += '<h4>Resultado:</h4>'
            html += '<pre>' + result.output + '</pre>'
            html += '</div>'
            
            document.getElementById('testResult').innerHTML = html
        }
    </script>
</body>
</html>
    `)
})

app.post('/analyze-cookies', upload.single('cookies'), (req, res) => {
    try {
        const cookiesContent = fs.readFileSync(req.file.path, 'utf8')
        const analysis = analyzeCookies(cookiesContent)
        
        const netscapeFormat = convertCookies(cookiesContent)
        fs.writeFileSync('cookies.txt', netscapeFormat)
        
        fs.unlinkSync(req.file.path)
        
        res.json(analysis)
    } catch (error) {
        res.json({ error: error.message })
    }
})

app.post('/test-download', (req, res) => {
    try {
        const { url } = req.body
        
        const cmd = `yt-dlp --no-warnings --cookies cookies.txt --format "best[height<=720]/best" --get-title --get-duration --get-filename "${url}"`
        
        const result = execSync(cmd, { encoding: 'utf8', timeout: 30000 })
        
        res.json({
            success: true,
            output: result
        })
    } catch (error) {
        res.json({
            success: false,
            output: error.message + '\n\nStdout: ' + (error.stdout || '') + '\nStderr: ' + (error.stderr || '')
        })
    }
})

const sslOptions = {
    key: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/privkey.pem'),
    cert: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/cert.pem'),
    ca: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/chain.pem')
}

https.createServer(sslOptions, app).listen(443, () => {
    console.log('Server running on https://system.heatherx.site')
})
