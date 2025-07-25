local hs2 = game:GetService("HttpService")
local ts2 = game:GetService("TweenService")
local rs2 = game:GetService("RunService")

-- Configuración de música
local md2 = "FrostWare/Music/"
local cd2 = "FrostWare/cloud_cache/"
local CLOUD_TXT_URL = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Music.txt"
local PROXY_URL = "https://music.brunomatiastoledo2000.workers.dev/"
local sf2 = {".mp3", ".ogg", ".wav", ".m4a", ".flac"}

-- Variables de música
local cp2, cv2, cm2 = nil, 0.5, nil
local ml2, cl2, fl2, fcl2 = {}, {}, {}, {}
local sr2, csr2 = nil, nil
local isLooped2, currentTime2, totalTime2 = false, 0, 0
local progressBar2, timeLabel2, visualizer2 = nil, nil, nil
local downloadProgress2 = {}
local currentSection2 = "local"
local currentPlayingIsCloud2 = false
local availableGenres2 = {}
local availableUploaders2 = {}
local currentGenreFilter2 = ""
local currentUploaderFilter2 = ""
local searchInput2 = nil

-- Agregar pestaña de música
fw.addTab("Music", "Music", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.52, 0), fw.cscp)

local pagesContainer = fw.gu()["11"]
local musicPageFrame = pagesContainer:FindFirstChild("MusicPage")

if musicPageFrame then
    local function ensDir2(dir)
        if not isfolder(dir) then makefolder(dir) end
    end

    local function fT2(seconds)
        local mins = math.floor(seconds / 60)
        local secs = math.floor(seconds % 60)
        return string.format("%02d:%02d", mins, secs)
    end

    local function updateNowPlaying2(trackName, status, statusColor)
        local cpt = musicPageFrame:FindFirstChild("CurrentTrack")
        local cps = musicPageFrame:FindFirstChild("PlayStatus")
        if cpt then cpt.Text = trackName or "No music selected" end
        if cps then
            cps.Text = status or "⏹ Stopped"
            cps.TextColor3 = statusColor or Color3.fromRGB(200, 200, 200)
        end
    end

    local function stVis2(bars)
        if bars and type(bars) == "table" then
            spawn(function()
                while cm2 and cm2.IsPlaying do
                    for i, bar in pairs(bars) do
                        if bar and bar.Parent then
                            local height = math.random(10, 80) / 100
                            local tw = ts2:Create(bar, TweenInfo.new(0.1, Enum.EasingStyle.Quad), {
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
                        local tw = ts2:Create(bar, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                            Size = UDim2.new(0.04, 0, 0.1, 0),
                            Position = UDim2.new((i-1) * 0.05, 0, 0.9, 0)
                        })
                        tw:Play()
                    end
                end
            end)
        end
    end

    local function upProg2()
        if progressBar2 and timeLabel2 then
            if totalTime2 > 0 then
                local progress = currentTime2 / totalTime2
                progressBar2.Size = UDim2.new(progress, 0, 1, 0)
                timeLabel2.Text = fT2(currentTime2) .. " / " .. fT2(totalTime2)
            else
                progressBar2.Size = UDim2.new(0, 0, 1, 0)
                timeLabel2.Text = "00:00 / 00:00"
            end
        end
    end

    local function safeListFiles2(directory)
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

    local function getLocalFiles2() return safeListFiles2(md2) end
    local function getCloudFiles2() return safeListFiles2(cd2) end

    local function updateGenresAndUploaders2()
        availableGenres2 = {}
        availableUploaders2 = {}
        
        for _, song in pairs(cl2) do
            if song.genre and song.genre ~= "" and song.genre ~= "Unknown" then
                local found = false
                for _, g in pairs(availableGenres2) do
                    if g:lower() == song.genre:lower() then found = true; break end
                end
                if not found then table.insert(availableGenres2, song.genre) end
            end
            
            if song.uploader_name and song.uploader_name ~= "" and song.uploader_name ~= "Unknown" then
                local found = false
                for _, u in pairs(availableUploaders2) do
                    if u:lower() == song.uploader_name:lower() then found = true; break end
                end
                if not found then table.insert(availableUploaders2, song.uploader_name) end
            end
        end
        
        table.sort(availableGenres2, function(a, b) return a:lower() < b:lower() end)
        table.sort(availableUploaders2, function(a, b) return a:lower() < b:lower() end)
    end

    local function ftM2(qry)
        if currentSection2 == "local" then
            fl2 = {}
            if qry == "" then
                for nm, dt in pairs(ml2) do fl2[nm] = dt end
            else
                qry = qry:lower()
                for nm, dt in pairs(ml2) do
                    if nm:lower():find(qry) then fl2[nm] = dt end
                end
            end
        else
            fcl2 = {}
            local searchQuery = qry:lower()
            for nm, dt in pairs(cl2) do
                local matchesSearch = qry == "" or nm:lower():find(searchQuery) or
                                   (dt.title and dt.title:lower():find(searchQuery))
                local matchesGenre = currentGenreFilter2 == "" or 
                                   (dt.genre and dt.genre:lower() == currentGenreFilter2:lower())
                local matchesUploader = currentUploaderFilter2 == "" or 
                                      (dt.uploader_name and dt.uploader_name:lower() == currentUploaderFilter2:lower())
                
                if matchesSearch and matchesGenre and matchesUploader then
                    fcl2[nm] = dt
                end
            end
        end
        upML2()
    end

    local function playSound2(soundPath, trackName, isCloudTrack)
        if not soundPath then
            fw.sa("Error", "Invalid sound path!", 3)
            return false
        end
        
        if cm2 then
            cm2:Stop()
            cm2:Destroy()
        end
        
        local snd = Instance.new("Sound")
        snd.SoundId = soundPath
        snd.Volume = cv2
        snd.Parent = workspace
        snd.Looped = isLooped2
        
        cm2 = snd
        cp2 = trackName
        currentPlayingIsCloud2 = isCloudTrack
        currentTime2 = 0
        totalTime2 = snd.TimeLength or 0
        
        updateNowPlaying2("♪ " .. trackName, "🎵 Playing", Color3.fromRGB(100, 255, 100))
        snd:Play()
        fw.sa("Success", "♪ Playing: " .. trackName, 2)
        upML2()
        
        if visualizer2 then stVis2(visualizer2) end
        
        spawn(function()
            while cm2 == snd and snd.IsPlaying do
                currentTime2 = snd.TimePosition
                totalTime2 = snd.TimeLength
                upProg2()
                wait(0.5)
            end
        end)
        
        snd.Ended:Connect(function()
            if cm2 == snd then
                cm2 = nil
                cp2 = nil
                currentTime2 = 0
                totalTime2 = 0
                currentPlayingIsCloud2 = false
                updateNowPlaying2("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                upML2()
                upProg2()
            end
        end)
        
        return true
    end

    local function dlCloudFile2(song, callback)
        ensDir2(cd2)
        local pt = cd2 .. song.filename
        
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
            downloadProgress2[song.filename] = 0
            if callback then callback("downloading", 0) end
            
            local proxyUrl = PROXY_URL .. song.url
            local success, data = pcall(function() return game:HttpGet(proxyUrl) end)
            
            if not success then
                downloadProgress2[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress2[song.filename] = 50
            if callback then callback("downloading", 50) end
            
            local writeSuccess = pcall(function() writefile(pt, data) end)
            if not writeSuccess then
                downloadProgress2[song.filename] = nil
                if callback then callback("error", 0) end
                return
            end
            
            downloadProgress2[song.filename] = 100
            local success2, asset = pcall(function() return getcustomasset(pt) end)
            
            if success2 and asset then
                song.path = asset
                song.isCached = true
                if callback then callback("complete", 100, asset) end
            else
                if callback then callback("error", 0) end
            end
            
            wait(0.5)
            downloadProgress2[song.filename] = nil
        end)
        
        return "downloading"
    end

    local function fetchCloudList2()
        spawn(function()
            fw.sa("Info", "Fetching cloud music list...", 2)
            local success, response = pcall(function() return game:HttpGet(CLOUD_TXT_URL) end)
            
            if success then
                local lines = {}
                for line in response:gmatch("([^\n]+)") do table.insert(lines, line) end
                
                local cachedFiles = getCloudFiles2()
                cl2 = {}
                
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
                        
                        cl2[key] = {
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
                
                fcl2 = cl2
                updateGenresAndUploaders2()
                if currentSection2 == "cloud" then upML2() end
                
                local count = 0
                for _ in pairs(cl2) do count = count + 1 end
                fw.sa("Success", "Cloud music list updated! Found " .. count .. " songs", 2)
            else
                fw.sa("Error", "Failed to fetch cloud music list", 3)
            end
        end)
    end

    local function pM2(nm, isCloud)
        local musicData = isCloud and cl2[nm] or ml2[nm]
        if not musicData then
            fw.sa("Error", "Music file not found!", 2)
            return
        end
        
        if isCloud and not musicData.path then
            updateNowPlaying2("⏳ Downloading: " .. nm, "📥 Downloading", Color3.fromRGB(100, 200, 255))
            dlCloudFile2(musicData, function(status, progress, assetPath)
                if status == "downloading" then
                    fw.sa("Info", "Downloading " .. nm .. " (" .. progress .. "%)", 1)
                    upML2()
                elseif status == "complete" then
                    playSound2(assetPath, nm, true)
                elseif status == "error" then
                    fw.sa("Error", "Failed to download: " .. nm, 3)
                    updateNowPlaying2("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
                end
            end)
        elseif musicData.path then
            playSound2(musicData.path, nm, isCloud)
        else
            fw.sa("Error", "Music path not available!", 2)
        end
    end

    local function stM2()
        if cm2 then
            cm2:Stop()
            cm2:Destroy()
            cm2 = nil
            cp2 = nil
            currentTime2 = 0
            totalTime2 = 0
            currentPlayingIsCloud2 = false
            updateNowPlaying2("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
            upML2()
            upProg2()
            fw.sa("Info", "Music stopped", 1)
        end
    end

    local function psM2()
        if cm2 then
            if cm2.IsPlaying then
                cm2:Pause()
                updateNowPlaying2("♪ " .. cp2, "⏸ Paused", Color3.fromRGB(255, 200, 100))
                fw.sa("Info", "Music paused", 1)
            else
                cm2:Resume()
                updateNowPlaying2("♪ " .. cp2, "🎵 Playing", Color3.fromRGB(100, 255, 100))
                fw.sa("Info", "Music resumed", 1)
                if visualizer2 then stVis2(visualizer2) end
            end
        end
    end

    -- Crear interfaz de música usando las funciones del framework
    local tb2 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.18,0), p=UDim2.new(0.025,0,0.02,0), n="TopBar"})
    nc(tb2, 0.18)

    -- Panel de reproducción actual
    local cpf2 = nf(tb2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.01,0,0.075,0), n="CurrentlyPlaying"})
    nc(cpf2, 0.15)

    nt(cpf2, {t="🎵 Now Playing", ts=15, tc=Color3.fromRGB(166,190,255), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0,0), n="CPLabel"})
    nt(cpf2, {t="No music selected", ts=17, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,0.35,0), p=UDim2.new(0,0,0.25,0), n="CurrentTrack"})
    nt(cpf2, {t="⏹ Stopped", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.25,0), p=UDim2.new(0,0,0.6,0), n="PlayStatus"})

    -- Visualizador
    local vf2 = nf(cpf2, {bt=1, s=UDim2.new(1,0,0.15,0), p=UDim2.new(0,0,0.85,0), n="Visualizer"})
    local vbars2 = {}
    for i = 1, 20 do
        local bar = nf(vf2, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0.04,0,0.1,0), p=UDim2.new((i-1)*0.05,0,0.9,0), n="Bar"..i})
        nc(bar, 0.1)
        vbars2[i] = bar
    end
    visualizer2 = vbars2

    -- Panel de controles de volumen
    local vcf2 = nf(tb2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.34,0,0.075,0), n="VolumeControl"})
    nc(vcf2, 0.15)

    nt(vcf2, {t="🔊 Volume: " .. math.floor(cv2 * 100) .. "%", ts=13, tc=Color3.fromRGB(200,200,200), s=UDim2.new(1,0,0.3,0), p=UDim2.new(0,0,0,0), n="VolumeLabel"})

    -- Barra de progreso
    local pf2 = nf(vcf2, {c=Color3.fromRGB(30,35,45), s=UDim2.new(0.9,0,0.15,0), p=UDim2.new(0.05,0,0.6,0), n="ProgressFrame"})
    nc(pf2, 0.1)
    progressBar2 = nf(pf2, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,0,1,0), p=UDim2.new(0,0,0,0), n="ProgressBar"})
    nc(progressBar2, 0.1)

    timeLabel2 = nt(vcf2, {t="00:00 / 00:00", ts=11, tc=Color3.fromRGB(180,180,180), s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.8,0), n="TimeLabel"})

    -- Panel de controles
    local cf2 = nf(tb2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.32,0,0.85,0), p=UDim2.new(0.67,0,0.075,0), n="Controls"})
    nc(cf2, 0.15)

    local plb2 = nb(cf2, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.02,0,0.1,0), t="▶", tc=Color3.fromRGB(255,255,255), ts=15, n="PlayPauseBtn"})
    nc(plb2, 0.15)

    local stb2 = nb(cf2, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.22,0,0.4,0), p=UDim2.new(0.26,0,0.1,0), t="■", tc=Color3.fromRGB(255,255,255), ts=15, n="StopBtn"})
    nc(stb2, 0.15)

    -- Selector de sección
    local sectf2 = nf(musicPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.08,0), p=UDim2.new(0.025,0,0.21,0), n="SectionFrame"})
    nc(sectf2, 0.18)

    local localBtn2 = nb(sectf2, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.02,0,0.15,0), t="📁 LOCAL", tc=Color3.fromRGB(255,255,255), ts=12, n="LocalBtn"})
    nc(localBtn2, 0.15)

    local cloudBtn2 = nb(sectf2, {c=Color3.fromRGB(100,100,150), s=UDim2.new(0.2,0,0.7,0), p=UDim2.new(0.24,0,0.15,0), t="☁ CLOUD", tc=Color3.fromRGB(255,255,255), ts=12, n="CloudBtn"})
    nc(cloudBtn2, 0.15)

    -- Lista de música
    local mlf2 = nf(musicPageFrame, {c=Color3.fromRGB(20,25,35), s=UDim2.new(0.95,0,0.58,0), p=UDim2.new(0.025,0,0.4,0), n="MusicListFrame"})
    nc(mlf2, 0.18)

    sr2 = nsf(mlf2, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="MusicListScroll", sic=Color3.fromRGB(50,130,210), v=true})
    csr2 = nsf(mlf2, {bt=1, s=UDim2.new(0.98,0,0.95,0), p=UDim2.new(0.01,0,0.025,0), sb=8, cs=UDim2.new(0,0,0,0), n="CloudMusicListScroll", sic=Color3.fromRGB(50,130,210), v=false})

    function upML2()
        local currentList = currentSection2 == "local" and fl2 or fcl2
        local scrollFrame = currentSection2 == "local" and sr2 or csr2
        
        sr2.Visible = currentSection2 == "local"
        csr2.Visible = currentSection2 == "cloud"
        
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
                
                if cp2 == nm then
                    mc.BackgroundColor3 = Color3.fromRGB(50,130,210)
                end
                
                -- Icono de música
                local ico = nf(mc, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0,55,0,55), p=UDim2.new(0,10,0,10), n="MusicIcon"})
                nc(ico, 0.3)
                
                local iconText = cp2 == nm and (cm2 and cm2.IsPlaying and "♪" or "⏸") or (currentSection2 == "cloud" and "☁" or "♫")
                nt(ico, {t=iconText, ts=cp2 == nm and 22 or 20, tc=Color3.fromRGB(29,29,38), n="MusicEmoji"})
                
                -- Título
                nt(mc, {t=nm, ts=15, s=UDim2.new(0.35,0,0.35,0), p=UDim2.new(0,75,0,2), xa=Enum.TextXAlignment.Left, n="MusicTitle"})
                
                -- Estado
                local statusText = ""
                if currentSection2 == "cloud" then
                    statusText = dt.isCached and "☁ Cached" or "☁ Cloud"
                else
                    statusText = dt.isLocal and "📁 Local File" or "🌐 Downloaded"
                end
                nt(mc, {t=statusText, ts=12, tc=Color3.fromRGB(160,170,190), s=UDim2.new(0.35,0,0.25,0), p=UDim2.new(0,75,0,28), xa=Enum.TextXAlignment.Left, n="MusicStatus"})
                
                -- Botones
                local pb = nb(mc, {c=cp2 == nm and (cm2 and cm2.IsPlaying and Color3.fromRGB(255,150,100) or Color3.fromRGB(100,200,100)) or Color3.fromRGB(50,170,90), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.1,0), t=cp2 == nm and (cm2 and cm2.IsPlaying and "PAUSE" or "RESUME") or "PLAY", tc=Color3.fromRGB(255,255,255), ts=11, n="PlayBtn"})
                nc(pb, 0.15)
                
                local stb = nb(mc, {c=Color3.fromRGB(100,100,200), s=UDim2.new(0.13,0,0.4,0), p=UDim2.new(0.63,0,0.55,0), t="STOP", tc=Color3.fromRGB(255,255,255), ts=11, n="StopBtn"})
                nc(stb, 0.15)
                
                local rb = nb(mc, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0.11,0,0.4,0), p=UDim2.new(0.77,0,0.1,0), t="REMOVE", tc=Color3.fromRGB(255,255,255), ts=10, n="RemoveBtn"})
                nc(rb, 0.15)
                
                -- Eventos de botones
                pb.MouseButton1Click:Connect(function()
                    if cp2 == nm then psM2() else pM2(nm, currentSection2 == "cloud") end
                end)
                
                stb.MouseButton1Click:Connect(function()
                    if cp2 == nm then stM2() end
                end)
                
                rb.MouseButton1Click:Connect(function()
                    -- Función de remover música aquí
                end)
                
                yp = yp + 80
            end
            
            scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yp)
        end
    end

    -- Eventos de controles principales
    plb2.MouseButton1Click:Connect(function()
        if cp2 then psM2() else fw.sa("Info", "No music selected!", 2) end
    end)

    stb2.MouseButton1Click:Connect(function() stM2() end)

    localBtn2.MouseButton1Click:Connect(function()
        currentSection2 = "local"
        localBtn2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        cloudBtn2.BackgroundColor3 = Color3.fromRGB(100,100,150)
        ftM2("")
    end)

    cloudBtn2.MouseButton1Click:Connect(function()
        currentSection2 = "cloud"
        cloudBtn2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        localBtn2.BackgroundColor3 = Color3.fromRGB(100,100,150)
        ftM2("")
    end)

    -- Inicialización
    ml2 = getLocalFiles2()
    fl2 = ml2
    cl2 = {}
    fcl2 = cl2
    
    upML2()
    updateNowPlaying2("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
    upProg2()
    
    spawn(function()
        wait(3)
        fetchCloudList2()
        fw.sa("Success", "🎵 Music system loaded!", 2)
    end)
    
    spawn(function()
        while true do
            if cm2 and cm2.IsPlaying then
                currentTime2 = cm2.TimePosition
                totalTime2 = cm2.TimeLength
                upProg2()
            end
            wait(0.5)
        end
    end)
end

return true
