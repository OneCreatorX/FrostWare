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
            local slideOut = TweenService:Create(curSec == "Local" and cloudF or localF, 
                TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(-1, 0, 0.18, 0)})
            local slideIn = TweenService:Create(curSec == "Local" and localF or cloudF, 
                TweenInfo.new(0.4, Enum.EasingStyle.Quart), {Position = UDim2.new(0.03, 0, 0.18, 0)})
            
            slideOut:Play()
            slideOut.Completed:Connect(function()
                if sec == "Local" then
                    localF.Visible = true
                    cloudF.Visible = false
                    localF.Position = UDim2.new(1, 0, 0.18, 0)
                else
                    localF.Visible = false
                    cloudF.Visible = true
                    cloudF.Position = UDim2.new(1, 0, 0.18, 0)
                end
                slideIn:Play()
            end)
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
            local yPos = 20
            for name, content in pairs(localScripts) do
                local scriptContainer = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                    Size = UDim2.new(1, -40, 0, 60),
                    Position = UDim2.new(0, 20, 0, yPos),
                    Name = "ScriptContainer_" .. name,
                    ClipsDescendants = true
                })
                FW.cC(scriptContainer, 0.12)
                FW.cS(scriptContainer, 1, Color3.fromRGB(230, 230, 235))

                local shadowFrame = FW.cF(scriptContainer, {
                    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                    Size = UDim2.new(1, 2, 1, 2),
                    Position = UDim2.new(0, 2, 0, 2),
                    BackgroundTransparency = 0.95,
                    ZIndex = 0
                })
                FW.cC(shadowFrame, 0.12)

                local scriptCard = FW.cF(scriptContainer, {
                    BackgroundColor3 = Color3.fromRGB(250, 250, 252),
                    Size = UDim2.new(1, -4, 1, -4),
                    Position = UDim2.new(0, 2, 0, 2),
                    Name = "ScriptCard",
                    ClipsDescendants = true,
                    ZIndex = 2
                })
                FW.cC(scriptCard, 0.08)

                local scriptNameBtn = FW.cB(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.5, 0, 1, 0),
                    Position = UDim2.new(0.05, 0, 0, 0),
                    Text = string.len(name) > 20 and string.sub(name, 1, 20) .. "..." or name,
                    TextColor3 = Color3.fromRGB(45, 55, 75),
                    TextSize = 16,
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(scriptNameBtn, 16)

                local actionContainer = FW.cF(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 1, 0),
                    Position = UDim2.new(0.58, 0, 0, 0),
                    Name = "ActionContainer",
                    Visible = false
                })

                local executeBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(76, 175, 80),
                    Size = UDim2.new(0.22, -2, 0.7, 0),
                    Position = UDim2.new(0, 0, 0.15, 0),
                    Text = "▶",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(executeBtn, 0.25)

                local viewBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(33, 150, 243),
                    Size = UDim2.new(0.22, -2, 0.7, 0),
                    Position = UDim2.new(0.26, 0, 0.15, 0),
                    Text = "👁",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(viewBtn, 0.25)

                local deleteBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(244, 67, 54),
                    Size = UDim2.new(0.22, -2, 0.7, 0),
                    Position = UDim2.new(0.52, 0, 0.15, 0),
                    Text = "🗑",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(deleteBtn, 0.25)

                local autoExecBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = autoExecScripts[name] and Color3.fromRGB(156, 39, 176) or Color3.fromRGB(158, 158, 158),
                    Size = UDim2.new(0.22, -2, 0.7, 0),
                    Position = UDim2.new(0.78, 0, 0.15, 0),
                    Text = "⚡",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(autoExecBtn, 0.25)

                local statusDot = FW.cF(scriptCard, {
                    BackgroundColor3 = defScripts[name] and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(255, 193, 7),
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0.95, 0, 0.5, -4),
                    Name = "StatusDot"
                })
                FW.cC(statusDot, 1)

                scriptNameBtn.MouseEnter:Connect(function()
                    local slideIn = TweenService:Create(actionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(0.58, 0, 0, 0)})
                    actionContainer.Visible = true
                    actionContainer.Position = UDim2.new(1, 0, 0, 0)
                    slideIn:Play()
                    TweenService:Create(scriptCard, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
                end)

                scriptCard.MouseLeave:Connect(function()
                    local slideOut = TweenService:Create(actionContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Position = UDim2.new(1, 0, 0, 0)})
                    slideOut:Play()
                    slideOut.Completed:Connect(function()
                        actionContainer.Visible = false
                    end)
                    TweenService:Create(scriptCard, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(250, 250, 252)}):Play()
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
                end)

                viewBtn.MouseButton1Click:Connect(function()
                    local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                    if srcRef then
                        srcRef.Text = content
                        FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                        FW.showAlert("Success", "Script loaded to editor!", 2)
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
                    else
                        FW.showAlert("Info", "Cannot delete default script!", 2)
                    end
                end)

                autoExecBtn.MouseButton1Click:Connect(function()
                    toggleAutoExec(name)
                    FW.showAlert("Info", autoExecScripts[name] and "Auto-execute enabled!" or "Auto-execute disabled!", 2)
                end)

                yPos = yPos + 75
            end
            scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, yPos + 20)
        end
    end

    local function createCloudBtn(parent, data, index)
        local yPos = (index - 1) * 85 + 20
        local cloudContainer = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, -40, 0, 75),
            Position = UDim2.new(0, 20, 0, yPos),
            Name = "CloudContainer",
            ClipsDescendants = true
        })
        FW.cC(cloudContainer, 0.12)
        FW.cS(cloudContainer, 1, Color3.fromRGB(230, 230, 235))

        local shadowFrame = FW.cF(cloudContainer, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 2, 1, 2),
            Position = UDim2.new(0, 2, 0, 2),
            BackgroundTransparency = 0.95,
            ZIndex = 0
        })
        FW.cC(shadowFrame, 0.12)

        local cloudCard = FW.cF(cloudContainer, {
            BackgroundColor3 = Color3.fromRGB(250, 250, 252),
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            Name = "CloudCard",
            ClipsDescendants = true,
            ZIndex = 2
        })
        FW.cC(cloudCard, 0.08)

        local titleLbl = FW.cT(cloudCard, {
            Text = string.len(data.title or "Unknown Script") > 28 and string.sub(data.title or "Unknown Script", 1, 28) .. "..." or (data.title or "Unknown Script"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(45, 55, 75),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.75, 0, 0.4, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(titleLbl, 16)

        local gameLbl = FW.cT(cloudCard, {
            Text = string.sub((data.game and data.game.name or "Universal"), 1, 25) .. (string.len(data.game and data.game.name or "Universal") > 25 and "..." or ""),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(96, 125, 139),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.5, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(gameLbl, 12)

        local statsLbl = FW.cT(cloudCard, {
            Text = (data.views or "0") .. " views • " .. (data.likeCount or "0") .. " likes",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(158, 158, 158),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.75, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(statsLbl, 10)

        local arrowIcon = FW.cT(cloudCard, {
            Text = "→",
            TextSize = 20,
            TextColor3 = Color3.fromRGB(158, 158, 158),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.1, 0, 0.6, 0),
            Position = UDim2.new(0.85, 0, 0.2, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(arrowIcon, 20)

        local clickBtn = FW.cB(cloudCard, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })

        clickBtn.MouseEnter:Connect(function()
            TweenService:Create(cloudCard, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(245, 245, 250)}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(33, 150, 243)}):Play()
        end)

        clickBtn.MouseLeave:Connect(function()
            TweenService:Create(cloudCard, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(250, 250, 252)}):Play()
            TweenService:Create(arrowIcon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(158, 158, 158)}):Play()
        end)

        clickBtn.MouseButton1Click:Connect(function()
            selScript = data
            showOpts(data)
        end)

        return cloudContainer
    end

    function showOpts(data)
        if scriptF then
            scriptF:Destroy()
        end
        local ui = FW.getUI()
        local mainUI = ui["11"]
        scriptF = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.75, 0, 0.8, 0),
            Position = UDim2.new(0.125, 0, 0.1, 0),
            Name = "ScriptFrame",
            ZIndex = 10,
            ClipsDescendants = true
        })
        FW.cC(scriptF, 0.15)
        FW.cS(scriptF, 2, Color3.fromRGB(224, 224, 224))

        local shadowFrame = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            Size = UDim2.new(1, 8, 1, 8),
            Position = UDim2.new(0, 4, 0, 4),
            BackgroundTransparency = 0.9,
            ZIndex = 0
        })
        FW.cC(shadowFrame, 0.15)

        local titleBar = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(250, 250, 252),
            Size = UDim2.new(1, 0, 0.12, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar",
            ClipsDescendants = true,
            ZIndex = 2
        })
        FW.cC(titleBar, 0.1)
        FW.cS(titleBar, 1, Color3.fromRGB(240, 240, 245), "Bottom")

        local title = FW.cT(titleBar, {
            Text = string.len(data.title or "Script Details") > 30 and string.sub(data.title or "Script Details", 1, 30) .. "..." or (data.title or "Script Details"),
            TextSize = 20,
            TextColor3 = Color3.fromRGB(45, 55, 75),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(title, 20)

        local closeBtn = FW.cB(titleBar, {
            BackgroundColor3 = Color3.fromRGB(244, 67, 54),
            Size = UDim2.new(0.08, 0, 0.6, 0),
            Position = UDim2.new(0.9, 0, 0.2, 0),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 0.25)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                local fadeOut = TweenService:Create(scriptF, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)})
                fadeOut:Play()
                fadeOut.Completed:Connect(function()
                    scriptF:Destroy()
                    scriptF = nil
                end)
            end
        end)

        local contentF = FW.cF(scriptF, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.94, 0, 0.84, 0),
            Position = UDim2.new(0.03, 0, 0.14, 0),
            Name = "ContentFrame",
            ClipsDescendants = true,
            ZIndex = 2
        })

        local infoPanel = FW.cF(contentF, {
            BackgroundColor3 = Color3.fromRGB(248, 249, 250),
            Size = UDim2.new(0.92, 0, 0.25, 0),
            Position = UDim2.new(0.04, 0, 0.05, 0),
            Name = "InfoPanel",
            ClipsDescendants = true
        })
        FW.cC(infoPanel, 0.1)
        FW.cS(infoPanel, 1, Color3.fromRGB(233, 236, 239))

        local infoLbl = FW.cT(infoPanel, {
            Text = "Game: " .. (data.game and data.game.name or "Universal") .. "\nViews: " .. (data.views or "0") .. " • Likes: " .. (data.likeCount or "0") .. "\nAuthor: " .. (data.owner and data.owner.username or "Unknown"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(73, 80, 87),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(infoLbl, 14)

        local buttonPanel = FW.cF(contentF, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.92, 0, 0.15, 0),
            Position = UDim2.new(0.04, 0, 0.35, 0),
            Name = "ButtonPanel"
        })

        local execBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(76, 175, 80),
            Size = UDim2.new(0.3, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "Execute Script",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(execBtn, 0.25)

        local copyBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(255, 193, 7),
            Size = UDim2.new(0.3, -5, 1, 0),
            Position = UDim2.new(0.35, 5, 0, 0),
            Text = "Copy Script",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(copyBtn, 0.25)

        local saveBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(33, 150, 243),
            Size = UDim2.new(0.3, -5, 1, 0),
            Position = UDim2.new(0.7, 10, 0, 0),
            Text = "Save Script",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(saveBtn, 0.25)

        local previewPanel = FW.cF(contentF, {
            BackgroundColor3 = Color3.fromRGB(248, 249, 250),
            Size = UDim2.new(0.92, 0, 0.4, 0),
            Position = UDim2.new(0.04, 0, 0.55, 0),
            Name = "PreviewPanel",
            ClipsDescendants = true
        })
        FW.cC(previewPanel, 0.1)
        FW.cS(previewPanel, 1, Color3.fromRGB(233, 236, 239))

        local previewTitle = FW.cT(previewPanel, {
            Text = "Script Preview",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(45, 55, 75),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.15, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewTitle, 16)

        local previewText = FW.cT(previewPanel, {
            Text = data.script and string.sub(data.script, 1, 500) .. "..." or "Loading preview...",
            TextSize = 11,
            TextColor3 = Color3.fromRGB(108, 117, 125),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.75, 0),
            Position = UDim2.new(0.05, 0, 0.2, 0),
            TextScaled = false,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewText, 11)

        execBtn.MouseButton1Click:Connect(function()
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

    local function displayScripts(scripts, scrollFrame)
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child.Name == "CloudContainer" then
                child:Destroy()
            end
        end
        for i, script in pairs(scripts) do
            createCloudBtn(scrollFrame, script, i)
        end
        local totalHeight = #scripts * 85 + 40
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(248, 249, 250),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local headerContainer = FW.cF(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.94, 0, 0.15, 0),
        Position = UDim2.new(0.03, 0, 0.02, 0),
        Name = "HeaderContainer",
        ClipsDescendants = true
    })
    FW.cC(headerContainer, 0.12)
    FW.cS(headerContainer, 1, Color3.fromRGB(230, 230, 235))

    local shadowHeader = FW.cF(headerContainer, {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.95,
        ZIndex = 0
    })
    FW.cC(shadowHeader, 0.12)

    local headerPanel = FW.cF(headerContainer, {
        BackgroundColor3 = Color3.fromRGB(250, 250, 252),
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Name = "HeaderPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })
    FW.cC(headerPanel, 0.08)

    local title = FW.cT(headerPanel, {
        Text = "Scripts Manager",
        TextSize = 28,
        TextColor3 = Color3.fromRGB(45, 55, 75),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(title, 28)

    local localTabBtn = FW.cB(headerPanel, {
        BackgroundColor3 = Color3.fromRGB(33, 150, 243),
        Size = UDim2.new(0.22, 0, 0.5, 0),
        Position = UDim2.new(0.5, 0, 0.25, 0),
        Text = "Local Scripts",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(localTabBtn, 0.25)

    local cloudTabBtn = FW.cB(headerPanel, {
        BackgroundColor3 = Color3.fromRGB(248, 249, 250),
        Size = UDim2.new(0.22, 0, 0.5, 0),
        Position = UDim2.new(0.74, 0, 0.25, 0),
        Text = "Cloud Scripts",
        TextColor3 = Color3.fromRGB(108, 117, 125),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(cloudTabBtn, 0.25)
    FW.cS(cloudTabBtn, 1, Color3.fromRGB(233, 236, 239))

    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.94, 0, 0.8, 0),
        Position = UDim2.new(0.03, 0, 0.18, 0),
        Name = "LocalFrame",
        Visible = true
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.94, 0, 0.8, 0),
        Position = UDim2.new(0.03, 0, 0.18, 0),
        Name = "CloudFrame",
        Visible = false
    })

    local inputContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "InputContainer",
        ClipsDescendants = true
    })
    FW.cC(inputContainer, 0.12)
    FW.cS(inputContainer, 1, Color3.fromRGB(230, 230, 235))

    local inputShadow = FW.cF(inputContainer, {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.95,
        ZIndex = 0
    })
    FW.cC(inputShadow, 0.12)

    local inputPanel = FW.cF(inputContainer, {
        BackgroundColor3 = Color3.fromRGB(250, 250, 252),
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Name = "InputPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })
    FW.cC(inputPanel, 0.08)

    local nameInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.45, -10, 0.25, 0),
        Position = UDim2.new(0.05, 0, 0.15, 0),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(45, 55, 75),
        PlaceholderColor3 = Color3.fromRGB(158, 158, 158),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true
    })
    FW.cC(nameInput, 0.1)
    FW.cS(nameInput, 1, Color3.fromRGB(206, 212, 218))

    local contentInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.45, -10, 0.25, 0),
        Position = UDim2.new(0.52, 0, 0.15, 0),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(45, 55, 75),
        PlaceholderColor3 = Color3.fromRGB(158, 158, 158),
        TextSize = 12,
        TextScaled = false,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true
    })
    FW.cC(contentInput, 0.1)
    FW.cS(contentInput, 1, Color3.fromRGB(206, 212, 218))

    local saveEditorBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(33, 150, 243),
        Size = UDim2.new(0.28, -5, 0.25, 0),
        Position = UDim2.new(0.05, 0, 0.55, 0),
        Text = "Save From Editor",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(saveEditorBtn, 0.25)

    local saveBoxBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(76, 175, 80),
        Size = UDim2.new(0.28, -5, 0.25, 0),
        Position = UDim2.new(0.36, 0, 0.55, 0),
        Text = "Save From Box",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(saveBoxBtn, 0.25)

    local pasteBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(255, 193, 7),
        Size = UDim2.new(0.28, -5, 0.25, 0),
        Position = UDim2.new(0.67, 0, 0.55, 0),
        Text = "Paste Clipboard",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(pasteBtn, 0.25)

    local scriptsContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.67, 0),
        Position = UDim2.new(0, 0, 0.33, 0),
        Name = "ScriptsContainer",
        ClipsDescendants = true
    })
    FW.cC(scriptsContainer, 0.12)
    FW.cS(scriptsContainer, 1, Color3.fromRGB(230, 230, 235))

    local scriptsShadow = FW.cF(scriptsContainer, {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.95,
        ZIndex = 0
    })
    FW.cC(scriptsShadow, 0.12)

    local scriptsPanel = FW.cF(scriptsContainer, {
        BackgroundColor3 = Color3.fromRGB(248, 249, 250),
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Name = "ScriptsPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })
    FW.cC(scriptsPanel, 0.08)

    local scriptsScroll = FW.cSF(scriptsPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(206, 212, 218)
    })
    scriptsScrollRef = scriptsScroll

    local searchContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.15, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "SearchContainer",
        ClipsDescendants = true
    })
    FW.cC(searchContainer, 0.12)
    FW.cS(searchContainer, 1, Color3.fromRGB(230, 230, 235))

    local searchShadow = FW.cF(searchContainer, {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.95,
        ZIndex = 0
    })
    FW.cC(searchShadow, 0.12)

    local searchPanel = FW.cF(searchContainer, {
        BackgroundColor3 = Color3.fromRGB(250, 250, 252),
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Name = "SearchPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })
    FW.cC(searchPanel, 0.08)

    local searchInput = FW.cTB(searchPanel, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.7, -10, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(158, 158, 158),
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(45, 55, 75),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchInput, 0.1)
    FW.cS(searchInput, 1, Color3.fromRGB(206, 212, 218))

    local searchBtn = FW.cB(searchPanel, {
        BackgroundColor3 = Color3.fromRGB(33, 150, 243),
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.77, 0, 0.2, 0),
        Text = "Search",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchBtn, 0.25)

    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.82, 0),
        Position = UDim2.new(0, 0, 0.18, 0),
        Name = "CloudScrollContainer",
        ClipsDescendants = true
    })
    FW.cC(cloudScrollContainer, 0.12)
    FW.cS(cloudScrollContainer, 1, Color3.fromRGB(230, 230, 235))

    local cloudScrollShadow = FW.cF(cloudScrollContainer, {
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        Size = UDim2.new(1, 2, 1, 2),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 0.95,
        ZIndex = 0
    })
    FW.cC(cloudScrollShadow, 0.12)

    local cloudScrollPanel = FW.cF(cloudScrollContainer, {
        BackgroundColor3 = Color3.fromRGB(248, 249, 250),
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        Name = "CloudScrollPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })
    FW.cC(cloudScrollPanel, 0.08)

    local cloudScroll = FW.cSF(cloudScrollPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(206, 212, 218)
    })

    saveEditorBtn.MouseButton1Click:Connect(function()
        local name = nameInput.Text
        if name and name ~= "" then
            local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
            if srcRef then
                saveScript(name, srcRef.Text)
                nameInput.Text = ""
                FW.showAlert("Success", "Script saved: " .. name, 2)
            end
        else
            FW.showAlert("Error", "Please enter a script name!", 2)
        end
    end)

    saveBoxBtn.MouseButton1Click:Connect(function()
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
                    displayScripts(scripts, cloudScroll)
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
        TweenService:Create(localTabBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(33, 150, 243),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(cloudTabBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(248, 249, 250),
            TextColor3 = Color3.fromRGB(108, 117, 125)
        }):Play()
    end)

    cloudTabBtn.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        TweenService:Create(cloudTabBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(33, 150, 243),
            TextColor3 = Color3.fromRGB(255, 255, 255)
        }):Play()
        TweenService:Create(localTabBtn, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(248, 249, 250),
            TextColor3 = Color3.fromRGB(108, 117, 125)
        }):Play()
    end)

    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(248, 249, 250) or Color3.fromRGB(255, 255, 255),
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
                FW.cG(box, Color3.fromRGB(33, 150, 243), Color3.fromRGB(76, 175, 80))
            else
                FW.cG(box, Color3.fromRGB(206, 212, 218), Color3.fromRGB(158, 158, 158))
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
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                TextColor3 = sel and Color3.fromRGB(45, 55, 75) or Color3.fromRGB(108, 117, 125),
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

    loadAutoExec()
    loadScripts()
    executeAutoScripts()
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local popularScripts = searchScripts("popular", 30)
        if #popularScripts > 0 then
            curScripts = popularScripts
            displayScripts(popularScripts, cloudScroll)
        end
    end)
end)
