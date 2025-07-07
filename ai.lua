spawn(function()
    wait(1)
    local FW = _G.FW
    local HttpService = game:GetService("HttpService")
    
    local FrostyUltra = {}
    FrostyUltra.__index = FrostyUltra
    local WS_URL = "wss://system.heatherx.site:8443"
    local chatHistory = {}
    local MAX_VISUAL_MESSAGES = 12
    local aiChatPage = nil
    local chatScroll = nil
    local inputBox = nil
    local chatLayout = nil
    local currentThinkingLabel = nil
    local isProcessing = false
    local messageCount = 0
    local connectionStatus = nil
    local statusLabel = nil

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

    function FrostyUltra.new()
        local self = setmetatable({}, FrostyUltra)
        self.ws = nil
        self.currentToken = nil
        self.isAuthenticated = false
        self.isConnecting = false
        self.hwid = gethwid and gethwid()
        self.user = game.Players.LocalPlayer.Name
        self.accessTime = 0
        return self
    end

    function FrostyUltra:connect()
        if self.isConnecting then return false end
        self.isConnecting = true
        
        local connect = syn and syn.websocket and syn.websocket.connect
            or (WebSocket and WebSocket.connect)
            or (WebSocketClient and WebSocketClient.connect)
            or (fluxus and fluxus.websocket)
            or nil
        
        if not connect then
            self.isConnecting = false
            return false
        end
        
        local success, ws = pcall(function()
            return connect(WS_URL)
        end)
        
        if not success then
            self.isConnecting = false
            return false
        end
        
        self.ws = ws
        ws.OnMessage:Connect(function(message)
            spawn(function()
                self:handleMessage(message)
            end)
        end)
        
        ws.OnClose:Connect(function()
            self:reset()
        end)
        
        task.wait(1)
        self:authenticate()
        return true
    end

    function FrostyUltra:authenticate()
        if not self.ws then return end
        
        local authData = {
            type = "auth",
            hwid = self.hwid,
            user = self.user,
            timestamp = os.time()
        }
        
        self.ws:Send(HttpService:JSONEncode(authData))
    end

    function FrostyUltra:handleMessage(message)
        local success, data = pcall(function()
            return HttpService:JSONDecode(message)
        end)
        
        if not success then return end
        
        if data.type == "auth_success" then
            self.currentToken = data.token
            self.isAuthenticated = true
            self.isConnecting = false
            self.accessTime = data.accessTime or 0
        elseif data.type == "auth_failed" then
            self.isAuthenticated = false
            self.isConnecting = false
            self.accessTime = 0
            if data.message:find("access time") then
                FW.showAlert("Premium Required", "Need " .. (data.required or 10) .. "h premium access!", 4)
            end
        elseif data.type == "final_response" then
            self.currentToken = data.newToken
            self:processResponse(data.message)
        elseif data.type == "execute_script" then
            self.currentToken = data.newToken
            self:processScript(data.script, data.taskId, data.message)
        elseif data.type == "image_response" then
            self.currentToken = data.newToken
            self:processImage(data.imageUrl, data.message)
        elseif data.type == "error" then
            if data.newToken then
                self.currentToken = data.newToken
            end
            self:processError(data.message)
        end
    end

    function FrostyUltra:processResponse(message)
        if currentThinkingLabel and currentThinkingLabel.Parent then
            table.insert(chatHistory, { role = "model", message = message })
            self:typewriterEffect(currentThinkingLabel, message, 0.02)
            currentThinkingLabel = nil
        end
    end

    function FrostyUltra:processImage(imageUrl, message)
        if currentThinkingLabel and currentThinkingLabel.Parent then
            self:typewriterEffect(currentThinkingLabel, message, 0.02)
            
            spawn(function()
                task.wait(1)
                
                if imageUrl:find("data:image") then
                    local filename = "generated_" .. os.time() .. ".png"
                    local assetUrl = getOrDownloadImageAsset(imageUrl, filename)
                    
                    if assetUrl then
                        self:addImageToChat(assetUrl, message)
                    else
                        if currentThinkingLabel and currentThinkingLabel.Parent then
                            currentThinkingLabel.Text = "Error downloading image"
                        end
                    end
                else
                    self:addImageToChat(imageUrl, message)
                end
                
                currentThinkingLabel = nil
            end)
        end
    end

    function FrostyUltra:addImageToChat(imageUrl, message)
        messageCount = messageCount + 1
        
        local msgFrame = FW.cF(chatScroll, {
            BackgroundColor3 = Color3.fromRGB(35, 42, 58),
            Size = UDim2.new(0.92, 0, 0, 0),
            Position = UDim2.new(0.04, 0, 0, 0),
            Name = "Message",
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = messageCount,
            ClipsDescendants = true
        })
        FW.cC(msgFrame, 0.4)
        FW.cS(msgFrame, 2, Color3.fromRGB(55, 65, 85))
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 15)
        padding.PaddingBottom = UDim.new(0, 15)
        padding.PaddingLeft = UDim.new(0, 18)
        padding.PaddingRight = UDim.new(0, 18)
        padding.Parent = msgFrame
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = msgFrame
        
        local senderLabel = FW.cT(msgFrame, {
            Text = "Frosty Ultra",
            TextSize = 15,
            TextColor3 = Color3.fromRGB(100, 255, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            LayoutOrder = 1,
            ClipsDescendants = true
        })
        FW.cTC(senderLabel, 15)
        
        local imageLabel = FW.cI(msgFrame, {
            Image = imageUrl,
            Size = UDim2.new(0.8, 0, 0, 200),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundColor3 = Color3.fromRGB(45, 52, 68),
            ScaleType = Enum.ScaleType.Fit,
            LayoutOrder = 2,
            ClipsDescendants = true
        })
        FW.cC(imageLabel, 0.3)
        FW.cS(imageLabel, 2, Color3.fromRGB(75, 85, 105))
        
        local msgLabel = FW.cT(msgFrame, {
            Text = message,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240, 245, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            LayoutOrder = 3,
            ClipsDescendants = true
        })
        FW.cTC(msgLabel, 14)
        
        self:updateScroll()
        self:cleanOldMessages()
    end

    function FrostyUltra:processScript(script, taskId, statusMessage)
        if currentThinkingLabel and currentThinkingLabel.Parent then
            self:typewriterEffect(currentThinkingLabel, statusMessage, 0.02)
            
            spawn(function()
                task.wait(0.5)
                local success, result = self:executeScript(script, taskId)
                
                if not success then
                    if currentThinkingLabel and currentThinkingLabel.Parent then
                        currentThinkingLabel.Text = "Error executing script"
                        currentThinkingLabel = nil
                    end
                end
            end)
        end
    end

    function FrostyUltra:processError(error)
        if currentThinkingLabel and currentThinkingLabel.Parent then
            currentThinkingLabel.Text = "Error: " .. error
            currentThinkingLabel = nil
        end
    end

    function FrostyUltra:executeScript(script, taskId)
        local infoScript = script:match("INFO_SCRIPT_START(.-)INFO_SCRIPT_END")
        local actionScript = script:match("ACTION_SCRIPT_START(.-)ACTION_SCRIPT_END")
        
        if infoScript then
            local success, result = pcall(function()
                local func = loadstring("local HttpService = game:GetService('HttpService')\n" .. infoScript)
                if func then
                    return func()
                end
            end)
            
            if success and result then
                if taskId then
                    self:sendScriptResult(taskId, result, true)
                end
                return true, result
            else
                if taskId then
                    self:sendScriptResult(taskId, nil, false)
                end
                return false, result
            end
        elseif actionScript then
            local success, error = pcall(function()
                loadstring(actionScript)()
            end)
            
            if success then
                if currentThinkingLabel and currentThinkingLabel.Parent then
                    currentThinkingLabel.Text = "Action completed! ✓"
                    task.wait(2)
                    currentThinkingLabel = nil
                end
                FW.showAlert("Success", "Action executed!", 2)
                return true, nil
            else
                if currentThinkingLabel and currentThinkingLabel.Parent then
                    currentThinkingLabel.Text = "Action failed: " .. tostring(error)
                    currentThinkingLabel = nil
                end
                FW.showAlert("Error", "Execution failed!", 3)
                return false, error
            end
        end
        
        return false, "Unknown script type"
    end

    function FrostyUltra:sendScriptResult(taskId, result, success)
        if not self.ws or not self.isAuthenticated then return end
        
        local resultData = {
            type = "script_result",
            taskId = taskId,
            result = result,
            success = success,
            hwid = self.hwid
        }
        
        self.ws:Send(HttpService:JSONEncode(resultData))
    end

    function FrostyUltra:sendMessage(message)
        if not self.ws or not self.isAuthenticated or not self.currentToken then
            return false
        end
        
        if not message or #message == 0 or #message > 2000 then
            return false
        end
        
        local chatData = {
            type = "chat",
            message = message,
            token = self.currentToken,
            hwid = self.hwid
        }
        
        self.ws:Send(HttpService:JSONEncode(chatData))
        
        table.insert(chatHistory, { role = "user", message = message })
        
        if #chatHistory > 20 then
            table.remove(chatHistory, 1)
            table.remove(chatHistory, 1)
        end
        
        return true
    end

    function FrostyUltra:ping()
        if not self.ws then return end
        self.ws:Send(HttpService:JSONEncode({ type = "ping" }))
    end

    function FrostyUltra:reset()
        self.ws = nil
        self.currentToken = nil
        self.isAuthenticated = false
        self.isConnecting = false
        self.accessTime = 0
    end

    function FrostyUltra:close()
        if self.ws then
            self.ws:Close()
        end
        self:reset()
    end

    function FrostyUltra:typewriterEffect(textLabel, fullText, speed)
        if not textLabel or not textLabel.Parent then return end
        
        speed = speed or 0.02
        textLabel.Text = ""
        
        spawn(function()
            for i = 1, #fullText do
                if textLabel and textLabel.Parent then
                    textLabel.Text = string.sub(fullText, 1, i)
                    task.wait(speed)
                else
                    break
                end
            end
        end)
    end

    function FrostyUltra:cleanOldMessages()
        if not chatScroll then return end
        
        local messages = {}
        for _, child in pairs(chatScroll:GetChildren()) do
            if child.Name == "Message" then
                table.insert(messages, child)
            end
        end
        
        if #messages > MAX_VISUAL_MESSAGES then
            table.sort(messages, function(a, b)
                return a.LayoutOrder < b.LayoutOrder
            end)
            
            for i = 1, #messages - MAX_VISUAL_MESSAGES do
                if messages[i] and messages[i].Parent then
                    messages[i]:Destroy()
                end
            end
        end
    end

    function FrostyUltra:updateScroll()
        spawn(function()
            task.wait(0.1)
            if chatLayout and chatLayout.Parent then
                local contentSize = chatLayout.AbsoluteContentSize.Y + 30
                chatScroll.CanvasSize = UDim2.new(0, 0, 0, contentSize)
                
                if contentSize > chatScroll.AbsoluteSize.Y then
                    chatScroll.CanvasPosition = Vector2.new(0, contentSize - chatScroll.AbsoluteSize.Y)
                end
            end
        end)
    end

    local chat = FrostyUltra.new()

    local function addMessageUI(sender, message, isUser)
        messageCount = messageCount + 1
        
        local msgFrame = FW.cF(chatScroll, {
            BackgroundColor3 = isUser and Color3.fromRGB(45, 52, 68) or Color3.fromRGB(35, 42, 58),
            Size = UDim2.new(0.92, 0, 0, 0),
            Position = UDim2.new(0.04, 0, 0, 0),
            Name = "Message",
            AutomaticSize = Enum.AutomaticSize.Y,
            LayoutOrder = messageCount,
            ClipsDescendants = true
        })
        FW.cC(msgFrame, 0.4)
        FW.cS(msgFrame, 2, isUser and Color3.fromRGB(65, 75, 95) or Color3.fromRGB(55, 65, 85))
        
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 15)
        padding.PaddingBottom = UDim.new(0, 15)
        padding.PaddingLeft = UDim.new(0, 18)
        padding.PaddingRight = UDim.new(0, 18)
        padding.Parent = msgFrame
        
        local layout = Instance.new("UIListLayout")
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Padding = UDim.new(0, 8)
        layout.Parent = msgFrame
        
        local senderLabel = FW.cT(msgFrame, {
            Text = sender,
            TextSize = 15,
            TextColor3 = isUser and Color3.fromRGB(120, 150, 255) or Color3.fromRGB(100, 255, 200),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
            LayoutOrder = 1,
            ClipsDescendants = true
        })
        FW.cTC(senderLabel, 15)
        
        local msgLabel = FW.cT(msgFrame, {
            Text = message,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(240, 245, 255),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            LayoutOrder = 2,
            ClipsDescendants = true
        })
        FW.cTC(msgLabel, 14)
        
        chat:updateScroll()
        chat:cleanOldMessages()
        return msgFrame, msgLabel
    end

    local function updateConnectionStatus()
        if not connectionStatus or not statusLabel then return end
        
        if chat.isAuthenticated then
            connectionStatus.Text = "🟢 Ultra-Efficient Active"
            connectionStatus.TextColor3 = Color3.fromRGB(100, 255, 200)
            statusLabel.Text = "Frosty Ultra AI Ready!"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 200)
        elseif chat.isConnecting then
            connectionStatus.Text = "🟡 Connecting..."
            connectionStatus.TextColor3 = Color3.fromRGB(255, 220, 120)
            statusLabel.Text = "Connecting to Ultra AI..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 220, 120)
        else
            connectionStatus.Text = "🔴 Premium Required"
            connectionStatus.TextColor3 = Color3.fromRGB(255, 120, 120)
            statusLabel.Text = "Premium access required"
            statusLabel.TextColor3 = Color3.fromRGB(255, 120, 120)
        end
    end

    aiChatPage = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(10, 15, 25),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "AIChatPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })

    local headerContainer = FW.cF(aiChatPage, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 68),
        Size = UDim2.new(0.92, 0, 0.11, 0),
        Position = UDim2.new(0.04, 0, 0.02, 0),
        Name = "HeaderContainer",
        ClipsDescendants = true
    })
    FW.cC(headerContainer, 0.4)
    FW.cS(headerContainer, 3, Color3.fromRGB(100, 255, 200))

    local headerPanel = FW.cF(headerContainer, {
        BackgroundColor3 = Color3.fromRGB(55, 63, 78),
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Name = "HeaderPanel",
        ClipsDescendants = true
    })
    FW.cC(headerPanel, 0.35)

    local title = FW.cT(headerPanel, {
        Text = "Frosty Ultra-Efficient AI",
        TextSize = 24,
        TextColor3 = Color3.fromRGB(100, 255, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0.7, 0),
        Position = UDim2.new(0.05, 0, 0.15, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(title, 24)

    statusLabel = FW.cT(headerPanel, {
        Text = "Connecting to Ultra AI...",
        TextSize = 13,
        TextColor3 = Color3.fromRGB(255, 220, 120),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.35, 0, 0.5, 0),
        Position = UDim2.new(0.62, 0, 0.25, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Right,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(statusLabel, 13)

    local chatContainer = FW.cF(aiChatPage, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 68),
        Size = UDim2.new(0.92, 0, 0.71, 0),
        Position = UDim2.new(0.04, 0, 0.15, 0),
        Name = "ChatContainer",
        ClipsDescendants = true
    })
    FW.cC(chatContainer, 0.4)
    FW.cS(chatContainer, 3, Color3.fromRGB(65, 75, 95))

    local chatFrame = FW.cF(chatContainer, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Name = "ChatFrame",
        ClipsDescendants = true
    })
    FW.cC(chatFrame, 0.35)

    chatScroll = FW.cSF(chatFrame, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 6,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Name = "ChatScroll"
    })

    chatLayout = Instance.new("UIListLayout")
    chatLayout.Parent = chatScroll
    chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    chatLayout.Padding = UDim.new(0, 12)

    local inputContainer = FW.cF(aiChatPage, {
        BackgroundColor3 = Color3.fromRGB(45, 52, 68),
        Size = UDim2.new(0.92, 0, 0.14, 0),
        Position = UDim2.new(0.04, 0, 0.88, 0),
        Name = "InputContainer",
        ClipsDescendants = true
    })
    FW.cC(inputContainer, 0.4)
    FW.cS(inputContainer, 3, Color3.fromRGB(65, 75, 95))

    local inputFrame = FW.cF(inputContainer, {
        BackgroundColor3 = Color3.fromRGB(35, 42, 58),
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Name = "InputFrame",
        ClipsDescendants = true
    })
    FW.cC(inputFrame, 0.35)

    inputBox = FW.cTB(inputFrame, {
        BackgroundColor3 = Color3.fromRGB(55, 63, 78),
        Size = UDim2.new(0.7, -10, 0.5, 0),
        Position = UDim2.new(0.04, 0, 0.15, 0),
        Text = "",
        PlaceholderText = "Ask Frosty Ultra anything...",
        TextColor3 = Color3.fromRGB(240, 245, 255),
        PlaceholderColor3 = Color3.fromRGB(180, 190, 210),
        TextSize = 15,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        Name = "InputBox",
        ClipsDescendants = true
    })
    FW.cC(inputBox, 0.3)
    FW.cS(inputBox, 2, Color3.fromRGB(75, 85, 105))
    FW.cTC(inputBox, 15)

    local sendBtn = FW.cB(inputFrame, {
        BackgroundColor3 = Color3.fromRGB(100, 255, 200),
        Size = UDim2.new(0.2, 0, 0.5, 0),
        Position = UDim2.new(0.76, 0, 0.15, 0),
        Text = "Send",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 15,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cC(sendBtn, 0.35)
    FW.cS(sendBtn, 2, Color3.fromRGB(120, 255, 220))
    FW.cTC(sendBtn, 15)

    connectionStatus = FW.cT(inputFrame, {
        Text = "🔴 Premium Required",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(255, 120, 120),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.3, 0),
        Position = UDim2.new(0.05, 0, 0.7, 0),
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
        ClipsDescendants = true
    })
    FW.cTC(connectionStatus, 12)

    sendBtn.MouseButton1Click:Connect(function()
        if isProcessing or not chat.isAuthenticated then 
            if not chat.isAuthenticated then
                FW.showAlert("Premium Required", "Premium access needed for Ultra AI!", 3)
            end
            return 
        end
        
        local message = inputBox.Text:gsub("^%s*(.-)%s*$", "%1")
        if message == "" or #message > 2000 then return end
        
        addMessageUI("You", message, true)
        inputBox.Text = ""
        
        local _, msgLabel = addMessageUI("Frosty Ultra", "Processing...", false)
        currentThinkingLabel = msgLabel
        
        spawn(function()
            local success = chat:sendMessage(message)
            if not success then
                if currentThinkingLabel and currentThinkingLabel.Parent then
                    currentThinkingLabel.Text = "Connection failed. Please try again."
                    currentThinkingLabel = nil
                end
            end
        end)
    end)

    inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed and not isProcessing and chat.isAuthenticated then
            sendBtn.MouseButton1Click:Fire()
        end
    end)

    spawn(function()
        while task.wait(2) do
            updateConnectionStatus()
        end
    end)

    local welcomeMessage = "Welcome to Frosty Ultra-Efficient AI, " .. game.Players.LocalPlayer.Name .. "! I use ultra-fast keyword coordination with multiple Gemini models: Flash-Lite for speed, Pro for complex tasks, and Image Generation for visuals. I can execute scripts, get game info, generate images, and respond intelligently!"
    addMessageUI("Frosty Ultra", welcomeMessage, false)

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
                FW.cG(box, Color3.fromRGB(100, 255, 200), Color3.fromRGB(80, 235, 180))
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
        local aiBtn, aiClk = cSBtn("UltraAI", "Ultra AI", "rbxassetid://6034229496", UDim2.new(0.088, 0, 0.582, 0), false)
        aiClk.MouseButton1Click:Connect(function()
            FW.switchPage("AIChat", sidebar)
        end)
    end

    if chat:connect() then
        spawn(function()
            while chat.ws do
                task.wait(30)
                chat:ping()
            end
        end)
    end
end)
