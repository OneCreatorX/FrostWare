import makeWASocket, { Browsers, useMultiFileAuthState, downloadMediaMessage } from "@whiskeysockets/baileys"
import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs/promises"
import { createWriteStream } from "fs"
import bodyParser from "body-parser"

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const app = express()
const port = 3000
let qrCodeDataURL = null
let isConnected = false
let whatsappClient = null
const messageHistory = []
let state, saveCreds // Declare state and saveCreds outside the function

// Configuración de Express
app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

// Aseguramos que exista el directorio de medios
const mediaDir = join(__dirname, "media")
try {
  await fs.mkdir(mediaDir, { recursive: true })
} catch (err) {
  console.error("Error al crear directorio de medios:", err)
}

// Iniciar WhatsApp
async function startWhatsApp() {
  // Usar persistencia de sesión
  const auth = await useMultiFileAuthState("auth_info")
  state = auth.state
  saveCreds = auth.saveCreds

  const sock = makeWASocket({
    auth: state,
    browser: Browsers.ubuntu("WhatsApp-Web-Interface"),
    printQRInTerminal: true,
  })

  // Guardar credenciales cuando cambien
  sock.ev.on("creds.update", saveCreds)

  // Manejar actualizaciones de conexión
  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update

    if (qr) {
      console.log("Nuevo código QR generado")
      qrCodeDataURL = await qrcode.toDataURL(qr)
    }

    if (connection === "close") {
      const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
      console.log("Conexión cerrada:", lastDisconnect?.error)

      if (shouldReconnect) {
        console.log("Reconectando...")
        whatsappClient = await startWhatsApp()
      }
      isConnected = false
    } else if (connection === "open") {
      console.log("¡WhatsApp conectado exitosamente!")
      isConnected = true
      qrCodeDataURL = null // Limpiar QR una vez conectado
    }
  })

  // Escuchar mensajes nuevos
  sock.ev.on("messages.upsert", async ({ messages }) => {
    for (const message of messages) {
      // Procesar solo mensajes nuevos
      if (!message.key.fromMe && message.message) {
        console.log("Mensaje recibido:", message)

        // Guardar mensaje en historial
        const formattedMessage = {
          id: message.key.id,
          from: message.key.remoteJid,
          timestamp: message.messageTimestamp,
          text:
            message.message.conversation ||
            (message.message.extendedTextMessage && message.message.extendedTextMessage.text) ||
            "Contenido multimedia",
          hasMedia:
            !!message.message.imageMessage ||
            !!message.message.documentMessage ||
            !!message.message.audioMessage ||
            !!message.message.videoMessage,
          mediaType: message.message.imageMessage
            ? "image"
            : message.message.documentMessage
              ? "document"
              : message.message.audioMessage
                ? "audio"
                : message.message.videoMessage
                  ? "video"
                  : null,
        }

        // Descargar medios si existen
        if (formattedMessage.hasMedia) {
          try {
            const buffer = await downloadMediaMessage(
              message,
              "buffer",
              {},
              {
                logger: console,
                reuploadRequest: sock.updateMediaMessage,
              },
            )

            const fileName = `${message.key.id}.${formattedMessage.mediaType}`
            const filePath = join(mediaDir, fileName)

            const writeStream = createWriteStream(filePath)
            writeStream.write(buffer)
            writeStream.end()

            formattedMessage.mediaPath = `/media/${fileName}`
          } catch (error) {
            console.error("Error al descargar medio:", error)
          }
        }

        messageHistory.unshift(formattedMessage)
        // Limitar historial a 100 mensajes
        if (messageHistory.length > 100) messageHistory.pop()
      }
    }
  })

  whatsappClient = sock
  return sock
}

// Iniciar WhatsApp
await startWhatsApp()

// Ruta principal - Interfaz de usuario
app.get("/", (req, res) => {
  if (isConnected) {
    res.sendFile(join(__dirname, "public", "index.html"))
  } else if (qrCodeDataURL) {
    res.send(`
      <div style="text-align: center; font-family: Arial;">
        <h1>📱 Escanea con WhatsApp</h1>
        <img src="${qrCodeDataURL}" style="max-width: 300px;" />
        <p>Abre WhatsApp → Dispositivos vinculados → Vincular dispositivo</p>
        <button onclick="location.reload()">Actualizar QR</button>
      </div>
    `)
  } else {
    res.send(`
      <div style="text-align: center; font-family: Arial;">
        <h1>⏳ Generando código QR...</h1>
        <p>Espera un momento...</p>
        <script>setTimeout(() => location.reload(), 3000)</script>
      </div>
    `)
  }
})

// Servir archivos multimedia
app.use("/media", express.static(mediaDir))

// API para obtener estado
app.get("/api/status", (req, res) => {
  res.json({
    connected: isConnected,
    hasQR: !!qrCodeDataURL,
  })
})

// API para obtener mensajes
app.get("/api/messages", (req, res) => {
  res.json(messageHistory)
})

// API para enviar mensaje
app.post("/api/send", async (req, res) => {
  if (!isConnected || !whatsappClient) {
    return res.status(400).json({ success: false, error: "WhatsApp no conectado" })
  }

  try {
    const { to, message } = req.body

    if (!to || !message) {
      return res.status(400).json({ success: false, error: "Faltan parámetros (to, message)" })
    }

    // Formatear número si es necesario
    let recipient = to
    if (!to.includes("@")) {
      // Asumimos que es un número de teléfono sin formato
      recipient = to.replace(/[^\d]/g, "") + "@s.whatsapp.net"
    }

    // Enviar mensaje
    await whatsappClient.sendMessage(recipient, { text: message })

    res.json({ success: true, message: "Mensaje enviado" })
  } catch (error) {
    console.error("Error al enviar mensaje:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

// Iniciar servidor
app.listen(port, "0.0.0.0", () => {
  console.log(`🚀 Servidor iniciado en http://0.0.0.0:${port}`)
  console.log(`📱 Accede desde: http://TU_IP_VPS:${port}`)
})

// Manejo de errores
process.on("uncaughtException", (err) => {
  console.error("Error no capturado:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("Promesa rechazada:", err)
})
