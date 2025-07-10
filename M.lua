while not getgenv()._FW_ACCESS_GRANTED do
    wait(0.5)
end

spawn(function()
    wait(1)
    local FW = getgenv()._FW or {}
    local hs = game:GetService("HttpService")
    local ts = game:GetService("TweenService")
    local rs = game:GetService("RunService")
    
    local md = "FrostWare/Music/"
    local cd = "FrostWare/cloud_cache/"
    local CLOUD_JSON_URL = "https://system.heatherx.site:8443/audios.json"
    local PROXY_URL = "https://music.brunomatiastoledo2000.workers.dev/"
    local sf = {".mp3", ".ogg", ".wav", ".m4a", ".flac"}
    
    local cp, cv, cm = nil, 0.5, nil
    local ml, cl, fl, fcl = {}, {}, {}, {}
    local sr, csr = nil, nil
    local isLooped, currentTime, totalTime = false, 0, 0
    local progressBar, timeLabel, visualizer = nil, nil, nil
    local downloadProgress = {}
    local currentSection = "local"
    local currentPlayingIsCloud = false
    
    local mp = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(15, 18, 25),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "MusicPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })
    
    local function cUI(p, t, pr)
        local props = pr or {}
        if t == "text" then
            local txt = FW.cT(p, {
                Text = props.Text or "",
                TextSize = props.TextSize or 14,
                TextColor3 = props.TextColor3 or Color3.fromRGB(240, 245, 255),
                BackgroundTransparency = props.BackgroundTransparency or 1,
                Size = props.Size or UDim2.new(1, 0, 1, 0),
                Position = props.Position or UDim2.new(0, 0, 0, 0),
                TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
                TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Name = props.Name or "StyledText"
            })
            FW.cTC(txt, props.TextSize or 14)
            return txt
        elseif t == "button" then
            local of = FW.cF(p, {
                BackgroundColor3 = Color3.fromRGB(12, 16, 24),
                Size = props.Size,
                Position = props.Position,
                Name = (props.Name or "Button") .. "_Outer"
            })
            FW.cC(of, 0.18)
            
            local btn = FW.cB(of, {
                BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(50, 130, 210),
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                Text = props.Text or "",
                TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
                TextSize = props.TextSize or 12,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Name = props.Name or "Button"
            })
            FW.cC(btn, 0.15)
            FW.cTC(btn, props.TextSize or 12)
            return btn, of
        elseif t == "input" then
            local of = FW.cF(p, {
                BackgroundColor3 = Color3.fromRGB(18, 22, 32),
                Size = props.Size,
                Position = props.Position,
                Name = (props.Name or "Input") .. "_Outer"
            })
            FW.cC(of, 0.18)
            
            local inp = FW.cTB(of, {
                BackgroundColor3 = Color3.fromRGB(35, 40, 50),
                Size = UDim2.new(1, -8, 1, -8),
                Position = UDim2.new(0, 4, 0, 4),
                PlaceholderText = props.PlaceholderText or "",
                PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
                Text = props.Text or "",
                TextSize = props.TextSize or 14,
                TextColor3 = Color3.fromRGB(240, 245, 255),
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Name = props.Name or "Input"
            })
            FW.cC(inp, 0.15)
            FW.cTC(inp, props.TextSize or 14)
            return inp, of
        elseif t == "container" then
            local of = FW.cF(p, {
                BackgroundColor3 = Color3.fromRGB(8, 12, 20),
                Size = props.Size,
                Position = props.Position,
                Name = (props.Name or "Container") .. "_Outer"
            })
            FW.cC(of, 0.18)
            
            local cont = FW.cF(of, {
                BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(20, 25, 35),
                Size = UDim2.new(1, -8, 1, -8),
                Position = UDim2.new(0, 4, 0, 4),
                Name = props.Name or "Container"
            })
            FW.cC(cont, 0.15)
            return cont, of
        elseif t == "slider" then
            local sf = FW.cF(p, {
                BackgroundColor3 = Color3.fromRGB(30, 35, 45),
                Size = props.Size,
                Position = props.Position,
                Name = (props.Name or "Slider") .. "_Track"
            })
            FW.cC(sf, 0.1)
            
            local sh = FW.cF(sf, {
                BackgroundColor3 = Color3.fromRGB(166, 190, 255),
                Size = UDim2.new(props.Value or 0.5, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Name = (props.Name or "Slider") .. "_Handle"
            })
            FW.cC(sh, 0.1)
            FW.cG(sh, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
            
            local sb = FW.cB(sf, {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                Text = "",
                Name = (props.Name or "Slider") .. "_Button"
            })
            
            return sf, sh, sb
        end
    end
    
    local tb, tbo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 120),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "TopBar"
    })
    
    local cpf, cpfo = cUI(tb, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.35, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        Name = "CurrentlyPlaying"
    })
    
    cUI(cpf, "text", {
        Text = "🎵 Now Playing",
        TextSize = 16,
        TextColor3 = Color3.fromRGB(166, 190, 255),
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "CPLabel"
    })
    
    cUI(cpf, "text", {
        Text = "No music selected",
        TextSize = 18,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.35, 0),
        Position = UDim2.new(0, 0, 0.25, 0),
        Name = "CurrentTrack"
    })
    
    cUI(cpf, "text", {
        Text = "⏹ Stopped",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0.6, 0),
        Name = "PlayStatus"
    })
    
    local vf = FW.cF(cpf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0.7, 0),
        Name = "Visualizer"
    })
    
    local vbars = {}
    for i = 1, 20 do
        local bar = FW.cF(vf, {
            BackgroundColor3 = Color3.fromRGB(166, 190, 255),
            Size = UDim2.new(0.04, 0, 0.1, 0),
            Position = UDim2.new((i-1) * 0.05, 0, 0.9, 0),
            Name = "Bar" .. i
        })
        FW.cC(bar, 0.1)
        FW.cG(bar, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        vbars[i] = bar
    end
    visualizer = vbars
    
    local vcf, vcfo = cUI(tb, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.3, -10, 1, -10),
        Position = UDim2.new(0.37, 5, 0, 5),
        Name = "VolumeControl"
    })
    
    cUI(vcf, "text", {
        Text = "🔊 Volume: " .. math.floor(cv * 100) .. "%",
        TextSize = 14,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(1, 0, 0.3, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "VolumeLabel"
    })
    
    local vs, vh, vb = cUI(vcf, "slider", {
        Size = UDim2.new(0.9, 0, 0.2, 0),
        Position = UDim2.new(0.05, 0, 0.35, 0),
        Value = cv,
        Name = "VolumeSlider"
    })
    
    local pf = FW.cF(vcf, {
        BackgroundColor3 = Color3.fromRGB(30, 35, 45),
        Size = UDim2.new(0.9, 0, 0.15, 0),
        Position = UDim2.new(0.05, 0, 0.6, 0),
        Name = "ProgressFrame"
    })
    FW.cC(pf, 0.1)
    
    local pb = FW.cF(pf, {
        BackgroundColor3 = Color3.fromRGB(166, 190, 255),
        Size = UDim2.new(0, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "ProgressBar"
    })
    FW.cC(pb, 0.1)
    FW.cG(pb, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
    progressBar = pb
    
    local tl = cUI(vcf, "text", {
        Text = "00:00 / 00:00",
        TextSize = 12,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.8, 0),
        Name = "TimeLabel"
    })
    timeLabel = tl
    
    local cf, cfo = cUI(tb, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.33, -10, 1, -10),
        Position = UDim2.new(0.67, 5, 0, 5),
        Name = "Controls"
    })
    
    local plb, plo = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 170, 90),
        Size = UDim2.new(0.22, -2, 0.4, 0),
        Position = UDim2.new(0, 2, 0.1, 0),
        Text = "▶",
        TextSize = 16,
        Name = "PlayPauseBtn"
    })
    
    local stb, sto = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(200, 100, 100),
        Size = UDim2.new(0.22, -2, 0.4, 0),
        Position = UDim2.new(0.26, 2, 0.1, 0),
        Text = "■",
        TextSize = 16,
        Name = "StopBtn"
    })
    
    local shb, sho = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(100, 150, 200),
        Size = UDim2.new(0.22, -2, 0.4, 0),
        Position = UDim2.new(0.52, 2, 0.1, 0),
        Text = "🔀",
        TextSize = 14,
        Name = "ShuffleBtn"
    })
    
    local rfb, rfo = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(150, 100, 200),
        Size = UDim2.new(0.22, -2, 0.4, 0),
        Position = UDim2.new(0.78, 2, 0.1, 0),
        Text = "🔄",
        TextSize = 14,
        Name = "RefreshBtn"
    })
    
    local lpb, lpo = cUI(cf, "button", {
        BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 100, 150),
        Size = UDim2.new(0.48, -2, 0.4, 0),
        Position = UDim2.new(0, 2, 0.55, 0),
        Text = isLooped and "🔁 LOOP ON" or "🔁 LOOP OFF",
        TextSize = 12,
        Name = "LoopBtn"
    })
    
    local scb, sco = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(200, 150, 100),
        Size = UDim2.new(0.48, -2, 0.4, 0),
        Position = UDim2.new(0.52, 2, 0.55, 0),
        Text = "📁 SCAN",
        TextSize = 12,
        Name = "ScanBtn"
    })
    
    local sectf, sectfo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 140),
        Name = "SectionFrame"
    })
    
    local localBtn, localBtnO = cUI(sectf, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0, 10, 0, 7),
        Text = "📁 LOCAL",
        TextSize = 12,
        Name = "LocalBtn"
    })
    
    local cloudBtn, cloudBtnO = cUI(sectf, "button", {
        BackgroundColor3 = Color3.fromRGB(100, 100, 150),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0.22, 5, 0, 7),
        Text = "☁ CLOUD",
        TextSize = 12,
        Name = "CloudBtn"
    })
    
    local af, afo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 200),
        Name = "AddFrame"
    })
    
    local ni, nio = cUI(af, "input", {
        Size = UDim2.new(0.25, -5, 0, 35),
        Position = UDim2.new(0, 10, 0, 12),
        PlaceholderText = "Music Name",
        TextSize = 14,
        Name = "NameInput"
    })
    
    local ui, uio = cUI(af, "input", {
        Size = UDim2.new(0.55, -5, 0, 35),
        Position = UDim2.new(0.27, 5, 0, 12),
        PlaceholderText = "Direct URL to music file (.mp3, .ogg, .wav, .m4a, .flac)",
        TextSize = 14,
        Name = "UrlInput"
    })
    
    local ab, abo = cUI(af, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.15, -5, 0, 35),
        Position = UDim2.new(0.85, 5, 0, 12),
        Text = "📥 ADD",
        TextSize = 12,
        Name = "AddBtn"
    })
    
    local sf, sfo = cUI(mp, "input", {
        Size = UDim2.new(0.4, 0, 0, 35),
        Position = UDim2.new(0, 10, 0, 275),
        PlaceholderText = "🔍 Search music by name or artist...",
        TextSize = 14,
        Name = "SearchInput"
    })
    
    local mlf, mlfo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(1, -20, 1, -330),
        Position = UDim2.new(0, 10, 0, 320),
        Name = "MusicListFrame"
    })
    
    local mls = FW.cSF(mlf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "MusicListScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210),
        Visible = true
    })
    sr = mls
    
    local cmls = FW.cSF(mlf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "CloudMusicListScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210),
        Visible = false
    })
    csr = cmls
    
    local function ensDir(dir)
        if not isfolder(dir) then 
            makefolder(dir) 
        end
    end
    
    local function fT(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end
    
    local function updateNowPlaying(trackName, status, statusColor)
        local cpt = cpf:FindFirstChild("CurrentTrack")
        local cps = cpf:FindFirstChild("PlayStatus")
        
        if cpt then
            cpt.Text = trackName or "No music selected"
        end
        if cps then
            cps.Text = status or "⏹ Stopped"
            cps.TextColor3 = statusColor or Color3.fromRGB(200, 200, 200)
        end
    end
    
    local function stVis(bars)
        if bars and type(bars) == "table" then
            spawn(function()
                while cm and cm.IsPlaying do
                    for i, bar in pairs(bars) do
                        if bar and bar.Parent then
                            local height = math.random(10, 80) / 100
                            local tw = ts:Create(bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
                                Size = UDim2.new(0.04, 0, height, 0),
                                Position = UDim2.new((i-1) * 0.05, 0, 1 - height, 0)
                            })
                            tw:Play()
                        end
                    end
                    wait(0.1)
                end
                for i, bar in pairs(bars) do
                    if bar and bar.Parent then
                        local tw = ts:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(0.04, 0, 0.1, 0),
                            Position = UDim2.new((i-1) * 0.05, 0, 0.9, 0)
                        })
                        tw:Play()
                    end
                end
            end)
        end
    end
    
    local function upProg()
        if progressBar and timeLabel then
            if totalTime > 0 then
                local progress = currentTime / totalTime
                progressBar.Size = UDim2.new(progress, 0, 1, 0)
                timeLabel.Text = fT(currentTime) .. " / " .. fT(totalTime)
            else
                progressBar.Size = UDim2.new(0, 0, 1, 0)
                timeLabel.Text = "00:00 / 00:00"
            end
        end
    end
    
 local function safeListFiles(directory)
    local success, result = pcall(function()
        return listfiles(directory)
    end)

    if not success or type(result) ~= "table" then
        return {}
    end

    local files = {}

    for _, filePath in ipairs(result) do
        if isfile(filePath) then -- Asegurarse de que no es una carpeta
            local filename = filePath:match("([^/\\]+)$")
            if filename then
                local success, asset = pcall(function()
                    return getcustomasset(filePath)
                end)
                if success and asset then
                    files[filename] = {
                        name = filename,
                        path = asset,
                        filename = filename,
                        isLocal = true
                    }
                end
            end
        end
    end

    return files
end

-- Luego podés usarlo así:
local function getLocalFiles()
    return safeListFiles(md, { isLocal = true })
end

local function getCloudFiles()
    return safeListFiles(cd, { isCloud = true, isCached = true })
end
    
    local function playSound(soundPath, trackName, isCloudTrack)
        if not soundPath then
            FW.showAlert("Error", "Invalid sound path!", 3)
            return false
        end
        
        if cm then 
            cm:Stop()
            cm:Destroy()
        end
        
        local snd = Instance.new("Sound")
        snd.SoundId = soundPath
        snd.Volume = cv
        snd.Parent = workspace
        snd.Looped = isLooped
        
        cm = snd
        cp = trackName
        currentPlayingIsCloud = isCloudTrack
        currentTime = 0
        totalTime = snd.TimeLength or 0
        
        updateNowPlaying("♪ " .. trackName, "🎵 Playing", Color3.fromRGB(100, 255, 100))
        
        snd:Play()
        FW.showAlert("Success", "♪ Playing: " .. trackName, 2)
        upML()
        
        if visualizer then 
            stVis(visualizer) 
        end
        
        spawn(function()
            while cm == snd and snd.IsPlaying do
                currentTime = snd.TimePosition
                totalTime = snd.TimeLength
                upProg()
                wait(0.5)
            end
        end)
        
        snd.Ended:Connect(function()
            if cm == snd then
                cm = nil
                cp = nil
                currentTime = 0
                totalTime = 0
                currentPlayingIsCloud = false
                updateNowPlaying("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                upML()
                upProg()
            end
        end)
        
        return true
    end
    
    local function dlCloudFile(song, callback)
        ensDir(cd)
        local pt = cd .. song.filename
        
        if isfile(pt) then
            local success, asset = pcall(function()
                return getcustomasset(pt)
            end)
            if success and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
                return asset
            end
        end
        
        spawn(function()
            downloadProgress[song.filename] = 0
            if callback then callback("downloading", 0) end
            
            local proxyUrl = PROXY_URL .. song.url
            local success, data = pcall(function() 
                return game:HttpGet(proxyUrl) 
            end)
            
            if not success then 
                downloadProgress[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress[song.filename] = 50
            if callback then callback("downloading", 50) end
            
            local writeSuccess = pcall(function()
                writefile(pt, data)
            end)
            
            if not writeSuccess then
                downloadProgress[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress[song.filename] = 100
            
            local success2, asset = pcall(function()
                return getcustomasset(pt)
            end)
            
            if success2 and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
            else
                if callback then callback("error", 0) end
            end
            
            wait(0.5)
            downloadProgress[song.filename] = nil
        end)
        return "downloading"
    end
    
    local function fetchCloudList()
        spawn(function()
            FW.showAlert("Info", "Fetching cloud music list...", 2)
            local success, response = pcall(function() 
                return game:HttpGet(CLOUD_JSON_URL) 
            end)
            
            if success then
                local success2, data = pcall(function() 
                    return hs:JSONDecode(response) 
                end)
                if success2 and data and type(data) == "table" then
                    local cachedFiles = getCloudFiles()
                    cl = {}
                    
                    for _, song in pairs(data) do
                        if song and song.name and song.artist and song.url then
                            local key = song.name .. " - " .. song.artist
                            local filename = song.name:gsub("[^%w%s%-_]", "") .. "_-_" .. song.artist:gsub("[^%w%s%-_]", "") .. ".mp3"
                            
                            cl[key] = {
                                name = key,
                                artist = song.artist,
                                title = song.name,
                                url = song.url,
                                filename = filename,
                                isCloud = true,
                                isCached = cachedFiles[key] ~= nil,
                                path = cachedFiles[key] and cachedFiles[key].path or nil
                            }
                        end
                    end
                    
                    fcl = cl
                    if currentSection == "cloud" then upML() end
                    
                    local count = 0
                    for _ in pairs(data) do count = count + 1 end
                    FW.showAlert("Success", "Cloud music list updated! Found " .. count .. " songs", 2)
                else
                    FW.showAlert("Error", "Failed to parse cloud music list", 3)
                end
            else
                FW.showAlert("Error", "Failed to fetch cloud music list", 3)
            end
        end)
    end
    
    local function refreshLocalFiles()
        ml = getLocalFiles()
        fl = ml
        if currentSection == "local" then upML() end
    end
    
    local function pM(nm, isCloud)
        local musicData = isCloud and cl[nm] or ml[nm]
        if not musicData then
            FW.showAlert("Error", "Music file not found!", 2)
            return
        end
        
        if isCloud and not musicData.path then
            updateNowPlaying("⏳ Downloading: " .. nm, "📥 Downloading", Color3.fromRGB(100, 200, 255))
            
            dlCloudFile(musicData, function(status, progress, assetPath)
                if status == "downloading" then
                    FW.showAlert("Info", "Downloading " .. nm .. " (" .. progress .. "%)", 1)
                    upML()
                elseif status == "complete" then
                    playSound(assetPath, nm, true)
                elseif status == "error" then
                    FW.showAlert("Error", "Failed to download: " .. nm, 3)
                    updateNowPlaying("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                end
            end)
        elseif musicData.path then
            playSound(musicData.path, nm, isCloud)
        else
            FW.showAlert("Error", "Music path not available!", 2)
        end
    end
    
    local function stM()
        if cm then
            cm:Stop()
            cm:Destroy()
            cm = nil
            cp = nil
            currentTime = 0
            totalTime = 0
            currentPlayingIsCloud = false
            updateNowPlaying("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
            upML()
            upProg()
            FW.showAlert("Info", "Music stopped", 1)
        end
    end
    
    local function psM()
        if cm then
            if cm.IsPlaying then
                cm:Pause()
                updateNowPlaying("♪ " .. cp, "⏸ Paused", Color3.fromRGB(255, 200, 100))
                FW.showAlert("Info", "Music paused", 1)
            else
                cm:Resume()
                updateNowPlaying("♪ " .. cp, "🎵 Playing", Color3.fromRGB(100, 255, 100))
                FW.showAlert("Info", "Music resumed", 1)
                if visualizer then 
                    stVis(visualizer) 
                end
            end
        end
    end
    
    local function sV(vol)
        cv = math.max(0, math.min(1, vol))
        if cm then cm.Volume = cv end
    end
    
    local function tgL()
        isLooped = not isLooped
        if cm then cm.Looped = isLooped end
        FW.showAlert("Info", isLooped and "Loop enabled" or "Loop disabled", 1)
    end
    
    local function adM(nm, url)
        if ml[nm] then
            FW.showAlert("Error", "Music already exists!", 2)
            return false
        end
        
        local fn = nm:gsub("[^%w%s%-_]", "") .. ".mp3"
        FW.showAlert("Info", "Downloading: " .. nm, 1)
        
        spawn(function()
            local success, data = pcall(function() 
                return game:HttpGet(url) 
            end)
            if success then
                ensDir(md)
                local writeSuccess = pcall(function()
                    writefile(md .. fn, data)
                end)
                if writeSuccess then
                    refreshLocalFiles()
                    FW.showAlert("Success", "✓ Downloaded: " .. nm, 2)
                else
                    FW.showAlert("Error", "Failed to save: " .. nm, 3)
                end
            else
                FW.showAlert("Error", "Failed to download: " .. nm, 3)
            end
        end)
        
        return true
    end
    
    local function rmM(nm, isCloud)
        if isCloud then
            if cl[nm] then
                if cp == nm then stM() end
                if cl[nm].filename and isfile(cd .. cl[nm].filename) then
                    pcall(function() delfile(cd .. cl[nm].filename) end)
                end
                cl[nm] = nil
                fcl = cl
            end
        else
            if ml[nm] then
                if cp == nm then stM() end
                if ml[nm].filename and isfile(md .. ml[nm].filename) and not ml[nm].isLocal then
                    pcall(function() delfile(md .. ml[nm].filename) end)
                end
                refreshLocalFiles()
            end
        end
        upML()
        FW.showAlert("Success", "Music removed: " .. nm, 2)
    end
    
    local function ftM(qry)
        if currentSection == "local" then
            fl = {}
            if qry == "" then
                for nm, dt in pairs(ml) do 
                    fl[nm] = dt 
                end
            else
                qry = qry:lower()
                for nm, dt in pairs(ml) do
                    if nm:lower():find(qry) then
                        fl[nm] = dt
                    end
                end
            end
        else
            fcl = {}
            if qry == "" then
                for nm, dt in pairs(cl) do 
                    fcl[nm] = dt 
                end
            else
                qry = qry:lower()
                for nm, dt in pairs(cl) do
                    if nm:lower():find(qry) or (dt.artist and dt.artist:lower():find(qry)) or (dt.title and dt.title:lower():find(qry)) then
                        fcl[nm] = dt
                    end
                end
            end
        end
        upML()
    end
    
    local function switchSection(section)
        currentSection = section
        if section == "local" then
            localBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
            cloudBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            af.Visible = true
            rfb.Text = "📁 SCAN"
            scb.Text = "📁 SCAN"
        else
            localBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            cloudBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
            af.Visible = false
            rfb.Text = "🔄 REFRESH"
            scb.Text = "🔄 REFRESH"
        end
        upML()
    end
    
    function upML()
        local currentList = currentSection == "local" and fl or fcl
        local scrollFrame = currentSection == "local" and sr or csr
        
        if scrollFrame then
            local children = scrollFrame:GetChildren()
            for i = 1, #children do
                local child = children[i]
                if child:IsA("Frame") and child.Name:find("MusicCard") then
                    child:Destroy()
                end
            end
            
            local yp = 0
            local idx = 0
            local sortedMusic = {}
            
            for nm, dt in pairs(currentList) do
                table.insert(sortedMusic, {name = nm, data = dt})
            end
            
            for i = 1, #sortedMusic do
                local entry = sortedMusic[i]
                local nm = entry.name
                local dt = entry.data
                idx = idx + 1
                
                local mc = FW.cF(scrollFrame, {
                    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                    Size = UDim2.new(1, -20, 0, 80),
                    Position = UDim2.new(0, 10, 0, yp),
                    Name = "MusicCard_" .. idx
                })
                FW.cC(mc, 0.15)
                FW.cS(mc, 1, Color3.fromRGB(35, 39, 54))
                
                if cp == nm then
                    FW.cG(mc, Color3.fromRGB(50, 130, 210), Color3.fromRGB(30, 80, 150))
                    local glow = FW.cF(mc, {
                        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
                        BackgroundTransparency = 0.8,
                        Size = UDim2.new(1, 4, 1, 4),
                        Position = UDim2.new(0, -2, 0, -2),
                        ZIndex = -1,
                        Name = "Glow"
                    })
                    FW.cC(glow, 0.15)
                end
                
                local ico = FW.cF(mc, {
                    BackgroundColor3 = Color3.fromRGB(166, 190, 255),
                    Size = UDim2.new(0, 60, 0, 60),
                    Position = UDim2.new(0, 10, 0, 10),
                    Name = "MusicIcon"
                })
                FW.cC(ico, 0.3)
                FW.cG(ico, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
                
                cUI(ico, "text", {
                    Text = cp == nm and (cm and cm.IsPlaying and "♪" or "⏸") or (currentSection == "cloud" and "☁" or "♫"),
                    TextSize = cp == nm and 28 or 24,
                    TextColor3 = Color3.fromRGB(29, 29, 38),
                    Name = "MusicEmoji"
                })
                
                cUI(mc, "text", {
                    Text = nm,
                    TextSize = 16,
                    Size = UDim2.new(0.35, 0, 0.4, 0),
                    Position = UDim2.new(0, 80, 0, 5),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "MusicTitle"
                })
                
                local statusText = ""
                if currentSection == "cloud" then
                    statusText = dt.isCached and "☁ Cached" or "☁ Cloud"
                else
                    statusText = dt.isLocal and "📁 Local File" or "🌐 Downloaded"
                end
                
                cUI(mc, "text", {
                    Text = statusText,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(160, 170, 190),
                    Size = UDim2.new(0.35, 0, 0.3, 0),
                    Position = UDim2.new(0, 80, 0, 35),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "MusicStatus"
                })
                
                if downloadProgress[dt.filename] then
                    local prog = downloadProgress[dt.filename]
                    cUI(mc, "text", {
                        Text = "Downloading... " .. prog .. "%",
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(100, 200, 255),
                        Size = UDim2.new(0.35, 0, 0.3, 0),
                        Position = UDim2.new(0, 80, 0, 50),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "DownloadProgress"
                    })
                end
                
                local pb, po = cUI(mc, "button", {
                    BackgroundColor3 = cp == nm and (cm and cm.IsPlaying and Color3.fromRGB(255, 150, 100) or Color3.fromRGB(100, 200, 100)) or Color3.fromRGB(50, 170, 90),
                    Size = UDim2.new(0, 70, 0, 30),
                    Position = UDim2.new(1, -240, 0, 10),
                    Text = cp == nm and (cm and cm.IsPlaying and "PAUSE" or "RESUME") or "PLAY",
                    TextSize = 11,
                    Name = "PlayBtn"
                })
                
                local stb, sto = cUI(mc, "button", {
                    BackgroundColor3 = Color3.fromRGB(100, 100, 200),
                    Size = UDim2.new(0, 70, 0, 30),
                    Position = UDim2.new(1, -160, 0, 10),
                    Text = "STOP",
                    TextSize = 11,
                    Name = "StopBtn"
                })
                
                local rb, ro = cUI(mc, "button", {
                    BackgroundColor3 = Color3.fromRGB(200, 100, 100),
                    Size = UDim2.new(0, 70, 0, 30),
                    Position = UDim2.new(1, -80, 0, 10),
                    Text = "REMOVE",
                    TextSize = 11,
                    Name = "RemoveBtn"
                })
                
                local lb, lo = cUI(mc, "button", {
                    BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 150, 200),
                    Size = UDim2.new(0, 70, 0, 30),
                    Position = UDim2.new(1, -240, 0, 45),
                    Text = isLooped and "LOOP ON" or "LOOP OFF",
                    TextSize = 10,
                    Name = "LoopBtn"
                })
                
                pb.MouseButton1Click:Connect(function()
                    if cp == nm then 
                        psM() 
                    else 
                        pM(nm, currentSection == "cloud") 
                    end
                end)
                
                stb.MouseButton1Click:Connect(function()
                    if cp == nm then stM() end
                end)
                
                rb.MouseButton1Click:Connect(function() 
                    rmM(nm, currentSection == "cloud") 
                end)
                
                lb.MouseButton1Click:Connect(function()
                    tgL()
                    upML()
                end)
                
                yp = yp + 90
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yp)
        end
    end
    
    vb.MouseButton1Down:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local connection
        connection = mouse.Button1Up:Connect(function()
            connection:Disconnect()
        end)
        
        local moveConnection
        moveConnection = mouse.Move:Connect(function()
            if connection.Connected then
                local relativeX = math.max(0, math.min(1, (mouse.X - vs.AbsolutePosition.X) / vs.AbsoluteSize.X))
                vh.Size = UDim2.new(relativeX, 0, 1, 0)
                sV(relativeX)
                
                local vl = vcf:FindFirstChild("VolumeLabel")
                if vl then vl.Text = "🔊 Volume: " .. math.floor(cv * 100) .. "%" end
            else
                moveConnection:Disconnect()
            end
        end)
    end)
    
    localBtn.MouseButton1Click:Connect(function()
        switchSection("local")
        sr.Visible = true
        csr.Visible = false
    end)
    
    cloudBtn.MouseButton1Click:Connect(function()
        switchSection("cloud")
        sr.Visible = false
        csr.Visible = true
    end)
    
    plb.MouseButton1Click:Connect(function()
        if cp then psM() else FW.showAlert("Info", "No music selected!", 2) end
    end)
    
    stb.MouseButton1Click:Connect(function() stM() end)
    
    shb.MouseButton1Click:Connect(function()
        local currentList = currentSection == "local" and ml or cl
        local mks = {}
        for nm, _ in pairs(currentList) do 
            table.insert(mks, nm) 
        end
        if #mks > 0 then
            local rnd = mks[math.random(1, #mks)]
            pM(rnd, currentSection == "cloud")
        else
            FW.showAlert("Info", "No music available!", 2)
        end
    end)
    
    rfb.MouseButton1Click:Connect(function() 
        if currentSection == "local" then
            refreshLocalFiles()
        else
            fetchCloudList()
        end
    end)
    
    lpb.MouseButton1Click:Connect(function()
        tgL()
        lpb.BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 100, 150)
        lpb.Text = isLooped and "🔁 LOOP ON" or "🔁 LOOP OFF"
    end)
    
    scb.MouseButton1Click:Connect(function() 
        if currentSection == "local" then
            refreshLocalFiles()
        else
            fetchCloudList()
        end
    end)
    
    ab.MouseButton1Click:Connect(function()
        local nm = ni.Text
        local url = ui.Text
        if nm ~= "" and url ~= "" then
            adM(nm, url)
            ni.Text = ""
            ui.Text = ""
        else
            FW.showAlert("Error", "Please enter name and URL!", 2)
        end
    end)
    
    sf.Changed:Connect(function(prop)
        if prop == "Text" then ftM(sf.Text) end
    end)
    
    local sb = FW.getUI()["6"]:FindFirstChild("Sidebar")
    if sb then
        local function cSBtn(nm, txt, ico, pos, sel)
            local btn = FW.cF(sb, {
                BackgroundColor3 = sel and Color3.fromRGB(30, 36, 51) or Color3.fromRGB(31, 34, 50),
                Size = UDim2.new(0.68, 0, 0.064, 0),
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
                TextSize = 16,
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
            FW.cTC(lbl, 16)
            
            local clk = FW.cB(btn, {
                TextWrapped = true,
                TextColor3 = Color3.fromRGB(0, 0, 0),
                TextSize = 12,
                TextScaled = true,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 1, 0),
                Name = "Clk",
                Text = "  ",
                ZIndex = 5
            })
            FW.cC(clk, 0)
            FW.cTC(clk, 12)
            
            return btn, clk
        end
        
        local mb, mc = cSBtn("Music", "Music", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.52, 0), false)
        mc.MouseButton1Click:Connect(function()
            FW.switchPage("Music", FW.getUI()["6"]:FindFirstChild("Sidebar"))
        end)
    end
    
    ml = getLocalFiles()
    fl = ml
    cl = {}
    fcl = cl
    upML()
    updateNowPlaying("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
    upProg()
    
    spawn(function()
        wait(3)
        fetchCloudList()
        FW.showAlert("Success", "🎵 Music system with Cloud support loaded!", 2)
    end)
end)
