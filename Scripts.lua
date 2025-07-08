while not getgenv()._FW_ACCESS_GRANTED do
    wait(0.5)
end

spawn(function()
    wait(1)
    local FW = getgenv()._FW or {}
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

    local function createStyledText(parent, props)
        local text = FW.cT(parent, {
            Text = props.Text,
            TextSize = props.TextSize or 14,
            TextColor3 = props.TextColor3 or Color3.fromRGB(240, 245, 255),
            BackgroundTransparency = props.BackgroundTransparency or 1,
            Size = props.Size,
            Position = props.Position,
            TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
            TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Name = props.Name or "StyledText"
        })
        FW.cTC(text, props.TextSize or 14)
        return text
    end

    local function createStyledButton(parent, props)
        local outerFrame = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(12, 16, 24),
            Size = props.Size,
            Position = props.Position,
            Name = props.Name .. "_Outer"
        })
        FW.cC(outerFrame, 0.18)
        
        local innerButton = FW.cB(outerFrame, {
            BackgroundColor3 = props.BackgroundColor3,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            Text = props.Text,
            TextColor3 = props.TextColor3,
            TextSize = props.TextSize,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Name = props.Name
        })
        FW.cC(innerButton, 0.15)
        FW.cTC(innerButton, props.TextSize)
        
        return innerButton, outerFrame
    end

    local function createStyledInput(parent, props)
        local outerFrame = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(18, 22, 32),
            Size = props.Size,
            Position = props.Position,
            Name = props.Name .. "_Outer"
        })
        FW.cC(outerFrame, 0.18)

        local input = FW.cTB(outerFrame, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            PlaceholderText = props.PlaceholderText,
            PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
            Text = props.Text or "",
            TextSize = props.TextSize,
            TextColor3 = Color3.fromRGB(240, 245, 255),
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Name = props.Name
        })
        FW.cC(input, 0.15)
        FW.cTC(input, props.TextSize)
        
        return input, outerFrame
    end

    local function createStyledContainer(parent, props)
        local outerFrame = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(8, 12, 20),
            Size = props.Size,
            Position = props.Position,
            Name = props.Name .. "_Outer"
        })
        FW.cC(outerFrame, 0.18)

        local innerFrame = FW.cF(outerFrame, {
            BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            Name = props.Name
        })
        FW.cC(innerFrame, 0.15)
        
        return innerFrame, outerFrame
    end

    local function createVerifiedBadge(parent, position)
        local verifiedOuter = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(20, 60, 110),
            Size = UDim2.new(0, 84, 0, 24),
            Position = position
        })
        FW.cC(verifiedOuter, 0.18)
        
        local verifiedBadge = FW.cF(verifiedOuter, {
            BackgroundColor3 = Color3.fromRGB(50, 130, 210),
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2)
        })
        FW.cC(verifiedBadge, 0.15)
        
        createStyledText(verifiedBadge, {
            Text = "VERIFIED",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, 0, 1, 0),
            Name = "VerifiedText"
        })
        
        return verifiedBadge
    end

    local scriptIconAsset = getOrDownloadImageAsset("https://cdn-icons-png.flaticon.com/512/1126/1126012.png", "script_icon.png")

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
            
            for i, script in pairs(scripts) do
                local yPos = (i - 1) * 65 + 10
                
                local scriptCard = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                    Size = UDim2.new(1, -20, 0, 55),
                    Position = UDim2.new(0, 10, 0, yPos),
                    Name = "ScriptCard_" .. script.name
                })
                FW.cC(scriptCard, 0.15)

                createStyledText(scriptCard, {
                    Text = script.name,
                    TextSize = 16,
                    Size = UDim2.new(0.4, 0, 0.6, 0),
                    Position = UDim2.new(0, 15, 0, 5),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "ScriptTitle"
                })

                if defScripts[script.name] then
                    createVerifiedBadge(scriptCard, UDim2.new(0, 13, 0, 28))
                end

                local autoExecBtn, autoExecOuter = createStyledButton(scriptCard, {
                    BackgroundColor3 = autoExecScripts[script.name] and Color3.fromRGB(50, 170, 90) or Color3.fromRGB(65, 75, 90),
                    Size = UDim2.new(0, 80, 0, 25),
                    Position = UDim2.new(0.45, 0, 0, 15),
                    Text = autoExecScripts[script.name] and "AUTO: ON" or "AUTO: OFF",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    Name = "AutoExecBtn"
                })

                local executeBtn, executeOuter = createStyledButton(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(50, 170, 90),
                    Size = UDim2.new(0, 80, 0, 25),
                    Position = UDim2.new(0.65, 0, 0, 15),
                    Text = "EXECUTE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Name = "ExecuteBtn"
                })

                local moreBtn, moreOuter = createStyledButton(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
                    Size = UDim2.new(0, 60, 0, 25),
                    Position = UDim2.new(0.85, 0, 0, 15),
                    Text = "MORE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Name = "MoreBtn"
                })

                executeBtn.MouseEnter:Connect(function()
                    executeBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 100)
                end)
                executeBtn.MouseLeave:Connect(function()
                    executeBtn.BackgroundColor3 = Color3.fromRGB(50, 170, 90)
                end)

                moreBtn.MouseEnter:Connect(function()
                    moreBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
                end)
                moreBtn.MouseLeave:Connect(function()
                    moreBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
                end)

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

                autoExecBtn.MouseButton1Click:Connect(function()
                    toggleAutoExec(script.name)
                end)

                moreBtn.MouseButton1Click:Connect(function()
                    showScriptOptions(script.name, script.content)
                end)
            end
            
            scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, #scripts * 65 + 20)
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
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel, optionsPanelOuter = createStyledContainer(scriptF, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(0, 400, 0, 350),
            Position = UDim2.new(0.5, -200, 0.5, -175),
            Name = "OptionsPanel"
        })

        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })

        createStyledText(titleBar, {
            Text = "Select Your Option",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            Name = "Title"
        })

        local closeBtn, closeBtnOuter = createStyledButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(190, 60, 60),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0, 10),
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Name = "CloseBtn"
        })

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        createStyledText(optionsPanel, {
            Text = "Choose whether to execute,\nopen in a new tab, etc...",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(190, 200, 220),
            Size = UDim2.new(0.8, 0, 0, 40),
            Position = UDim2.new(0.1, 0, 0, 60),
            TextYAlignment = Enum.TextYAlignment.Top,
            Name = "Subtitle"
        })

        local buttons = {
            {text = "EXECUTE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 120)},
            {text = "OPEN SCRIPT IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
            {text = "SAVE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 220)},
            {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 270)}
        }

        for i, btnData in pairs(buttons) do
            local btn, btnOuter = createStyledButton(optionsPanel, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(0.8, 0, 0, 35),
                Position = btnData.pos,
                Text = btnData.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Name = "OptionBtn" .. i
            })

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
            end)

            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = btnData.color
            end)

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
                    if not isfolder("FrostWare/Exports") then makefolder("FrostWare/Exports") end
                    writefile("FrostWare/Exports/" .. name .. ".lua", content)
                    FW.showAlert("Success", "Script saved to file!", 2)
                    scriptF:Destroy()
                    scriptF = nil
                end)
            elseif i == 4 then
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
            end
        end
    end

    local function createCloudCard(parent, data, index)
        local yPos = (index - 1) * 65 + 10
        
        local cloudCard = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 40),
            Size = UDim2.new(1, -20, 0, 55),
            Position = UDim2.new(0, 10, 0, yPos),
            Name = "CloudCard"
        })
        FW.cC(cloudCard, 0.15)

        createStyledText(cloudCard, {
            Text = data.title or "Unknown Script",
            TextSize = 16,
            Size = UDim2.new(0.35, 0, 0.6, 0),
            Position = UDim2.new(0, 15, 0, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "ScriptTitle"
        })

        createVerifiedBadge(cloudCard, UDim2.new(0, 13, 0, 28))

        createStyledText(cloudCard, {
            Text = (data.views or "0") .. " Views",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(160, 170, 190),
            Size = UDim2.new(0.2, 0, 0.6, 0),
            Position = UDim2.new(0.4, 0, 0, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "ViewsLabel"
        })

        local selectBtn, selectOuter = createStyledButton(cloudCard, {
            BackgroundColor3 = Color3.fromRGB(50, 130, 210),
            Size = UDim2.new(0, 100, 0, 35),
            Position = UDim2.new(1, -110, 0, 10),
            Text = "SELECT",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Name = "SelectBtn"
        })

        selectBtn.MouseEnter:Connect(function()
            selectBtn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
        end)
        selectBtn.MouseLeave:Connect(function()
            selectBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        end)

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
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "CloudOptionsOverlay",
            ZIndex = 10
        })

        local optionsPanel, optionsPanelOuter = createStyledContainer(scriptF, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(0, 400, 0, 350),
            Position = UDim2.new(0.5, -200, 0.5, -175),
            Name = "OptionsPanel"
        })

        local titleBar = FW.cF(optionsPanel, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })

        createStyledText(titleBar, {
            Text = "Select Your Option",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            Name = "Title"
        })

        local closeBtn, closeBtnOuter = createStyledButton(titleBar, {
            BackgroundColor3 = Color3.fromRGB(190, 60, 60),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0, 10),
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Name = "CloseBtn"
        })

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        createStyledText(optionsPanel, {
            Text = "Choose whether to execute,\nopen in a new tab, etc...",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(190, 200, 220),
            Size = UDim2.new(0.8, 0, 0, 40),
            Position = UDim2.new(0.1, 0, 0, 60),
            TextYAlignment = Enum.TextYAlignment.Top,
            Name = "Subtitle"
        })

        local buttons = {
            {text = "EXECUTE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 120)},
            {text = "OPEN SCRIPT IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
            {text = "SAVE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 220)},
            {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 270)}
        }

        for i, btnData in pairs(buttons) do
            local btn, btnOuter = createStyledButton(optionsPanel, {
                BackgroundColor3 = btnData.color,
                Size = UDim2.new(0.8, 0, 0, 35),
                Position = btnData.pos,
                Text = btnData.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Name = "CloudOptionBtn" .. i
            })

            btn.MouseEnter:Connect(function()
                btn.BackgroundColor3 = Color3.fromRGB(60, 140, 220)
            end)

            btn.MouseLeave:Connect(function()
                btn.BackgroundColor3 = btnData.color
            end)

            if i == 1 then
                btn.MouseButton1Click:Connect(function()
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
            elseif i == 2 then
                btn.MouseButton1Click:Connect(function()
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
            elseif i == 3 then
                btn.MouseButton1Click:Connect(function()
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
            elseif i == 4 then
                btn.MouseButton1Click:Connect(function()
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
            end
        end
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
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, #scripts * 65 + 20)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(15, 18, 25),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local topBar, topBarOuter = createStyledContainer(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "TopBar"
    })

    local searchBox, searchBoxOuter = createStyledInput(topBar, {
        Size = UDim2.new(0.5, -10, 0, 35),
        Position = UDim2.new(0, 15, 0, 12),
        PlaceholderText = "Search for scripts...",
        TextSize = 14,
        Name = "SearchBox"
    })

    local localTab, localTabOuter = createStyledButton(topBar, {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0.55, 5, 0, 12),
        Text = "LOCAL",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Name = "LocalTab"
    })

    local cloudTab, cloudTabOuter = createStyledButton(topBar, {
        BackgroundColor3 = Color3.fromRGB(65, 75, 90),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0.78, 5, 0, 12),
        Text = "CLOUD",
        TextColor3 = Color3.fromRGB(190, 200, 220),
        TextSize = 14,
        Name = "CloudTab"
    })

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

    local addPanel, addPanelOuter = createStyledContainer(localF, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "AddPanel"
    })

    local nameInput, nameInputOuter = createStyledInput(addPanel, {
        Size = UDim2.new(0.25, -5, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        PlaceholderText = "Script Name",
        TextSize = 12,
        Name = "NameInput"
    })

    local contentInput, contentInputOuter = createStyledInput(addPanel, {
        Size = UDim2.new(0.45, -5, 0, 30),
        Position = UDim2.new(0.27, 5, 0, 10),
        PlaceholderText = "Paste script content here",
        TextSize = 12,
        Name = "ContentInput"
    })

    local saveBtn, saveBtnOuter = createStyledButton(addPanel, {
        BackgroundColor3 = Color3.fromRGB(50, 170, 90),
        Size = UDim2.new(0.12, -5, 0, 30),
        Position = UDim2.new(0.74, 5, 0, 10),
        Text = "SAVE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Name = "SaveBtn"
    })

    local pasteBtn, pasteBtnOuter = createStyledButton(addPanel, {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.12, -5, 0, 30),
        Position = UDim2.new(0.88, 5, 0, 10),
        Text = "PASTE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Name = "PasteBtn"
    })

    local scriptsContainer, scriptsContainerOuter = createStyledContainer(localF, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(1, -20, 1, -110),
        Position = UDim2.new(0, 10, 0, 100),
        Name = "ScriptsContainer"
    })

    local scriptsScroll = FW.cSF(scriptsContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210)
    })
    scriptsScrollRef = scriptsScroll

    local cloudContainer, cloudContainerOuter = createStyledContainer(cloudF, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "CloudContainer"
    })

    local cloudScroll = FW.cSF(cloudContainer, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210)
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

    searchBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and curSec == "Cloud" then
            local query = searchBox.Text
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
            end
        end
    end)

    localTab.MouseButton1Click:Connect(function()
        switchSec("Local")
        localTab.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        localTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTab.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
        cloudTab.TextColor3 = Color3.fromRGB(190, 200, 220)
    end)

    cloudTab.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTab.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        cloudTab.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTab.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
        localTab.TextColor3 = Color3.fromRGB(190, 200, 220)
    end)

    local sidebar = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sidebar then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sidebar, {
                BackgroundColor3 = sel and Color3.fromRGB(30, 36, 51) or Color3.fromRGB(31, 34, 50),
                Size = UDim2.new(0.85, 0, 0.08, 0),
                Position = pos,
                Name = nm,
                BackgroundTransparency = sel and 0 or 1
            })
            FW.cC(btn, 0.15)
            
            local box = FW.cF(btn, {
                ZIndex = sel and 2 or 0,
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                Size = UDim2.new(0.15, 0, 0.6, 0),
                Position = UDim2.new(0.08, 0, 0.2, 0),
                Name = "Box"
            })
            FW.cC(box, 0.2)
            FW.cAR(box, 1)
            
            if sel then
                FW.cG(box, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
            else
                FW.cG(box, Color3.fromRGB(66, 79, 113), Color3.fromRGB(36, 44, 63))
            end
            
            FW.cI(box, {
                ZIndex = sel and 2 or 0,
                ScaleType = Enum.ScaleType.Fit,
                Image = ico,
                Size = UDim2.new(0.6, 0, 0.6, 0),
                BackgroundTransparency = 1,
                Name = "Ico",
                Position = UDim2.new(0.2, 0, 0.2, 0)
            })
            
            local lbl = FW.cT(btn, {
                TextWrapped = true,
                TextSize = 20,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.6, 0, 0.6, 0),
                Text = txt,
                Name = "Lbl",
                Position = UDim2.new(0.3, 0, 0.2, 0)
            })
            FW.cTC(lbl, 20)
            
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
        
        local scriptsBtn, scriptsClk = cSBtn("Scripts", "Scripts", scriptIconAsset or "rbxassetid://7733779610", UDim2.new(0.088, 0, 0.483, 0), false)
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
            displayCloudScripts(popularScripts, cloudScroll)
        end
    end)
end)
