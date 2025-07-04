local h = gethwid()
local r = request or http_request or syn_request

local originalLighting = {}
local originalCamera = {}
local ambientEffects = {}
local soundEffects = {}

local function saveOriginalSettings()
    local lighting = game:GetService("Lighting")
    local camera = workspace.CurrentCamera
    
    originalLighting = {
        Brightness = lighting.Brightness,
        Ambient = lighting.Ambient,
        ColorShift_Bottom = lighting.ColorShift_Bottom,
        ColorShift_Top = lighting.ColorShift_Top,
        OutdoorAmbient = lighting.OutdoorAmbient,
        ShadowSoftness = lighting.ShadowSoftness,
        ClockTime = lighting.ClockTime,
        FogEnd = lighting.FogEnd,
        FogStart = lighting.FogStart,
        FogColor = lighting.FogColor
    }
    
    originalCamera = {
        FieldOfView = camera.FieldOfView
    }
end

local function createAmbientEffects()
    local lighting = game:GetService("Lighting")
    local camera = workspace.CurrentCamera
    local tweenService = game:GetService("TweenService")
    
    lighting.Brightness = 0.5
    lighting.Ambient = Color3.fromRGB(0, 50, 100)
    lighting.ColorShift_Bottom = Color3.fromRGB(0, 100, 200)
    lighting.ColorShift_Top = Color3.fromRGB(100, 0, 200)
    lighting.OutdoorAmbient = Color3.fromRGB(0, 100, 150)
    lighting.ShadowSoftness = 1
    lighting.ClockTime = 0
    lighting.FogEnd = 500
    lighting.FogStart = 100
    lighting.FogColor = Color3.fromRGB(0, 50, 100)
    
    local colorCorrection = Instance.new("ColorCorrectionEffect")
    colorCorrection.Brightness = -0.1
    colorCorrection.Contrast = 0.2
    colorCorrection.Saturation = 0.3
    colorCorrection.TintColor = Color3.fromRGB(0, 200, 255)
    colorCorrection.Parent = lighting
    table.insert(ambientEffects, colorCorrection)
    
    local bloom = Instance.new("BloomEffect")
    bloom.Intensity = 0.8
    bloom.Size = 15
    bloom.Threshold = 0.5
    bloom.Parent = lighting
    table.insert(ambientEffects, bloom)
    
    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Intensity = 0.3
    sunRays.Spread = 0.8
    sunRays.Parent = lighting
    table.insert(ambientEffects, sunRays)
    
    for i = 1, 15 do
        spawn(function()
            local particle = Instance.new("Part")
            particle.Name = "FrostParticle"
            particle.Size = Vector3.new(0.5, 0.5, 0.5)
            particle.Material = Enum.Material.Neon
            particle.BrickColor = BrickColor.new("Cyan")
            particle.Anchored = true
            particle.CanCollide = false
            particle.Shape = Enum.PartType.Ball
            particle.Parent = workspace
            table.insert(ambientEffects, particle)
            
            local light = Instance.new("PointLight")
            light.Color = Color3.fromRGB(0, 255, 255)
            light.Brightness = 2
            light.Range = 10
            light.Parent = particle
            
            while particle.Parent do
                local randomPos = camera.CFrame.Position + Vector3.new(
                    math.random(-50, 50),
                    math.random(10, 30),
                    math.random(-50, 50)
                )
                particle.Position = randomPos
                
                tweenService:Create(particle, TweenInfo.new(
                    math.random(3, 8),
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true
                ), {
                    Position = randomPos + Vector3.new(
                        math.random(-20, 20),
                        math.random(-10, 10),
                        math.random(-20, 20)
                    )
                }):Play()
                
                tweenService:Create(light, TweenInfo.new(
                    2,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true
                ), {
                    Brightness = math.random(1, 3)
                }):Play()
                
                wait(math.random(1, 3))
            end
        end)
    end
    
    spawn(function()
        while #ambientEffects > 0 do
            tweenService:Create(camera, TweenInfo.new(
                0.1,
                Enum.EasingStyle.Linear
            ), {
                FieldOfView = originalCamera.FieldOfView + math.random(-1, 1)
            }):Play()
            wait(0.1)
        end
    end)
end

local function restoreOriginalSettings()
    local lighting = game:GetService("Lighting")
    local camera = workspace.CurrentCamera
    local tweenService = game:GetService("TweenService")
    
    for _, effect in pairs(ambientEffects) do
        if effect and effect.Parent then
            effect:Destroy()
        end
    end
    ambientEffects = {}
    
    for property, value in pairs(originalLighting) do
        lighting[property] = value
    end
    
    camera.FieldOfView = originalCamera.FieldOfView
    
    for _, sound in pairs(soundEffects) do
        if sound and sound.Parent then
            sound:Stop()
            sound:Destroy()
        end
    end
    soundEffects = {}
end

local function createAmbientSounds()
    local soundService = game:GetService("SoundService")
    
    local ambientSound = Instance.new("Sound")
    ambientSound.SoundId = "rbxasset://sounds/electronicpingshort.wav"
    ambientSound.Volume = 0.3
    ambientSound.Looped = true
    ambientSound.Pitch = 0.5
    ambientSound.Parent = soundService
    ambientSound:Play()
    table.insert(soundEffects, ambientSound)
    
    local pulseSound = Instance.new("Sound")
    pulseSound.SoundId = "rbxasset://sounds/button_rollover.wav"
    pulseSound.Volume = 0.2
    pulseSound.Pitch = 0.3
    pulseSound.Parent = soundService
    table.insert(soundEffects, pulseSound)
    
    spawn(function()
        while #soundEffects > 0 do
            pulseSound:Play()
            wait(math.random(3, 7))
        end
    end)
end

local function ca()
    local s, res = pcall(function()
        return r({
            Url = getgenv()._frostw .. "/status/" .. h,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if s and res and res.StatusCode == 200 then
        local t = tonumber(res.Body) or 0
        local ha = t > 0
        local hr = math.floor(t / 3600)
        return ha, {hr = hr, t = t}
    end
    return false, nil
end

local function cl()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FW_L_" .. tostring(math.random(10000, 99999))
    sg.Parent = gethui()
    sg.ResetOnSpawn = false
    
    saveOriginalSettings()
    createAmbientEffects()
    createAmbientSounds()
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.Parent = sg
    
    local ps = {}
    for i = 1, 20 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, 3, 0, 3)
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        p.BorderSizePixel = 0
        p.BackgroundTransparency = math.random(70, 90) / 100
        p.Parent = bg
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = p
        
        table.insert(ps, p)
    end
    
    local hexagon = Instance.new("Frame")
    hexagon.Size = UDim2.new(0.4, 0, 0.4, 0)
    hexagon.Position = UDim2.new(0.3, 0, 0.3, 0)
    hexagon.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    hexagon.BackgroundTransparency = 0.97
    hexagon.BorderSizePixel = 0
    hexagon.Parent = bg
    hexagon.Rotation = 30
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0.15, 0)
    hc.Parent = hexagon
    
    local hs = Instance.new("UIStroke")
    hs.Color = Color3.fromRGB(0, 255, 255)
    hs.Thickness = 2
    hs.Transparency = 0.4
    hs.Parent = hexagon
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0.8, 0, 0.15, 0)
    l.Position = UDim2.new(0.1, 0, 0.25, 0)
    l.BackgroundTransparency = 1
    l.Text = "❄️ FROSTWARE"
    l.TextColor3 = Color3.fromRGB(0, 255, 255)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.TextStrokeTransparency = 0.3
    l.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)
    l.Parent = bg
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0.6, 0, 0.08, 0)
    st.Position = UDim2.new(0.2, 0, 0.42, 0)
    st.BackgroundTransparency = 1
    st.Text = "QUANTUM SYSTEM"
    st.TextColor3 = Color3.fromRGB(255, 0, 255)
    st.TextScaled = true
    st.Font = Enum.Font.Gotham
    st.Parent = bg
    
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(0.5, 0, 0.06, 0)
    lt.Position = UDim2.new(0.25, 0, 0.65, 0)
    lt.BackgroundTransparency = 1
    lt.Text = "Initializing quantum protocols..."
    lt.TextColor3 = Color3.fromRGB(0, 255, 127)
    lt.TextScaled = true
    lt.Font = Enum.Font.Gotham
    lt.Parent = bg
    
    local orb = Instance.new("Frame")
    orb.Size = UDim2.new(0.12, 0, 0.12, 0)
    orb.Position = UDim2.new(0.44, 0, 0.44, 0)
    orb.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    orb.BackgroundTransparency = 0.7
    orb.BorderSizePixel = 0
    orb.Parent = bg
    
    local oc = Instance.new("UICorner")
    oc.CornerRadius = UDim.new(1, 0)
    oc.Parent = orb
    
    local og = Instance.new("UIGradient")
    og.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 127))
    }
    og.Parent = orb
    
    local os = Instance.new("UIStroke")
    os.Color = Color3.fromRGB(255, 255, 255)
    os.Thickness = 2
    os.Transparency = 0.5
    os.Parent = orb
    
    l.TextTransparency = 1
    st.TextTransparency = 1
    lt.TextTransparency = 1
    orb.BackgroundTransparency = 1
    hexagon.BackgroundTransparency = 1
    
    local ts = game:GetService("TweenService")
    
    ts:Create(l, TweenInfo.new(1.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    wait(0.4)
    ts:Create(st, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    ts:Create(hexagon, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.97}):Play()
    wait(0.6)
    ts:Create(orb, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {BackgroundTransparency = 0.7}):Play()
    ts:Create(lt, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    
    local ss = {
        "Connecting to quantum servers...",
        "Verifying neural pathways...",
        "Loading security matrices...",
        "Checking access permissions...",
        "Finalizing initialization..."
    }
    
    for i, s in ipairs(ss) do
        lt.Text = s
        local pulse = ts:Create(orb, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(0.14, 0, 0.14, 0), 
            Position = UDim2.new(0.43, 0, 0.43, 0)
        })
        pulse:Play()
        pulse.Completed:Connect(function()
            ts:Create(orb, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0.12, 0, 0.12, 0), 
                Position = UDim2.new(0.44, 0, 0.44, 0)
            }):Play()
        end)
        wait(1)
    end
    
    spawn(function()
        while sg.Parent do
            ts:Create(hexagon, TweenInfo.new(8, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = hexagon.Rotation + 360}):Play()
            ts:Create(og, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Rotation = og.Rotation + 180}):Play()
            for _, p in ipairs(ps) do
                if p.Parent then
                    ts:Create(p, TweenInfo.new(math.random(4, 10), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
                        Position = UDim2.new(math.random(), 0, math.random(), 0),
                        BackgroundTransparency = math.random(70, 90) / 100
                    }):Play()
                end
            end
            wait(3)
        end
    end)
    
    wait(1.5)
    
    local fo = ts:Create(bg, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
    fo:Play()
    fo.Completed:Connect(function()
        sg:Destroy()
    end)
end

local function cm()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FW_M_" .. tostring(math.random(10000, 99999))
    sg.Parent = gethui()
    sg.ResetOnSpawn = false
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundTransparency = 1
    bg.BorderSizePixel = 0
    bg.Parent = sg
    
    local particles = {}
    for i = 1, 25 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, 2, 0, 2)
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
        p.BorderSizePixel = 0
        p.BackgroundTransparency = math.random(70, 90) / 100
        p.Parent = bg
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = p
        
        table.insert(particles, p)
    end
    
    local mainContainer = Instance.new("Frame")
    mainContainer.Size = UDim2.new(0.85, 0, 0.75, 0)
    mainContainer.Position = UDim2.new(0.075, 0, 0.125, 0)
    mainContainer.BackgroundTransparency = 1
    mainContainer.Parent = sg
    
    local hexFrame = Instance.new("Frame")
    hexFrame.Size = UDim2.new(1, 0, 1, 0)
    hexFrame.BackgroundTransparency = 1
    hexFrame.BorderSizePixel = 0
    hexFrame.Parent = mainContainer
    
    local hs = Instance.new("UIStroke")
    hs.Color = Color3.fromRGB(0, 255, 255)
    hs.Thickness = 3
    hs.Transparency = 0.3
    hs.Parent = hexFrame
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0.08, 0)
    hc.Parent = hexFrame
    
    local topOrb = Instance.new("Frame")
    topOrb.Size = UDim2.new(0.12, 0, 0.12, 0)
    topOrb.Position = UDim2.new(0.44, 0, -0.06, 0)
    topOrb.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    topOrb.BackgroundTransparency = 0.2
    topOrb.BorderSizePixel = 0
    topOrb.Parent = hexFrame
    
    local toc = Instance.new("UICorner")
    toc.CornerRadius = UDim.new(1, 0)
    toc.Parent = topOrb
    
    local tog = Instance.new("UIGradient")
    tog.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 255, 127))
    }
    tog.Parent = topOrb
    
    local tos = Instance.new("UIStroke")
    tos.Color = Color3.fromRGB(255, 255, 255)
    tos.Thickness = 2
    tos.Transparency = 0.4
    tos.Parent = topOrb
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.8, 0, 0.15, 0)
    title.Position = UDim2.new(0.1, 0, 0.08, 0)
    title.BackgroundTransparency = 1
    title.Text = "❄️ FROSTWARE"
    title.TextColor3 = Color3.fromRGB(0, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextStrokeTransparency = 0.5
    title.TextStrokeColor3 = Color3.fromRGB(255, 0, 255)
    title.Parent = hexFrame
    
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(0.7, 0, 0.08, 0)
    subtitle.Position = UDim2.new(0.15, 0, 0.22, 0)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "QUANTUM ACCESS SYSTEM"
    subtitle.TextColor3 = Color3.fromRGB(255, 0, 255)
    subtitle.TextScaled = true
    subtitle.Font = Enum.Font.Gotham
    subtitle.Parent = hexFrame
    
    local statusContainer = Instance.new("Frame")
    statusContainer.Size = UDim2.new(0.85, 0, 0.18, 0)
    statusContainer.Position = UDim2.new(0.075, 0, 0.32, 0)
    statusContainer.BackgroundTransparency = 1
    statusContainer.BorderSizePixel = 0
    statusContainer.Parent = hexFrame
    
    local scs = Instance.new("UIStroke")
    scs.Color = Color3.fromRGB(255, 100, 100)
    scs.Thickness = 2
    scs.Transparency = 0.5
    scs.Parent = statusContainer
    
    local scc = Instance.new("UICorner")
    scc.CornerRadius = UDim.new(0.15, 0)
    scc.Parent = statusContainer
    
    local statusIcon = Instance.new("TextLabel")
    statusIcon.Size = UDim2.new(0.2, 0, 0.6, 0)
    statusIcon.Position = UDim2.new(0.05, 0, 0.2, 0)
    statusIcon.BackgroundTransparency = 1
    statusIcon.Text = "🔒"
    statusIcon.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusIcon.TextScaled = true
    statusIcon.Font = Enum.Font.Gotham
    statusIcon.Parent = statusContainer
    
    local statusText = Instance.new("TextLabel")
    statusText.Size = UDim2.new(0.7, 0, 0.6, 0)
    statusText.Position = UDim2.new(0.25, 0, 0.2, 0)
    statusText.BackgroundTransparency = 1
    statusText.Text = "Access Required - Complete verification"
    statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
    statusText.TextScaled = true
    statusText.Font = Enum.Font.Gotham
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.TextWrapped = true
    statusText.Parent = statusContainer
    
    local instructionsFrame = Instance.new("Frame")
    instructionsFrame.Size = UDim2.new(0.85, 0, 0.22, 0)
    instructionsFrame.Position = UDim2.new(0.075, 0, 0.52, 0)
    instructionsFrame.BackgroundTransparency = 1
    instructionsFrame.BorderSizePixel = 0
    instructionsFrame.Parent = hexFrame
    
    local ifc = Instance.new("UICorner")
    ifc.CornerRadius = UDim.new(0.12, 0)
    ifc.Parent = instructionsFrame
    
    local ifs = Instance.new("UIStroke")
    ifs.Color = Color3.fromRGB(0, 255, 127)
    ifs.Thickness = 2
    ifs.Transparency = 0.6
    ifs.Parent = instructionsFrame
    
    local instTitle = Instance.new("TextLabel")
    instTitle.Size = UDim2.new(0.9, 0, 0.25, 0)
    instTitle.Position = UDim2.new(0.05, 0, 0.05, 0)
    instTitle.BackgroundTransparency = 1
    instTitle.Text = "🔮 QUANTUM VERIFICATION"
    instTitle.TextColor3 = Color3.fromRGB(0, 255, 127)
    instTitle.TextScaled = true
    instTitle.Font = Enum.Font.GothamBold
    instTitle.TextXAlignment = Enum.TextXAlignment.Left
    instTitle.Parent = instructionsFrame
    
    local step1 = Instance.new("TextLabel")
    step1.Size = UDim2.new(0.9, 0, 0.2, 0)
    step1.Position = UDim2.new(0.05, 0, 0.3, 0)
    step1.BackgroundTransparency = 1
    step1.Text = "◆ Copy verification URL and open in browser"
    step1.TextColor3 = Color3.fromRGB(180, 180, 180)
    step1.TextScaled = true
    step1.Font = Enum.Font.Gotham
    step1.TextXAlignment = Enum.TextXAlignment.Left
    step1.Parent = instructionsFrame
    
    local step2 = Instance.new("TextLabel")
    step2.Size = UDim2.new(0.9, 0, 0.2, 0)
    step2.Position = UDim2.new(0.05, 0, 0.5, 0)
    step2.BackgroundTransparency = 1
    step2.Text = "◆ Complete all verification protocols"
    step2.TextColor3 = Color3.fromRGB(180, 180, 180)
    step2.TextScaled = true
    step2.Font = Enum.Font.Gotham
    step2.TextXAlignment = Enum.TextXAlignment.Left
    step2.Parent = instructionsFrame
    
    local step3 = Instance.new("TextLabel")
    step3.Size = UDim2.new(0.9, 0, 0.2, 0)
    step3.Position = UDim2.new(0.05, 0, 0.7, 0)
    step3.BackgroundTransparency = 1
    step3.Text = "◆ Return and activate quantum access"
    step3.TextColor3 = Color3.fromRGB(180, 180, 180)
    step3.TextScaled = true
    step3.Font = Enum.Font.Gotham
    step3.TextXAlignment = Enum.TextXAlignment.Left
    step3.Parent = instructionsFrame
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Size = UDim2.new(0.85, 0, 0.22, 0)
    buttonContainer.Position = UDim2.new(0.075, 0, 0.76, 0)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.Parent = hexFrame
    
    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(1, 0, 0.45, 0)
    copyBtn.Position = UDim2.new(0, 0, 0, 0)
    copyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
    copyBtn.BackgroundTransparency = 0.2
    copyBtn.Text = "🌐 COPY VERIFICATION URL"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.TextScaled = true
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.BorderSizePixel = 0
    copyBtn.Parent = buttonContainer
    
    local cbc = Instance.new("UICorner")
    cbc.CornerRadius = UDim.new(0.2, 0)
    cbc.Parent = copyBtn
    
    local cbg = Instance.new("UIGradient")
    cbg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255))
    }
    cbg.Rotation = 45
    cbg.Parent = copyBtn
    
    local cbs = Instance.new("UIStroke")
    cbs.Color = Color3.fromRGB(255, 255, 255)
    cbs.Thickness = 2
    cbs.Transparency = 0.7
    cbs.Parent = copyBtn
    
    local buttonGrid = Instance.new("Frame")
    buttonGrid.Size = UDim2.new(1, 0, 0.45, 0)
    buttonGrid.Position = UDim2.new(0, 0, 0.55, 0)
    buttonGrid.BackgroundTransparency = 1
    buttonGrid.Parent = buttonContainer
    
    local refreshBtn = Instance.new("TextButton")
    refreshBtn.Size = UDim2.new(0.3, -5, 1, 0)
    refreshBtn.Position = UDim2.new(0, 0, 0, 0)
    refreshBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
    refreshBtn.BackgroundTransparency = 0.2
    refreshBtn.Text = "🔄"
    refreshBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    refreshBtn.TextScaled = true
    refreshBtn.Font = Enum.Font.GothamBold
    refreshBtn.BorderSizePixel = 0
    refreshBtn.Parent = buttonGrid
    
    local rbc = Instance.new("UICorner")
    rbc.CornerRadius = UDim.new(0.25, 0)
    rbc.Parent = refreshBtn
    
    local hwidBtn = Instance.new("TextButton")
    hwidBtn.Size = UDim2.new(0.3, -5, 1, 0)
    hwidBtn.Position = UDim2.new(0.35, 0, 0, 0)
    hwidBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255)
    hwidBtn.BackgroundTransparency = 0.2
    hwidBtn.Text = "📋"
    hwidBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    hwidBtn.TextScaled = true
    hwidBtn.Font = Enum.Font.GothamBold
    hwidBtn.BorderSizePixel = 0
    hwidBtn.Parent = buttonGrid
    
    local hbc = Instance.new("UICorner")
    hbc.CornerRadius = UDim.new(0.25, 0)
    hbc.Parent = hwidBtn
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0.3, -5, 1, 0)
    closeBtn.Position = UDim2.new(0.7, 0, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    closeBtn.BackgroundTransparency = 0.2
    closeBtn.Text = "❌"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextScaled = true
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = buttonGrid
    
    local clc = Instance.new("UICorner")
    clc.CornerRadius = UDim.new(0.25, 0)
    clc.Parent = closeBtn
    
    mainContainer.Size = UDim2.new(0, 0, 0, 0)
    mainContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local ts = game:GetService("TweenService")
    
    spawn(function()
        while sg.Parent do
            ts:Create(tog, TweenInfo.new(4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = tog.Rotation + 360}):Play()
            ts:Create(hs, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Transparency = 0.1}):Play()
            for _, p in ipairs(particles) do
                if p.Parent then
                    ts:Create(p, TweenInfo.new(math.random(5, 12), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
                        Position = UDim2.new(math.random(), 0, math.random(), 0),
                        BackgroundTransparency = math.random(70, 90) / 100
                    }):Play()
                end
            end
            wait(2)
        end
    end)
    
    local openTween = ts:Create(mainContainer, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0.85, 0, 0.75, 0),
        Position = UDim2.new(0.075, 0, 0.125, 0)
    })
    openTween:Play()
    
    spawn(function()
        while topOrb.Parent do
            ts:Create(topOrb, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Size = UDim2.new(0.14, 0, 0.14, 0),
                Position = UDim2.new(0.43, 0, -0.07, 0)
            }):Play()
            wait(1.5)
        end
    end)
    
    local function us(txt, col, ico)
        statusText.Text = txt
        statusText.TextColor3 = col
        statusIcon.Text = ico
        statusIcon.TextColor3 = col
        scs.Color = col
    end
    
    copyBtn.MouseButton1Click:Connect(function()
        local url = getgenv()._frostw .. "/key/" .. h
        if setclipboard then
            setclipboard(url)
        elseif toclipboard then
            toclipboard(url)
        end
        us("✅ Verification URL copied! Open in browser.", Color3.fromRGB(0, 255, 127), "🔗")
        
        local bt = ts:Create(copyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.1})
        bt:Play()
        bt.Completed:Connect(function()
            ts:Create(copyBtn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.2}):Play()
        end)
    end)
    
    hwidBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(h)
        elseif toclipboard then
            toclipboard(h)
        end
        us("📋 HWID copied to clipboard!", Color3.fromRGB(255, 0, 255), "📋")
    end)
    
    refreshBtn.MouseButton1Click:Connect(function()
        us("🔄 Checking quantum access status...", Color3.fromRGB(0, 255, 255), "🔄")
        
        local ha, d = ca()
        if ha then
            us("✅ Access verified! Loading FrostWare...", Color3.fromRGB(0, 255, 127), "✅")
            wait(1.5)
            
            local ct = ts:Create(mainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            ct:Play()
            ct.Completed:Connect(function()
                restoreOriginalSettings()
                sg:Destroy()
                
                local function sn(hr)
                    local nsg = Instance.new("ScreenGui")
                    nsg.Name = "FW_N_" .. tostring(math.random(10000, 99999))
                    nsg.Parent = gethui()
                    nsg.ResetOnSpawn = false
                    
                    local nf = Instance.new("Frame")
                    nf.Size = UDim2.new(0.6, 0, 0.3, 0)
                    nf.Position = UDim2.new(1.1, 0, 0, 0)
                    nf.BackgroundTransparency = 1
                    nf.Parent = nsg
                    
                    local diamond = Instance.new("Frame")
                    diamond.Size = UDim2.new(1, 0, 1, 0)
                    diamond.BackgroundTransparency = 1
                    diamond.BorderSizePixel = 0
                    diamond.Rotation = 5
                    diamond.Parent = nf
                    
                    local ds = Instance.new("UIStroke")
                    ds.Color = Color3.fromRGB(0, 255, 127)
                    ds.Thickness = 3
                    ds.Parent = diamond
                    
                    local dc = Instance.new("UICorner")
                    dc.CornerRadius = UDim.new(0.15, 0)
                    dc.Parent = diamond
                    
                    local successOrb = Instance.new("Frame")
                    successOrb.Size = UDim2.new(0.25, 0, 0.4, 0)
                    successOrb.Position = UDim2.new(0.05, 0, 0.15, 0)
                    successOrb.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
                    successOrb.BackgroundTransparency = 0.3
                    successOrb.BorderSizePixel = 0
                    successOrb.Parent = diamond
                    
                    local soc = Instance.new("UICorner")
                    soc.CornerRadius = UDim.new(1, 0)
                    soc.Parent = successOrb
                    
                    local sog = Instance.new("UIGradient")
                    sog.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(127, 255, 0))
                    }
                    sog.Parent = successOrb
                    
                    local checkmark = Instance.new("TextLabel")
                    checkmark.Size = UDim2.new(1, 0, 1, 0)
                    checkmark.BackgroundTransparency = 1
                    checkmark.Text = "✓"
                    checkmark.TextColor3 = Color3.fromRGB(255, 255, 255)
                    checkmark.TextScaled = true
                    checkmark.Font = Enum.Font.GothamBold
                    checkmark.Parent = successOrb
                    
                    local nt = Instance.new("TextLabel")
                    nt.Size = UDim2.new(0.65, 0, 0.35, 0)
                    nt.Position = UDim2.new(0.32, 0, 0.1, 0)
                    nt.BackgroundTransparency = 1
                    nt.Text = "QUANTUM ACCESS"
                    nt.TextColor3 = Color3.fromRGB(0, 255, 127)
                    nt.TextScaled = true
                    nt.Font = Enum.Font.GothamBold
                    nt.TextXAlignment = Enum.TextXAlignment.Left
                    nt.Parent = diamond
                    
                    local nst = Instance.new("TextLabel")
                    nst.Size = UDim2.new(0.65, 0, 0.25, 0)
                    nst.Position = UDim2.new(0.32, 0, 0.4, 0)
                    nst.BackgroundTransparency = 1
                    nst.Text = "GRANTED SUCCESSFULLY"
                    nst.TextColor3 = Color3.fromRGB(200, 200, 200)
                    nst.TextScaled = true
                    nst.Font = Enum.Font.Gotham
                    nst.TextXAlignment = Enum.TextXAlignment.Left
                    nst.Parent = diamond
                    
                    local timeFrame = Instance.new("Frame")
                    timeFrame.Size = UDim2.new(0.9, 0, 0.35, 0)
                    timeFrame.Position = UDim2.new(0.05, 0, 0.6, 0)
                    timeFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 127)
                    timeFrame.BackgroundTransparency = 0.8
                    timeFrame.BorderSizePixel = 0
                    timeFrame.Parent = diamond
                    
                    local tfc = Instance.new("UICorner")
                    tfc.CornerRadius = UDim.new(0.2, 0)
                    tfc.Parent = timeFrame
                    
                    local tfg = Instance.new("UIGradient")
                    tfg.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 255, 127)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 200, 255))
                    }
                    tfg.Rotation = 45
                    tfg.Parent = timeFrame
                    
                    local ntt = Instance.new("TextLabel")
                    ntt.Size = UDim2.new(1, 0, 1, 0)
                    ntt.BackgroundTransparency = 1
                    ntt.Text = "⏰ " .. hr .. " HOURS REMAINING"
                    ntt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ntt.TextScaled = true
                    ntt.Font = Enum.Font.GothamBold
                    ntt.Parent = timeFrame
                    
                    local nts = game:GetService("TweenService")
                    
                    local ot = nts:Create(nf, TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.35, 0, 0.05, 0)
                    })
                    ot:Play()
                    
                    spawn(function()
                        while successOrb.Parent do
                            nts:Create(sog, TweenInfo.new(2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut), {Rotation = sog.Rotation + 360}):Play()
                            nts:Create(checkmark, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, -1, true), {TextTransparency = 0.3}):Play()
                            wait(1)
                        end
                    end)
                    
                    wait(6)
                    
                    local ct = nts:Create(nf, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Position = UDim2.new(1.1, 0, 0, 0)
                    })
                    ct:Play()
                    ct.Completed:Connect(function()
                        nsg:Destroy()
                    end)
                end
                
                sn(d.hr)
                loadstring(game:HttpGet(getgenv()._frost))()
            end)
        else
            us("❌ No access found. Complete verification first.", Color3.fromRGB(255, 100, 100), "🔒")
        end
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        local ct = ts:Create(mainContainer, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        ct:Play()
        ct.Completed:Connect(function()
            restoreOriginalSettings()
            sg:Destroy()
        end)
    end)
end

local ha, ad = ca()
if ha then
    loadstring(game:HttpGet(getgenv()._frost))()
else
    repeat task.wait(0.1) until game:IsLoaded()
    cl()
    wait(5)
    cm()
end
