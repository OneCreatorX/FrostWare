spawn(function()
    wait(1)
    local FW = _G.FW
    local HttpService = game:GetService("HttpService")
    local curSec = "Local"
    local localF = nil
    local cloudF = nil
    local curScripts = {}
    local selScript = nil
    local scriptF = nil
    local localScripts = {}
    local scriptsScrollRef = nil
    local scriptsDir = "FrostWare/Scripts/"
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
            local yPos = 15
            for name, content in pairs(localScripts) do
                local scriptContainer = FW.cF(scriptsScrollRef, {
                    BackgroundColor3 = Color3.fromRGB(35, 40, 50),
                    Size = UDim2.new(1, -30, 0, 90),
                    Position = UDim2.new(0, 15, 0, yPos),
                    Name = "ScriptContainer_" .. name
                })
                FW.cC(scriptContainer, 0.25)
                FW.cS(scriptContainer, 3, Color3.fromRGB(20, 25, 35))

                local scriptCard = FW.cF(scriptContainer, {
                    BackgroundColor3 = Color3.fromRGB(45, 52, 65),
                    Size = UDim2.new(1, -6, 1, -6),
                    Position = UDim2.new(0, 3, 0, 3),
                    Name = "ScriptCard"
                })
                FW.cC(scriptCard, 0.2)

                local scriptNameBtn = FW.cB(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(55, 65, 80),
                    Size = UDim2.new(0.6, -10, 0.6, 0),
                    Position = UDim2.new(0, 15, 0.2, 0),
                    Text = name,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 18,
                    TextScaled = true,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
                })
                FW.cC(scriptNameBtn, 0.3)
                FW.cS(scriptNameBtn, 2, Color3.fromRGB(70, 80, 95))
                FW.cTC(scriptNameBtn, 18)

                local viewBtn = FW.cB(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(91, 110, 225),
                    Size = UDim2.new(0.12, 0, 0.5, 0),
                    Position = UDim2.new(0.65, 0, 0.25, 0),
                    Text = "👁️",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 20,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                })
                FW.cC(viewBtn, 0.4)
                FW.cS(viewBtn, 2, Color3.fromRGB(111, 130, 245))
                FW.cTC(viewBtn, 20)

                local deleteBtn = FW.cB(scriptCard, {
                    BackgroundColor3 = Color3.fromRGB(225, 91, 91),
                    Size = UDim2.new(0.12, 0, 0.5, 0),
                    Position = UDim2.new(0.8, 0, 0.25, 0),
                    Text = "❌",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 18,
                    TextScaled = true,
                    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
                })
                FW.cC(deleteBtn, 0.4)
                FW.cS(deleteBtn, 2, Color3.fromRGB(245, 111, 111))
                FW.cTC(deleteBtn, 18)

                local statusIndicator = FW.cF(scriptCard, {
                    BackgroundColor3 = defScripts[name] and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(255, 200, 100),
                    Size = UDim2.new(0.02, 0, 0.8, 0),
                    Position = UDim2.new(0.98, 0, 0.1, 0),
                    Name = "StatusIndicator"
                })
                FW.cC(statusIndicator, 1)

                scriptNameBtn.MouseEnter:Connect(function()
                    scriptNameBtn.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
                end)
                scriptNameBtn.MouseLeave:Connect(function()
                    scriptNameBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
                end)

                viewBtn.MouseEnter:Connect(function()
                    viewBtn.BackgroundColor3 = Color3.fromRGB(101, 120, 235)
                end)
                viewBtn.MouseLeave:Connect(function()
                    viewBtn.BackgroundColor3 = Color3.fromRGB(91, 110, 225)
                end)

                deleteBtn.MouseEnter:Connect(function()
                    deleteBtn.BackgroundColor3 = Color3.fromRGB(235, 101, 101)
                end)
                deleteBtn.MouseLeave:Connect(function()
                    deleteBtn.BackgroundColor3 = Color3.fromRGB(225, 91, 91)
                end)

                scriptNameBtn.MouseButton1Click:Connect(function()
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
                        if isfile(scriptsDir .. name .. ".lua") then
                            delfile(scriptsDir .. name .. ".lua")
                        end
                        local data = {}
                        for n, c in pairs(localScripts) do
                            data[n] = c
                        end
                        writefile(scriptsDir .. "scripts.json", HttpService:JSONEncode(data))
                        updateList()
                        FW.showAlert("Success", "Script deleted!", 2)
                    else
                        FW.showAlert("Info", "Cannot delete default script!", 2)
                    end
                end)

                yPos = yPos + 105
            end
            scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, yPos + 15)
        end
    end

    local function createCloudBtn(parent, data, index)
        local yPos = (index - 1) * 130 + 15
        local cloudContainer = FW.cF(parent, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            Size = UDim2.new(1, -30, 0, 120),
            Position = UDim2.new(0, 15, 0, yPos),
            Name = "CloudContainer"
        })
        FW.cC(cloudContainer, 0.25)
        FW.cS(cloudContainer, 3, Color3.fromRGB(20, 25, 35))

        local cloudCard = FW.cF(cloudContainer, {
            BackgroundColor3 = Color3.fromRGB(45, 52, 65),
            Size = UDim2.new(1, -6, 1, -6),
            Position = UDim2.new(0, 3, 0, 3),
            Name = "CloudCard"
        })
        FW.cC(cloudCard, 0.2)

        local titleLbl = FW.cT(cloudCard, {
            Text = data.title or "Unknown Script",
            TextSize = 20,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.3, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(titleLbl, 20)

        local gameLbl = FW.cT(cloudCard, {
            Text = "🎮 " .. (data.game and data.game.name or "Universal"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(200, 210, 220),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.4, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(gameLbl, 16)

        local statsLbl = FW.cT(cloudCard, {
            Text = "👁️ " .. (data.views or "0") .. " | ⭐ " .. (data.likeCount or "0") .. " | 📅 " .. (data.createdAt and string.sub(data.createdAt, 1, 10) or "Unknown"),
            TextSize = 14,
            TextColor3 = Color3.fromRGB(170, 180, 190),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.25, 0),
            Position = UDim2.new(0.05, 0, 0.7, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(statsLbl, 14)

        local clickBtn = FW.cB(cloudCard, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 5
        })

        clickBtn.MouseEnter:Connect(function()
            cloudCard.BackgroundColor3 = Color3.fromRGB(55, 62, 75)
        end)
        clickBtn.MouseLeave:Connect(function()
            cloudCard.BackgroundColor3 = Color3.fromRGB(45, 52, 65)
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
            BackgroundColor3 = Color3.fromRGB(25, 30, 40),
            Size = UDim2.new(0.75, 0, 0.8, 0),
            Position = UDim2.new(0.125, 0, 0.1, 0),
            Name = "ScriptFrame",
            ZIndex = 10
        })
        FW.cC(scriptF, 0.3)
        FW.cS(scriptF, 5, Color3.fromRGB(91, 110, 225))

        local titleBar = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(35, 42, 55),
            Size = UDim2.new(1, 0, 0.1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        FW.cC(titleBar, 0.3)
        FW.cS(titleBar, 2, Color3.fromRGB(50, 60, 75))

        local title = FW.cT(titleBar, {
            Text = data.title or "Script Options",
            TextSize = 22,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.05, 0, 0, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(title, 22)

        local closeBtn = FW.cB(titleBar, {
            BackgroundColor3 = Color3.fromRGB(225, 91, 91),
            Size = UDim2.new(0.08, 0, 0.6, 0),
            Position = UDim2.new(0.9, 0, 0.2, 0),
            Text = "❌",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cC(closeBtn, 0.4)
        FW.cS(closeBtn, 2, Color3.fromRGB(245, 111, 111))
        FW.cTC(closeBtn, 18)

        closeBtn.MouseButton1Click:Connect(function()
            if scriptF then
                scriptF:Destroy()
                scriptF = nil
            end
        end)

        local contentF = FW.cF(scriptF, {
            BackgroundColor3 = Color3.fromRGB(35, 42, 55),
            Size = UDim2.new(0.95, 0, 0.85, 0),
            Position = UDim2.new(0.025, 0, 0.12, 0),
            Name = "ContentFrame"
        })
        FW.cC(contentF, 0.25)
        FW.cS(contentF, 2, Color3.fromRGB(50, 60, 75))

        local infoPanel = FW.cF(contentF, {
            BackgroundColor3 = Color3.fromRGB(45, 52, 65),
            Size = UDim2.new(0.95, 0, 0.2, 0),
            Position = UDim2.new(0.025, 0, 0.05, 0),
            Name = "InfoPanel"
        })
        FW.cC(infoPanel, 0.2)
        FW.cS(infoPanel, 1, Color3.fromRGB(60, 70, 85))

        local infoLbl = FW.cT(infoPanel, {
            Text = "🎮 Game: " .. (data.game and data.game.name or "Universal") .. "\n👁️ Views: " .. (data.views or "0") .. " | ⭐ Likes: " .. (data.likeCount or "0") .. "\n👤 Author: " .. (data.owner and data.owner.username or "Unknown"),
            TextSize = 16,
            TextColor3 = Color3.fromRGB(220, 230, 240),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.1, 0),
            TextScaled = true,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(infoLbl, 16)

        local buttonPanel = FW.cF(contentF, {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.95, 0, 0.15, 0),
            Position = UDim2.new(0.025, 0, 0.3, 0),
            Name = "ButtonPanel"
        })

        local execBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(100, 200, 100),
            Size = UDim2.new(0.3, -10, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "▶️ Execute",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cC(execBtn, 0.4)
        FW.cS(execBtn, 2, Color3.fromRGB(120, 220, 120))
        FW.cTC(execBtn, 18)

        local copyBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(255, 180, 100),
            Size = UDim2.new(0.3, -10, 1, 0),
            Position = UDim2.new(0.35, 5, 0, 0),
            Text = "📋 Copy",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cC(copyBtn, 0.4)
        FW.cS(copyBtn, 2, Color3.fromRGB(255, 200, 120))
        FW.cTC(copyBtn, 18)

        local saveBtn = FW.cB(buttonPanel, {
            BackgroundColor3 = Color3.fromRGB(91, 110, 225),
            Size = UDim2.new(0.3, -10, 1, 0),
            Position = UDim2.new(0.7, 10, 0, 0),
            Text = "💾 Save",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 18,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cC(saveBtn, 0.4)
        FW.cS(saveBtn, 2, Color3.fromRGB(111, 130, 245))
        FW.cTC(saveBtn, 18)

        local previewPanel = FW.cF(contentF, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 40),
            Size = UDim2.new(0.95, 0, 0.45, 0),
            Position = UDim2.new(0.025, 0, 0.5, 0),
            Name = "PreviewPanel"
        })
        FW.cC(previewPanel, 0.2)
        FW.cS(previewPanel, 2, Color3.fromRGB(40, 50, 65))

        local previewTitle = FW.cT(previewPanel, {
            Text = "📄 Script Preview",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.1, 0),
            Position = UDim2.new(0.05, 0, 0.05, 0),
            TextScaled = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(previewTitle, 18)

        local previewText = FW.cT(previewPanel, {
            Text = data.script and string.sub(data.script, 1, 600) .. "..." or "Loading preview...",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(200, 210, 220),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.9, 0, 0.8, 0),
            Position = UDim2.new(0.05, 0, 0.15, 0),
            TextScaled = false,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(previewText, 12)

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
        local totalHeight = #scripts * 130 + 30
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
    end

    local scriptsPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(20, 25, 35),
        Image = "rbxassetid://76734110237026",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local headerContainer = FW.cF(scriptsPage, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Size = UDim2.new(0.95, 0, 0.12, 0),
        Position = UDim2.new(0.025, 0, 0.02, 0),
        Name = "HeaderContainer"
    })
    FW.cC(headerContainer, 0.25)
    FW.cS(headerContainer, 3, Color3.fromRGB(20, 25, 35))

    local headerPanel = FW.cF(headerContainer, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 65),
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Name = "HeaderPanel"
    })
    FW.cC(headerPanel, 0.2)

    local title = FW.cT(headerPanel, {
        Text = "🚀 Scripts Hub",
        TextSize = 32,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.4, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(title, 32)

    local localTabBtn = FW.cB(headerPanel, {
        BackgroundColor3 = Color3.fromRGB(91, 110, 225),
        Size = UDim2.new(0.22, 0, 0.5, 0),
        Position = UDim2.new(0.5, 0, 0.25, 0),
        Text = "💻 Local Scripts",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(localTabBtn, 0.4)
    FW.cS(localTabBtn, 2, Color3.fromRGB(111, 130, 245))
    FW.cTC(localTabBtn, 16)

    local cloudTabBtn = FW.cB(headerPanel, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 80),
        Size = UDim2.new(0.22, 0, 0.5, 0),
        Position = UDim2.new(0.74, 0, 0.25, 0),
        Text = "☁️ Cloud Scripts",
        TextColor3 = Color3.fromRGB(200, 210, 220),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(cloudTabBtn, 0.4)
    FW.cS(cloudTabBtn, 2, Color3.fromRGB(75, 85, 100))
    FW.cTC(cloudTabBtn, 16)

    localF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.95, 0, 0.83, 0),
        Position = UDim2.new(0.025, 0, 0.15, 0),
        Name = "LocalFrame",
        Visible = true
    })

    cloudF = FW.cF(scriptsPage, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.95, 0, 0.83, 0),
        Position = UDim2.new(0.025, 0, 0.15, 0),
        Name = "CloudFrame",
        Visible = false
    })

    local inputContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "InputContainer"
    })
    FW.cC(inputContainer, 0.25)
    FW.cS(inputContainer, 3, Color3.fromRGB(20, 25, 35))

    local inputPanel = FW.cF(inputContainer, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 65),
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Name = "InputPanel"
    })
    FW.cC(inputPanel, 0.2)

    local nameInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 80),
        Size = UDim2.new(0.45, -10, 0.25, 0),
        Position = UDim2.new(0.025, 0, 0.15, 0),
        Text = "",
        PlaceholderText = "Script Name",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(180, 190, 200),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "NameInput"
    })
    FW.cC(nameInput, 0.3)
    FW.cS(nameInput, 1, Color3.fromRGB(70, 80, 95))
    FW.cTC(nameInput, 16)

    local contentInput = FW.cTB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 80),
        Size = UDim2.new(0.45, -10, 0.25, 0),
        Position = UDim2.new(0.525, 0, 0.15, 0),
        Text = "",
        PlaceholderText = "Paste script content here",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        PlaceholderColor3 = Color3.fromRGB(180, 190, 200),
        TextSize = 14,
        TextScaled = false,
        TextWrapped = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "ContentInput"
    })
    FW.cC(contentInput, 0.3)
    FW.cS(contentInput, 1, Color3.fromRGB(70, 80, 95))
    FW.cTC(contentInput, 14)

    local saveEditorBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(91, 110, 225),
        Size = UDim2.new(0.3, -5, 0.25, 0),
        Position = UDim2.new(0.025, 0, 0.5, 0),
        Text = "💾 Save From Editor",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(saveEditorBtn, 0.4)
    FW.cS(saveEditorBtn, 2, Color3.fromRGB(111, 130, 245))
    FW.cTC(saveEditorBtn, 16)

    local saveBoxBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(91, 110, 225),
        Size = UDim2.new(0.3, -5, 0.25, 0),
        Position = UDim2.new(0.35, 0, 0.5, 0),
        Text = "📝 Save From Box",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(saveBoxBtn, 0.4)
    FW.cS(saveBoxBtn, 2, Color3.fromRGB(111, 130, 245))
    FW.cTC(saveBoxBtn, 16)

    local pasteBtn = FW.cB(inputPanel, {
        BackgroundColor3 = Color3.fromRGB(100, 200, 100),
        Size = UDim2.new(0.3, -5, 0.25, 0),
        Position = UDim2.new(0.675, 0, 0.5, 0),
        Text = "📋 Paste Clipboard",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(pasteBtn, 0.4)
    FW.cS(pasteBtn, 2, Color3.fromRGB(120, 220, 120))
    FW.cTC(pasteBtn, 16)

    local scriptsContainer = FW.cF(localF, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Size = UDim2.new(1, 0, 0.72, 0),
        Position = UDim2.new(0, 0, 0.28, 0),
        Name = "ScriptsContainer"
    })
    FW.cC(scriptsContainer, 0.25)
    FW.cS(scriptsContainer, 3, Color3.fromRGB(20, 25, 35))

    local scriptsPanel = FW.cF(scriptsContainer, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Name = "ScriptsPanel"
    })
    FW.cC(scriptsPanel, 0.2)

    local scriptsScroll = FW.cSF(scriptsPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll"
    })
    scriptsScrollRef = scriptsScroll

    local searchContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Size = UDim2.new(1, 0, 0.12, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "SearchContainer"
    })
    FW.cC(searchContainer, 0.25)
    FW.cS(searchContainer, 3, Color3.fromRGB(20, 25, 35))

    local searchPanel = FW.cF(searchContainer, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 65),
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Name = "SearchPanel"
    })
    FW.cC(searchPanel, 0.2)

    local searchInput = FW.cTB(searchPanel, {
        BackgroundColor3 = Color3.fromRGB(55, 65, 80),
        Size = UDim2.new(0.7, -10, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        PlaceholderText = "🔍 Search for scripts...",
        PlaceholderColor3 = Color3.fromRGB(180, 190, 200),
        Text = "",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cC(searchInput, 0.3)
    FW.cS(searchInput, 1, Color3.fromRGB(70, 80, 95))
    FW.cTC(searchInput, 16)

    local searchBtn = FW.cB(searchPanel, {
        BackgroundColor3 = Color3.fromRGB(91, 110, 225),
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.77, 0, 0.2, 0),
        Text = "🔍 Search",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(searchBtn, 0.4)
    FW.cS(searchBtn, 2, Color3.fromRGB(111, 130, 245))
    FW.cTC(searchBtn, 16)

    local cloudScrollContainer = FW.cF(cloudF, {
        BackgroundColor3 = Color3.fromRGB(35, 40, 50),
        Size = UDim2.new(1, 0, 0.85, 0),
        Position = UDim2.new(0, 0, 0.15, 0),
        Name = "CloudScrollContainer"
    })
    FW.cC(cloudScrollContainer, 0.25)
    FW.cS(cloudScrollContainer, 3, Color3.fromRGB(20, 25, 35))

    local cloudScrollPanel = FW.cF(cloudScrollContainer, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -6, 1, -6),
        Position = UDim2.new(0, 3, 0, 3),
        Name = "CloudScrollPanel"
    })
    FW.cC(cloudScrollPanel, 0.2)

    local cloudScroll = FW.cSF(cloudScrollPanel, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "CloudScroll"
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
        localTabBtn.BackgroundColor3 = Color3.fromRGB(91, 110, 225)
        localTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        cloudTabBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
        cloudTabBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
    end)

    cloudTabBtn.MouseButton1Click:Connect(function()
        switchSec("Cloud")
        cloudTabBtn.BackgroundColor3 = Color3.fromRGB(91, 110, 225)
        cloudTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        localTabBtn.BackgroundColor3 = Color3.fromRGB(55, 65, 80)
        localTabBtn.TextColor3 = Color3.fromRGB(200, 210, 220)
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
                FW.cG(box, Color3.fromRGB(91, 110, 225), Color3.fromRGB(111, 130, 245))
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
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local popularScripts = searchScripts("popular", 30)
        if #popularScripts > 0 then
            curScripts = popularScripts
            displayScripts(popularScripts, cloudScroll)
        end
    end)
end)
