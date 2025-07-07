print("Cloud module starting...")

spawn(function()
    wait(3)
    
    print("Creating cloud page...")
    
    local ui = FW.getUI()
    if not ui then
        warn("FW.getUI() returned nil")
        return
    end
    
    local mainUI = ui["11"]
    if not mainUI then
        warn("Main UI container not found")
        return
    end
    
    local cloudPage = FW.cI(mainUI, {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(13, 15, 20),
        Image = "rbxassetid://76734110237026",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "CloudPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })
    
    print("Cloud page created")
    
    local title = FW.cT(cloudPage, {
        Text = "Cloud Storage",
        TextSize = 32,
        TextColor3 = Color3.fromRGB(100, 200, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.08, 0),
        Position = UDim2.new(0, 0, 0.02, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(title, 32)
    
    local mainFrame = FW.cF(cloudPage, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 32),
        Size = UDim2.new(0.95, 0, 0.85, 0),
        Position = UDim2.new(0.025, 0, 0.12, 0),
        Name = "MainFrame"
    })
    FW.cC(mainFrame, 0.02)
    FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
    
    print("Cloud UI elements created")
    
    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        print("Adding cloud button to sidebar...")
        
        local cloudBtn = FW.cF(sidebar, {
            BackgroundColor3 = Color3.fromRGB(31, 34, 50),
            Size = UDim2.new(0.714, 0, 0.088, 0),
            Position = UDim2.new(0.088, 0, 0.582, 0),
            Name = "Cloud",
            BackgroundTransparency = 1
        })
        FW.cC(cloudBtn, 0.18)
        
        local box = FW.cF(cloudBtn, {
            ZIndex = 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.167, 0, 0.629, 0),
            Position = UDim2.new(0.093, 0, 0.2, 0),
            Name = "Box"
        })
        FW.cC(box, 0.24)
        FW.cAR(box, 0.982)
        FW.cG(box, Color3.fromRGB(66, 79, 113), Color3.fromRGB(36, 44, 63))
        
        FW.cI(box, {
            ZIndex = 0,
            ScaleType = Enum.ScaleType.Fit,
            Image = "rbxassetid://6034229496",
            Size = UDim2.new(0.527, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Name = "Ico",
            Position = UDim2.new(0.236, 0, 0.25, 0)
        })
        
        local lbl = FW.cT(cloudBtn, {
            TextWrapped = true,
            TextSize = 32,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.359, 0, 0.36, 0),
            Text = "Cloud",
            Name = "Lbl",
            Position = UDim2.new(0.379, 0, 0.348, 0)
        })
        FW.cTC(lbl, 32)
        
        local clk = FW.cB(cloudBtn, {
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 14,
            TextScaled = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Name = "Clk",
            Text = "  ",
            ZIndex = 5
        })
        FW.cC(clk, 0)
        FW.cTC(clk, 14)
        
        clk.MouseButton1Click:Connect(function()
            print("Cloud button clicked!")
            FW.switchPage("Cloud", sidebar)
        end)
        
        print("Cloud button added successfully")
    else
        warn("Sidebar not found")
    end
    
    print("Cloud module loaded completely")
end)
