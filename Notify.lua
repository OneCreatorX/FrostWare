import express from "express"
import https from "https"
import fs from "fs/promises"
import path from "path"
import { fileURLToPath } from "url"
import helmet from "helmet"
import cors from "cors"
import compression from "compression"
import { Redis } from "ioredis"
import rateLimit from "express-rate-limit"
import RedisStore from "rate-limit-redis"
import crypto from "crypto"
import os from "os"
import cluster from "cluster"
import { WebSocketServer } from "ws"

const __dirname = path.dirname(fileURLToPath(import.meta.url))

const DISCORD_WEBHOOK =
  "https://discord.com/api/webhooks/1378890594952413214/37rcnx06gYiwMITkAvkUFCBVAMhkdlDF98eHL_4jZi1WKH3eTGE9K5Q2D0Va81WBjdUH"

const logDiscord = async (msg) => {
  setImmediate(async () => {
    try {
      await fetch(DISCORD_WEBHOOK, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ content: msg }),
      })
    } catch (e) {}
  })
}

const cfg = {
  DOMAIN: "system.heatherx.site",
  PORT: 443,
  WS_PORT: 8080,
  ACC_HRS: 50,
  SESS_MIN: 6,
  REQ_STEPS: 2,
  RL_GEN: 40,
  RL_REG: 10,
  RL_STAT: 200,
  RL_LOOT: 30,
  REDIS_MEM: "1gb",
  WRK_CNT: Math.min(os.cpus().length, 8),
  MAX_WS: 5,
  WS_TO: 300000,
  CACHE_TTL: 30000,
  MAX_CACHE: 10000,
  REDIS_POOL: 10,
  LV_TOK: "4a5250cc51bd9ad0756f46cf929aa513e44967aa06f826a80f40d55f08f826a80f40d55f08f82985",
  LV_PROJ: "1176431",
  LL_TOK: "c0048eceed1f110aab61e86acb86830751ceb0b37d793063f9f43e1b153248fd",
}

if (cluster.isPrimary && process.env.NODE_ENV === "production") {
  for (let i = 0; i < cfg.WRK_CNT; i++) {
    cluster.fork()
  }

  cluster.on("exit", (worker, code, signal) => {
    cluster.fork()
  })
} else {
  const rds = new Redis("redis://localhost:6379", {
    maxRetriesPerRequest: 3,
    retryDelayOnFailover: 100,
    lazyConnect: true,
    keepAlive: 30000,
    commandTimeout: 5000,
    maxMemoryPolicy: "allkeys-lru",
    connectTimeout: 10000,
    family: 4,
    db: 0,
  })

  const rdsSub = new Redis("redis://localhost:6379", {
    maxRetriesPerRequest: 3,
    lazyConnect: true,
  })

  const cache = new Map()
  const wsConns = new Map()
  const llQueue = new Map()

  const getIP = (req) =>
    req.headers["cf-connecting-ip"] ||
    req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
    req.headers["x-real-ip"] ||
    req.ip

  const validHW = (hwid) => {
    if (!hwid || typeof hwid !== "string" || hwid.length !== 16) return false
    if (!/^[a-zA-Z0-9]+$/.test(hwid)) return false
    if (/^[0-9]+$/.test(hwid)) return false
    if (/^[a-zA-Z]+$/.test(hwid)) return false
    if (/^(.)\1{3,}/.test(hwid)) return false
    const pats = ["0123", "1234", "2345", "3456", "4567", "5678", "6789", "7890", "abcd", "bcde", "cdef"]
    if (pats.some((p) => hwid.toLowerCase().includes(p))) return false
    const wrds = ["test", "demo", "admin", "user", "pass", "key", "hack", "null", "void", "temp"]
    if (wrds.some((w) => hwid.toLowerCase().includes(w))) return false
    return true
  }

  const qCheck = async (hwid) => {
    if (!validHW(hwid)) return { valid: false }

    const ck = `qc:${hwid}`
    const cached = cache.get(ck)
    if (cached && Date.now() - cached.time < cfg.CACHE_TTL) {
      return cached.data
    }

    try {
      const ttl = await rds.ttl(`a:${hwid}`)
      const res =
        ttl > 0
          ? { valid: true, hasAccess: true, hours: Math.ceil(ttl / 3600), seconds: ttl }
          : { valid: true, hasAccess: false }

      cache.set(ck, { data: res, time: Date.now() })
      return res
    } catch (error) {
      return { valid: true, hasAccess: false }
    }
  }

  const verLV = async (hash, maxRetries = 2) => {
    if (!hash) return false
    const ck = `lv:${hash}`
    const cached = cache.get(ck)
    if (cached !== undefined) return cached
    for (let att = 1; att <= maxRetries; att++) {
      try {
        const ctrl = new AbortController()
        setTimeout(() => ctrl.abort(), 5000)
        const resp = await fetch(
          `https://publisher.linkvertise.com/api/v1/anti_bypassing?token=${cfg.LV_TOK}&hash=${hash}`,
          {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            signal: ctrl.signal,
          },
        )
        if (resp.ok) {
          const data = await resp.json()
          const valid = data && (data.success === true || data.status === true)
          cache.set(ck, valid)
          return valid
        }
      } catch (error) {
        if (att === maxRetries) {
          cache.set(ck, false)
          return false
        }
        await new Promise((resolve) => setTimeout(resolve, 1000))
      }
    }
    cache.set(ck, false)
    return false
  }

  const genLL = async (hwid) => {
    const pk = `processing:${hwid}`
    if (llQueue.has(pk)) {
      return { error: "Request already processing" }
    }
    llQueue.set(pk, true)
    try {
      const uk = `ll:${hwid}`
      const tk = `llt:${hwid}`
      const [cachedUrl, existingToken] = await Promise.all([rds.get(uk), rds.get(tk)])
      if (cachedUrl && existingToken) {
        return { url: cachedUrl, cached: true }
      }
      const token = crypto.randomBytes(16).toString("hex")
      const redUrl = `https://${cfg.DOMAIN}/verify?token=${token}`
      await rds.setex(`t:${token}`, 10 * 60, hwid)
      const ctrl = new AbortController()
      setTimeout(() => ctrl.abort(), 10000)
      const params = new URLSearchParams({
        api_token: cfg.LL_TOK,
        title: "Key System - Complete Step",
        url: redUrl,
        tier_id: 3,
        number_of_tasks: 3,
      })
      const resp = await fetch(`https://creators.lootlabs.gg/api/public/content_locker?${params}`, {
        signal: ctrl.signal,
      })
      const data = await resp.json()
      const url = data.message?.loot_url || data.message?.[0]?.loot_url
      if (!url) {
        throw new Error("No URL returned from Lootlabs")
      }
      await Promise.all([rds.setex(uk, 10 * 60, url), rds.setex(tk, 10 * 60, token)])
      return { url, cached: false }
    } catch (e) {
      const fbTok = crypto.randomBytes(16).toString("hex")
      const fbUrl = `https://loot-link.com/s?url=${encodeURIComponent(`https://${cfg.DOMAIN}/verify?token=${fbTok}`)}`
      await rds.setex(`t:${fbTok}`, 10 * 60, hwid)
      return { url: fbUrl, cached: false, fallback: true }
    } finally {
      llQueue.delete(pk)
    }
  }

  const bcHW = (hwid, msg) => {
    const conns = wsConns.get(hwid)
    if (conns) {
      conns.forEach((ws) => {
        if (ws.readyState === 1) {
          try {
            ws.send(JSON.stringify(msg))
          } catch (error) {}
        }
      })
    }
  }

  const cleanWS = (hwid) => {
    const conns = wsConns.get(hwid)
    if (conns) {
      conns.forEach((ws) => {
        if (ws.readyState === 1) {
          ws.close(1000, "Session completed")
        }
      })
      wsConns.delete(hwid)
    }
  }

  const app = express()
  app.set("trust proxy", 1)
  app.use(compression({ level: 6, threshold: 1024 }))
  app.use(express.json({ limit: "2kb" }))
  app.use(
    helmet({
      contentSecurityPolicy: false,
      hsts: { maxAge: 31536000, includeSubDomains: true },
      noSniff: true,
      frameguard: { action: "deny" },
      xssFilter: true,
    }),
  )
  app.use(cors({ origin: false }))
  app.use(
    express.static(path.join(__dirname, "public"), {
      maxAge: "1d",
      etag: true,
      immutable: true,
    }),
  )

  const mkLim = (max, windowMs = 60000, skipSuccessfulRequests = false) =>
    rateLimit({
      store: new RedisStore({
        sendCommand: (...args) => rds.call(...args),
        prefix: "rl:",
      }),
      windowMs,
      max,
      keyGenerator: (req) => {
        const ip =
          req.headers["cf-connecting-ip"] ||
          req.headers["x-forwarded-for"]?.split(",")[0]?.trim() ||
          req.headers["x-real-ip"] ||
          req.connection.remoteAddress ||
          req.ip ||
          "unknown"
        return `${ip}:${req.route?.path || req.url}`
      },
      message: { error: "Rate limit exceeded" },
      standardHeaders: false,
      legacyHeaders: false,
      skipSuccessfulRequests,
      skip: (req) => {
        const ua = req.headers["user-agent"]
        return (ua && ua.includes("HealthCheck")) || req.url === "/health"
      },
    })

  const genLim = mkLim(cfg.RL_GEN, 60000, true)
  const regLim = mkLim(cfg.RL_REG, 300000)
  const statLim = mkLim(cfg.RL_STAT, 60000, true)
  const llLim = mkLim(cfg.RL_LOOT, 60000)

  app.use(genLim)

  app.use((req, res, next) => {
    const ua = req.headers["user-agent"]
    if (!ua || ua.length < 10) {
      return res.status(403).json({ error: "Invalid user agent" })
    }
    const blocked = ["curl", "wget", "python", "bot", "crawler", "scanner", "postman"]
    if (blocked.some((agent) => ua.toLowerCase().includes(agent))) {
      return res.status(403).json({ error: "Access denied" })
    }
    req.clientIP = getIP(req)
    req.startTime = Date.now()
    next()
  })

  app.get("/health", (req, res) => {
    res.json({
      status: "ok",
      timestamp: Date.now(),
      worker: process.pid,
      uptime: process.uptime(),
      memory: process.memoryUsage(),
    })
  })

  app.get("/", (req, res) => {
    res.redirect("/key")
  })

  app.get("/key/:hwid?", async (req, res) => {
    try {
      const { hwid } = req.params
      const pd = {
        hwid: hwid || "",
        hasAccess: false,
        hours: 0,
        progress: { total: 0, required: cfg.REQ_STEPS },
        showRegistration: true,
      }

      if (hwid && !validHW(hwid)) {
        pd.error = "Invalid HWID format"
      } else if (hwid) {
        const chk = await qCheck(hwid)
        if (chk.hasAccess) {
          pd.hasAccess = true
          pd.hours = chk.hours
          pd.showRegistration = false
        } else {
          const sk = `s:${hwid}`
          const sess = await rds.get(sk)
          if (sess) {
            const data = JSON.parse(sess)
            const se = await rds.ttl(sk)
            pd.progress = {
              total: data.total || 0,
              required: cfg.REQ_STEPS,
              sessionExpires: Math.max(0, se),
            }
            pd.showRegistration = false
          }
        }
      }

      const html = await fs.readFile(path.join(__dirname, "public", "index.html"), "utf8")
      res.setHeader("Content-Type", "text/html")
      res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate")
      res.setHeader("Pragma", "no-cache")
      res.setHeader("Expires", "0")
      res.send(
        html
          .replace("{{PAGE_DATA}}", JSON.stringify(pd))
          .replace("{{DOMAIN}}", cfg.DOMAIN)
          .replace("{{LINKVERTISE_PROJECT}}", cfg.LV_PROJ),
      )
    } catch (error) {
      res.redirect("/key")
    }
  })

  app.post("/register", regLim, async (req, res) => {
    try {
      const { hwid } = req.body
      if (!validHW(hwid)) {
        return res.status(400).json({ error: "Invalid HWID format" })
      }

      const chk = await qCheck(hwid)
      if (chk.hasAccess) {
        return res.json({
          success: true,
          hasAccess: true,
          hours: chk.hours,
          seconds: chk.seconds,
        })
      }

      const sk = `s:${hwid}`
      const sess = await rds.get(sk)
      if (sess) {
        const data = JSON.parse(sess)
        const se = await rds.ttl(sk)
        await rds.expire(sk, cfg.SESS_MIN * 60)
        return res.json({
          success: true,
          progress: {
            total: data.total || 0,
            required: cfg.REQ_STEPS,
            sessionExpires: Math.max(0, se),
          },
        })
      }

      const sd = {
        hwid,
        ip: req.clientIP,
        total: 0,
        created: Date.now(),
      }
      await rds.setex(sk, cfg.SESS_MIN * 60, JSON.stringify(sd))

      await logDiscord(`🎯 New registration: ${hwid} from ${req.clientIP}`)

      bcHW(hwid, {
        type: "session_started",
        progress: {
          total: 0,
          required: cfg.REQ_STEPS,
          sessionExpires: cfg.SESS_MIN * 60,
        },
      })

      res.json({
        success: true,
        progress: {
          total: 0,
          required: cfg.REQ_STEPS,
          sessionExpires: cfg.SESS_MIN * 60,
        },
      })
    } catch (error) {
      res.status(500).json({ error: "Registration failed" })
    }
  })

  app.post("/lootlabs", llLim, async (req, res) => {
    try {
      const { hwid } = req.body
      if (!validHW(hwid)) {
        return res.status(400).json({ error: "Invalid HWID format" })
      }

      const chk = await qCheck(hwid)
      if (chk.hasAccess) {
        return res.json({ success: true, hasAccess: true })
      }

      const sk = `s:${hwid}`
      const sess = await rds.get(sk)
      if (!sess) {
        return res.status(400).json({ error: "No active session" })
      }

      const result = await genLL(hwid)
      if (result.error) {
        return res.status(429).json({ error: result.error })
      }

      res.json({
        success: true,
        url: result.url,
        cached: result.cached || false,
        fallback: result.fallback || false,
      })
    } catch (error) {
      res.status(500).json({ error: "Failed to generate link" })
    }
  })

  app.get("/verify", async (req, res) => {
    try {
      const { token, hwid, hash } = req.query
      let tgtHW = null

      if (token) {
        const tk = `t:${token}`
        tgtHW = await rds.get(tk)
        if (tgtHW) {
          await Promise.all([rds.del(tk), rds.del(`ll:${tgtHW}`), rds.del(`llt:${tgtHW}`)])
        }
      } else if (hwid && hash) {
        if (!validHW(hwid)) {
          return res.send(
            `<!DOCTYPE html><html><head><title>Error</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Invalid request</p></body></html>`,
          )
        }
        tgtHW = hwid
      }

      if (!tgtHW) {
        return res.send(
          `<!DOCTYPE html><html><head><title>Error</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Invalid request</p></body></html>`,
        )
      }

      if (hash) {
        const hk = `h:${hash}`
        const hUsed = await rds.exists(hk)
        if (hUsed) {
          return res.send(
            `<!DOCTYPE html><html><head><title>Already Used</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Hash already used</p></body></html>`,
          )
        }

        const isValid = await verLV(hash)
        if (!isValid) {
          return res.send(
            `<!DOCTYPE html><html><head><title>Invalid</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Invalid verification</p></body></html>`,
          )
        }
        await rds.setex(hk, 300, "1")
      }

      const chk = await qCheck(tgtHW)
      if (chk.hasAccess) {
        return res.send(
          `<!DOCTYPE html><html><head><title>Success</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Access already granted</p></body></html>`,
        )
      }

      const sk = `s:${tgtHW}`
      const sess = await rds.get(sk)
      if (!sess) {
        return res.send(
          `<!DOCTYPE html><html><head><title>No Session</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>No active session</p></body></html>`,
        )
      }

      const data = JSON.parse(sess)
      data.total = (data.total || 0) + 1

      if (data.total >= cfg.REQ_STEPS) {
        const ak = `a:${tgtHW}`
        await Promise.all([rds.setex(ak, cfg.ACC_HRS * 3600, "1"), rds.del(sk)])
        cache.delete(`qc:${tgtHW}`)

        await logDiscord(`🎉 Access granted: ${tgtHW} - ${cfg.ACC_HRS} hours`)

        bcHW(tgtHW, {
          type: "access_granted",
          hours: cfg.ACC_HRS,
        })

        cleanWS(tgtHW)

        return res.send(
          `<!DOCTYPE html><html><head><title>Access Granted</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Access granted! Closing...</p></body></html>`,
        )
      }

      await rds.setex(sk, cfg.SESS_MIN * 60, JSON.stringify(data))
      const se = await rds.ttl(sk)

      bcHW(tgtHW, {
        type: "step_completed",
        progress: {
          total: data.total,
          required: cfg.REQ_STEPS,
          sessionExpires: Math.max(0, se),
        },
        service: hash ? "linkvertise" : "lootlabs",
      })

      res.send(
        `<!DOCTYPE html><html><head><title>Step Complete</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Step completed! Closing...</p></body></html>`,
      )
    } catch (error) {
      res.send(
        `<!DOCTYPE html><html><head><title>Error</title></head><body><script>setTimeout(()=>window.close(),1000);</script><p>Verification failed</p></body></html>`,
      )
    }
  })

  app.get("/status/:hwid", statLim, async (req, res) => {
    const { hwid } = req.params
    if (!validHW(hwid)) return res.send("0")

    const ck = `qc:${hwid}`
    const cached = cache.get(ck)
    if (cached && Date.now() - cached.time < cfg.CACHE_TTL) {
      return res.send(String(cached.data.hasAccess ? cached.data.seconds : 0))
    }

    try {
      const ttl = await rds.ttl(`a:${hwid}`)
      const result = ttl > 0 ? ttl : 0

      if (ttl > 0) {
        cache.set(ck, {
          data: { valid: true, hasAccess: true, hours: Math.ceil(ttl / 3600), seconds: ttl },
          time: Date.now(),
        })
      }

      res.send(String(result))
      if (result > 0) {
        await logDiscord(`✅ Status check: ${hwid} - ${Math.ceil(result / 3600)}h remaining`)
      }
    } catch (error) {
      res.send("0")
    }
  })

  app.get("/admin/:token", async (req, res) => {
    try {
      const { token } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).send("Not Found")
      }

      const html = await fs.readFile(path.join(__dirname, "public", "admin.html"), "utf8")
      res.setHeader("Content-Type", "text/html")
      res.setHeader("Cache-Control", "no-cache")
      res.send(html)
    } catch (error) {
      res.status(404).send("Not Found")
    }
  })

  app.get("/api/admin/:token/dashboard", async (req, res) => {
    try {
      const { token } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      const [ak, sk] = await Promise.all([rds.keys("a:*"), rds.keys("s:*")])
      let au = 0
      let th = 0
      let eu = 0

      const ttlPs = ak.map((key) => rds.ttl(key))
      const ttls = await Promise.all(ttlPs)

      ttls.forEach((ttl) => {
        if (ttl > 0) {
          au++
          const hrs = Math.ceil(ttl / 3600)
          th += hrs
          if (hrs <= 24) eu++
        }
      })

      const wsCnt = Array.from(wsConns.values()).reduce((total, conns) => total + conns.size, 0)

      const la = os.loadavg()
      const tm = os.totalmem()
      const fm = os.freemem()

      const dd = {
        stats: {
          activeUsers: au,
          totalHours: th,
          registering: sk.length,
          expiringUsers: eu,
          wsConnections: wsCnt,
          cacheSize: cache.size,
          queueSize: llQueue.size,
        },
        server: {
          cpuLoad: ((la[0] / os.cpus().length) * 100).toFixed(1),
          memoryUsage: (((tm - fm) / tm) * 100).toFixed(1),
          uptime: Math.floor(process.uptime() / 3600),
          workers: cfg.WRK_CNT,
          pid: process.pid,
        },
        config: cfg,
      }

      res.json(dd)
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.get("/api/admin/:token/users", async (req, res) => {
    try {
      const { token } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      const keys = await rds.keys("a:*")
      const users = []

      const ttlPs = keys.map(async (key) => {
        const hwid = key.substring(2)
        if (!validHW(hwid)) return null
        const ttl = await rds.ttl(key)
        if (ttl > 0) {
          return {
            hwid,
            hours: Math.ceil(ttl / 3600),
            expires: new Date(Date.now() + ttl * 1000).toISOString(),
          }
        }
        return null
      })

      const results = await Promise.all(ttlPs)
      results.forEach((user) => {
        if (user) users.push(user)
      })

      users.sort((a, b) => b.hours - a.hours)
      res.json({ users, total: users.length })
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.post("/api/admin/:token/users", async (req, res) => {
    try {
      const { token } = req.params
      const { hwid, hours } = req.body
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      if (!validHW(hwid)) {
        return res.status(400).json({ error: "Invalid HWID format" })
      }

      if (!hours || hours < 1 || hours > 8760) {
        return res.status(400).json({ error: "Invalid hours (1-8760)" })
      }

      const ak = `a:${hwid}`
      const sk = `s:${hwid}`
      await Promise.all([rds.setex(ak, hours * 3600, "1"), rds.del(sk)])
      cache.delete(`qc:${hwid}`)

      bcHW(hwid, {
        type: "access_granted",
        hours: hours,
      })

      cleanWS(hwid)
      res.json({ success: true })
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.delete("/api/admin/:token/users/:hwid", async (req, res) => {
    try {
      const { token, hwid } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      if (!validHW(hwid)) {
        return res.status(400).json({ error: "Invalid HWID format" })
      }

      const ak = `a:${hwid}`
      const sk = `s:${hwid}`
      await Promise.all([rds.del(ak), rds.del(sk)])
      cache.delete(`qc:${hwid}`)

      bcHW(hwid, {
        type: "access_revoked",
      })

      cleanWS(hwid)
      res.json({ success: true })
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.get("/api/admin/:token/search/:hwid", async (req, res) => {
    try {
      const { token, hwid } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      if (!validHW(hwid)) {
        return res.status(400).json({ error: "Invalid HWID format" })
      }

      const chk = await qCheck(hwid)
      if (chk.hasAccess) {
        res.json({
          found: true,
          user: {
            hwid,
            hours: chk.hours,
            seconds: chk.seconds,
            expires: new Date(Date.now() + chk.seconds * 1000).toISOString(),
          },
        })
      } else {
        res.json({ found: false })
      }
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.post("/api/admin/:token/config", async (req, res) => {
    try {
      const { token } = req.params
      const vt = await rds.get("admin_token")

      if (!vt || token !== vt) {
        return res.status(404).json({ error: "Not Found" })
      }

      const { accessHours, requiredSteps, sessionMinutes, rateLimitGeneral, rateLimitRegister } = req.body
      const oc = { ...cfg }

      if (accessHours && accessHours >= 1 && accessHours <= 8760) cfg.ACC_HRS = accessHours
      if (requiredSteps && requiredSteps >= 1 && requiredSteps <= 5) cfg.REQ_STEPS = requiredSteps
      if (sessionMinutes && sessionMinutes >= 1 && sessionMinutes <= 60) cfg.SESS_MIN = sessionMinutes
      if (rateLimitGeneral && rateLimitGeneral >= 10 && rateLimitGeneral <= 200) cfg.RL_GEN = rateLimitGeneral
      if (rateLimitRegister && rateLimitRegister >= 1 && rateLimitRegister <= 50) cfg.RL_REG = rateLimitRegister

      await rds.set("system_config", JSON.stringify(cfg))
      res.json({ success: true, config: cfg })
    } catch (error) {
      res.status(500).json({ error: "Server error" })
    }
  })

  app.use((req, res) => {
    res.status(404).json({ error: "Not Found" })
  })

  app.use(async (error, req, res, next) => {
    res.status(500).json({ error: "Internal server error" })
  })

  try {
    const [key, cert] = await Promise.all([
      fs.readFile(`/etc/letsencrypt/live/${cfg.DOMAIN}/privkey.pem`),
      fs.readFile(`/etc/letsencrypt/live/${cfg.DOMAIN}/fullchain.pem`),
    ])

    const server = https.createServer({ key, cert }, app)
    const wss = new WebSocketServer({
      server,
      path: "/ws",
      perMessageDeflate: false,
      maxPayload: 1024,
    })

    wss.on("connection", async (ws, req) => {
      const url = new URL(req.url, `https://${cfg.DOMAIN}`)
      const hwid = url.searchParams.get("hwid")

      if (!validHW(hwid)) {
        ws.close(1008, "Invalid HWID")
        return
      }

      if (!wsConns.has(hwid)) {
        wsConns.set(hwid, new Set())
      }

      const conns = wsConns.get(hwid)
      if (conns.size >= cfg.MAX_WS) {
        ws.close(1008, "Too many connections")
        return
      }

      conns.add(ws)
      ws.isAlive = true

      const to = setTimeout(() => {
        if (ws.readyState === 1) {
          ws.close(1000, "Timeout")
        }
      }, cfg.WS_TO)

      const hb = setInterval(() => {
        if (ws.readyState === 1 && ws.isAlive) {
          ws.isAlive = false
          ws.ping()
        } else if (ws.readyState === 1) {
          ws.close(1000, "No pong")
        }
      }, 30000)

      ws.on("close", () => {
        clearTimeout(to)
        clearInterval(hb)
        conns.delete(ws)
        if (conns.size === 0) {
          wsConns.delete(hwid)
        }
      })

      ws.on("error", async (error) => {
        clearTimeout(to)
        clearInterval(hb)
        conns.delete(ws)
        if (conns.size === 0) {
          wsConns.delete(hwid)
        }
      })

      ws.on("pong", () => {
        ws.isAlive = true
      })

      ws.on("message", (data) => {
        try {
          const msg = JSON.parse(data.toString())
          if (msg.type === "ping") {
            ws.send(JSON.stringify({ type: "pong" }))
          }
        } catch (e) {}
      })

      ws.send(JSON.stringify({ type: "connected", hwid }))
    })

    server.listen(cfg.PORT, async () => {
      console.log(`Worker ${process.pid} started on port ${cfg.PORT}`)
    })

    const loadCfg = async () => {
      try {
        const saved = await rds.get("system_config")
        if (saved) {
          Object.assign(cfg, JSON.parse(saved))
        }
      } catch (error) {}
    }

    const cleanCache = () => {
      if (cache.size < cfg.MAX_CACHE) return

      const now = Date.now()
      let cleaned = 0
      for (const [key, value] of cache.entries()) {
        if (now - value.time > cfg.CACHE_TTL) {
          cache.delete(key)
          cleaned++
          if (cleaned > 100) break
        }
      }
    }

    const cleanQueues = () => {
      const now = Date.now()
      let cleaned = 0
      for (const [key, timestamp] of llQueue.entries()) {
        if (now - timestamp > 60000) {
          llQueue.delete(key)
          cleaned++
        }
      }
    }

    await loadCfg()
    setInterval(loadCfg, 60000)
    setInterval(cleanCache, 300000)
    setInterval(cleanQueues, 120000)

    process.on("SIGTERM", async () => {
      wss.close()
      server.close(() => {
        rds.disconnect()
        rdsSub.disconnect()
        process.exit(0)
      })
    })

    process.on("SIGINT", async () => {
      wss.close()
      server.close(() => {
        rds.disconnect()
        rdsSub.disconnect()
        process.exit(0)
      })
    })
  } catch (error) {
    process.exit(1)
  }
}
