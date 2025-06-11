#!/bin/bash

set -e

DOMAIN="system.heatherx.site"
PORT=8433
APP_DIR="whatsapp-https-app"

echo "🔒 Instalando WhatsApp HTTPS App"
echo "==============================="

if ! command -v node &> /dev/null || [[ $(node -v | cut -d'v' -f2 | cut -d'.' -f1) -lt 18 ]]; then
    echo "📦 Instalando Node.js 20 LTS..."
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs build-essential python3 libvips-dev
fi

if ! command -v certbot &> /dev/null; then
    echo "📦 Instalando Certbot..."
    sudo apt install -y certbot
fi

if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo "🔑 Obteniendo certificado SSL para $DOMAIN..."
    sudo certbot certonly --standalone -d $DOMAIN
fi

echo "🔑 Configurando permisos para certificados SSL..."
sudo chmod -R 755 /etc/letsencrypt/live
sudo chmod -R 755 /etc/letsencrypt/archive

echo "🗂️ Creando directorio de aplicación..."
mkdir -p $APP_DIR
cd $APP_DIR

echo "📝 Creando package.json..."
cat > package.json << 'EOF'
{
  "name": "whatsapp-https-interface",
  "version": "1.0.0",
  "type": "module",
  "description": "WhatsApp Web Interface with HTTPS",
  "main": "server.js",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "@whiskeysockets/baileys": "^6.7.8",
    "body-parser": "^1.20.2",
    "express": "^4.18.2",
    "qrcode": "^1.5.3"
  }
}
EOF

echo "📦 Instalando dependencias npm..."
npm install

echo "📝 Creando servidor HTTPS..."
cat > server.js << 'EOF'
import makeWASocket, { Browsers, useMultiFileAuthState, downloadMediaMessage } from "@whiskeysockets/baileys"
import express from "express"
import qrcode from "qrcode"
import { fileURLToPath } from "url"
import { dirname, join } from "path"
import fs from "fs"
import https from "https"
import { createWriteStream } from "fs"
import bodyParser from "body-parser"

const CONFIG = {
  PORT: 8433,
  DOMAIN: "system.heatherx.site",
  SSL_KEY: `/etc/letsencrypt/live/system.heatherx.site/privkey.pem`,
  SSL_CERT: `/etc/letsencrypt/live/system.heatherx.site/cert.pem`,
  SSL_CA: `/etc/letsencrypt/live/system.heatherx.site/chain.pem`,
}

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)
const app = express()
let qrCodeDataURL = null
let isConnected = false
let whatsappClient = null
const messageHistory = []
let state, saveCreds

app.use(express.static("public"))
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: true }))

const mediaDir = join(__dirname, "media")
try {
  await fs.promises.mkdir(mediaDir, { recursive: true })
} catch (err) {
  console.error("Error creating media directory:", err)
}

try {
  await fs.promises.mkdir("public", { recursive: true })
} catch (err) {
  console.error("Error creating public directory:", err)
}

const htmlContent = `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>WhatsApp Web Interface</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    }
    body {
      background-color: #f0f2f5;
    }
    .container {
      max-width: 1200px;
      margin: 0 auto;
      height: 100vh;
      display: flex;
      flex-direction: column;
    }
    header {
      background-color: #128c7e;
      color: white;
      padding: 15px;
      display: flex;
      justify-content: space-between;
      align-items: center;
    }
    .status-connected {
      background-color: #25d366;
      padding: 5px 10px;
      border-radius: 10px;
      font-size: 14px;
    }
    .status-disconnected {
      background-color: #ff6b6b;
      padding: 5px 10px;
      border-radius: 10px;
      font-size: 14px;
    }
    .main-content {
      display: flex;
      height: calc(100vh - 70px);
    }
    .sidebar {
      width: 30%;
      background-color: white;
      border-right: 1px solid #ddd;
      display: flex;
      flex-direction: column;
    }
    .self-chat {
      padding: 15px;
      border-bottom: 1px solid #ddd;
    }
    .self-chat h3 {
      margin-bottom: 10px;
      color: #128c7e;
    }
    .send-form {
      display: flex;
      flex-direction: column;
    }
    .send-form textarea {
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 5px;
      resize: none;
      height: 80px;
      margin-bottom: 10px;
    }
    .send-form button {
      background-color: #128c7e;
      color: white;
      border: none;
      padding: 8px;
      border-radius: 5px;
      cursor: pointer;
    }
    .chat-list {
      flex: 1;
      overflow-y: auto;
      padding: 15px;
    }
    .chat-list h3 {
      margin-bottom: 15px;
      color: #128c7e;
    }
    .chat-list ul {
      list-style: none;
    }
    .chat-list li {
      padding: 10px;
      border-bottom: 1px solid #eee;
      cursor: pointer;
    }
    .chat-list li:hover {
      background-color: #f5f5f5;
    }
    .chat-area {
      flex: 1;
      display: flex;
      flex-direction: column;
    }
    .messages {
      flex: 1;
      padding: 20px;
      overflow-y: auto;
      background-color: #e5ddd5;
      display: flex;
      flex-direction: column-reverse;
    }
    .message {
      max-width: 65%;
      padding: 10px 15px;
      margin-bottom: 10px;
      border-radius: 7.5px;
      position: relative;
      word-wrap: break-word;
    }
    .message-received {
      background-color: white;
      align-self: flex-start;
    }
    .message-sent {
      background-color: #dcf8c6;
      align-self: flex-end;
    }
    .message-time {
      font-size: 11px;
      color: #999;
      text-align: right;
      margin-top: 5px;
    }
    .message-media {
      max-width: 100%;
      max-height: 200px;
      margin-top: 10px;
      border-radius: 5px;
    }
    .input-area {
      padding: 15px;
      background-color: #f0f0f0;
      display: flex;
      align-items: center;
    }
    .input-area textarea {
      flex: 1;
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 20px;
      resize: none;
      height: 45px;
    }
    .input-area button {
      background-color: #128c7e;
      color: white;
      border: none;
      width: 45px;
      height: 45px;
      border-radius: 50%;
      margin-left: 10px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .input-area button::after {
      content: "➤";
      font-size: 18px;
    }
    @media (max-width: 768px) {
      .main-content {
        flex-direction: column;
      }
      .sidebar {
        width: 100%;
        height: 40%;
      }
      .chat-area {
        height: 60%;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <header>
      <h1>WhatsApp Web Interface</h1>
      <div id="status" class="status-connected">Connected</div>
    </header>
    
    <div class="main-content">
      <div class="sidebar">
        <div class="self-chat">
          <h3>Send message to myself</h3>
          <div class="send-form">
            <textarea id="self-message" placeholder="Write a message..."></textarea>
            <button id="send-self">Send</button>
          </div>
        </div>
        
        <div class="chat-list">
          <h3>Recent conversations</h3>
          <ul id="chat-list">
          </ul>
        </div>
      </div>
      
      <div class="chat-area">
        <div class="messages" id="messages">
        </div>
        
        <div class="input-area">
          <textarea id="message-input" placeholder="Write a message..."></textarea>
          <button id="send-button"></button>
        </div>
      </div>
    </div>
  </div>
  
  <script>
    let currentChat = null
    let myNumber = null

    const statusElement = document.getElementById("status")
    const messagesList = document.getElementById("messages")
    const chatList = document.getElementById("chat-list")
    const messageInput = document.getElementById("message-input")
    const sendButton = document.getElementById("send-button")
    const selfMessageInput = document.getElementById("self-message")
    const sendSelfButton = document.getElementById("send-self")

    async function checkStatus() {
      try {
        const response = await fetch("/api/status")
        const data = await response.json()

        if (data.connected) {
          statusElement.textContent = "Connected"
          statusElement.className = "status-connected"
          loadMessages()

          if (!myNumber) {
            const messagesResponse = await fetch("/api/messages")
            const messages = await messagesResponse.json()
            if (messages.length > 0) {
              const firstMessage = messages[0]
              if (firstMessage && firstMessage.from) {
                myNumber = firstMessage.from
                console.log("My number detected:", myNumber)
              }
            }
          }
        } else {
          statusElement.textContent = "Disconnected"
          statusElement.className = "status-disconnected"
          setTimeout(() => {
            window.location.reload()
          }, 5000)
        }
      } catch (error) {
        console.error("Error checking status:", error)
        statusElement.textContent = "Connection error"
        statusElement.className = "status-disconnected"
      }
    }

    async function loadMessages() {
      try {
        const response = await fetch("/api/messages")
        const messages = await response.json()

        messagesList.innerHTML = ""
        const chats = new Map()

        messages.forEach((msg) => {
          if (!chats.has(msg.from)) {
            chats.set(msg.from, {
              id: msg.from,
              lastMessage: msg.text,
              timestamp: msg.timestamp,
            })
          }

          if (currentChat === msg.from || !currentChat) {
            displayMessage(msg)
          }
        })

        updateChatList(chats)

        if (!currentChat && chats.size > 0) {
          currentChat = chats.values().next().value.id
          highlightSelectedChat()
        }
      } catch (error) {
        console.error("Error loading messages:", error)
      }
    }

    function displayMessage(message) {
      const messageElement = document.createElement("div")
      messageElement.classList.add("message")

      const isSent = message.from === myNumber
      messageElement.classList.add(isSent ? "message-sent" : "message-received")

      const date = new Date(message.timestamp * 1000)
      const timeString = date.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

      let content = `<div class="message-text">${escapeHtml(message.text)}</div>`

      if (message.hasMedia && message.mediaPath) {
        if (message.mediaType === "image") {
          content += `<img src="${message.mediaPath}" class="message-media" alt="Image" />`
        } else if (message.mediaType === "audio") {
          content += `<audio controls src="${message.mediaPath}" class="message-media"></audio>`
        } else if (message.mediaType === "video") {
          content += `<video controls src="${message.mediaPath}" class="message-media"></video>`
        } else {
          content += `<a href="${message.mediaPath}" target="_blank" download>Download file</a>`
        }
      }

      content += `<div class="message-time">${timeString}</div>`
      messageElement.innerHTML = content

      messagesList.appendChild(messageElement)
    }

    function updateChatList(chats) {
      chatList.innerHTML = ""

      const sortedChats = Array.from(chats.values()).sort((a, b) => b.timestamp - a.timestamp)

      sortedChats.forEach((chat) => {
        const chatElement = document.createElement("li")
        chatElement.dataset.chatId = chat.id

        let chatName = chat.id
        if (chatName.includes("@s.whatsapp.net")) {
          chatName = chatName.split("@")[0]
          chatName = formatPhoneNumber(chatName)
        }

        const isMe = chat.id === myNumber

        chatElement.innerHTML = `
          <strong>${isMe ? "Myself" : chatName}</strong>
          <p>${escapeHtml(chat.lastMessage.substring(0, 30))}${chat.lastMessage.length > 30 ? "..." : ""}</p>
        `

        chatElement.addEventListener("click", () => {
          currentChat = chat.id
          highlightSelectedChat()
          loadMessages()
        })

        chatList.appendChild(chatElement)
      })

      highlightSelectedChat()
    }

    function highlightSelectedChat() {
      document.querySelectorAll("#chat-list li").forEach((li) => {
        if (li.dataset.chatId === currentChat) {
          li.classList.add("selected")
          li.style.backgroundColor = "#ebebeb"
        } else {
          li.classList.remove("selected")
          li.style.backgroundColor = ""
        }
      })
    }

    async function sendMessage(to, message) {
      try {
        const response = await fetch("/api/send", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({ to, message }),
        })

        const result = await response.json()

        if (result.success) {
          messageInput.value = ""
          selfMessageInput.value = ""
          setTimeout(loadMessages, 1000)
        } else {
          alert("Error sending message: " + result.error)
        }
      } catch (error) {
        console.error("Error sending message:", error)
        alert("Error sending message")
      }
    }

    function formatPhoneNumber(number) {
      if (number.length > 10) {
        return `+${number.substring(0, number.length - 10)} ${number.substring(number.length - 10)}`
      }
      return number
    }

    function escapeHtml(text) {
      const div = document.createElement("div")
      div.textContent = text
      return div.innerHTML
    }

    sendButton.addEventListener("click", () => {
      const message = messageInput.value.trim()
      if (message && currentChat) {
        sendMessage(currentChat, message)
      }
    })

    messageInput.addEventListener("keypress", (e) => {
      if (e.key === "Enter" && !e.shiftKey) {
        e.preventDefault()
        sendButton.click()
      }
    })

    sendSelfButton.addEventListener("click", () => {
      const message = selfMessageInput.value.trim()
      if (message && myNumber) {
        sendMessage(myNumber, message)
      } else if (message) {
        alert("Your number hasn't been detected yet. Wait to receive a message first.")
      }
    })

    checkStatus()
    setInterval(checkStatus, 10000)
  </script>
</body>
</html>`;

await fs.promises.writeFile("public/index.html", htmlContent);

async function startWhatsApp() {
  const auth = await useMultiFileAuthState("auth_info")
  state = auth.state
  saveCreds = auth.saveCreds

  const sock = makeWASocket({
    auth: state,
    browser: Browsers.ubuntu("WhatsApp-Web-Interface"),
    printQRInTerminal: false,
  })

  sock.ev.on("creds.update", saveCreds)

  sock.ev.on("connection.update", async (update) => {
    const { connection, lastDisconnect, qr } = update

    if (qr) {
      console.log("New QR code generated")
      qrCodeDataURL = await qrcode.toDataURL(qr)
    }

    if (connection === "close") {
      const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== 401
      console.log("Connection closed:", lastDisconnect?.error)

      if (shouldReconnect) {
        console.log("Reconnecting...")
        whatsappClient = await startWhatsApp()
      }
      isConnected = false
    } else if (connection === "open") {
      console.log("WhatsApp connected successfully!")
      isConnected = true
      qrCodeDataURL = null
    }
  })

  sock.ev.on("messages.upsert", async ({ messages }) => {
    for (const message of messages) {
      if (!message.key.fromMe && message.message) {
        console.log("Message received:", message.key.id)

        const formattedMessage = {
          id: message.key.id,
          from: message.key.remoteJid,
          timestamp: message.messageTimestamp,
          text:
            message.message.conversation ||
            (message.message.extendedTextMessage && message.message.extendedTextMessage.text) ||
            "Multimedia content",
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
            console.error("Error downloading media:", error)
          }
        }

        messageHistory.unshift(formattedMessage)
        if (messageHistory.length > 100) messageHistory.pop()
      }
    }
  })

  whatsappClient = sock
  return sock
}

await startWhatsApp()

app.get("/", (req, res) => {
  if (isConnected) {
    res.sendFile(join(__dirname, "public", "index.html"))
  } else if (qrCodeDataURL) {
    res.send(`
      <div style="text-align: center; font-family: Arial; padding: 50px;">
        <h1>📱 Scan with WhatsApp</h1>
        <img src="${qrCodeDataURL}" style="max-width: 300px; border: 2px solid #128c7e; border-radius: 10px;" />
        <p style="margin: 20px 0;">Open WhatsApp → Linked Devices → Link Device</p>
        <button onclick="location.reload()" style="background: #128c7e; color: white; border: none; padding: 10px 20px; border-radius: 5px; cursor: pointer;">Refresh QR</button>
      </div>
    `)
  } else {
    res.send(`
      <div style="text-align: center; font-family: Arial; padding: 50px;">
        <h1>⏳ Generating QR code...</h1>
        <p>Please wait...</p>
        <script>setTimeout(() => location.reload(), 3000)</script>
      </div>
    `)
  }
})

app.use("/media", express.static(mediaDir))

app.get("/api/status", (req, res) => {
  res.json({
    connected: isConnected,
    hasQR: !!qrCodeDataURL,
  })
})

app.get("/api/messages", (req, res) => {
  res.json(messageHistory)
})

app.post("/api/send", async (req, res) => {
  if (!isConnected || !whatsappClient) {
    return res.status(400).json({ success: false, error: "WhatsApp not connected" })
  }

  try {
    const { to, message } = req.body

    if (!to || !message) {
      return res.status(400).json({ success: false, error: "Missing parameters (to, message)" })
    }

    let recipient = to
    if (!to.includes("@")) {
      recipient = to.replace(/[^\d]/g, "") + "@s.whatsapp.net"
    }

    await whatsappClient.sendMessage(recipient, { text: message })
    res.json({ success: true, message: "Message sent" })
  } catch (error) {
    console.error("Error sending message:", error)
    res.status(500).json({ success: false, error: error.message })
  }
})

try {
  const httpsOptions = {
    key: fs.readFileSync(CONFIG.SSL_KEY),
    cert: fs.readFileSync(CONFIG.SSL_CERT),
    ca: fs.readFileSync(CONFIG.SSL_CA),
  }

  const server = https.createServer(httpsOptions, app)

  server.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTPS Server running at https://${CONFIG.DOMAIN}:${CONFIG.PORT}`)
  })
} catch (error) {
  console.error("Error starting HTTPS server:", error)
  console.log("Falling back to HTTP server...")

  app.listen(CONFIG.PORT, "0.0.0.0", () => {
    console.log(`HTTP Server running at http://0.0.0.0:${CONFIG.PORT}`)
  })
}

process.on("uncaughtException", (err) => {
  console.error("Uncaught exception:", err)
})

process.on("unhandledRejection", (err) => {
  console.error("Unhandled rejection:", err)
})
EOF

if command -v pm2 &> /dev/null; then
    echo "🔄 Stopping existing PM2 process..."
    pm2 delete whatsapp-web 2>/dev/null || true
    echo "🚀 Starting with PM2..."
    pm2 start server.js --name whatsapp-https
    pm2 save
else
    echo "📦 Installing PM2 for process management..."
    sudo npm install -g pm2
    echo "🚀 Starting with PM2..."
    pm2 start server.js --name whatsapp-https
    pm2 startup
    pm2 save
fi

echo "🔧 Configurando firewall..."
if command -v ufw &> /dev/null; then
    sudo ufw allow $PORT/tcp
fi

echo ""
echo "✅ ¡Instalación completada exitosamente!"
echo "🌐 Accede a tu WhatsApp Web Interface en:"
echo "   https://$DOMAIN:$PORT"
echo ""
echo "📱 Para escanear el código QR, abre la URL en tu navegador"
echo "🔧 Para gestionar la aplicación:"
echo "   pm2 status          - Verificar estado"
echo "   pm2 logs whatsapp-https - Ver logs"
echo "   pm2 restart whatsapp-https - Reiniciar app"
echo ""
echo "🎉 ¡Tu WhatsApp Web App con HTTPS está funcionando en el puerto $PORT!"
