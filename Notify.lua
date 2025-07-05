repeat task.wait(0.1) until game:IsLoaded()
local response = tonumber(game:HttpGet(getgenv()._frostw .. "/status/" .. gethwid()))
if response and response > 0 then
    local hours = math.floor(response / 3600)
    local isPremium = hours > 50
    local Players = game:GetService("Players")
    local TweenService = game:GetService("TweenService")
    local Lighting = game:GetService("Lighting")
    local SoundService = game:GetService("SoundService")
    local player = Players.LocalPlayer
    
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
        eliteSound.Volume = 0.3
        eliteSound.Parent = SoundService
        eliteSound:Play()
        
        local lightingTween = TweenService:Create(Lighting, TweenInfo.new(2, Enum.EasingStyle.Sine), {
            Brightness = 1.5,
            ColorShift_Top = Color3.fromRGB(255, 215, 0),
            ColorShift_Bottom = Color3.fromRGB(138, 43, 226),
            Ambient = Color3.fromRGB(50, 40, 80),
            OutdoorAmbient = Color3.fromRGB(100, 80, 150)
        })
        lightingTween:Play()
        
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            local humanoid = player.Character.Humanoid
            local originalWalkSpeed = humanoid.WalkSpeed
            local originalJumpPower = humanoid.JumpPower
            
            humanoid.WalkSpeed = 0
            humanoid.JumpPower = 0
            
            spawn(function()
                wait(4)
                if humanoid.Parent then
                    TweenService:Create(humanoid, TweenInfo.new(1), {WalkSpeed = originalWalkSpeed, JumpPower = originalJumpPower}):Play()
                end
            end)
        end
        
        local particles = {}
        for i = 1, 15 do
            local part = Instance.new("Part")
            part.Name = "EliteParticle"
            part.Size = Vector3.new(0.5, 0.5, 0.5)
            part.Material = Enum.Material.Neon
            part.BrickColor = BrickColor.new("Gold")
            part.CanCollide = false
            part.Anchored = true
            part.Parent = workspace
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local rootPart = player.Character.HumanoidRootPart
                part.Position = rootPart.Position + Vector3.new(
                    math.random(-20, 20),
                    math.random(5, 25),
                    math.random(-20, 20)
                )
                
                local floatTween = TweenService:Create(part, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Position = part.Position + Vector3.new(0, 5, 0)
                })
                floatTween:Play()
                
                local fadeTween = TweenService:Create(part, TweenInfo.new(8), {
                    Transparency = 1,
                    Size = Vector3.new(0.1, 0.1, 0.1)
                })
                fadeTween:Play()
                
                table.insert(particles, part)
            end
        end
        
        spawn(function()
            wait(8)
            for _, part in pairs(particles) do
                if part.Parent then
                    part:Destroy()
                end
            end
            
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
    f.Size = UDim2.new(0, 420, 0, 200)
    f.Position = UDim2.new(1, -440, 0, -240)
    f.BackgroundColor3 = isPremium and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(15, 23, 42)
    f.BorderSizePixel = 0
    f.Parent = sg
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 20)
    c.Parent = f
    
    local s = Instance.new("UIStroke")
    s.Color = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    s.Thickness = isPremium and 4 or 2
    s.Parent = f
    
    local g = Instance.new("UIGradient")
    if isPremium then
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(30, 25, 45)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 60, 120)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(150, 100, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 15))
        }
    else
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(30, 41, 59)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(48, 164, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42))
        }
    end
    g.Rotation = isPremium and 270 or 135
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, isPremium and 0.4 or 0.8),
        NumberSequenceKeypoint.new(1, 0.1)
    }
    g.Parent = f
    
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 30, 1, 30)
    sh.Position = UDim2.new(0, -15, 0, -15)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    sh.ImageColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    sh.ImageTransparency = isPremium and 0.1 or 0.4
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(12, 12, 12, 12)
    sh.ZIndex = f.ZIndex - 1
    sh.Parent = f
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 65)
    hd.BackgroundColor3 = isPremium and Color3.fromRGB(30, 25, 45) or Color3.fromRGB(30, 41, 59)
    hd.BorderSizePixel = 0
    hd.Parent = f
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 20)
    hc.Parent = hd
    
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 20)
    hb.Position = UDim2.new(0, 0, 1, -20)
    hb.BackgroundColor3 = isPremium and Color3.fromRGB(30, 25, 45) or Color3.fromRGB(30, 41, 59)
    hb.BorderSizePixel = 0
    hb.Parent = hd
    
    local hg = Instance.new("UIGradient")
    if isPremium then
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(138, 43, 226)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(75, 0, 130))
        }
    else
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
        }
    end
    hg.Rotation = isPremium and 120 or 45
    hg.Parent = hd
    
    local i = Instance.new("TextLabel")
    i.Size = UDim2.new(0, 50, 0, 50)
    i.Position = UDim2.new(0, 15, 0, 8)
    i.BackgroundTransparency = 1
    i.Text = isPremium and "👑" or "❄️"
    i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.TextSize = isPremium and 36 or 28
    i.Font = Enum.Font.Gotham
    i.Parent = hd
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -75, 0, 35)
    t.Position = UDim2.new(0, 70, 0, 5)
    t.BackgroundTransparency = 1
    t.Text = isPremium and "FROSTWARE ELITE" or "FROSTWARE PREMIUM"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = isPremium and 20 or 16
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = hd
    
    local playerName = Instance.new("TextLabel")
    playerName.Size = UDim2.new(1, -75, 0, 25)
    playerName.Position = UDim2.new(0, 70, 0, 35)
    playerName.BackgroundTransparency = 1
    playerName.Text = "Welcome, " .. player.DisplayName
    playerName.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(156, 163, 175)
    playerName.TextSize = isPremium and 14 or 12
    playerName.Font = Enum.Font.Gotham
    playerName.TextXAlignment = Enum.TextXAlignment.Left
    playerName.Parent = hd
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -30, 0, 30)
    st.Position = UDim2.new(0, 15, 0, 75)
    st.BackgroundTransparency = 1
    st.Text = isPremium and "⭐ ELITE ACCESS VERIFIED" or "✅ Access Verified & Active"
    st.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(52, 211, 153)
    st.TextSize = isPremium and 18 or 14
    st.Font = Enum.Font.GothamBold
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = f
    
    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, -30, 0, 55)
    tf.Position = UDim2.new(0, 15, 0, 115)
    tf.BackgroundColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    tf.BorderSizePixel = 0
    tf.Parent = f
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 16)
    tc.Parent = tf
    
    local tg = Instance.new("UIGradient")
    if isPremium then
        tg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
    else
        tg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
        }
    end
    tg.Rotation = isPremium and 160 or 45
    tg.Parent = tf
    
    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, 0, 1, 0)
    tt.BackgroundTransparency = 1
    tt.Text = isPremium and ("💎 " .. hours .. " ELITE HOURS ACTIVE") or ("⏰ " .. hours .. " HOURS REMAINING")
    tt.TextColor3 = isPremium and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(255, 255, 255)
    tt.TextSize = isPremium and 20 or 16
    tt.Font = Enum.Font.GothamBold
    tt.Parent = tf
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 32, 0, 32)
    cb.Position = UDim2.new(1, -42, 0, 10)
    cb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    cb.Text = "✕"
    cb.TextColor3 = Color3.fromRGB(255, 255, 255)
    cb.TextSize = 18
    cb.Font = Enum.Font.GothamBold
    cb.Parent = f
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 10)
    cc.Parent = cb
    
    local ts = game:GetService("TweenService")
    
    local ot = ts:Create(f, TweenInfo.new(1.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -440, 0, 20)
    })
    
    spawn(function()
        wait(isPremium and 2 or 0.5)
        ot:Play()
    end)
    
    spawn(function()
        if isPremium then
            for j = 1, 8 do
                ts:Create(i, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 42}):Play()
                wait(0.25)
                ts:Create(i, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 36}):Play()
                wait(0.3)
            end
        else
            for j = 1, 4 do
                ts:Create(i, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 32}):Play()
                wait(0.4)
                ts:Create(i, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 28}):Play()
                wait(0.6)
            end
        end
    end)
    
    spawn(function()
        while f.Parent do
            local glowIntensity = isPremium and 0.3 or 0.8
            local duration = isPremium and 1 or 2
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
                local shimmer = ts:Create(hg, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Rotation = 240
                })
                shimmer:Play()
                wait(0.1)
            end
        end)
        
        spawn(function()
            while f.Parent do
                local pulse = ts:Create(sh, TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    ImageTransparency = 0.5
                })
                pulse:Play()
                wait(0.1)
            end
        end)
    end
    
    cb.MouseButton1Click:Connect(function()
        local ct = ts:Create(f, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -440, 0, -240)
        })
        ct:Play()
        ct.Completed:Connect(function()
            sg:Destroy()
        end)
    end)
    
    spawn(function()
        wait(isPremium and 10 or 6)
        if f.Parent then
            local ct = ts:Create(f, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -440, 0, -240)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
            end)
        end
    end)
end
