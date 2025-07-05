repeat task.wait(0.1) until game:IsLoaded()
local response = tonumber(game:HttpGet(getgenv()._frostw .. "/status/" .. gethwid()))
if response and response > 0 then
    local hours = math.floor(response / 3600)
    local isPremium = hours > 50
    
    local sg = Instance.new("ScreenGui")
    sg.Name = "FW_AN_" .. tostring(math.random(10000, 99999))
    sg.Parent = gethui()
    sg.ResetOnSpawn = false
    
    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 400, 0, 180)
    f.Position = UDim2.new(1, -420, 0, -220)
    f.BackgroundColor3 = isPremium and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(15, 23, 42)
    f.BorderSizePixel = 0
    f.Parent = sg
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 18)
    c.Parent = f
    
    local s = Instance.new("UIStroke")
    s.Color = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    s.Thickness = isPremium and 3 or 2
    s.Parent = f
    
    local g = Instance.new("UIGradient")
    if isPremium then
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 15)),
            ColorSequenceKeypoint.new(0.2, Color3.fromRGB(25, 20, 35)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 45, 85)),
            ColorSequenceKeypoint.new(0.8, Color3.fromRGB(120, 80, 200)),
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
    g.Rotation = isPremium and 225 or 135
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(0.5, isPremium and 0.6 or 0.8),
        NumberSequenceKeypoint.new(1, 0.1)
    }
    g.Parent = f
    
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 25, 1, 25)
    sh.Position = UDim2.new(0, -12, 0, -12)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    sh.ImageColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    sh.ImageTransparency = isPremium and 0.2 or 0.4
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(12, 12, 12, 12)
    sh.ZIndex = f.ZIndex - 1
    sh.Parent = f
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 55)
    hd.BackgroundColor3 = isPremium and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(30, 41, 59)
    hd.BorderSizePixel = 0
    hd.Parent = f
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 18)
    hc.Parent = hd
    
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 18)
    hb.Position = UDim2.new(0, 0, 1, -18)
    hb.BackgroundColor3 = isPremium and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(30, 41, 59)
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
    hg.Rotation = isPremium and 90 or 45
    hg.Parent = hd
    
    local i = Instance.new("TextLabel")
    i.Size = UDim2.new(0, 45, 0, 45)
    i.Position = UDim2.new(0, 15, 0, 5)
    i.BackgroundTransparency = 1
    i.Text = isPremium and "👑" or "❄️"
    i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.TextSize = isPremium and 32 or 28
    i.Font = Enum.Font.Gotham
    i.Parent = hd
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -70, 0, 55)
    t.Position = UDim2.new(0, 60, 0, 0)
    t.BackgroundTransparency = 1
    t.Text = isPremium and "FROSTWARE ELITE" or "FROSTWARE PREMIUM"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = isPremium and 18 or 16
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = hd
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -30, 0, 28)
    st.Position = UDim2.new(0, 15, 0, 65)
    st.BackgroundTransparency = 1
    st.Text = isPremium and "⭐ ELITE ACCESS VERIFIED" or "✅ Access Verified & Active"
    st.TextColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(52, 211, 153)
    st.TextSize = isPremium and 16 or 14
    st.Font = Enum.Font.GothamBold
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = f
    
    local tf = Instance.new("Frame")
    tf.Size = UDim2.new(1, -30, 0, 50)
    tf.Position = UDim2.new(0, 15, 0, 105)
    tf.BackgroundColor3 = isPremium and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(96, 165, 250)
    tf.BorderSizePixel = 0
    tf.Parent = f
    
    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 14)
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
    tg.Rotation = isPremium and 135 or 45
    tg.Parent = tf
    
    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, 0, 1, 0)
    tt.BackgroundTransparency = 1
    tt.Text = isPremium and ("💎 " .. hours .. " ELITE HOURS") or ("⏰ " .. hours .. " HOURS REMAINING")
    tt.TextColor3 = isPremium and Color3.fromRGB(10, 10, 15) or Color3.fromRGB(255, 255, 255)
    tt.TextSize = isPremium and 18 or 16
    tt.Font = Enum.Font.GothamBold
    tt.Parent = tf
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 28, 0, 28)
    cb.Position = UDim2.new(1, -38, 0, 10)
    cb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    cb.Text = "✕"
    cb.TextColor3 = Color3.fromRGB(255, 255, 255)
    cb.TextSize = 16
    cb.Font = Enum.Font.GothamBold
    cb.Parent = f
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 8)
    cc.Parent = cb
    
    local ts = game:GetService("TweenService")
    
    local ot = ts:Create(f, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -420, 0, 20)
    })
    ot:Play()
    
    spawn(function()
        if isPremium then
            for j = 1, 6 do
                ts:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 38}):Play()
                wait(0.3)
                ts:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 32}):Play()
                wait(0.4)
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
            local glowIntensity = isPremium and 0.6 or 0.8
            local glow = ts:Create(s, TweenInfo.new(isPremium and 1.5 or 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
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
        local ct = ts:Create(f, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -420, 0, -220)
        })
        ct:Play()
        ct.Completed:Connect(function()
            sg:Destroy()
        end)
    end)
    
    spawn(function()
        wait(isPremium and 8 or 6)
        if f.Parent then
            local ct = ts:Create(f, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -420, 0, -220)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
            end)
        end
    end)
end
