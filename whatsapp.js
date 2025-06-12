const express = require('express')
const multer = require('multer')
const fs = require('fs')
const https = require('https')
const { exec } = require('child_process')

const app = express()
const upload = multer({ dest: 'uploads/' })

const sslOptions = {
  key: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/privkey.pem'),
  cert: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/cert.pem'),
  ca: fs.readFileSync('/etc/letsencrypt/live/system.heatherx.site/chain.pem')
}

app.use(express.static('public'))
app.use(express.json())

function convertEditThisCookieFormat(jsonData) {
  let cookies
  
  if (Array.isArray(jsonData)) {
    cookies = jsonData
  } else if (jsonData.cookies && Array.isArray(jsonData.cookies)) {
    cookies = jsonData.cookies
  } else {
    throw new Error('Formato de cookies no reconocido')
  }
  
  let netscapeFormat = '# Netscape HTTP Cookie File\n'
  
  cookies.forEach(cookie => {
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
        <title>YouTube Cookie Tester - EditThisCookie</title>
        <style>
            body { font-family: Arial; margin: 40px; background: #f0f0f0; }
            .container { max-width: 900px; background: white; padding: 30px; border-radius: 10px; }
            input, textarea, button { margin: 10px 0; padding: 12px; width: 100%; box-sizing: border-box; }
            button { background: #007cba; color: white; border: none; cursor: pointer; font-size: 16px; }
            button:hover { background: #005a87; }
            .result { padding: 20px; margin: 20px 0; border-radius: 5px; }
            .error { background: #ffe6e6; border: 1px solid #ff9999; }
            .success { background: #e6ffe6; border: 1px solid #99ff99; }
            .warning { background: #fff3cd; border: 1px solid #ffeaa7; }
            .info { background: #e3f2fd; border: 1px solid #90caf9; }
            pre { white-space: pre-wrap; word-wrap: break-word; }
            .step { background: #f8f9fa; padding: 15px; margin: 10px 0; border-left: 4px solid #007cba; }
            .cookie-count { font-weight: bold; color: #007cba; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🍪 YouTube Cookie Tester</h1>
            <p><strong>Extensión recomendada:</strong> EditThisCookie v3</p>
            
            <div class="step">
                <h3>📋 Instrucciones:</h3>
                <ol>
                    <li><strong>Instala EditThisCookie:</strong> <a href="https://chromewebstore.google.com/detail/editthiscookie-v3/ojfebgpkimhlhcblbalbfjblapadhbol" target="_blank">Chrome Web Store</a></li>
                    <li><strong>Ve a YouTube</strong> y asegúrate de estar <strong>completamente logueado</strong></li>
                    <li><strong>Abre EditThisCookie</strong> (ícono en la barra de herramientas)</li>
                    <li><strong>Haz clic en la flecha →</strong> para copiar al portapapeles</li>
                    <li><strong>Pega aquí abajo</strong> y prueba la descarga</li>
                </ol>
            </div>
            
            <form id="testForm">
                <h3>🍪 Cookies JSON (EditThisCookie):</h3>
                <textarea id="cookies" rows="8" placeholder="Pega aquí el JSON copiado de EditThisCookie..."></textarea>
                
                <h3>🎬 URL de YouTube:</h3>
                <input type="text" id="url" value="https://youtu.be/eypt-w22cto" />
                
                <button type="submit">🚀 Probar Descarga</button>
            </form>
            
            <div id="result"></div>
        </div>

        <script>
            document.getElementById('testForm').onsubmit = async (e) => {
                e.preventDefault()
                
                const cookies = document.getElementById('cookies').value.trim()
                const url = document.getElementById('url').value.trim()
                const resultDiv = document.getElementById('result')
                
                if (!cookies) {
                    resultDiv.innerHTML = '<div class="result error">❌ Por favor pega las cookies de EditThisCookie</div>'
                    return
                }
                
                if (!url) {
                    resultDiv.innerHTML = '<div class="result error">❌ Por favor ingresa una URL de YouTube</div>'
                    return
                }
                
                resultDiv.innerHTML = '<div class="result info">🔄 Analizando cookies y probando descarga...</div>'
                
                try {
                    const response = await fetch('/test', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ cookies, url })
                    })
                    
                    const result = await response.json()
                    
                    if (result.success) {
                        resultDiv.innerHTML = \`
                            <div class="result success">
                                <h3>✅ ¡Descarga exitosa!</h3>
                                <p class="cookie-count">Cookies procesadas: \${result.cookieCount}</p>
                                <h4>📊 Información del video:</h4>
                                <pre>\${result.output}</pre>
                            </div>
                        \`
                    } else {
                        let errorClass = 'error'
                        if (result.error.includes('Faltan cookies')) {
                            errorClass = 'warning'
                        }
                        
                        resultDiv.innerHTML = \`
                            <div class="result \${errorClass}">
                                <h3>❌ Error en la descarga</h3>
                                <pre>\${result.error}</pre>
                            </div>
                        \`
                    }
                } catch (error) {
                    resultDiv.innerHTML = \`
                        <div class="result error">
                            <h3>❌ Error de conexión</h3>
                            <pre>\${error.message}</pre>
                        </div>
                    \`
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
    
    let cookieArray
    if (Array.isArray(cookieData)) {
      cookieArray = cookieData
    } else if (cookieData.cookies && Array.isArray(cookieData.cookies)) {
      cookieArray = cookieData.cookies
    } else {
      return res.json({ success: false, error: 'Formato de cookies no válido. Usa EditThisCookie para exportar.' })
    }
    
    const requiredCookies = ['SAPISID', 'APISID', 'SID', 'HSID', 'SSID']
    const availableCookies = cookieArray.map(c => c.name)
    const missingCookies = requiredCookies.filter(c => !availableCookies.includes(c))
    
    if (missingCookies.length > 0) {
      return res.json({ 
        success: false, 
        error: `🚫 Faltan cookies críticas para YouTube: ${missingCookies.join(', ')}\n\n📋 Cookies disponibles (${availableCookies.length}): ${availableCookies.join(', ')}\n\n💡 Solución:\n1. Asegúrate de estar LOGUEADO en YouTube\n2. Usa EditThisCookie (no J2Team)\n3. Exporta desde youtube.com (no desde google.com)` 
      })
    }
    
    const netscapeCookies = convertEditThisCookieFormat(cookieData)
    fs.writeFileSync('cookies.txt', netscapeCookies)
    
    const command = `yt-dlp --no-warnings --cookies cookies.txt --get-title --get-duration --get-filename "${url}"`
    
    exec(command, (error, stdout, stderr) => {
      fs.unlinkSync('cookies.txt')
      
      if (error) {
        res.json({ 
          success: false, 
          error: `Comando: ${command}\n\nError: ${stderr || error.message}\n\nStdout: ${stdout}`,
          cookieCount: cookieArray.length
        })
      } else {
        res.json({ 
          success: true, 
          output: stdout,
          cookieCount: cookieArray.length
        })
      }
    })
    
  } catch (error) {
    res.json({ success: false, error: 'JSON de cookies inválido: ' + error.message })
  }
})

https.createServer(sslOptions, app).listen(443, () => {
  console.log('🚀 YouTube Cookie Tester running on https://system.heatherx.site')
  console.log('📋 Usa EditThisCookie para exportar cookies de YouTube')
})
