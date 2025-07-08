_G.FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

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
    local ui = _G.FW.getUI()
    if ui and ui["3"] then
        ui["3"].Visible = false
        ui["2"].Visible = false
        
        spawn(function()
            wait(5)
            ui["3"].Visible = true
            ui["2"].Visible = true
            _G.FW.showAlert("Success", "UI restored!", 2)
        end)
    end
end

local function extremeAntiLag()
    local settings = UserSettings():GetService("UserGameSettings")
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
    
    _G.FW.showAlert("Success", "Extreme anti-lag applied!", 2)
end

local function createEmojiButton(parent, emoji, text, pos, size, callback)
    local btn = _G.FW.cF(parent, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = size,
        Position = pos,
        Name = text:gsub(" ", "")
    })
    _G.FW.cC(btn, 0.2)
    _G.FW.cG(btn, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
    
    local emojiLabel = _G.FW.cT(btn, {
        Text = emoji,
        TextSize = 24,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.3, 0, 0.6, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = true,
        FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    
    local textLabel = _G.FW.cT(btn, {
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
    _G.FW.cTC(textLabel, 16)
    
    local clickBtn = _G.FW.cB(btn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    clickBtn.MouseButton1Click:Connect(callback)
    
    return btn
end

local function createStatLabel(parent, text, pos, size)
    local frame = _G.FW.cF(parent, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = size,
        Position = pos,
        Name = text:gsub(" ", "")
    })
    _G.FW.cC(frame, 0.15)
    _G.FW.cS(frame, 1, Color3.fromRGB(35, 39, 54))
    
    local label = _G.FW.cT(frame, {
        Text = text,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    _G.FW.cTC(label, 14)
    
    return label
end

spawn(function()
    wait(2)
    
    local function updateExtraPage()
        local extraPage = _G.FW.getUI()["11"]:FindFirstChild("ExtraPage")
        if extraPage then
            local title = extraPage:FindFirstChild("TextLabel")
            if title then title.Text = "🛠️ System Tools" end
            
            local mainFrame = _G.FW.cF(extraPage, {
                BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                Size = UDim2.new(0.95, 0, 0.9, 0),
                Position = UDim2.new(0.025, 0, 0.08, 0),
                Name = "MainFrame"
            })
            _G.FW.cC(mainFrame, 0.02)
            _G.FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
            
            local statsFrame = _G.FW.cF(mainFrame, {
                BackgroundColor3 = Color3.fromRGB(16, 19, 27),
                Size = UDim2.new(0.9, 0, 0.15, 0),
                Position = UDim2.new(0.05, 0, 0.02, 0),
                Name = "StatsFrame"
            })
            _G.FW.cC(statsFrame, 0.02)
            _G.FW.cS(statsFrame, 1, Color3.fromRGB(35, 39, 54))
            
            local statsTitle = _G.FW.cT(statsFrame, {
                Text = "📊 Live Stats",
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0.25, 0),
                Position = UDim2.new(0.05, 0, 0.05, 0),
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            _G.FW.cTC(statsTitle, 16)
            
            playerCountLabel = createStatLabel(statsFrame, "👥 0/0", UDim2.new(0.02, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
            pingLabel = createStatLabel(statsFrame, "📡 0ms", UDim2.new(0.22, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
            fpsLabel = createStatLabel(statsFrame, "🎯 0 FPS", UDim2.new(0.42, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
            memoryLabel = createStatLabel(statsFrame, "💾 0MB", UDim2.new(0.62, 0, 0.35, 0), UDim2.new(0.18, 0, 0.6, 0))
            timeLabel = createStatLabel(statsFrame, "⏱️ 0:00", UDim2.new(0.82, 0, 0.35, 0), UDim2.new(0.16, 0, 0.6, 0))
            
            createEmojiButton(mainFrame, "💀", "Reset Character", UDim2.new(0.05, 0, 0.2, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                    _G.FW.showAlert("Success", "Character reset!", 2)
                end
            end)
            
            createEmojiButton(mainFrame, "🔄", "Rejoin Server", UDim2.new(0.36, 0, 0.2, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
            
            createEmojiButton(mainFrame, "🌐", "Server Hop", UDim2.new(0.67, 0, 0.2, 0), UDim2.new(0.28, 0, 0.08, 0), function()
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
            
            createEmojiButton(mainFrame, "📋", "Copy User ID", UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                if setclipboard then
                    setclipboard(tostring(game.Players.LocalPlayer.UserId))
                    _G.FW.showAlert("Success", "User ID copied!", 2)
                end
            end)
            
            createEmojiButton(mainFrame, "👁️", "Hide UI (5s)", UDim2.new(0.36, 0, 0.3, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                hideUI()
                _G.FW.showAlert("Info", "UI hidden for 5 seconds!", 1)
            end)
            
            createEmojiButton(mainFrame, "⚡", "Extreme Anti-Lag", UDim2.new(0.67, 0, 0.3, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                extremeAntiLag()
            end)
            
            createEmojiButton(mainFrame, "🧹", "Clear Workspace", UDim2.new(0.05, 0, 0.4, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                for _, obj in pairs(workspace:GetChildren()) do
                    if not obj:IsA("Terrain") and not obj:IsA("Camera") and obj ~= workspace.CurrentCamera then
                        pcall(function() obj:Destroy() end)
                    end
                end
                _G.FW.showAlert("Success", "Workspace cleared!", 2)
            end)
            
            createEmojiButton(mainFrame, "🎵", "Toggle Sound", UDim2.new(0.36, 0, 0.4, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                local settings = UserSettings():GetService("UserGameSettings")
                if settings.MasterVolume > 0 then
                    settings.MasterVolume = 0
                    _G.FW.showAlert("Info", "Sound disabled!", 2)
                else
                    settings.MasterVolume = 1
                    _G.FW.showAlert("Info", "Sound enabled!", 2)
                end
            end)
            
            createEmojiButton(mainFrame, "🔄", "Refresh UI", UDim2.new(0.67, 0, 0.4, 0), UDim2.new(0.28, 0, 0.08, 0), function()
                _G.FW.hide()
                wait(0.5)
                _G.FW.show()
                _G.FW.showAlert("Success", "UI refreshed!", 2)
            end)
            
            updateStats()
        end
    end
    
    updateExtraPage()
    
    wait(1)
    
    local modules = {
        "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Scripts.lua",
            "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/ai.lua"
    }
    
    for i, moduleUrl in pairs(modules) do
        spawn(function()
            
            
            local success, moduleCode = pcall(function()
                return game:HttpGet(moduleUrl)
            end)
            
            if success then
                print("Module " .. i .. " downloaded successfully")
                
                local success2, error = pcall(function()
                    loadstring(moduleCode)()
                end)
                
                if success2 then
                    print("Module " .. i .. " executed successfully")
                else
                    warn("Error executing module " .. i .. ": " .. tostring(error))
                end
            else
                warn("Error downloading module " .. i .. ": " .. tostring(moduleCode))
            end
        end)
        
        wait(1)
    end
end)
