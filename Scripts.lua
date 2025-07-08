spawn(function()
    wait(1)
    local FW = _G.FW
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local curSec = "Local"
    local localF = nil
    local cloudF = nil
    local curScripts = {}
    local selScript = nil
    local scriptF = nil
    local localScripts = {}
    local autoExecScripts = {}
    local scriptsScrollRef = nil
    local scriptsDir = "FrostWare/Scripts/"
    local autoExecFile = "FrostWare/AutoExec.json"
    local defScripts = {
        ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
        ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
        ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
    }

    local function switchSec(sec)
        curSec = sec
        if localF and cloudF then
            if sec == "Local" then
                localF.Visible = true
                cloudF.Visible = false
            else
                localF.Visible = false
                cloudF.Visible = true
            end
        end
    end

    local function saveAutoExec()
        if not isfolder("FrostWare") then makefolder("FrostWare") end
        writefile(autoExecFile, HttpService:JSONEncode(autoExecScripts))
    end

    local function loadAutoExec()
        if not isfolder("FrostWare") then makefolder("FrostWare") end
        if isfile(autoExecFile) then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(autoExecFile))
            end)
            if success and data then
                autoExecScripts = data
            end
        end
    end

    local function toggleAutoExec(name)
        if autoExecScripts[name] then
            autoExecScripts[name] = nil
        else
            autoExecScripts[name] = true
        end
        saveAutoExec()
        updateList()
    end

    local function executeAutoScripts()
        for name, _ in pairs(autoExecScripts) do
            if localScripts[name] then
                spawn(function()
                    local success, result = pcall(function()
                        return loadstring(localScripts[name])
                    end)
                    if success and result then
                        pcall(result)
                    end
                end)
            end
        end
    end

    local function saveScript(name, content)
        if not isfolder(scriptsDir) then makefolder(scriptsDir) end
        localScripts[name] = content
        writefile(scriptsDir .. name .. ".lua", content)
        local data = {}
        for n, c in pairs(localScripts) do
            data[n] = c
        end
        writefile(scriptsDir .. "scripts.json", HttpService:JSONEncode(data))
        updateList()
    end

    local function loadScripts()
        if not isfolder(scriptsDir) then makefolder(scriptsDir) end
        for name, content in pairs(defScripts) do
            localScripts[name] = content
        end
        if isfile(scriptsDir .. "scripts.json") then
            local success, data = pcall(function()
                return HttpService:JSONDecode(readfile(scriptsDir .. "scripts.json"))
            end)
            if success and data then
                for name, content in pairs(data) do
                    localScripts[name] = content
                end
            end
        end
        updateList()
    end

    function updateList()
        if scriptsScrollRef then
            for _, child in pairs(scriptsScrollRef:GetChildren()) do
                if child:IsA("Frame") then
                    child:Destroy()
                end
            end
            
            local scripts = {}
            for name, content in pairs(localScripts) do
                table.insert(scripts, {name = name, content = content})
            end
            
            local columns = 3
            local cardWidth = (scriptsScrollRef.AbsoluteSize.X - 40) / columns
            local cardHeight = 180
            local padding = 10
            
            for i, script in pairs(scripts) do
                local row = math.floor((i - 1) / columns)
                local col = (i - 1) % columns
                local xPos = col * (cardWidth + padding) + padding
                local yPos = row * (cardHeight + padding) + padding
                
                local scriptCard = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(248, 250, 252),
                    Size = UDim2.new(0, cardWidth, 0, cardHeight),
                    Position = UDim2.new(0, xPos, 0, yPos),
                    Name = "ScriptCard_" .. script.name,
                    ClipsDescendants = true
                })
                FW.cC(scriptCard, 0.12)
                FW.cS(scriptCard, 1, Color3.fromRGB(226, 232, 240))

                local headerSection = FW.cF(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(59, 130, 246),
                    Size = UDim2.new(1, 0, 0, 50),
                    Position = UDim2.new(0, 0, 0, 0),
                    Name = "HeaderSection"
                })

                local scriptTitle = FW.cT(headerSection, {
                    Text = string.len(script.name) > 20 and string.sub(script.name, 1, 20) .. "..." or script.name,
                    TextSize = 16,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.8, 0, 1, 0),
                    Position = UDim2.new(0.1, 0, 0, 0),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(scriptTitle, 16)

                local statusBadge = FW.cF(scriptCard, {
                    BackgroundColor3 = defScripts[script.name] and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(249, 115, 22),
                    Size = UDim2.new(0, 80, 0, 20),
                    Position = UDim2.new(1, -90, 0, 60),
                    Name = "StatusBadge"
                })
                FW.cC(statusBadge, 0.5)

                local statusText = FW.cT(statusBadge, {
                    Text = defScripts[script.name] and "DEFAULT" or "CUSTOM",
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(statusText, 10)

                local autoExecIndicator = FW.cF(scriptCard, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(156, 163, 175),
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new(0, 10, 0, 60),
                    Name = "AutoExecIndicator"
                })
                FW.cC(autoExecIndicator, 1)

                local autoExecLabel = FW.cT(scriptCard, {
                    Text = "Auto Execute",
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(107, 114, 128),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 80, 0, 12),
                    Position = UDim2.new(0, 30, 0, 60),
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(autoExecLabel, 11)

                local buttonContainer = FW.cF(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 40),
                    Position = UDim2.new(0, 10, 1, -50),
                    Name = "ButtonContainer"
                })

                local executeBtn = FW.cB(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(34, 197, 94),
                    Size = UDim2.new(0.48, -5, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = "EXECUTE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(executeBtn, 0.08)

                local moreBtn = FW.cB(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(107, 114, 128),
                    Size = UDim2.new(0.48, -5, 1, 0),
                    Position = UDim2.new(0.52, 5, 0, 0),
                    Text = "MORE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(moreBtn, 0.08)

                executeBtn.MouseButton1Click:Connect(function()
                    FW.showAlert("Success", script.name .. " executing...", 2)
                    local success, result = pcall(function()
                        return loadstring(script.content)
                    end)
                    if success and result then
                        local execSuccess, execErr = pcall(result)
                        if execSuccess then
                            FW.showAlert("Success", script.name .. " executed!", 2)
                        else
                            FW.showAlert("Error", "Execution failed!", 3)
                        end
                    else
                        FW.showAlert("Error", "Compilation failed!", 3)
                    end
                end)

                moreBtn.MouseButton1Click:Connect(function()
                    showScriptOptions(script.name, script.content)
                end)

                autoExecIndicator.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        toggleAutoExec(script.name)
                    end
                end)
            end
            
            local totalRows = math.ceil(#scripts / columns)
            scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cardHeight + padding) + padding)
        end
    end

    function showScriptOptions(name, content)
        if scriptF then
            scriptF:Destroy()
        end
        local ui = FW.getUI()
        local mainUI = ui["11"]
        scriptF = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 400, 0, 300),
            Position = UDim2.new(0.5, -200, 0.5, -150),
            Name = "OptionsPanel",
            ClipsDescendants = true
        })
        FW.cC(optionsPanel, 0.16)
        FW.cS(optionsPanel, 2, Color3.fromRGB(226, 232, 240))

        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })

        local title = FW.cT(titleBar, {
            Text = string.len(name) > 25 and string.sub(name, 1, 25) .. "..." or name,
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(title, 18)

        local closeBtn = FW.cB(titleBar, {
            BackgroundColor3 = Color3.fromRGB(239, 68, 68),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 0.5)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local buttonGrid = FW.cF(optionsPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 120),
            Position = UDim2.new(0, 20, 0, 80),
            Name = "ButtonGrid"
        })

        local viewBtn = FW.cB(buttonGrid, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(0.48, -5, 0.45, -5),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "VIEW IN EDITOR",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(viewBtn, 0.08)

        local deleteBtn = FW.cB(buttonGrid, {
            BackgroundColor3 = Color3.fromRGB(239, 68, 68),
            Size = UDim2.new(0.48, -5, 0.45, -5),
            Position = UDim2.new(0.52, 5, 0, 0),
            Text = "DELETE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(deleteBtn, 0.08)

        local autoBtn = FW.cB(buttonGrid, {
            BackgroundColor3 = autoExecScripts[name] and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(156, 163, 175),
            Size = UDim2.new(0.48, -5, 0.45, -5),
            Position = UDim2.new(0, 0, 0.55, 5),
            Text = autoExecScripts[name] and "DISABLE AUTO" or "ENABLE AUTO",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(autoBtn, 0.08)

        local executeBtn = FW.cB(buttonGrid, {
            BackgroundColor3 = Color3.fromRGB(34, 197, 94),
            Size = UDim2.new(0.48, -5, 0.45, -5),
            Position = UDim2.new(0.52, 5, 0.55, 5),
            Text = "EXECUTE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(executeBtn, 0.08)

        viewBtn.MouseButton1Click:Connect(function()
            local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
            if srcRef then
                srcRef.Text = content
                FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                FW.showAlert("Success", "Script loaded to editor!", 2)
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        deleteBtn.MouseButton1Click:Connect(function()
            if not defScripts[name] then
                localScripts[name] = nil
                autoExecScripts[name] = nil
                if isfile(scriptsDir .. name .. ".lua") then
                    delfile(scriptsDir .. name .. ".lua")
                end
                local data = {}
                for n, c in pairs(localScripts) do
                    data[n] = c
                end
                writefile(scriptsDir .. "scripts.json", HttpService:JSONEncode(data))
                saveAutoExec()
                updateList()
                FW.showAlert("Success", "Script deleted!", 2)
                scriptF:Destroy()
                scriptF = nil
            else
                FW.showAlert("Info", "Cannot delete default script!", 2)
            end
        end)

        autoBtn.MouseButton1Click:Connect(function()
            toggleAutoExec(name)
            FW.showAlert("Info", autoExecScripts[name] and "Auto-execute enabled!" or "Auto-execute disabled!", 2)
            scriptF:Destroy()
            scriptF = nil
        end)

        executeBtn.MouseButton1Click:Connect(function()
            FW.showAlert("Success", name .. " executing...", 2)
            local success, result = pcall(function()
                return loadstring(content)
            end)
            if success and result then
                local execSuccess, execErr = pcall(result)
                if execSuccess then
                    FW.showAlert("Success", name .. " executed!", 2)
                else
                    FW.showAlert("Error", "Execution failed!", 3)
                end
            else
                FW.showAlert("Error", "Compilation failed!", 3)
            end
            scriptF:Destroy()
            scriptF = nil
        end)
    end

    local function createCloudCard(parent, data, index)
        local columns = 2
        local cardWidth = (parent.AbsoluteSize.X - 30) / columns
        local cardHeight = 200
        local padding = 10
        
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local xPos = col * (cardWidth + padding) + padding
        local yPos = row * (cardHeight + padding) + padding
        
        local cloudCard = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(248, 250, 252),
            Size = UDim2.new(0, cardWidth, 0, cardHeight),
            Position = UDim2.new(0, xPos, 0, yPos),
            Name = "CloudCard",
            ClipsDescendants = true
        })
        FW.cC(cloudCard, 0.12)
        FW.cS(cloudCard, 1, Color3.fromRGB(226, 232, 240))

        local headerSection = FW.cF(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(99, 102, 241),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "HeaderSection"
        })

        local titleLbl = FW.cT(headerSection, {
            Text = string.len(data.title or "Unknown Script") > 25 and string.sub(data.title or "Unknown Script", 1, 25) .. "..." or (data.title or "Unknown Script"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Center,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(titleLbl, 16)

        local infoSection = FW.cF(cloudCard, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 80),
            Position = UDim2.new(0, 10, 0, 70),
            Name = "InfoSection"
        })

        local gameLbl = FW.cT(infoSection, {
            Text = "Game: " .. string.sub((data.game and data.game.name or "Universal"), 1, 25),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(75, 85, 99),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.33, 0),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(gameLbl, 12)

        local authorLbl = FW.cT(infoSection, {
            Text = "Author: " .. (data.owner and data.owner.username or "Unknown"),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(75, 85, 99),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.33, 0),
            Position = UDim2.new(0, 0, 0.33, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(authorLbl, 12)

        local statsLbl = FW.cT(infoSection, {
            Text = "Views: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 11,
            TextColor3 = Color3.fromRGB(107, 114, 128),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.33, 0),
            Position = UDim2.new(0, 0, 0.66, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(statsLbl, 11)

        local selectBtn = FW.cB(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 1, -45),
            Text = "SELECT SCRIPT",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(selectBtn, 0.08)

        selectBtn.MouseButton1Click:Connect(function()
            selScript = data
            showCloudOptions(data)
        end)

        return cloudCard
    end

    function showCloudOptions(data)
        if scriptF then
            scriptF:Destroy()
        end
        local ui = FW.getUI()
        local mainUI = ui["11"]
        scriptF = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "CloudOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0, 500, 0, 400),
            Position = UDim2.new(0.5, -250, 0.5, -200),
            Name = "OptionsPanel",
            ClipsDescendants = true
        })
        FW.cC(optionsPanel, 0.16)
        FW.cS(optionsPanel, 2, Color3.fromRGB(226, 232, 240))

        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(99, 102, 241),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })

        local title = FW.cT(titleBar, {
            Text = string.len(data.title or "Cloud Script") > 30 and string.sub(data.title or "Cloud Script", 1, 30) .. "..." or (data.title or "Cloud Script"),
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(title, 18)

        local closeBtn = FW.cB(titleBar, {
            BackgroundColor3 = Color3.fromRGB(239, 68, 68),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 0.5)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local infoPanel = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(249, 250, 251),
            Size = UDim2.new(1, -40, 0, 100),
            Position = UDim2.new(0, 20, 0, 80),
            Name = "InfoPanel",
            ClipsDescendants = true
        })
        FW.cC(infoPanel, 0.08)
        FW.cS(infoPanel, 1, Color3.fromRGB(229, 231, 235))

        local infoText = FW.cT(infoPanel, {
            Text = "Game: " .. (data.game and data.game.name or "Universal") .. "\nAuthor: " .. (data.owner and data.owner.username or "Unknown") .. "\nViews: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(75, 85, 99),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(infoText, 14)

        local buttonContainer = FW.cF(optionsPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 50),
            Position = UDim2.new(0, 20, 0, 200),
            Name = "ButtonContainer"
        })

        local executeBtn = FW.cB(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(34, 197, 94),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "EXECUTE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(executeBtn, 0.08)

        local copyBtn = FW.cB(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(249, 115, 22),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.345, 5, 0, 0),
            Text = "COPY",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(copyBtn, 0.08)

        local saveBtn = FW.cB(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.69, 10, 0, 0),
            Text = "SAVE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(saveBtn, 0.08)

        local previewPanel = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(17, 24, 39),
            Size = UDim2.new(1, -40, 0, 120),
            Position = UDim2.new(0, 20, 0, 270),
            Name = "PreviewPanel",
            ClipsDescendants = true
        })
        FW.cC(previewPanel, 0.08)

        local previewTitle = FW.cT(previewPanel, {
            Text = "Script Preview",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(156, 163, 175),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, 5),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewTitle, 14)

        local previewText = FW.cT(previewPanel, {
            Text = data.script and string.sub(data.script, 1, 300) .. "..." or "Loading preview...",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 90),
            Position = UDim2.new(0, 10, 0, 25),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewText, 10)

        executeBtn.MouseButton1Click:Connect(function()
            spawn(function()
                local scriptContent = nil
                if data.script then
                    scriptContent = data.script
                else
                    local success, response = pcall(function()
                        return game:HttpGet("https://scriptblox.com/api/script/" .. data._id)
                    end)
                    if success then
                        local scriptData = HttpService:JSONDecode(response)
                        if scriptData.script then
                            scriptContent = scriptData.script
                        end
                    end
                end
                if scriptContent then
                    FW.showAlert("Success", "Executing script...", 2)
                    local success, result = pcall(function()
                        return loadstring(scriptContent)
                    end)
                    if success and result then
                        local execSuccess, execErr = pcall(result)
                        if execSuccess then
                            FW.showAlert("Success", "Script executed!", 2)
                        else
                            FW.showAlert("Error", "Execution failed!", 3)
                        end
                    else
                        FW.showAlert("Error", "Compilation failed!", 3)
                    end
                else
                    FW.showAlert("Error", "Failed to fetch script!", 3)
                end
                scriptF:Destroy()
                scriptF = nil
            end)
        end)

        copyBtn.MouseButton1Click:Connect(function()
            spawn(function()
                local scriptContent = nil
                if data.script then
                    scriptContent = data.script
                else
                    local success, response = pcall(function()
                        return game:HttpGet("https://scriptblox.com/api/script/" .. data._id)
                    end)
                    if success then
                        local scriptData = HttpService:JSONDecode(response)
                        if scriptData.script then
                            scriptContent = scriptData.script
                        end
                    end
                end
                if scriptContent and setclipboard then
                    setclipboard(scriptContent)
                    FW.showAlert("Success", "Script copied!", 2)
                else
                    FW.showAlert("Error", "Failed to copy!", 3)
                end
                scriptF:Destroy()
                scriptF = nil
            end)
        end)

        saveBtn.MouseButton1Click:Connect(function()
            spawn(function()
                local scriptContent = nil
                if data.script then
                    scriptContent = data.script
                else
                    local success, response = pcall(function()
                        return game:HttpGet("https://scriptblox.com/api/script/" .. data._id)
                    end)
                    if success then
                        local scriptData = HttpService:JSONDecode(response)
                        if scriptData.script then
                            scriptContent = scriptData.script
                        end
                    end
                end
                if scriptContent then
                    saveScript(data.title or "CloudScript_" .. tick(), scriptContent)
                    FW.showAlert("Success", "Script saved!", 2)
                else
                    FW.showAlert("Error", "Failed to save!", 3)
                end
                scriptF:Destroy()
                scriptF = nil
            end)
        end)
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

    local function displayCloudScripts(scripts, scrollFrame)
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child.Name == "CloudCard" then
                child:Destroy()
            end
        end
        for i, script in pairs(scripts) do
            createCloudCard(scrollFrame, script, i)
        end
        local columns = 2
        local cardHeight = 200
        local padding = 10
        local totalRows = math.ceil(#scripts / columns)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cardHeight + padding) + padding)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(243, 244, 246),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local sidebar = FW.cF(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(31, 41, 55),
        Size = UDim2.new(0, 200, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "NavigationSidebar",
        ClipsDescendants = true
    })

    local sidebarTitle = FW.cT(sidebar, {
        Text = "SCRIPT HUB",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 20),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(sidebarTitle, 18)

    local localNavBtn = FW.cB(sidebar, {
        BackgroundColor3 = Color3.fromRGB(59, 130, 246),
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 90),
        Text = "LOCAL SCRIPTS",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(localNavBtn, 0.08)

    local cloudNavBtn = FW.cB(sidebar, {
        BackgroundColor3 = Color3.fromRGB(75, 85, 99),
        Size = UDim2.new(1, -20, 0, 45),
        Position = UDim2.new(0, 10, 0, 145),
        Text = "CLOUD SCRIPTS",
        TextColor3 = Color3.fromRGB(209, 213, 219),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(cloudNavBtn, 0.08)

    local mainContent = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 1, 0),
        Position = UDim2.new(0, 200, 0, 0),
        Name = "MainContent"
    })

    localF = FW.cF(mainContent, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "LocalFrame",
        Visible = true
    })

    cloudF = FW.cF(mainContent, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "CloudFrame",
        Visible = false
    })

    local localHeader = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, -40, 0, 120),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "LocalHeader",
        ClipsDescendants = true
    })
    FW.cC(localHeader, 0.12)
    FW.cS(localHeader, 1, Color3.fromRGB(226, 232, 240))

    local headerTitle = FW.cT(localHeader, {
        Text = "Local Scripts Manager",
        TextSize = 24,
        TextColor3 = Color3.fromRGB(31, 41, 55),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 40),
        Position = UDim2.new(0, 20, 0, 15),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(headerTitle, 24)

    local inputRow = FW.cF(localHeader, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 50),
        Position = UDim2.new(0, 20, 0, 55),
        Name = "InputRow"
    })

    local nameInput = FW.cTB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(249, 250, 251),
        Size = UDim2.new(0.3, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(31, 41, 55),
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true
    })
    FW.cC(nameInput, 0.08)
    FW.cS(nameInput, 1, Color3.fromRGB(209, 213, 219))

    local contentInput = FW.cTB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(249, 250, 251),
        Size = UDim2.new(0.4, -5, 1, 0),
        Position = UDim2.new(0.31, 5, 0, 0),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(31, 41, 55),
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        TextSize = 12,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true
    })
    FW.cC(contentInput, 0.08)
    FW.cS(contentInput, 1, Color3.fromRGB(209, 213, 219))

    local saveBtn = FW.cB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(34, 197, 94),
        Size = UDim2.new(0.14, -5, 1, 0),
        Position = UDim2.new(0.72, 5, 0, 0),
        Text = "SAVE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(saveBtn, 0.08)

    local pasteBtn = FW.cB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(249, 115, 22),
        Size = UDim2.new(0.14, -5, 1, 0),
        Position = UDim2.new(0.87, 5, 0, 0),
        Text = "PASTE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(pasteBtn, 0.08)

    local scriptsContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, -40, 1, -170),
        Position = UDim2.new(0, 20, 0, 150),
        Name = "ScriptsContainer",
        ClipsDescendants = true
    })
    FW.cC(scriptsContainer, 0.12)
    FW.cS(scriptsContainer, 1, Color3.fromRGB(226, 232, 240))

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(156, 163, 175)
    })
    scriptsScrollRef = scriptsScroll

    local cloudHeader = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "CloudHeader",
        ClipsDescendants = true
    })
    FW.cC(cloudHeader, 0.12)
    FW.cS(cloudHeader, 1, Color3.fromRGB(226, 232, 240))

    local cloudTitle = FW.cT(cloudHeader, {
        Text = "Cloud Scripts Browser",
        TextSize = 24,
        TextColor3 = Color3.fromRGB(31, 41, 55),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0.5, 0),
        Position = UDim2.new(0, 20, 0, 10),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(cloudTitle, 24)

    local searchInput = FW.cTB(cloudHeader, {
        BackgroundColor3 = Color3.fromRGB(249, 250, 251),
        Size = UDim2.new(0.6, -10, 0, 35),
        Position = UDim2.new(0, 20, 1, -45),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(31, 41, 55),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchInput, 0.08)
    FW.cS(searchInput, 1, Color3.fromRGB(209, 213, 219))

    local searchBtn = FW.cB(cloudHeader, {
        BackgroundColor3 = Color3.fromRGB(59, 130, 246),
        Size = UDim2.new(0.3, -10, 0, 35),
        Position = UDim2.new(0.7, 0, 1, -45),
        Text = "SEARCH",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchBtn, 0.08)

    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, -40, 1, -130),
        Position = UDim2.new(0, 20, 0, 110),
        Name = "CloudScrollContainer",
        ClipsDescendants = true
    })
    FW.cC(cloudScrollContainer, 0.12)
    FW.cS(cloudScrollContainer, 1, Color3.fromRGB(226, 232, 240))

    local cloudScroll = FW.cSF(cloudScrollContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(156, 163, 175)
    })

    saveBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        local content = contentInput.Text
        if name and name ~= "" and content and content ~= "" then
            saveScript(name, content)
            nameInput.Text = ""
            contentInput.Text = ""
            FW.showAlert("Success", "Script saved: " .. name, 2)
        else
            FW.showAlert("Error", "Please enter name and content!", 2)
        end
    end)

    pasteBtn.MouseButton1Click:Connect(function()
        local clipboard = getclipboard and getclipboard() or ""
        if clipboard ~= "" then
            contentInput.Text = clipboard
            FW.showAlert("Success", "Content pasted!", 2)
        else
            FW.showAlert("Error", "Clipboard is empty!", 2)
        end
    end)

    searchBtn.MouseButton1Click:Connect(function()
        local query = searchInput.Text
        if query and query ~= "" then
            FW.showAlert("Info", "Searching scripts...", 1)
            spawn(function()
                local scripts = searchScripts(query, 50)
                if #scripts > 0 then
                    curScripts = scripts
                    displayCloudScripts(scripts, cloudScroll)
                    FW.showAlert("Success", "Found " .. #scripts .. " scripts!", 2)
                else
                    FW.showAlert("Error", "No scripts found!", 2)
                end
            end)
        else
            FW.showAlert("Error", "Please enter a search term!", 2)
        end
    end)

    searchInput.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            searchBtn.MouseButton1Click:Fire()
        end
    end)

    localNavBtn.MouseButton1Click:Connect(function()
        switchSec("Local")
        localNavBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        localNavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudNavBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        cloudNavBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
    end)

    cloudNavBtn.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudNavBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        cloudNavBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        localNavBtn.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        localNavBtn.TextColor3 = Color3.fromRGB(209, 213, 219)
    end)

    local mainSidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if mainSidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(mainSidebar, {
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
                FW.cG(box, Color3.fromRGB(59, 130, 246), Color3.fromRGB(99, 102, 241))
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
            FW.switchPage("Scripts", mainSidebar)
        end)
    end

    loadAutoExec()
    loadScripts()
    executeAutoScripts()
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local popularScripts = searchScripts("popular", 30)
        if #popularScripts > 0 then
            curScripts = popularScripts
            displayCloudScripts(popularScripts, cloudScroll)
        end
    end)
end)
