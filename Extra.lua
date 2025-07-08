if not getgenv()._FW then
    local ok, fw = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()
    end)
    if ok and fw then
        getgenv()._FW = fw
    end
end

while not getgenv()._FW_ACCESS_GRANTED do
    wait(0.5)
end

local FW = getgenv()._FW or {}
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local UserSettings = game:GetService("UserSettings")

local playerCountLabel = nil
local pingLabel = nil
local fpsLabel = nil
local memoryLabel = nil
local timeLabel = nil
local startTime = tick()
local fpsCounter = 0
local lastFpsUpdate = tick()

local function updateStats()
    spawn(function()
        RunService.Heartbeat:Connect(function()
            fpsCounter = fpsCounter + 1
        end)
        
        while task.wait(1) do
            if playerCountLabel and playerCountLabel.Parent then
                local currentPlayers = #game.Players:GetPlayers()
                local maxPlayers = game.Players.MaxPlayers
                playerCountLabel.Text = "👥 " .. currentPlayers .. "/" .. maxPlayers
            end
            
            if pingLabel and pingLabel.Parent then
                local ping = game.Players.LocalPlayer:GetNetworkPing() * 1000
                pingLabel.Text = "📡 " .. math.floor(ping) .. "ms"
            end
            
            if fpsLabel and fpsLabel.Parent then
                local currentTime = tick()
                local fps = math.floor(fpsCounter / (currentTime - lastFpsUpdate))
                fpsLabel.Text = "🎯 " .. fps .. " FPS"
                fpsCounter = 0
                lastFpsUpdate = currentTime
            end
            
            if memoryLabel and memoryLabel.Parent then
                local memory = Stats:GetTotalMemoryUsageMb()
                memoryLabel.Text = "💾 " .. math.floor(memory) .. "MB"
            end
            
            if timeLabel and timeLabel.Parent then
                local elapsed = tick() - startTime
                local minutes = math.floor(elapsed / 60)
                local seconds = math.floor(elapsed % 60)
                timeLabel.Text = "⏱️ " .. minutes .. ":" .. string.format("%02d", seconds)
            end
        end
    end)
end

local function hideUI()
    local ui = FW.getUI()
    if ui and ui["3"] then
        ui["3"].Visible = false
        ui["2"].Visible = false
        
        spawn(function()
            wait(5)
            ui["3"].Visible = true
            ui["2"].Visible = true
            FW.showAlert("Success", "UI restored!", 2)
        end)
    end
end

local function extremeAntiLag()
    local userSettings = typeof(UserSettings) == "function" and UserSettings()
    local settings = userSettings and userSettings:GetService("UserGameSettings")
    local lighting = game:GetService("Lighting")
    local workspace = game:GetService("Workspace")
    
    pcall(function()
        settings.MasterVolume = 0
        settings.GraphicsQualityLevel = 1
        settings.SavedQualityLevel = 1
    end)
    
    pcall(function()
        lighting.GlobalShadows = false
        lighting.FogEnd = 9e9
        lighting.Brightness = 0
        lighting.ColorShift_Bottom = Color3.fromRGB(11, 11, 11)
        lighting.ColorShift_Top = Color3.fromRGB(240, 240, 240)
        lighting.OutdoorAmbient = Color3.fromRGB(34, 34, 34)
        lighting.Ambient = Color3.fromRGB(34, 34, 34)
    end)
    
    pcall(function()
        workspace.Terrain.WaterWaveSize = 0
        workspace.Terrain.WaterWaveSpeed = 0
        workspace.Terrain.WaterReflectance = 0
        workspace.Terrain.WaterTransparency = 0
    end)
    
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                obj.Material = Enum.Material.Plastic
                obj.Reflectance = 0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled = false
            elseif obj:IsA("Explosion") then
                obj.BlastPressure = 1
                obj.BlastRadius = 1
            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled = false
            end
        end)
    end
    
    for _, effect in pairs(lighting:GetChildren()) do
        pcall(function()
            if effect:IsA("BloomEffect") or effect:IsA("BlurEffect") or 
               effect:IsA("ColorCorrectionEffect") or effect:IsA("SunRaysEffect") then
                effect.Enabled = false
            end
        end)
    end
    
    FW.showAlert("Success", "Extreme anti-lag applied!", 2)
end

local function createEmojiButton(parent, emoji, text, pos, size, callback)
    local btn = FW.cF(parent, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = size,
        Position = pos,
        Name = text:gsub(" ", "")
    })
    FW.cC(btn, 0.2)
    FW.cG(btn, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
    
    local emojiLabel = FW.cT(btn, {
        Text = emoji,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = true,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    
    local textLabel = FW.cT(btn, {
        Text = text,
        TextSize = 16,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.6, 0, 0.6, 0),
        Position = UDim2.new(0.35, 0, 0.2, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(textLabel, 16)
    
    local clickBtn = FW.cB(btn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    clickBtn.MouseButton1Click:Connect(callback)
    
    return btn
end

local function createStatLabel(parent, text, pos, size)
    local frame = FW.cF(parent, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = size,
        Position = pos,
        Name = text:gsub(" ", "")
    })
    FW.cC(frame, 0.15)
    FW.cS(frame, 1, Color3.fromRGB(35, 39, 54))
    
    local label = FW.cT(frame, {
        Text = text,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(label, 14)
    
    return label
end

local function serverHop()
    local success, servers = pcall(function()
        return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if success and servers.data then
        for _, server in pairs(servers.data) do
            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, server.id)
                break
            end
        end
    else
        FW.showAlert("Error", "Failed to get servers!", 2)
    end
end

local function clearWorkspace()
    local count = 0
    for _, obj in pairs(workspace:GetChildren()) do
        if not obj:IsA("Terrain") and not obj:IsA("Camera") and obj ~= workspace.CurrentCamera and not game.Players:GetPlayerFromCharacter(obj) then
            pcall(function()
                 obj:Destroy()
                 count = count + 1
            end)
        end
    end
    FW.showAlert("Success", "Cleared " .. count .. " objects!", 2)
end

local function toggleSound()
    local userSettings = typeof(UserSettings) == "function" and UserSettings()
    local settings = userSettings and userSettings:GetService("UserGameSettings")
    if settings.MasterVolume > 0 then
        settings.MasterVolume = 0
        FW.showAlert("Info", "Sound disabled!", 2)
    else
        settings.MasterVolume = 1
        FW.showAlert("Info", "Sound enabled!", 2)
    end
end

local function updateExtraPage()
    local extraPage = FW.getUI()["11"]:FindFirstChild("ExtraPage")
    if not extraPage then return end
    
    for _, child in pairs(extraPage:GetChildren()) do
        if child.Name ~= "TextLabel" then
            child:Destroy()
        end
    end
    
    local title = extraPage:FindFirstChild("TextLabel")
    if title then 
        title.Text = "🛠️ System Tools"
        title.Size = UDim2.new(1, 0, 0.08, 0)
        title.Position = UDim2.new(0, 0, 0.02, 0)
    end
    
    local mainFrame = FW.cF(extraPage, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 32),
        Size = UDim2.new(0.95, 0, 0.88, 0),
        Position = UDim2.new(0.025, 0, 0.1, 0),
        Name = "MainFrame"
    })
    FW.cC(mainFrame, 0.02)
    FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
    
    local statsFrame = FW.cF(mainFrame, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.96, 0, 0.18, 0),
        Position = UDim2.new(0.02, 0, 0.02, 0),
        Name = "StatsFrame"
    })
    FW.cC(statsFrame, 0.02)
    FW.cS(statsFrame, 1, Color3.fromRGB(35, 39, 54))
    
    local statsTitle = FW.cT(statsFrame, {
        Text = "📊 Live Stats",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.25, 0),
        Position = UDim2.new(0.02, 0, 0.05, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(statsTitle, 18)
    
    playerCountLabel = createStatLabel(statsFrame, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    pingLabel = createStatLabel(statsFrame, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    fpsLabel = createStatLabel(statsFrame, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    memoryLabel = createStatLabel(statsFrame, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
    timeLabel = createStatLabel(statsFrame, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
    
    createEmojiButton(mainFrame, "💀", "Reset Character", UDim2.new(0.02, 0, 0.25, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
            FW.showAlert("Success", "Character reset!", 2)
        end
    end)
    
    createEmojiButton(mainFrame, "🔄", "Rejoin Server", UDim2.new(0.345, 0, 0.25, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
    end)
    
    createEmojiButton(mainFrame, "🌐", "Server Hop", UDim2.new(0.67, 0, 0.25, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        serverHop()
    end)
    
    createEmojiButton(mainFrame, "📋", "Copy User ID", UDim2.new(0.02, 0, 0.37, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        if getgenv().setclipboard then
            getgenv().setclipboard(tostring(game.Players.LocalPlayer.UserId))
            FW.showAlert("Success", "User ID copied!", 2)
        else
            FW.showAlert("Error", "Clipboard not supported!", 2)
        end
    end)
    
    createEmojiButton(mainFrame, "👁️", "Hide UI (5s)", UDim2.new(0.345, 0, 0.37, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        hideUI()
        FW.showAlert("Info", "UI hidden for 5 seconds!", 1)
    end)
    
    createEmojiButton(mainFrame, "⚡", "Extreme Anti-Lag", UDim2.new(0.67, 0, 0.37, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        extremeAntiLag()
    end)
    
    createEmojiButton(mainFrame, "🧹", "Clear Workspace", UDim2.new(0.02, 0, 0.49, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        clearWorkspace()
    end)
    
    createEmojiButton(mainFrame, "🎵", "Toggle Sound", UDim2.new(0.345, 0, 0.49, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        toggleSound()
    end)
    
    createEmojiButton(mainFrame, "🔄", "Refresh UI", UDim2.new(0.67, 0, 0.49, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        FW.hide()
        wait(0.5)
        FW.show()
        FW.showAlert("Success", "UI refreshed!", 2)
    end)
    
    createEmojiButton(mainFrame, "📊", "Game Info", UDim2.new(0.02, 0, 0.61, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        local info = "Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name .. "\nPlace ID: " .. game.PlaceId .. "\nJob ID: " .. game.JobId
        if getgenv().setclipboard then
            getgenv().setclipboard(info)
            FW.showAlert("Success", "Game info copied!", 2)
        else
            FW.showAlert("Info", info, 4)
        end
    end)
    
    createEmojiButton(mainFrame, "🔧", "Developer Console", UDim2.new(0.345, 0, 0.61, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        game:GetService("StarterGui"):SetCore("DevConsoleVisible", true)
        FW.showAlert("Info", "Developer console opened!", 2)
    end)
    
    createEmojiButton(mainFrame, "💾", "Save Place", UDim2.new(0.67, 0, 0.61, 0), UDim2.new(0.31, 0, 0.1, 0), function()
        if saveinstance then
            saveinstance()
            FW.showAlert("Success", "Place saved!", 2)
        else
            FW.showAlert("Error", "Save instance not supported!", 2)
        end
    end)
    
    local infoFrame = FW.cF(mainFrame, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.96, 0, 0.2, 0),
        Position = UDim2.new(0.02, 0, 0.75, 0),
        Name = "InfoFrame"
    })
    FW.cC(infoFrame, 0.02)
    FW.cS(infoFrame, 1, Color3.fromRGB(35, 39, 54))
    
    local infoTitle = FW.cT(infoFrame, {
        Text = "ℹ️ System Information",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.25, 0),
        Position = UDim2.new(0.02, 0, 0.05, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(infoTitle, 16)
    
    local executorInfo = FW.cT(infoFrame, {
        Text = "Executor: " .. (identifyexecutor and identifyexecutor() or "Unknown"),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.46, 0, 0.3, 0),
        Position = UDim2.new(0.02, 0, 0.35, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    })
    FW.cTC(executorInfo, 12)
    
    local hwid = getgenv()._e and getgenv()._e.gethwid and getgenv()._e.gethwid() or "Unknown"
    local hwidInfo = FW.cT(infoFrame, {
        Text = "HWID: " .. hwid:sub(1, 8) .. "...",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.46, 0, 0.3, 0),
        Position = UDim2.new(0.52, 0, 0.35, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal)
    })
    FW.cTC(hwidInfo, 12)
    
    local versionInfo = FW.cT(infoFrame, {
        Text = "FrostWare V2.1 - Extra Module Loaded",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(166, 190, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.96, 0, 0.3, 0),
        Position = UDim2.new(0.02, 0, 0.65, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Center,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(versionInfo, 12)
    
    updateStats()
end

spawn(function()
    wait(2)
    updateExtraPage()
    
    local modules = {
        "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts.lua"
    }
    
    for i, moduleUrl in pairs(modules) do
        spawn(function()
            local success, moduleCode = pcall(function()
                return game:HttpGet(moduleUrl)
            end)
            
            if success then
                FW.addLog("Module " .. i .. " downloaded successfully", "info")
                
                local success2, error = pcall(function()
                    loadstring(moduleCode)()
                end)
                
                if success2 then
                    FW.addLog("Module " .. i .. " executed successfully", "info")
                else
                    FW.addLog("Error executing module " .. i .. ": " .. tostring(error), "error")
                end
            else
                FW.addLog("Error downloading module " .. i .. ": " .. tostring(moduleCode), "error")
            end
        end)
        
        wait(1)
    end
end)

return true
