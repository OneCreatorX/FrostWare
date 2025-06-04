local hwid = gethwid()
local requestFunc = request or http_request or syn_request

local function checkAccess()
    local success, response = pcall(function()
        return requestFunc({
            Url = getgenv()._frostw .. "/check-access/" .. hwid,
            Method = "GET",
            Headers = {
                ["User-Agent"] = "Roblox/WinInet",
                ["Content-Type"] = "application/json"
            }
        })
    end)
    
    if success and response and response.StatusCode == 200 then
        local timeRemaining = tonumber(response.Body) or 0
        local hasAccess = timeRemaining > 0
        local hoursRemaining = math.floor(timeRemaining / (1000 * 60 * 60))
        return hasAccess, {hoursRemaining = hoursRemaining, timeRemaining = timeRemaining}
    end
    return false, nil
end

local function createInterface()
    local sg = Instance.new("ScreenGui")
    sg.Name = "FrostWare_" .. tostring(math.random(1000, 9999))
    sg.Parent = gethui()
    
    local fr = Instance.new("Frame")
    fr.Size = UDim2.new(0, 420, 0, 240)
    fr.Position = UDim2.new(0.5, -210, 0.5, -120)
    fr.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
    fr.BorderSizePixel = 0
    fr.Parent = sg
    
    local uc = Instance.new("UICorner")
    uc.CornerRadius = UDim.new(0, 16)
    uc.Parent = fr
    
    local us = Instance.new("UIStroke")
    us.Color = Color3.fromRGB(96, 165, 250)
    us.Thickness = 2
    us.Parent = fr
    
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(12, 12, 12, 12)
    shadow.ZIndex = fr.ZIndex - 1
    shadow.Parent = fr
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 41, 59))
    }
    gradient.Rotation = 45
    gradient.Parent = fr
    
    local tt = Instance.new("TextLabel")
    tt.Size = UDim2.new(1, 0, 0, 40)
    tt.Position = UDim2.new(0, 0, 0, 10)
    tt.BackgroundTransparency = 1
    tt.Text = "❄️ FrostWare Access"
    tt.TextColor3 = Color3.fromRGB(96, 165, 250)
    tt.TextSize = 20
    tt.Font = Enum.Font.GothamBold
    tt.Parent = fr
    
    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -30, 0, 35)
    st.Position = UDim2.new(0, 15, 0, 50)
    st.BackgroundTransparency = 1
    st.Text = "🔒 Access required. Copy URL and verify in browser."
    st.TextColor3 = Color3.fromRGB(148, 163, 184)
    st.TextSize = 14
    st.Font = Enum.Font.Gotham
    st.TextWrapped = true
    st.Parent = fr
    
    local cb = Instance.new("TextButton")
    cb.Size = UDim2.new(0, 180, 0, 40)
    cb.Position = UDim2.new(0.5, -90, 0, 95)
    cb.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
    cb.Text = "📋 Copy Verification URL"
    cb.TextColor3 = Color3.fromRGB(15, 23, 42)
    cb.TextSize = 14
    cb.Font = Enum.Font.GothamBold
    cb.Parent = fr
    
    local cc = Instance.new("UICorner")
    cc.CornerRadius = UDim.new(0, 10)
    cc.Parent = cb
    
    local cbGradient = Instance.new("UIGradient")
    cbGradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
    }
    cbGradient.Rotation = 45
    cbGradient.Parent = cb
    
    local db = Instance.new("TextButton")
    db.Size = UDim2.new(0, 90, 0, 35)
    db.Position = UDim2.new(0, 20, 0, 150)
    db.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    db.Text = "💬 Discord"
    db.TextColor3 = Color3.fromRGB(255, 255, 255)
    db.TextSize = 12
    db.Font = Enum.Font.GothamBold
    db.Parent = fr
    
    local dc = Instance.new("UICorner")
    dc.CornerRadius = UDim.new(0, 8)
    dc.Parent = db
    
    local rb = Instance.new("TextButton")
    rb.Size = UDim2.new(0, 90, 0, 35)
    rb.Position = UDim2.new(0, 125, 0, 150)
    rb.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
    rb.Text = "🔄 Refresh"
    rb.TextColor3 = Color3.fromRGB(255, 255, 255)
    rb.TextSize = 12
    rb.Font = Enum.Font.GothamBold
    rb.Parent = fr
    
    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 8)
    rc.Parent = rb
    
    local xb = Instance.new("TextButton")
    xb.Size = UDim2.new(0, 90, 0, 35)
    xb.Position = UDim2.new(1, -110, 0, 150)
    xb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
    xb.Text = "❌ Close"
    xb.TextColor3 = Color3.fromRGB(255, 255, 255)
    xb.TextSize = 12
    xb.Font = Enum.Font.Gotham
    xb.Parent = fr
    
    local xc = Instance.new("UICorner")
    xc.CornerRadius = UDim.new(0, 8)
    xc.Parent = xb
    
    local it = Instance.new("TextLabel")
    it.Size = UDim2.new(1, -30, 0, 35)
    it.Position = UDim2.new(0, 15, 0, 195)
    it.BackgroundTransparency = 1
    it.Text = "1. Copy URL → 2. Complete 2 steps → 3. Return to Roblox"
    it.TextColor3 = Color3.fromRGB(100, 116, 139)
    it.TextSize = 11
    it.Font = Enum.Font.Gotham
    it.TextWrapped = true
    it.Parent = fr
    
    local function updateButtonState(button, isHovered)
        local tween = game:GetService("TweenService"):Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad),
            {Size = isHovered and button.Size + UDim2.new(0, 4, 0, 2) or button.Size - UDim2.new(0, 4, 0, 2)}
        )
        tween:Play()
    end
    
    cb.MouseEnter:Connect(function() updateButtonState(cb, true) end)
    cb.MouseLeave:Connect(function() updateButtonState(cb, false) end)
    
    cb.MouseButton1Click:Connect(function()
        setclipboard(getgenv()._frostw .. "/verify?hwid=" .. hwid)
        st.Text = "🔗 URL copied! Complete 2 steps in browser."
        st.TextColor3 = Color3.fromRGB(34, 197, 94)
        
        local successTween = game:GetService("TweenService"):Create(
            cb,
            TweenInfo.new(0.1, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(34, 197, 94)}
        )
        successTween:Play()
        
        wait(0.5)
        
        local resetTween = game:GetService("TweenService"):Create(
            cb,
            TweenInfo.new(0.3, Enum.EasingStyle.Quad),
            {BackgroundColor3 = Color3.fromRGB(96, 165, 250)}
        )
        resetTween:Play()
    end)
    
    db.MouseButton1Click:Connect(function()
        setclipboard(getgenv()._dc)
        st.Text = "💬 Discord URL copied!"
        st.TextColor3 = Color3.fromRGB(88, 101, 242)
    end)
    
    rb.MouseButton1Click:Connect(function()
        st.Text = "🔄 Checking access..."
        st.TextColor3 = Color3.fromRGB(96, 165, 250)
        
        local hasAccess, data = checkAccess()
        if hasAccess then
            st.Text = "✅ Access found! Loading script..."
            st.TextColor3 = Color3.fromRGB(34, 197, 94)
            wait(1)
            sg:Destroy()
            loadstring(game:HttpGet(getgenv()._frost))()
        else
            st.Text = "❌ No access found. Complete verification."
            st.TextColor3 = Color3.fromRGB(239, 68, 68)
        end
    end)
    
    xb.MouseButton1Click:Connect(function()
        local closeTween = game:GetService("TweenService"):Create(
            fr,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
        )
        closeTween:Play()
        closeTween.Completed:Connect(function()
            sg:Destroy()
        end)
    end)
    
    local openTween = game:GetService("TweenService"):Create(
        fr,
        TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 420, 0, 240)}
    )
    fr.Size = UDim2.new(0, 0, 0, 0)
    fr.Position = UDim2.new(0.5, 0, 0.5, 0)
    openTween:Play()
    openTween.Completed:Connect(function()
        fr.Position = UDim2.new(0.5, -210, 0.5, -120)
    end)
end

print("[FrostWare] 🔍 Checking Redis access...")
local hasAccess, accessData = checkAccess()

if hasAccess then
    local hours = math.floor(accessData.hoursRemaining or 0)
    print("[FrostWare] ✅ Access valid - " .. hours .. " hours remaining")
    print("[FrostWare] 🚀 Loading script...")
    loadstring(game:HttpGet(getgenv()._frost))()
else
    print("[FrostWare] ❌ No Redis access found - Opening verification interface...")
    repeat task.wait(0.1) until game:IsLoaded()
    createInterface()
end
