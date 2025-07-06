repeat task.wait(0.1) until game:IsLoaded()
local r = tonumber(game:HttpGet(getgenv()._frostw .. "/status/" .. gethwid()))
if r and r > 0 then
    local h = math.floor(r / 3600)
    local m = math.floor((r % 3600) / 60)
    local p = h > 50
    local P = game:GetService("Players")
    local T = game:GetService("TweenService")
    local L = game:GetService("Lighting")
    local S = game:GetService("SoundService")
    local u = P.LocalPlayer
    
    local function td(h, m)
        if h >= 720 then
            return math.floor(h / 720) .. " months", "📅"
        elseif h >= 24 then
            return math.floor(h / 24) .. " days", "🗓️"
        else
            return h .. "h " .. m .. "m", "⏰"
        end
    end
    
    local function pd(h)
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
    
    local pr, c1, c2, st = pd(h)
    local tt, ti = td(h, m)
    
    if p then
        local ol = {
            Brightness = L.Brightness,
            ColorShift_Top = L.ColorShift_Top,
            ColorShift_Bottom = L.ColorShift_Bottom,
            Ambient = L.Ambient,
            OutdoorAmbient = L.OutdoorAmbient
        }
        
        local es = Instance.new("Sound")
        es.SoundId = "rbxassetid://131961136"
        es.Volume = 0.2
        es.Parent = S
        es:Play()
        
        local lt = T:Create(L, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
            Brightness = 1.3,
            ColorShift_Top = Color3.fromRGB(255, 215, 0),
            ColorShift_Bottom = Color3.fromRGB(138, 43, 226),
            Ambient = Color3.fromRGB(40, 30, 60),
            OutdoorAmbient = Color3.fromRGB(80, 60, 120)
        })
        lt:Play()
        
        spawn(function()
            wait(6)
            local rt = T:Create(L, TweenInfo.new(2), ol)
            rt:Play()
            if es.Parent then
                es:Destroy()
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
    f.BackgroundColor3 = p and Color3.fromRGB(8, 8, 12) or Color3.fromRGB(12, 18, 32)
    f.BorderSizePixel = 0
    f.Parent = sg
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 24)
    c.Parent = f
    
    local s = Instance.new("UIStroke")
    s.Color = p and Color3.fromRGB(255, 215, 0) or c1
    s.Thickness = p and 3 or 2
    s.Parent = f
    
    local g = Instance.new("UIGradient")
    if p then
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
    sh.ImageColor3 = p and Color3.fromRGB(255, 215, 0) or c1
    sh.ImageTransparency = 0.3
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(12, 12, 12, 12)
    sh.ZIndex = f.ZIndex - 1
    sh.Parent = f
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 70)
    hd.BackgroundColor3 = p and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(20, 30, 50)
    hd.BorderSizePixel = 0
    hd.Parent = f
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 24)
    hc.Parent = hd
    
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 24)
    hb.Position = UDim2.new(0, 0, 1, -24)
    hb.BackgroundColor3 = p and Color3.fromRGB(25, 20, 35) or Color3.fromRGB(20, 30, 50)
    hb.BorderSizePixel = 0
    hb.Parent = hd
    
    local hg = Instance.new("UIGradient")
    if p then
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 215, 0)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 165, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 43, 226))
        }
    else
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, c1),
            ColorSequenceKeypoint.new(1, c2)
        }
    end
    hg.Rotation = 90
    hg.Parent = hd
    
    local i = Instance.new("TextLabel")
    i.Size = UDim2.new(0, 55, 0, 55)
    i.Position = UDim2.new(0, 15, 0, 8)
    i.BackgroundTransparency = 1
    i.Text = p and "👑" or (st == "CRITICAL" and "⚠️" or "❄️")
    i.TextColor3 = Color3.fromRGB(255, 255, 255)
    i.TextSize = p and 40 or (st == "CRITICAL" and 35 or 32)
    i.Font = Enum.Font.Gotham
    i.Parent = hd
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -80, 0, 35)
    t.Position = UDim2.new(0, 75, 0, 8)
    t.BackgroundTransparency = 1
    t.Text = p and "FROSTWARE ELITE" or ("FROSTWARE " .. st)
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = p and 22 or 18
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = hd
    
    local pn = Instance.new("TextLabel")
    pn.Size = UDim2.new(1, -80, 0, 25)
    pn.Position = UDim2.new(0, 75, 0, 40)
    pn.BackgroundTransparency = 1
    pn.Text = "Welcome, " .. u.DisplayName
    pn.TextColor3 = p and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(156, 163, 175)
    pn.TextSize = 14
    pn.Font = Enum.Font.Gotham
    pn.TextXAlignment = Enum.TextXAlignment.Left
    pn.Parent = hd
    
    local pc = Instance.new("Frame")
    pc.Size = UDim2.new(1, -30, 0, 45)
    pc.Position = UDim2.new(0, 15, 0, 85)
    pc.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    pc.BorderSizePixel = 0
    pc.Parent = f
    
    local pcc = Instance.new("UICorner")
    pcc.CornerRadius = UDim.new(0, 22)
    pcc.Parent = pc
    
    local pb = Instance.new("Frame")
    pb.Size = UDim2.new(0, 0, 1, 0)
    pb.BackgroundColor3 = c1
    pb.BorderSizePixel = 0
    pb.Parent = pc
    
    local pbc = Instance.new("UICorner")
    pbc.CornerRadius = UDim.new(0, 22)
    pbc.Parent = pb
    
    local pg = Instance.new("UIGradient")
    pg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, c1),
        ColorSequenceKeypoint.new(1, c2)
    }
    pg.Rotation = 45
    pg.Parent = pb
    
    local pt = Instance.new("TextLabel")
    pt.Size = UDim2.new(1, 0, 1, 0)
    pt.BackgroundTransparency = 1
    pt.Text = ti .. " " .. tt .. " • " .. math.floor(pr * 100) .. "%"
    pt.TextColor3 = Color3.fromRGB(255, 255, 255)
    pt.TextSize = 16
    pt.Font = Enum.Font.GothamBold
    pt.Parent = pc
    
    local sl = Instance.new("TextLabel")
    sl.Size = UDim2.new(1, -30, 0, 30)
    sl.Position = UDim2.new(0, 15, 0, 140)
    sl.BackgroundTransparency = 1
    sl.Text = p and "⭐ UNLIMITED ACCESS ACTIVE" or ("🔥 " .. st .. " STATUS")
    sl.TextColor3 = p and Color3.fromRGB(255, 215, 0) or c1
    sl.TextSize = p and 18 or 16
    sl.Font = Enum.Font.GothamBold
    sl.TextXAlignment = Enum.TextXAlignment.Left
    sl.Parent = f
    
    local df = Instance.new("Frame")
    df.Size = UDim2.new(1, -30, 0, 35)
    df.Position = UDim2.new(0, 15, 0, 175)
    df.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
    df.BorderSizePixel = 0
    df.Parent = f
    
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 18)
    dc.Parent = df
    
    local dt = Instance.new("TextLabel")
    dt.Size = UDim2.new(1, 0, 1, 0)
    dt.BackgroundTransparency = 1
    dt.Text = p and "💎 PREMIUM FEATURES UNLOCKED" or ("⚡ " .. math.floor(r) .. " seconds remaining")
    dt.TextColor3 = p and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(156, 163, 175)
    dt.TextSize = 14
    dt.Font = Enum.Font.Gotham
    dt.Parent = df
    
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
    
    local ot = T:Create(f, TweenInfo.new(1.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Position = UDim2.new(1, -470, 0, 20)
    })
    
    spawn(function()
        wait(p and 1.5 or 0.3)
        ot:Play()
        
        wait(0.5)
        local bt = T:Create(pb, TweenInfo.new(2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(pr, 0, 1, 0)
        })
        bt:Play()
        
        if st == "CRITICAL" then
            spawn(function()
                while f.Parent do
                    T:Create(pb, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                        BackgroundColor3 = Color3.fromRGB(255, 100, 100)
                    }):Play()
                    wait(0.1)
                end
            end)
        end
    end)
    
    spawn(function()
        if p then
            for j = 1, 10 do
                T:Create(i, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 46}):Play()
                wait(0.2)
                T:Create(i, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 40}):Play()
                wait(0.25)
            end
        else
            for j = 1, 6 do
                local ts = st == "CRITICAL" and 40 or 36
                T:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = ts}):Play()
                wait(0.3)
                T:Create(i, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = st == "CRITICAL" and 35 or 32}):Play()
                wait(0.4)
            end
        end
    end)
    
    spawn(function()
        while f.Parent do
            local gi = p and 0.1 or (st == "CRITICAL" and 0.5 or 0.7)
            local d = p and 0.8 or (st == "CRITICAL" and 0.3 or 1.5)
            local gl = T:Create(s, TweenInfo.new(d, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                Transparency = gi
            })
            gl:Play()
            wait(0.1)
        end
    end)
    
    if p then
        spawn(function()
            while f.Parent do
                local sm = T:Create(hg, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Rotation = 180
                })
                sm:Play()
                wait(0.1)
            end
        end)
    end
    
    cb.MouseButton1Click:Connect(function()
        local ct = T:Create(f, TweenInfo.new(0.7, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Position = UDim2.new(1, -470, 0, -260)
        })
        ct:Play()
        ct.Completed:Connect(function()
            sg:Destroy()
        end)
    end)
    
    spawn(function()
        wait(p and 12 or 8)
        if f.Parent then
            local ct = T:Create(f, TweenInfo.new(0.9, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -470, 0, -260)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
            end)
        end
    end)
end
