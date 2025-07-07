_G.FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()
local HttpService = game:GetService("HttpService")

local playerCountLabel = nil
local currentTransparency = 0

local function hideUI()
    local ui = _G.FW.getUI()
    if ui then
        for _, element in pairs(ui:GetChildren()) do
            if element:IsA("GuiObject") then
                element.Visible = false
            end
        end
        
        spawn(function()
            wait(5)
            for _, element in pairs(ui:GetChildren()) do
                if element:IsA("GuiObject") then
                    element.Visible = true
                end
            end
            _G.FW.showAlert("Success", "UI restored!", 2)
        end)
    end
end

local function changeUITransparency(transparency)
    local function updateElement(element)
        if element:IsA("Frame") or element:IsA("TextLabel") or element:IsA("TextButton") then
            if element:FindFirstChild("BackgroundTransparency") then
                element.BackgroundTransparency = math.min(transparency, 0.95)
            end
        elseif element:IsA("ImageLabel") or element:IsA("ImageButton") then
            if element:FindFirstChild("ImageTransparency") then
                element.ImageTransparency = math.min(transparency, 0.95)
            end
            if element:FindFirstChild("BackgroundTransparency") then
                element.BackgroundTransparency = math.min(transparency, 0.95)
            end
        end
        
        for _, child in pairs(element:GetChildren()) do
            updateElement(child)
        end
    end
    
    local ui = _G.FW.getUI()
    if ui then
        updateElement(ui)
    end
    
    currentTransparency = transparency
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

spawn(function()
    wait(2)
    
    local function updateExtraPage()
        local extraPage = _G.FW.getUI()["11"]:FindFirstChild("ExtraPage")
        if extraPage then
            local title = extraPage:FindFirstChild("TextLabel")
            if title then title.Text = "System Tools" end
            
            local mainFrame = _G.FW.cF(extraPage, {
                BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                Size = UDim2.new(0.9, 0, 0.85, 0),
                Position = UDim2.new(0.05, 0, 0.1, 0),
                Name = "MainFrame"
            })
            _G.FW.cC(mainFrame, 0.02)
            _G.FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
            
            playerCountLabel = _G.FW.cT(mainFrame, {
                Text = "Players: 0/0",
                TextSize = 16,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0.08, 0),
                Position = UDim2.new(0.05, 0, 0.02, 0),
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            _G.FW.cTC(playerCountLabel, 16)
            
            local resetBtn = _G.FW.cStdBtn(mainFrame, "ResetBtn", "Reset Character", "rbxassetid://73909411554012", UDim2.new(0.05, 0, 0.12, 0), UDim2.new(0.28, 0, 0.12, 0))
            local rejoinBtn = _G.FW.cStdBtn(mainFrame, "RejoinBtn", "Rejoin Server", "rbxassetid://89434276213036", UDim2.new(0.36, 0, 0.12, 0), UDim2.new(0.28, 0, 0.12, 0))
            local serverHopBtn = _G.FW.cStdBtn(mainFrame, "ServerHopBtn", "Server Hop", "rbxassetid://94595204123047", UDim2.new(0.67, 0, 0.12, 0), UDim2.new(0.28, 0, 0.12, 0))
            
            local copyIdBtn = _G.FW.cStdBtn(mainFrame, "CopyIdBtn", "Copy User ID", "rbxassetid://133018045821797", UDim2.new(0.05, 0, 0.27, 0), UDim2.new(0.28, 0, 0.12, 0))
            local hideUIBtn = _G.FW.cStdBtn(mainFrame, "HideUIBtn", "Hide UI (5s)", "rbxassetid://6034229496", UDim2.new(0.36, 0, 0.27, 0), UDim2.new(0.28, 0, 0.12, 0))
            local antiLagBtn = _G.FW.cStdBtn(mainFrame, "AntiLagBtn", "Extreme Anti-Lag", "rbxassetid://6034229496", UDim2.new(0.67, 0, 0.27, 0), UDim2.new(0.28, 0, 0.12, 0))
            
            local transparencyFrame = _G.FW.cF(mainFrame, {
                BackgroundColor3 = Color3.fromRGB(16, 19, 27),
                Size = UDim2.new(0.9, 0, 0.25, 0),
                Position = UDim2.new(0.05, 0, 0.42, 0),
                Name = "TransparencyFrame"
            })
            _G.FW.cC(transparencyFrame, 0.02)
            _G.FW.cS(transparencyFrame, 1, Color3.fromRGB(35, 39, 54))
            
            local transparencyLabel = _G.FW.cT(transparencyFrame, {
                Text = "UI Transparency: 0%",
                TextSize = 14,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0.2, 0),
                Position = UDim2.new(0.05, 0, 0.05, 0),
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            _G.FW.cTC(transparencyLabel, 14)
            
            local trans0Btn = _G.FW.cStdBtn(transparencyFrame, "Trans0", "0%", "rbxassetid://6034229496", UDim2.new(0.05, 0, 0.3, 0), UDim2.new(0.18, 0, 0.3, 0))
            local trans25Btn = _G.FW.cStdBtn(transparencyFrame, "Trans25", "25%", "rbxassetid://6034229496", UDim2.new(0.25, 0, 0.3, 0), UDim2.new(0.18, 0, 0.3, 0))
            local trans50Btn = _G.FW.cStdBtn(transparencyFrame, "Trans50", "50%", "rbxassetid://6034229496", UDim2.new(0.45, 0, 0.3, 0), UDim2.new(0.18, 0, 0.3, 0))
            local trans75Btn = _G.FW.cStdBtn(transparencyFrame, "Trans75", "75%", "rbxassetid://6034229496", UDim2.new(0.65, 0, 0.3, 0), UDim2.new(0.18, 0, 0.3, 0))
            local trans90Btn = _G.FW.cStdBtn(transparencyFrame, "Trans90", "90%", "rbxassetid://6034229496", UDim2.new(0.77, 0, 0.3, 0), UDim2.new(0.18, 0, 0.3, 0))
            
            local resetTransBtn = _G.FW.cStdBtn(transparencyFrame, "ResetTrans", "Reset Transparency", "rbxassetid://6034229496", UDim2.new(0.05, 0, 0.65, 0), UDim2.new(0.4, 0, 0.3, 0))
            
            resetBtn.MouseButton1Click:Connect(function()
                if game.Players.LocalPlayer.Character then
                    game.Players.LocalPlayer.Character:FindFirstChild("Humanoid"):ChangeState(Enum.HumanoidStateType.Dead)
                    _G.FW.showAlert("Success", "Character reset!", 2)
                end
            end)
            
            rejoinBtn.MouseButton1Click:Connect(function()
                game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
            end)
            
            copyIdBtn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(tostring(game.Players.LocalPlayer.UserId))
                    _G.FW.showAlert("Success", "User ID copied!", 2)
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
            
            hideUIBtn.MouseButton1Click:Connect(function()
                hideUI()
                _G.FW.showAlert("Info", "UI hidden for 5 seconds!", 1)
            end)
            
            antiLagBtn.MouseButton1Click:Connect(function()
                extremeAntiLag()
            end)
            
            trans0Btn.MouseButton1Click:Connect(function()
                changeUITransparency(0)
                transparencyLabel.Text = "UI Transparency: 0%"
            end)
            
            trans25Btn.MouseButton1Click:Connect(function()
                changeUITransparency(0.25)
                transparencyLabel.Text = "UI Transparency: 25%"
            end)
            
            trans50Btn.MouseButton1Click:Connect(function()
                changeUITransparency(0.5)
                transparencyLabel.Text = "UI Transparency: 50%"
            end)
            
            trans75Btn.MouseButton1Click:Connect(function()
                changeUITransparency(0.75)
                transparencyLabel.Text = "UI Transparency: 75%"
            end)
            
            trans90Btn.MouseButton1Click:Connect(function()
                changeUITransparency(0.9)
                transparencyLabel.Text = "UI Transparency: 90%"
            end)
            
            resetTransBtn.MouseButton1Click:Connect(function()
                changeUITransparency(0)
                transparencyLabel.Text = "UI Transparency: 0%"
                _G.FW.showAlert("Success", "Transparency reset!", 2)
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
    
    updateExtraPage()
    
    wait(1)
    
    local modules = {
        "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Cloud.lua"
    }
    
    for i, moduleUrl in pairs(modules) do
        spawn(function()
            print("Loading module " .. i .. ": " .. moduleUrl)
            
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
