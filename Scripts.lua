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
    ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()",
    ["CMD-X"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/CMD-X/CMD-X/master/Source', true))()"
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
        local yPos = 0
        for name, content in pairs(localScripts) do
            local sF = FW.cF(scriptsScrollRef, {
                BackgroundColor3 = Color3.fromRGB(20, 25, 32),
                Size = UDim2.new(1, 0, 0, 50),
                Position = UDim2.new(0, 0, 0, yPos),
                Name = "Script_" .. name
            })
            FW.cC(sF, 0.02)
            FW.cS(sF, 1, Color3.fromRGB(35, 39, 54))
            
            local sBtn = FW.cB(sF, {
                BackgroundColor3 = Color3.fromRGB(50, 60, 80),
                Size = UDim2.new(0.55, 0, 0.8, 0),
                Position = UDim2.new(0.02, 0, 0.1, 0),
                Text = name,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                TextScaled = true,
                FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
            })
            FW.cC(sBtn, 0.02)
            FW.cTC(sBtn, 18)
            
            local loadBtn = FW.cB(sF, {
                BackgroundColor3 = Color3.fromRGB(100, 150, 255),
                Size = UDim2.new(0.12, 0, 0.6, 0),
                Position = UDim2.new(0.59, 0, 0.2, 0),
                Text = "Load",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true
            })
            FW.cC(loadBtn, 0.02)
            FW.cTC(loadBtn, 14)
            
            local execBtn = FW.cB(sF, {
                BackgroundColor3 = Color3.fromRGB(100, 150, 100),
                Size = UDim2.new(0.12, 0, 0.6, 0),
                Position = UDim2.new(0.73, 0, 0.2, 0),
                Text = "Run",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true
            })
            FW.cC(execBtn, 0.02)
            FW.cTC(execBtn, 14)
            
            local delBtn = FW.cB(sF, {
                BackgroundColor3 = Color3.fromRGB(150, 100, 100),
                Size = UDim2.new(0.12, 0, 0.6, 0),
                Position = UDim2.new(0.86, 0, 0.2, 0),
                Text = "X",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                TextScaled = true
            })
            FW.cC(delBtn, 0.02)
            FW.cTC(delBtn, 14)
            
            sBtn.MouseButton1Click:Connect(function()
                FW.showAlert("Info", "Script: " .. name, 2)
            end)
            
            loadBtn.MouseButton1Click:Connect(function()
                local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                if srcRef then
                    srcRef.Text = content
                    FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                    FW.showAlert("Success", "Script loaded to editor!", 2)
                end
            end)
            
            execBtn.MouseButton1Click:Connect(function()
                local success, result = pcall(function()
                    return loadstring(content)
                end)
                if success and result then
                    local execSuccess, execErr = pcall(result)
                    if execSuccess then
                        FW.showAlert("Success", name .. " executed!", 2)
                    else
                        FW.showAlert("Error", "Execution error!", 4)
                    end
                else
                    FW.showAlert("Error", "Compilation error!", 4)
                end
            end)
            
            delBtn.MouseButton1Click:Connect(function()
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
            
            yPos = yPos + 55
        end
        scriptsScrollRef.CanvasSize = UDim2.new(0, 0, 0, yPos)
    end
end

local function createBtn(parent, data, index)
    local yPos = (index - 1) * 120
    local btn = FW.cF(parent, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.96, 0, 0, 110),
        Position = UDim2.new(0.02, 0, 0, yPos),
        Name = "ScriptBtn"
    })
    FW.cC(btn, 0.15)
    FW.cG(btn, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
    
    local titleLbl = FW.cT(btn, {
        Text = data.title or "Unknown Script",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.35, 0),
        Position = UDim2.new(0.05, 0, 0.05, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(titleLbl, 16)
    
    local gameLbl = FW.cT(btn, {
        Text = "🎮 " .. (data.game and data.game.name or "Universal"),
        TextSize = 14,
        TextColor3 = Color3.fromRGB(60, 60, 80),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.25, 0),
        Position = UDim2.new(0.05, 0, 0.4, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cTC(gameLbl, 14)
    
    local statsLbl = FW.cT(btn, {
        Text = "👁️ " .. (data.views or "0") .. " | ⭐ " .. (data.likeCount or "0") .. " | 📅 " .. (data.createdAt and string.sub(data.createdAt, 1, 10) or "Unknown"),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(80, 80, 100),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.25, 0),
        Position = UDim2.new(0.05, 0, 0.7, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cTC(statsLbl, 12)
    
    local clickBtn = FW.cB(btn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    clickBtn.MouseButton1Click:Connect(function()
        selScript = data
        showOpts(data)
    end)
    
    return btn
end

function showOpts(data)
    if scriptF then
        scriptF:Destroy()
    end
    
    local ui = FW.getUI()
    local mainUI = ui["11"]
    
    scriptF = FW.cF(mainUI, {
        BackgroundColor3 = Color3.fromRGB(13, 15, 20),
        Size = UDim2.new(0.8, 0, 0.6, 0),
        Position = UDim2.new(0.1, 0, 0.2, 0),
        Name = "ScriptFrame",
        ZIndex = 10
    })
    FW.cC(scriptF, 0.02)
    FW.cS(scriptF, 3, Color3.fromRGB(100, 200, 255))
    
    local titleBar = FW.cF(scriptF, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 32),
        Size = UDim2.new(1, 0, 0.15, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "TitleBar"
    })
    FW.cC(titleBar, 0.02)
    
    local title = FW.cT(titleBar, {
        Text = data.title or "Script Options",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.8, 0, 1, 0),
        Position = UDim2.new(0.05, 0, 0, 0),
        TextScaled = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(title, 18)
    
    local closeBtn = FW.cB(titleBar, {
        BackgroundColor3 = Color3.fromRGB(220, 50, 50),
        Size = UDim2.new(0.1, 0, 0.6, 0),
        Position = UDim2.new(0.88, 0, 0.2, 0),
        Text = "✕",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 16,
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cC(closeBtn, 0.15)
    FW.cTC(closeBtn, 16)
    
    closeBtn.MouseButton1Click:Connect(function()
        if scriptF then
            scriptF:Destroy()
            scriptF = nil
        end
    end)
    
    local contentF = FW.cF(scriptF, {
        BackgroundColor3 = Color3.fromRGB(16, 19, 27),
        Size = UDim2.new(0.95, 0, 0.8, 0),
        Position = UDim2.new(0.025, 0, 0.18, 0),
        Name = "ContentFrame"
    })
    FW.cC(contentF, 0.02)
    
    local infoLbl = FW.cT(contentF, {
        Text = "🎮 " .. (data.game and data.game.name or "Universal") .. "\n👁️ " .. (data.views or "0") .. " views | ⭐ " .. (data.likeCount or "0") .. " likes\n👤 " .. (data.owner and data.owner.username or "Unknown"),
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.2, 0),
        Position = UDim2.new(0.05, 0, 0.05, 0),
        TextScaled = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cTC(infoLbl, 14)
    
    local execBtn = FW.cF(contentF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.2, 0, 0.15, 0),
        Position = UDim2.new(0.05, 0, 0.3, 0),
        Name = "ExecuteBtn"
    })
    FW.cC(execBtn, 0.15)
    FW.cG(execBtn, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
    
    local execLbl = FW.cT(execBtn, {
        Text = "▶️ Execute",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(execLbl, 14)
    
    local execClick = FW.cB(execBtn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    execClick.MouseButton1Click:Connect(function()
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
                local success, result = pcall(function()
                    return loadstring(scriptContent)
                end)
                if success and result then
                    local execSuccess, execErr = pcall(result)
                    if execSuccess then
                        FW.showAlert("Success", "Script executed!", 2)
                    else
                        FW.showAlert("Error", "Execution error!", 2)
                    end
                else
                    FW.showAlert("Error", "Compilation error!", 2)
                end
            else
                FW.showAlert("Error", "Failed to fetch script!", 2)
            end
        end)
    end)
    
    local copyBtn = FW.cF(contentF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.2, 0, 0.15, 0),
        Position = UDim2.new(0.27, 0, 0.3, 0),
        Name = "CopyBtn"
    })
    FW.cC(copyBtn, 0.15)
    FW.cG(copyBtn, Color3.fromRGB(255, 200, 100), Color3.fromRGB(200, 150, 50))
    
    local copyLbl = FW.cT(copyBtn, {
        Text = "📋 Copy",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(copyLbl, 14)
    
    local copyClick = FW.cB(copyBtn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    copyClick.MouseButton1Click:Connect(function()
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
                FW.showAlert("Success", "Script copied to clipboard!", 2)
            else
                FW.showAlert("Error", "Failed to copy script!", 2)
            end
        end)
    end)
    
    local saveBtn = FW.cF(contentF, {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(0.2, 0, 0.15, 0),
        Position = UDim2.new(0.49, 0, 0.3, 0),
        Name = "SaveBtn"
    })
    FW.cC(saveBtn, 0.15)
    FW.cG(saveBtn, Color3.fromRGB(100, 150, 255), Color3.fromRGB(50, 100, 200))
    
    local saveLbl = FW.cT(saveBtn, {
        Text = "💾 Save",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(29, 29, 38),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.05, 0, 0.1, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(saveLbl, 14)
    
    local saveClick = FW.cB(saveBtn, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = 5
    })
    
    saveClick.MouseButton1Click:Connect(function()
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
                FW.showAlert("Success", "Script saved locally!", 2)
            else
                FW.showAlert("Error", "Failed to save script!", 2)
            end
        end)
    end)
    
    local prevF = FW.cF(contentF, {
        BackgroundColor3 = Color3.fromRGB(10, 12, 18),
        Size = UDim2.new(0.9, 0, 0.4, 0),
        Position = UDim2.new(0.05, 0, 0.5, 0),
        Name = "PreviewFrame"
    })
    FW.cC(prevF, 0.02)
    FW.cS(prevF, 1, Color3.fromRGB(35, 39, 54))
    
    local prevLbl = FW.cT(prevF, {
        Text = "Script Preview",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(150, 150, 150),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.15, 0),
        Position = UDim2.new(0.05, 0, 0.05, 0),
        TextScaled = true,
        FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
    })
    FW.cTC(prevLbl, 12)
    
    local prevTxt = FW.cT(prevF, {
        Text = data.script and string.sub(data.script, 1, 200) .. "..." or "Loading preview...",
        TextSize = 10,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        BackgroundTransparency = 1,
        Size = UDim2.new(0.9, 0, 0.75, 0),
        Position = UDim2.new(0.05, 0, 0.2, 0),
        TextScaled = false,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
    })
    FW.cTC(prevTxt, 10)
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
        if child.Name == "ScriptBtn" then
            child:Destroy()
        end
    end
    for i, script in pairs(scripts) do
        createBtn(scrollFrame, script, i)
    end
    local totalHeight = #scripts * 120 + 20
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

local scriptsPage = FW.cI(FW.getUI()["11"], {
    ImageTransparency = 1,
    ImageColor3 = Color3.fromRGB(13, 15, 20),
    Image = "rbxassetid://76734110237026",
    Size = UDim2.new(1.001, 0, 1, 0),
    Visible = false,
    ClipsDescendants = true,
    BackgroundTransparency = 1,
    Name = "ScriptsPage",
    Position = UDim2.new(-0.001, 0, 0, 0)
})

local title = FW.cT(scriptsPage, {
    Text = "📜 Scripts Hub",
    TextSize = 32,
    TextColor3 = Color3.fromRGB(255, 150, 100),
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 0.08, 0),
    Position = UDim2.new(0, 0, 0.02, 0),
    TextScaled = true,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
})
FW.cTC(title, 32)

local mainF = FW.cF(scriptsPage, {
    BackgroundColor3 = Color3.fromRGB(20, 25, 32),
    Size = UDim2.new(0.95, 0, 0.85, 0),
    Position = UDim2.new(0.025, 0, 0.12, 0),
    Name = "MainFrame"
})
FW.cC(mainF, 0.02)
FW.cS(mainF, 2, Color3.fromRGB(35, 39, 54))

local tabF = FW.cF(mainF, {
    BackgroundColor3 = Color3.fromRGB(16, 19, 27),
    Size = UDim2.new(0.95, 0, 0.1, 0),
    Position = UDim2.new(0.025, 0, 0.02, 0),
    Name = "TabFrame"
})
FW.cC(tabF, 0.02)
FW.cS(tabF, 1, Color3.fromRGB(35, 39, 54))

local localTab = FW.cF(tabF, {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0.45, 0, 0.7, 0),
    Position = UDim2.new(0.05, 0, 0.15, 0),
    Name = "LocalTab"
})
FW.cC(localTab, 0.15)
FW.cG(localTab, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))

local localLbl = FW.cT(localTab, {
    Text = "💻 Local Scripts",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(29, 29, 38),
    BackgroundTransparency = 1,
    Size = UDim2.new(0.9, 0, 0.8, 0),
    Position = UDim2.new(0.05, 0, 0.1, 0),
    TextScaled = true,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
})
FW.cTC(localLbl, 16)

local localClick = FW.cB(localTab, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "",
    ZIndex = 5
})

local cloudTab = FW.cF(tabF, {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0.45, 0, 0.7, 0),
    Position = UDim2.new(0.52, 0, 0.15, 0),
    Name = "CloudTab"
})
FW.cC(cloudTab, 0.15)
FW.cG(cloudTab, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))

local cloudLbl = FW.cT(cloudTab, {
    Text = "☁️ Cloud Scripts",
    TextSize = 16,
    TextColor3 = Color3.fromRGB(29, 29, 38),
    BackgroundTransparency = 1,
    Size = UDim2.new(0.9, 0, 0.8, 0),
    Position = UDim2.new(0.05, 0, 0.1, 0),
    TextScaled = true,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
})
FW.cTC(cloudLbl, 16)

local cloudClick = FW.cB(cloudTab, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "",
    ZIndex = 5
})

localF = FW.cF(mainF, {
    BackgroundColor3 = Color3.fromRGB(16, 19, 27),
    Size = UDim2.new(0.95, 0, 0.85, 0),
    Position = UDim2.new(0.025, 0, 0.13, 0),
    Name = "LocalFrame",
    Visible = true
})
FW.cC(localF, 0.02)
FW.cS(localF, 1, Color3.fromRGB(35, 39, 54))

cloudF = FW.cF(mainF, {
    BackgroundColor3 = Color3.fromRGB(16, 19, 27),
    Size = UDim2.new(0.95, 0, 0.85, 0),
    Position = UDim2.new(0.025, 0, 0.13, 0),
    Name = "CloudFrame",
    Visible = false
})
FW.cC(cloudF, 0.02)
FW.cS(cloudF, 1, Color3.fromRGB(35, 39, 54))

local inputF = FW.cF(localF, {
    BackgroundColor3 = Color3.fromRGB(20, 25, 32),
    Size = UDim2.new(0.95, 0, 0.2, 0),
    Position = UDim2.new(0.025, 0, 0.02, 0),
    Name = "InputFrame"
})
FW.cC(inputF, 0.02)
FW.cS(inputF, 2, Color3.fromRGB(35, 39, 54))

local nameBox = FW.cTB(inputF, {
    BackgroundColor3 = Color3.fromRGB(24, 28, 35),
    Size = UDim2.new(0.4, 0, 0.25, 0),
    Position = UDim2.new(0.02, 0, 0.1, 0),
    Text = "",
    PlaceholderText = "Script Name",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 16,
    TextScaled = true,
    FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    Name = "NameBox"
})
FW.cC(nameBox, 0.02)
FW.cS(nameBox, 1, Color3.fromRGB(50, 55, 65))
FW.cTC(nameBox, 16)

local contentBox = FW.cTB(inputF, {
    BackgroundColor3 = Color3.fromRGB(24, 28, 35),
    Size = UDim2.new(0.4, 0, 0.25, 0),
    Position = UDim2.new(0.44, 0, 0.1, 0),
    Text = "",
    PlaceholderText = "Paste script content here",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    PlaceholderColor3 = Color3.fromRGB(150, 150, 150),
    TextSize = 14,
    TextScaled = false,
    TextWrapped = true,
    FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
    Name = "ContentBox"
})
FW.cC(contentBox, 0.02)
FW.cS(contentBox, 1, Color3.fromRGB(50, 55, 65))
FW.cTC(contentBox, 14)

local saveFromEditorBtn = FW.cStdBtn(inputF, "SaveEditorBtn", "Save From Editor", "rbxassetid://89434276213036", UDim2.new(0.02, 0, 0.4, 0), UDim2.new(0.3, 0, 0.25, 0))
local saveFromBoxBtn = FW.cStdBtn(inputF, "SaveBoxBtn", "Save From Box", "rbxassetid://89434276213036", UDim2.new(0.34, 0, 0.4, 0), UDim2.new(0.3, 0, 0.25, 0))
local pasteBtn = FW.cStdBtn(inputF, "PasteBtn", "Paste Clipboard", "rbxassetid://133018045821797", UDim2.new(0.66, 0, 0.4, 0), UDim2.new(0.3, 0, 0.25, 0))

local instrTxt = FW.cT(inputF, {
    Text = "Enter name and paste/type script content, then save. Or save current editor content.",
    TextSize = 12,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    BackgroundTransparency = 1,
    Size = UDim2.new(0.96, 0, 0.25, 0),
    Position = UDim2.new(0.02, 0, 0.7, 0),
    TextScaled = true,
    TextWrapped = true,
    FontFace = Font.new("rbxassetid://11702779409", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
})
FW.cTC(instrTxt, 12)

local scriptsF = FW.cF(localF, {
    BackgroundColor3 = Color3.fromRGB(16, 19, 27),
    Size = UDim2.new(0.95, 0, 0.75, 0),
    Position = UDim2.new(0.025, 0, 0.23, 0),
    Name = "ScriptsFrame"
})
FW.cC(scriptsF, 0.02)
FW.cS(scriptsF, 2, Color3.fromRGB(35, 39, 54))

local scriptsScroll = FW.cSF(scriptsF, {
    BackgroundColor3 = Color3.fromRGB(12, 15, 22),
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 8,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    Name = "ScriptsScroll"
})
FW.cC(scriptsScroll, 0.02)
scriptsScrollRef = scriptsScroll

saveFromEditorBtn.MouseButton1Click:Connect(function()
    local name = nameBox.Text
    if name and name ~= "" then
        local srcRef = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
        if srcRef then
            saveScript(name, srcRef.Text)
            nameBox.Text = ""
            FW.showAlert("Success", "Script saved: " .. name, 2)
        end
    else
        FW.showAlert("Error", "Please enter a script name!", 2)
    end
end)

saveFromBoxBtn.MouseButton1Click:Connect(function()
    local name = nameBox.Text
    local content = contentBox.Text
    if name and name ~= "" and content and content ~= "" then
        saveScript(name, content)
        nameBox.Text = ""
        contentBox.Text = ""
        FW.showAlert("Success", "Script saved: " .. name, 2)
    else
        FW.showAlert("Error", "Please enter name and content!", 2)
    end
end)

pasteBtn.MouseButton1Click:Connect(function()
    local clipboard = getclipboard and getclipboard() or ""
    if clipboard ~= "" then
        contentBox.Text = clipboard
        FW.showAlert("Success", "Content pasted!", 2)
    else
        FW.showAlert("Error", "Clipboard is empty!", 2)
    end
end)

local searchF = FW.cF(cloudF, {
    BackgroundColor3 = Color3.fromRGB(10, 12, 18),
    Size = UDim2.new(0.95, 0, 0.12, 0),
    Position = UDim2.new(0.025, 0, 0.02, 0),
    Name = "SearchFrame"
})
FW.cC(searchF, 0.02)
FW.cS(searchF, 1, Color3.fromRGB(35, 39, 54))

local searchBox = FW.cTB(searchF, {
    BackgroundColor3 = Color3.fromRGB(180, 180, 180),
    Size = UDim2.new(0.7, 0, 0.6, 0),
    Position = UDim2.new(0.05, 0, 0.2, 0),
    PlaceholderText = "Search for scripts...",
    PlaceholderColor3 = Color3.fromRGB(100, 100, 100),
    Text = "",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(29, 29, 38),
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
})
FW.cC(searchBox, 0.15)
FW.cTC(searchBox, 14)

local searchBtn = FW.cF(searchF, {
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(0.2, 0, 0.6, 0),
    Position = UDim2.new(0.77, 0, 0.2, 0),
    Name = "SearchBtn"
})
FW.cC(searchBtn, 0.15)
FW.cG(searchBtn, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))

local searchLbl = FW.cT(searchBtn, {
    Text = "🔍 Search",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(29, 29, 38),
    BackgroundTransparency = 1,
    Size = UDim2.new(0.9, 0, 0.8, 0),
    Position = UDim2.new(0.05, 0, 0.1, 0),
    TextScaled = true,
    FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
})
FW.cTC(searchLbl, 14)

local searchClick = FW.cB(searchBtn, {
    BackgroundTransparency = 1,
    Size = UDim2.new(1, 0, 1, 0),
    Text = "",
    ZIndex = 5
})

local scrollF = FW.cSF(cloudF, {
    BackgroundColor3 = Color3.fromRGB(10, 12, 18),
    Size = UDim2.new(0.95, 0, 0.8, 0),
    Position = UDim2.new(0.025, 0, 0.16, 0),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    ScrollBarThickness = 8,
    Name = "ScrollFrame"
})
FW.cC(scrollF, 0.02)
FW.cS(scrollF, 1, Color3.fromRGB(35, 39, 54))

searchClick.MouseButton1Click:Connect(function()
    local query = searchBox.Text
    if query and query ~= "" then
        FW.showAlert("Info", "Searching scripts...", 1)
        spawn(function()
            local scripts = searchScripts(query, 50)
            if #scripts > 0 then
                curScripts = scripts
                displayScripts(scripts, scrollF)
                FW.showAlert("Success", "Found " .. #scripts .. " scripts!", 2)
            else
                FW.showAlert("Error", "No scripts found!", 2)
            end
        end)
    else
        FW.showAlert("Error", "Please enter a search term!", 2)
    end
end)

searchBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        searchClick.MouseButton1Click:Fire()
    end
end)

localClick.MouseButton1Click:Connect(function()
    switchSec("Local")
    FW.cG(localTab, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))
    FW.cG(cloudTab, Color3.fromRGB(100, 200, 255), Color3.fromRGB(50, 150, 200))
end)

cloudClick.MouseButton1Click:Connect(function()
    switchSec("Cloud")
    FW.cG(cloudTab, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
    FW.cG(localTab, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
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
            FW.cG(box, Color3.fromRGB(255, 150, 100), Color3.fromRGB(200, 100, 50))
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
        displayScripts(popularScripts, scrollF)
    end
end)
end)
