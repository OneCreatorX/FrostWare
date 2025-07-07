local module = {}

function module.init(FW)
    spawn(function()
        wait(2)
        
        local scriptsDir = "FrostWare/Scripts/"
        local localScripts = {}
        local scriptsScrollRef = nil
        local currentSection = "Local"
        local localFrame = nil
        local cloudFrame = nil
        
        local defaultScripts = {
            ["Infinity Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()";
            ["Dex Explorer"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()"
        }
        
        local function saveScript(name, content)
            if not isfolder(scriptsDir) then makefolder(scriptsDir) end
            localScripts[name] = content
            writefile(scriptsDir .. name .. ".lua", content)
            local scriptsData = {}
            for n, c in pairs(localScripts) do
                scriptsData[n] = c
            end
            writefile(scriptsDir .. "scripts.json", game:GetService("HttpService"):JSONEncode(scriptsData))
            updateScriptsList()
        end
        
        local function loadScripts()
            if not isfolder(scriptsDir) then makefolder(scriptsDir) end
            for name, content in pairs(defaultScripts) do
                if not isfile(scriptsDir .. name .. ".lua") then
                    writefile(scriptsDir .. name .. ".lua", content)
                end
                localScripts[name] = content
            end
            if isfile(scriptsDir .. "scripts.json") then
                local success, data = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(readfile(scriptsDir .. "scripts.json"))
                end)
                if success and data then
                    for name, content in pairs(data) do
                        localScripts[name] = content
                    end
                end
            end
            updateScriptsList()
        end
        
        function updateScriptsList()
            if scriptsScrollRef then
                for _, child in pairs(scriptsScrollRef:GetChildren()) do
                    if child:IsA("Frame") then
                        child:Destroy()
                    end
                end
                local yPos = 0
                for name, content in pairs(localScripts) do
                    local scriptFrame = FW.cF(scriptsScrollRef, {
                        BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                        Size = UDim2.new(1, 0, 0, 50),
                        Position = UDim2.new(0, 0, 0, yPos),
                        Name = "Script_" .. name
                    })
                    FW.cC(scriptFrame, 0.02)
                    FW.cS(scriptFrame, 1, Color3.fromRGB(35, 39, 54))
                    
                    local scriptBtn = FW.cB(scriptFrame, {
                        BackgroundColor3 = Color3.fromRGB(50, 60, 80),
                        Size = UDim2.new(0.7, 0, 0.8, 0),
                        Position = UDim2.new(0.02, 0, 0.1, 0),
                        Text = name,
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 18,
                        TextScaled = true,
                        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                    })
                    FW.cC(scriptBtn, 0.02)
                    FW.cTC(scriptBtn, 18)
                    
                    local execBtn = FW.cB(scriptFrame, {
                        BackgroundColor3 = Color3.fromRGB(100, 150, 100),
                        Size = UDim2.new(0.12, 0, 0.6, 0),
                        Position = UDim2.new(0.74, 0, 0.2, 0),
                        Text = "> Run <",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 14,
                        TextScaled = true
                    })
                    FW.cC(execBtn, 0.02)
                    FW.cTC(execBtn, 14)
                    
                    local deleteBtn = FW.cB(scriptFrame, {
                        BackgroundColor3 = Color3.fromRGB(150, 100, 100),
                        Size = UDim2.new(0.12, 0, 0.6, 0),
                        Position = UDim2.new(0.86, 0, 0.2, 0),
                        Text = "X",
                        TextColor3 = Color3.fromRGB(255, 255, 255),
                        TextSize = 14,
                        TextScaled = true
                    })
                    FW.cC(deleteBtn, 0.02)
                    FW.cTC(deleteBtn, 14)
                    
                    scriptBtn.MouseButton1Click:Connect(function()
                        local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                        local lnRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("TextLabel")
                        if srcRef then
                            srcRef.Text = content
                            local curTab = FW.getCurTab()
                            local tabs = FW.getTabs()
                            if tabs[curTab] then
                                tabs[curTab].content = content
                            end
                            FW.updLines(srcRef, lnRef)
                            FW.saveTabs()
                            FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                            FW.showAlert("Success", "Script loaded to editor!", 2)
                        end
                    end)
                    
                    execBtn.MouseButton1Click:Connect(function()
                        local success, result = pcall(function()
                            return loadstring(content)
                        end)
                        if success and result then
                            local execSuccess, execErr = pcall(result)
                            if execSuccess then
                                FW.showAlert("Success", name .. " executed!", 2)
                            else
                                FW.showAlert("Error", "Execution error: " .. tostring(execErr), 4)
                            end
                        else
                            FW.showAlert("Error", "Compilation error: " .. tostring(result), 4)
                        end
                    end)
                    
                    deleteBtn.MouseButton1Click:Connect(function()
                        if not defaultScripts[name] then
                            localScripts[name] = nil
                            if isfile(scriptsDir .. name .. ".lua") then
                                delfile(scriptsDir .. name .. ".lua")
                            end
                            local scriptsData = {}
                            for n, c in pairs(localScripts) do
                                scriptsData[n] = c
                            end
                            writefile(scriptsDir .. "scripts.json", game:GetService("HttpService"):JSONEncode(scriptsData))
                            updateScriptsList()
                            FW.showAlert("Success", "Script deleted!", 2)
                        else
                            FW.showAlert("Info", "Cannot delete default script!", 2)
                        end
                    end)
                    
                    yPos = yPos + 55
                end
                scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, yPos)
            end
        end
        
        local function switchSection(section)
            currentSection = section
            if localFrame and cloudFrame then
                if section == "Local" then
                    localFrame.Visible = true
                    cloudFrame.Visible = false
                else
                    localFrame.Visible = false
                    cloudFrame.Visible = true
                end
            end
        end
        
        local scriptsPage = FW.cI(FW.getUI()["11"], {
            ImageTransparency = 1,
            ImageColor3 = Color3.fromRGB(13, 15, 20),
            Image = "rbxassetid://76734110237026",
            Size = UDim2.new(1.001, 0, 1, 0),
            Visible = false,
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            Name = "ScriptsPage",
            Position = UDim2.new(-0.001, 0, 0, 0)
        })
        
        local title = FW.cT(scriptsPage, {
            Text = "📜 Scripts Hub",
            TextSize = 32,
            TextColor3 = Color3.fromRGB(255, 150, 100),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.08, 0),
            Position = UDim2.new(0, 0, 0.02, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(title, 32)
        
        local mainFrame = FW.cF(scriptsPage, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 32),
            Size = UDim2.new(0.95, 0, 0.85, 0),
            Position = UDim2.new(0.025, 0, 0.12, 0),
            Name = "MainFrame"
        })
        FW.cC(mainFrame, 0.02)
        FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
        
        local tabFrame = FW.cF(mainFrame, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.1, 0),
            Position = UDim2.new(0.025, 0, 0.02, 0),
            Name = "TabFrame"
        })
        FW.cC(tabFrame, 0.02)
        FW.cS(tabFrame, 1, Color3.fromRGB(35, 39, 54))
        
        local localTab = FW.cF(tabFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.45, 0, 0.7, 0),
            Position = UDim2.new(0.05, 0, 0.15, 0),
            Name = "LocalTab"
        })
        FW.cC(localTab, 0.15)
        FW.cG(localTab, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))
        
        local localLabel = FW.cT(localTab, {
            Text = "💻 Local Scripts",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(localLabel, 16)
        
        local localClick = FW.cB(localTab, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        local cloudTab = FW.cF(tabFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.45, 0, 0.7, 0),
            Position = UDim2.new(0.52, 0, 0.15, 0),
            Name = "CloudTab"
        })
        FW.cC(cloudTab, 0.15)
        FW.cG(cloudTab, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))
        
        local cloudLabel = FW.cT(cloudTab, {
            Text = "☁️ Cloud Scripts",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(29, 29, 38),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(cloudLabel, 16)
        
        local cloudClick = FW.cB(cloudTab, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })
        
        localFrame = FW.cF(mainFrame, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.85, 0),
            Position = UDim2.new(0.025, 0, 0.13, 0),
            Name = "LocalFrame",
            Visible = true
        })
        FW.cC(localFrame, 0.02)
        FW.cS(localFrame, 1, Color3.fromRGB(35, 39, 54))
        
        local inputFrame = FW.cF(localFrame, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 32),
            Size = UDim2.new(0.95, 0, 0.15, 0),
            Position = UDim2.new(0.025, 0, 0.02, 0),
            Name = "InputFrame"
        })
        FW.cC(inputFrame, 0.02)
        FW.cS(inputFrame, 2, Color3.fromRGB(35, 39, 54))
        
        local nameBox = FW.cTB(inputFrame, {
            BackgroundColor3 = Color3.fromRGB(24, 28, 35),
            Size = UDim2.new(0.4, 0, 0.3, 0),
            Position = UDim2.new(0.02, 0, 0.1, 0),
            Text = "",
            PlaceholderText = "Script Name",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Name = "NameBox"
        })
        FW.cC(nameBox, 0.02)
        FW.cS(nameBox, 1, Color3.fromRGB(50, 55, 65))
        FW.cTC(nameBox, 16)
        
        local saveBtn = FW.cStdBtn(inputFrame, "SaveBtn", "Save Current", "rbxassetid://89434276213036", UDim2.new(0.44, 0, 0.1, 0), UDim2.new(0.25, 0, 0.3, 0))
        local loadBtn = FW.cStdBtn(inputFrame, "LoadBtn", "Load to Editor", "rbxassetid://94595204123047", UDim2.new(0.71, 0, 0.1, 0), UDim2.new(0.25, 0, 0.3, 0))
        
        local instructionsText = FW.cT(inputFrame, {
            Text = "Enter a name and click 'Save Current' to save the current editor content, or select a script below to load it.",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.96, 0, 0.4, 0),
            Position = UDim2.new(0.02, 0, 0.5, 0),
            TextScaled = true,
            TextWrapped = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(instructionsText, 14)
        
        local scriptsFrame = FW.cF(localFrame, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.8, 0),
            Position = UDim2.new(0.025, 0, 0.19, 0),
            Name = "ScriptsFrame"
        })
        FW.cC(scriptsFrame, 0.02)
        FW.cS(scriptsFrame, 2, Color3.fromRGB(35, 39, 54))
        
        local scriptsScroll = FW.cSF(scriptsFrame, {
            BackgroundColor3 = Color3.fromRGB(12, 15, 22),
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            ScrollBarThickness = 8,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Name = "ScriptsScroll"
        })
        FW.cC(scriptsScroll, 0.02)
        scriptsScrollRef = scriptsScroll
        
        cloudFrame = FW.cF(mainFrame, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.85, 0),
            Position = UDim2.new(0.025, 0, 0.13, 0),
            Name = "CloudFrame",
            Visible = false
        })
        FW.cC(cloudFrame, 0.02)
        FW.cS(cloudFrame, 1, Color3.fromRGB(35, 39, 54))
        
        local cloudPlaceholder = FW.cT(cloudFrame, {
            Text = "☁️ Cloud Scripts\n\nLoading external content...",
            TextSize = 24,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 0.6, 0),
            Position = UDim2.new(0.1, 0, 0.2, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(cloudPlaceholder, 24)
        
        saveBtn.MouseButton1Click:Connect(function()
            local name = nameBox.Text
            if name and name ~= "" then
                local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                if srcRef then
                    saveScript(name, srcRef.Text)
                    nameBox.Text = ""
                    FW.showAlert("Success", "Script saved: " .. name, 2)
                end
            else
                FW.showAlert("Error", "Please enter a script name!", 2)
            end
        end)
        
        localClick.MouseButton1Click:Connect(function()
            switchSection("Local")
            FW.cG(localTab, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))
            FW.cG(cloudTab, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))
        end)
        
        cloudClick.MouseButton1Click:Connect(function()
            switchSection("Cloud")
            FW.cG(cloudTab, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
            FW.cG(localTab, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        end)
        
        _G.getCloudFrame = function()
            return cloudFrame
        end
        
        _G.switchToCloud = function()
            switchSection("Cloud")
            FW.cG(cloudTab, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
            FW.cG(localTab, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        end
        
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
                    FW.cG(box, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))
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
            
            local scriptsBtn, scriptsClk = cSBtn("Scripts", "Scripts", "rbxassetid://6034229496", UDim2.new(0.088, 0, 0.483, 0), false)
            scriptsClk.MouseButton1Click:Connect(function()
                FW.switchPage("Scripts", sidebar)
            end)
        end
        
        loadScripts()
        
        print("Scripts module loaded successfully!")
    end)
end

return module
