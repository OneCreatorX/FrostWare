repeat wait() until game:IsLoaded()
repeat wait() until lp
repeat wait() until lp.Character
repeat wait() until lp.Character:FindFirstChild("HumanoidRootPart")

local pcl, pgl, fpl, mml, tml = nil, nil, nil, nil, nil
local stt = tick()
local fpc = 0
local lfu = tick()

local function us_()
    return game:GetService("UserInputService")
end

local function gs_()
    local userInputService = us_()
    return userInputService and userInputService:GetService("UserGameSettings")
end

local function upd()
    spawn(function()
        rs.Heartbeat:Connect(function()
            fpc = fpc + 1
        end)
        
        while task.wait(1) do
            if pcl and pcl.Parent then
                local cp = #game:GetService("Players"):GetPlayers()
                local mp = game:GetService("Players").MaxPlayers
                pcl.Text = "👥 " .. cp .. "/" .. mp
            end
            
            if pgl and pgl.Parent then
                local png = lp:GetNetworkPing() * 1000
                pgl.Text = "📡 " .. math.floor(png) .. "ms"
            end
            
            if fpl and fpl.Parent then
                local ct = tick()
                local fps = math.floor(fpc / (ct - lfu))
                fpl.Text = "🎯 " .. fps .. " FPS"
                fpc = 0
                lfu = ct
            end
            
            if mml and mml.Parent then
                local mem = game:GetService("Stats"):GetTotalMemoryUsageMb()
                mml.Text = "💾 " .. math.floor(mem) .. "MB"
            end
            
            if tml and tml.Parent then
                local el = tick() - stt
                local m = math.floor(el / 60)
                local s = math.floor(el % 60)
                tml.Text = "⏱️ " .. m .. ":" .. string.format("%02d", s)
            end
        end
    end)
end

local function hui()
    local ui = fw.gu()
    if ui and ui["3"] then
        ui["3"].Visible = false
        
        spawn(function()
            wait(5)
            ui["3"].Visible = true
            fw.sa("Success", "UI restored!", 2)
        end)
    end
end

local function eal()
    local uset = gs_()
    local lt = game:GetService("Lighting")
    local ws = workspace
    
    pcall(function()
        if uset then
            uset.MasterVolume = 0
            uset.GraphicsQualityLevel = 1
            uset.SavedQualityLevel = 1
        end
    end)
    
    pcall(function()
        lt.GlobalShadows = false
        lt.FogEnd = 9e9
        lt.Brightness = 0
        lt.ColorShift_Bottom = Color3.fromRGB(11, 11, 11)
        lt.ColorShift_Top = Color3.fromRGB(240, 240, 240)
        lt.OutdoorAmbient = Color3.fromRGB(34, 34, 34)
        lt.Ambient = Color3.fromRGB(34, 34, 34)
    end)
    
    pcall(function()
        ws.Terrain.WaterWaveSize = 0
        ws.Terrain.WaterWaveSpeed = 0
        ws.Terrain.WaterReflectance = 0
        ws.Terrain.WaterTransparency = 0
    end)
    
    for _, obj in pairs(ws:GetDescendants()) do
        pcall(function()
            if obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Explosion") then
                obj.BlastPressure = 1
                obj.BlastRadius = 1
            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end)
    end
    
    for _, eff in pairs(lt:GetChildren()) do
        pcall(function()
            if eff:IsA("BloomEffect") or eff:IsA("BlurEffect") or 
               eff:IsA("ColorCorrectionEffect") or eff:IsA("SunRaysEffect") then
                eff.Enabled = false
            end
        end)
    end
    
    fw.sa("Success", "Extreme anti-lag applied!", 2)
end

local function ceb(p, e, t, pos, sz, cb)
    local btn = fw.csb(p, t:gsub(" ", ""), t, e, pos, sz)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local function csl(p, t, pos, sz)
    local f = nf(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    nc(f, 0.06)
    ns(f, 1, Color3.fromRGB(35,39,54))
    
    local l = nt(f, {t=t, ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(l, 14)
    
    return l
end

local function sh()
    local ok, svs = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and svs.data then
        for _, sv in pairs(svs.data) do
            if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, sv.id)
                break
            end
        end
    else
        fw.sa("Error", "Failed to get servers!", 2)
    end
end

local function cws()
    local c = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if not obj:IsA("Terrain") and not obj:IsA("Camera") and obj ~= workspace.CurrentCamera and not game:GetService("Players"):GetPlayerFromCharacter(obj) then
            pcall(function()
                obj:Destroy()
                c = c + 1
            end)
        end
    end
    fw.sa("Success", "Cleared " .. c .. " objects!", 2)
end

local function ts_()
    local uset = gs_()
    if uset then
        if uset.MasterVolume > 0 then
            uset.MasterVolume = 0
            fw.sa("Info", "Sound disabled!", 2)
        else
            uset.MasterVolume = 1
            fw.sa("Info", "Sound enabled!", 2)
        end
    else
        fw.sa("Error", "Cannot access sound settings!", 2)
    end
end

local function uep()
    local ui = fw.gu()
    local ep = ui["11"]:FindFirstChild("ExtraPage")
    if not ep then return end
    
    for _, ch in pairs(ep:GetChildren()) do
        if ch.Name ~= "TextLabel" then
            ch:Destroy()
        end
    end
    
    local tt = ep:FindFirstChild("TextLabel")
    if tt then
        tt.Text = "🛠️ System Tools"
        tt.Size = UDim2.new(1, 0, 0.08, 0)
        tt.Position = UDim2.new(0, 0, 0.02, 0)
    end
    
    local mf = nf(ep, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0.95,0,0.88,0), p=UDim2.new(0.025,0,0.1,0), n="MainFrame"})
    nc(mf, 0.08)
    ns(mf, 2, Color3.fromRGB(35,39,54))
    
    local sf = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.18,0), p=UDim2.new(0.02,0,0.02,0), n="StatsFrame"})
    nc(sf, 0.08)
    ns(sf, 1, Color3.fromRGB(35,39,54))
    
    local st_ = nt(sf, {t="📊 Live Stats", ts=18, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(st_, 18)
    
    pcl = csl(sf, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    pgl = csl(sf, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    fpl = csl(sf, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    mml = csl(sf, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    tml = csl(sf, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
    
    local bsz = UDim2.new(0.31, 0, 0.1, 0)
    
    ceb(mf, "🗄️", "Toggle Animations", UDim2.new(0.02, 0, 0.25, 0), bsz, function()
        da = not da
        fw.sa("Success", "Animations " .. (da and "disabled" or "enabled") .. "!", 2)
    end)
    
    ceb(mf, "🔄", "Rejoin Server", UDim2.new(0.345, 0, 0.25, 0), bsz, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
    end)
    
    ceb(mf, "🌐", "Server Hop", UDim2.new(0.67, 0, 0.25, 0), bsz, function()
        sh()
    end)
    
    ceb(mf, "📋", "Copy User ID", UDim2.new(0.02, 0, 0.37, 0), bsz, function()
        if e.sc then
            e.sc(tostring(lp.UserId))
            fw.sa("Success", "User ID copied!", 2)
        else
            fw.sa("Error", "Clipboard not supported!", 2)
        end
    end)
    
    ceb(mf, "👁️", "Hide UI (5s)", UDim2.new(0.345, 0, 0.37, 0), bsz, function()
        hui()
        fw.sa("Info", "UI hidden for 5 seconds!", 1)
    end)
    
    ceb(mf, "⚡", "Extreme Anti-Lag", UDim2.new(0.67, 0, 0.37, 0), bsz, function()
        eal()
    end)
    
    ceb(mf, "🧹", "Clear Workspace", UDim2.new(0.02, 0, 0.49, 0), bsz, function()
        cws()
    end)
    
    ceb(mf, "🎵", "Toggle Sound", UDim2.new(0.345, 0, 0.49, 0), bsz, function()
        ts_()
    end)
    
    ceb(mf, "🔄", "Refresh UI", UDim2.new(0.67, 0, 0.49, 0), bsz, function()
        fw.hd()
        wait(0.5)
        fw.sh()
        fw.sa("Success", "UI refreshed!", 2)
    end)
    
    ceb(mf, "📊", "Game Info", UDim2.new(0.02, 0, 0.61, 0), bsz, function()
        local inf = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if e.sc then
            e.sc(inf)
            fw.sa("Success", "Game info copied!", 2)
        else
            fw.sa("Info", inf, 4)
        end
    end)
    
    ceb(mf, "🔧", "Developer Console", UDim2.new(0.345, 0, 0.61, 0), bsz, function()
        game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
        fw.sa("Info", "Developer console opened!", 2)
    end)
    
    ceb(mf, "💾", "Save Place", UDim2.new(0.67, 0, 0.61, 0), bsz, function()
        if saveinstance then
            saveinstance()
            fw.sa("Success", "Place saved!", 2)
        else
            fw.sa("Error", "Save instance not supported!", 2)
        end
    end)
    
    local if_ = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.2,0), p=UDim2.new(0.02,0,0.75,0), n="InfoFrame"})
    nc(if_, 0.08)
    ns(if_, 1, Color3.fromRGB(35,39,54))
    
    local it = nt(if_, {t="ℹ️ System Information", ts=16, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(it, 16)
    
    local ei = nt(if_, {t="Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"), ts=12, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.3,0), p=UDim2.new(0.02,0,0.35,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(ei, 12)
    
    local hid = gethwid and gethwid() or "Unknown"
    local hi = nt(if_, {t="HWID: " .. hid:sub(1, 8) .. "...", ts=12, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.3,0), p=UDim2.new(0.52,0,0.35,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(hi, 12)
    
    local vi = nt(if_, {t="FrostWare Lib V2 - Module Loaded", ts=12, tc=Color3.fromRGB(166,190,255), bt=1, s=UDim2.new(0.96,0,0.3,0), p=UDim2.new(0.02,0,0.65,0), sc=true, xa=Enum.TextXAlignment.Center, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(vi, 12)
    
    upd()
end

spawn(function()
    wait(2)
    uep()
end)
