local hs34 = game:GetService("HttpService")
local ts34 = game:GetService("TweenService")
local rs34 = game:GetService("RunService")

local md34 = "FrostWare/Music/"
local cd34 = "FrostWare/cloud_cache/"
local CLOUD_TXT_URL = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Music.txt"
local PROXY_URL = "https://music.brunomatiastoledo2000.workers.dev/"
local sf34 = {".mp3", ".ogg", ".wav", ".m4a", ".flac"}

local cp34, cv34, cm34 = nil, 0.5, nil
local ml34, cl34, fl34, fcl34 = {}, {}, {}, {}
local sr34, csr34 = nil, nil
local isLooped34, currentTime34, totalTime34 = false, 0, 0
local progressBar34, timeLabel34, visualizer34 = nil, nil, nil
local downloadProgress34 = {}
local currentSection34 = "local"
local currentPlayingIsCloud34 = false
local availableGenres34 = {}
local availableUploaders34 = {}
local currentGenreFilter34 = ""
local currentUploaderFilter34 = ""
local searchInput34 = nil
local localBtn34, cloudBtn34 = nil, nil
local ni34, ui34, ab34 = nil, nil, nil
local nio34, uio34, abo34 = nil, nil, nil
local sf34_input = nil
local sfo34 = nil
local gdf34, gdb34, gdl34 = nil, nil, nil
local udf34, udb34, udl34 = nil, nil, nil
local rfb34, scb34 = nil, nil

fw.addTab("Music", "Music", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.52, 0), fw.cscp)

local pagesContainer = fw.gu()["11"]
local musicPageFrame = pagesContainer:FindFirstChild("MusicPage")

if musicPageFrame then
    local function ensDir34(dir)
        if not isfolder(dir) then makefolder(dir) end
    end

    local function fT34(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    local function updateNowPlaying34(trackName, status, statusColor)
        local cpt = musicPageFrame:FindFirstChild("CurrentTrack")
        local cps = musicPageFrame:FindFirstChild("PlayStatus")
        if cpt then cpt.Text = trackName or "No music selected" end
        if cps then
            cps.Text = status or "⏹ Stopped"
            cps.TextColor3 = statusColor or Color3.fromRGB(200, 200, 200)
        end
    end

    local function stVis34(bars)
        if bars and type(bars) == "table" then
            spawn(function()
                while cm34 and cm34.IsPlaying do
                    for i, bar in pairs(bars) do
                        if bar and bar.Parent then
                            local height = math.random(10, 80) / 100
                            local tw = ts34:Create(bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
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
                        local tw = ts34:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(0.04, 0, 0.1, 0),
                            Position = UDim2.new((i-1) * 0.05, 0, 0.9, 0)
                        })
                        tw:Play()
                    end
                end
            end)
        end
    end

    local function upProg34()
        if progressBar34 and timeLabel34 then
            if totalTime34 > 0 then
                local progress = currentTime34 / totalTime34
                progressBar34.Size = UDim2.new(progress, 0, 1, 0)
                timeLabel34.Text = fT34(currentTime34) .. " / " .. fT34(totalTime34)
            else
                progressBar34.Size = UDim2.new(0, 0, 1, 0)
                timeLabel34.Text = "00:00 / 00:00"
            end
        end
    end

    local function safeListFiles34(directory)
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

    local function getLocalFiles34() return safeListFiles34(md34) end
    local function getCloudFiles34() return safeListFiles34(cd34) end

    local function updateGenresAndUploaders34()
        availableGenres34 = {}
        availableUploaders34 = {}
        
        for _, song in pairs(cl34) do
            if song.genre and song.genre ~= "" and song.genre ~= "Unknown" then
                local found = false
                for _, g in pairs(availableGenres34) do
                    if g:lower() == song.genre:lower() then found = true; break end
                end
                if not found then table.insert(availableGenres34, song.genre) end
            end
            
            if song.uploader_name and song.uploader_name ~= "" and song.uploader_name ~= "Unknown" then
                local found = false
                for _, u in pairs(availableUploaders34) do
                    if u:lower() == song.uploader_name:lower() then found = true; break end
                end
                if not found then table.insert(availableUploaders34, song.uploader_name) end
            end
        end
        
        table.sort(availableGenres34, function(a, b) return a:lower() < b:lower() end)
        table.sort(availableUploaders34, function(a, b) return a:lower() < b:lower() end)
    end

    local function ftM34(qry)
        if currentSection34 == "local" then
            fl34 = {}
            if qry == "" then
                for nm, dt in pairs(ml34) do fl34[nm] = dt end
            else
                qry = qry:lower()
                for nm, dt in pairs(ml34) do
                    if nm:lower():find(qry) then fl34[nm] = dt end
                end
            end
        else
            fcl34 = {}
            local searchQuery = qry:lower()
            for nm, dt in pairs(cl34) do
                local matchesSearch = qry == "" or nm:lower():find(searchQuery) or
                                   (dt.title and dt.title:lower():find(searchQuery))
                local matchesGenre = currentGenreFilter34 == "" or 
                                   (dt.genre and dt.genre:lower() == currentGenreFilter34:lower())
                local matchesUploader = currentUploaderFilter34 == "" or 
                                      (dt.uploader_name and dt.uploader_name:lower() == currentUploaderFilter34:lower())
                
                if matchesSearch and matchesGenre and matchesUploader then
                    fcl34[nm] = dt
                end
            end
        end
        upML34()
    end

    local function playSound34(soundPath, trackName, isCloudTrack)
        if not soundPath then
            fw.sa("Error", "Invalid sound path!", 3)
            return false
        end
        
        if cm34 then
            cm34:Stop()
            cm34:Destroy()
        end
        
        local snd = Instance.new("Sound")
        snd.SoundId = soundPath
        snd.Volume = cv34
        snd.Parent = workspace
        snd.Looped = isLooped34
        
        cm34 = snd
        cp34 = trackName
        currentPlayingIsCloud34 = isCloudTrack
        currentTime34 = 0
        totalTime34 = snd.TimeLength or 0
        
        updateNowPlaying34("♪ " .. trackName, "🎵 Playing", Color3.fromRGB(100, 255, 100))
        snd:Play()
        fw.sa("Success", "♪ Playing: " .. trackName, 2)
        upML34()
        
        if visualizer34 then stVis34(visualizer34) end
        
        spawn(function()
            while cm34 == snd and snd.IsPlaying do
                currentTime34 = snd.TimePosition
                totalTime34 = snd.TimeLength
                upProg34()
                wait(0.5)
            end
        end)
        
        snd.Ended:Connect(function()
            if cm34 == snd then
                cm34 = nil
                cp34 = nil
                currentTime34 = 0
                totalTime34 = 0
                currentPlayingIsCloud34 = false
                updateNowPlaying34("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                upML34()
                upProg34()
            end
        end)
        
        return true
    end

    local function dlCloudFile34(song, callback)
        ensDir34(cd34)
        local pt = cd34 .. song.filename
        
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
            downloadProgress34[song.filename] = 0
            if callback then callback("downloading", 0) end
            
            local proxyUrl = PROXY_URL .. song.url
            local success, data = pcall(function() return game:HttpGet(proxyUrl) end)
            
            if not success then
                downloadProgress34[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress34[song.filename] = 50
            if callback then callback("downloading", 50) end
            
            local writeSuccess = pcall(function() writefile(pt, data) end)
            if not writeSuccess then
                downloadProgress34[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress34[song.filename] = 100
            local success2, asset = pcall(function() return getcustomasset(pt) end)
            
            if success2 and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
            else
                if callback then callback("error", 0) end
            end
            
            wait(0.5)
            downloadProgress34[song.filename] = nil
        end)
        
        return "downloading"
    end

    local function fetchCloudList34()
        spawn(function()
            fw.sa("Info", "Fetching cloud music list...", 2)
            local success, response = pcall(function() return game:HttpGet(CLOUD_TXT_URL) end)
            
            if success then
                local lines = {}
                for line in response:gmatch("([^\n]+)") do table.insert(lines, line) end
                
                local cachedFiles = getCloudFiles34()
                cl34 = {}
                
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
                        
                        cl34[key] = {
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
                
                fcl34 = cl34
                updateGenresAndUploaders34()
                if currentSection34 == "cloud" then upML34() end
                
                local count = 0
                for _ in pairs(cl34) do count = count + 1 end
                fw.sa("Success", "Cloud music list updated! Found " .. count .. " songs", 2)
            else
                fw.sa("Error", "Failed to fetch cloud music list", 3)
            end
        end)
    end

    local function pM34(nm, isCloud)
        local musicData = isCloud and cl34[nm] or ml34[nm]
        if not musicData then
            fw.sa("Error", "Music file not found!", 2)
            return
        end
        
        if isCloud and not musicData.path then
            updateNowPlaying34("⏳ Downloading: " .. nm, "📥 Downloading", Color3.fromRGB(100, 200, 255))
            dlCloudFile34(musicData, function(status, progress, assetPath)
                if status == "downloading" then
                    fw.sa("Info", "Downloading " .. nm .. " (" .. progress .. "%)", 1)
                    upML34()
                elseif status == "complete" then
                    playSound34(assetPath, nm, true)
                elseif status == "error" then
                    fw.sa("Error", "Failed to download: " .. nm, 3)
                    updateNowPlaying34("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                end
            end)
        elseif musicData.path then
            playSound34(musicData.path, nm, isCloud)
        else
            fw.sa("Error", "Music path not available!", 2)
        end
    end

    local function stM34()
        if cm34 then
            cm34:Stop()
            cm34:Destroy()
            cm34 = nil
            cp34 = nil
            currentTime34 = 0
            totalTime34 = 0
            currentPlayingIsCloud34 = false
            updateNowPlaying34("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
            upML34()
            upProg34()
            fw.sa("Info", "Music stopped", 1)
        end
    end

    local function psM34()
        if cm34 then
            if cm34.IsPlaying then
                cm34:Pause()
                updateNowPlaying34("♪ " .. cp34, "⏸ Paused", Color3.fromRGB(255, 200, 100))
                fw.sa("Info", "Music paused", 1)
            else
                cm34:Resume()
                updateNowPlaying34("♪ " .. cp34, "🎵 Playing", Color3.fromRGB(100, 255, 100))
                fw.sa("Info", "Music resumed", 1)
                if visualizer34 then stVis34(visualizer34) end
            end
        end
    end

    local function sV34(vol)
        cv34 = math.max(0, math.min(1, vol))
        if cm34 then cm34.Volume = cv34 end
    end

    local function tgL34()
        isLooped34 = not isLooped34
        if cm34 then cm34.Looped = isLooped34 end
        fw.sa("Info", isLooped34 and "Loop enabled" or "Loop disabled", 1)
    end

    local function adM34(nm, url)
        if ml34[nm] then
            fw.sa("Error", "Music already exists!", 2)
            return false
        end
        local fn = nm:gsub("[^%w%s%-_]", "") .. ".mp3"
        fw.sa("Info", "Downloading: " .. nm, 1)
        spawn(function()
            local success, data = pcall(function() return game:HttpGet(url) end)
            if success then
                ensDir34(md34)
                local writeSuccess = pcall(function() writefile(md34 .. fn, data) end)
                if writeSuccess then
                    ml34 = getLocalFiles34()
                    fl34 = ml34
                    upML34()
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

    local function rmM34(nm, isCloud)
        if isCloud then
            if cl34[nm] then
                if cp34 == nm then stM34() end
                if cl34[nm].filename and isfile(cd34 .. cl34[nm].filename) then
                    pcall(function() delfile(cd34 .. cl34[nm].filename) end)
                end
                cl34[nm] = nil
                fcl34 = cl34
            end
        else
            if ml34[nm] then
                if cp34 == nm then stM34() end
                if ml34[nm].filename and isfile(md34 .. ml34[nm].filename) and not ml34[nm].isLocal then
                    pcall(function() delfile(md34 .. ml34[nm].filename) end)
                end
                ml34 = getLocalFiles34()
                fl34 = ml34
            end
        end
        upML34()
        fw.sa("Success", "Music removed: " .. nm, 2)
    end

    local function switchSection34(section)
        currentSection34 = section
        if section == "local" then
            if localBtn34 then localBtn34.BackgroundColor3 = Color3.fromRGB(50,130,210) end
            if cloudBtn34 then cloudBtn34.BackgroundColor3 = Color3.fromRGB(100,100,150) end
            if ni34 then ni34.Visible = true end
            if nio34 then nio34.Visible = true end
            if ui34 then ui34.Visible = true end
            if uio34 then uio34.Visible = true end
            if ab34 then ab34.Visible = true end
            if abo34 then abo34.Visible = true end
            if sf34_input then sf34_input.Visible = false end
            if sfo34 then sfo34.Visible = false end
            if gdf34 then gdf34.Visible = false end
            if udf34 then udf34.Visible = false end
            if gdl34 then gdl34.Visible = false end
            if udl34 then udl34.Visible = false end
            if rfb34 then rfb34.Text = "📁 SCAN" end
            if scb34 then scb34.Text = "📁 SCAN" end
        else
            if localBtn34 then localBtn34.BackgroundColor3 = Color3.fromRGB(100,100,150) end
            if cloudBtn34 then cloudBtn34.BackgroundColor3 = Color3.fromRGB(50,130,210) end
            if ni34 then ni34.Visible = false end
            if nio34 then nio34.Visible = false end
            if ui34 then ui34.Visible = false end
            if uio34 then uio34.Visible = false end
            if ab34 then ab34.Visible = false end
            if abo34 then abo34.Visible = false end
            if sf34_input then sf34_input.Visible = true end
            if sfo34 then sfo34.Visible = true end
            if gdf34 then gdf34.Visible = true end
            if udf34 then udf34.Visible = true end
            if rfb34 then rfb34.Text = "🔄 REFRESH" end
            if scb34 then scb34.Text = "🔄 REFRESH" end
        end
        ftM34(searchInput34 and searchInput34.Text or "")
    end

    function upML34()
        local currentList = currentSection34 == "local" and fl34 or fcl34
        local scrollFrame = currentSection34 == "local" and sr34 or csr34
        
        if sr34 then sr34.Visible = currentSection34 == "local" end
        if csr34 then csr34.Visible = currentSection34 == "cloud" end
        
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
                
                if cp34 == nm then
                    mc.BackgroundColor3 = Color3.fromRGB(50,130,210)
                end
                
                local ico = nf(mc, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,55,0,55), p=UDim2.new(0,10,0,10), n="MusicIcon"})
                nc(ico, 0.3)
                
                local iconText = cp34 == nm and (cm34 and cm34.IsPlaying and "♪" or "⏸") or (currentSection34 == "cloud" and "☁" or "♫")
                nt(ico, {t=iconText, ts=cp34 == nm and 22 or 20, tc=Color3.fromRGB(29,29,38), n="MusicEmoji"})
                
                nt(mc, {t=nm, ts=15, s=UDim2.new(0.35,0,0.35,0), p=UDim2.new(0,75,0,2), xa=Enum.TextXAlignment.Left, n="MusicTitle"})
                
                local statusText = ""
                local infoText = ""
                if currentSection34 == "cloud" then
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
                
                if downloadProgress34[dt.filename] then
                    local prog = downloadProgress34[dt.filename]
                    nt(mc, {t="Downloading... " .. prog .. "%", ts=12, tc=Color3.fromRGB(100,200,255), s=UDim2.new(0.35,0,0.25,0), p=UDim2.new(0,75,0,65), xa=Enum.TextXAlignment.Left, n="DownloadProgress"})
                end
                
                local pb = nb(mc, {c=cp34 == nm and (cm34 and cm34.IsPlaying and Color3.fromRGB(255,150,100) or Color3.fromRGB(100,200,100)) or Color3.fromRGB(50,170,90), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.1,0), t=cp34 == nm and (cm34 and cm34.IsPlaying and "PAUSE" or "RESUME") or "PLAY", tc=Color3.fromRGB(255,255,255), ts=11, n="PlayBtn"})
                nc(pb, 0.15)
                
                local stb = nb(mc, {c=Color3.fromRGB(100,100,200), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.55,0), t="STOP", tc=Color3.fromRGB(255,255,255), ts=11, n="StopBtn"})
                nc(stb, 0.15)
                
                local rb = nb(mc, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.11,0,0.4,0), p=UDim2.new(0.77,0,0.1,0), t="REMOVE", tc=Color3.fromRGB(255,255,255), ts=10, n="RemoveBtn"})
                nc(rb, 0.15)
                
                local lb = nb(mc, {c=isLooped34 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,150,200), s=UDim2.new(0.11,0,0.4,0), p=UDim2.new(0.77,0,0.55,0), t=isLooped34 and "LOOP ON" or "LOOP OFF", tc=Color3.fromRGB(255,255,255), ts=10, n="LoopBtn"})
                nc(lb, 0.15)
                
                pb.MouseButton1Click:Connect(function()
                    if cp34 == nm then psM34() else pM34(nm, currentSection34 == "cloud") end
                end)
                
                stb.MouseButton1Click:Connect(function()
                    if cp34 == nm then stM34() end
                end)
                
                rb.MouseButton1Click:Connect(function()
                    rmM34(nm, currentSection34 == "cloud")
                end)
                
                lb.MouseButton1Click:Connect(function()
                    tgL34()
                    upML34()
                end)
                
                yp = yp + 80
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yp)
        end
    end

    local tb34 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.18,0), p=UDim2.new(0.025,0,0.02,0), n="TopBar"})
    nc(tb34, 0.18)

    local cpf34 = nf(tb34, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.01,0,0.075,0), n="CurrentlyPlaying"})
    nc(cpf34, 0.15)

    nt(cpf34, {t="🎵 Now Playing", ts=15, tc=Color3.fromRGB(166,190,255), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0,0), n="CPLabel"})
    nt(cpf34, {t="No music selected", ts=17, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,0.35,0), p=UDim2.new(0,0,0.25,0), n="CurrentTrack"})
    nt(cpf34, {t="⏹ Stopped", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0.6,0), n="PlayStatus"})

    local vf34 = nf(cpf34, {bt=1, s=UDim2.new(1,0,0.15,0), p=UDim2.new(0,0,0.85,0), n="Visualizer"})
    local vbars34 = {}
    for i = 1, 20 do
        local bar = nf(vf34, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0.04,0,0.1,0), p=UDim2.new((i-1)*0.05,0,0.9,0), n="Bar"..i})
        nc(bar, 0.1)
        vbars34[i] = bar
    end
    visualizer34 = vbars34

    local vcf34 = nf(tb34, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.34,0,0.075,0), n="VolumeControl"})
    nc(vcf34, 0.15)

    nt(vcf34, {t="🔊 Volume: " .. math.floor(cv34 * 100) .. "%", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.3,0), p=UDim2.new(0,0,0,0), n="VolumeLabel"})

    local vs34 = nf(vcf34, {c=Color3.fromRGB(30,35,45), s=UDim2.new(0.9,0,0.2,0), p=UDim2.new(0.05,0,0.35,0), n="VolumeSlider_Track"})
    nc(vs34, 0.1)
    local vh34 = nf(vs34, {c=Color3.fromRGB(166,190,255), s=UDim2.new(cv34,0,1,0), p=UDim2.new(0,0,0,0), n="VolumeSlider_Handle"})
    nc(vh34, 0.1)
    local vb34 = nb(vs34, {bt=1, s=UDim2.new(1,0,1,0), p=UDim2.new(0,0,0,0), t="", n="VolumeSlider_Button"})

    local pf34 = nf(vcf34, {c=Color3.fromRGB(30,35,45), s=UDim2.new(0.9,0,0.15,0), p=UDim2.new(0.05,0,0.6,0), n="ProgressFrame"})
    nc(pf34, 0.1)
    progressBar34 = nf(pf34, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,0,1,0), p=UDim2.new(0,0,0,0), n="ProgressBar"})
    nc(progressBar34, 0.1)

    timeLabel34 = nt(vcf34, {t="00:00 / 00:00", ts=11, tc=Color3.fromRGB(180,180,180), s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.8,0), n="TimeLabel"})

    local cf34 = nf(tb34, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.67,0,0.075,0), n="Controls"})
    nc(cf34, 0.15)

    local plb34 = nb(cf34, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.02,0,0.1,0), t="▶", tc=Color3.fromRGB(255,255,255), ts=15, n="PlayPauseBtn"})
    nc(plb34, 0.15)

    local stb34 = nb(cf34, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.26,0,0.1,0), t="■", tc=Color3.fromRGB(255,255,255), ts=15, n="StopBtn"})
    nc(stb34, 0.15)

    local shb34 = nb(cf34, {c=Color3.fromRGB(100,150,200), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.5,0,0.1,0), t="🔀", tc=Color3.fromRGB(255,255,255), ts=13, n="ShuffleBtn"})
    nc(shb34, 0.15)

    rfb34 = nb(cf34, {c=Color3.fromRGB(150,100,200), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.74,0,0.1,0), t="🔄", tc=Color3.fromRGB(255,255,255), ts=13, n="RefreshBtn"})
    nc(rfb34, 0.15)

    local lpb34 = nb(cf34, {c=isLooped34 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,100,150), s=UDim2.new(0.47,0,0.4,0), p=UDim2.new(0.02,0,0.55,0), t=isLooped34 and "🔁 LOOP ON" or "🔁 LOOP OFF", tc=Color3.fromRGB(255,255,255), ts=11, n="LoopBtn"})
    nc(lpb34, 0.15)

    scb34 = nb(cf34, {c=Color3.fromRGB(200,150,100), s=UDim2.new(0.47,0,0.4,0), p=UDim2.new(0.51,0,0.55,0), t="📁 SCAN", tc=Color3.fromRGB(255,255,255), ts=11, n="ScanBtn"})
    nc(scb34, 0.15)

    local sectf34 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.08,0), p=UDim2.new(0.025,0,0.21,0), n="SectionFrame"})
    nc(sectf34, 0.18)

    localBtn34 = nb(sectf34, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.02,0,0.15,0), t="📁 LOCAL", tc=Color3.fromRGB(255,255,255), ts=12, n="LocalBtn"})
    nc(localBtn34, 0.15)

    cloudBtn34 = nb(sectf34, {c=Color3.fromRGB(100,100,150), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.24,0,0.15,0), t="☁ CLOUD", tc=Color3.fromRGB(255,255,255), ts=12, n="CloudBtn"})
    nc(cloudBtn34, 0.15)

    local af34 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.09,0), p=UDim2.new(0.025,0,0.3,0), n="UnifiedInputFrame"})
    nc(af34, 0.18)

    nio34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.25,0,0.6,0), p=UDim2.new(0.02,0,0.2,0), n="NameInput_Outer"})
    nc(nio34, 0.18)

    ni34 = ntb(nio34, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=13, tc=Color3.fromRGB(240,245,255), n="NameInput"})
    nc(ni34, 0.15)

    uio34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.5,0,0.6,0), p=UDim2.new(0.29,0,0.2,0), n="UrlInput_Outer"})
    nc(uio34, 0.18)

    ui34 = ntb(uio34, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=13, tc=Color3.fromRGB(240,245,255), n="UrlInput"})
    nc(ui34, 0.15)

    abo34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.17,0,0.6,0), p=UDim2.new(0.81,0,0.2,0), n="AddBtn_Outer"})
    nc(abo34, 0.18)

    ab34 = nb(abo34, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), t="📥 ADD", tc=Color3.fromRGB(255,255,255), ts=12, n="AddBtn"})
    nc(ab34, 0.15)

    sfo34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.3,0,0.6,0), p=UDim2.new(0.02,0,0.2,0), n="SearchInput_Outer", v=false})
    nc(sfo34, 0.18)

    sf34_input = ntb(sfo34, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=12, tc=Color3.fromRGB(240,245,255), n="SearchInput"})
    nc(sf34_input, 0.15)
    searchInput34 = sf34_input

    gdf34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.34,0,0.2,0), n="GenreDropdown_Frame", v=false})
    nc(gdf34, 0.18)

    gdb34 = nb(gdf34, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), t="🎵 All Genres", tc=Color3.fromRGB(240,245,255), ts=11, n="GenreDropdown"})
    nc(gdb34, 0.15)

    gdl34 = nsf(af34, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0,200,0,150), p=UDim2.new(0,0,0,0), sb=6, cs=UDim2.new(0,0,0,0), v=false, n="GenreDropdown_List"})
    nc(gdl34, 0.15)

    udf34 = nf(af34, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.56,0,0.2,0), n="UploaderDropdown_Frame", v=false})
    nc(udf34, 0.18)

    udb34 = nb(udf34, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), t="👤 All Users", tc=Color3.fromRGB(240,245,255), ts=11, n="UploaderDropdown"})
    nc(udb34, 0.15)

    udl34 = nsf(af34, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0,200,0,150), p=UDim2.new(0,0,0,0), sb=6, cs=UDim2.new(0,0,0,0), v=false, n="UploaderDropdown_List"})
    nc(udl34, 0.15)

    local mlf34 = nf(musicPageFrame, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.95,0,0.58,0), p=UDim2.new(0.025,0,0.4,0), n="MusicListFrame"})
    nc(mlf34, 0.18)

    sr34 = nsf(mlf34, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="MusicListScroll", sic=Color3.fromRGB(50,130,210), v=true})
    csr34 = nsf(mlf34, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="CloudMusicListScroll", sic=Color3.fromRGB(50,130,210), v=false})

    vb34.MouseButton1Down:Connect(function()
        local mouse = game.Players.LocalPlayer:GetMouse()
        local connection
        connection = mouse.Button1Up:Connect(function() connection:Disconnect() end)
        local moveConnection
        moveConnection = mouse.Move:Connect(function()
            if connection.Connected then
                local relativeX = math.max(0, math.min(1, (mouse.X - vs34.AbsolutePosition.X) / vs34.AbsoluteSize.X))
                vh34.Size = UDim2.new(relativeX, 0, 1, 0)
                sV34(relativeX)
                local vl = vcf34:FindFirstChild("VolumeLabel")
                if vl then vl.Text = "🔊 Volume: " .. math.floor(cv34 * 100) .. "%" end
            else
                moveConnection:Disconnect()
            end
        end)
    end)

    localBtn34.MouseButton1Click:Connect(function() switchSection34("local") end)
    cloudBtn34.MouseButton1Click:Connect(function() switchSection34("cloud") end)

    plb34.MouseButton1Click:Connect(function()
        if cp34 then psM34() else fw.sa("Info", "No music selected!", 2) end
    end)

    stb34.MouseButton1Click:Connect(function() stM34() end)

    shb34.MouseButton1Click:Connect(function()
        local currentList = currentSection34 == "local" and ml34 or cl34
        local mks = {}
        for nm, _ in pairs(currentList) do table.insert(mks, nm) end
        if #mks > 0 then
            local rnd = mks[math.random(1, #mks)]
            pM34(rnd, currentSection34 == "cloud")
        else
            fw.sa("Info", "No music available!", 2)
        end
    end)

    rfb34.MouseButton1Click:Connect(function()
        if currentSection34 == "local" then
            ml34 = getLocalFiles34()
            fl34 = ml34
            upML34()
        else
            fetchCloudList34()
        end
    end)

    lpb34.MouseButton1Click:Connect(function()
        tgL34()
        lpb34.BackgroundColor3 = isLooped34 and Color3.fromRGB(255,200,100) or Color3.fromRGB(100,100,150)
        lpb34.Text = isLooped34 and "🔁 LOOP ON" or "🔁 LOOP OFF"
    end)

    scb34.MouseButton1Click:Connect(function()
        if currentSection34 == "local" then
            ml34 = getLocalFiles34()
            fl34 = ml34
            upML34()
        else
            fetchCloudList34()
        end
    end)

    ab34.MouseButton1Click:Connect(function()
        local nm = ni34.Text
        local url = ui34.Text
        if nm ~= "" and url ~= "" then
            adM34(nm, url)
            ni34.Text = ""
            ui34.Text = ""
        else
            fw.sa("Error", "Please enter name and URL!", 2)
        end
    end)

    sf34_input.Changed:Connect(function(prop)
        if prop == "Text" then ftM34(sf34_input.Text) end
    end)

    ml34 = getLocalFiles34()
    fl34 = ml34
    cl34 = {}
    fcl34 = cl34
    
    switchSection34("local")
    upML34()
    updateNowPlaying34("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
    upProg34()
    
    spawn(function()
        wait(3)
        fetchCloudList34()
        fw.sa("Success", "🎵 Music system loaded!", 2)
    end)
    
    spawn(function()
        while true do
            if cm34 and cm34.IsPlaying then
                currentTime34 = cm34.TimePosition
                totalTime34 = cm34.TimeLength
                upProg34()
            end
            wait(0.5)
        end
    end)
end

return true
