setreadonly(dtc, false);
dtc.securestring = function() end
dtc._securestring = function() end
setreadonly(dtc, true);
dtc.pushautoexec();
local fw = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/main2.lua"))()

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
local da = false

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
    
    fw.sa("Success", "Extreme anti-lag applied!", 2)
end

local function ceb(p, e, t, pos, sz, cb)
    local btn = fw.csb(p, t:gsub(" ", ""), t, e, pos, sz)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local function csl(p, t, pos, sz)
    local f = Instance.new("Frame", p)
    f.BackgroundColor3 = Color3.fromRGB(16, 19, 27)
    f.Size = sz
    f.Position = pos
    f.Name = t:gsub(" ", "")
    
    local corner = Instance.new("UICorner", f)
    corner.CornerRadius = UDim.new(0, 6)
    
    local stroke = Instance.new("UIStroke", f)
    stroke.Thickness = 1
    stroke.Color = Color3.fromRGB(35, 39, 54)
    
    local l = Instance.new("TextLabel", f)
    l.Text = t
    l.TextSize = 14
    l.TextColor3 = Color3.fromRGB(255, 255, 255)
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(0.9, 0, 0.8, 0)
    l.Position = UDim2.new(0.05, 0, 0.1, 0)
    l.TextScaled = true
    l.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    
    local constraint = Instance.new("UITextSizeConstraint", l)
    constraint.MaxTextSize = 14
    
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
        fw.sa("Error", "Failed to get servers!", 2)
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
    fw.sa("Success", "Cleared " .. c .. " objects!", 2)
end

local function ts_()
    local uset = gs_()
    if uset.MasterVolume > 0 then
        uset.MasterVolume = 0
        fw.sa("Info", "Sound disabled!", 2)
    else
        uset.MasterVolume = 1
        fw.sa("Info", "Sound enabled!", 2)
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
    
    local mf = Instance.new("Frame", ep)
    mf.BackgroundColor3 = Color3.fromRGB(20, 25, 32)
    mf.Size = UDim2.new(0.95, 0, 0.88, 0)
    mf.Position = UDim2.new(0.025, 0, 0.1, 0)
    mf.Name = "MainFrame"
    
    local corner = Instance.new("UICorner", mf)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", mf)
    stroke.Thickness = 2
    stroke.Color = Color3.fromRGB(35, 39, 54)
    
    local sf = Instance.new("Frame", mf)
    sf.BackgroundColor3 = Color3.fromRGB(16, 19, 27)
    sf.Size = UDim2.new(0.96, 0, 0.18, 0)
    sf.Position = UDim2.new(0.02, 0, 0.02, 0)
    sf.Name = "StatsFrame"
    
    local sfCorner = Instance.new("UICorner", sf)
    sfCorner.CornerRadius = UDim.new(0, 8)
    
    local sfStroke = Instance.new("UIStroke", sf)
    sfStroke.Thickness = 1
    sfStroke.Color = Color3.fromRGB(35, 39, 54)
    
    local st_ = Instance.new("TextLabel", sf)
    st_.Text = "📊 Live Stats"
    st_.TextSize = 18
    st_.TextColor3 = Color3.fromRGB(255, 255, 255)
    st_.BackgroundTransparency = 1
    st_.Size = UDim2.new(0.96, 0, 0.25, 0)
    st_.Position = UDim2.new(0.02, 0, 0.05, 0)
    st_.TextScaled = true
    st_.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    
    local stConstraint = Instance.new("UITextSizeConstraint", st_)
    stConstraint.MaxTextSize = 18
    
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
        ts:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end)
    
    ceb(mf, "🌐", "Server Hop", UDim2.new(0.67, 0, 0.25, 0), bsz, function()
        sh()
    end)
    
    ceb(mf, "📋", "Copy User ID", UDim2.new(0.02, 0, 0.37, 0), bsz, function()
        if setclipboard then
            setclipboard(tostring(game.Players.LocalPlayer.UserId))
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
        local inf = "Game: " .. ms:GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if setclipboard then
            setclipboard(inf)
            fw.sa("Success", "Game info copied!", 2)
        else
            fw.sa("Info", inf, 4)
        end
    end)
    
    ceb(mf, "🔧", "Developer Console", UDim2.new(0.345, 0, 0.61, 0), bsz, function()
        sg:SetCore("DevConsoleVisible", true)
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
    
    local if_ = Instance.new("Frame", mf)
    if_.BackgroundColor3 = Color3.fromRGB(16, 19, 27)
    if_.Size = UDim2.new(0.96, 0, 0.2, 0)
    if_.Position = UDim2.new(0.02, 0, 0.75, 0)
    if_.Name = "InfoFrame"
    
    local ifCorner = Instance.new("UICorner", if_)
    ifCorner.CornerRadius = UDim.new(0, 8)
    
    local ifStroke = Instance.new("UIStroke", if_)
    ifStroke.Thickness = 1
    ifStroke.Color = Color3.fromRGB(35, 39, 54)
    
    local it = Instance.new("TextLabel", if_)
    it.Text = "ℹ️ System Information"
    it.TextSize = 16
    it.TextColor3 = Color3.fromRGB(255, 255, 255)
    it.BackgroundTransparency = 1
    it.Size = UDim2.new(0.96, 0, 0.25, 0)
    it.Position = UDim2.new(0.02, 0, 0.05, 0)
    it.TextScaled = true
    it.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    
    local itConstraint = Instance.new("UITextSizeConstraint", it)
    itConstraint.MaxTextSize = 16
    
    local ei = Instance.new("TextLabel", if_)
    ei.Text = "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown")
    ei.TextSize = 12
    ei.TextColor3 = Color3.fromRGB(200, 200, 200)
    ei.BackgroundTransparency = 1
    ei.Size = UDim2.new(0.46, 0, 0.3, 0)
    ei.Position = UDim2.new(0.02, 0, 0.35, 0)
    ei.TextScaled = true
    ei.TextXAlignment = Enum.TextXAlignment.Left
    ei.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    
    local eiConstraint = Instance.new("UITextSizeConstraint", ei)
    eiConstraint.MaxTextSize = 12
    
    local hid = gethwid and gethwid() or "Unknown"
    local hi = Instance.new("TextLabel", if_)
    hi.Text = "HWID: " .. hid:sub(1, 8) .. "..."
    hi.TextSize = 12
    hi.TextColor3 = Color3.fromRGB(200, 200, 200)
    hi.BackgroundTransparency = 1
    hi.Size = UDim2.new(0.46, 0, 0.3, 0)
    hi.Position = UDim2.new(0.52, 0, 0.35, 0)
    hi.TextScaled = true
    hi.TextXAlignment = Enum.TextXAlignment.Left
    hi.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    
    local hiConstraint = Instance.new("UITextSizeConstraint", hi)
    hiConstraint.MaxTextSize = 12
    
    local vi = Instance.new("TextLabel", if_)
    vi.Text = "FrostWare Lib V2 - Module Loaded"
    vi.TextSize = 12
    vi.TextColor3 = Color3.fromRGB(166, 190, 255)
    vi.BackgroundTransparency = 1
    vi.Size = UDim2.new(0.96, 0, 0.3, 0)
    vi.Position = UDim2.new(0.02, 0, 0.65, 0)
    vi.TextScaled = true
    vi.TextXAlignment = Enum.TextXAlignment.Center
    vi.FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    
    local viConstraint = Instance.new("UITextSizeConstraint", vi)
    viConstraint.MaxTextSize = 12
    
    upd()
end

spawn(function()
    wait(2)
    uep()
    
    local mods = {}
    
    for i, mu in pairs(mods) do
        spawn(function()
            local ok, mc = pcall(function()
                return game:HttpGet(mu)
            end)
            
            if ok then
                fw.al("Module " .. i .. " downloaded successfully", "info")
                
                local ok2, err = pcall(function()
                    loadstring(mc)()
                end)
                
                if ok2 then
                    fw.al("Module " .. i .. " executed successfully", "info")
                else
                    fw.al("Error executing module " .. i .. ": " .. tostring(err), "error")
                end
            else
                fw.al("Error downloading module " .. i .. ": " .. tostring(mc), "error")
            end
        end)
        
        wait(1)
    end
end)

local hs = game:GetService("HttpService")
local ts = game:GetService("TweenService")
local cs = "Local"
local lf, cf, csc, ss, sf = nil, nil, {}, nil, nil
local ls, aes = {}, {}
local ssr = nil
local csr = nil
local searchBox = nil
local sd = "FrostWare/Scripts/"
local aef = "FrostWare/AutoExec.json"

local ds = {
    ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
    ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
    ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
}

local function swS(sec)
    cs = sec
    if lf and cf then
        if sec == "Local" then
            lf.Visible = true
            cf.Visible = false
        else
            lf.Visible = false
            cf.Visible = true
        end
    end
end

local function svAE()
    if not isfolder("FrostWare") then makefolder("FrostWare") end
    writefile(aef, hs:JSONEncode(aes))
end

local function ldAE()
    if not isfolder("FrostWare") then makefolder(sd) end
    if isfile(aef) then
        local ok, dt = pcall(function() return hs:JSONDecode(readfile(aef)) end)
        if ok and dt then aes = dt end
    end
end

local function tgAE(nm)
    if aes[nm] then
        aes[nm] = nil
    else
        aes[nm] = true
    end
    svAE()
    upL()
end

local function exAS()
    for nm, _ in pairs(aes) do
        if ls[nm] then
            spawn(function()
                local ok, res = pcall(function() return loadstring(ls[nm]) end)
                if ok and res then pcall(res) end
            end)
        end
    end
end

local function svS(nm, cont)
    if not isfolder(sd) then makefolder(sd) end
    ls[nm] = cont
    writefile(sd .. nm .. ".lua", cont)
    local dt = {}
    for n, c in pairs(ls) do dt[n] = c end
    writefile(sd .. "scripts.json", hs:JSONEncode(dt))
    upL()
end

local function dlS(nm)
    if ds[nm] then
        fw.sa("Error", "Cannot delete default script!", 2)
        return false
    end
    
    if ls[nm] then
        if aes[nm] then
            aes[nm] = nil
            svAE()
        end
        
        ls[nm] = nil
        
        if isfile(sd .. nm .. ".lua") then
            pcall(function() delfile(sd .. nm .. ".lua") end)
        end
        
        local dt = {}
        for n, c in pairs(ls) do dt[n] = c end
        writefile(sd .. "scripts.json", hs:JSONEncode(dt))
        
        upL()
        fw.sa("Success", "Script deleted: " .. nm, 2)
        return true
    end
    return false
end

local function ldS()
    if not isfolder(sd) then makefolder(sd) end
    for nm, cont in pairs(ds) do ls[nm] = cont end
    if isfile(sd .. "scripts.json") then
        local ok, dt = pcall(function() return hs:JSONDecode(readfile(sd .. "scripts.json")) end)
        if ok and dt then
            for nm, cont in pairs(dt) do ls[nm] = cont end
        end
    end
    upL()
end

local function createScriptCard(parent, name, content, yPos)
    local scd = nf(parent, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 55),
        p = UDim2.new(0, 10, 0, yPos),
        n = "ScriptCard_" .. name
    })
    nc(scd, 0.15)
    
    local title = nt(scd, {
        t = name,
        ts = 16,
        s = UDim2.new(0.4, 0, 0.6, 0),
        p = UDim2.new(0, 15, 0, 5),
        xa = Enum.TextXAlignment.Left,
        tc = Color3.fromRGB(240, 245, 255),
        bt = 1,
        ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        n = "ScriptTitle"
    })
    ntc(title, 16)
    
    if ds[name] then
        local vb = nf(scd, {
            c = Color3.fromRGB(20, 60, 110),
            s = UDim2.new(0, 84, 0, 24),
            p = UDim2.new(0, 13, 0, 28)
        })
        nc(vb, 0.18)
        
        local vt = nt(vb, {
            t = "VERIFIED",
            ts = 10,
            tc = Color3.fromRGB(255, 255, 255),
            s = UDim2.new(1, 0, 1, 0),
            bt = 1,
            n = "VerifiedText"
        })
        ntc(vt, 10)
    end
    
    local aeb = nb(scd, {
        c = aes[name] and Color3.fromRGB(50, 170, 90) or Color3.fromRGB(65, 75, 90),
        s = UDim2.new(0, 80, 0, 25),
        p = UDim2.new(0.45, 0, 0, 15),
        t = aes[name] and "AUTO: ON" or "AUTO: OFF",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 10,
        n = "AutoExecBtn"
    })
    nc(aeb, 0.15)
    ntc(aeb, 10)
    
    local exb = nb(scd, {
        c = Color3.fromRGB(50, 170, 90),
        s = UDim2.new(0, 80, 0, 25),
        p = UDim2.new(0.65, 0, 0, 15),
        t = "EXECUTE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 11,
        n = "ExecuteBtn"
    })
    nc(exb, 0.15)
    ntc(exb, 11)
    
    local mrb = nb(scd, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0, 60, 0, 25),
        p = UDim2.new(0.85, 0, 0, 15),
        t = "MORE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 11,
        n = "MoreBtn"
    })
    nc(mrb, 0.15)
    ntc(mrb, 11)
    
    exb.MouseEnter:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(60, 180, 100) end)
    exb.MouseLeave:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(50, 170, 90) end)
    mrb.MouseEnter:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
    mrb.MouseLeave:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
    
    exb.MouseButton1Click:Connect(function()
        fw.sa("Success", name .. " executing...", 2)
        local ok, res = pcall(function() return loadstring(content) end)
        if ok and res then
            local eok, err = pcall(res)
            if eok then
                fw.sa("Success", name .. " executed!", 2)
            else
                fw.sa("Error", "Execution failed!", 3)
            end
        else
            fw.sa("Error", "Compilation failed!", 3)
        end
    end)
    
    aeb.MouseButton1Click:Connect(function() tgAE(name) end)
    mrb.MouseButton1Click:Connect(function() shSO(name, content) end)
    
    return scd
end

local function filterLocalScripts(query)
    if not query or query == "" then
        upL()
        return
    end
    
    if ssr then
        for _, ch in pairs(ssr:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        
        local filteredScripts = {}
        for nm, cont in pairs(ls) do
            if string.lower(nm):find(string.lower(query)) then
                table.insert(filteredScripts, {name = nm, content = cont})
            end
        end
        
        for i, sc in pairs(filteredScripts) do
            local yp = (i - 1) * 65 + 10
            createScriptCard(ssr, sc.name, sc.content, yp)
        end
        
        ssr.CanvasSize = UDim2.new(0, 0, 0, #filteredScripts * 65 + 20)
    end
end

function upL()
    if ssr then
        for _, ch in pairs(ssr:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        
        local scs = {}
        for nm, cont in pairs(ls) do
            table.insert(scs, {name = nm, content = cont})
        end
        
        for i, sc in pairs(scs) do
            local yp = (i - 1) * 65 + 10
            createScriptCard(ssr, sc.name, sc.content, yp)
        end
        
        ssr.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
    end
end

function shSO(nm, cont)
    if sf then sf:Destroy() end
    local ui = fw.gu()
    local mui = ui["11"]
    
    sf = nf(mui, {
        c = Color3.fromRGB(0, 0, 0),
        bt = 0.4,
        s = UDim2.new(1, 0, 1, 0),
        p = UDim2.new(0, 0, 0, 0),
        n = "ScriptOptionsOverlay",
        z = 10
    })
    
    local op = nf(sf, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(0, 400, 0, ds[nm] and 350 or 400),
        p = UDim2.new(0.5, -200, 0.5, ds[nm] and -175 or -200),
        n = "OptionsPanel"
    })
    nc(op, 0.18)
    
    local tb = nf(op, {
        c = Color3.fromRGB(30, 35, 45),
        s = UDim2.new(1, 0, 0, 50),
        p = UDim2.new(0, 0, 0, 0),
        n = "TitleBar"
    })
    
    local title = nt(tb, {
        t = "Script Options",
        ts = 18,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(0.8, 0, 1, 0),
        p = UDim2.new(0.1, 0, 0, 0),
        bt = 1,
        n = "Title"
    })
    ntc(title, 18)
    
    local cb = nb(tb, {
        c = Color3.fromRGB(190, 60, 60),
        s = UDim2.new(0, 30, 0, 30),
        p = UDim2.new(1, -40, 0, 10),
        t = "×",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 16,
        n = "CloseBtn"
    })
    nc(cb, 0.15)
    ntc(cb, 16)
    
    cb.MouseButton1Click:Connect(function()
        if sf then sf:Destroy() sf = nil end
    end)
    
    local subtitle = nt(op, {
        t = "Choose an action for: " .. nm,
        ts = 12,
        tc = Color3.fromRGB(190, 200, 220),
        s = UDim2.new(0.8, 0, 0, 40),
        p = UDim2.new(0.1, 0, 0, 60),
        ya = Enum.TextYAlignment.Top,
        bt = 1,
        n = "Subtitle"
    })
    ntc(subtitle, 12)
    
    local btns = {
        {text = "EXECUTE SCRIPT", color = Color3.fromRGB(50, 170, 90), pos = UDim2.new(0.1, 0, 0, 120)},
        {text = "OPEN IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
        {text = "SAVE TO FILE", color = Color3.fromRGB(150, 100, 200), pos = UDim2.new(0.1, 0, 0, 220)},
        {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(100, 150, 200), pos = UDim2.new(0.1, 0, 0, 270)}
    }
    
    if not ds[nm] then
        table.insert(btns, {text = "DELETE SCRIPT", color = Color3.fromRGB(200, 100, 100), pos = UDim2.new(0.1, 0, 0, 320)})
    end
    
    for i, bd in pairs(btns) do
        local btn = nb(op, {
            c = bd.color,
            s = UDim2.new(0.8, 0, 0, 35),
            p = bd.pos,
            t = bd.text,
            tc = Color3.fromRGB(255, 255, 255),
            ts = 12,
            n = "OptionBtn" .. i
        })
        nc(btn, 0.15)
        ntc(btn, 12)
        
        btn.MouseEnter:Connect(function()
            if bd.text == "DELETE SCRIPT" then
                btn.BackgroundColor3 = Color3.fromRGB(220, 120, 120)
            else
                btn.BackgroundColor3 = Color3.fromRGB(bd.color.R * 255 + 20, bd.color.G * 255 + 20, bd.color.B * 255 + 20)
            end
        end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bd.color end)
        
        if bd.text == "EXECUTE SCRIPT" then
            btn.MouseButton1Click:Connect(function()
                fw.sa("Success", nm .. " executing...", 2)
                local ok, res = pcall(function() return loadstring(cont) end)
                if ok and res then
                    local eok, err = pcall(res)
                    if eok then
                        fw.sa("Success", nm .. " executed!", 2)
                    else
                        fw.sa("Error", "Execution failed!", 3)
                    end
                else
                    fw.sa("Error", "Compilation failed!", 3)
                end
                sf:Destroy()
                sf = nil
            end)
        elseif bd.text == "OPEN IN EDITOR" then
            btn.MouseButton1Click:Connect(function()
                local ui = fw.gu()
                local sr = ui["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                if sr then
                    sr.Text = cont
                    fw.sp("Editor", ui["6"]:FindFirstChild("Sidebar"))
                    fw.sa("Success", "Script loaded to editor!", 2)
                    sf:Destroy()
                    sf = nil
                end
            end)
        elseif bd.text == "SAVE TO FILE" then
            btn.MouseButton1Click:Connect(function()
                if not isfolder("FrostWare/Exports") then makefolder("FrostWare/Exports") end
                writefile("FrostWare/Exports/" .. nm .. ".lua", cont)
                fw.sa("Success", "Script saved to file!", 2)
                sf:Destroy()
                sf = nil
            end)
        elseif bd.text == "COPY TO CLIPBOARD" then
            btn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(cont)
                    fw.sa("Success", "Script copied to clipboard!", 2)
                else
                    fw.sa("Error", "Clipboard not supported!", 3)
                end
                sf:Destroy()
                sf = nil
            end)
        elseif bd.text == "DELETE SCRIPT" then
            btn.MouseButton1Click:Connect(function()
                dlS(nm)
                sf:Destroy()
                sf = nil
            end)
        end
    end
end

local function srS(qry, mr)
    mr = mr or 20
    local ok, res = pcall(function()
        local url = "https://scriptblox.com/api/script/search?q=" .. hs:UrlEncode(qry) .. "&max=" .. mr
        return game:HttpGet(url)
    end)
    if ok then
        local dt = hs:JSONDecode(res)
        if dt.result and dt.result.scripts then
            return dt.result.scripts
        end
    end
    return {}
end

local function createCloudCard(parent, data, index)
    local yp = (index - 1) * 65 + 10
    
    local cc = nf(parent, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 55),
        p = UDim2.new(0, 10, 0, yp),
        n = "CloudCard"
    })
    nc(cc, 0.15)
    
    local title = nt(cc, {
        t = data.title or "Unknown Script",
        ts = 16,
        s = UDim2.new(0.35, 0, 0.6, 0),
        p = UDim2.new(0, 15, 0, 5),
        xa = Enum.TextXAlignment.Left,
        tc = Color3.fromRGB(240, 245, 255),
        bt = 1,
        n = "ScriptTitle"
    })
    ntc(title, 16)
    
    local vb = nf(cc, {
        c = Color3.fromRGB(20, 60, 110),
        s = UDim2.new(0, 84, 0, 24),
        p = UDim2.new(0, 13, 0, 28)
    })
    nc(vb, 0.18)
    
    local vt = nt(vb, {
        t = "VERIFIED",
        ts = 10,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(1, 0, 1, 0),
        bt = 1
    })
    ntc(vt, 10)
    
    local views = nt(cc, {
        t = (data.views or "0") .. " Views",
        ts = 12,
        tc = Color3.fromRGB(160, 170, 190),
        s = UDim2.new(0.2, 0, 0.6, 0),
        p = UDim2.new(0.4, 0, 0, 5),
        xa = Enum.TextXAlignment.Left,
        bt = 1,
        n = "ViewsLabel"
    })
    ntc(views, 12)
    
    local sb = nb(cc, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0, 100, 0, 35),
        p = UDim2.new(1, -110, 0, 10),
        t = "SELECT",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 12,
        n = "SelectBtn"
    })
    nc(sb, 0.15)
    ntc(sb, 12)
    
    sb.MouseEnter:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
    sb.MouseLeave:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
    sb.MouseButton1Click:Connect(function()
        ss = data
        shCO(data)
    end)
    
    return cc
end

function shCO(dt)
    if sf then sf:Destroy() end
    local ui = fw.gu()
    local mui = ui["11"]
    
    sf = nf(mui, {
        c = Color3.fromRGB(0, 0, 0),
        bt = 0.4,
        s = UDim2.new(1, 0, 1, 0),
        p = UDim2.new(0, 0, 0, 0),
        n = "CloudOptionsOverlay",
        z = 10
    })
    
    local op = nf(sf, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(0, 400, 0, 350),
        p = UDim2.new(0.5, -200, 0.5, -175),
        n = "OptionsPanel"
    })
    nc(op, 0.18)
    
    local tb = nf(op, {
        c = Color3.fromRGB(30, 35, 45),
        s = UDim2.new(1, 0, 0, 50),
        p = UDim2.new(0, 0, 0, 0),
        n = "TitleBar"
    })
    
    local title = nt(tb, {
        t = "Cloud Script Options",
        ts = 18,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(0.8, 0, 1, 0),
        p = UDim2.new(0.1, 0, 0, 0),
        bt = 1,
        n = "Title"
    })
    ntc(title, 18)
    
    local cb = nb(tb, {
        c = Color3.fromRGB(190, 60, 60),
        s = UDim2.new(0, 30, 0, 30),
        p = UDim2.new(1, -40, 0, 10),
        t = "×",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 16,
        n = "CloseBtn"
    })
    nc(cb, 0.15)
    ntc(cb, 16)
    
    cb.MouseButton1Click:Connect(function()
        if sf then sf:Destroy() sf = nil end
    end)
    
    local subtitle = nt(op, {
        t = "Choose an action for: " .. (dt.title or "Unknown Script"),
        ts = 12,
        tc = Color3.fromRGB(190, 200, 220),
        s = UDim2.new(0.8, 0, 0, 40),
        p = UDim2.new(0.1, 0, 0, 60),
        ya = Enum.TextYAlignment.Top,
        bt = 1,
        n = "Subtitle"
    })
    ntc(subtitle, 12)
    
    local btns = {
        {text = "EXECUTE SCRIPT", color = Color3.fromRGB(50, 170, 90), pos = UDim2.new(0.1, 0, 0, 120)},
        {text = "OPEN IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
        {text = "SAVE TO LOCAL", color = Color3.fromRGB(150, 100, 200), pos = UDim2.new(0.1, 0, 0, 220)},
        {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(100, 150, 200), pos = UDim2.new(0.1, 0, 0, 270)}
    }
    
    for i, bd in pairs(btns) do
        local btn = nb(op, {
            c = bd.color,
            s = UDim2.new(0.8, 0, 0, 35),
            p = bd.pos,
            t = bd.text,
            tc = Color3.fromRGB(255, 255, 255),
            ts = 12,
            n = "CloudOptionBtn" .. i
        })
        nc(btn, 0.15)
        ntc(btn, 12)
        
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(bd.color.R * 255 + 20, bd.color.G * 255 + 20, bd.color.B * 255 + 20) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bd.color end)
        
        if i == 1 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        fw.sa("Success", "Executing script...", 2)
                        local ok, res = pcall(function() return loadstring(sc) end)
                        if ok and res then
                            local eok, err = pcall(res)
                            if eok then
                                fw.sa("Success", "Script executed!", 2)
                            else
                                fw.sa("Error", "Execution failed!", 3)
                            end
                        else
                            fw.sa("Error", "Compilation failed!", 3)
                        end
                    else
                        fw.sa("Error", "Failed to fetch script!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            end)
        elseif i == 2 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        local ui = fw.gu()
                        local sr = ui["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                        if sr then
                            sr.Text = sc
                            fw.sp("Editor", ui["6"]:FindFirstChild("Sidebar"))
                            fw.sa("Success", "Script loaded to editor!", 2)
                        end
                    else
                        fw.sa("Error", "Failed to load script!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            end)
        elseif i == 3 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        svS(dt.title or "CloudScript_" .. tick(), sc)
                        fw.sa("Success", "Script saved!", 2)
                    else
                        fw.sa("Error", "Failed to save!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            end)
        elseif i == 4 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc and setclipboard then
                        setclipboard(sc)
                        fw.sa("Success", "Script copied!", 2)
                    else
                        fw.sa("Error", "Failed to copy!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            end)
        end
    end
end

local function dsCS(scs, sf)
    for _, ch in pairs(sf:GetChildren()) do
        if ch.Name == "CloudCard" then ch:Destroy() end
    end
    for i, sc in pairs(scs) do
        createCloudCard(sf, sc, i)
    end
    sf.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
end

local function performSearch()
    if cs == "Cloud" then
        local qry = searchBox.Text
        if qry and qry ~= "" then
            fw.sa("Info", "Searching scripts...", 1)
            spawn(function()
                local scs = srS(qry, 50)
                if #scs > 0 then
                    csc = scs
                    dsCS(scs, csr)
                    fw.sa("Success", "Found " .. #scs .. " scripts!", 2)
                else
                    fw.sa("Error", "No scripts found!", 2)
                end
            end)
        end
    elseif cs == "Local" then
        local qry = searchBox.Text
        filterLocalScripts(qry)
    end
end

local sp = nim(fw.gu()["11"], {
    it = 1,
    ic = Color3.fromRGB(15, 18, 25),
    i = "rbxassetid://18665679839",
    s = UDim2.new(1.001, 0, 1, 0),
    v = false,
    cl = true,
    bt = 1,
    n = "ScriptsPage",
    p = UDim2.new(-0.001, 0, 0, 0)
})

local tb = nf(sp, {
    c = Color3.fromRGB(25, 30, 40),
    s = UDim2.new(1, -20, 0, 60),
    p = UDim2.new(0, 10, 0, 10),
    n = "TopBar"
})
nc(tb, 0.18)

local sbo = nf(tb, {
    c = Color3.fromRGB(18, 22, 32),
    s = UDim2.new(0.5, -10, 0, 35),
    p = UDim2.new(0, 15, 0, 12),
    n = "SearchBox_Outer"
})
nc(sbo, 0.18)

searchBox = ntb(sbo, {
    c = Color3.fromRGB(35, 40, 50),
    s = UDim2.new(1, -8, 1, -8),
    p = UDim2.new(0, 4, 0, 4),
    pc = Color3.fromRGB(120, 130, 150),
    t = "",
    ts = 14,
    tc = Color3.fromRGB(240, 245, 255),
    ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    n = "SearchBox"
})
nc(searchBox, 0.15)
ntc(searchBox, 14)

local lt = nb(tb, {
    c = Color3.fromRGB(50, 130, 210),
    s = UDim2.new(0.2, -5, 0, 35),
    p = UDim2.new(0.55, 5, 0, 12),
    t = "LOCAL",
    tc = Color3.fromRGB(255, 255, 255),
    ts = 14,
    n = "LocalTab"
})
nc(lt, 0.15)
ntc(lt, 14)

local ct = nb(tb, {
    c = Color3.fromRGB(65, 75, 90),
    s = UDim2.new(0.2, -5, 0, 35),
    p = UDim2.new(0.78, 5, 0, 12),
    t = "CLOUD",
    tc = Color3.fromRGB(190, 200, 220),
    ts = 14,
    n = "CloudTab"
})
nc(ct, 0.15)
ntc(ct, 14)

lf = nf(sp, {
    bt = 1,
    s = UDim2.new(1, 0, 1, -80),
    p = UDim2.new(0, 0, 0, 80),
    n = "LocalFrame",
    v = true
})

cf = nf(sp, {
    bt = 1,
    s = UDim2.new(1, 0, 1, -80),
    p = UDim2.new(0, 0, 0, 80),
    n = "CloudFrame",
    v = false
})

local ap = nf(lf, {
    c = Color3.fromRGB(25, 30, 40),
    s = UDim2.new(1, -20, 0, 80),
    p = UDim2.new(0, 10, 0, 10),
    n = "AddPanel"
})
nc(ap, 0.18)

local nio = nf(ap, {
    c = Color3.fromRGB(18, 22, 32),
    s = UDim2.new(0.25, -5, 0, 30),
    p = UDim2.new(0, 10, 0, 10),
    n = "NameInput_Outer"
})
nc(nio, 0.18)

local ni = ntb(nio, {
    c = Color3.fromRGB(35, 40, 50),
    s = UDim2.new(1, -8, 1, -8),
    p = UDim2.new(0, 4, 0, 4),
    pc = Color3.fromRGB(120, 130, 150),
    t = "",
    ts = 12,
    tc = Color3.fromRGB(240, 245, 255),
    ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    n = "NameInput"
})
nc(ni, 0.15)
ntc(ni, 12)

local cio = nf(ap, {
    c = Color3.fromRGB(18, 22, 32),
    s = UDim2.new(0.45, -5, 0, 30),
    p = UDim2.new(0.27, 5, 0, 10),
    n = "ContentInput_Outer"
})
nc(cio, 0.18)

local ci = ntb(cio, {
    c = Color3.fromRGB(35, 40, 50),
    s = UDim2.new(1, -8, 1, -8),
    p = UDim2.new(0, 4, 0, 4),
    pc = Color3.fromRGB(120, 130, 150),
    t = "",
    ts = 12,
    tc = Color3.fromRGB(240, 245, 255),
    ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
    n = "ContentInput"
})
nc(ci, 0.15)
ntc(ci, 12)

local svb = nb(ap, {
    c = Color3.fromRGB(50, 170, 90),
    s = UDim2.new(0.12, -5, 0, 30),
    p = UDim2.new(0.74, 5, 0, 10),
    t = "SAVE",
    tc = Color3.fromRGB(255, 255, 255),
    ts = 12,
    n = "SaveBtn"
})
nc(svb, 0.15)
ntc(svb, 12)

local pb = nb(ap, {
    c = Color3.fromRGB(50, 130, 210),
    s = UDim2.new(0.12, -5, 0, 30),
    p = UDim2.new(0.88, 5, 0, 10),
    t = "PASTE",
    tc = Color3.fromRGB(255, 255, 255),
    ts = 12,
    n = "PasteBtn"
})
nc(pb, 0.15)
ntc(pb, 12)

local sc = nf(lf, {
    c = Color3.fromRGB(20, 25, 35),
    s = UDim2.new(1, -20, 1, -110),
    p = UDim2.new(0, 10, 0, 100),
    n = "ScriptsContainer"
})
nc(sc, 0.18)

local ss = nsf(sc, {
    bt = 1,
    s = UDim2.new(1, -10, 1, -10),
    p = UDim2.new(0, 5, 0, 5),
    sb = 8,
    cs = UDim2.new(0, 0, 0, 0),
    n = "ScriptsScroll",
    sic = Color3.fromRGB(50, 130, 210)
})
ssr = ss

local cc = nf(cf, {
    c = Color3.fromRGB(20, 25, 35),
    s = UDim2.new(1, -20, 1, -20),
    p = UDim2.new(0, 10, 0, 10),
    n = "CloudContainer"
})
nc(cc, 0.18)

local cs = nsf(cc, {
    bt = 1,
    s = UDim2.new(1, -10, 1, -10),
    p = UDim2.new(0, 5, 0, 5),
    cs = UDim2.new(0, 0, 0, 0),
    sb = 8,
    n = "CloudScroll",
    sic = Color3.fromRGB(50, 130, 210)
})
csr = cs

svb.MouseButton1Click:Connect(function()
    local nm = ni.Text
    local cont = ci.Text
    if nm and nm ~= "" and cont and cont ~= "" then
        svS(nm, cont)
        ni.Text = ""
        ci.Text = ""
        fw.sa("Success", "Script saved: " .. nm, 2)
    else
        fw.sa("Error", "Please enter name and content!", 2)
    end
end)

pb.MouseButton1Click:Connect(function()
    local cb = getclipboard and getclipboard() or ""
    if cb ~= "" then
        ci.Text = cb
        fw.sa("Success", "Content pasted!", 2)
    else
        fw.sa("Error", "Clipboard is empty!", 2)
    end
end)

searchBox.FocusLost:Connect(function(ep)
    if ep then
        performSearch()
    end
end)

searchBox.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Return then
        performSearch()
    end
end)

lt.MouseButton1Click:Connect(function()
    swS("Local")
    lt.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
    ct.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
end)

ct.MouseButton1Click:Connect(function()
    swS("Cloud")
    ct.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
    lt.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
end)

local sidebar = fw.gu()["6"]:FindFirstChild("Sidebar")
if sidebar then
    local scriptBtn = nf(sidebar, {
        c = Color3.fromRGB(31, 34, 50),
        s = UDim2.new(0.68, 0, 0.064, 0),
        p = UDim2.new(0.075, 0, 0.44, 0),
        n = "Scripts",
        bt = 1
    })
    nc(scriptBtn, 0.15)
    
    local box = nf(scriptBtn, {
        z = 0,
        c = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(0.15, 0, 0.6, 0),
        p = UDim2.new(0.08, 0, 0.2, 0),
        n = "Box"
    })
    nc(box, 0.2)
    nar(box, 1)
    ng(box, Color3.fromRGB(66, 79, 113), Color3.fromRGB(36, 44, 63))
    
    nim(box, {
        z = 0,
        st = Enum.ScaleType.Fit,
        i = "rbxassetid://7733779610",
        s = UDim2.new(0.6, 0, 0.6, 0),
        bt = 1,
        n = "Ico",
        p = UDim2.new(0.2, 0, 0.2, 0)
    })
    
    local lbl = nt(scriptBtn, {
        tw = true,
        ts = 16,
        xa = Enum.TextXAlignment.Left,
        ya = Enum.TextYAlignment.Top,
        sc = true,
        ff = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        tc = Color3.fromRGB(255, 255, 255),
        bt = 1,
        s = UDim2.new(0.6, 0, 0.6, 0),
        t = "Scripts",
        n = "Lbl",
        p = UDim2.new(0.3, 0, 0.2, 0)
    })
    ntc(lbl, 16)
    
    local clk = nb(scriptBtn, {
        tw = true,
        tc = Color3.fromRGB(0, 0, 0),
        ts = 12,
        sc = true,
        bt = 1,
        s = UDim2.new(1, 0, 1, 0),
        n = "Clk",
        t = "  ",
        z = 5
    })
    nc(clk, 0)
    ntc(clk, 12)
    
    clk.MouseButton1Click:Connect(function()
        fw.sp("Scripts", sidebar)
    end)
end

ldAE()
ldS()
exAS()

spawn(function()
    fw.sa("Info", "Loading popular scripts...", 1)
    local ps = srS("popular", 30)
    if #ps > 0 then
        csc = ps
        dsCS(ps, csr)
    end
end)

return true

return true
