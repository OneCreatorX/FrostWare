repeat wait() until game:IsLoaded()
repeat wait() until lp
repeat wait() until lp.Character
repeat wait() until lp.Character:FindFirstChild("HumanoidRootPart")

local function waitForGameLoad()
    local startTime = tick()
    local maxWaitTime = 30
    
    while not game:IsLoaded() and (tick() - startTime) < maxWaitTime do
        wait(0.1)
    end
    
    if lp then
        while not lp.Character and (tick() - startTime) < maxWaitTime do
            wait(0.1)
        end
        
        if lp.Character then
            while not lp.Character:FindFirstChild("HumanoidRootPart") and (tick() - startTime) < maxWaitTime do
                wait(0.1)
            end
        end
    end
    
    wait(2)
end

waitForGameLoad()

local function createExtraFeatures()
    local ui = fw.gu()
    local extraPage = ui["11"]:FindFirstChild("ExtraPage")
    
    if not extraPage then return end
    
    local mainFrame = nf(extraPage, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(0.9, 0, 0.8, 0),
        p = UDim2.new(0.05, 0, 0.1, 0),
        n = "ExtraMainFrame"
    })
    nc(mainFrame, 0.02)
    ns(mainFrame, 2, Color3.fromRGB(35, 39, 54))
    
    local titleLabel = nt(mainFrame, {
        t = "Extra Features",
        ts = 24,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(1, 0, 0, 40),
        p = UDim2.new(0, 0, 0, 10),
        xa = Enum.TextXAlignment.Center,
        ff = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        bt = 1
    })
    ntc(titleLabel, 24)
    
    local scrollFrame = nsf(mainFrame, {
        c = Color3.fromRGB(16, 19, 27),
        s = UDim2.new(1, -20, 1, -70),
        p = UDim2.new(0, 10, 0, 60),
        cs = UDim2.new(0, 0, 0, 0),
        sb = 8,
        n = "ExtraScroll"
    })
    nc(scrollFrame, 0.02)
    
    local listLayout = ap(ni("UIListLayout", scrollFrame), {
        fd = Enum.FillDirection.Vertical,
        so = Enum.SortOrder.LayoutOrder,
        pd = UDim.new(0, 10)
    })
    
    local function createFeatureButton(name, description, callback, layoutOrder)
        local btnFrame = nf(scrollFrame, {
            c = Color3.fromRGB(25, 30, 40),
            s = UDim2.new(1, -10, 0, 80),
            n = name .. "Frame"
        })
        btnFrame.LayoutOrder = layoutOrder or 1
        nc(btnFrame, 0.02)
        ns(btnFrame, 1, Color3.fromRGB(40, 45, 55))
        
        local nameLabel = nt(btnFrame, {
            t = name,
            ts = 18,
            tc = Color3.fromRGB(255, 255, 255),
            s = UDim2.new(0.7, 0, 0, 25),
            p = UDim2.new(0, 15, 0, 10),
            xa = Enum.TextXAlignment.Left,
            ff = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            bt = 1
        })
        ntc(nameLabel, 18)
        
        local descLabel = nt(btnFrame, {
            t = description,
            ts = 14,
            tc = Color3.fromRGB(180, 190, 210),
            s = UDim2.new(0.7, 0, 0, 20),
            p = UDim2.new(0, 15, 0, 40),
            xa = Enum.TextXAlignment.Left,
            ff = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            bt = 1,
            tw = true
        })
        ntc(descLabel, 14)
        
        local actionBtn = nb(btnFrame, {
            t = "Execute",
            ts = 16,
            tc = Color3.fromRGB(255, 255, 255),
            c = Color3.fromRGB(50, 150, 250),
            s = UDim2.new(0, 100, 0, 35),
            p = UDim2.new(1, -120, 0, 22),
            ff = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            n = name .. "Btn"
        })
        nc(actionBtn, 0.02)
        ntc(actionBtn, 16)
        
        actionBtn.MouseButton1Click:Connect(function()
            if callback then
                local success, err = pcall(callback)
                if success then
                    fw.sa("Success", name .. " executed successfully!", 2)
                else
                    fw.sa("Error", "Failed to execute " .. name .. ": " .. tostring(err), 3)
                end
            end
        end)
        
        return btnFrame
    end
    
    createFeatureButton("Infinite Jump", "Allows unlimited jumping", function()
        local player = lp
        local mouse = player:GetMouse()
        
        mouse.KeyDown:Connect(function(key)
            if key == " " then
                if player.Character and player.Character:FindFirstChild("Humanoid") then
                    player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end, 1)
    
    createFeatureButton("Speed Boost", "Increases walkspeed to 50", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = 50
        end
    end, 2)
    
    createFeatureButton("Reset Speed", "Resets walkspeed to normal", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.WalkSpeed = 16
        end
    end, 3)
    
    createFeatureButton("Jump Power", "Increases jump power to 100", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = 100
        end
    end, 4)
    
    createFeatureButton("Reset Jump", "Resets jump power to normal", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.JumpPower = 50
        end
    end, 5)
    
    createFeatureButton("Noclip Toggle", "Toggle noclip mode", function()
        local noclipping = false
        local connection
        
        local function noclip()
            if lp.Character then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
        
        if not noclipping then
            noclipping = true
            connection = rs.Stepped:Connect(noclip)
        else
            noclipping = false
            if connection then
                connection:Disconnect()
            end
            if lp.Character then
                for _, part in pairs(lp.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = true
                    end
                end
            end
        end
    end, 6)
    
    createFeatureButton("Teleport to Spawn", "Teleports player to spawn", function()
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(0, 50, 0)
        end
    end, 7)
    
    createFeatureButton("God Mode", "Makes player invulnerable", function()
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            lp.Character.Humanoid.MaxHealth = math.huge
            lp.Character.Humanoid.Health = math.huge
        end
    end, 8)
    
    listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
    end)
    
    fw.sa("Extra", "Extra features loaded successfully!", 2)
end

spawn(function()
    wait(1)
    createExtraFeatures()
end)
