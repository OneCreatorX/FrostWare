repeat wait() until game:IsLoaded()
repeat wait() until lp
repeat wait() until lp.Character
repeat wait() until lp.Character:FindFirstChild("HumanoidRootPart")

local pcl1, pgl1, fpl1, mml1, tml1 = nil, nil, nil, nil, nil
local stt1 = tick()
local fpc1 = 0
local lfu1 = tick()

local esp1 = false
local xry1 = false
local ctp1 = false
local fbr1 = false
local aaf1 = true
local frz1 = false
local ncp1 = false
local cam1 = false
local gra1 = false
local ani1 = 1
local fov1 = 70

local ec1 = {}
local ot1 = {}
local cc1 = nil
local ac1 = nil
local gc1 = nil
local fc1 = nil
local sc1 = nil

local function us1()
    return game:GetService("UserInputService")
end

local function gs1()
    local uis = us1()
    return uis and uis:GetService("UserGameSettings")
end

local function upd1()
    spawn(function()
        rs.Heartbeat:Connect(function()
            fpc1 = fpc1 + 1
        end)
        
        while task.wait(1) do
            if pcl1 and pcl1.Parent then
                local cp = #game:GetService("Players"):GetPlayers()
                local mp = game:GetService("Players").MaxPlayers
                pcl1.Text = "👥 " .. cp .. "/" .. mp
            end
            
            if pgl1 and pgl1.Parent then
                local png = lp:GetNetworkPing() * 1000
                pgl1.Text = "📡 " .. math.floor(png) .. "ms"
            end
            
            if fpl1 and fpl1.Parent then
                local ct = tick()
                local fps = math.floor(fpc1 / (ct - lfu1))
                fpl1.Text = "🎯 " .. fps .. " FPS"
                fpc1 = 0
                lfu1 = ct
            end
            
            if mml1 and mml1.Parent then
                local mem = game:GetService("Stats"):GetTotalMemoryUsageMb()
                mml1.Text = "💾 " .. math.floor(mem) .. "MB"
            end
            
            if tml1 and tml1.Parent then
                local el = tick() - stt1
                local m = math.floor(el / 60)
                local s = math.floor(el % 60)
                tml1.Text = "⏱️ " .. m .. ":" .. string.format("%02d", s)
            end
        end
    end)
end

local function cep1(p)
    if p == lp or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local h = Instance.new("Highlight")
    h.Parent = p.Character
    h.FillColor = Color3.new(1, 0.2, 0.2)
    h.OutlineColor = Color3.new(1, 1, 1)
    h.FillTransparency = 0.6
    h.OutlineTransparency = 0
    h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    
    local bg = Instance.new("BillboardGui")
    bg.Parent = p.Character:FindFirstChild("Head")
    bg.Size = UDim2.new(0, 200, 0, 50)
    bg.StudsOffset = Vector3.new(0, 2, 0)
    bg.AlwaysOnTop = true
    
    local nl = Instance.new("TextLabel")
    nl.Parent = bg
    nl.Size = UDim2.new(1, 0, 0.5, 0)
    nl.BackgroundTransparency = 1
    nl.Text = p.Name
    nl.TextColor3 = Color3.new(1, 1, 1)
    nl.TextScaled = true
    nl.Font = Enum.Font.GothamBold
    nl.TextStrokeTransparency = 0
    nl.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    local dl = Instance.new("TextLabel")
    dl.Parent = bg
    dl.Size = UDim2.new(1, 0, 0.5, 0)
    dl.Position = UDim2.new(0, 0, 0.5, 0)
    dl.BackgroundTransparency = 1
    dl.TextColor3 = Color3.new(1, 1, 0)
    dl.TextScaled = true
    dl.Font = Enum.Font.Gotham
    dl.TextStrokeTransparency = 0
    dl.TextStrokeColor3 = Color3.new(0, 0, 0)
    
    local con = rs.Heartbeat:Connect(function()
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude
            dl.Text = math.floor(dist) .. "m"
            
            local hue = math.min(dist / 100, 1)
            h.FillColor = Color3.fromHSV(0.3 - hue * 0.3, 1, 1)
        end
    end)
    
    ec1[p] = {h, bg, con}
end

local function tep1()
    esp1 = not esp1
    
    if esp1 then
        for _, p in pairs(game:GetService("Players"):GetPlayers()) do
            cep1(p)
        end
        
        game:GetService("Players").PlayerAdded:Connect(function(p)
            if esp1 then
                p.CharacterAdded:Connect(function()
                    wait(1)
                    cep1(p)
                end)
            end
        end)
    else
        for p, objs in pairs(ec1) do
            if objs[1] then objs[1]:Destroy() end
            if objs[2] then objs[2]:Destroy() end
            if objs[3] then objs[3]:Disconnect() end
        end
        ec1 = {}
    end
    
    fw.sa("Success", "Advanced ESP " .. (esp1 and "ON" or "OFF") .. "!", 2)
end

local function txr1()
    xry1 = not xry1
    
    if xry1 then
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and not game:GetService("Players"):GetPlayerFromCharacter(obj.Parent) then
                ot1[obj] = {obj.Transparency, obj.CanCollide}
                obj.Transparency = 0.8
                obj.CanCollide = false
                obj.Material = Enum.Material.ForceField
            end
        end
    else
        for obj, props in pairs(ot1) do
            if obj and obj.Parent then
                obj.Transparency = props[1]
                obj.CanCollide = props[2]
                obj.Material = Enum.Material.Plastic
            end
        end
        ot1 = {}
    end
    
    fw.sa("Success", "Advanced X-Ray " .. (xry1 and "ON" or "OFF") .. "!", 2)
end

local function tctp1()
    ctp1 = not ctp1
    
    if ctp1 then
        cc1 = us1().InputBegan:Connect(function(input, gp)
            if not gp and input.UserInputType == Enum.UserInputType.MouseButton1 and us1():IsKeyDown(Enum.KeyCode.LeftControl) then
                local mouse = lp:GetMouse()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local cf = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    lp.Character.HumanoidRootPart.CFrame = cf
                    
                    local beam = Instance.new("Beam")
                    local a0 = Instance.new("Attachment", lp.Character.HumanoidRootPart)
                    local a1 = Instance.new("Attachment", workspace.Terrain)
                    a1.WorldPosition = mouse.Hit.Position
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Color = ColorSequence.new(Color3.new(0, 1, 1))
                    beam.Width0 = 1
                    beam.Width1 = 1
                    beam.Parent = workspace
                    
                    spawn(function()
                        wait(0.5)
                        beam:Destroy()
                        a0:Destroy()
                        a1:Destroy()
                    end)
                end
            end
        end)
    else
        if cc1 then
            cc1:Disconnect()
            cc1 = nil
        end
    end
    
    fw.sa("Success", "Click TP " .. (ctp1 and "ON (Ctrl+Click)" or "OFF") .. "!", 2)
end

local function tfbr1()
    fbr1 = not fbr1
    local lt = game:GetService("Lighting")
    
    if fbr1 then
        lt.Brightness = 3
        lt.ClockTime = 12
        lt.FogEnd = 1e10
        lt.GlobalShadows = false
        lt.OutdoorAmbient = Color3.new(1, 1, 1)
        lt.Ambient = Color3.new(1, 1, 1)
        lt.ColorShift_Bottom = Color3.new(1, 1, 1)
        lt.ColorShift_Top = Color3.new(1, 1, 1)
        
        for _, obj in pairs(lt:GetChildren()) do
            if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                obj.Enabled = false
            end
        end
        
        workspace.CurrentCamera.ColorCorrection.Brightness = 0.3
        workspace.CurrentCamera.ColorCorrection.Contrast = 0.2
        workspace.CurrentCamera.ColorCorrection.Saturation = 0
    else
        lt.Brightness = 1
        lt.ClockTime = 14
        lt.FogEnd = 100000
        lt.GlobalShadows = true
        lt.OutdoorAmbient = Color3.fromRGB(70, 70, 70)
        lt.Ambient = Color3.fromRGB(128, 128, 128)
        lt.ColorShift_Bottom = Color3.new(0, 0, 0)
        lt.ColorShift_Top = Color3.new(0, 0, 0)
        
        workspace.CurrentCamera.ColorCorrection.Brightness = 0
        workspace.CurrentCamera.ColorCorrection.Contrast = 0
        workspace.CurrentCamera.ColorCorrection.Saturation = 0
    end
    
    fw.sa("Success", "Advanced Fullbright " .. (fbr1 and "ON" or "OFF") .. "!", 2)
end

local function aaf1_init()
    local vu = game:GetService("VirtualUser")
    lp.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end

local function tfrz1()
    frz1 = not frz1
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.Anchored = frz1
        fw.sa("Success", "Character " .. (frz1 and "FROZEN" or "UNFROZEN") .. "!", 2)
    end
end

local function tncp1()
    ncp1 = not ncp1
    if lp.Character then
        for _, part in pairs(lp.Character:GetChildren()) do
            if part:IsA("BasePart") then
                part.CanCollide = not ncp1
            end
        end
        fw.sa("Success", "NoClip " .. (ncp1 and "ON" or "OFF") .. "!", 2)
    end
end

local function tcam1()
    cam1 = not cam1
    local cam = workspace.CurrentCamera
    
    if cam1 then
        cam.CameraSubject = nil
        cam.CameraType = Enum.CameraType.Custom
        
        ac1 = us1().InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W then
                spawn(function()
                    while us1():IsKeyDown(Enum.KeyCode.W) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(0, 0, -2)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.S then
                spawn(function()
                    while us1():IsKeyDown(Enum.KeyCode.S) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(0, 0, 2)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.A then
                spawn(function()
                    while us1():IsKeyDown(Enum.KeyCode.A) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(-2, 0, 0)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.D then
                spawn(function()
                    while us1():IsKeyDown(Enum.KeyCode.D) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(2, 0, 0)
                        wait()
                    end
                end)
            end
        end)
    else
        if ac1 then ac1:Disconnect() ac1 = nil end
        cam.CameraSubject = lp.Character and lp.Character:FindFirstChild("Humanoid")
        cam.CameraType = Enum.CameraType.Custom
    end
    
    fw.sa("Success", "Free Camera " .. (cam1 and "ON (WASD)" or "OFF") .. "!", 2)
end

local function tgra1()
    gra1 = not gra1
    
    if gra1 then
        workspace.Gravity = 0
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            bv.Parent = lp.Character.HumanoidRootPart
            
            gc1 = us1().InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space then
                    bv.Velocity = Vector3.new(0, 50, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftShift then
                    bv.Velocity = Vector3.new(0, -50, 0)
                end
            end)
            
            us1().InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftShift then
                    bv.Velocity = Vector3.new(0, 0, 0)
                end
            end)
        end
    else
        workspace.Gravity = 196.2
        if gc1 then gc1:Disconnect() gc1 = nil end
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local bv = lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then bv:Destroy() end
        end
    end
    
    fw.sa("Success", "Zero Gravity " .. (gra1 and "ON (Space/Shift)" or "OFF") .. "!", 2)
end

local function sani1(val)
    ani1 = val
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        for _, track in pairs(lp.Character.Humanoid:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(ani1)
        end
    end
end

local function sfov1(val)
    fov1 = val
    workspace.CurrentCamera.FieldOfView = fov1
end

local function hui1()
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

local function eal1()
    local uset = gs1()
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
    
    for _, obj in pairs(ws:GetDescendants()) do
        pcall(function()
            if obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end)
    end
    
    fw.sa("Success", "Extreme anti-lag applied!", 2)
end

local function ceb1(p, e, t, pos, sz, cb)
    local btn = fw.csb(p, t:gsub(" ", ""), t, e, pos, sz)
    btn.MouseButton1Click:Connect(cb)
    return btn
end

local function csl1(p, t, pos, sz)
    local f = nf(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    nc(f, 0.06)
    ns(f, 1, Color3.fromRGB(35,39,54))
    
    local l = nt(f, {t=t, ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(l, 14)
    
    return l
end

local function csg1(p, t, pos, sz, min, max, def, cb)
    local f = nf(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    nc(f, 0.06)
    ns(f, 1, Color3.fromRGB(35,39,54))
    
    local l = nt(f, {t=t .. ": " .. def, ts=12, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.3,0), p=UDim2.new(0.05,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(l, 12)
    
    local sf = nf(f, {c=Color3.fromRGB(35,39,54), s=UDim2.new(0.9,0,0.4,0), p=UDim2.new(0.05,0,0.4,0), n="SliderFrame"})
    nc(sf, 0.04)
    
    local sb = nf(sf, {c=Color3.fromRGB(0,150,255), s=UDim2.new(0.05,0,0.8,0), p=UDim2.new(0,0,0.1,0), n="SliderButton"})
    nc(sb, 0.02)
    
    local dragging = false
    local val = def
    
    sb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    us1().InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    us1().InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mouse = lp:GetMouse()
            local rel = (mouse.X - sf.AbsolutePosition.X) / sf.AbsoluteSize.X
            rel = math.clamp(rel, 0, 1)
            val = min + (max - min) * rel
            sb.Position = UDim2.new(rel - 0.025, 0, 0.1, 0)
            l.Text = t .. ": " .. math.floor(val * 100) / 100
            cb(val)
        end
    end)
    
    return f
end

local function ctg1(p, t, pos, sz, def, cb)
    local f = nf(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    nc(f, 0.06)
    ns(f, 1, Color3.fromRGB(35,39,54))
    
    local l = nt(f, {t=t, ts=12, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.7,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(l, 12)
    
    local tb = nf(f, {c=def and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60), s=UDim2.new(0.15,0,0.6,0), p=UDim2.new(0.8,0,0.2,0), n="ToggleButton"})
    nc(tb, 0.3)
    
    local tc = nf(tb, {c=Color3.fromRGB(255,255,255), s=UDim2.new(0.4,0,0.8,0), p=def and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.05,0,0.1,0), n="ToggleCircle"})
    nc(tc, 0.5)
    
    local state = def
    
    tb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            tb.BackgroundColor3 = state and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60)
            tc:TweenPosition(state and UDim2.new(0.55,0,0.1,0) or UDim2.new(0.05,0,0.1,0), "Out", "Quad", 0.2, true)
            cb(state)
        end
    end)
    
    return f
end

local function sh1()
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

local function cws1()
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

local function ts1()
    local uset = gs1()
    if uset then
        if uset.MasterVolume > 0 then
            uset.MasterVolume = 0
            fw.sa("Info", "Sound OFF!", 2)
        else
            uset.MasterVolume = 1
            fw.sa("Info", "Sound ON!", 2)
        end
    end
end

local function uep1()
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
        tt.Text = "🛠️ Advanced System Tools"
        tt.Size = UDim2.new(1, 0, 0.05, 0)
        tt.Position = UDim2.new(0, 0, 0.01, 0)
    end
    
    local mf = nf(ep, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0.95,0,0.93,0), p=UDim2.new(0.025,0,0.06,0), n="MainFrame"})
    nc(mf, 0.08)
    ns(mf, 2, Color3.fromRGB(35,39,54))
    
    local sf = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.12,0), p=UDim2.new(0.02,0,0.02,0), n="StatsFrame"})
    nc(sf, 0.08)
    ns(sf, 1, Color3.fromRGB(35,39,54))
    
    local st = nt(sf, {t="📊 Live Stats", ts=16, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(st, 16)
    
    pcl1 = csl1(sf, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    pgl1 = csl1(sf, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    fpl1 = csl1(sf, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    mml1 = csl1(sf, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    tml1 = csl1(sf, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
    
    local tf = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.46,0,0.25,0), p=UDim2.new(0.02,0,0.16,0), n="ToggleFrame"})
    nc(tf, 0.08)
    ns(tf, 1, Color3.fromRGB(35,39,54))
    
    local tft = nt(tf, {t="🔧 Toggle Features", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.15,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tft, 14)
    
    ctg1(tf, "👀 Advanced ESP", UDim2.new(0.02, 0, 0.2, 0), UDim2.new(0.96, 0, 0.12, 0), esp1, tep1)
    ctg1(tf, "🔍 Advanced X-Ray", UDim2.new(0.02, 0, 0.34, 0), UDim2.new(0.96, 0, 0.12, 0), xry1, txr1)
    ctg1(tf, "🖱️ Click Teleport", UDim2.new(0.02, 0, 0.48, 0), UDim2.new(0.96, 0, 0.12, 0), ctp1, tctp1)
    ctg1(tf, "💡 Advanced Fullbright", UDim2.new(0.02, 0, 0.62, 0), UDim2.new(0.96, 0, 0.12, 0), fbr1, tfbr1)
    ctg1(tf, "😴 Anti-AFK (Always ON)", UDim2.new(0.02, 0, 0.76, 0), UDim2.new(0.96, 0, 0.12, 0), true, function() end)
    
    local tf2 = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.46,0,0.25,0), p=UDim2.new(0.5,0,0.16,0), n="ToggleFrame2"})
    nc(tf2, 0.08)
    ns(tf2, 1, Color3.fromRGB(35,39,54))
    
    local tf2t = nt(tf2, {t="⚡ Movement Features", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.15,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tf2t, 14)
    
    ctg1(tf2, "🧊 Freeze Character", UDim2.new(0.02, 0, 0.2, 0), UDim2.new(0.96, 0, 0.12, 0), frz1, tfrz1)
    ctg1(tf2, "👻 NoClip Mode", UDim2.new(0.02, 0, 0.34, 0), UDim2.new(0.96, 0, 0.12, 0), ncp1, tncp1)
    ctg1(tf2, "📷 Free Camera", UDim2.new(0.02, 0, 0.48, 0), UDim2.new(0.96, 0, 0.12, 0), cam1, tcam1)
    ctg1(tf2, "🌌 Zero Gravity", UDim2.new(0.02, 0, 0.62, 0), UDim2.new(0.96, 0, 0.12, 0), gra1, tgra1)
    
    local cf = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.18,0), p=UDim2.new(0.02,0,0.43,0), n="ControlFrame"})
    nc(cf, 0.08)
    ns(cf, 1, Color3.fromRGB(35,39,54))
    
    local cft = nt(cf, {t="🎮 Advanced Controls", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.2,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(cft, 14)
    
    csg1(cf, "🎭 Animation Speed", UDim2.new(0.02, 0, 0.25, 0), UDim2.new(0.46, 0, 0.7, 0), 0.1, 5, ani1, sani1)
    csg1(cf, "🔭 Field of View", UDim2.new(0.52, 0, 0.25, 0), UDim2.new(0.46, 0, 0.7, 0), 30, 120, fov1, sfov1)
    
    local bsz = UDim2.new(0.19, 0, 0.06, 0)
    
    ceb1(mf, "🔄", "Rejoin", UDim2.new(0.02, 0, 0.63, 0), bsz, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
    end)
    
    ceb1(mf, "🌐", "Server Hop", UDim2.new(0.22, 0, 0.63, 0), bsz, function()
        sh1()
    end)
    
    ceb1(mf, "📋", "Copy ID", UDim2.new(0.42, 0, 0.63, 0), bsz, function()
        if e.sc then
            e.sc(tostring(lp.UserId))
            fw.sa("Success", "ID copied!", 2)
        end
    end)
    
    ceb1(mf, "👁️", "Hide UI", UDim2.new(0.62, 0, 0.63, 0), bsz, function()
        hui1()
    end)
    
    ceb1(mf, "⚡", "Anti-Lag", UDim2.new(0.82, 0, 0.63, 0), bsz, function()
        eal1()
    end)
    
    ceb1(mf, "🧹", "Clear WS", UDim2.new(0.02, 0, 0.71, 0), bsz, function()
        cws1()
    end)
    
    ceb1(mf, "🎵", "Sound", UDim2.new(0.22, 0, 0.71, 0), bsz, function()
        ts1()
    end)
    
    ceb1(mf, "🔄", "Refresh", UDim2.new(0.42, 0, 0.71, 0), bsz, function()
        fw.hd()
        wait(0.5)
        fw.sh()
        fw.sa("Success", "UI refreshed!", 2)
    end)
    
    ceb1(mf, "📊", "Game Info", UDim2.new(0.62, 0, 0.71, 0), bsz, function()
        local inf = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if e.sc then
            e.sc(inf)
            fw.sa("Success", "Info copied!", 2)
        else
            fw.sa("Info", inf, 4)
        end
    end)
    
    ceb1(mf, "🔧", "Console", UDim2.new(0.82, 0, 0.71, 0), bsz, function()
        game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
        fw.sa("Info", "Console opened!", 2)
    end)
    
    local if1 = nf(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.18,0), p=UDim2.new(0.02,0,0.8,0), n="InfoFrame"})
    nc(if1, 0.08)
    ns(if1, 1, Color3.fromRGB(35,39,54))
    
    local it = nt(if1, {t="ℹ️ System Information", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(it, 14)
    
    local ei = nt(if1, {t="Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"), ts=11, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.3,0), p=UDim2.new(0.02,0,0.35,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(ei, 11)
    
    local hid = gethwid and gethwid() or "Unknown"
    local hi = nt(if1, {t="HWID: " .. hid:sub(1, 8) .. "...", ts=11, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.3,0), p=UDim2.new(0.52,0,0.35,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(hi, 11)
    
    local vi = nt(if1, {t="FrostWare Lib V2 - Advanced Module Loaded", ts=11, tc=Color3.fromRGB(166,190,255), bt=1, s=UDim2.new(0.96,0,0.3,0), p=UDim2.new(0.02,0,0.65,0), sc=true, xa=Enum.TextXAlignment.Center, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(vi, 11)
    
    upd1()
end

aaf1_init()

spawn(function()
    wait(2)
    uep1()
end)

spawn(function()
    while wait() do
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            for _, track in pairs(lp.Character.Humanoid:GetPlayingAnimationTracks()) do
                if track.Speed ~= ani1 then
                    track:AdjustSpeed(ani1)
                end
            end
        end
        
        if ncp1 and lp.Character then
            for _, part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end
end)
