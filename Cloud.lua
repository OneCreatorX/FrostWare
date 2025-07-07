spawn(function()
    wait(3)
    
    local cloudPage = FW.cI(FW.getUI()["11"], {
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
    
    local uploadBtn = FW.cStdBtn(mainFrame, "UploadBtn", "Upload Script", "rbxassetid://6034229496", UDim2.new(0.05, 0, 0.05, 0), UDim2.new(0.2, 0, 0.08, 0))
    local downloadBtn = FW.cStdBtn(mainFrame, "DownloadBtn", "Download", "rbxassetid://6034229496", UDim2.new(0.27, 0, 0.05, 0), UDim2.new(0.2, 0, 0.08, 0))
    local deleteBtn = FW.cStdBtn(mainFrame, "DeleteBtn", "Delete", "rbxassetid://6034229496", UDim2.new(0.49, 0, 0.05, 0), UDim2.new(0.2, 0, 0.08, 0))
    
    local fileScroll = FW.cSF(mainFrame, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.15, 0),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Name = "FileScroll"
    })
    FW.cC(fileScroll, 0.02)
    
    local fileLayout = Instance.new("UIListLayout")
    fileLayout.Parent = fileScroll
    fileLayout.SortOrder = Enum.SortOrder.LayoutOrder
    fileLayout.Padding = UDim.new(0, 5)
    
    uploadBtn.MouseButton1Click:Connect(function()
        FW.showAlert("Info", "Upload functionality coming soon!", 2)
    end)
    
    downloadBtn.MouseButton1Click:Connect(function()
        FW.showAlert("Info", "Download functionality coming soon!", 2)
    end)
    
    deleteBtn.MouseButton1Click:Connect(function()
        FW.showAlert("Info", "Delete functionality coming soon!", 2)
    end)
    
    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(30, 36, 51) or Color3.fromRGB(31, 34, 50),
                Size = UDim2.new(0.714, 0, 0.088, 0),
                Position = pos,
                Name = nm,
                BackgroundTransparency = sel and 0 or 1
            })
            FW.cC(btn, 0.18)
            
            local box = FW.cF(btn, {
                ZIndex = sel and 2 or 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0.167, 0, 0.629, 0),
                Position = UDim2.new(0.093, 0, 0.2, 0),
                Name = "Box"
            })
            FW.cC(box, 0.24)
            FW.cAR(box, 0.982)
            
            if sel then
                FW.cG(box, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))
            else
                FW.cG(box, Color3.fromRGB(66, 79, 113), Color3.fromRGB(36, 44, 63))
            end
            
            FW.cI(box, {
                ZIndex = sel and 2 or 0,
                ScaleType = Enum.ScaleType.Fit,
                Image = ico,
                Size = UDim2.new(0.527, 0, sel and 0.571 or 0.5, 0),
                BackgroundTransparency = 1,
                Name = "Ico",
                Position = UDim2.new(0.236, 0, sel and 0.232 or 0.25, 0)
            })
            
            local lbl = FW.cT(btn, {
                TextWrapped = true,
                TextSize = 32,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(sel and 0.248 or 0.359, 0, 0.36, 0),
                Text = txt,
                Name = "Lbl",
                Position = UDim2.new(0.379, 0, 0.348, 0)
            })
            FW.cTC(lbl, 32)
            
            local clk = FW.cB(btn, {
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
            
            return btn, clk
        end
        
        local cloudBtn, cloudClk = cSBtn("Cloud", "Cloud", "rbxassetid://6034229496", UDim2.new(0.088, 0, 0.582, 0), false)
        cloudClk.MouseButton1Click:Connect(function()
            FW.switchPage("Cloud", sidebar)
        end)
    end
end)
