setreadonly(dtc, false);
dtc.securestring = function() end
dtc._securestring = function() end
setreadonly(dtc, true);
dtc.pushautoexec();

if not getgenv()._FW then
    local ok, fw = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/main.lua"))()
    end)
    if ok and fw then
        getgenv()._FW = fw
    end
end

local FW = getgenv()._FW or {}
local hs = game:GetService("HttpService")
local rs = game:GetService("RunService")
local st = game:GetService("Stats")
local ts = game:GetService("TeleportService")
local us = game:GetService("UserSettings")
local sg = game:GetService("StarterGui")
local ms = game:GetService("MarketplaceService")

local pcl, pgl, fpl, mml, tml = nil, nil, nil, nil, nil
local stt = tick()
local fpc = 0
local lfu = tick()

local function us_()
    return typeof(us) == "function" and us() or us
end

local function gs_()
    return us_() and us_():GetService("UserGameSettings")
end

local function upd()
    spawn(function()
        rs.Heartbeat:Connect(function()
            fpc = fpc + 1
        end)
        
        while task.wait(1) do
            if pcl and pcl.Parent then
                local cp = #game.Players:GetPlayers()
                local mp = game.Players.MaxPlayers
                pcl.Text = "👥 " .. cp .. "/" .. mp
            end
            
            if pgl and pgl.Parent then
                local png = game.Players.LocalPlayer:GetNetworkPing() * 1000
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
                local mem = st:GetTotalMemoryUsageMb()
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
    local ui = FW.getUI()
    if ui and ui["3"] then
        ui["3"].Visible = false
        ui["2"].Visible = false
        
        spawn(function()
            wait(5)
            ui["3"].Visible = true
            ui["2"].Visible = true
            FW.showAlert("Success", "UI restored!", 2)
        end)
    end
end

local function eal()
    local uset = gs_()
    local lt = game:GetService("Lighting")
    local ws = game:GetService("Workspace")
    
    pcall(function()
        uset.MasterVolume = 0
        uset.GraphicsQualityLevel = 1
        uset.SavedQualityLevel = 1
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
    
    FW.showAlert("Success", "Extreme anti-lag applied!", 2)
end

local function ceb(p, e, t, pos, sz, cb)
    local btn = FW.cF(p, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = sz,
        Position = pos,
        Name = t:gsub(" ", "")
    })
    FW.cC(btn, 0.2)
    FW.cG(btn, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
    
    local el = FW.cT(btn, {
        Text = e,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = true,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    
    local tl = FW.cT(btn, {
        Text = t,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0.6, 0),
        Position = UDim2.new(0.35, 0, 0.2, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(tl, 16)
    
    local cb_ = FW.cB(btn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    cb_.MouseButton1Click:Connect(cb)
    return btn
end

local function csl(p, t, pos, sz)
    local f = FW.cF(p, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = sz,
        Position = pos,
        Name = t:gsub(" ", "")
    })
    FW.cC(f, 0.15)
    FW.cS(f, 1, Color3.fromRGB(35, 39, 54))
    
    local l = FW.cT(f, {
        Text = t,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(l, 14)
    return l
end

local function sh()
    local ok, svs = pcall(function()
        return hs:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and svs.data then
        for _, sv in pairs(svs.data) do
            if sv.playing < sv.maxPlayers and sv.id ~= game.JobId then
                ts:TeleportToPlaceInstance(game.PlaceId, sv.id)
                break
            end
        end
    else
        FW.showAlert("Error", "Failed to get servers!", 2)
    end
end

local function cws()
    local c = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if not obj:IsA("Terrain") and not obj:IsA("Camera") and obj ~= workspace.CurrentCamera and not game.Players:GetPlayerFromCharacter(obj) then
            pcall(function()
                 obj:Destroy()
                 c = c + 1
            end)
        end
    end
    FW.showAlert("Success", "Cleared " .. c .. " objects!", 2)
end

local function ts_()
    local uset = gs_()
    if uset.MasterVolume > 0 then
        uset.MasterVolume = 0
        FW.showAlert("Info", "Sound disabled!", 2)
    else
        uset.MasterVolume = 1
        FW.showAlert("Info", "Sound enabled!", 2)
    end
end

local function uep()
    local ep = FW.getUI()["11"]:FindFirstChild("ExtraPage")
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
    
    local mf = FW.cF(ep, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 32),
        Size = UDim2.new(0.95, 0, 0.88, 0),
        Position = UDim2.new(0.025, 0, 0.1, 0),
        Name = "MainFrame"
    })
    FW.cC(mf, 0.02)
    FW.cS(mf, 2, Color3.fromRGB(35, 39, 54))
    
    local sf = FW.cF(mf, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.96, 0, 0.18, 0),
        Position = UDim2.new(0.02, 0, 0.02, 0),
        Name = "StatsFrame"
    })
    FW.cC(sf, 0.02)
    FW.cS(sf, 1, Color3.fromRGB(35, 39, 54))
    
    local st_ = FW.cT(sf, {
        Text = "📊 Live Stats",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.25, 0),
        Position = UDim2.new(0.02, 0, 0.05, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(st_, 18)
    
    pcl = csl(sf, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    pgl = csl(sf, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    fpl = csl(sf, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    mml = csl(sf, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    tml = csl(sf, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
    
    local bsz = UDim2.new(0.31, 0, 0.1, 0)
    
    ceb(mf, "🗄️", "Animation UI", UDim2.new(0.02, 0, 0.25, 0), bsz, function()
    getgenv()._FW_DISABLE_ANIMATIONS = not getgenv()._FW_DISABLE_ANIMATIONS
    FW.showAlert("Success", "Animations " .. (getgenv()._FW_DISABLE_ANIMATIONS and "disabled" or "enabled") .. "!", 2)
end)
    
    ceb(mf, "🔄", "Rejoin Server", UDim2.new(0.345, 0, 0.25, 0), bsz, function()
        ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end)
    
    ceb(mf, "🌐", "Server Hop", UDim2.new(0.67, 0, 0.25, 0), bsz, function()
        sh()
    end)
    
    ceb(mf, "📋", "Copy User ID", UDim2.new(0.02, 0, 0.37, 0), bsz, function()
        if getgenv().setclipboard then
            getgenv().setclipboard(tostring(game.Players.LocalPlayer.UserId))
            FW.showAlert("Success", "User ID copied!", 2)
        else
            FW.showAlert("Error", "Clipboard not supported!", 2)
        end
    end)
    
    ceb(mf, "👁️", "Hide UI (5s)", UDim2.new(0.345, 0, 0.37, 0), bsz, function()
        hui()
        FW.showAlert("Info", "UI hidden for 5 seconds!", 1)
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
        FW.hide()
        wait(0.5)
        FW.show()
        FW.showAlert("Success", "UI refreshed!", 2)
    end)
    
    ceb(mf, "📊", "Game Info", UDim2.new(0.02, 0, 0.61, 0), bsz, function()
        local inf = "Game: " .. ms:GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if getgenv().setclipboard then
            getgenv().setclipboard(inf)
            FW.showAlert("Success", "Game info copied!", 2)
        else
            FW.showAlert("Info", inf, 4)
        end
    end)
    
    ceb(mf, "🔧", "Developer Console", UDim2.new(0.345, 0, 0.61, 0), bsz, function()
        sg:SetCore("DevConsoleVisible", true)
        FW.showAlert("Info", "Developer console opened!", 2)
    end)
    
    ceb(mf, "💾", "Save Place", UDim2.new(0.67, 0, 0.61, 0), bsz, function()
        if saveinstance then
            saveinstance()
            FW.showAlert("Success", "Place saved!", 2)
        else
            FW.showAlert("Error", "Save instance not supported!", 2)
        end
    end)
    
    local if_ = FW.cF(mf, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.96, 0, 0.2, 0),
        Position = UDim2.new(0.02, 0, 0.75, 0),
        Name = "InfoFrame"
    })
    FW.cC(if_, 0.02)
    FW.cS(if_, 1, Color3.fromRGB(35, 39, 54))
    
    local it = FW.cT(if_, {
        Text = "ℹ️ System Information",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.25, 0),
        Position = UDim2.new(0.02, 0, 0.05, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(it, 16)
    
    local ei = FW.cT(if_, {
        Text = "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.46, 0, 0.3, 0),
        Position = UDim2.new(0.02, 0, 0.35, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    })
    FW.cTC(ei, 12)
    
    local hid = getgenv()._e and getgenv()._e.gethwid and getgenv()._e.gethwid() or "Unknown"
    local hi = FW.cT(if_, {
        Text = "HWID: " .. hid:sub(1, 8) .. "...",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.46, 0, 0.3, 0),
        Position = UDim2.new(0.52, 0, 0.35, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    })
    FW.cTC(hi, 12)
    
    local vi = FW.cT(if_, {
        Text = "FrostWare Lib V2 - Module Loaded",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(166, 190, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.3, 0),
        Position = UDim2.new(0.02, 0, 0.65, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(vi, 12)
    
    upd()
end

spawn(function()
    wait(2)
    uep()
    
    local mods = {
        "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts.lua",
            "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/M.lua"
    }
    
    for i, mu in pairs(mods) do
        spawn(function()
            local ok, mc = pcall(function()
                return game:HttpGet(mu)
            end)
            
            if ok then
                FW.addLog("Module " .. i .. " downloaded successfully", "info")
                
                local ok2, err = pcall(function()
                    loadstring(mc)()
                end)
                
                if ok2 then
                    FW.addLog("Module " .. i .. " executed successfully", "info")
                else
                    FW.addLog("Error executing module " .. i .. ": " .. tostring(err), "error")
                end
            else
                FW.addLog("Error downloading module " .. i .. ": " .. tostring(mc), "error")
            end
        end)
        
        wait(1)
    end
end)

return true
