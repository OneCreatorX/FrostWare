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

local function ci1(t, p)
    local inst = Instance.new(t)
    if p then inst.Parent = p end
    return inst
end

local function sp1(inst, props)
    for k, v in pairs(props) do
        if k == "c" then inst.BackgroundColor3 = v
        elseif k == "s" then inst.Size = v
        elseif k == "p" then inst.Position = v
        elseif k == "n" then inst.Name = v
        elseif k == "t" then inst.Text = v
        elseif k == "ts" then inst.TextSize = v
        elseif k == "tc" then inst.TextColor3 = v
        elseif k == "bt" then inst.BackgroundTransparency = v
        elseif k == "sc" then inst.TextScaled = v
        elseif k == "xa" then inst.TextXAlignment = v
        elseif k == "ya" then inst.TextYAlignment = v
        elseif k == "ff" then inst.Font = v
        elseif k == "bs" then inst.BorderSizePixel = v
        elseif k == "cs" then inst.CanvasSize = v
        elseif k == "sbt" then inst.ScrollBarThickness = v
        elseif k == "sbc" then inst.ScrollBarImageColor3 = v
        elseif k == "vis" then inst.Visible = v
        elseif k == "anc" then inst.Anchored = v
        elseif k == "cc" then inst.CanCollide = v
        elseif k == "tr" then inst.Transparency = v
        elseif k == "mat" then inst.Material = v
        elseif k == "ref" then inst.Reflectance = v
        elseif k == "fc" then inst.FillColor = v
        elseif k == "oc" then inst.OutlineColor = v
        elseif k == "ft" then inst.FillTransparency = v
        elseif k == "ot" then inst.OutlineTransparency = v
        elseif k == "dm" then inst.DepthMode = v
        elseif k == "so" then inst.StudsOffset = v
        elseif k == "ao" then inst.AlwaysOnTop = v
        elseif k == "tst" then inst.TextStrokeTransparency = v
        elseif k == "tsc" then inst.TextStrokeColor3 = v
        elseif k == "cr" then inst.CornerRadius = v
        elseif k == "ss" then inst.SliceScale = v
        elseif k == "st" then inst.SliceCenter = v
        elseif k == "img" then inst.Image = v
        elseif k == "it" then inst.ImageTransparency = v
        elseif k == "ic" then inst.ImageColor3 = v
        elseif k == "col" then inst.Color = v
        elseif k == "th" then inst.Thickness = v
        elseif k == "tr2" then inst.Transparency = v
        end
    end
    return inst
end

local function cf1(parent, props)
    return sp1(ci1("Frame", parent), props)
end

local function ct1(parent, props)
    return sp1(ci1("TextLabel", parent), props)
end

local function cb1(parent, props)
    return sp1(ci1("TextButton", parent), props)
end

local function cs1(parent, props)
    return sp1(ci1("ScrollingFrame", parent), props)
end

local function cc1_ui(parent, props)
    return sp1(ci1("UICorner", parent), props)
end

local function cst1(parent, props)
    return sp1(ci1("UIStroke", parent), props)
end

local function ch1(parent, props)
    return sp1(ci1("Highlight", parent), props)
end

local function cbg1(parent, props)
    return sp1(ci1("BillboardGui", parent), props)
end

local function us1()
    return game:GetService("UserInputService")
end

local function gs1()
    return game:GetService("UserGameSettings")
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
    
    local h = ch1(p.Character, {fc=Color3.new(1, 0.2, 0.2), oc=Color3.new(1, 1, 1), ft=0.6, ot=0, dm=Enum.HighlightDepthMode.AlwaysOnTop})
    
    local bg = cbg1(p.Character:FindFirstChild("Head"), {s=UDim2.new(0, 200, 0, 50), so=Vector3.new(0, 2, 0), ao=true})
    
    local nl = ct1(bg, {s=UDim2.new(1, 0, 0.5, 0), bt=1, t=p.Name, tc=Color3.new(1, 1, 1), sc=true, ff=Enum.Font.GothamBold, tst=0, tsc=Color3.new(0, 0, 0)})
    
    local dl = ct1(bg, {s=UDim2.new(1, 0, 0.5, 0), p=UDim2.new(0, 0, 0.5, 0), bt=1, tc=Color3.new(1, 1, 0), sc=true, ff=Enum.Font.Gotham, tst=0, tsc=Color3.new(0, 0, 0)})
    
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
            if not gp and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1) then
                local mouse = lp:GetMouse()
                if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                    local cf = CFrame.new(mouse.Hit.Position + Vector3.new(0, 5, 0))
                    lp.Character.HumanoidRootPart.CFrame = cf
                    
                    local beam = ci1("Beam", workspace)
                    local a0 = ci1("Attachment", lp.Character.HumanoidRootPart)
                    local a1 = ci1("Attachment", workspace.Terrain)
                    a1.WorldPosition = mouse.Hit.Position
                    beam.Attachment0 = a0
                    beam.Attachment1 = a1
                    beam.Color = ColorSequence.new(Color3.new(0, 1, 1))
                    beam.Width0 = 1
                    beam.Width1 = 1
                    
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
    
    fw.sa("Success", "Touch TP " .. (ctp1 and "ON" or "OFF") .. "!", 2)
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
    fw.sa("Success", "NoClip " .. (ncp1 and "ON" or "OFF") .. "!", 2)
end

local function tcam1()
    cam1 = not cam1
    local cam = workspace.CurrentCamera
    
    if cam1 then
        cam.CameraSubject = nil
        cam.CameraType = Enum.CameraType.Custom
        
        ac1 = us1().InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.ButtonY then
                spawn(function()
                    while (us1():IsKeyDown(Enum.KeyCode.W) or us1():IsKeyDown(Enum.KeyCode.ButtonY)) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(0, 0, -2)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.ButtonA then
                spawn(function()
                    while (us1():IsKeyDown(Enum.KeyCode.S) or us1():IsKeyDown(Enum.KeyCode.ButtonA)) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(0, 0, 2)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.ButtonX then
                spawn(function()
                    while (us1():IsKeyDown(Enum.KeyCode.A) or us1():IsKeyDown(Enum.KeyCode.ButtonX)) and cam1 do
                        cam.CFrame = cam.CFrame * CFrame.new(-2, 0, 0)
                        wait()
                    end
                end)
            elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.ButtonB then
                spawn(function()
                    while (us1():IsKeyDown(Enum.KeyCode.D) or us1():IsKeyDown(Enum.KeyCode.ButtonB)) and cam1 do
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
    
    fw.sa("Success", "Free Camera " .. (cam1 and "ON" or "OFF") .. "!", 2)
end

local function tgra1()
    gra1 = not gra1
    
    if gra1 then
        workspace.Gravity = 0
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local bv = ci1("BodyVelocity", lp.Character.HumanoidRootPart)
            bv.MaxForce = Vector3.new(4000, 4000, 4000)
            bv.Velocity = Vector3.new(0, 0, 0)
            
            gc1 = us1().InputBegan:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonR1 then
                    bv.Velocity = Vector3.new(0, 50, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL1 then
                    bv.Velocity = Vector3.new(0, -50, 0)
                end
            end)
            
            us1().InputEnded:Connect(function(input)
                if input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonR1 or input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.ButtonL1 then
                    if bv and bv.Parent then
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
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
    
    fw.sa("Success", "Zero Gravity " .. (gra1 and "ON" or "OFF") .. "!", 2)
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
    local f = cf1(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    cc1_ui(f, {cr=UDim.new(0, 6)})
    cst1(f, {col=Color3.fromRGB(35,39,54), th=1})
    
    local l = ct1(f, {t=t, ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    return l
end

local function csg1(p, t, pos, sz, min, max, def, cb)
    local f = cf1(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    cc1_ui(f, {cr=UDim.new(0, 8)})
    cst1(f, {col=Color3.fromRGB(35,39,54), th=1})
    
    local l = ct1(f, {t=t .. ": " .. def, ts=12, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.25,0), p=UDim2.new(0.05,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    
    local sf = cf1(f, {c=Color3.fromRGB(35,39,54), s=UDim2.new(0.9,0,0.35,0), p=UDim2.new(0.05,0,0.35,0), n="SliderFrame"})
    cc1_ui(sf, {cr=UDim.new(0, 15)})
    
    local sb = cf1(sf, {c=Color3.fromRGB(0,150,255), s=UDim2.new(0.08,0,0.8,0), p=UDim2.new(0,0,0.1,0), n="SliderButton"})
    cc1_ui(sb, {cr=UDim.new(0, 10)})
    
    local dragging = false
    local val = def
    
    local function updateSlider(input)
        if dragging then
            local relativeX = (input.Position.X - sf.AbsolutePosition.X) / sf.AbsoluteSize.X
            relativeX = math.clamp(relativeX, 0, 1)
            val = min + (max - min) * relativeX
            sb.Position = UDim2.new(relativeX - 0.04, 0, 0.1, 0)
            l.Text = t .. ": " .. math.floor(val * 100) / 100
            cb(val)
        end
    end
    
    sb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    
    us1().InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    us1().InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            updateSlider(input)
        end
    end)
    
    us1().TouchMoved:Connect(function(input)
        updateSlider(input)
    end)
    
    return f
end

local function ctg1(p, t, pos, sz, def, cb)
    local f = cf1(p, {c=Color3.fromRGB(16,19,27), s=sz, p=pos, n=t:gsub(" ","")})
    cc1_ui(f, {cr=UDim.new(0, 8)})
    cst1(f, {col=Color3.fromRGB(35,39,54), th=1})
    
    local l = ct1(f, {t=t, ts=12, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.65,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    
    local tb = cf1(f, {c=def and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.75,0,0.2,0), n="ToggleButton"})
    cc1_ui(tb, {cr=UDim.new(0.5, 0)})
    
    local tc = cf1(tb, {c=Color3.fromRGB(255,255,255), s=UDim2.new(0.35,0,0.8,0), p=def and UDim2.new(0.6,0,0.1,0) or UDim2.new(0.05,0,0.1,0), n="ToggleCircle"})
    cc1_ui(tc, {cr=UDim.new(0.5, 0)})
    
    local state = def
    
    tb.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            state = not state
            tb.BackgroundColor3 = state and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60)
            tc:TweenPosition(state and UDim2.new(0.6,0,0.1,0) or UDim2.new(0.05,0,0.1,0), "Out", "Quad", 0.2, true)
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
        tt.Size = UDim2.new(1, 0, 0.04, 0)
        tt.Position = UDim2.new(0, 0, 0.01, 0)
    end
    
    local mf = cs1(ep, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0.95,0,0.94,0), p=UDim2.new(0.025,0,0.05,0), n="MainFrame", cs=UDim2.new(0, 0, 2.2, 0), sbt=8, sbc=Color3.fromRGB(166,190,255), bs=0})
    cc1_ui(mf, {cr=UDim.new(0, 12)})
    cst1(mf, {col=Color3.fromRGB(35,39,54), th=2})
    
    local sf = cf1(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.08,0), p=UDim2.new(0.02,0,0.01,0), n="StatsFrame"})
    cc1_ui(sf, {cr=UDim.new(0, 8)})
    cst1(sf, {col=Color3.fromRGB(35,39,54), th=1})
    
    local st = ct1(sf, {t="📊 Live Stats", ts=16, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    pcl1 = csl1(sf, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    pgl1 = csl1(sf, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    fpl1 = csl1(sf, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    mml1 = csl1(sf, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    tml1 = csl1(sf, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
    
    local tf = cf1(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.46,0,0.18,0), p=UDim2.new(0.02,0,0.11,0), n="ToggleFrame"})
    cc1_ui(tf, {cr=UDim.new(0, 8)})
    cst1(tf, {col=Color3.fromRGB(35,39,54), th=1})
    
    local tft = ct1(tf, {t="🔧 Toggle Features", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.12,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    ctg1(tf, "👀 Advanced ESP", UDim2.new(0.02, 0, 0.16, 0), UDim2.new(0.96, 0, 0.08, 0), esp1, tep1)
    ctg1(tf, "🔍 Advanced X-Ray", UDim2.new(0.02, 0, 0.26, 0), UDim2.new(0.96, 0, 0.08, 0), xry1, txr1)
    ctg1(tf, "📱 Touch Teleport", UDim2.new(0.02, 0, 0.36, 0), UDim2.new(0.96, 0, 0.08, 0), ctp1, tctp1)
    ctg1(tf, "💡 Advanced Fullbright", UDim2.new(0.02, 0, 0.46, 0), UDim2.new(0.96, 0, 0.08, 0), fbr1, tfbr1)
    ctg1(tf, "😴 Anti-AFK (Always ON)", UDim2.new(0.02, 0, 0.56, 0), UDim2.new(0.96, 0, 0.08, 0), true, function() end)
    ctg1(tf, "🧊 Freeze Character", UDim2.new(0.02, 0, 0.66, 0), UDim2.new(0.96, 0, 0.08, 0), frz1, tfrz1)
    ctg1(tf, "👻 NoClip Mode", UDim2.new(0.02, 0, 0.76, 0), UDim2.new(0.96, 0, 0.08, 0), ncp1, tncp1)
    ctg1(tf, "📷 Free Camera", UDim2.new(0.02, 0, 0.86, 0), UDim2.new(0.96, 0, 0.08, 0), cam1, tcam1)
    
    local tf2 = cf1(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.46,0,0.18,0), p=UDim2.new(0.5,0,0.11,0), n="ToggleFrame2"})
    cc1_ui(tf2, {cr=UDim.new(0, 8)})
    cst1(tf2, {col=Color3.fromRGB(35,39,54), th=1})
    
    local tf2t = ct1(tf2, {t="⚡ Movement Features", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.12,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    ctg1(tf2, "🌌 Zero Gravity", UDim2.new(0.02, 0, 0.16, 0), UDim2.new(0.96, 0, 0.08, 0), gra1, tgra1)
    
    local cf = cf1(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.12,0), p=UDim2.new(0.02,0,0.31,0), n="ControlFrame"})
    cc1_ui(cf, {cr=UDim.new(0, 8)})
    cst1(cf, {col=Color3.fromRGB(35,39,54), th=1})
    
    local cft = ct1(cf, {t="🎮 Advanced Controls", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.15,0), p=UDim2.new(0.02,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    csg1(cf, "🎭 Animation Speed", UDim2.new(0.02, 0, 0.2, 0), UDim2.new(0.46, 0, 0.75, 0), 0.1, 5, ani1, sani1)
    csg1(cf, "🔭 Field of View", UDim2.new(0.52, 0, 0.2, 0), UDim2.new(0.46, 0, 0.75, 0), 30, 120, fov1, sfov1)
    
    local bsz = UDim2.new(0.18, 0, 0.04, 0)
    
    ceb1(mf, "🔄", "Rejoin", UDim2.new(0.02, 0, 0.45, 0), bsz, function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, lp)
    end)
    
    ceb1(mf, "🌐", "Server Hop", UDim2.new(0.22, 0, 0.45, 0), bsz, function()
        sh1()
    end)
    
    ceb1(mf, "📋", "Copy ID", UDim2.new(0.42, 0, 0.45, 0), bsz, function()
        if e.sc then
            e.sc(tostring(lp.UserId))
            fw.sa("Success", "ID copied!", 2)
        end
    end)
    
    ceb1(mf, "👁️", "Hide UI", UDim2.new(0.62, 0, 0.45, 0), bsz, function()
        hui1()
    end)
    
    ceb1(mf, "⚡", "Anti-Lag", UDim2.new(0.82, 0, 0.45, 0), bsz, function()
        eal1()
    end)
    
    ceb1(mf, "🧹", "Clear WS", UDim2.new(0.02, 0, 0.51, 0), bsz, function()
        cws1()
    end)
    
    ceb1(mf, "🎵", "Sound", UDim2.new(0.22, 0, 0.51, 0), bsz, function()
        ts1()
    end)
    
    ceb1(mf, "🔄", "Refresh", UDim2.new(0.42, 0, 0.51, 0), bsz, function()
        fw.hd()
        wait(0.5)
        fw.sh()
        fw.sa("Success", "UI refreshed!", 2)
    end)
    
    ceb1(mf, "📊", "Game Info", UDim2.new(0.62, 0, 0.51, 0), bsz, function()
        local inf = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if e.sc then
            e.sc(inf)
            fw.sa("Success", "Info copied!", 2)
        else
            fw.sa("Info", inf, 4)
        end
    end)
    
    ceb1(mf, "🔧", "Console", UDim2.new(0.82, 0, 0.51, 0), bsz, function()
        game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
        fw.sa("Info", "Console opened!", 2)
    end)
    
    local if1 = cf1(mf, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.96,0,0.12,0), p=UDim2.new(0.02,0,0.58,0), n="InfoFrame"})
    cc1_ui(if1, {cr=UDim.new(0, 8)})
    cst1(if1, {col=Color3.fromRGB(35,39,54), th=1})
    
    local it = ct1(if1, {t="ℹ️ System Information", ts=14, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.96,0,0.2,0), p=UDim2.new(0.02,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
    local ei = ct1(if1, {t="Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"), ts=11, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.25,0), p=UDim2.new(0.02,0,0.3,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    
    local hid = gethwid and gethwid() or "Unknown"
    local hi = ct1(if1, {t="HWID: " .. hid:sub(1, 8) .. "...", ts=11, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.46,0,0.25,0), p=UDim2.new(0.52,0,0.3,0), sc=true, xa=Enum.TextXAlignment.Left, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    
    local vi = ct1(if1, {t="FrostWare Lib V2 - Mobile Advanced Module", ts=11, tc=Color3.fromRGB(166,190,255), bt=1, s=UDim2.new(0.96,0,0.25,0), p=UDim2.new(0.02,0,0.65,0), sc=true, xa=Enum.TextXAlignment.Center, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    
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
        
        if frz1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            if not lp.Character.HumanoidRootPart.Anchored then
                lp.Character.HumanoidRootPart.Anchored = true
            end
        end
        
        if gra1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            if not lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                local bv = ci1("BodyVelocity", lp.Character.HumanoidRootPart)
                bv.MaxForce = Vector3.new(4000, 4000, 4000)
                bv.Velocity = Vector3.new(0, 0, 0)
            end
        end
        
        if esp1 then
            for _, p in pairs(game:GetService("Players"):GetPlayers()) do
                if p ~= lp and p.Character and not ec1[p] then
                    cep1(p)
                end
            end
        end
    end
end)

lp.CharacterAdded:Connect(function()
    wait(1)
    if ncp1 then
        spawn(function()
            while ncp1 and lp.Character do
                for _, part in pairs(lp.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
                wait()
            end
        end)
    end
    
    if frz1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.Anchored = true
    end
    
    if gra1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local bv = ci1("BodyVelocity", lp.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(4000, 4000, 4000)
        bv.Velocity = Vector3.new(0, 0, 0)
    end
    
    if ani1 ~= 1 and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.AnimationPlayed:Connect(function(track)
            track:AdjustSpeed(ani1)
        end)
    end
end)
