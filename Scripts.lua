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
        imageAssets.folderIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/716/716784.png", "folder_icon.png")
        imageAssets.starIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/1828/1828884.png", "star_icon.png")
        imageAssets.downloadIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/3580/3580085.png", "download_icon.png")
        imageAssets.viewIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/159/159604.png", "view_icon.png")
        imageAssets.copyIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/54/54702.png", "copy_icon.png")
        imageAssets.settingsIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/503/503849.png", "settings_icon.png")
        imageAssets.refreshIcon = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/2805/2805355.png", "refresh_icon.png")
    end

    local function create3DFrame(parent, props)
        local mainFrame = FW.cF(parent, props)
        FW.cC(mainFrame, 0.12)
        
        local shadowFrame = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.8,
            Size = props.Size,
            Position = UDim2.new(props.Position.X.Scale, props.Position.X.Offset + 3, props.Position.Y.Scale, props.Position.Y.Offset + 3),
            ZIndex = props.ZIndex and props.ZIndex - 1 or 0
        })
        FW.cC(shadowFrame, 0.12)
        
        local highlightFrame = FW.cF(mainFrame, {
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 0.95,
            Size = UDim2.new(1, -2, 0, 1),
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
            local cardWidth = 240
            local cardHeight = 160
            local padding = 15
            
            for i, script in pairs(scripts) do
                local row = math.floor((i - 1) / columns)
                local col = (i - 1) % columns
                local xPos = col * (cardWidth + padding) + padding
                local yPos = row * (cardHeight + padding) + padding
                
                local scriptCard = create3DFrame(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(32, 36, 50),
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
                        ImageTransparency = 0.92,
                        ZIndex = 1
                    })
                end

                local headerFrame = create3DFrame(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(42, 48, 65),
                    Size = UDim2.new(1, -6, 0, 45),
                    Position = UDim2.new(0, 3, 0, 3),
                    Name = "HeaderFrame",
                    ZIndex = 3
                })

                local headerGradient = FW.cG(headerFrame, Color3.fromRGB(55, 62, 82), Color3.fromRGB(42, 48, 65))

                local iconContainer = create3DFrame(headerFrame, {
                    BackgroundColor3 = Color3.fromRGB(65, 72, 95),
                    Size = UDim2.new(0, 32, 0, 32),
                    Position = UDim2.new(0, 8, 0, 6),
                    Name = "IconContainer",
                    ZIndex = 4
                })

                if imageAssets.scriptIcon then
                    local scriptIcon = FW.cI(iconContainer, {
                        Image = imageAssets.scriptIcon,
                        Size = UDim2.new(0.65, 0, 0.65, 0),
                        Position = UDim2.new(0.175, 0, 0.175, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(190, 210, 245),
                        ZIndex = 5
                    })
                end

                local titleContainer = create3DFrame(headerFrame, {
                    BackgroundColor3 = Color3.fromRGB(48, 54, 72),
                    Size = UDim2.new(1, -55, 0, 25),
                    Position = UDim2.new(0, 45, 0, 10),
                    Name = "TitleContainer",
                    ZIndex = 4
                })

                local scriptTitle = FW.cT(titleContainer, {
                    Text = string.len(script.name) > 18 and string.sub(script.name, 1, 18) .. "..." or script.name,
                    TextSize = 11,
                    TextColor3 = Color3.fromRGB(210, 220, 245),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -8, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(scriptTitle, 11)

                local infoContainer = create3DFrame(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(28, 32, 44),
                    Size = UDim2.new(1, -6, 0, 65),
                    Position = UDim2.new(0, 3, 0, 52),
                    Name = "InfoContainer",
                    ZIndex = 3
                })

                local typeContainer = create3DFrame(infoContainer, {
                    BackgroundColor3 = defScripts[script.name] and Color3.fromRGB(45, 85, 55) or Color3.fromRGB(75, 65, 45),
                    Size = UDim2.new(1, -12, 0, 18),
                    Position = UDim2.new(0, 6, 0, 5),
                    Name = "TypeContainer",
                    ZIndex = 4
                })

                local typeLabel = FW.cT(typeContainer, {
                    Text = defScripts[script.name] and "System Script" or "Custom Script",
                    TextSize = 9,
                    TextColor3 = defScripts[script.name] and Color3.fromRGB(120, 220, 150) or Color3.fromRGB(220, 180, 120),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -8, 1, 0),
                    Position = UDim2.new(0, 4, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(typeLabel, 9)

                local autoContainer = create3DFrame(infoContainer, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(45, 75, 55) or Color3.fromRGB(55, 55, 65),
                    Size = UDim2.new(1, -12, 0, 20),
                    Position = UDim2.new(0, 6, 0, 28),
                    Name = "AutoContainer",
                    ZIndex = 4
                })

                local autoIndicator = create3DFrame(autoContainer, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(60, 180, 90) or Color3.fromRGB(70, 70, 85),
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = UDim2.new(0, 4, 0, 2),
                    Name = "AutoIndicator",
                    ZIndex = 5
                })

                if imageAssets.autoIcon then
                    local autoIcon = FW.cI(autoIndicator, {
                        Image = imageAssets.autoIcon,
                        Size = UDim2.new(0.6, 0, 0.6, 0),
                        Position = UDim2.new(0.2, 0, 0.2, 0),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(245, 245, 245),
                        ZIndex = 6
                    })
                end

                local autoLabel = FW.cT(autoContainer, {
                    Text = "Auto-Execute",
                    TextSize = 8,
                    TextColor3 = Color3.fromRGB(170, 180, 200),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -28, 1, 0),
                    Position = UDim2.new(0, 24, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(autoLabel, 8)

                local buttonContainer = create3DFrame(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(25, 29, 40),
                    Size = UDim2.new(1, -6, 0, 35),
                    Position = UDim2.new(0, 3, 1, -38),
                    Name = "ButtonContainer",
                    ZIndex = 3
                })

                local executeBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(45, 160, 85),
                    Size = UDim2.new(0.28, -2, 0, 28),
                    Position = UDim2.new(0, 4, 0, 4),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 4
                })

                if imageAssets.executeIcon then
                    local execIcon = FW.cI(executeBtn, {
                        Image = imageAssets.executeIcon,
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 6, 0, 6),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 5
                    })
                end

                local execText = FW.cT(executeBtn, {
                    Text = "Run",
                    TextSize = 8,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 22, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(execText, 8)

                local editBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(60, 115, 180),
                    Size = UDim2.new(0.28, -2, 0, 28),
                    Position = UDim2.new(0.32, 2, 0, 4),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 4
                })

                if imageAssets.editIcon then
                    local editIcon = FW.cI(editBtn, {
                        Image = imageAssets.editIcon,
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 6, 0, 6),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 5
                    })
                end

                local editText = FW.cT(editBtn, {
                    Text = "Edit",
                    TextSize = 8,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 22, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(editText, 8)

                local moreBtn = create3DButton(buttonContainer, {
                    BackgroundColor3 = Color3.fromRGB(100, 100, 120),
                    Size = UDim2.new(0.28, -2, 0, 28),
                    Position = UDim2.new(0.64, 4, 0, 4),
                    Text = "",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 4
                })

                if imageAssets.settingsIcon then
                    local moreIcon = FW.cI(moreBtn, {
                        Image = imageAssets.settingsIcon,
                        Size = UDim2.new(0, 16, 0, 16),
                        Position = UDim2.new(0, 6, 0, 6),
                        BackgroundTransparency = 1,
                        ImageColor3 = Color3.fromRGB(255, 255, 255),
                        ZIndex = 5
                    })
                end

                local moreText = FW.cT(moreBtn, {
                    Text = "More",
                    TextSize = 8,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 22, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true,
                    ZIndex = 5
                })
                FW.cTC(moreText, 8)

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
            BackgroundColor3 = Color3.fromRGB(22, 27, 38),
            Size = UDim2.new(0, 500, 0, 400),
            Position = UDim2.new(0.5, -250, 0.5, -200),
            Name = "OptionsPanel",
            ClipsDescendants = true,
            ZIndex = 11
        })

        local titleBar = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(40, 48, 65),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar",
            ZIndex = 12
        })

        local titleGradient = FW.cG(titleBar, Color3.fromRGB(55, 65, 85), Color3.fromRGB(40, 48, 65))

        local title = FW.cT(titleBar, {
            Text = string.len(name) > 25 and string.sub(name, 1, 25) .. "..." or name,
            TextSize = 16,
            TextColor3 = Color3.fromRGB(210, 220, 245),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(title, 16)

        local closeBtn = create3DButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(180, 55, 55),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
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

        local buttonContainer = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(28, 33, 45),
            Size = UDim2.new(1, -20, 0, 180),
            Position = UDim2.new(0, 10, 0, 70),
            Name = "ButtonContainer",
            ZIndex = 12
        })

        local buttons = {
            {text = "Execute Script", color = Color3.fromRGB(45, 160, 85), icon = imageAssets.executeIcon, pos = UDim2.new(0, 10, 0, 10)},
            {text = "View in Editor", color = Color3.fromRGB(60, 115, 180), icon = imageAssets.editIcon, pos = UDim2.new(0.5, 5, 0, 10)},
            {text = autoExecScripts[name] and "Disable Auto-Exec" or "Enable Auto-Exec", color = autoExecScripts[name] and Color3.fromRGB(180, 70, 70) or Color3.fromRGB(85, 130, 180), icon = imageAssets.autoIcon, pos = UDim2.new(0, 10, 0, 55)},
            {text = "Delete Script", color = Color3.fromRGB(160, 55, 55), icon = imageAssets.deleteIcon, pos = UDim2.new(0.5, 5, 0, 55)},
            {text = "Copy to Clipboard", color = Color3.fromRGB(120, 90, 160), icon = imageAssets.copyIcon, pos = UDim2.new(0, 10, 0, 100)},
            {text = "Save as File", color = Color3.fromRGB(90, 140, 90), icon = imageAssets.saveIcon, pos = UDim2.new(0.5, 5, 0, 100)}
        }

        for i, btnData in pairs(buttons) do
            local btn = create3DButton(buttonContainer, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(0.45, -7.5, 0, 35),
                Position = btnData.pos,
                Text = "",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 10,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true,
                ZIndex = 13
            })

            if btnData.icon then
                local btnIcon = FW.cI(btn, {
                    Image = btnData.icon,
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = UDim2.new(0, 8, 0, 8),
                    BackgroundTransparency = 1,
                    ImageColor3 = Color3.fromRGB(255, 255, 255),
                    ZIndex = 14
                })
            end

            local btnText = FW.cT(btn, {
                Text = btnData.text,
                TextSize = 9,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -32, 1, 0),
                Position = UDim2.new(0, 30, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true,
                ZIndex = 14
            })
            FW.cTC(btnText, 9)

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
            elseif i == 5 then
                btn.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(content)
                        FW.showAlert("Success", "Script copied to clipboard!", 2)
                    else
                        FW.showAlert("Error", "Clipboard not supported!", 3)
                    end
                    scriptF:Destroy()
                    scriptF = nil
                end)
            elseif i == 6 then
                btn.MouseButton1Click:Connect(function()
                    if not isfolder("FrostWare/Exports") then makefolder("FrostWare/Exports") end
                    writefile("FrostWare/Exports/" .. name .. ".lua", content)
                    FW.showAlert("Success", "Script saved to file!", 2)
                    scriptF:Destroy()
                    scriptF = nil
                end)
            end
        end

        local previewContainer = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(15, 18, 25),
            Size = UDim2.new(1, -20, 0, 120),
            Position = UDim2.new(0, 10, 0, 260),
            Name = "PreviewContainer",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local previewTitle = FW.cT(previewContainer, {
            Text = "Script Preview",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(140, 150, 170),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 20),
            Position = UDim2.new(0, 8, 0, 5),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewTitle, 12)

        local previewText = FW.cT(previewContainer, {
            Text = string.sub(content, 1, 250) .. (string.len(content) > 250 and "..." or ""),
            TextSize = 8,
            TextColor3 = Color3.fromRGB(170, 180, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 90),
            Position = UDim2.new(0, 8, 0, 25),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewText, 8)
    end

    local function createCloudCard(parent, data, index)
        local columns = 3
        local cardWidth = 240
        local cardHeight = 160
        local padding = 15
        
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local xPos = col * (cardWidth + padding) + padding
        local yPos = row * (cardHeight + padding) + padding
        
        local cloudCard = create3DFrame(parent, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 58),
            Size = UDim2.new(0, cardWidth, 0, cardHeight),
            Position = UDim2.new(0, xPos, 0, yPos),
            Name = "CloudCard",
            ClipsDescendants = true,
            ZIndex = 2
        })

        local headerFrame = create3DFrame(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(50, 58, 78),
            Size = UDim2.new(1, -6, 0, 45),
            Position = UDim2.new(0, 3, 0, 3),
            Name = "HeaderFrame",
            ZIndex = 3
        })

        local cloudGradient = FW.cG(headerFrame, Color3.fromRGB(65, 75, 100), Color3.fromRGB(50, 58, 78))

        local cloudIconContainer = create3DFrame(headerFrame, {
            BackgroundColor3 = Color3.fromRGB(75, 85, 110),
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 8, 0, 6),
            Name = "CloudIconContainer",
            ZIndex = 4
        })

        if imageAssets.cloudIcon then
            local cloudIcon = FW.cI(cloudIconContainer, {
                Image = imageAssets.cloudIcon,
                Size = UDim2.new(0.65, 0, 0.65, 0),
                Position = UDim2.new(0.175, 0, 0.175, 0),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(190, 210, 245),
                ZIndex = 5
            })
        end

        local titleContainer = create3DFrame(headerFrame, {
            BackgroundColor3 = Color3.fromRGB(55, 63, 85),
            Size = UDim2.new(1, -55, 0, 25),
            Position = UDim2.new(0, 45, 0, 10),
            Name = "TitleContainer",
            ZIndex = 4
        })

        local titleLbl = FW.cT(titleContainer, {
            Text = string.len(data.title or "Unknown Script") > 18 and string.sub(data.title or "Unknown Script", 1, 18) .. "..." or (data.title or "Unknown Script"),
            TextSize = 11,
            TextColor3 = Color3.fromRGB(210, 220, 245),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })
        FW.cTC(titleLbl, 11)

        local infoContainer = create3DFrame(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 50),
            Size = UDim2.new(1, -6, 0, 70),
            Position = UDim2.new(0, 3, 0, 52),
            Name = "InfoContainer",
            ZIndex = 3
        })

        local gameContainer = create3DFrame(infoContainer, {
            BackgroundColor3 = Color3.fromRGB(40, 50, 70),
            Size = UDim2.new(1, -12, 0, 18),
            Position = UDim2.new(0, 6, 0, 5),
            Name = "GameContainer",
            ZIndex = 4
        })

        local gameInfo = FW.cT(gameContainer, {
            Text = string.sub((data.game and data.game.name or "Universal"), 1, 22),
            TextSize = 9,
            TextColor3 = Color3.fromRGB(140, 180, 220),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })
        FW.cTC(gameInfo, 9)

        local statsContainer = create3DFrame(infoContainer, {
            BackgroundColor3 = Color3.fromRGB(35, 42, 60),
            Size = UDim2.new(1, -12, 0, 20),
            Position = UDim2.new(0, 6, 0, 28),
            Name = "StatsContainer",
            ZIndex = 4
        })

        if imageAssets.viewIcon then
            local viewIcon = FW.cI(statsContainer, {
                Image = imageAssets.viewIcon,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 4, 0, 4),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(120, 140, 170),
                ZIndex = 5
            })
        end

        local statsInfo = FW.cT(statsContainer, {
            Text = "Views: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 8,
            TextColor3 = Color3.fromRGB(120, 140, 170),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })
        FW.cTC(statsInfo, 8)

        local ratingContainer = create3DFrame(infoContainer, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 75),
            Size = UDim2.new(1, -12, 0, 17),
            Position = UDim2.new(0, 6, 0, 48),
            Name = "RatingContainer",
            ZIndex = 4
        })

        if imageAssets.starIcon then
            local starIcon = FW.cI(ratingContainer, {
                Image = imageAssets.starIcon,
                Size = UDim2.new(0, 12, 0, 12),
                Position = UDim2.new(0, 4, 0, 2),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(220, 180, 80),
                ZIndex = 5
            })
        end

        local ratingInfo = FW.cT(ratingContainer, {
            Text = "Rating: " .. (data.rating and string.format("%.1f", data.rating) or "N/A") .. "/5",
            TextSize = 8,
            TextColor3 = Color3.fromRGB(180, 160, 120),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 20, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })
        FW.cTC(ratingInfo, 8)

        local buttonContainer = create3DFrame(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 42),
            Size = UDim2.new(1, -6, 0, 35),
            Position = UDim2.new(0, 3, 1, -38),
            Name = "ButtonContainer",
            ZIndex = 3
        })

        local selectBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(60, 115, 180),
            Size = UDim2.new(1, -8, 0, 28),
            Position = UDim2.new(0, 4, 0, 4),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 4
        })

        if imageAssets.downloadIcon then
            local selectIcon = FW.cI(selectBtn, {
                Image = imageAssets.downloadIcon,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 8, 0, 6),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 5
            })
        end

        local selectText = FW.cT(selectBtn, {
            Text = "Select Script",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 28, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 5
        })
        FW.cTC(selectText, 9)

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
            BackgroundColor3 = Color3.fromRGB(22, 27, 38),
            Size = UDim2.new(0, 550, 0, 480),
            Position = UDim2.new(0.5, -275, 0.5, -240),
            Name = "OptionsPanel",
            ClipsDescendants = true,
            ZIndex = 11
        })

        local titleBar = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(50, 58, 78),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar",
            ZIndex = 12
        })

        local cloudTitleGradient = FW.cG(titleBar, Color3.fromRGB(65, 75, 100), Color3.fromRGB(50, 58, 78))

        local title = FW.cT(titleBar, {
            Text = string.len(data.title or "Cloud Script") > 28 and string.sub(data.title or "Cloud Script", 1, 28) .. "..." or (data.title or "Cloud Script"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(210, 220, 245),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(title, 16)

        local closeBtn = create3DButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(180, 55, 55),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "✕",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
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
            BackgroundColor3 = Color3.fromRGB(32, 38, 52),
            Size = UDim2.new(1, -20, 0, 100),
            Position = UDim2.new(0, 10, 0, 70),
            Name = "InfoPanel",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local infoText = FW.cT(infoPanel, {
            Text = "Game: " .. (data.game and data.game.name or "Universal") .. "\nAuthor: " .. (data.owner and data.owner.username or "Unknown") .. "\nViews: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0") .. "\nRating: " .. (data.rating and string.format("%.1f", data.rating) or "N/A") .. "/5",
            TextSize = 11,
            TextColor3 = Color3.fromRGB(190, 200, 220),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 1, -16),
            Position = UDim2.new(0, 8, 0, 8),
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(infoText, 11)

        local buttonContainer = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(28, 33, 45),
            Size = UDim2.new(1, -20, 0, 120),
            Position = UDim2.new(0, 10, 0, 180),
            Name = "ButtonContainer",
            ZIndex = 12
        })

        local executeBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(45, 160, 85),
            Size = UDim2.new(0.3, -5, 0, 45),
            Position = UDim2.new(0, 5, 0, 10),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.executeIcon then
            local execIcon = FW.cI(executeBtn, {
                Image = imageAssets.executeIcon,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local execText = FW.cT(executeBtn, {
            Text = "Execute",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(execText, 9)

        local copyBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(180, 115, 45),
            Size = UDim2.new(0.3, -5, 0, 45),
            Position = UDim2.new(0.35, 5, 0, 10),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.copyIcon then
            local copyIcon = FW.cI(copyBtn, {
                Image = imageAssets.copyIcon,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local copyText = FW.cT(copyBtn, {
            Text = "Copy",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(copyText, 9)

        local saveBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(60, 115, 180),
            Size = UDim2.new(0.3, -5, 0, 45),
            Position = UDim2.new(0.7, 5, 0, 10),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.saveIcon then
            local saveIcon = FW.cI(saveBtn, {
                Image = imageAssets.saveIcon,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local saveText = FW.cT(saveBtn, {
            Text = "Save Local",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(saveText, 9)

        local viewBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(120, 90, 160),
            Size = UDim2.new(0.45, -5, 0, 45),
            Position = UDim2.new(0, 5, 0, 65),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.viewIcon then
            local viewIcon = FW.cI(viewBtn, {
                Image = imageAssets.viewIcon,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local viewText = FW.cT(viewBtn, {
            Text = "View in Editor",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(viewText, 9)

        local refreshBtn = create3DButton(buttonContainer, {
            BackgroundColor3 = Color3.fromRGB(90, 140, 90),
            Size = UDim2.new(0.45, -5, 0, 45),
            Position = UDim2.new(0.55, 5, 0, 65),
            Text = "",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 10,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })

        if imageAssets.refreshIcon then
            local refreshIcon = FW.cI(refreshBtn, {
                Image = imageAssets.refreshIcon,
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(0, 8, 0, 12),
                BackgroundTransparency = 1,
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                ZIndex = 14
            })
        end

        local refreshText = FW.cT(refreshBtn, {
            Text = "Refresh Data",
            TextSize = 9,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -32, 1, 0),
            Position = UDim2.new(0, 30, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 14
        })
        FW.cTC(refreshText, 9)

        local previewPanel = create3DFrame(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(15, 18, 25),
            Size = UDim2.new(1, -20, 0, 160),
            Position = UDim2.new(0, 10, 0, 310),
            Name = "PreviewPanel",
            ClipsDescendants = true,
            ZIndex = 12
        })

        local previewTitle = FW.cT(previewPanel, {
            Text = "Script Preview",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(140, 150, 170),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 25),
            Position = UDim2.new(0, 8, 0, 5),
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewTitle, 12)

        local previewText = FW.cT(previewPanel, {
            Text = data.script and string.sub(data.script, 1, 400) .. "..." or "Loading preview...",
            TextSize = 8,
            TextColor3 = Color3.fromRGB(170, 180, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -16, 0, 125),
            Position = UDim2.new(0, 8, 0, 30),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true,
            ZIndex = 13
        })
        FW.cTC(previewText, 8)

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

        viewBtn.MouseButton1Click:Connect(function()
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
                    local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                    if srcRef then
                        srcRef.Text = scriptContent
                        FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                        FW.showAlert("Success", "Script loaded to editor!", 2)
                    end
                else
                    FW.showAlert("Error", "Failed to load script!", 3)
                end
                scriptF:Destroy()
                scriptF = nil
            end)
        end)

        refreshBtn.MouseButton1Click:Connect(function()
            spawn(function()
                FW.showAlert("Info", "Refreshing script data...", 1)
                local success, response = pcall(function()
                    return game:HttpGet("https://scriptblox.com/api/script/" .. data._id)
                end)
                if success then
                    local scriptData = HttpService:JSONDecode(response)
                    if scriptData then
                        data = scriptData
                        previewText.Text = scriptData.script and string.sub(scriptData.script, 1, 400) .. "..." or "No preview available"
                        FW.showAlert("Success", "Data refreshed!", 2)
                    else
                        FW.showAlert("Error", "Failed to refresh!", 3)
                    end
                else
                    FW.showAlert("Error", "Connection failed!", 3)
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
        local cardHeight = 160
        local padding = 15
        local totalRows = math.ceil(#scripts / columns)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cardHeight + padding) + padding)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(18, 22, 32),
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
            ImageTransparency = 0.96,
            ZIndex = 0
        })
    end

    local topBar = create3DFrame(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(28, 33, 46),
        Size = UDim2.new(1, -30, 0, 70),
        Position = UDim2.new(0, 15, 0, 15),
        Name = "TopBar",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local topGradient = FW.cG(topBar, Color3.fromRGB(40, 46, 62), Color3.fromRGB(28, 33, 46))

    local searchContainer = create3DFrame(topBar, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 55),
        Size = UDim2.new(0.55, 0, 0, 50),
        Position = UDim2.new(0, 15, 0, 10),
        Name = "SearchContainer",
        ZIndex = 2
    })

    if imageAssets.searchIcon then
        local searchIcon = FW.cI(searchContainer, {
            Image = imageAssets.searchIcon,
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 12, 0, 15),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(140, 150, 170),
            ZIndex = 3
        })
    end

    local searchPlaceholder = FW.cT(searchContainer, {
        Text = "Search for Scripts here..",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(110, 120, 140),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -45, 1, 0),
        Position = UDim2.new(0, 40, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(searchPlaceholder, 12)

    local tabContainer = create3DFrame(topBar, {
        BackgroundColor3 = Color3.fromRGB(32, 37, 50),
        Size = UDim2.new(0.35, -30, 0, 50),
        Position = UDim2.new(0.6, 15, 0, 10),
        Name = "TabContainer",
        ZIndex = 2
    })

    local localTab = create3DButton(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(60, 115, 180),
        Size = UDim2.new(0.48, -2, 0, 40),
        Position = UDim2.new(0, 5, 0, 5),
        Text = "Local",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(localTab, 11)

    local cloudTab = create3DButton(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(55, 60, 75),
        Size = UDim2.new(0.48, -2, 0, 40),
        Position = UDim2.new(0.52, 2, 0, 5),
        Text = "Cloud",
        TextColor3 = Color3.fromRGB(140, 150, 170),
        TextSize = 11,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(cloudTab, 11)

    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -105),
        Position = UDim2.new(0, 0, 0, 105),
        Name = "LocalFrame",
        Visible = true,
        ZIndex = 1
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -105),
        Position = UDim2.new(0, 0, 0, 105),
        Name = "CloudFrame",
        Visible = false,
        ZIndex = 1
    })

    local inputPanel = create3DFrame(localF, {
        BackgroundColor3 = Color3.fromRGB(32, 37, 52),
        Size = UDim2.new(1, -30, 0, 120),
        Position = UDim2.new(0, 15, 0, 15),
        Name = "InputPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })

    local inputGradient = FW.cG(inputPanel, Color3.fromRGB(45, 52, 70), Color3.fromRGB(32, 37, 52))

    local inputTitle = FW.cT(inputPanel, {
        Text = "Add New Script",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(190, 200, 220),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -30, 0, 25),
        Position = UDim2.new(0, 15, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(inputTitle, 14)

    local nameInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(40, 46, 62),
        Size = UDim2.new(0.28, -5, 0, 35),
        Position = UDim2.new(0, 15, 0, 45),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(210, 220, 240),
        PlaceholderColor3 = Color3.fromRGB(110, 120, 140),
        TextSize = 11,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(nameInput, 0.08)
    FW.cTC(nameInput, 11)

    local contentInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(40, 46, 62),
        Size = UDim2.new(0.38, -5, 0, 35),
        Position = UDim2.new(0.3, 5, 0, 45),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(210, 220, 240),
        PlaceholderColor3 = Color3.fromRGB(110, 120, 140),
        TextSize = 10,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(contentInput, 0.08)
    FW.cTC(contentInput, 10)

    local saveBtn = create3DButton(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(60, 115, 180),
        Size = UDim2.new(0.15, -5, 0, 35),
        Position = UDim2.new(0.7, 5, 0, 45),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 10,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    if imageAssets.saveIcon then
        local saveIcon = FW.cI(saveBtn, {
            Image = imageAssets.saveIcon,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 5, 0, 9),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 4
        })
    end

    local saveText = FW.cT(saveBtn, {
        Text = "Save",
        TextSize = 9,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -25, 1, 0),
        Position = UDim2.new(0, 23, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 4
    })
    FW.cTC(saveText, 9)

    local pasteBtn = create3DButton(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(180, 115, 45),
        Size = UDim2.new(0.15, -5, 0, 35),
        Position = UDim2.new(0.87, 5, 0, 45),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 10,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    if imageAssets.copyIcon then
        local pasteIcon = FW.cI(pasteBtn, {
            Image = imageAssets.copyIcon,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 5, 0, 9),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 4
        })
    end

    local pasteText = FW.cT(pasteBtn, {
        Text = "Paste",
        TextSize = 9,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -25, 1, 0),
        Position = UDim2.new(0, 23, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 4
    })
    FW.cTC(pasteText, 9)

    local scriptsContainer = create3DFrame(localF, {
        BackgroundColor3 = Color3.fromRGB(25, 29, 40),
        Size = UDim2.new(1, -30, 1, -155),
        Position = UDim2.new(0, 15, 0, 145),
        Name = "ScriptsContainer",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(60, 115, 180),
        ZIndex = 2
    })
    scriptsScrollRef = scriptsScroll

    local cloudSearchPanel = create3DFrame(cloudF, {
        BackgroundColor3 = Color3.fromRGB(32, 37, 52),
        Size = UDim2.new(1, -30, 0, 85),
        Position = UDim2.new(0, 15, 0, 15),
        Name = "CloudSearchPanel",
        ClipsDescendants = true,
        ZIndex = 2
    })

    local cloudSearchGradient = FW.cG(cloudSearchPanel, Color3.fromRGB(45, 52, 70), Color3.fromRGB(32, 37, 52))

    local cloudTitle = FW.cT(cloudSearchPanel, {
        Text = "Browse Cloud Scripts",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(190, 200, 220),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 0, 25),
        Position = UDim2.new(0, 15, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cTC(cloudTitle, 14)

    local searchInput = FW.cTB(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(40, 46, 62),
        Size = UDim2.new(0.55, -5, 0, 35),
        Position = UDim2.new(0, 15, 0, 40),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(110, 120, 140),
        Text = "",
        TextSize = 11,
        TextColor3 = Color3.fromRGB(210, 220, 240),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })
    FW.cC(searchInput, 0.08)
    FW.cTC(searchInput, 11)

    local searchBtn = create3DButton(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(60, 115, 180),
        Size = UDim2.new(0.35, -10, 0, 35),
        Position = UDim2.new(0.6, 5, 0, 40),
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 11,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 3
    })

    if imageAssets.searchIcon then
        local searchBtnIcon = FW.cI(searchBtn, {
            Image = imageAssets.searchIcon,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 8, 0, 9),
            BackgroundTransparency = 1,
            ImageColor3 = Color3.fromRGB(255, 255, 255),
            ZIndex = 4
        })
    end

    local searchBtnText = FW.cT(searchBtn, {
        Text = "Search Scripts",
        TextSize = 9,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -28, 1, 0),
        Position = UDim2.new(0, 26, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true,
        ZIndex = 4
    })
    FW.cTC(searchBtnText, 9)

    local cloudScrollContainer = create3DFrame(cloudF, {
        BackgroundColor3 = Color3.fromRGB(25, 29, 40),
        Size = UDim2.new(1, -30, 1, -115),
        Position = UDim2.new(0, 15, 0, 110),
        Name = "CloudScrollContainer",
        ClipsDescendants = true,
        ZIndex = 1
    })

    local cloudScroll = FW.cSF(cloudScrollContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -8, 1, -8),
        Position = UDim2.new(0, 4, 0, 4),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(60, 115, 180),
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
        localTab.BackgroundColor3 = Color3.fromRGB(60, 115, 180)
        localTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTab.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
        cloudTab.TextColor3 = Color3.fromRGB(140, 150, 170)
    end)

    cloudTab.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTab.BackgroundColor3 = Color3.fromRGB(60, 115, 180)
        cloudTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTab.BackgroundColor3 = Color3.fromRGB(55, 60, 75)
        localTab.TextColor3 = Color3.fromRGB(140, 150, 170)
    end)

    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(32, 37, 52) or Color3.fromRGB(24, 29, 40),
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
                FW.cG(box, Color3.fromRGB(60, 115, 180), Color3.fromRGB(45, 160, 85))
            else
                FW.cG(box, Color3.fromRGB(55, 60, 75), Color3.fromRGB(40, 46, 62))
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
                TextSize = 28,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(210, 220, 240),
                BackgroundTransparency = 1,
                Size = UDim2.new(sel and 0.248 or 0.359, 0, 0.36, 0),
                Text = txt,
                Name = "Lbl",
                Position = UDim2.new(0.379, 0, 0.348, 0)
            })
            FW.cTC(lbl, 28)
            local clk = FW.cB(btn, {
                TextWrapped = true,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 12,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Name = "Clk",
                Text = "  ",
                ZIndex = 5
            })
            FW.cC(clk, 0)
            FW.cTC(clk, 12)
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
