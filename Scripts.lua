spawn(function()
    wait(1)
    local FW = _G.FW
    local HttpService = game:GetService("HttpService")
    local TweenService = game:GetService("TweenService")
    local curSec = "Local" -- Sección actual: Local o Cloud
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
    
    -- Scripts por defecto que vienen preinstalados
    local defScripts = {
        ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
        ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
        ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
    }

    -- Función para cambiar entre secciones Local y Cloud
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

    -- Funciones de gestión de auto-ejecución
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

    -- Ejecutar scripts marcados para auto-ejecución al iniciar
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

    -- Función para guardar un script localmente
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

    -- Cargar scripts guardados y por defecto
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

    -- Actualizar la lista de scripts locales (estilo tarjetas como en Cloud)
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
            
            -- Crear tarjetas en grid de 2 columnas como en la imagen de Cloud
            local columns = 2
            local cardWidth = 280
            local cardHeight = 140
            local padding = 20
            
            for i, script in pairs(scripts) do
                local row = math.floor((i - 1) / columns)
                local col = (i - 1) % columns
                local xPos = col * (cardWidth + padding) + padding
                local yPos = row * (cardHeight + padding) + padding
                
                -- Tarjeta principal con el mismo estilo que las de Cloud
                local scriptCard = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(165, 180, 252), -- Mismo azul lavanda de las imágenes
                    Size = UDim2.new(0, cardWidth, 0, cardHeight),
                    Position = UDim2.new(0, xPos, 0, yPos),
                    Name = "ScriptCard_" .. script.name,
                    ClipsDescendants = true
                })
                FW.cC(scriptCard, 0.16) -- Esquinas redondeadas como en las imágenes

                -- Sección superior con el nombre del script
                local headerSection = FW.cF(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(139, 157, 244), -- Azul más oscuro para el header
                    Size = UDim2.new(1, 0, 0, 50),
                    Position = UDim2.new(0, 0, 0, 0),
                    Name = "HeaderSection"
                })
                FW.cC(headerSection, 0.16)

                local scriptTitle = FW.cT(headerSection, {
                    Text = string.len(script.name) > 18 and string.sub(script.name, 1, 18) .. "..." or script.name,
                    TextSize = 16,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.8, 0, 1, 0),
                    Position = UDim2.new(0.1, 0, 0, 0),
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(scriptTitle, 16)

                -- Descripción del script
                local scriptDesc = FW.cT(scriptCard, {
                    Text = defScripts[script.name] and "Default system script" or "Custom user script",
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.8, 0, 0, 30),
                    Position = UDim2.new(0.1, 0, 0, 55),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(scriptDesc, 12)

                -- Indicador de auto-ejecución
                local autoIndicator = FW.cF(scriptCard, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(34, 197, 94) or Color3.fromRGB(107, 114, 128),
                    Size = UDim2.new(0, 8, 0, 8),
                    Position = UDim2.new(0, 15, 0, 90),
                    Name = "AutoIndicator"
                })
                FW.cC(autoIndicator, 1)

                local autoLabel = FW.cT(scriptCard, {
                    Text = "Auto-Execute",
                    TextSize = 10,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0, 80, 0, 15),
                    Position = UDim2.new(0, 30, 0, 85),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cTC(autoLabel, 10)

                -- Botones de acción en la parte inferior
                local actionContainer = FW.cF(scriptCard, {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, -20, 0, 30),
                    Position = UDim2.new(0, 10, 1, -40),
                    Name = "ActionContainer"
                })

                local executeBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(34, 197, 94),
                    Size = UDim2.new(0.3, -5, 1, 0),
                    Position = UDim2.new(0, 0, 0, 0),
                    Text = "Run",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(executeBtn, 0.08)

                local editBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(59, 130, 246),
                    Size = UDim2.new(0.3, -5, 1, 0),
                    Position = UDim2.new(0.35, 5, 0, 0),
                    Text = "Edit",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(editBtn, 0.08)

                local moreBtn = FW.cB(actionContainer, {
                    BackgroundColor3 = Color3.fromRGB(107, 114, 128),
                    Size = UDim2.new(0.3, -5, 1, 0),
                    Position = UDim2.new(0.7, 10, 0, 0),
                    Text = "More",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 12,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                    ClipsDescendants = true
                })
                FW.cC(moreBtn, 0.08)

                -- Eventos de los botones
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

                -- Click en el indicador de auto-ejecución para togglear
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

    -- Modal de opciones del script (estilo consistente con la UI)
    function showScriptOptions(name, content)
        if scriptF then
            scriptF:Destroy()
        end
        local ui = FW.getUI()
        local mainUI = ui["11"]
        
        -- Overlay oscuro
        scriptF = FW.cF(mainUI, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.5,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })

        -- Panel principal del modal
        local optionsPanel = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(45, 55, 72), -- Mismo color que el fondo principal
            Size = UDim2.new(0, 500, 0, 400),
            Position = UDim2.new(0.5, -250, 0.5, -200),
            Name = "OptionsPanel",
            ClipsDescendants = true
        })
        FW.cC(optionsPanel, 0.16)

        -- Header del modal
        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(165, 180, 252), -- Azul lavanda
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        FW.cC(titleBar, 0.16)

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

        -- Botón de cerrar (estilo circular como en las imágenes)
        local closeBtn = FW.cB(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(165, 180, 252),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 1) -- Completamente circular

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        -- Área de botones de acción
        local buttonContainer = FW.cF(optionsPanel, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -40, 0, 200),
            Position = UDim2.new(0, 20, 0, 80),
            Name = "ButtonContainer"
        })

        -- Botones con el mismo estilo que los de la interfaz
        local buttons = {
            {text = "Execute Script", color = Color3.fromRGB(34, 197, 94), pos = UDim2.new(0, 0, 0, 0)},
            {text = "View in Editor", color = Color3.fromRGB(59, 130, 246), pos = UDim2.new(0.5, 10, 0, 0)},
            {text = autoExecScripts[name] and "Disable Auto-Exec" or "Enable Auto-Exec", color = autoExecScripts[name] and Color3.fromRGB(239, 68, 68) or Color3.fromRGB(165, 180, 252), pos = UDim2.new(0, 0, 0, 60)},
            {text = "Delete Script", color = Color3.fromRGB(220, 38, 127), pos = UDim2.new(0.5, 10, 0, 60)}
        }

        for i, btnData in pairs(buttons) do
            local btn = FW.cB(buttonContainer, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(0.45, -5, 0, 45),
                Position = btnData.pos,
                Text = btnData.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                ClipsDescendants = true
            })
            FW.cC(btn, 0.08)

            -- Eventos específicos para cada botón
            if i == 1 then -- Execute
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
            elseif i == 2 then -- View in Editor
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
            elseif i == 3 then -- Toggle Auto-Exec
                btn.MouseButton1Click:Connect(function()
                    toggleAutoExec(name)
                    FW.showAlert("Info", autoExecScripts[name] and "Auto-execute enabled!" or "Auto-execute disabled!", 2)
                    scriptF:Destroy()
                    scriptF = nil
                end)
            elseif i == 4 then -- Delete
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

        -- Preview del código
        local previewContainer = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(26, 32, 44), -- Fondo más oscuro para el código
            Size = UDim2.new(1, -40, 0, 100),
            Position = UDim2.new(0, 20, 0, 290),
            Name = "PreviewContainer",
            ClipsDescendants = true
        })
        FW.cC(previewContainer, 0.08)

        local previewText = FW.cT(previewContainer, {
            Text = string.sub(content, 1, 200) .. (string.len(content) > 200 and "..." or ""),
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

    -- Funciones para scripts de la nube (manteniendo funcionalidad original)
    local function createCloudCard(parent, data, index)
        local columns = 2
        local cardWidth = 280
        local cardHeight = 140
        local padding = 20
        
        local row = math.floor((index - 1) / columns)
        local col = (index - 1) % columns
        local xPos = col * (cardWidth + padding) + padding
        local yPos = row * (cardHeight + padding) + padding
        
        -- Tarjeta con el mismo estilo que las locales
        local cloudCard = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(165, 180, 252),
            Size = UDim2.new(0, cardWidth, 0, cardHeight),
            Position = UDim2.new(0, xPos, 0, yPos),
            Name = "CloudCard",
            ClipsDescendants = true
        })
        FW.cC(cloudCard, 0.16)

        local headerSection = FW.cF(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(139, 157, 244),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "HeaderSection"
        })
        FW.cC(headerSection, 0.16)

        local titleLbl = FW.cT(headerSection, {
            Text = string.len(data.title or "Unknown Script") > 18 and string.sub(data.title or "Unknown Script", 1, 18) .. "..." or (data.title or "Unknown Script"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(titleLbl, 16)

        local gameInfo = FW.cT(cloudCard, {
            Text = string.sub((data.game and data.game.name or "Universal"), 1, 25),
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 0, 25),
            Position = UDim2.new(0.1, 0, 0, 55),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(gameInfo, 12)

        local statsInfo = FW.cT(cloudCard, {
            Text = "Views: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 10,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 0, 20),
            Position = UDim2.new(0.1, 0, 0, 80),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(statsInfo, 10)

        local selectBtn = FW.cB(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(59, 130, 246),
            Size = UDim2.new(1, -20, 0, 25),
            Position = UDim2.new(0, 10, 1, -35),
            Text = "Select Script",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
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

    -- Modal para opciones de scripts de la nube
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
            BackgroundColor3 = Color3.fromRGB(45, 55, 72),
            Size = UDim2.new(0, 600, 0, 500),
            Position = UDim2.new(0.5, -300, 0.5, -250),
            Name = "OptionsPanel",
            ClipsDescendants = true
        })
        FW.cC(optionsPanel, 0.16)

        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(165, 180, 252),
            Size = UDim2.new(1, 0, 0, 60),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        FW.cC(titleBar, 0.16)

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

        local closeBtn = FW.cB(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(165, 180, 252),
            Size = UDim2.new(0, 40, 0, 40),
            Position = UDim2.new(1, -50, 0, 10),
            Text = "X",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(closeBtn, 1)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        -- Información del script
        local infoPanel = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(55, 65, 81),
            Size = UDim2.new(1, -40, 0, 100),
            Position = UDim2.new(0, 20, 0, 80),
            Name = "InfoPanel",
            ClipsDescendants = true
        })
        FW.cC(infoPanel, 0.08)

        local infoText = FW.cT(infoPanel, {
            Text = "Game: " .. (data.game and data.game.name or "Universal") .. "\nAuthor: " .. (data.owner and data.owner.username or "Unknown") .. "\nViews: " .. (data.views or "0") .. " | Likes: " .. (data.likeCount or "0"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 1, -20),
            Position = UDim2.new(0, 10, 0, 10),
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(infoText, 14)

        -- Botones de acción
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
            Text = "Execute",
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
            Text = "Copy",
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
            Text = "Save Local",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cC(saveBtn, 0.08)

        -- Preview del script
        local previewPanel = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(26, 32, 44),
            Size = UDim2.new(1, -40, 0, 220),
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
            Text = data.script and string.sub(data.script, 1, 500) .. "..." or "Loading preview...",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(209, 213, 219),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 190),
            Position = UDim2.new(0, 10, 0, 25),
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            ClipsDescendants = true
        })
        FW.cTC(previewText, 10)

        -- Eventos de los botones
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

    -- Funciones de búsqueda y visualización de scripts de la nube
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
        local cardHeight = 140
        local padding = 20
        local totalRows = math.ceil(#scripts / columns)
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalRows * (cardHeight + padding) + padding)
    end

    -- Crear la página principal de scripts
    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(45, 55, 72), -- Fondo principal igual a las imágenes
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    -- Barra de búsqueda superior (estilo consistente)
    local searchContainer = FW.cF(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 0, 60),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "SearchContainer",
        ClipsDescendants = true
    })
    FW.cC(searchContainer, 0.16)

    local searchIcon = FW.cT(searchContainer, {
        Text = "Search for Settings here..", -- Placeholder como en las imágenes
        TextSize = 14,
        TextColor3 = Color3.fromRGB(156, 163, 175),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 1, 0),
        Position = UDim2.new(0.05, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(searchIcon, 14)

    -- Tabs para Local/Cloud (estilo consistente con las imágenes)
    local tabContainer = FW.cF(searchContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 0.8, 0),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Name = "TabContainer"
    })

    local localTab = FW.cB(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252), -- Azul lavanda activo
        Size = UDim2.new(0.48, -5, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Text = "Local",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(localTab, 0.08)

    local cloudTab = FW.cB(tabContainer, {
        BackgroundColor3 = Color3.fromRGB(75, 85, 99), -- Gris inactivo
        Size = UDim2.new(0.48, -5, 1, 0),
        Position = UDim2.new(0.52, 5, 0, 0),
        Text = "Cloud",
        TextColor3 = Color3.fromRGB(156, 163, 175),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(cloudTab, 0.08)

    -- Botón circular de agregar (como en las imágenes)
    local addBtn = FW.cB(searchContainer, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0, 10),
        Text = "+",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(addBtn, 1) -- Completamente circular

    -- Frames para Local y Cloud
    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 100),
        Name = "LocalFrame",
        Visible = true
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -100),
        Position = UDim2.new(0, 0, 0, 100),
        Name = "CloudFrame",
        Visible = false
    })

    -- Panel de entrada para scripts locales
    local inputPanel = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 0, 120),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "InputPanel",
        ClipsDescendants = true
    })
    FW.cC(inputPanel, 0.16)

    local inputTitle = FW.cT(inputPanel, {
        Text = "Add New Script",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 0, 25),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(inputTitle, 16)

    local nameInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(75, 85, 99),
        Size = UDim2.new(0.3, -10, 0, 35),
        Position = UDim2.new(0, 20, 0, 40),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(156, 163, 175),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput",
        ClipsDescendants = true
    })
    FW.cC(nameInput, 0.08)

    local contentInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(75, 85, 99),
        Size = UDim2.new(0.4, -10, 0, 35),
        Position = UDim2.new(0.32, 10, 0, 40),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(156, 163, 175),
        TextSize = 12,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput",
        ClipsDescendants = true
    })
    FW.cC(contentInput, 0.08)

    -- Botones de acción (estilo como en las imágenes del editor)
    local saveBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0.12, -5, 0, 35),
        Position = UDim2.new(0.74, 10, 0, 40),
        Text = "Save Script",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(saveBtn, 0.08)

    local pasteBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0.12, -5, 0, 35),
        Position = UDim2.new(0.87, 10, 0, 40),
        Text = "Paste Clipboard",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(pasteBtn, 0.08)

    -- Área de scripts locales
    local scriptsContainer = FW.cF(localF, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -170),
        Position = UDim2.new(0, 20, 0, 150),
        Name = "ScriptsContainer",
        ClipsDescendants = true
    })

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(165, 180, 252)
    })
    scriptsScrollRef = scriptsScroll

    -- Panel de búsqueda para Cloud
    local cloudSearchPanel = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 81),
        Size = UDim2.new(1, -40, 0, 80),
        Position = UDim2.new(0, 20, 0, 20),
        Name = "CloudSearchPanel",
        ClipsDescendants = true
    })
    FW.cC(cloudSearchPanel, 0.16)

    local cloudTitle = FW.cT(cloudSearchPanel, {
        Text = "Browse Cloud Scripts",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.5, 0, 0.4, 0),
        Position = UDim2.new(0, 20, 0, 10),
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(cloudTitle, 16)

    local searchInput = FW.cTB(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(75, 85, 99),
        Size = UDim2.new(0.6, -10, 0, 35),
        Position = UDim2.new(0, 20, 0, 35),
        PlaceholderText = "Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(156, 163, 175),
        Text = "",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchInput, 0.08)

    local searchBtn = FW.cB(cloudSearchPanel, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0.3, -10, 0, 35),
        Position = UDim2.new(0.65, 10, 0, 35),
        Text = "Search Scripts",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(searchBtn, 0.08)

    -- Área de resultados de Cloud
    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -40, 1, -130),
        Position = UDim2.new(0, 20, 0, 110),
        Name = "CloudScrollContainer",
        ClipsDescendants = true
    })

    local cloudScroll = FW.cSF(cloudScrollContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 6,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(165, 180, 252)
    })

    -- Eventos de los botones
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

    -- Eventos de los tabs
    localTab.MouseButton1Click:Connect(function()
        switchSec("Local")
        localTab.BackgroundColor3 = Color3.fromRGB(165, 180, 252)
        localTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTab.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        cloudTab.TextColor3 = Color3.fromRGB(156, 163, 175)
    end)

    cloudTab.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTab.BackgroundColor3 = Color3.fromRGB(165, 180, 252)
        cloudTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTab.BackgroundColor3 = Color3.fromRGB(75, 85, 99)
        localTab.TextColor3 = Color3.fromRGB(156, 163, 175)
    end)

    -- Agregar botón al sidebar principal (manteniendo estilo consistente)
    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(55, 65, 81) or Color3.fromRGB(26, 32, 44),
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
                FW.cG(box, Color3.fromRGB(165, 180, 252), Color3.fromRGB(139, 157, 244))
            else
                FW.cG(box, Color3.fromRGB(75, 85, 99), Color3.fromRGB(55, 65, 81))
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

    -- Botones circulares flotantes (como en las imágenes)
    local floatingContainer = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 120, 0, 60),
        Position = UDim2.new(1, -140, 1, -80),
        Name = "FloatingContainer"
    })

    local cloudBtn = FW.cB(floatingContainer, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 0, 0, 5),
        Text = "☁",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(cloudBtn, 1)

    local refreshBtn = FW.cB(floatingContainer, {
        BackgroundColor3 = Color3.fromRGB(165, 180, 252),
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 60, 0, 5),
        Text = "⟲",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 20,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(refreshBtn, 1)

    cloudBtn.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTab.MouseButton1Click:Fire()
    end)

    refreshBtn.MouseButton1Click:Connect(function()
        updateList()
        FW.showAlert("Success", "Scripts refreshed!", 2)
    end)

    -- Inicialización
    loadAutoExec()
    loadScripts()
    executeAutoScripts()
    
    -- Cargar scripts populares de la nube al inicio
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local popularScripts = searchScripts("popular", 30)
        if #popularScripts > 0 then
            curScripts = popularScripts
            displayCloudScripts(popularScripts, cloudScroll)
        end
    end)
end)
