import express from "express"
import multer from "multer"
import { execSync } from "child_process"
import fs from "fs"
import https from "https"
import path from "path"

const app = express()
app.use(express.static("."))
app.use(express.json())

// Crear directorio de descargas si no existe
if (!fs.existsSync("downloads")) {
  fs.mkdirSync("downloads")
}

const upload = multer({ dest: "uploads/" })

function convertCookies(cookiesJson) {
  const cookies = JSON.parse(cookiesJson)
  let netscapeFormat = "# Netscape HTTP Cookie File\n"

  cookies.cookies.forEach((cookie) => {
    const expires = Math.floor(cookie.expirationDate || 0)
    const domain = cookie.domain.startsWith(".") ? cookie.domain : `.${cookie.domain}`
    const httpOnly = cookie.httpOnly ? "TRUE" : "FALSE"
    const secure = cookie.secure ? "TRUE" : "FALSE"
    const path = cookie.path || "/"

    netscapeFormat += `${domain}\tTRUE\t${path}\t${secure}\t${expires}\t${cookie.name}\t${cookie.value}\n`
  })

  return netscapeFormat
}

function analyzeCookies(cookiesJson) {
  const cookies = JSON.parse(cookiesJson)
  const required = ["SAPISID", "APISID", "SID", "HSID", "SSID", "__Secure-1PSID", "__Secure-3PSID"]
  const found = cookies.cookies.map((c) => c.name)
  const missing = required.filter((name) => !found.includes(name))

  return {
    total: found.length,
    found: found,
    missing: missing,
    hasAuth: missing.length === 0,
  }
}

app.get("/", (req, res) => {
  res.send(`
<!DOCTYPE html>
<html>
<head>
    <title>YouTube Downloader</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .container { 
            max-width: 900px; 
            margin: 0 auto;
            background: white;
            border-radius: 15px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
        }
        h1 { 
            color: #333; 
            text-align: center;
            margin-bottom: 30px;
            font-size: 2.5em;
        }
        .section {
            margin: 30px 0;
            padding: 20px;
            border: 1px solid #e0e0e0;
            border-radius: 10px;
            background: #fafafa;
        }
        textarea, input[type="text"] { 
            width: 100%; 
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 14px;
            box-sizing: border-box;
        }
        textarea { height: 100px; }
        button { 
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white; 
            padding: 12px 25px; 
            border: none; 
            border-radius: 8px;
            margin: 10px 5px; 
            cursor: pointer;
            font-size: 14px;
            font-weight: bold;
            transition: transform 0.2s;
        }
        button:hover {
            transform: translateY(-2px);
        }
        button:disabled {
            background: #ccc;
            cursor: not-allowed;
            transform: none;
        }
        .result { 
            background: #f5f5f5; 
            padding: 15px; 
            margin: 15px 0; 
            border-radius: 8px;
            border-left: 4px solid #007cba;
        }
        .error { 
            background: #ffebee; 
            color: #c62828; 
            border-left-color: #c62828;
        }
        .success { 
            background: #e8f5e8; 
            color: #2e7d32; 
            border-left-color: #2e7d32;
        }
        .download-options {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            margin: 15px 0;
        }
        .download-btn {
            background: #28a745;
        }
        .download-btn.audio {
            background: #17a2b8;
        }
        .progress {
            display: none;
            margin: 10px 0;
        }
        .progress-bar {
            width: 100%;
            height: 20px;
            background: #e0e0e0;
            border-radius: 10px;
            overflow: hidden;
        }
        .progress-fill {
            height: 100%;
            background: linear-gradient(45deg, #28a745, #20c997);
            width: 0%;
            transition: width 0.3s;
        }
        .video-info {
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin: 10px 0;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎥 YouTube Downloader</h1>
        
        <div class="section">
            <h3>📁 1. Subir Cookies JSON</h3>
            <input type="file" id="cookieFile" accept=".json,.txt">
            <button onclick="uploadCookies()">Analizar Cookies</button>
            <div id="cookieResult"></div>
        </div>
        
        <div class="section">
            <h3>🔍 2. Información del Video</h3>
            <input type="text" id="youtubeUrl" placeholder="https://youtu.be/... o https://www.youtube.com/watch?v=...">
            <button onclick="getVideoInfo()">Obtener Información</button>
            <div id="videoInfo"></div>
        </div>
        
        <div class="section">
            <h3>⬇️ 3. Descargar</h3>
            <div class="download-options">
                <button class="download-btn" onclick="downloadVideo('720p')">📹 Video 720p</button>
                <button class="download-btn" onclick="downloadVideo('1080p')">📹 Video 1080p</button>
                <button class="download-btn" onclick="downloadVideo('best')">📹 Mejor Calidad</button>
                <button class="download-btn audio" onclick="downloadAudio('mp3')">🎵 Audio MP3</button>
                <button class="download-btn audio" onclick="downloadAudio('m4a')">🎵 Audio M4A</button>
            </div>
            <div class="progress" id="downloadProgress">
                <div class="progress-bar">
                    <div class="progress-fill" id="progressFill"></div>
                </div>
                <div id="progressText">Preparando descarga...</div>
            </div>
            <div id="downloadResult"></div>
        </div>
    </div>

    <script>
        let currentVideoId = null;
        
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
            html += '<h4>📊 Análisis de Cookies:</h4>'
            html += '<p><strong>Total cookies:</strong> ' + result.total + '</p>'
            
            if (result.missing.length > 0) {
                html += '<p class="error">❌ Cookies faltantes (CRÍTICAS): ' + result.missing.join(', ') + '</p>'
                html += '<p class="error">⚠️ No tienes las cookies de autenticación necesarias</p>'
            } else {
                html += '<p class="success">✅ Tienes todas las cookies necesarias para descargar</p>'
            }
            
            html += '</div>'
            document.getElementById('cookieResult').innerHTML = html
        }
        
        async function getVideoInfo() {
            const url = document.getElementById('youtubeUrl').value
            if (!url) return alert('Ingresa una URL de YouTube')
            
            document.getElementById('videoInfo').innerHTML = '<div class="result">🔍 Obteniendo información...</div>'
            
            const response = await fetch('/video-info', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url })
            })
            
            const result = await response.json()
            
            if (result.success) {
                currentVideoId = result.videoId;
                let html = '<div class="result success video-info">'
                html += '<h4>📺 ' + result.title + '</h4>'
                html += '<p><strong>⏱️ Duración:</strong> ' + result.duration + '</p>'
                html += '<p><strong>👀 Vistas:</strong> ' + (result.views || 'N/A') + '</p>'
                html += '<p><strong>📅 Subido:</strong> ' + (result.uploadDate || 'N/A') + '</p>'
                if (result.thumbnail) {
                    html += '<img src="' + result.thumbnail + '" style="max-width: 300px; border-radius: 8px; margin: 10px 0;">'
                }
                html += '</div>'
                document.getElementById('videoInfo').innerHTML = html
            } else {
                document.getElementById('videoInfo').innerHTML = '<div class="result error">❌ Error: ' + result.error + '</div>'
            }
        }
        
        async function downloadVideo(quality) {
            if (!currentVideoId) {
                return alert('Primero obtén la información del video')
            }
            
            const url = document.getElementById('youtubeUrl').value
            startDownload()
            
            const response = await fetch('/download-video', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url, quality })
            })
            
            const result = await response.json()
            finishDownload(result, 'video')
        }
        
        async function downloadAudio(format) {
            if (!currentVideoId) {
                return alert('Primero obtén la información del video')
            }
            
            const url = document.getElementById('youtubeUrl').value
            startDownload()
            
            const response = await fetch('/download-audio', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ url, format })
            })
            
            const result = await response.json()
            finishDownload(result, 'audio')
        }
        
        function startDownload() {
            document.getElementById('downloadProgress').style.display = 'block'
            document.getElementById('progressText').textContent = 'Iniciando descarga...'
            simulateProgress()
        }
        
        function simulateProgress() {
            let progress = 0
            const interval = setInterval(() => {
                progress += Math.random() * 15
                if (progress > 90) progress = 90
                document.getElementById('progressFill').style.width = progress + '%'
                document.getElementById('progressText').textContent = 'Descargando... ' + Math.round(progress) + '%'
            }, 500)
            
            // Guardar el interval para poder limpiarlo después
            window.downloadInterval = interval
        }
        
        function finishDownload(result, type) {
            clearInterval(window.downloadInterval)
            document.getElementById('progressFill').style.width = '100%'
            document.getElementById('downloadProgress').style.display = 'none'
            
            let html = '<div class="result ' + (result.success ? 'success' : 'error') + '">'
            
            if (result.success) {
                html += '<h4>✅ Descarga completada</h4>'
                html += '<p><strong>Archivo:</strong> ' + result.filename + '</p>'
                html += '<p><strong>Tamaño:</strong> ' + result.size + '</p>'
                html += '<a href="/download/' + encodeURIComponent(result.filename) + '" download>'
                html += '<button class="download-btn">📥 Descargar Archivo</button></a>'
            } else {
                html += '<h4>❌ Error en la descarga</h4>'
                html += '<pre>' + result.error + '</pre>'
            }
            
            html += '</div>'
            document.getElementById('downloadResult').innerHTML = html
        }
    </script>
</body>
</html>
    `)
})

app.post("/analyze-cookies", upload.single("cookies"), (req, res) => {
  try {
    const cookiesContent = fs.readFileSync(req.file.path, "utf8")
    const analysis = analyzeCookies(cookiesContent)

    const netscapeFormat = convertCookies(cookiesContent)
    fs.writeFileSync("cookies.txt", netscapeFormat)

    fs.unlinkSync(req.file.path)

    res.json(analysis)
  } catch (error) {
    res.json({ error: error.message })
  }
})

app.post("/video-info", (req, res) => {
  try {
    const { url } = req.body

    const cmd = `yt-dlp --no-warnings --cookies cookies.txt --get-title --get-duration --get-id --get-thumbnail --print "%(view_count)s" --print "%(upload_date)s" "${url}"`

    const result = execSync(cmd, { encoding: "utf8", timeout: 30000 })
    const lines = result.trim().split("\n")

    res.json({
      success: true,
      title: lines[0] || "Título no disponible",
      duration: lines[1] || "N/A",
      videoId: lines[2] || null,
      thumbnail: lines[3] || null,
      views: lines[4] || "N/A",
      uploadDate: lines[5] || "N/A",
    })
  } catch (error) {
    res.json({
      success: false,
      error: error.message,
    })
  }
})

app.post("/download-video", (req, res) => {
  try {
    const { url, quality } = req.body

    let format = "best[height<=720]/best"
    if (quality === "1080p") {
      format = "best[height<=1080]/best"
    } else if (quality === "best") {
      format = "best"
    }

    const outputTemplate = "downloads/%(title)s.%(ext)s"
    const cmd = `yt-dlp --no-warnings --cookies cookies.txt --format "${format}" -o "${outputTemplate}" "${url}"`

    const result = execSync(cmd, { encoding: "utf8", timeout: 300000 }) // 5 minutos timeout

    // Obtener el nombre del archivo descargado
    const filenameCmd = `yt-dlp --no-warnings --cookies cookies.txt --format "${format}" --get-filename -o "${outputTemplate}" "${url}"`
    const filename = execSync(filenameCmd, { encoding: "utf8" }).trim()
    const basename = path.basename(filename)

    // Obtener el tamaño del archivo
    const stats = fs.statSync(filename)
    const fileSizeInBytes = stats.size
    const fileSizeInMB = (fileSizeInBytes / (1024 * 1024)).toFixed(2)

    res.json({
      success: true,
      filename: basename,
      size: fileSizeInMB + " MB",
      output: result,
    })
  } catch (error) {
    res.json({
      success: false,
      error: error.message + "\n\nStdout: " + (error.stdout || "") + "\nStderr: " + (error.stderr || ""),
    })
  }
})

app.post("/download-audio", (req, res) => {
  try {
    const { url, format } = req.body

    const outputTemplate = `downloads/%(title)s.${format}`
    const cmd = `yt-dlp --no-warnings --cookies cookies.txt --extract-audio --audio-format ${format} -o "${outputTemplate}" "${url}"`

    const result = execSync(cmd, { encoding: "utf8", timeout: 300000 }) // 5 minutos timeout

    // Obtener el nombre del archivo descargado
    const filenameCmd = `yt-dlp --no-warnings --cookies cookies.txt --extract-audio --audio-format ${format} --get-filename -o "${outputTemplate}" "${url}"`
    const filename = execSync(filenameCmd, { encoding: "utf8" }).trim()
    const basename = path.basename(filename)

    // Obtener el tamaño del archivo
    const stats = fs.statSync(filename)
    const fileSizeInBytes = stats.size
    const fileSizeInMB = (fileSizeInBytes / (1024 * 1024)).toFixed(2)

    res.json({
      success: true,
      filename: basename,
      size: fileSizeInMB + " MB",
      output: result,
    })
  } catch (error) {
    res.json({
      success: false,
      error: error.message + "\n\nStdout: " + (error.stdout || "") + "\nStderr: " + (error.stderr || ""),
    })
  }
})

// Endpoint para servir archivos descargados
app.get("/download/:filename", (req, res) => {
  try {
    const filename = decodeURIComponent(req.params.filename)
    const filepath = path.join("downloads", filename)

    if (!fs.existsSync(filepath)) {
      return res.status(404).json({ error: "Archivo no encontrado" })
    }

    res.download(filepath, filename, (err) => {
      if (err) {
        console.error("Error al descargar:", err)
      }
    })
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// Endpoint para limpiar archivos antiguos (opcional)
app.post("/cleanup", (req, res) => {
  try {
    const files = fs.readdirSync("downloads")
    let deletedCount = 0

    files.forEach((file) => {
      const filepath = path.join("downloads", file)
      const stats = fs.statSync(filepath)
      const ageInHours = (Date.now() - stats.mtime.getTime()) / (1000 * 60 * 60)

      // Eliminar archivos de más de 24 horas
      if (ageInHours > 24) {
        fs.unlinkSync(filepath)
        deletedCount++
      }
    })

    res.json({ success: true, deletedFiles: deletedCount })
  } catch (error) {
    res.json({ success: false, error: error.message })
  }
})

const sslOptions = {
  key: fs.readFileSync("/etc/letsencrypt/live/system.heatherx.site/privkey.pem"),
  cert: fs.readFileSync("/etc/letsencrypt/live/system.heatherx.site/cert.pem"),
  ca: fs.readFileSync("/etc/letsencrypt/live/system.heatherx.site/chain.pem"),
}

https.createServer(sslOptions, app).listen(443, () => {
  console.log("🚀 YouTube Downloader running on https://system.heatherx.site")
  console.log("📁 Downloads will be saved to ./downloads/")
})
