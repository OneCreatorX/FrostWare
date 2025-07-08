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
    local imageAssets = {}
    
    local defScripts = {
        ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
        ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
        ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
    }

    local function getOrDownloadImageAsset(url, filename)
        local folder = "Images/"
        local path = folder .. filename
        if not isfolder(folder) then
            makefolder(folder)
        end
        if not isfile(path) then
            local success, data = pcall(function()
                return game:HttpGet(url)
            end)
            if not success then
                warn("Error al descargar imagen: " .. tostring(data))
                return nil
            end
            writefile(path, data)
        end
        return getcustomasset(path)
    end

    local function preloadImages()
        imageAssets.scriptIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/1126/1126012.png", "script_icon.png")
        imageAssets.cloudIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/2104/2104676.png", "cloud_icon.png")
        imageAssets.executeIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/727/727245.png", "execute_icon.png")
        imageAssets.editIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/1159/1159633.png", "edit_icon.png")
        imageAssets.deleteIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/3096/3096673.png", "delete_icon.png")
        imageAssets.saveIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/3580/3580085.png", "save_icon.png")
        imageAssets.searchIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/622/622669.png", "search_icon.png")
        imageAssets.autoIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/2997/2997933.png", "auto_icon.png")
        imageAssets.backgroundPattern = getOrDownloadImageAsset("https://www.transparenttextures.com/patterns/dark-geometric.png", "bg_pattern.png")
        imageAssets.cardBg = getOrDownloadImageAsset("https://www.transparenttextures.com/patterns/carbon-fibre-v2.png", "card_bg.png")
    end

    local function create3DFrame(parent, props)
        local mainFrame = FW.cF(parent, props)
        FW.cC(mainFrame, 0.12)
        
        local shadowFrame = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.8,
            Size = props.Size,
            Position = UDim2.new(props.Position.X.Scale, props.Position.X.Offset + 4, props.Position.Y.Scale, props.Position.Y.Offset + 4),
            ZIndex = props.ZIndex and props.ZIndex - 1 or 0
        })
        FW.cC(shadowFrame, 0.12)
        
        local highlightFrame = FW.cF(mainFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.95,
            Size = UDim2.new(1, -2, 0, 2),
            Position = UDim2.new(0, 1, 0, 1),
            ZIndex = (props.ZIndex or 1) + 1
        })
        
        return mainFrame
    end

    local function create3DButton(parent, props)
        local btn = FW.cB(parent, props)
        FW.cC(btn, 0.08)
        
        local shadowBtn = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.7,
            Size = props.Size,
            Position = UDim2.new(props.Position.X.Scale, props.Position.X.Offset + 2, props.Position.Y.Scale, props.Position.Y.Offset + 2),
            ZIndex = props.ZIndex and props.ZIndex - 1 or 0
        })
        FW.cC(shadowBtn, 0.08)
        
        local highlightBtn = FW.cF(btn, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.9,
            Size = UDim2.new(1, -2, 0, 1),
            Position = UDim2.new(0, 1, 0, 0),
            ZIndex = (props.ZIndex or 1) + 1
        })
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.new(props.BackgroundColor3.R + 0.1, props.BackgroundColor3.G + 0.1, props.BackgroundColor3.B + 0.1)}):Play()
        end)
        
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = props.BackgroundColor3}):Play()
        end)
        
        return btn
    end

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
            local cardWidth = 260
            local cardHeight = 180
            local padding = 20
            
            for i, script in pairs(scripts) do
                local row = math.floor((i - 1) / columns)
                local col = (i - 1) % columns
                local xPos = col * (cardWidth + padding) + padding
                local yPos = row * (cardHeight + padding) + padding
                
                local scriptCard = create3DFrame(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(35, 39, 54),
                    Size = UDim2.new(0, cardWidth, 0, cardHeight),
                    Position = UDim2.new(0, xPos, 0, yPos),
                    Name = "ScriptCard_" .. script.name,
                    ClipsDescendants = true,
                    ZIndex = 2
                })

                if imageAssets.cardBg then
                    local bgImage = FW.cI(scriptCard, {
                        Image = imageAssets.cardBg,
                        Size = UDim2.new(1, 0, 1, 0),
                        Position = UDim2.new(0, 0, 0, 0),
                        BackgroundTransparency = 1,
                        ImageTransparency = 0.9,
                        ZIndex = 1
                    })
                end

                local gradientFrame = FW.cF(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(45, 52, 71),
                    Size = UDim2.new(1, 0, 0, 60),
                    Position = UDim2.new(0, 0, 0, 0),
                    Name = "GradientHeader",
                    ZIndex = 3
                })
                FW.cC(gradientFrame, 0.12)
                
                local gradient = FW.cG(gradientFrame, Color3.fromRGB(65, 75, 102), Color3.fromRGB(45, 52, 71))

                local iconFrame = FW.cF(gradientFrame, {
                    BackgroundColor3 = Color3.fromRGB(75, 85, 115),
                    Size = UDim2.new(0, 40, 0, 40),
                    Position = UDim2.new(0, 10, 0, 10),
                    Name = "IconFrame",
                    ZIndex = 4
                })
                FW.cC(iconFrame, 1)

                if imageAssets.scriptIcon then
                    local scriptIcon = FW.cI(iconFrame, {
                        Image = imageAssets.scriptIcon,
                        Size = UDim2.new(0.7, 0, 0.7, 0),
                        Position = UDim2.new(0.15, 0, 0.15, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(200, 220, 255),
                        ZIndex = 5
                    })
                end

                local scriptTitle = FW.cT(gradientFrame, {
                    Text = string.len(script.name) > 16 and string.sub(script.name, 1, 16) .. "..." or script.name,
                    TextSize = 16,
                    TextColor3 = Color3.fromRGB(220, 230, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -70, 0, 30),
                    Position = UDim2.new(0, 60, 0, 15),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 4
                })
                FW.cTC(scriptTitle, 16)

                local typeLabel = FW.cT(scriptCard, {
                    Text = defScripts[script.name] and "System Script" or "Custom Script",
                    TextSize = 12,
                    TextColor3 = defScripts[script.name] and Color3.fromRGB(100, 255, 150) or Color3.fromRGB(255, 200, 100),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 20),
                    Position = UDim2.new(0, 10, 0, 70),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 4
                })
                FW.cTC(typeLabel, 12)

                local autoContainer = FW.cF(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 25),
                    Position = UDim2.new(0, 10, 0, 95),
                    Name = "AutoContainer",
                    ZIndex = 4
                })

                local autoIndicator = create3DFrame(autoContainer, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(50, 200, 100) or Color3.fromRGB(80, 80, 100),
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 0, 0, 2),
                    Name = "AutoIndicator",
                    ZIndex = 5
                })

                if imageAssets.autoIcon then
                    local autoIcon = FW.cI(autoIndicator, {
                        Image = imageAssets.autoIcon,
                        Size = UDim2.new(0.6, 0, 0.6, 0),
                        Position = UDim2.new(0.2, 0, 0.2, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 6
                    })
                end

                local autoLabel = FW.cT(autoContainer, {
                    Text = "Auto-Execute",
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(180, 190, 210),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -30, 1, 0),
                    Position = UDim2.new(0, 25, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(autoLabel, 11)

                local buttonContainer = FW.cF(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 40),
                    Position = UDim2.new(0, 10, 1, -50),
                    Name = "ButtonContainer",
                    ZIndex = 4
                })

                local executeBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(50, 180, 100),
                    Size = UDim2.new(0.3, -3, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })

                if imageAssets.executeIcon then
                    local execIcon = FW.cI(executeBtn, {
                        Image = imageAssets.executeIcon,
                        Size = UDim2.new(0.5, 0, 0.5, 0),
                        Position = UDim2.new(0.25, 0, 0.25, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 6
                    })
                end

                local editBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(70, 130, 200),
                    Size = UDim2.new(0.3, -3, 1, 0),
                    Position = UDim2.new(0.35, 3, 0, 0),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })

                if imageAssets.editIcon then
                    local editIcon = FW.cI(editBtn, {
                        Image = imageAssets.editIcon,
                        Size = UDim2.new(0.5, 0, 0.5, 0),
                        Position = UDim2.new(0.25, 0, 0.25, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 6
                    })
                end

                local moreBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(120, 120, 140),
                    Size = UDim2.new(0.3, -3, 1, 0),
                    Position = UDim2.new(0.7, 6, 0, 0),
                    Text = "⋯",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 16,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })

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

                editBtn.MouseButton1Click:Connect(function()
                    local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                    if srcRef then
                        srcRef.Text = script.content
                        FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                        FW.showAlert("Success", "Script loaded to editor!", 2)
                    end
                end)

                moreBtn.MouseButton1Click:Connect(function()
                    showScriptOptions(script.name, script.content)
                end)

                autoIndicator.InputBegan:Connect(function(input)
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
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel = create3DFrame(scriptF, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 42),
            Size = UDim2.new(0, 550, 0, 450),
            Position = UDim2.new(0.5, -275, 0.5, -225),
            Name = "OptionsPanel",
            ClipsDescendants = true,
            ZIndex = 11
        })

        local titleBar = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 75),
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar",
            ZIndex = 12
        })

        local titleGradient = FW.cG(titleBar, Color3.fromRGB(65, 75, 105), Color3.fromRGB(45, 55, 75))

        local title = FW.cT(titleBar, {
            Text = string.len(name) > 25 and string.sub(name, 1, 25) .. "..." or name,
            TextSize = 20,
            TextColor3 = Color3.fromRGB(220, 230, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(title, 20)

        local closeBtn = create3DButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60),
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -60, 0, 10),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local buttonContainer = FW.cF(optionsPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 220),
            Position = UDim2.new(0, 20, 0, 90),
            Name = "ButtonContainer",
            ZIndex = 12
        })

        local buttons = {
            {text = "Execute Script", color = Color3.fromRGB(50, 180, 100), icon = imageAssets.executeIcon, pos = UDim2.new(0, 0, 0, 0)},
            {text = "View in Editor", color = Color3.fromRGB(70, 130, 200), icon = imageAssets.editIcon, pos = UDim2.new(0.5, 10, 0, 0)},
            {text = autoExecScripts[name] and "Disable Auto-Exec" or "Enable Auto-Exec", color = autoExecScripts[name] and Color3.fromRGB(200, 80, 80) or Color3.fromRGB(100, 150, 200), icon = imageAssets.autoIcon, pos = UDim2.new(0, 0, 0, 70)},
            {text = "Delete Script", color = Color3.fromRGB(180, 60, 60), icon = imageAssets.deleteIcon, pos = UDim2.new(0.5, 10, 0, 70)}
        }

        for i, btnData in pairs(buttons) do
            local btn = create3DButton(buttonContainer, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(0.45, -5, 0, 50),
                Position = btnData.pos,
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true,
                ZIndex = 13
            })

            if btnData.icon then
                local btnIcon = FW.cI(btn, {
                    Image = btnData.icon,
                    Size = UDim2.new(0, 24, 0, 24),
                    Position = UDim2.new(0, 10, 0, 13),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 14
                })
            end

            local btnText = FW.cT(btn, {
                Text = btnData.text,
                TextSize = 12,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -45, 1, 0),
                Position = UDim2.new(0, 40, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true,
                ZIndex = 14
            })
            FW.cTC(btnText, 12)

            if i == 1 then
                btn.MouseButton1Click:Connect(function()
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
            elseif i == 2 then
                btn.MouseButton1Click:Connect(function()
                    local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                    if srcRef then
                        srcRef.Text = content
                        FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                        FW.showAlert("Success", "Script loaded to editor!", 2)
                        scriptF:Destroy()
                        scriptF = nil
                    end
                end)
            elseif i == 3 then
                btn.MouseButton1Click:Connect(function()
                    toggleAutoExec(name)
                    FW.showAlert("Info", autoExecScripts[name] and "Auto-execute enabled!" or "Auto-execute disabled!", 2)
                    scriptF:Destroy()
                    scriptF = nil
                end)
            elseif i == 4 then
                btn.MouseButton1Click:Connect(function()
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
            end
        end

        local previewContainer = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(15, 20, 30),
            Size = UDim2.new(1, -40, 0, 120),
            Position = UDim2.new(0, 20, 0, 320),
            Name = "PreviewContainer",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local previewTitle = FW.cT(previewContainer, {
            Text = "Script Preview",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(150, 160, 180),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 5),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewTitle, 14)

        local previewText = FW.cT(previewContainer, {
            Text = string.sub(content, 1, 300) .. (string.len(content) > 300 and "..." or ""),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(180, 190, 210),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 85),
            Position = UDim2.new(0, 10, 0, 30),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewText, 10)
    end

    local function createCloudCard(parent, data, index)
        local columns = 3
        local cardWidth = 260
        local cardHeight = 180
        local padding = 20
        
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local xPos = col * (cardWidth + padding) + padding
        local yPos = row * (cardHeight + padding) + padding
        
        local cloudCard = create3DFrame(parent, {
            BackgroundColor3 = Color3.fromRGB(40, 45, 65),
            Size = UDim2.new(0, cardWidth, 0, cardHeight),
            Position = UDim2.new(0, xPos, 0, yPos),
            Name = "CloudCard",
            ClipsDescendants = true,
            ZIndex = 2
        })

        local gradientFrame = FW.cF(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(60, 70, 95),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "GradientHeader",
            ZIndex = 3
        })
        FW.cC(gradientFrame, 0.12)
        
        local cloudGradient = FW.cG(gradientFrame, Color3.fromRGB(80, 90, 125), Color3.fromRGB(60, 70, 95))

        local cloudIconFrame = FW.cF(gradientFrame, {
            BackgroundColor3 = Color3.fromRGB(90, 100, 135),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(0, 10, 0, 10),
            Name = "CloudIconFrame",
            ZIndex = 4
        })
        FW.cC(cloudIconFrame, 1)

        if imageAssets.cloudIcon then
            local cloudIcon = FW.cI(cloudIconFrame, {
                Image = imageAssets.cloudIcon,
                Size = UDim2.new(0.7, 0, 0.7, 0),
                Position = UDim2.new(0.15, 0, 0.15, 0),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(200, 220, 255),
                ZIndex = 5
            })
        end

        local titleLbl = FW.cT(gradientFrame, {
            Text = string.len(data.title or "Unknown Script") > 16 and string.sub(data.title or "Unknown Script", 1, 16) .. "..." or (data.title or "Unknown Script"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(220, 230, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -70, 0, 30),
            Position = UDim2.new(0, 60, 0, 15),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 4
        })
        FW.cTC(titleLbl, 16)

        local gameInfo = FW.cT(cloudCard, {
            Text = string.sub((data.game and data.game.name or "Universal"), 1, 25),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(150, 200, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 0, 70),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 4
        })
        FW.cTC(gameInfo, 12)

        local statsInfo = FW.cT(cloudCard, {
            Text = "Views: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(130, 150, 180),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 20),
            Position = UDim2.new(0, 10, 0, 100),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 4
        })
        FW.cTC(statsInfo, 10)

        local selectBtn = create3DButton(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(70, 130, 200),
            Size = UDim2.new(1, -20, 0, 35),
            Position = UDim2.new(0, 10, 1, -45),
            Text = "Select Script",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })

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
            BackgroundTransparency = 0.3,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "CloudOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel = create3DFrame(scriptF, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 42),
            Size = UDim2.new(0, 650, 0, 550),
            Position = UDim2.new(0.5, -325, 0.5, -275),
            Name = "OptionsPanel",
            ClipsDescendants = true,
            ZIndex = 11
        })

        local titleBar = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(60, 70, 95),
            Size = UDim2.new(1, 0, 0, 70),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar",
            ZIndex = 12
        })

        local cloudTitleGradient = FW.cG(titleBar, Color3.fromRGB(80, 90, 125), Color3.fromRGB(60, 70, 95))

        local title = FW.cT(titleBar, {
            Text = string.len(data.title or "Cloud Script") > 30 and string.sub(data.title or "Cloud Script", 1, 30) .. "..." or (data.title or "Cloud Script"),
            TextSize = 20,
            TextColor3 = Color3.fromRGB(220, 230, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(title, 20)

        local closeBtn = create3DButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(200, 60, 60),
            Size = UDim2.new(0, 50, 0, 50),
            Position = UDim2.new(1, -60, 0, 10),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local infoPanel = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(35, 42, 58),
            Size = UDim2.new(1, -40, 0, 120),
            Position = UDim2.new(0, 20, 0, 90),
            Name = "InfoPanel",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local infoText = FW.cT(infoPanel, {
            Text = "Game: " .. (data.game and data.game.name or "Universal") .. "\nAuthor: " .. (data.owner and data.owner.username or "Unknown") .. "\nViews: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0") .. "\nRating: " .. (data.rating and string.format("%.1f", data.rating) or "N/A") .. "/5",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(200, 210, 230),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(infoText, 14)

        local buttonContainer = FW.cF(optionsPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 70),
            Position = UDim2.new(0, 20, 0, 230),
            Name = "ButtonContainer",
            ZIndex = 12
        })

        local executeBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(50, 180, 100),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.executeIcon then
            local execIcon = FW.cI(executeBtn, {
                Image = imageAssets.executeIcon,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, 10, 0, 23),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local execText = FW.cT(executeBtn, {
            Text = "Execute",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(execText, 12)

        local copyBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(200, 130, 50),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.345, 5, 0, 0),
            Text = "Copy",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        local saveBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(70, 130, 200),
            Size = UDim2.new(0.31, -5, 1, 0),
            Position = UDim2.new(0.69, 10, 0, 0),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.saveIcon then
            local saveIcon = FW.cI(saveBtn, {
                Image = imageAssets.saveIcon,
                Size = UDim2.new(0, 24, 0, 24),
                Position = UDim2.new(0, 10, 0, 23),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local saveText = FW.cT(saveBtn, {
            Text = "Save Local",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 35, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(saveText, 12)

        local previewPanel = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(15, 20, 30),
            Size = UDim2.new(1, -40, 0, 220),
            Position = UDim2.new(0, 20, 0, 320),
            Name = "PreviewPanel",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local previewTitle = FW.cT(previewPanel, {
            Text = "Script Preview",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(150, 160, 180),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 30),
            Position = UDim2.new(0, 10, 0, 5),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewTitle, 16)

        local previewText = FW.cT(previewPanel, {
            Text = data.script and string.sub(data.script, 1, 600) .. "..." or "Loading preview...",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(180, 190, 210),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 180),
            Position = UDim2.new(0, 10, 0, 35),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
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
        local columns = 3
        local cardHeight = 180
        local padding = 20
        local totalRows = math.ceil(#scripts / columns)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cardHeight + padding) + padding)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(20, 25, 35),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    if imageAssets.backgroundPattern then
        local bgPattern = FW.cI(scriptsPage, {
            Image = imageAssets.backgroundPattern,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            ImageTransparency = 0.95,
            ZIndex = 0
        })
    end

    local topBar = create3DFrame(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(30, 35, 50),
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "TopBar",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local topGradient = FW.cG(topBar, Color3.fromRGB(45, 52, 71), Color3.fromRGB(30, 35, 50))

    local searchContainer = FW.cF(topBar, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0.7, 0),
        Position = UDim2.new(0, 20, 0.15, 0),
        Name = "SearchContainer",
        ZIndex = 2
    })

    local searchFrame = create3DFrame(searchContainer, {
        BackgroundColor3 = Color3.fromRGB(40, 45, 65),
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "SearchFrame",
        ZIndex = 3
    })

    if imageAssets.searchIcon then
        local searchIcon = FW.cI(searchFrame, {
            Image = imageAssets.searchIcon,
            Size = UDim2.new(0, 24, 0, 24),
            Position = UDim2.new(0, 15, 0, 18),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(150, 160, 180),
            ZIndex = 4
        })
    end

    local searchPlaceholder = FW.cT(searchFrame, {
        Text = "Search for Scripts here..",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(120, 130, 150),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 45, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 4
    })
    FW.cTC(searchPlaceholder, 14)

    local tabContainer = FW.cF(topBar, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, -40, 0.7, 0),
        Position = UDim2.new(0.65, 20, 0.15, 0),
        Name = "TabContainer",
        ZIndex = 2
    })

    local localTab = create3DButton(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(70, 130, 200),
        Size = UDim2.new(0.48, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "Local",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    local cloudTab = create3DButton(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(60, 70, 90),
        Size = UDim2.new(0.48, -5, 1, 0),
        Position = UDim2.new(0.52, 5, 0, 0),
        Text = "Cloud",
        TextColor3 = Color3.fromRGB(150, 160, 180),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -120),
        Position = UDim2.new(0, 0, 0, 120),
        Name = "LocalFrame",
        Visible = true,
        ZIndex = 1
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -120),
        Position = UDim2.new(0, 0, 0, 120),
        Name = "CloudFrame",
        Visible = false,
        ZIndex = 1
    })

    local inputPanel = create3DFrame(localF, {
        BackgroundColor3 = Color3.fromRGB(35, 42, 58),
        Size = UDim2.new(1, -40, 0, 140),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "InputPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })

    local inputGradient = FW.cG(inputPanel, Color3.fromRGB(50, 58, 78), Color3.fromRGB(35, 42, 58))

    local inputTitle = FW.cT(inputPanel, {
        Text = "Add New Script",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(200, 210, 230),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 30),
        Position = UDim2.new(0, 20, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(inputTitle, 18)

    local nameInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 71),
        Size = UDim2.new(0.3, -10, 0, 40),
        Position = UDim2.new(0, 20, 0, 55),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(220, 230, 255),
        PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(nameInput, 0.08)

    local contentInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 71),
        Size = UDim2.new(0.4, -10, 0, 40),
        Position = UDim2.new(0.32, 10, 0, 55),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(220, 230, 255),
        PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
        TextSize = 12,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(contentInput, 0.08)

    local saveBtn = create3DButton(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(70, 130, 200),
        Size = UDim2.new(0.12, -5, 0, 40),
        Position = UDim2.new(0.74, 10, 0, 55),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    if imageAssets.saveIcon then
        local saveIcon = FW.cI(saveBtn, {
            Image = imageAssets.saveIcon,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 5, 0, 10),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 4
        })
    end

    local saveText = FW.cT(saveBtn, {
        Text = "Save",
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 1, 0),
        Position = UDim2.new(0, 25, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 4
    })
    FW.cTC(saveText, 10)

    local pasteBtn = create3DButton(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(200, 130, 50),
        Size = UDim2.new(0.12, -5, 0, 40),
        Position = UDim2.new(0.87, 10, 0, 55),
        Text = "Paste",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    local scriptsContainer = FW.cF(localF, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -190),
        Position = UDim2.new(0, 20, 0, 170),
        Name = "ScriptsContainer",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(70, 130, 200),
        ZIndex = 2
    })
    scriptsScrollRef = scriptsScroll

    local cloudSearchPanel = create3DFrame(cloudF, {
        BackgroundColor3 = Color3.fromRGB(35, 42, 58),
        Size = UDim2.new(1, -40, 0, 100),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "CloudSearchPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })

    local cloudSearchGradient = FW.cG(cloudSearchPanel, Color3.fromRGB(50, 58, 78), Color3.fromRGB(35, 42, 58))

    local cloudTitle = FW.cT(cloudSearchPanel, {
        Text = "Browse Cloud Scripts",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(200, 210, 230),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0.4, 0),
        Position = UDim2.new(0, 20, 0, 15),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(cloudTitle, 18)

    local searchInput = FW.cTB(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 71),
        Size = UDim2.new(0.6, -10, 0, 40),
        Position = UDim2.new(0, 20, 0, 45),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(220, 230, 255),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(searchInput, 0.08)

    local searchBtn = create3DButton(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(70, 130, 200),
        Size = UDim2.new(0.3, -10, 0, 40),
        Position = UDim2.new(0.65, 10, 0, 45),
        Text = "Search Scripts",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -150),
        Position = UDim2.new(0, 20, 0, 130),
        Name = "CloudScrollContainer",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local cloudScroll = FW.cSF(cloudScrollContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(70, 130, 200),
        ZIndex = 2
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

    localTab.MouseButton1Click:Connect(function()
        switchSec("Local")
        localTab.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
        localTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTab.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
        cloudTab.TextColor3 = Color3.fromRGB(150, 160, 180)
    end)

    cloudTab.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTab.BackgroundColor3 = Color3.fromRGB(70, 130, 200)
        cloudTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTab.BackgroundColor3 = Color3.fromRGB(60, 70, 90)
        localTab.TextColor3 = Color3.fromRGB(150, 160, 180)
    end)

    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(35, 42, 58) or Color3.fromRGB(26, 32, 44),
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
                FW.cG(box, Color3.fromRGB(70, 130, 200), Color3.fromRGB(50, 180, 100))
            else
                FW.cG(box, Color3.fromRGB(60, 70, 90), Color3.fromRGB(45, 52, 71))
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
                TextColor3 = Color3.fromRGB(220, 230, 255),
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

    preloadImages()
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
