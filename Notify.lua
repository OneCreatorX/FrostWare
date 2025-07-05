repeat task.wait(0.1) until game:IsLoaded()
local response = tonumber(game:HttpGet(getgenv()._frostw .. "/status/" .. gethwid()))
if response and response > 0 then
    local hours = math.floor(response / 3600)
    local minutes = math.floor((response % 3600) / 60)
    local isPremium = hours > 50
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local SoundService = game:GetService("SoundService")
    local player = Players.LocalPlayer
    
    local function getTimeDisplay(h, m)
        if h >= 720 then
            return math.floor(h / 720) .. " months", "📅"
        elseif h >= 24 then
            return math.floor(h / 24) .. " days", "🗓️"
        else
            return h .. "h " .. m .. "m", "⏰"
        end
    end
    
    local function getProgressData(h)
        if h > 50 then
            return 1, Color3.fromRGB(255, 215, 0), Color3.fromRGB(138, 43, 226), "ELITE"
        elseif h >= 40 then
            return h / 50, Color3.fromRGB(52, 211, 153), Color3.fromRGB(34, 197, 94), "EXCELLENT"
        elseif h >= 25 then
            return h / 50, Color3.fromRGB(96, 165, 250), Color3.fromRGB(59, 130, 246), "GOOD"
        elseif h >= 10 then
            return h / 50, Color3.fromRGB(251, 191, 36), Color3.fromRGB(245, 158, 11), "MODERATE"
        elseif h >= 5 then
            return h / 50, Color3.fromRGB(251, 146, 60), Color3.fromRGB(249, 115, 22), "LOW"
        else
            return h / 50, Color3.fromRGB(239, 68, 68), Color3.fromRGB(220, 38, 38), "CRITICAL"
        end
    end
    
    local progress, color1, color2, status = getProgressData(hours)
    local timeText, timeIcon = getTimeDisplay(hours, minutes)
    
    if isPremium then
        local originalLighting = {
            Brightness = Lighting.Brightness,
            ColorShift_Top = Lighting.ColorShift_Top,
            ColorShift_Bottom = Lighting.ColorShift_Bottom,
            Ambient = Lighting.Ambient,
            OutdoorAmbient = Lighting.OutdoorAmbient
        }
        
        local eliteSound = Instance.new("Sound")
        eliteSound.SoundId = "rbxassetid://131961136"
        eliteSound.Volume = 0.2
        eliteSound.Parent = SoundService
        eliteSound:Play()
        
        local lightingTween = TweenService:Create(Lighting, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Brightness = 1.3,
            ColorShift_Top = Color3.fromRGB(255, 215, 0),
            ColorShift_Bottom = Color3.fromRGB(138, 43, 226),
            Ambient = Color3.fromRGB(40, 30, 60),
            OutdoorAmbient = Color3.fromRGB(80, 60, 120)
        })
        lightingTween:Play()
        
        spawn(function()
            wait(6)
            local restoreTween = TweenService:Create(Lighting, TweenInfo.new(2), originalLighting)
            restoreTween:Play()
            if eliteSound.Parent then
                eliteSound:Destroy()
            end
        end)
    end
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "FW_AN_" .. tostring(math.random(10000, 99999))
    sg.Parent = gethui()
    sg.ResetOnSpawn = false
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 450, 0, 220)
    f.Position = UDim2.new(1, -470, 0, -260)
    f.BackgroundColor3 = isPremium and Color3.fromRGB(8, 8, 12) or Color3.fromRGB(12, 18, 32)
    f.BorderSizePixel = 0
    f.Parent = sg
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 24)
    c.Parent = f
    
    local s = Instance.new("UIStroke")
    s.Color = isPremium and Color3.fromRGB(255, 215, 0) or color1
    s.Thickness = isPremium and 3 or 2
    s.Parent = f
    
    local g = Instance.new("UIGradient")
    if isPremium then
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(8, 8, 12)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(25, 20, 35)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(60, 40, 100)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 12))
        }
    else
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 18, 32)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 30, 50)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 18, 32))
        }
    end
    g.Rotation = 45
    g.Parent = f
    
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 40, 1, 40)
    sh.Position = UDim2.new(0, -20, 0, -20)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    sh.ImageColor3 = isPremium and Color3.fromRGB(255, 215, 0) or color1
    sh.ImageTransparency = 0.3
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(12, 12, 12, 12)
    sh.ZIndex = f.ZIndex - 1
    sh.Parent = f
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 70)
    hd.BackgroundColor3 = isPremium and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(20, 30, 50)
    hd.BorderSizePixel = 0
    hd.Parent = f
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 24)
    hc.Parent = hd
    
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 24)
    hb.Position = UDim2.new(0, 0, 1, -24)
    hb.BackgroundColor3 = isPremium and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(20, 30, 50)
    hb.BorderSizePixel = 0
    hb.Parent = hd
    
    local hg = Instance.new("UIGradient")
    if isPremium then
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
    else
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, color1),
            ColorSequenceKeypoint.new(1, color2)
        }
    end
    hg.Rotation = 90
    hg.Parent = hd
    
    local i = Instance.new("TextLabel")
    i.Size = UDim2.new(0, 55, 0, 55)
    i.Position = UDim2.new(0, 15, 0, 8)
    i.BackgroundTransparency = 1
    i.Text = isPremium and "👑" or (status == "CRITICAL" and "⚠️" or "❄️")
    i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.TextSize = isPremium and 40 or (status == "CRITICAL" and 35 or 32)
    i.Font = Enum.Font.Gotham
    i.Parent = hd
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -80, 0, 35)
    t.Position = UDim2.new(0, 75, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = isPremium and "FROSTWARE ELITE" or ("FROSTWARE " .. status)
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = isPremium and 22 or 18
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = hd
    
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, -80, 0, 25)
    playerName.Position = UDim2.new(0, 75, 0, 40)
    playerName.BackgroundTransparency = 1
    playerName.Text = "Welcome, " .. player.DisplayName
    playerName.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(156, 163, 175)
    playerName.TextSize = 14
    playerName.Font = Enum.Font.Gotham
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.Parent = hd
    
    local progressContainer = Instance.new("Frame")
    progressContainer.Size = UDim2.new(1, -30, 0, 45)
    progressContainer.Position = UDim2.new(0, 15, 0, 85)
    progressContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    progressContainer.BorderSizePixel = 0
    progressContainer.Parent = f
    
    local progressCorner = Instance.new("UICorner")
    progressCorner.CornerRadius = UDim.new(0, 22)
    progressCorner.Parent = progressContainer
    
    local progressBar = Instance.new("Frame")
    progressBar.Size = UDim2.new(0, 0, 1, 0)
    progressBar.BackgroundColor3 = color1
    progressBar.BorderSizePixel = 0
    progressBar.Parent = progressContainer
    
    local progressBarCorner = Instance.new("UICorner")
    progressBarCorner.CornerRadius = UDim.new(0, 22)
    progressBarCorner.Parent = progressBar
    
    local progressGradient = Instance.new("UIGradient")
    progressGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, color1),
        ColorSequenceKeypoint.new(1, color2)
    }
    progressGradient.Rotation = 45
    progressGradient.Parent = progressBar
    
    local progressText = Instance.new("TextLabel")
    progressText.Size = UDim2.new(1, 0, 1, 0)
    progressText.BackgroundTransparency = 1
    progressText.Text = timeIcon .. " " .. timeText .. " • " .. math.floor(progress * 100) .. "%"
    progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
    progressText.TextSize = 16
    progressText.Font = Enum.Font.GothamBold
    progressText.Parent = progressContainer
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -30, 0, 30)
    statusLabel.Position = UDim2.new(0, 15, 0, 140)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = isPremium and "⭐ UNLIMITED ACCESS ACTIVE" or ("🔥 " .. status .. " STATUS")
    statusLabel.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or color1
    statusLabel.TextSize = isPremium and 18 or 16
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = f
    
    local detailsFrame = Instance.new("Frame")
    detailsFrame.Size = UDim2.new(1, -30, 0, 35)
    detailsFrame.Position = UDim2.new(0, 15, 0, 175)
    detailsFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    detailsFrame.BorderSizePixel = 0
    detailsFrame.Parent = f
    
    local detailsCorner = Instance.new("UICorner")
    detailsCorner.CornerRadius = UDim.new(0, 18)
    detailsCorner.Parent = detailsFrame
    
    local detailsText = Instance.new("TextLabel")
    detailsText.Size = UDim2.new(1, 0, 1, 0)
    detailsText.BackgroundTransparency = 1
    detailsText.Text = isPremium and "💎 PREMIUM FEATURES UNLOCKED" or ("⚡ " .. math.floor(response) .. " seconds remaining")
    detailsText.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(156, 163, 175)
    detailsText.TextSize = 14
    detailsText.Font = Enum.Font.Gotham
    detailsText.Parent = detailsFrame
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 35, 0, 35)
    cb.Position = UDim2.new(1, -45, 0, 10)
    cb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    cb.Text = "✕"
    cb.TextColor3 = Color3.fromRGB(255, 255, 255)
    cb.TextSize = 20
    cb.Font = Enum.Font.GothamBold
    cb.Parent = f
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 12)
    cc.Parent = cb
    
    local ts = game:GetService("TweenService")
    
    local ot = ts:Create(f, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -470, 0, 20)
    })
    
    spawn(function()
        wait(isPremium and 1.5 or 0.3)
        ot:Play()
        
        wait(0.5)
        local barTween = ts:Create(progressBar, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(progress, 0, 1, 0)
        })
        barTween:Play()
        
        if status == "CRITICAL" then
            spawn(function()
                while f.Parent do
                    ts:Create(progressBar, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                    }):Play()
                    wait(0.1)
                end
            end)
        end
    end)
    
    spawn(function()
        if isPremium then
            for j = 1, 10 do
                ts:Create(i, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 46}):Play()
                wait(0.2)
                ts:Create(i, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 40}):Play()
                wait(0.25)
            end
        else
            for j = 1, 6 do
                local targetSize = status == "CRITICAL" and 40 or 36
                ts:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = targetSize}):Play()
                wait(0.3)
                ts:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = status == "CRITICAL" and 35 or 32}):Play()
                wait(0.4)
            end
        end
    end)
    
    spawn(function()
        while f.Parent do
            local glowIntensity = isPremium and 0.1 or (status == "CRITICAL" and 0.5 or 0.7)
            local duration = isPremium and 0.8 or (status == "CRITICAL" and 0.3 or 1.5)
            local glow = ts:Create(s, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Transparency = glowIntensity
            })
            glow:Play()
            wait(0.1)
        end
    end)
    
    if isPremium then
        spawn(function()
            while f.Parent do
                local shimmer = ts:Create(hg, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Rotation = 180
                })
                shimmer:Play()
                wait(0.1)
            end
        end)
    end
    
    cb.MouseButton1Click:Connect(function()
        local ct = ts:Create(f, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -470, 0, -260)
        })
        ct:Play()
        ct.Completed:Connect(function()
            sg:Destroy()
        end)
    end)
    
    spawn(function()
        wait(isPremium and 12 or 8)
        if f.Parent then
            local ct = ts:Create(f, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -470, 0, -260)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
            end)
        end
    end)
end
