local hs3 = game:GetService("HttpService")
local ts3 = game:GetService("TweenService")
local rs3 = game:GetService("RunService")

local md3 = "FrostWare/Music/"
local cd3 = "FrostWare/cloud_cache/"
local CLOUD_TXT_URL = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Music.txt"
local PROXY_URL = "https://music.brunomatiastoledo2000.workers.dev/"
local sf3 = {".mp3", ".ogg", ".wav", ".m4a", ".flac"}

local cp3, cv3, cm3 = nil, 0.5, nil
local ml3, cl3, fl3, fcl3 = {}, {}, {}, {}
local sr3, csr3 = nil, nil
local isLooped3, currentTime3, totalTime3 = false, 0, 0
local progressBar3, timeLabel3, visualizer3 = nil, nil, nil
local downloadProgress3 = {}
local currentSection3 = "local"
local currentPlayingIsCloud3 = false
local availableGenres3 = {}
local availableUploaders3 = {}
local currentGenreFilter3 = ""
local currentUploaderFilter3 = ""
local searchInput3 = nil

fw.addTab("Music", "Music", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.52, 0), fw.cscp)

local pagesContainer = fw.gu()["11"]
local musicPageFrame = pagesContainer:FindFirstChild("MusicPage")

if musicPageFrame then
    local function ensDir3(dir)
        if not isfolder(dir) then makefolder(dir) end
    end

    local function fT3(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    local function updateNowPlaying3(trackName, status, statusColor)
        local cpt = musicPageFrame:FindFirstChild("CurrentTrack")
        local cps = musicPageFrame:FindFirstChild("PlayStatus")
        if cpt then cpt.Text = trackName or "No music selected" end
        if cps then
            cps.Text = status or "⏹ Stopped"
            cps.TextColor3 = statusColor or Color3.fromRGB(200, 200, 200)
        end
    end

    local function stVis3(bars)
        if bars and type(bars) == "table" then
            spawn(function()
                while cm3 and cm3.IsPlaying do
                    for i, bar in pairs(bars) do
                        if bar and bar.Parent then
                            local height = math.random(10, 80) / 100
                            local tw = ts3:Create(bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
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
                        local tw = ts3:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(0.04, 0, 0.1, 0),
                            Position = UDim2.new((i-1) * 0.05, 0, 0.9, 0)
                        })
                        tw:Play()
                    end
                end
            end)
        end
    end

    local function upProg3()
        if progressBar3 and timeLabel3 then
            if totalTime3 > 0 then
                local progress = currentTime3 / totalTime3
                progressBar3.Size = UDim2.new(progress, 0, 1, 0)
                timeLabel3.Text = fT3(currentTime3) .. " / " .. fT3(totalTime3)
            else
                progressBar3.Size = UDim2.new(0, 0, 1, 0)
                timeLabel3.Text = "00:00 / 00:00"
            end
        end
    end

    local function safeListFiles3(directory)
        local success, result = pcall(function() return listfiles(directory) end)
        if not success or type(result) ~= "table" then return {} end
        
        local files = {}
        for _, filePath in ipairs(result) do
            if isfile(filePath) then
                local filename = filePath:match("([^/\\]+)$")
                if filename then
                    local success2, asset = pcall(function() return getcustomasset(filePath) end)
                    if success2 and asset then
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

    local function getLocalFiles3() return safeListFiles3(md3) end
    local function getCloudFiles3() return safeListFiles3(cd3) end

    local function updateGenresAndUploaders3()
        availableGenres3 = {}
        availableUploaders3 = {}
        
        for _, song in pairs(cl3) do
            if song.genre and song.genre ~= "" and song.genre ~= "Unknown" then
                local found = false
                for _, g in pairs(availableGenres3) do
                    if g:lower() == song.genre:lower() then found = true; break end
                end
                if not found then table.insert(availableGenres3, song.genre) end
            end
            
            if song.uploader_name and song.uploader_name ~= "" and song.uploader_name ~= "Unknown" then
                local found = false
                for _, u in pairs(availableUploaders3) do
                    if u:lower() == song.uploader_name:lower() then found = true; break end
                end
                if not found then table.insert(availableUploaders3, song.uploader_name) end
            end
        end
        
        table.sort(availableGenres3, function(a, b) return a:lower() < b:lower() end)
        table.sort(availableUploaders3, function(a, b) return a:lower() < b:lower() end)
    end

    local function ftM3(qry)
        if currentSection3 == "local" then
            fl3 = {}
            if qry == "" then
                for nm, dt in pairs(ml3) do fl3[nm] = dt end
            else
                qry = qry:lower()
                for nm, dt in pairs(ml3) do
                    if nm:lower():find(qry) then fl3[nm] = dt end
                end
            end
        else
            fcl3 = {}
            local searchQuery = qry:lower()
            for nm, dt in pairs(cl3) do
                local matchesSearch = qry == "" or nm:lower():find(searchQuery) or
                                   (dt.title and dt.title:lower():find(searchQuery))
                local matchesGenre = currentGenreFilter3 == "" or 
                                   (dt.genre and dt.genre:lower() == currentGenreFilter3:lower())
                local matchesUploader = currentUploaderFilter3 == "" or 
                                      (dt.uploader_name and dt.uploader_name:lower() == currentUploaderFilter3:lower())
                
                if matchesSearch and matchesGenre and matchesUploader then
                    fcl3[nm] = dt
                end
            end
        end
        upML3()
    end

    local function playSound3(soundPath, trackName, isCloudTrack)
        if not soundPath then
            fw.sa("Error", "Invalid sound path!", 3)
            return false
        end
        
        if cm3 then
            cm3:Stop()
            cm3:Destroy()
        end
        
        local snd = Instance.new("Sound")
        snd.SoundId = soundPath
        snd.Volume = cv3
        snd.Parent = workspace
        snd.Looped = isLooped3
        
        cm3 = snd
        cp3 = trackName
        currentPlayingIsCloud3 = isCloudTrack
        currentTime3 = 0
        totalTime3 = snd.TimeLength or 0
        
        updateNowPlaying3("♪ " .. trackName, "🎵 Playing", Color3.fromRGB(100, 255, 100))
        snd:Play()
        fw.sa("Success", "♪ Playing: " .. trackName, 2)
        upML3()
        
        if visualizer3 then stVis3(visualizer3) end
        
        spawn(function()
            while cm3 == snd and snd.IsPlaying do
                currentTime3 = snd.TimePosition
                totalTime3 = snd.TimeLength
                upProg3()
                wait(0.5)
            end
        end)
        
        snd.Ended:Connect(function()
            if cm3 == snd then
                cm3 = nil
                cp3 = nil
                currentTime3 = 0
                totalTime3 = 0
                currentPlayingIsCloud3 = false
                updateNowPlaying3("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                upML3()
                upProg3()
            end
        end)
        
        return true
    end

    local function dlCloudFile3(song, callback)
        ensDir3(cd3)
        local pt = cd3 .. song.filename
        
        if isfile(pt) then
            local success, asset = pcall(function() return getcustomasset(pt) end)
            if success and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
                return asset
            end
        end
        
        spawn(function()
            downloadProgress3[song.filename] = 0
            if callback then callback("downloading", 0) end
            
            local proxyUrl = PROXY_URL .. song.url
            local success, data = pcall(function() return game:HttpGet(proxyUrl) end)
            
            if not success then
                downloadProgress3[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress3[song.filename] = 50
            if callback then callback("downloading", 50) end
            
            local writeSuccess = pcall(function() writefile(pt, data) end)
            if not writeSuccess then
                downloadProgress3[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress3[song.filename] = 100
            local success2, asset = pcall(function() return getcustomasset(pt) end)
            
            if success2 and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
            else
                if callback then callback("error", 0) end
            end
            
            wait(0.5)
            downloadProgress3[song.filename] = nil
        end)
        
        return "downloading"
    end

    local function fetchCloudList3()
        spawn(function()
            fw.sa("Info", "Fetching cloud music list...", 2)
            local success, response = pcall(function() return game:HttpGet(CLOUD_TXT_URL) end)
            
            if success then
                local lines = {}
                for line in response:gmatch("([^\n]+)") do table.insert(lines, line) end
                
                local cachedFiles = getCloudFiles3()
                cl3 = {}
                
                for _, line in ipairs(lines) do
                    local parts = {}
                    for part in line:gmatch("([^|]+)") do
                        table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
                    end
                    
                    if #parts >= 2 then
                        local url = parts[1]
                        local name = parts[2]
                        local genre = parts[3] or "Unknown"
                        local uploader_name = parts[4] or "Unknown"
                        local key = name
                        local filename = name:gsub("[^%w%s%-_]", "") .. ".mp3"
                        
                        cl3[key] = {
                            name = key,
                            title = name,
                            url = url,
                            filename = filename,
                            genre = genre,
                            uploader_name = uploader_name,
                            isCloud = true,
                            isCached = cachedFiles[key] ~= nil,
                            path = cachedFiles[key] and cachedFiles[key].path or nil
                        }
                    end
                end
                
                fcl3 = cl3
                updateGenresAndUploaders3()
                if currentSection3 == "cloud" then upML3() end
                
                local count = 0
                for _ in pairs(cl3) do count = count + 1 end
                fw.sa("Success", "Cloud music list updated! Found " .. count .. " songs", 2)
            else
                fw.sa("Error", "Failed to fetch cloud music list", 3)
            end
        end)
    end

    local function pM3(nm, isCloud)
        local musicData = isCloud and cl3[nm] or ml3[nm]
        if not musicData then
            fw.sa("Error", "Music file not found!", 2)
            return
        end
        
        if isCloud and not musicData.path then
            updateNowPlaying3("⏳ Downloading: " .. nm, "📥 Downloading", Color3.fromRGB(100, 200, 255))
            dlCloudFile3(musicData, function(status, progress, assetPath)
                if status == "downloading" then
                    fw.sa("Info", "Downloading " .. nm .. " (" .. progress .. "%)", 1)
                    upML3()
                elseif status == "complete" then
                    playSound3(assetPath, nm, true)
                elseif status == "error" then
                    fw.sa("Error", "Failed to download: " .. nm, 3)
                    updateNowPlaying3("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                end
            end)
        elseif musicData.path then
            playSound3(musicData.path, nm, isCloud)
        else
            fw.sa("Error", "Music path not available!", 2)
        end
    end

    local function stM3()
        if cm3 then
            cm3:Stop()
            cm3:Destroy()
            cm3 = nil
            cp3 = nil
            currentTime3 = 0
            totalTime3 = 0
            currentPlayingIsCloud3 = false
            updateNowPlaying3("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
            upML3()
            upProg3()
            fw.sa("Info", "Music stopped", 1)
        end
    end

    local function psM3()
        if cm3 then
            if cm3.IsPlaying then
                cm3:Pause()
                updateNowPlaying3("♪ " .. cp3, "⏸ Paused", Color3.fromRGB(255, 200, 100))
                fw.sa("Info", "Music paused", 1)
            else
                cm3:Resume()
                updateNowPlaying3("♪ " .. cp3, "🎵 Playing", Color3.fromRGB(100, 255, 100))
                fw.sa("Info", "Music resumed", 1)
                if visualizer3 then stVis3(visualizer3) end
            end
        end
    end

    local function sV3(vol)
        cv3 = math.max(0, math.min(1, vol))
        if cm3 then cm3.Volume = cv3 end
    end

    local function tgL3()
        isLooped3 = not isLooped3
        if cm3 then cm3.Looped = isLooped3 end
        fw.sa("Info", isLooped3 and "Loop enabled" or "Loop disabled", 1)
    end

    local function adM3(nm, url)
        if ml3[nm] then
            fw.sa("Error", "Music already exists!", 2)
            return false
        end
        local fn = nm:gsub("[^%w%s%-_]", "") .. ".mp3"
        fw.sa("Info", "Downloading: " .. nm, 1)
        spawn(function()
            local success, data = pcall(function() return game:HttpGet(url) end)
            if success then
                ensDir3(md3)
                local writeSuccess = pcall(function() writefile(md3 .. fn, data) end)
                if writeSuccess then
                    ml3 = getLocalFiles3()
                    fl3 = ml3
                    upML3()
                    fw.sa("Success", "✓ Downloaded: " .. nm, 2)
                else
                    fw.sa("Error", "Failed to save: " .. nm, 3)
                end
            else
                fw.sa("Error", "Failed to download: " .. nm, 3)
            end
        end)
        return true
    end

    local function rmM3(nm, isCloud)
        if isCloud then
            if cl3[nm] then
                if cp3 == nm then stM3() end
                if cl3[nm].filename and isfile(cd3 .. cl3[nm].filename) then
                    pcall(function() delfile(cd3 .. cl3[nm].filename) end)
                end
                cl3[nm] = nil
                fcl3 = cl3
            end
        else
            if ml3[nm] then
                if cp3 == nm then stM3() end
                if ml3[nm].filename and isfile(md3 .. ml3[nm].filename) and not ml3[nm].isLocal then
                    pcall(function() delfile(md3 .. ml3[nm].filename) end)
                end
                ml3 = getLocalFiles3()
                fl3 = ml3
            end
        end
        upML3()
        fw.sa("Success", "Music removed: " .. nm, 2)
    end

    local function switchSection3(section)
        currentSection3 = section
        if section == "local" then
            localBtn3.BackgroundColor3 = Color3.fromRGB(50,130,210)
            cloudBtn3.BackgroundColor3 = Color3.fromRGB(100,100,150)
            ni3.Visible = true
            nio3.Visible = true
            ui3.Visible = true
            uio3.Visible = true
            ab3.Visible = true
            abo3.Visible = true
            sf3.Visible = false
            sfo3.Visible = false
            gdf3.Visible = false
            udf3.Visible = false
            gdl3.Visible = false
            udl3.Visible = false
            rfb3.Text = "📁 SCAN"
            scb3.Text = "📁 SCAN"
        else
            localBtn3.BackgroundColor3 = Color3.fromRGB(100,100,150)
            cloudBtn3.BackgroundColor3 = Color3.fromRGB(50,130,210)
            ni3.Visible = false
            nio3.Visible = false
            ui3.Visible = false
            uio3.Visible = false
            ab3.Visible = false
            abo3.Visible = false
            sf3.Visible = true
            sfo3.Visible = true
            gdf3.Visible = true
            udf3.Visible = true
            rfb3.Text = "🔄 REFRESH"
            scb3.Text = "🔄 REFRESH"
        end
        ftM3(searchInput3 and searchInput3.Text or "")
    end

    function upML3()
        local currentList = currentSection3 == "local" and fl3 or fcl3
        local scrollFrame = currentSection3 == "local" and sr3 or csr3
        
        sr3.Visible = currentSection3 == "local"
        csr3.Visible = currentSection3 == "cloud"
        
        if scrollFrame then
            for _, child in pairs(scrollFrame:GetChildren()) do
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
            table.sort(sortedMusic, function(a, b) return a.name:lower() < b.name:lower() end)
            
            for _, entry in pairs(sortedMusic) do
                local nm = entry.name
                local dt = entry.data
                idx = idx + 1
                
                local mc = nf(scrollFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.98,0,0,75), p=UDim2.new(0.01,0,0,yp), n="MusicCard_"..idx})
                nc(mc, 0.15)
                
                if cp3 == nm then
                    mc.BackgroundColor3 = Color3.fromRGB(50,130,210)
                end
                
                local ico = nf(mc, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,55,0,55), p=UDim2.new(0,10,0,10), n="MusicIcon"})
                nc(ico, 0.3)
                
                local iconText = cp3 == nm and (cm3 and cm3.IsPlaying and "♪" or "⏸") or (currentSection3 == "cloud" and "☁" or "♫")
                nt(ico, {t=iconText, ts=cp3 == nm and 22 or 20, tc=Color3.fromRGB(29,29,38), n="MusicEmoji"})
                
                nt(mc, {t=nm, ts=15, s=UDim2.new(0.35,0,0.35,0), p=UDim2.new(0,75,0,2), xa=Enum.TextXAlignment.Left, n="MusicTitle"})
                
                local statusText = ""
                local infoText = ""
                if currentSection3 == "cloud" then
                    statusText = dt.isCached and "☁ Cached" or "☁ Cloud"
                    if dt.genre and dt.genre ~= "Unknown" then
                        infoText = "🎵 " .. dt.genre
                    end
                    if dt.uploader_name and dt.uploader_name ~= "Unknown" then
                        infoText = infoText .. (infoText ~= "" and " | " or "") .. "👤 " .. dt.uploader_name
                    end
                else
                    statusText = dt.isLocal and "📁 Local File" or "🌐 Downloaded"
                end
                
                nt(mc, {t=statusText, ts=12, tc=Color3.fromRGB(160,170,190), s=UDim2.new(0.35,0,0.25,0), p=UDim2.new(0,75,0,28), xa=Enum.TextXAlignment.Left, n="MusicStatus"})
                
                if infoText ~= "" then
                    nt(mc, {t=infoText, ts=11, tc=Color3.fromRGB(140,150,170), s=UDim2.new(0.35,0,0.25,0), p=UDim2.new(0,75,0,50), xa=Enum.TextXAlignment.Left, n="MusicInfo"})
                end
                
                if downloadProgress3[dt.filename] then
                    local prog = downloadProgress3[dt.filename]
                    nt(mc, {t="Downloading... " .. prog .. "%", ts=12, tc=Color3.fromRGB(100,200,255), s=UDim2.new(0.35,0,0.25,0), p=UDim2.new(0,75,0,65), xa=Enum.TextXAlignment.Left, n="DownloadProgress"})
                end
                
                local pb = nb(mc, {c=cp3 == nm and (cm3 and cm3.IsPlaying and Color3.fromRGB(255,150,100) or Color3.fromRGB(100,200,100)) or Color3.fromRGB(50,170,90), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.1,0), t=cp3 == nm and (cm3 and cm3.IsPlaying and "PAUSE" or "RESUME") or "PLAY", tc=Color3.fromRGB(255,255,255), ts=11, n="PlayBtn"})
                nc(pb, 0.15)
                
                local stb = nb(mc, {c=Color3.fromRGB(100,100,200), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.55,0), t="STOP", tc=Color3.fromRGB(255,255,255), ts=11, n="StopBtn"})
                nc(stb, 0.15)
                
                local rb = nb(mc, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.11,0,0.4,0), p=UDim2.new(0.77,0,0.1,0), t="REMOVE", tc=Color3.fromRGB(255,255,255), ts=10, n="RemoveBtn"})
                nc(rb, 0.15)
                
                local lb = nb(mc, {c=isLooped3 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,150,200), s=UDim2.new(0.11,0,0.4,0), p=UDim2.new(0.77,0,0.55,0), t=isLooped3 and "LOOP ON" or "LOOP OFF", tc=Color3.fromRGB(255,255,255), ts=10, n="LoopBtn"})
                nc(lb, 0.15)
                
                pb.MouseButton1Click:Connect(function()
                    if cp3 == nm then psM3() else pM3(nm, currentSection3 == "cloud") end
                end)
                
                stb.MouseButton1Click:Connect(function()
                    if cp3 == nm then stM3() end
                end)
                
                rb.MouseButton1Click:Connect(function()
                    rmM3(nm, currentSection3 == "cloud")
                end)
                
                lb.MouseButton1Click:Connect(function()
                    tgL3()
                    upML3()
                end)
                
                yp = yp + 80
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yp)
        end
    end

    local tb3 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.18,0), p=UDim2.new(0.025,0,0.02,0), n="TopBar"})
    nc(tb3, 0.18)

    local cpf3 = nf(tb3, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.01,0,0.075,0), n="CurrentlyPlaying"})
    nc(cpf3, 0.15)

    nt(cpf3, {t="🎵 Now Playing", ts=15, tc=Color3.fromRGB(166,190,255), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0,0), n="CPLabel"})
    nt(cpf3, {t="No music selected", ts=17, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,0.35,0), p=UDim2.new(0,0,0.25,0), n="CurrentTrack"})
    nt(cpf3, {t="⏹ Stopped", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0.6,0), n="PlayStatus"})

    local vf3 = nf(cpf3, {bt=1, s=UDim2.new(1,0,0.15,0), p=UDim2.new(0,0,0.85,0), n="Visualizer"})
    local vbars3 = {}
    for i = 1, 20 do
        local bar = nf(vf3, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0.04,0,0.1,0), p=UDim2.new((i-1)*0.05,0,0.9,0), n="Bar"..i})
        nc(bar, 0.1)
        vbars3[i] = bar
    end
    visualizer3 = vbars3

    local vcf3 = nf(tb3, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.34,0,0.075,0), n="VolumeControl"})
    nc(vcf3, 0.15)

    nt(vcf3, {t="🔊 Volume: " .. math.floor(cv3 * 100) .. "%", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.3,0), p=UDim2.new(0,0,0,0), n="VolumeLabel"})

    local vs3, vh3, vb3 = cUI(vcf3, "slider", {
        Size = UDim2.new(0.9, 0, 0.2, 0),
        Position = UDim2.new(0.05, 0, 0.35, 0),
        Value = cv3,
        Name = "VolumeSlider"
    })

    local pf3 = nf(vcf3, {c=Color3.fromRGB(30,35,45), s=UDim2.new(0.9,0,0.15,0), p=UDim2.new(0.05,0,0.6,0), n="ProgressFrame"})
    nc(pf3, 0.1)
    progressBar3 = nf(pf3, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,0,1,0), p=UDim2.new(0,0,0,0), n="ProgressBar"})
    nc(progressBar3, 0.1)

    timeLabel3 = nt(vcf3, {t="00:00 / 00:00", ts=11, tc=Color3.fromRGB(180,180,180), s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.8,0), n="TimeLabel"})

    local cf3 = nf(tb3, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.67,0,0.075,0), n="Controls"})
    nc(cf3, 0.15)

    local plb3 = nb(cf3, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.02,0,0.1,0), t="▶", tc=Color3.fromRGB(255,255,255), ts=15, n="PlayPauseBtn"})
    nc(plb3, 0.15)

    local stb3 = nb(cf3, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.26,0,0.1,0), t="■", tc=Color3.fromRGB(255,255,255), ts=15, n="StopBtn"})
    nc(stb3, 0.15)

    local shb3 = nb(cf3, {c=Color3.fromRGB(100,150,200), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.5,0,0.1,0), t="🔀", tc=Color3.fromRGB(255,255,255), ts=13, n="ShuffleBtn"})
    nc(shb3, 0.15)

    local rfb3 = nb(cf3, {c=Color3.fromRGB(150,100,200), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.74,0,0.1,0), t="🔄", tc=Color3.fromRGB(255,255,255), ts=13, n="RefreshBtn"})
    nc(rfb3, 0.15)

    local lpb3 = nb(cf3, {c=isLooped3 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,100,150), s=UDim2.new(0.47,0,0.4,0), p=UDim2.new(0.02,0,0.55,0), t=isLooped3 and "🔁 LOOP ON" or "🔁 LOOP OFF", tc=Color3.fromRGB(255,255,255), ts=11, n="LoopBtn"})
    nc(lpb3, 0.15)

    local scb3 = nb(cf3, {c=Color3.fromRGB(200,150,100), s=UDim2.new(0.47,0,0.4,0), p=UDim2.new(0.51,0,0.55,0), t="📁 SCAN", tc=Color3.fromRGB(255,255,255), ts=11, n="ScanBtn"})
    nc(scb3, 0.15)

    local sectf3 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.08,0), p=UDim2.new(0.025,0,0.21,0), n="SectionFrame"})
    nc(sectf3, 0.18)

    local localBtn3 = nb(sectf3, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.02,0,0.15,0), t="📁 LOCAL", tc=Color3.fromRGB(255,255,255), ts=12, n="LocalBtn"})
    nc(localBtn3, 0.15)

    local cloudBtn3 = nb(sectf3, {c=Color3.fromRGB(100,100,150), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.24,0,0.15,0), t="☁ CLOUD", tc=Color3.fromRGB(255,255,255), ts=12, n="CloudBtn"})
    nc(cloudBtn3, 0.15)

    local af3 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.09,0), p=UDim2.new(0.025,0,0.3,0), n="UnifiedInputFrame"})
    nc(af3, 0.18)

    local nio3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.25,0,0.6,0), p=UDim2.new(0.02,0,0.2,0), n="NameInput_Outer"})
    nc(nio3, 0.18)

    local ni3 = ntb(nio3, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=13, tc=Color3.fromRGB(240,245,255), n="NameInput"})
    nc(ni3, 0.15)

    local uio3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.5,0,0.6,0), p=UDim2.new(0.29,0,0.2,0), n="UrlInput_Outer"})
    nc(uio3, 0.18)

    local ui3 = ntb(uio3, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=13, tc=Color3.fromRGB(240,245,255), n="UrlInput"})
    nc(ui3, 0.15)

    local abo3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.17,0,0.6,0), p=UDim2.new(0.81,0,0.2,0), n="AddBtn_Outer"})
    nc(abo3, 0.18)

    local ab3 = nb(abo3, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), t="📥 ADD", tc=Color3.fromRGB(255,255,255), ts=12, n="AddBtn"})
    nc(ab3, 0.15)

    local sfo3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.3,0,0.6,0), p=UDim2.new(0.02,0,0.2,0), n="SearchInput_Outer", v=false})
    nc(sfo3, 0.18)

    local sf3 = ntb(sfo3, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=12, tc=Color3.fromRGB(240,245,255), n="SearchInput"})
    nc(sf3, 0.15)
    searchInput3 = sf3

    local gdf3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.34,0,0.2,0), n="GenreDropdown_Frame", v=false})
    nc(gdf3, 0.18)

    local gdb3 = nb(gdf3, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), t="🎵 All Genres", tc=Color3.fromRGB(240,245,255), ts=11, n="GenreDropdown"})
    nc(gdb3, 0.15)

    local gdl3 = nsf(af3, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0,200,0,150), p=UDim2.new(0,0,0,0), sb=6, cs=UDim2.new(0,0,0,0), v=false, n="GenreDropdown_List"})
    nc(gdl3, 0.15)

    local udf3 = nf(af3, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.56,0,0.2,0), n="UploaderDropdown_Frame", v=false})
    nc(udf3, 0.18)

    local udb3 = nb(udf3, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), t="👤 All Users", tc=Color3.fromRGB(240,245,255), ts=11, n="UploaderDropdown"})
    nc(udb3, 0.15)

    local udl3 = nsf(af3, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0,200,0,150), p=UDim2.new(0,0,0,0), sb=6, cs=UDim2.new(0,0,0,0), v=false, n="UploaderDropdown_List"})
    nc(udl3, 0.15)

    local mlf3 = nf(musicPageFrame, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.95,0,0.58,0), p=UDim2.new(0.025,0,0.4,0), n="MusicListFrame"})
    nc(mlf3, 0.18)

    sr3 = nsf(mlf3, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="MusicListScroll", sic=Color3.fromRGB(50,130,210), v=true})
    csr3 = nsf(mlf3, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="CloudMusicListScroll", sic=Color3.fromRGB(50,130,210), v=false})

    vb3.MouseButton1Down:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local connection
        connection = mouse.Button1Up:Connect(function() connection:Disconnect() end)
        local moveConnection
        moveConnection = mouse.Move:Connect(function()
            if connection.Connected then
                local relativeX = math.max(0, math.min(1, (mouse.X - vs3.AbsolutePosition.X) / vs3.AbsoluteSize.X))
                vh3.Size = UDim2.new(relativeX, 0, 1, 0)
                sV3(relativeX)
                local vl = vcf3:FindFirstChild("VolumeLabel")
                if vl then vl.Text = "🔊 Volume: " .. math.floor(cv3 * 100) .. "%" end
            else
                moveConnection:Disconnect()
            end
        end)
    end)

    localBtn3.MouseButton1Click:Connect(function() switchSection3("local") end)
    cloudBtn3.MouseButton1Click:Connect(function() switchSection3("cloud") end)

    plb3.MouseButton1Click:Connect(function()
        if cp3 then psM3() else fw.sa("Info", "No music selected!", 2) end
    end)

    stb3.MouseButton1Click:Connect(function() stM3() end)

    shb3.MouseButton1Click:Connect(function()
        local currentList = currentSection3 == "local" and ml3 or cl3
        local mks = {}
        for nm, _ in pairs(currentList) do table.insert(mks, nm) end
        if #mks > 0 then
            local rnd = mks[math.random(1, #mks)]
            pM3(rnd, currentSection3 == "cloud")
        else
            fw.sa("Info", "No music available!", 2)
        end
    end)

    rfb3.MouseButton1Click:Connect(function()
        if currentSection3 == "local" then
            ml3 = getLocalFiles3()
            fl3 = ml3
            upML3()
        else
            fetchCloudList3()
        end
    end)

    lpb3.MouseButton1Click:Connect(function()
        tgL3()
        lpb3.BackgroundColor3 = isLooped3 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,100,150)
        lpb3.Text = isLooped3 and "🔁 LOOP ON" or "🔁 LOOP OFF"
    end)

    scb3.MouseButton1Click:Connect(function()
        if currentSection3 == "local" then
            ml3 = getLocalFiles3()
            fl3 = ml3
            upML3()
        else
            fetchCloudList3()
        end
    end)

    ab3.MouseButton1Click:Connect(function()
        local nm = ni3.Text
        local url = ui3.Text
        if nm ~= "" and url ~= "" then
            adM3(nm, url)
            ni3.Text = ""
            ui3.Text = ""
        else
            fw.sa("Error", "Please enter name and URL!", 2)
        end
    end)

    sf3.Changed:Connect(function(prop)
        if prop == "Text" then ftM3(sf3.Text) end
    end)

    ml3 = getLocalFiles3()
    fl3 = ml3
    cl3 = {}
    fcl3 = cl3
    
    switchSection3("local")
    upML3()
    updateNowPlaying3("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
    upProg3()
    
    spawn(function()
        wait(3)
        fetchCloudList3()
        fw.sa("Success", "🎵 Music system loaded!", 2)
    end)
    
    spawn(function()
        while true do
            if cm3 and cm3.IsPlaying then
                currentTime3 = cm3.TimePosition
                totalTime3 = cm3.TimeLength
                upProg3()
            end
            wait(0.5)
        end
    end)
end

return true
