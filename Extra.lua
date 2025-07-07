_G.FW = loadstring(game:HttpGet("https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/test.la"))()
local HttpService = game:GetService("HttpService")

local playerCountLabel = nil

spawn(function()
    wait(1)
    
    local function updateExtraPage()
        local extraPage = _G.FW.getUI()["11"]:FindFirstChild("ExtraPage")
        if extraPage then
            local title = extraPage:FindFirstChild("TextLabel")
            if title then title.Text = "System Tools" end
            
            local mainFrame = _G.FW.cF(extraPage, {
                BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                Size = UDim2.new(0.9, 0, 0.7, 0),
                Position = UDim2.new(0.05, 0, 0.15, 0),
                Name = "MainFrame"
            })
            _G.FW.cC(mainFrame, 0.02)
            _G.FW.cS(mainFrame, 2, Color3.fromRGB(35, 39, 54))
            
            playerCountLabel = _G.FW.cT(mainFrame, {
                Text = "Players: 0/0",
                TextSize = 18,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                BackgroundTransparency = 1,
                Size = UDim2.new(0.9, 0, 0.15, 0),
                Position = UDim2.new(0.05, 0, 0.05, 0),
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            _G.FW.cTC(playerCountLabel, 18)
            
            local resetBtn = _G.FW.cStdBtn(mainFrame, "ResetBtn", "Reset Character", "rbxassetid://73909411554012", UDim2.new(0.05, 0, 0.25, 0), UDim2.new(0.4, 0, 0.2, 0))
            local rejoinBtn = _G.FW.cStdBtn(mainFrame, "RejoinBtn", "Rejoin Server", "rbxassetid://89434276213036", UDim2.new(0.55, 0, 0.25, 0), UDim2.new(0.4, 0, 0.2, 0))
            local copyIdBtn = _G.FW.cStdBtn(mainFrame, "CopyIdBtn", "Copy User ID", "rbxassetid://133018045821797", UDim2.new(0.05, 0, 0.5, 0), UDim2.new(0.4, 0, 0.2, 0))
            local serverHopBtn = _G.FW.cStdBtn(mainFrame, "ServerHopBtn", "Server Hop", "rbxassetid://94595204123047", UDim2.new(0.55, 0, 0.5, 0), UDim2.new(0.4, 0, 0.2, 0))
            
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
