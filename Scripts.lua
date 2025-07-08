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
            
            local xPos = 10
            for name, content in pairs(localScripts) do
                local scriptItem = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(45, 55, 72),
                    Size = UDim2.new(0, 280, 1, -20),
                    Position = UDim2.new(0, xPos, 0, 10),
                    Name = "ScriptItem_" .. name,
                    ClipsDescendants = true
                })
                FW.cC(scriptItem, 0)
                FW.cS(scriptItem, 2, Color3.fromRGB(74, 85, 104))

                local topBar = FW.cF(scriptItem, {
                    BackgroundColor3 = Color3.fromRGB(74, 85, 104),
                    Size = UDim2.new(1, 0, 0, 40),
                    Position = UDim2.new(0, 0, 0, 0),
                    Name = "TopBar"
                })

                local scriptName = FW.cT(topBar, {
                    Text = string.len(name) > 22 and string.sub(name, 1, 22) .. "..." or name,
                    TextSize = 14,
                    TextColor3 = Color3.fromRGB(237, 242, 247),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 1, 0),
                    Position = UDim2.new(0, 10, 0, 0),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(scriptName, 14)

                local infoPanel = FW.cF(scriptItem, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 60),
                    Position = UDim2.new(0, 10, 0, 50),
                    Name = "InfoPanel"
                })

                local typeLabel = FW.cT(infoPanel, {
                    Text = "Type: " .. (defScripts[name] and "Default" or "Custom"),
                    TextSize = 11,
                    TextColor3 = defScripts[name] and Color3.fromRGB(104, 211, 145) or Color3.fromRGB(251, 191, 36),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0.33, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(typeLabel, 11)

                local autoLabel = FW.cT(infoPanel, {
                    Text = "Auto-Execute: " .. (autoExecScripts[name] and "Enabled" or "Disabled"),
                    TextSize = 11,
                    TextColor3 = autoExecScripts[name] and Color3.fromRGB(104, 211, 145) or Color3.fromRGB(160, 174, 192),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0.33, 0),
                    Position = UDim2.new(0, 0, 0.33, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(autoLabel, 11)

                local sizeLabel = FW.cT(infoPanel, {
                    Text = "Size: " .. string.len(content) .. " chars",
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(160, 174, 192),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0.33, 0),
                    Position = UDim2.new(0, 0, 0.66, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(sizeLabel, 11)

                local actionPanel = FW.cF(scriptItem, {
                    BackgroundColor3 = Color3.fromRGB(55, 65, 81),
                    Size = UDim2.new(1, 0, 0, 50),
                    Position = UDim2.new(0, 0, 1, -50),
                    Name = "ActionPanel"
                })

                local executeBtn = FW.cB(actionPanel, {
                    BackgroundColor3 = Color3.fromRGB(16, 185, 129),
                    Size = UDim2.new(0.45, -5, 0.6, 0),
                    Position = UDim2.new(0.05, 0, 0.2, 0),
                    Text = "RUN",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(executeBtn, 0)

                local optionsBtn = FW.cB(actionPanel, {
                    BackgroundColor3 = Color3.fromRGB(99, 102, 241),
                    Size = UDim2.new(0.45, -5, 0.6, 0),
                    Position = UDim2.new(0.5, 5, 0.2, 0),
                    Text = "OPTIONS",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(optionsBtn, 0)

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
                end)

                optionsBtn.MouseButton1Click:Connect(function()
                    showScriptOptions(name, content)
                end)

                xPos = xPos + 290
            end
            
            scriptsScrollRef.CanvasSize = UDim2.new(0, xPos, 0, 0)
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
            BackgroundTransparency = 0.6,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })

        local optionsWindow = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(26, 32, 44),
            Size = UDim2.new(0, 600, 0, 400),
            Position = UDim2.new(0.5, -300, 0.5, -200),
            Name = "OptionsWindow",
            ClipsDescendants = true
        })
        FW.cC(optionsWindow, 0)
        FW.cS(optionsWindow, 3, Color3.fromRGB(74, 85, 104))

        local titleSection = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 72),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleSection"
        })

        local title = FW.cT(titleSection, {
            Text = "Script Manager - " .. (string.len(name) > 20 and string.sub(name, 1, 20) .. "..." or name),
            TextSize = 18,
            TextColor3 = Color3.fromRGB(237, 242, 247),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(title, 18)

        local closeBtn = FW.cB(titleSection, {
            BackgroundColor3 = Color3.fromRGB(220, 38, 127),
            Size = UDim2.new(0, 50, 0, 40),
            Position = UDim2.new(1, -60, 0, 10),
            Text = "CLOSE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 0)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local leftPanel = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(55, 65, 81),
            Size = UDim2.new(0.4, 0, 1, -60),
            Position = UDim2.new(0, 0, 0, 60),
            Name = "LeftPanel",
            ClipsDescendants = true
        })

        local rightPanel = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(31, 41, 55),
            Size = UDim2.new(0.6, 0, 1, -60),
            Position = UDim2.new(0.4, 0, 0, 60),
            Name = "RightPanel",
            ClipsDescendants = true
        })

        local actionTitle = FW.cT(leftPanel, {
            Text = "ACTIONS",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 10),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(actionTitle, 16)

        local buttonContainer = FW.cF(leftPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -60),
            Position = UDim2.new(0, 10, 0, 50),
            Name = "ButtonContainer"
        })

        local buttons = {
            {text = "EXECUTE SCRIPT", color = Color3.fromRGB(16, 185, 129), action = function()
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
            end},
            {text = "VIEW IN EDITOR", color = Color3.fromRGB(59, 130, 246), action = function()
                local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                if srcRef then
                    srcRef.Text = content
                    FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                    FW.showAlert("Success", "Script loaded to editor!", 2)
                    scriptF:Destroy()
                    scriptF = nil
                end
            end},
            {text = autoExecScripts[name] and "DISABLE AUTO-EXEC" or "ENABLE AUTO-EXEC", color = autoExecScripts[name] and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(34, 197, 94), action = function()
                toggleAutoExec(name)
                FW.showAlert("Info", autoExecScripts[name] and "Auto-execute enabled!" or "Auto-execute disabled!", 2)
                scriptF:Destroy()
                scriptF = nil
            end},
            {text = "DELETE SCRIPT", color = Color3.fromRGB(220, 38, 127), action = function()
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
            end}
        }

        for i, btnData in pairs(buttons) do
            local btn = FW.cB(buttonContainer, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.new(0, 0, 0, (i-1) * 60),
                Text = btnData.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true
            })
            FW.cC(btn, 0)
            btn.MouseButton1Click:Connect(btnData.action)
        end

        local previewTitle = FW.cT(rightPanel, {
            Text = "SCRIPT PREVIEW",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 10),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewTitle, 16)

        local previewContainer = FW.cF(rightPanel, {
            BackgroundColor3 = Color3.fromRGB(17, 24, 39),
            Size = UDim2.new(1, -20, 1, -60),
            Position = UDim2.new(0, 10, 0, 50),
            Name = "PreviewContainer",
            ClipsDescendants = true
        })
        FW.cC(previewContainer, 0)
        FW.cS(previewContainer, 1, Color3.fromRGB(55, 65, 81))

        local previewText = FW.cT(previewContainer, {
            Text = string.sub(content, 1, 800) .. (string.len(content) > 800 and "..." or ""),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(156, 163, 175),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewText, 10)
    end

    local function createCloudItem(parent, data, index)
        local xPos = (index - 1) * 320 + 10
        
        local cloudItem = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 72),
            Size = UDim2.new(0, 300, 1, -20),
            Position = UDim2.new(0, xPos, 0, 10),
            Name = "CloudItem",
            ClipsDescendants = true
        })
        FW.cC(cloudItem, 0)
        FW.cS(cloudItem, 2, Color3.fromRGB(74, 85, 104))

        local headerBar = FW.cF(cloudItem, {
            BackgroundColor3 = Color3.fromRGB(99, 102, 241),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "HeaderBar"
        })

        local titleLbl = FW.cT(headerBar, {
            Text = string.len(data.title or "Unknown Script") > 25 and string.sub(data.title or "Unknown Script", 1, 25) .. "..." or (data.title or "Unknown Script"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(titleLbl, 14)

        local infoSection = FW.cF(cloudItem, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 80),
            Position = UDim2.new(0, 10, 0, 60),
            Name = "InfoSection"
        })

        local gameInfo = FW.cT(infoSection, {
            Text = "Game: " .. string.sub((data.game and data.game.name or "Universal"), 1, 30),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(203, 213, 224),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.25, 0),
            Position = UDim2.new(0, 0, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(gameInfo, 12)

        local authorInfo = FW.cT(infoSection, {
            Text = "Author: " .. (data.owner and data.owner.username or "Unknown"),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(203, 213, 224),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.25, 0),
            Position = UDim2.new(0, 0, 0.25, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(authorInfo, 12)

        local statsInfo = FW.cT(infoSection, {
            Text = "Views: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 11,
            TextColor3 = Color3.fromRGB(160, 174, 192),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.25, 0),
            Position = UDim2.new(0, 0, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(statsInfo, 11)

        local ratingInfo = FW.cT(infoSection, {
            Text = "Rating: " .. (data.rating and string.format("%.1f", data.rating) or "N/A") .. "/5",
            TextSize = 11,
            TextColor3 = Color3.fromRGB(251, 191, 36),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.25, 0),
            Position = UDim2.new(0, 0, 0.75, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(ratingInfo, 11)

        local actionSection = FW.cF(cloudItem, {
            BackgroundColor3 = Color3.fromRGB(55, 65, 81),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 1, -60),
            Name = "ActionSection"
        })

        local selectBtn = FW.cB(actionSection, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(0.9, 0, 0.6, 0),
            Position = UDim2.new(0.05, 0, 0.2, 0),
            Text = "SELECT & MANAGE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(selectBtn, 0)

        selectBtn.MouseButton1Click:Connect(function()
            selScript = data
            showCloudOptions(data)
        end)

        return cloudItem
    end

    function showCloudOptions(data)
        if scriptF then
            scriptF:Destroy()
        end
        local ui = FW.getUI()
        local mainUI = ui["11"]
        scriptF = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.6,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "CloudOptionsOverlay",
            ZIndex = 10
        })

        local optionsWindow = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(26, 32, 44),
            Size = UDim2.new(0, 700, 0, 500),
            Position = UDim2.new(0.5, -350, 0.5, -250),
            Name = "OptionsWindow",
            ClipsDescendants = true
        })
        FW.cC(optionsWindow, 0)
        FW.cS(optionsWindow, 3, Color3.fromRGB(74, 85, 104))

        local titleSection = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(99, 102, 241),
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleSection"
        })

        local title = FW.cT(titleSection, {
            Text = "Cloud Script Manager",
            TextSize = 20,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 0.6, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(title, 20)

        local subtitle = FW.cT(titleSection, {
            Text = string.len(data.title or "Unknown Script") > 35 and string.sub(data.title or "Unknown Script", 1, 35) .. "..." or (data.title or "Unknown Script"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(224, 231, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.7, 0, 0.3, 0),
            Position = UDim2.new(0.05, 0, 0.65, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(subtitle, 14)

        local closeBtn = FW.cB(titleSection, {
            BackgroundColor3 = Color3.fromRGB(220, 38, 127),
            Size = UDim2.new(0, 60, 0, 50),
            Position = UDim2.new(1, -70, 0, 10),
            Text = "CLOSE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 0)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local topPanel = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 72),
            Size = UDim2.new(1, 0, 0, 120),
            Position = UDim2.new(0, 0, 0, 70),
            Name = "TopPanel",
            ClipsDescendants = true
        })

        local infoGrid = FW.cF(topPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, -20),
            Position = UDim2.new(0, 20, 0, 10),
            Name = "InfoGrid"
        })

        local infoLabels = {
            {text = "Game: " .. (data.game and data.game.name or "Universal"), pos = UDim2.new(0, 0, 0, 0)},
            {text = "Author: " .. (data.owner and data.owner.username or "Unknown"), pos = UDim2.new(0.5, 0, 0, 0)},
            {text = "Views: " .. (data.views or "0"), pos = UDim2.new(0, 0, 0.33, 0)},
            {text = "Likes: " .. (data.likeCount or "0"), pos = UDim2.new(0.5, 0, 0.33, 0)},
            {text = "Rating: " .. (data.rating and string.format("%.1f", data.rating) or "N/A") .. "/5", pos = UDim2.new(0, 0, 0.66, 0)},
            {text = "Updated: " .. (data.updatedAt and string.sub(data.updatedAt, 1, 10) or "Unknown"), pos = UDim2.new(0.5, 0, 0.66, 0)}
        }

        for _, info in pairs(infoLabels) do
            local label = FW.cT(infoGrid, {
                Text = info.text,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(203, 213, 224),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.45, 0, 0.25, 0),
                Position = info.pos,
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                ClipsDescendants = true
            })
            FW.cTC(label, 12)
        end

        local middlePanel = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(55, 65, 81),
            Size = UDim2.new(1, 0, 0, 80),
            Position = UDim2.new(0, 0, 0, 190),
            Name = "MiddlePanel"
        })

        local actionTitle = FW.cT(middlePanel, {
            Text = "AVAILABLE ACTIONS",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 25),
            Position = UDim2.new(0, 20, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(actionTitle, 16)

        local buttonRow = FW.cF(middlePanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 40),
            Position = UDim2.new(0, 20, 0, 35),
            Name = "ButtonRow"
        })

        local executeBtn = FW.cB(buttonRow, {
            BackgroundColor3 = Color3.fromRGB(16, 185, 129),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "EXECUTE",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(executeBtn, 0)

        local copyBtn = FW.cB(buttonRow, {
            BackgroundColor3 = Color3.fromRGB(251, 191, 36),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.345, 5, 0, 0),
            Text = "COPY",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(copyBtn, 0)

        local saveBtn = FW.cB(buttonRow, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.69, 10, 0, 0),
            Text = "SAVE LOCAL",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(saveBtn, 0)

        local bottomPanel = FW.cF(optionsWindow, {
            BackgroundColor3 = Color3.fromRGB(17, 24, 39),
            Size = UDim2.new(1, 0, 1, -270),
            Position = UDim2.new(0, 0, 0, 270),
            Name = "BottomPanel",
            ClipsDescendants = true
        })

        local previewTitle = FW.cT(bottomPanel, {
            Text = "SCRIPT PREVIEW",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(156, 163, 175),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 30),
            Position = UDim2.new(0, 20, 0, 10),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewTitle, 16)

        local previewScroll = FW.cSF(bottomPanel, {
            BackgroundColor3 = Color3.fromRGB(31, 41, 55),
            Size = UDim2.new(1, -40, 1, -50),
            Position = UDim2.new(0, 20, 0, 40),
            ScrollBarThickness = 6,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Name = "PreviewScroll",
            ScrollBarImageColor3 = Color3.fromRGB(74, 85, 104)
        })
        FW.cC(previewScroll, 0)
        FW.cS(previewScroll, 1, Color3.fromRGB(55, 65, 81))

        local previewText = FW.cT(previewScroll, {
            Text = data.script and string.sub(data.script, 1, 1000) .. (string.len(data.script) > 1000 and "..." or "") or "Loading preview...",
            TextSize = 11,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 0),
            Position = UDim2.new(0, 10, 0, 10),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewText, 11)

        local textBounds = previewText.TextBounds
        previewText.Size = UDim2.new(1, -20, 0, textBounds.Y + 20)
        previewScroll.CanvasSize = UDim2.new(0, 0, 0, textBounds.Y + 40)

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
            if child.Name == "CloudItem" then
                child:Destroy()
            end
        end
        for i, script in pairs(scripts) do
            createCloudItem(scrollFrame, script, i)
        end
        local totalWidth = #scripts * 320 + 20
        scrollFrame.CanvasSize = UDim2.new(0, totalWidth, 0, 0)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(26, 32, 44),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local topBar = FW.cF(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(45, 55, 72),
        Size = UDim2.new(1, 0, 0, 80),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "TopBar",
        ClipsDescendants = true
    })
    FW.cS(topBar, 2, Color3.fromRGB(74, 85, 104))

    local titleSection = FW.cF(topBar, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 1, 0),
        Position = UDim2.new(0, 20, 0, 0),
        Name = "TitleSection"
    })

    local mainTitle = FW.cT(titleSection, {
        Text = "SCRIPT DASHBOARD",
        TextSize = 24,
        TextColor3 = Color3.fromRGB(237, 242, 247),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.6, 0),
        Position = UDim2.new(0, 0, 0.1, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(mainTitle, 24)

    local subtitle = FW.cT(titleSection, {
        Text = "Manage and execute your scripts",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(160, 174, 192),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0.65, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(subtitle, 14)

    local navSection = FW.cF(topBar, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, -40, 1, 0),
        Position = UDim2.new(0.4, 20, 0, 0),
        Name = "NavSection"
    })

    local localTabBtn = FW.cB(navSection, {
        BackgroundColor3 = Color3.fromRGB(59, 130, 246),
        Size = UDim2.new(0.48, -5, 0.6, 0),
        Position = UDim2.new(0, 0, 0.2, 0),
        Text = "LOCAL SCRIPTS",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(localTabBtn, 0)

    local cloudTabBtn = FW.cB(navSection, {
        BackgroundColor3 = Color3.fromRGB(74, 85, 104),
        Size = UDim2.new(0.48, -5, 0.6, 0),
        Position = UDim2.new(0.52, 5, 0.2, 0),
        Text = "CLOUD SCRIPTS",
        TextColor3 = Color3.fromRGB(160, 174, 192),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(cloudTabBtn, 0)

    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        Name = "LocalFrame",
        Visible = true
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        Name = "CloudFrame",
        Visible = false
    })

    local controlPanel = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 0, 100),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "ControlPanel",
        ClipsDescendants = true
    })
    FW.cC(controlPanel, 0)
    FW.cS(controlPanel, 2, Color3.fromRGB(74, 85, 104))

    local controlTitle = FW.cT(controlPanel, {
        Text = "SCRIPT MANAGEMENT",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(209, 213, 219),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 25),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(controlTitle, 16)

    local inputRow = FW.cF(controlPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 50),
        Position = UDim2.new(0, 20, 0, 40),
        Name = "InputRow"
    })

    local nameInput = FW.cTB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(31, 41, 55),
        Size = UDim2.new(0.25, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(237, 242, 247),
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true
    })
    FW.cC(nameInput, 0)
    FW.cS(nameInput, 1, Color3.fromRGB(74, 85, 104))

    local contentInput = FW.cTB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(31, 41, 55),
        Size = UDim2.new(0.45, -5, 1, 0),
        Position = UDim2.new(0.26, 5, 0, 0),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(237, 242, 247),
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        TextSize = 12,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true
    })
    FW.cC(contentInput, 0)
    FW.cS(contentInput, 1, Color3.fromRGB(74, 85, 104))

    local saveBtn = FW.cB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(16, 185, 129),
        Size = UDim2.new(0.14, -5, 1, 0),
        Position = UDim2.new(0.72, 5, 0, 0),
        Text = "SAVE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(saveBtn, 0)

    local pasteBtn = FW.cB(inputRow, {
        BackgroundColor3 = Color3.fromRGB(251, 191, 36),
        Size = UDim2.new(0.14, -5, 1, 0),
        Position = UDim2.new(0.87, 5, 0, 0),
        Text = "PASTE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(pasteBtn, 0)

    local scriptsContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 1, -150),
        Position = UDim2.new(0, 20, 0, 130),
        Name = "ScriptsContainer",
        ClipsDescendants = true
    })
    FW.cC(scriptsContainer, 0)
    FW.cS(scriptsContainer, 2, Color3.fromRGB(74, 85, 104))

    local scriptsTitle = FW.cT(scriptsContainer, {
        Text = "YOUR SCRIPTS",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(209, 213, 219),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(scriptsTitle, 16)

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 40),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(74, 85, 104),
        ScrollingDirection = Enum.ScrollingDirection.X
    })
    scriptsScrollRef = scriptsScroll

    local cloudControlPanel = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "CloudControlPanel",
        ClipsDescendants = true
    })
    FW.cC(cloudControlPanel, 0)
    FW.cS(cloudControlPanel, 2, Color3.fromRGB(74, 85, 104))

    local cloudTitle = FW.cT(cloudControlPanel, {
        Text = "CLOUD SCRIPT BROWSER",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(209, 213, 219),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0.4, 0),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(cloudTitle, 16)

    local searchRow = FW.cF(cloudControlPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 35),
        Position = UDim2.new(0, 20, 0, 35),
        Name = "SearchRow"
    })

    local searchInput = FW.cTB(searchRow, {
        BackgroundColor3 = Color3.fromRGB(31, 41, 55),
        Size = UDim2.new(0.7, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(107, 114, 128),
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(237, 242, 247),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchInput, 0)
    FW.cS(searchInput, 1, Color3.fromRGB(74, 85, 104))

    local searchBtn = FW.cB(searchRow, {
        BackgroundColor3 = Color3.fromRGB(59, 130, 246),
        Size = UDim2.new(0.3, -5, 1, 0),
        Position = UDim2.new(0.7, 5, 0, 0),
        Text = "SEARCH SCRIPTS",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchBtn, 0)

    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 1, -130),
        Position = UDim2.new(0, 20, 0, 110),
        Name = "CloudScrollContainer",
        ClipsDescendants = true
    })
    FW.cC(cloudScrollContainer, 0)
    FW.cS(cloudScrollContainer, 2, Color3.fromRGB(74, 85, 104))

    local cloudResultsTitle = FW.cT(cloudScrollContainer, {
        Text = "SEARCH RESULTS",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(209, 213, 219),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(cloudResultsTitle, 16)

    local cloudScroll = FW.cSF(cloudScrollContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 1, -50),
        Position = UDim2.new(0, 10, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(74, 85, 104),
        ScrollingDirection = Enum.ScrollingDirection.X
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

    localTabBtn.MouseButton1Click:Connect(function()
        switchSec("Local")
        localTabBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        localTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTabBtn.BackgroundColor3 = Color3.fromRGB(74, 85, 104)
        cloudTabBtn.TextColor3 = Color3.fromRGB(160, 174, 192)
    end)

    cloudTabBtn.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTabBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
        cloudTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTabBtn.BackgroundColor3 = Color3.fromRGB(74, 85, 104)
        localTabBtn.TextColor3 = Color3.fromRGB(160, 174, 192)
    end)

    local mainSidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if mainSidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(mainSidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(45, 55, 72) or Color3.fromRGB(26, 32, 44),
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
                FW.cG(box, Color3.fromRGB(59, 130, 246), Color3.fromRGB(16, 185, 129))
            else
                FW.cG(box, Color3.fromRGB(74, 85, 104), Color3.fromRGB(55, 65, 81))
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
                TextColor3 = Color3.fromRGB(237, 242, 247),
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
