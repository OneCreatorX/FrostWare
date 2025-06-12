// Importación correcta de Baileys
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
  MAX_SESSIONS: 10,
  AUTO_DELETE_AFTER_SEND: true,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()

const activeSessions = new Map()
const sessionStates = new Map()
const waitingQueue = []
const cookiesStorage = new Map()
const qrCodes = new Map()

const userAgents = [
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
  "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
]

function generateSecureSessionId() {
  const timestamp = Date.now().toString(36)
  const randomBytes = crypto.randomBytes(32).toString("hex")
  const hash = crypto
    .createHash("sha256")
    .update(timestamp + randomBytes)
    .digest("hex")
  return `ws_${timestamp}_${hash.substring(0, 48)}_${crypto.randomBytes(16).toString("hex")}`
}

function getRandomUserAgent() {
  return userAgents[Math.floor(Math.random() * userAgents.length)]
}

function convertJsonToNetscape(cookies) {
  console.log(`🍪 Converting ${cookies.length} cookies to Netscape format`)

  let netscapeFormat = "# Netscape HTTP Cookie File\n"
  netscapeFormat += "# This is a generated file! Do not edit.\n\n"

  let validCookies = 0

  cookies.forEach((cookie, index) => {
    try {
      const domain = cookie.domain || cookie.Domain || ""
      if (!domain) {
        console.log(`⚠️ Cookie ${index}: Missing domain, skipping`)
        return
      }

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
      } else if (typeof expiration === "string") {
        expiration = Math.floor(Number.parseFloat(expiration))
        if (isNaN(expiration)) {
          expiration = Math.floor(Date.now() / 1000) + 365 * 24 * 60 * 60
        }
      }

      const name = cookie.name || cookie.Name || ""
      const value = cookie.value || cookie.Value || ""

      if (!name) {
        console.log(`⚠️ Cookie ${index}: Missing name, skipping`)
        return
      }

      netscapeFormat += `${domain}\t${flag}\t${path}\t${secure}\t${expiration}\t${name}\t${value}\n`
      validCookies++

      if (name.includes("session") || name.includes("auth") || name.includes("login")) {
        console.log(`🔑 Found important cookie: ${name} for domain ${domain}`)
      }
    } catch (error) {
      console.error(`❌ Error processing cookie ${index}:`, error)
    }
  })

  console.log(`✅ Converted ${validCookies}/${cookies.length} cookies successfully`)
  return netscapeFormat
}

function validateCookies(cookiesData) {
  if (!cookiesData || typeof cookiesData !== "object") {
    throw new Error("Invalid cookies data: must be an object")
  }

  if (!cookiesData.cookies || !Array.isArray(cookiesData.cookies)) {
    throw new Error("Invalid cookies format: missing cookies array")
  }

  if (cookiesData.cookies.length === 0) {
    throw new Error("No cookies found in the file")
  }

  const youtubeCookies = cookiesData.cookies.filter(
    (cookie) =>
      (cookie.domain || cookie.Domain || "").includes("youtube") ||
      (cookie.domain || cookie.Domain || "").includes("google"),
  )

  if (youtubeCookies.length === 0) {
    console.log("⚠️ Warning: No YouTube/Google cookies found")
  } else {
    console.log(`🎯 Found ${youtubeCookies.length} YouTube/Google cookies`)
  }

  const importantCookies = cookiesData.cookies.filter((cookie) => {
    const name = (cookie.name || cookie.Name || "").toLowerCase()
    return (
      name.includes("session") ||
      name.includes("auth") ||
      name.includes("login") ||
      name.includes("sapisid") ||
      name.includes("hsid") ||
      name.includes("ssid")
    )
  })

  console.log(`🔐 Found ${importantCookies.length} authentication cookies`)

  return true
}

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

app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const mediaDir = join(__dirname, "media")
const uploadsDir = join(__dirname, "uploads")
const tempDir = join(__dirname, "temp")
const cookiesDir = join(__dirname, "cookies")

try {
  fs.mkdirSync(mediaDir, { recursive: true })
  fs.mkdirSync(uploadsDir, { recursive: true })
  fs.mkdirSync("public", { recursive: true })
  fs.mkdirSync("sessions", { recursive: true })
  fs.mkdirSync(tempDir, { recursive: true })
  fs.mkdirSync(cookiesDir, { recursive: true })
} catch (err) {
  console.error("Error creating directories:", err)
}

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

    console.log(`🍪 Processing cookies for session ${sessionId}`)

    const cookiesData = JSON.parse(fs.readFileSync(req.file.path, "utf8"))

    validateCookies(cookiesData)

    const netscapeCookies = convertJsonToNetscape(cookiesData.cookies)
    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    fs.writeFileSync(sessionCookiesPath, netscapeCookies)

    const sessionJsonPath = join(cookiesDir, `${sessionId}.json`)
    fs.writeFileSync(sessionJsonPath, JSON.stringify(cookiesData, null, 2))

    cookiesStorage.set(sessionId, cookiesData)

    fs.unlinkSync(req.file.path)

    console.log(`✅ Cookies saved for session ${sessionId}`)
    console.log(`📄 Netscape file: ${sessionCookiesPath}`)

    res.json({
      success: true,
      message: `Cookies loaded: ${cookiesData.cookies.length} cookies from ${cookiesData.url}`,
    })
  } catch (error) {
    console.error("❌ Error processing cookies:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/upload", upload.single("file"), async (req, res) => {
  try {
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!req.file) {
      return res.json({ success: false, error: "No file uploaded" })
    }

    const sock = activeSessions.get(sessionId)
    const file = req.file
    const fileBuffer = fs.readFileSync(file.path)

    await sock.sendMessage(sock.user.id, {
      document: fileBuffer,
      fileName: file.originalname,
      mimetype: file.mimetype,
    })

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      fs.unlinkSync(file.path)
    }

    console.log(`📎 File sent: ${file.originalname}`)
    res.json({ success: true, message: "File sent successfully", filename: file.originalname })
  } catch (error) {
    console.error("❌ Error uploading file:", error)
    res.json({ success: false, error: error.message })
  }
})

app.post("/api/download", async (req, res) => {
  try {
    const { url } = req.body
    const sessionId = req.headers["session-id"] || req.query.session

    if (!sessionId || !activeSessions.has(sessionId)) {
      return res.json({ success: false, error: "Invalid session" })
    }

    if (!url) {
      return res.json({ success: false, error: "URL is required" })
    }

    console.log(`⬇️ Download request for session ${sessionId}: ${url}`)

    const sock = activeSessions.get(sessionId)
    const userAgent = getRandomUserAgent()
    const tempFilePath = join(tempDir, `${Date.now()}_${crypto.randomBytes(8).toString("hex")}`)

    // Comando simplificado de yt-dlp compatible con versiones antiguas
    const ytDlpCommand = [
      "yt-dlp",
      "--no-warnings",
      "--ignore-errors",
      `--user-agent "${userAgent}"`,
      '--format "best[height<=720]/best"',
    ]

    const sessionCookiesPath = join(cookiesDir, `${sessionId}.txt`)
    if (fs.existsSync(sessionCookiesPath)) {
      console.log(`🍪 Using cookies for session ${sessionId}`)

      const cookiesContent = fs.readFileSync(sessionCookiesPath, "utf8")
      console.log(`📄 Cookies file size: ${cookiesContent.length} bytes`)

      const cookieLines = cookiesContent.split("\n").filter((line) => line.trim() && !line.startsWith("#"))
      console.log(`🔢 Valid cookie lines: ${cookieLines.length}`)

      ytDlpCommand.push(`--cookies "${sessionCookiesPath}"`)
    } else {
      console.log(`⚠️ No cookies found for session ${sessionId}`)
      if (url.includes("youtube.com") || url.includes("youtu.be")) {
        return res.json({
          success: false,
          error: "YouTube cookies required. Please upload J2Team cookies first.",
        })
      }
    }

    ytDlpCommand.push(`-o "${tempFilePath}.%(ext)s"`)
    ytDlpCommand.push(`"${url}"`)

    const finalCommand = ytDlpCommand.join(" ")
    console.log(`🔧 Executing: ${finalCommand}`)

    const { stdout, stderr } = await execAsync(finalCommand, {
      timeout: 300000,
      maxBuffer: 1024 * 1024 * 10,
    })

    console.log(`📋 yt-dlp stdout:`, stdout)
    if (stderr) {
      console.log(`⚠️ yt-dlp stderr:`, stderr)
    }

    const files = fs.readdirSync(tempDir).filter((f) => f.startsWith(path.basename(tempFilePath)))
    if (files.length === 0) {
      throw new Error("Download failed - no file created. Check if URL is valid and accessible.")
    }

    console.log(`📁 Downloaded files: ${files.join(", ")}`)

    const videoFile = files.find((f) => f.match(/\.(mp4|mkv|webm|avi|mov)$/i))
    const mainFile = videoFile || files[0]

    const downloadedFile = join(tempDir, mainFile)
    const fileStats = fs.statSync(downloadedFile)
    console.log(`📊 File size: ${(fileStats.size / 1024 / 1024).toFixed(2)} MB`)

    const fileBuffer = fs.readFileSync(downloadedFile)

    const fileExtension = path.extname(mainFile).toLowerCase()
    let messageOptions = {}

    if ([".mp4", ".mkv", ".webm", ".avi", ".mov"].includes(fileExtension)) {
      messageOptions = {
        video: fileBuffer,
        caption: `Downloaded from: ${url}`,
        mimetype: "video/mp4",
      }
    } else if ([".mp3", ".wav", ".ogg", ".m4a", ".aac"].includes(fileExtension)) {
      messageOptions = {
        audio: fileBuffer,
        mimetype: "audio/mp4",
      }
    } else if ([".jpg", ".jpeg", ".png", ".gif", ".webp"].includes(fileExtension)) {
      messageOptions = {
        image: fileBuffer,
        caption: `Downloaded from: ${url}`,
      }
    } else {
      messageOptions = {
        document: fileBuffer,
        fileName: mainFile,
        mimetype: getMimeType(mainFile),
      }
    }

    await sock.sendMessage(sock.user.id, messageOptions)

    if (CONFIG.AUTO_DELETE_AFTER_SEND) {
      files.forEach((file) => {
        try {
          fs.unlinkSync(join(tempDir, file))
        } catch (err) {
          console.error(`Error deleting ${file}:`, err)
        }
      })
    }

    console.log(`✅ Downloaded and sent: ${mainFile}`)
    res.json({
      success: true,
      message: "Downloaded and sent successfully",
      filename: mainFile,
      size: `${(fileStats.size / 1024 / 1024).toFixed(2)} MB`,
    })
  } catch (error) {
    console.error("❌ Error downloading:", error)

    let errorMessage = error.message
    if (error.message.includes("Sign in to confirm")) {
      errorMessage = "YouTube requires authentication. Please upload valid J2Team cookies."
    } else if (error.message.includes("Video unavailable")) {
      errorMessage = "Video is unavailable or private."
    } else if (error.message.includes("No video formats found")) {
      errorMessage = "No downloadable video formats found."
    }

    res.json({ success: false, error: errorMessage })
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
      return res.json({ success: false, error: "Message is required" })
    }

    const sock = activeSessions.get(sessionId)
    await sock.sendMessage(sock.user.id, { text: message })

    console.log(`💬 Message sent: ${message.substring(0, 50)}...`)
    res.json({ success: true, message: "Message sent successfully" })
  } catch (error) {
    console.error("❌ Error sending message:", error)
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
      const position = waitingQueue.indexOf(sessionId)
      if (position === -1) {
        waitingQueue.push(sessionId)
      }
      return res.json({
        status: "waiting",
        position: waitingQueue.indexOf(sessionId) + 1,
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
      console.log(`🔄 Creating new WhatsApp session: ${sessionId}`)
      createWhatsAppSession(sessionId)
    }

    res.json({ status: "initializing" })
  } catch (error) {
    console.error("❌ Error checking status:", error)
    res.json({ success: false, error: error.message })
  }
})

app.use("/media", express.static(mediaDir))

function getMimeType(filename) {
  const ext = path.extname(filename).toLowerCase()
  const mimeTypes = {
    ".jpg": "image/jpeg",
    ".jpeg": "image/jpeg",
    ".png": "image/png",
    ".gif": "image/gif",
    ".webp": "image/webp",
    ".mp4": "video/mp4",
    ".avi": "video/x-msvideo",
    ".mov": "video/quicktime",
    ".mkv": "video/x-matroska",
    ".webm": "video/webm",
    ".mp3": "audio/mpeg",
    ".wav": "audio/wav",
    ".ogg": "audio/ogg",
    ".m4a": "audio/mp4",
    ".flac": "audio/flac",
    ".pdf": "application/pdf",
    ".doc": "application/msword",
    ".docx": "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    ".txt": "text/plain",
    ".zip": "application/zip",
    ".rar": "application/x-rar-compressed",
  }
  return mimeTypes[ext] || "application/octet-stream"
}

function createWhatsAppSession(sessionId) {
  const sessionDir = join(__dirname, "sessions", sessionId)
  fs.mkdirSync(sessionDir, { recursive: true })

  console.log(`📱 Initializing WhatsApp session: ${sessionId}`)

  useMultiFileAuthState(sessionDir)
    .then(({ state, saveCreds }) => {
      const sock = makeWASocket({
        auth: state,
        printQRInTerminal: false,
        browser: Browsers.macOS("Desktop"),
        defaultQueryTimeoutMs: 60000,
      })

      sock.ev.on("connection.update", async (update) => {
        const { connection, lastDisconnect, qr } = update

        if (qr) {
          console.log(`📱 QR code generated for session: ${sessionId}`)
          const qrDataURL = await qrcode.toDataURL(qr, { scale: 8 })
          qrCodes.set(sessionId, qrDataURL)
        }

        if (connection === "close") {
          const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
          console.log(`❌ Connection closed for session ${sessionId}:`, lastDisconnect?.error)

          activeSessions.delete(sessionId)
          qrCodes.delete(sessionId)

          if (shouldReconnect) {
            console.log(`🔄 Reconnecting session ${sessionId} in 5 seconds...`)
            setTimeout(() => createWhatsAppSession(sessionId), 5000)
          } else {
            console.log(`🚫 Session ${sessionId} permanently closed (logout)`)
            try {
              fs.rmSync(sessionDir, { recursive: true, force: true })
            } catch (err) {
              console.error("Error cleaning session directory:", err)
            }
          }
        } else if (connection === "open") {
          console.log(`✅ WhatsApp connected successfully for session: ${sessionId}`)
          console.log(`👤 User: ${sock.user.name} (${sock.user.id})`)

          qrCodes.delete(sessionId)

          const queueIndex = waitingQueue.indexOf(sessionId)
          if (queueIndex !== -1) {
            waitingQueue.splice(queueIndex, 1)
          }
        }
      })

      sock.ev.on("creds.update", saveCreds)

      sock.ev.on("messages.upsert", async (m) => {
        if (m.type !== "notify") return

        for (const msg of m.messages) {
          if (msg.key.fromMe) {
            console.log(`📤 Message sent from session ${sessionId}: ${msg.message?.conversation || "Media"}`)
          }
        }
      })

      activeSessions.set(sessionId, sock)

      sessionStates.set(sessionId, {
        lastActivity: Date.now(),
      })

      console.log(`🎯 Session ${sessionId} initialized successfully`)
    })
    .catch((error) => {
      console.error(`❌ Error creating WhatsApp session ${sessionId}:`, error)

      activeSessions.delete(sessionId)
      qrCodes.delete(sessionId)

      setTimeout(() => {
        console.log(`🔄 Retrying session creation for ${sessionId}`)
        createWhatsAppSession(sessionId)
      }, 10000)
    })
}

try {
  const options = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(options, app)

  server.listen(CONFIG.PORT, () => {
    console.log(`🚀 HTTPS Server running on https://${CONFIG.DOMAIN}`)
    console.log(`📱 WhatsApp YouTube Interface available`)
    console.log(`⚙️  Max sessions: ${CONFIG.MAX_SESSIONS}`)
    console.log(`🔧 Auto-delete files: ${CONFIG.AUTO_DELETE_AFTER_SEND}`)
    console.log(`🍪 Cookies directory: ${cookiesDir}`)
  })
} catch (error) {
  console.error("❌ Error starting HTTPS server:", error)
  console.log("⚠️  Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`🚀 HTTP Server running on http://0.0.0.0:${CONFIG.PORT}`)
    console.log("⚠️  WARNING: Running without HTTPS")
  })
}

setInterval(
  () => {
    const now = Date.now()
    const maxInactiveTime = 24 * 60 * 60 * 1000

    for (const [sessionId, sessionState] of sessionStates) {
      if (now - sessionState.lastActivity > maxInactiveTime) {
        console.log(`🧹 Cleaning up inactive session: ${sessionId}`)

        if (activeSessions.has(sessionId)) {
          try {
            const sock = activeSessions.get(sessionId)
            sock.end()
          } catch (err) {
            console.error("Error closing socket:", err)
          }
          activeSessions.delete(sessionId)
        }

        sessionStates.delete(sessionId)
        qrCodes.delete(sessionId)

        try {
          const cookiesPath = join(cookiesDir, `${sessionId}.txt`)
          const jsonPath = join(cookiesDir, `${sessionId}.json`)
          if (fs.existsSync(cookiesPath)) fs.unlinkSync(cookiesPath)
          if (fs.existsSync(jsonPath)) fs.unlinkSync(jsonPath)
        } catch (err) {
          console.error("Error cleaning cookies:", err)
        }
      }
    }
  },
  60 * 60 * 1000,
)

process.on("uncaughtException", (err) => {
  console.error("❌ Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("❌ Unhandled rejection:", err)
})

process.on("SIGINT", () => {
  console.log("\n🛑 Shutting down gracefully...")

  for (const [sessionId, sock] of activeSessions) {
    try {
      console.log(`📱 Closing session: ${sessionId}`)
      sock.end()
    } catch (err) {
      console.error(`Error closing session ${sessionId}:`, err)
    }
  }

  process.exit(0)
})

console.log("🎉 WhatsApp YouTube Interface initialized!")
console.log("📋 Features:")
console.log("   ✅ Simplified yt-dlp command for compatibility")
console.log("   ✅ Fixed Baileys import")
console.log("   ✅ Enhanced cookie handling")
console.log("   ✅ YouTube authentication support")
