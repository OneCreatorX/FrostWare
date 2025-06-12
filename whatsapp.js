import express from 'express'
import multer from 'multer'
import fs from 'fs'
import https from 'https'
import { exec } from 'child_process'

const app = express()
const upload = multer({ dest: 'uploads/' })

const sslOptions = {
  key: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/cert.pem'),
  ca: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/chain.pem')
}

app.use(express.static('public'))
app.use(express.json())

function convertCookies(jsonCookies) {
  const cookies = JSON.parse(jsonCookies)
  let netscapeFormat = '# Netscape HTTP Cookie File\n'
  
  cookies.cookies.forEach(cookie => {
    const domain = cookie.domain
    const flag = cookie.hostOnly ? 'FALSE' : 'TRUE'
    const path = cookie.path
    const secure = cookie.secure ? 'TRUE' : 'FALSE'
    const expiration = Math.floor(cookie.expirationDate || 0)
    const name = cookie.name
    const value = cookie.value
    
    netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
  })
  
  return netscapeFormat
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
            input, textarea, button { margin: 10px 0; padding: 10px; width: 100%; }
            .result { background: #f5f5f5; padding: 20px; margin: 20px 0; }
            .error { background: #ffe6e6; }
            .success { background: #e6ffe6; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>YouTube Cookie Tester</h1>
            
            <h3>Instrucciones:</h3>
            <p>1. Instala la extensión "EditThisCookie" (no J2Team)</p>
            <p>2. Ve a YouTube y asegúrate de estar logueado</p>
            <p>3. Abre EditThisCookie y exporta como JSON</p>
            <p>4. Pega el JSON aquí y prueba</p>
            
            <form id="testForm">
                <h3>Cookies JSON:</h3>
                <textarea id="cookies" rows="10" placeholder="Pega aquí el JSON de cookies de EditThisCookie"></textarea>
                
                <h3>URL de YouTube:</h3>
                <input type="text" id="url" value="https://youtu.be/eypt-w22cto" />
                
                <button type="submit">Probar Descarga</button>
            </form>
            
            <div id="result"></div>
        </div>

        <script>
            document.getElementById('testForm').onsubmit = async (e) => {
                e.preventDefault()
                
                const cookies = document.getElementById('cookies').value
                const url = document.getElementById('url').value
                const resultDiv = document.getElementById('result')
                
                resultDiv.innerHTML = '<div class="result">Probando...</div>'
                
                try {
                    const response = await fetch('/test', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ cookies, url })
                    })
                    
                    const result = await response.json()
                    
                    if (result.success) {
                        resultDiv.innerHTML = '<div class="result success"><h3>✅ Éxito!</h3><pre>' + result.output + '</pre></div>'
                    } else {
                        resultDiv.innerHTML = '<div class="result error"><h3>❌ Error:</h3><pre>' + result.error + '</pre></div>'
                    }
                } catch (error) {
                    resultDiv.innerHTML = '<div class="result error"><h3>❌ Error de conexión:</h3><pre>' + error.message + '</pre></div>'
                }
            }
        </script>
    </body>
    </html>
  `)
})

app.post('/test', (req, res) => {
  const { cookies, url } = req.body
  
  if (!cookies || !url) {
    return res.json({ success: false, error: 'Faltan cookies o URL' })
  }
  
  try {
    const cookieData = JSON.parse(cookies)
    
    const requiredCookies = ['SAPISID', 'APISID', 'SID', 'HSID', 'SSID']
    const availableCookies = cookieData.cookies.map(c => c.name)
    const missingCookies = requiredCookies.filter(c => !availableCookies.includes(c))
    
    if (missingCookies.length > 0) {
      return res.json({ 
        success: false, 
        error: `Faltan cookies críticas: ${missingCookies.join(', ')}\n\nCookies disponibles: ${availableCookies.join(', ')}\n\nNecesitas usar EditThisCookie y estar completamente logueado en YouTube.` 
      })
    }
    
    const netscapeCookies = convertCookies(cookies)
    fs.writeFileSync('cookies.txt', netscapeCookies)
    
    const command = `yt-dlp --cookies cookies.txt --get-title --get-duration "${url}"`
    
    exec(command, (error, stdout, stderr) => {
      if (error) {
        res.json({ success: false, error: stderr || error.message })
      } else {
        res.json({ success: true, output: stdout })
      }
    })
    
  } catch (error) {
    res.json({ success: false, error: 'JSON de cookies inválido: ' + error.message })
  }
})

https.createServer(sslOptions, app).listen(443, () => {
  console.log('Server running on https://system.heatherx.site')
})
