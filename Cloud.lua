spawn(function()
    wait(1)
    
    local FW = _G.FW
    if not FW then return end
    
    local ui = FW.getUI()
    if not ui then return end
    
    local mainUI = ui["11"]
    if not mainUI then return end
    
    local HttpService = game:GetService("HttpService")
    local currentScripts = {}
    local selectedScript = nil
    local scriptFrame = nil
    
    local function createScriptButton(parent, scriptData, pos, size)
        local btn = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = size,
            Position = pos,
            Name = "ScriptBtn"
        })
        FW.cC(btn, 0.15)
        FW.cG(btn, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        
        local titleLabel = FW.cT(btn, {
            Text = scriptData.title or "Unknown Script",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.4, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(titleLabel, 14)
        
        local gameLabel = FW.cT(btn, {
            Text = "Game: " .. (scriptData.game or "Universal"),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(60, 60, 80),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.45, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(gameLabel, 12)
        
        local viewsLabel = FW.cT(btn, {
            Text = "👁️ " .. (scriptData.views or "0") .. " | ⭐ " .. (scriptData.likes or "0"),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(80, 80, 100),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.7, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(viewsLabel, 10)
        
        local clickBtn = FW.cB(btn, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        clickBtn.MouseButton1Click:Connect(function()
            selectedScript = scriptData
            showScriptOptions(scriptData)
        end)
        
        return btn
    end
    
    local function showScriptOptions(scriptData)
        if scriptFrame then
            scriptFrame:Destroy()
        end
        
        scriptFrame = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(13, 15, 20),
            Size = UDim2.new(0.8, 0, 0.6, 0),
            Position = UDim2.new(0.1, 0, 0.2, 0),
            Name = "ScriptFrame",
            ZIndex = 10
        })
        FW.cC(scriptFrame, 0.02)
        FW.cS(scriptFrame, 3, Color3.fromRGB(100, 200, 255))
        
        local titleBar = FW.cF(scriptFrame, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 32),
            Size = UDim2.new(1, 0, 0.15, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        FW.cC(titleBar, 0.02)
        
        local title = FW.cT(titleBar, {
            Text = scriptData.title or "Script Options",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(title, 18)
        
        local closeBtn = FW.cB(titleBar, {
            BackgroundColor3 = Color3.fromRGB(220, 50, 50),
            Size = UDim2.new(0.1, 0, 0.6, 0),
            Position = UDim2.new(0.88, 0, 0.2, 0),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cC(closeBtn, 0.15)
        FW.cTC(closeBtn, 16)
        
        closeBtn.MouseButton1Click:Connect(function()
            if scriptFrame then
                scriptFrame:Destroy()
                scriptFrame = nil
            end
        end)
        
        local contentFrame = FW.cF(scriptFrame, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.8, 0),
            Position = UDim2.new(0.025, 0, 0.18, 0),
            Name = "ContentFrame"
        })
        FW.cC(contentFrame, 0.02)
        
        local infoLabel = FW.cT(contentFrame, {
            Text = "Game: " .. (scriptData.game or "Universal") .. "\nViews: " .. (scriptData.views or "0") .. " | Likes: " .. (scriptData.likes or "0"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.2, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(infoLabel, 14)
        
        local executeBtn = FW.cF(contentFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.25, 0, 0.15, 0),
            Position = UDim2.new(0.05, 0, 0.3, 0),
            Name = "ExecuteBtn"
        })
        FW.cC(executeBtn, 0.15)
        FW.cG(executeBtn, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
        
        local executeLabel = FW.cT(executeBtn, {
            Text = "▶️ Execute",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(executeLabel, 14)
        
        local executeClick = FW.cB(executeBtn, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        executeClick.MouseButton1Click:Connect(function()
            if scriptData.script then
                local success, error = pcall(function()
                    loadstring(scriptData.script)()
                end)
                if success then
                    FW.showAlert("Success", "Script executed!", 2)
                else
                    FW.showAlert("Error", "Failed to execute script!", 2)
                end
            else
                local success, scriptContent = pcall(function()
                    return game:HttpGet("https://scriptblox.com/api/script/" .. scriptData._id)
                end)
                if success then
                    local scriptData2 = HttpService:JSONDecode(scriptContent)
                    if scriptData2.script then
                        loadstring(scriptData2.script)()
                        FW.showAlert("Success", "Script executed!", 2)
                    end
                else
                    FW.showAlert("Error", "Failed to fetch script!", 2)
                end
            end
        end)
        
        local editorBtn = FW.cF(contentFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.25, 0, 0.15, 0),
            Position = UDim2.new(0.35, 0, 0.3, 0),
            Name = "EditorBtn"
        })
        FW.cC(editorBtn, 0.15)
        FW.cG(editorBtn, Color3.fromRGB(100, 150, 255), Color3.fromRGB(50, 100, 200))
        
        local editorLabel = FW.cT(editorBtn, {
            Text = "📝 Open Editor",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(editorLabel, 14)
        
        local editorClick = FW.cB(editorBtn, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        editorClick.MouseButton1Click:Connect(function()
            FW.showAlert("Info", "Editor functionality coming soon!", 2)
        end)
        
        local copyBtn = FW.cF(contentFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.25, 0, 0.15, 0),
            Position = UDim2.new(0.65, 0, 0.3, 0),
            Name = "CopyBtn"
        })
        FW.cC(copyBtn, 0.15)
        FW.cG(copyBtn, Color3.fromRGB(255, 200, 100), Color3.fromRGB(200, 150, 50))
        
        local copyLabel = FW.cT(copyBtn, {
            Text = "📋 Copy Script",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(copyLabel, 14)
        
        local copyClick = FW.cB(copyBtn, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        copyClick.MouseButton1Click:Connect(function()
            if scriptData.script and setclipboard then
                setclipboard(scriptData.script)
                FW.showAlert("Success", "Script copied to clipboard!", 2)
            else
                local success, scriptContent = pcall(function()
                    return game:HttpGet("https://scriptblox.com/api/script/" .. scriptData._id)
                end)
                if success and setclipboard then
                    local scriptData2 = HttpService:JSONDecode(scriptContent)
                    if scriptData2.script then
                        setclipboard(scriptData2.script)
                        FW.showAlert("Success", "Script copied to clipboard!", 2)
                    end
                else
                    FW.showAlert("Error", "Failed to copy script!", 2)
                end
            end
        end)
        
        local previewFrame = FW.cF(contentFrame, {
            BackgroundColor3 = Color3.fromRGB(10, 12, 18),
            Size = UDim2.new(0.9, 0, 0.4, 0),
            Position = UDim2.new(0.05, 0, 0.5, 0),
            Name = "PreviewFrame"
        })
        FW.cC(previewFrame, 0.02)
        FW.cS(previewFrame, 1, Color3.fromRGB(35, 39, 54))
        
        local previewLabel = FW.cT(previewFrame, {
            Text = "Script Preview",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.15, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(previewLabel, 12)
        
        local previewText = FW.cT(previewFrame, {
            Text = scriptData.script and string.sub(scriptData.script, 1, 200) .. "..." or "Loading preview...",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.75, 0),
            Position = UDim2.new(0.05, 0, 0.2, 0),
            TextScaled = false,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(previewText, 10)
    end
    
    local function searchScripts(query, maxResults)
        maxResults = maxResults or 20
        local success, response = pcall(function()
            local url = "https://scriptblox.com/api/script/search?q=" .. HttpService:UrlEncode(query) .. "&max=" .. maxResults
            return game:HttpGet(url)
        end)
        
        if success then
            local data = HttpService:JSONDecode(response)
            if data.result and data.result.scripts then
                return data.result.scripts
            end
        end
        return {}
    end
    
    local function displayScripts(scripts, scrollFrame)
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child.Name == "ScriptBtn" then
                child:Destroy()
            end
        end
        
        for i, script in pairs(scripts) do
            local yPos = (i - 1) * 0.12
            createScriptButton(scrollFrame, script, UDim2.new(0.02, 0, yPos, 0), UDim2.new(0.96, 0, 0.1, 0))
        end
        
        scrollFrame.CanvasSize = UDim2.new(0, 0, #scripts * 0.12, 0)
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
    
    local title = FW.cT(cloudPage, {
        Text = "☁️ Script Cloud",
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
    
    local searchFrame = FW.cF(mainFrame, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.95, 0, 0.12, 0),
        Position = UDim2.new(0.025, 0, 0.02, 0),
        Name = "SearchFrame"
    })
    FW.cC(searchFrame, 0.02)
    FW.cS(searchFrame, 1, Color3.fromRGB(35, 39, 54))
    
    local searchBox = FW.cTB(searchFrame, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.7, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        PlaceholderText = "Search for scripts...",
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cC(searchBox, 0.15)
    FW.cTC(searchBox, 14)
    
    local searchBtn = FW.cF(searchFrame, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.77, 0, 0.2, 0),
        Name = "SearchBtn"
    })
    FW.cC(searchBtn, 0.15)
    FW.cG(searchBtn, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))
    
    local searchLabel = FW.cT(searchBtn, {
        Text = "🔍 Search",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(searchLabel, 14)
    
    local searchClick = FW.cB(searchBtn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    local scrollFrame = FW.cSF(mainFrame, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.95, 0, 0.8, 0),
        Position = UDim2.new(0.025, 0, 0.16, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "ScrollFrame"
    })
    FW.cC(scrollFrame, 0.02)
    FW.cS(scrollFrame, 1, Color3.fromRGB(35, 39, 54))
    
    searchClick.MouseButton1Click:Connect(function()
        local query = searchBox.Text
        if query and query ~= "" then
            FW.showAlert("Info", "Searching scripts...", 1)
            spawn(function()
                local scripts = searchScripts(query, 50)
                if #scripts > 0 then
                    currentScripts = scripts
                    displayScripts(scripts, scrollFrame)
                    FW.showAlert("Success", "Found " .. #scripts .. " scripts!", 2)
                else
                    FW.showAlert("Error", "No scripts found!", 2)
                end
            end)
        else
            FW.showAlert("Error", "Please enter a search term!", 2)
        end
    end)
    
    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            searchClick.MouseButton1Click:Fire()
        end
    end)
    
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local popularScripts = searchScripts("popular", 30)
        if #popularScripts > 0 then
            currentScripts = popularScripts
            displayScripts(popularScripts, scrollFrame)
        end
    end)
    
    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
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
            FW.switchPage("Cloud", sidebar)
        end)
    end
end)
