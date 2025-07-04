local h = gethwid()
local r = request or http_request or syn_request

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
    
    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.Parent = sg
    
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(5, 10, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 20, 40))
    }
    g.Rotation = 45
    g.Parent = bg
    
    local ps = {}
    for i = 1, 15 do
        local p = Instance.new("Frame")
        p.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        p.Position = UDim2.new(math.random(), 0, math.random(), 0)
        p.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
        p.BorderSizePixel = 0
        p.BackgroundTransparency = math.random(30, 70) / 100
        p.Parent = bg
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(1, 0)
        c.Parent = p
        
        table.insert(ps, p)
    end
    
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(0, 600, 0, 120)
    l.Position = UDim2.new(0.5, -300, 0.5, -150)
    l.BackgroundTransparency = 1
    l.Text = "❄️ FROSTWARE"
    l.TextColor3 = Color3.fromRGB(96, 165, 250)
    l.TextSize = 72
    l.Font = Enum.Font.GothamBold
    l.TextStrokeTransparency = 0.5
    l.Parent = bg
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(0, 500, 0, 40)
    st.Position = UDim2.new(0.5, -250, 0.5, -50)
    st.BackgroundTransparency = 1
    st.Text = "PREMIUM KEY SYSTEM"
    st.TextColor3 = Color3.fromRGB(148, 163, 184)
    st.TextSize = 24
    st.Font = Enum.Font.Gotham
    st.Parent = bg
    
    local lt = Instance.new("TextLabel")
    lt.Size = UDim2.new(0, 400, 0, 30)
    lt.Position = UDim2.new(0.5, -200, 0.5, 50)
    lt.BackgroundTransparency = 1
    lt.Text = "Initializing system..."
    lt.TextColor3 = Color3.fromRGB(96, 165, 250)
    lt.TextSize = 18
    lt.Font = Enum.Font.Gotham
    lt.Parent = bg
    
    local pb = Instance.new("Frame")
    pb.Size = UDim2.new(0, 400, 0, 6)
    pb.Position = UDim2.new(0.5, -200, 0.5, 90)
    pb.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    pb.BorderSizePixel = 0
    pb.Parent = bg
    
    local pc = Instance.new("UICorner")
    pc.CornerRadius = UDim.new(0, 3)
    pc.Parent = pb
    
    local pf = Instance.new("Frame")
    pf.Size = UDim2.new(0, 0, 1, 0)
    pf.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    pf.BorderSizePixel = 0
    pf.Parent = pb
    
    local fc = Instance.new("UICorner")
    fc.CornerRadius = UDim.new(0, 3)
    fc.Parent = pf
    
    local fg = Instance.new("UIGradient")
    fg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
    }
    fg.Parent = pf
    
    l.TextTransparency = 1
    st.TextTransparency = 1
    lt.TextTransparency = 1
    pb.BackgroundTransparency = 1
    
    local ts = game:GetService("TweenService")
    
    ts:Create(l, TweenInfo.new(1, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    wait(0.3)
    ts:Create(st, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    wait(0.5)
    ts:Create(lt, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
    ts:Create(pb, TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
    
    local ss = {
        "Connecting to servers...",
        "Verifying credentials...",
        "Loading security protocols...",
        "Checking access permissions...",
        "Finalizing initialization..."
    }
    
    for i, s in ipairs(ss) do
        lt.Text = s
        ts:Create(pf, TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(i / #ss, 0, 1, 0)}):Play()
        wait(0.8)
    end
    
    spawn(function()
        while sg.Parent do
            for _, p in ipairs(ps) do
                if p.Parent then
                    ts:Create(p, TweenInfo.new(math.random(3, 8), Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true), {
                        Position = UDim2.new(math.random(), 0, math.random(), 0)
                    }):Play()
                end
            end
            wait(1)
        end
    end)
    
    wait(1)
    
    local fo = ts:Create(bg, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {BackgroundTransparency = 1})
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
    
    local m = Instance.new("Frame")
    m.Size = UDim2.new(0, 520, 0, 380)
    m.Position = UDim2.new(0.5, -260, 0.5, -190)
    m.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    m.BorderSizePixel = 0
    m.Parent = sg
    
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 20)
    mc.Parent = m
    
    local ms = Instance.new("UIStroke")
    ms.Color = Color3.fromRGB(96, 165, 250)
    ms.Thickness = 2
    ms.Transparency = 0.3
    ms.Parent = m
    
    local mg = Instance.new("UIGradient")
    mg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 41, 59)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42))
    }
    mg.Rotation = 135
    mg.Parent = m
    
    local sh = Instance.new("ImageLabel")
    sh.Size = UDim2.new(1, 40, 1, 40)
    sh.Position = UDim2.new(0, -20, 0, -20)
    sh.BackgroundTransparency = 1
    sh.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    sh.ImageColor3 = Color3.fromRGB(0, 0, 0)
    sh.ImageTransparency = 0.3
    sh.ScaleType = Enum.ScaleType.Slice
    sh.SliceCenter = Rect.new(12, 12, 12, 12)
    sh.ZIndex = m.ZIndex - 1
    sh.Parent = m
    
    local hd = Instance.new("Frame")
    hd.Size = UDim2.new(1, 0, 0, 80)
    hd.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    hd.BorderSizePixel = 0
    hd.Parent = m
    
    local hc = Instance.new("UICorner")
    hc.CornerRadius = UDim.new(0, 20)
    hc.Parent = hd
    
    local hb = Instance.new("Frame")
    hb.Size = UDim2.new(1, 0, 0, 20)
    hb.Position = UDim2.new(0, 0, 1, -20)
    hb.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    hb.BorderSizePixel = 0
    hb.Parent = hd
    
    local hg = Instance.new("UIGradient")
    hg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
    }
    hg.Rotation = 45
    hg.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.8),
        NumberSequenceKeypoint.new(1, 0.9)
    }
    hg.Parent = hd
    
    local t = Instance.new("TextLabel")
    t.Size = UDim2.new(1, -40, 0, 35)
    t.Position = UDim2.new(0, 20, 0, 15)
    t.BackgroundTransparency = 1
    t.Text = "❄️ FROSTWARE ACCESS SYSTEM"
    t.TextColor3 = Color3.fromRGB(255, 255, 255)
    t.TextSize = 22
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.Parent = hd
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -40, 0, 20)
    st.Position = UDim2.new(0, 20, 0, 50)
    st.BackgroundTransparency = 1
    st.Text = "Premium Key Verification Required"
    st.TextColor3 = Color3.fromRGB(148, 163, 184)
    st.TextSize = 14
    st.Font = Enum.Font.Gotham
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = hd
    
    local sf = Instance.new("Frame")
    sf.Size = UDim2.new(1, -40, 0, 60)
    sf.Position = UDim2.new(0, 20, 0, 100)
    sf.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
    sf.BorderSizePixel = 0
    sf.Parent = m
    
    local sc = Instance.new("UICorner")
    sc.CornerRadius = UDim.new(0, 12)
    sc.Parent = sf
    
    local si = Instance.new("TextLabel")
    si.Size = UDim2.new(0, 40, 0, 40)
    si.Position = UDim2.new(0, 10, 0, 10)
    si.BackgroundTransparency = 1
    si.Text = "🔒"
    si.TextColor3 = Color3.fromRGB(239, 68, 68)
    si.TextSize = 24
    si.Font = Enum.Font.Gotham
    si.Parent = sf
    
    local stx = Instance.new("TextLabel")
    stx.Size = UDim2.new(1, -60, 0, 40)
    stx.Position = UDim2.new(0, 50, 0, 10)
    stx.BackgroundTransparency = 1
    stx.Text = "Access Required - Complete verification to continue"
    stx.TextColor3 = Color3.fromRGB(148, 163, 184)
    stx.TextSize = 14
    stx.Font = Enum.Font.Gotham
    stx.TextXAlignment = Enum.TextXAlignment.Left
    stx.TextWrapped = true
    stx.Parent = sf
    
    local inf = Instance.new("Frame")
    inf.Size = UDim2.new(1, -40, 0, 80)
    inf.Position = UDim2.new(0, 20, 0, 180)
    inf.BackgroundColor3 = Color3.fromRGB(22, 27, 34)
    inf.BorderSizePixel = 0
    inf.Parent = m
    
    local ic = Instance.new("UICorner")
    ic.CornerRadius = UDim.new(0, 12)
    ic.Parent = inf
    
    local it = Instance.new("TextLabel")
    it.Size = UDim2.new(1, -20, 0, 25)
    it.Position = UDim2.new(0, 10, 0, 5)
    it.BackgroundTransparency = 1
    it.Text = "📋 VERIFICATION STEPS"
    it.TextColor3 = Color3.fromRGB(96, 165, 250)
    it.TextSize = 14
    it.Font = Enum.Font.GothamBold
    it.TextXAlignment = Enum.TextXAlignment.Left
    it.Parent = inf
    
    local s1 = Instance.new("TextLabel")
    s1.Size = UDim2.new(1, -20, 0, 15)
    s1.Position = UDim2.new(0, 10, 0, 30)
    s1.BackgroundTransparency = 1
    s1.Text = "1. Copy verification URL and open in browser"
    s1.TextColor3 = Color3.fromRGB(148, 163, 184)
    s1.TextSize = 12
    s1.Font = Enum.Font.Gotham
    s1.TextXAlignment = Enum.TextXAlignment.Left
    s1.Parent = inf
    
    local s2 = Instance.new("TextLabel")
    s2.Size = UDim2.new(1, -20, 0, 15)
    s2.Position = UDim2.new(0, 10, 0, 45)
    s2.BackgroundTransparency = 1
    s2.Text = "2. Complete all verification steps"
    s2.TextColor3 = Color3.fromRGB(148, 163, 184)
    s2.TextSize = 12
    s2.Font = Enum.Font.Gotham
    s2.TextXAlignment = Enum.TextXAlignment.Left
    s2.Parent = inf
    
    local s3 = Instance.new("TextLabel")
    s3.Size = UDim2.new(1, -20, 0, 15)
    s3.Position = UDim2.new(0, 10, 0, 60)
    s3.BackgroundTransparency = 1
    s3.Text = "3. Return here and click Refresh Access"
    s3.TextColor3 = Color3.fromRGB(148, 163, 184)
    s3.TextSize = 12
    s3.Font = Enum.Font.Gotham
    s3.TextXAlignment = Enum.TextXAlignment.Left
    s3.Parent = inf
    
    local bf = Instance.new("Frame")
    bf.Size = UDim2.new(1, -40, 0, 80)
    bf.Position = UDim2.new(0, 20, 0, 280)
    bf.BackgroundTransparency = 1
    bf.Parent = m
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 220, 0, 45)
    cb.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    cb.Text = "🔗 COPY VERIFICATION URL"
    cb.TextColor3 = Color3.fromRGB(255, 255, 255)
    cb.TextSize = 14
    cb.Font = Enum.Font.GothamBold
    cb.Parent = bf
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 12)
    cc.Parent = cb
    
    local cg = Instance.new("UIGradient")
    cg.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
    }
    cg.Rotation = 45
    cg.Parent = cb
    
    local rb = Instance.new("TextButton")
    rb.Size = UDim2.new(0, 100, 0, 35)
    rb.Position = UDim2.new(0, 240, 0, 5)
    rb.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    rb.Text = "🔄 REFRESH"
    rb.TextColor3 = Color3.fromRGB(255, 255, 255)
    rb.TextSize = 12
    rb.Font = Enum.Font.GothamBold
    rb.Parent = bf
    
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 10)
    rc.Parent = rb
    
    local hb = Instance.new("TextButton")
    hb.Size = UDim2.new(0, 100, 0, 35)
    hb.Position = UDim2.new(0, 350, 0, 5)
    hb.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
    hb.Text = "📋 COPY HWID"
    hb.TextColor3 = Color3.fromRGB(255, 255, 255)
    hb.TextSize = 12
    hb.Font = Enum.Font.GothamBold
    hb.Parent = bf
    
    local hbc = Instance.new("UICorner")
    hbc.CornerRadius = UDim.new(0, 10)
    hbc.Parent = hb
    
    local db = Instance.new("TextButton")
    db.Size = UDim2.new(0, 100, 0, 30)
    db.Position = UDim2.new(0, 240, 0, 45)
    db.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    db.Text = "💬 DISCORD"
    db.TextColor3 = Color3.fromRGB(255, 255, 255)
    db.TextSize = 11
    db.Font = Enum.Font.GothamBold
    db.Parent = bf
    
    local dbc = Instance.new("UICorner")
    dbc.CornerRadius = UDim.new(0, 8)
    dbc.Parent = db
    
    local xb = Instance.new("TextButton")
    xb.Size = UDim2.new(0, 100, 0, 30)
    xb.Position = UDim2.new(0, 350, 0, 45)
    xb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    xb.Text = "❌ CLOSE"
    xb.TextColor3 = Color3.fromRGB(255, 255, 255)
    xb.TextSize = 11
    xb.Font = Enum.Font.GothamBold
    xb.Parent = bf
    
    local xbc = Instance.new("UICorner")
    xbc.CornerRadius = UDim.new(0, 8)
    xbc.Parent = xb
    
    m.Size = UDim2.new(0, 0, 0, 0)
    m.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local ts = game:GetService("TweenService")
    
    ts:Create(m, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 380),
        Position = UDim2.new(0.5, -260, 0.5, -190)
    }):Play()
    
    local function us(txt, col, ico)
        stx.Text = txt
        stx.TextColor3 = col
        si.Text = ico
        si.TextColor3 = col
    end
    
    cb.MouseButton1Click:Connect(function()
        local url = getgenv()._frostw .. "/key/" .. h
        if setclipboard then
            setclipboard(url)
        elseif toclipboard then
            toclipboard(url)
        end
        us("✅ Verification URL copied! Open it in your browser.", Color3.fromRGB(34, 197, 94), "🔗")
        
        local bt = ts:Create(cb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 210, 0, 43)})
        bt:Play()
        bt.Completed:Connect(function()
            ts:Create(cb, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(0, 220, 0, 45)}):Play()
        end)
    end)
    
    hb.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(h)
        elseif toclipboard then
            toclipboard(h)
        end
        us("📋 HWID copied to clipboard!", Color3.fromRGB(59, 130, 246), "📋")
    end)
    
    db.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(getgenv()._dc)
        elseif toclipboard then
            toclipboard(getgenv()._dc)
        end
        us("💬 Discord URL copied to clipboard!", Color3.fromRGB(88, 101, 242), "💬")
    end)
    
    rb.MouseButton1Click:Connect(function()
        us("🔄 Checking access status...", Color3.fromRGB(96, 165, 250), "🔄")
        
        local ha, d = ca()
        if ha then
            us("✅ Access verified! Loading FrostWare...", Color3.fromRGB(34, 197, 94), "✅")
            wait(1)
            
            local ct = ts:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 0, 0, 0),
                Position = UDim2.new(0.5, 0, 0.5, 0)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
                
                local function sn(hr)
                    local nsg = Instance.new("ScreenGui")
                    nsg.Name = "FW_N_" .. tostring(math.random(10000, 99999))
                    nsg.Parent = gethui()
                    nsg.ResetOnSpawn = false
                    
                    local nf = Instance.new("Frame")
                    nf.Size = UDim2.new(0, 450, 0, 200)
                    nf.Position = UDim2.new(0.5, -225, 0, -250)
                    nf.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
                    nf.BorderSizePixel = 0
                    nf.Parent = nsg
                    
                    local nc = Instance.new("UICorner")
                    nc.CornerRadius = UDim.new(0, 20)
                    nc.Parent = nf
                    
                    local ns = Instance.new("UIStroke")
                    ns.Color = Color3.fromRGB(34, 197, 94)
                    ns.Thickness = 3
                    ns.Parent = nf
                    
                    local ng = Instance.new("UIGradient")
                    ng.Color = ColorSequence.new{
                        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(22, 101, 52)),
                        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42))
                    }
                    ng.Rotation = 45
                    ng.Transparency = NumberSequence.new{
                        NumberSequenceKeypoint.new(0, 0.1),
                        NumberSequenceKeypoint.new(1, 0.3)
                    }
                    ng.Parent = nf
                    
                    local ni = Instance.new("TextLabel")
                    ni.Size = UDim2.new(0, 80, 0, 80)
                    ni.Position = UDim2.new(0, 30, 0, 20)
                    ni.BackgroundTransparency = 1
                    ni.Text = "✅"
                    ni.TextColor3 = Color3.fromRGB(34, 197, 94)
                    ni.TextSize = 60
                    ni.Font = Enum.Font.Gotham
                    ni.Parent = nf
                    
                    local nt = Instance.new("TextLabel")
                    nt.Size = UDim2.new(1, -120, 0, 40)
                    nt.Position = UDim2.new(0, 120, 0, 20)
                    nt.BackgroundTransparency = 1
                    nt.Text = "ACCESS GRANTED!"
                    nt.TextColor3 = Color3.fromRGB(34, 197, 94)
                    nt.TextSize = 24
                    nt.Font = Enum.Font.GothamBold
                    nt.TextXAlignment = Enum.TextXAlignment.Left
                    nt.Parent = nf
                    
                    local nst = Instance.new("TextLabel")
                    nst.Size = UDim2.new(1, -120, 0, 30)
                    nst.Position = UDim2.new(0, 120, 0, 60)
                    nst.BackgroundTransparency = 1
                    nst.Text = "FrostWare Premium Active"
                    nst.TextColor3 = Color3.fromRGB(148, 163, 184)
                    nst.TextSize = 16
                    nst.Font = Enum.Font.Gotham
                    nst.TextXAlignment = Enum.TextXAlignment.Left
                    nst.Parent = nf
                    
                    local ntf = Instance.new("Frame")
                    ntf.Size = UDim2.new(1, -40, 0, 60)
                    ntf.Position = UDim2.new(0, 20, 0, 120)
                    ntf.BackgroundColor3 = Color3.fromRGB(22, 101, 52)
                    ntf.BorderSizePixel = 0
                    ntf.Parent = nf
                    
                    local ntc = Instance.new("UICorner")
                    ntc.CornerRadius = UDim.new(0, 15)
                    ntc.Parent = ntf
                    
                    local ntt = Instance.new("TextLabel")
                    ntt.Size = UDim2.new(1, 0, 1, 0)
                    ntt.BackgroundTransparency = 1
                    ntt.Text = "⏰ " .. hr .. " HOURS REMAINING"
                    ntt.TextColor3 = Color3.fromRGB(255, 255, 255)
                    ntt.TextSize = 20
                    ntt.Font = Enum.Font.GothamBold
                    ntt.Parent = ntf
                    
                    local nts = game:GetService("TweenService")
                    
                    local ot = nts:Create(nf, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                        Position = UDim2.new(0.5, -225, 0, 50)
                    })
                    ot:Play()
                    
                    spawn(function()
                        for i = 1, 3 do
                            nts:Create(ni, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 70}):Play()
                            wait(0.3)
                            nts:Create(ni, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 60}):Play()
                            wait(0.7)
                        end
                    end)
                    
                    wait(5)
                    
                    local ct = nts:Create(nf, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                        Position = UDim2.new(0.5, -225, 0, -250)
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
            us("❌ No access found. Complete verification first.", Color3.fromRGB(239, 68, 68), "🔒")
        end
    end)
    
    xb.MouseButton1Click:Connect(function()
        local ct = ts:Create(m, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        ct:Play()
        ct.Completed:Connect(function()
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
    wait(4.5)
    cm()
end
