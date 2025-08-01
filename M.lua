spawn(function()
    wait(1)
    local FW = getgenv()._FW or {}
    local hs = game:GetService("HttpService")
    local ts = game:GetService("TweenService")
    local rs = game:GetService("RunService")

    local md = "FrostWare/Music/"
    local cd = "FrostWare/cloud_cache/"
    local CLOUD_TXT_URL = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/Music.txt"
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
    local availableGenres = {}
    local availableUploaders = {}
    local currentGenreFilter = ""
    local currentUploaderFilter = ""
    local searchInput = nil

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
                TextSize = props.TextSize or 16,
                TextColor3 = props.TextColor3 or Color3.fromRGB(240, 245, 255),
                BackgroundTransparency = props.BackgroundTransparency or 1,
                Size = props.Size or UDim2.new(1, 0, 1, 0),
                Position = props.Position or UDim2.new(0, 0, 0, 0),
                TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Center,
                TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Name = props.Name or "StyledText"
            })
            FW.cTC(txt, props.TextSize or 16)
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
                TextSize = props.TextSize or 14,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
                Name = props.Name or "Button"
            })
            FW.cC(btn, 0.15)
            FW.cTC(btn, props.TextSize or 14)
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
                TextSize = props.TextSize or 16,
                TextColor3 = Color3.fromRGB(240, 245, 255),
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Name = props.Name or "Input"
            })
            FW.cC(inp, 0.15)
            FW.cTC(inp, props.TextSize or 16)
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
        elseif t == "dropdown" then
            local df = FW.cF(p, {
                BackgroundColor3 = Color3.fromRGB(18, 22, 32),
                Size = props.Size,
                Position = props.Position,
                Name = (props.Name or "Dropdown") .. "_Frame",
                ZIndex = props.ZIndex or 1
            })
            FW.cC(df, 0.18)

            local db = FW.cB(df, {
                BackgroundColor3 = Color3.fromRGB(35, 40, 50),
                Size = UDim2.new(1, -4, 1, -4),
                Position = UDim2.new(0, 2, 0, 2),
                Text = props.Text or "Select...",
                TextColor3 = Color3.fromRGB(240, 245, 255),
                TextSize = props.TextSize or 14,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Name = props.Name or "Dropdown",
                ZIndex = props.ZIndex or 1
            })
            FW.cC(db, 0.15)
            FW.cTC(db, props.TextSize or 14)

            local dl = FW.cSF(p, {
                BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                Size = UDim2.new(0, 200, 0, 150),
                Position = UDim2.new(0, 0, 0, 0),
                ScrollBarThickness = 6,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Visible = false,
                ZIndex = 200,
                Name = (props.Name or "Dropdown") .. "_List"
            })
            FW.cC(dl, 0.15)
            FW.cS(dl, 2, Color3.fromRGB(50, 130, 210))

            return df, db, dl
        end
    end

    local tb, tbo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(0.95, 0, 0.18, 0),
        Position = UDim2.new(0.025, 0, 0.02, 0),
        Name = "TopBar"
    })

    local cpf, cpfo = cUI(tb, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.32, 0, 0.85, 0),
        Position = UDim2.new(0.01, 0, 0.075, 0),
        Name = "CurrentlyPlaying"
    })

    cUI(cpf, "text", {
        Text = "🎵 Now Playing",
        TextSize = 15,
        TextColor3 = Color3.fromRGB(166, 190, 255),
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Name = "CPLabel"
    })

    cUI(cpf, "text", {
        Text = "No music selected",
        TextSize = 17,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Size = UDim2.new(1, 0, 0.35, 0),
        Position = UDim2.new(0, 0, 0.25, 0),
        Name = "CurrentTrack"
    })

    cUI(cpf, "text", {
        Text = "⏹ Stopped",
        TextSize = 13,
        TextColor3 = Color3.fromRGB(200, 200, 200),
        Size = UDim2.new(1, 0, 0.25, 0),
        Position = UDim2.new(0, 0, 0.6, 0),
        Name = "PlayStatus"
    })

    local vf = FW.cF(cpf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0.15, 0),
        Position = UDim2.new(0, 0, 0.85, 0),
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
        Size = UDim2.new(0.32, 0, 0.85, 0),
        Position = UDim2.new(0.34, 0, 0.075, 0),
        Name = "VolumeControl"
    })

    cUI(vcf, "text", {
        Text = "🔊 Volume: " .. math.floor(cv * 100) .. "%",
        TextSize = 13,
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
        TextSize = 11,
        TextColor3 = Color3.fromRGB(180, 180, 180),
        Size = UDim2.new(1, 0, 0.2, 0),
        Position = UDim2.new(0, 0, 0.8, 0),
        Name = "TimeLabel"
    })
    timeLabel = tl

    local cf, cfo = cUI(tb, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.32, 0, 0.85, 0),
        Position = UDim2.new(0.67, 0, 0.075, 0),
        Name = "Controls"
    })

    local plb, plo = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 170, 90),
        Size = UDim2.new(0.22, 0, 0.4, 0),
        Position = UDim2.new(0.02, 0, 0.1, 0),
        Text = "▶",
        TextSize = 15,
        Name = "PlayPauseBtn"
    })

    local stb, sto = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(200, 100, 100),
        Size = UDim2.new(0.22, 0, 0.4, 0),
        Position = UDim2.new(0.26, 0, 0.1, 0),
        Text = "■",
        TextSize = 15,
        Name = "StopBtn"
    })

    local shb, sho = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(100, 150, 200),
        Size = UDim2.new(0.22, 0, 0.4, 0),
        Position = UDim2.new(0.5, 0, 0.1, 0),
        Text = "🔀",
        TextSize = 13,
        Name = "ShuffleBtn"
    })

    local rfb, rfo = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(150, 100, 200),
        Size = UDim2.new(0.22, 0, 0.4, 0),
        Position = UDim2.new(0.74, 0, 0.1, 0),
        Text = "🔄",
        TextSize = 13,
        Name = "RefreshBtn"
    })

    local lpb, lpo = cUI(cf, "button", {
        BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 100, 150),
        Size = UDim2.new(0.47, 0, 0.4, 0),
        Position = UDim2.new(0.02, 0, 0.55, 0),
        Text = isLooped and "🔁 LOOP ON" or "🔁 LOOP OFF",
        TextSize = 11,
        Name = "LoopBtn"
    })

    local scb, sco = cUI(cf, "button", {
        BackgroundColor3 = Color3.fromRGB(200, 150, 100),
        Size = UDim2.new(0.47, 0, 0.4, 0),
        Position = UDim2.new(0.51, 0, 0.55, 0),
        Text = "📁 SCAN",
        TextSize = 11,
        Name = "ScanBtn"
    })

    local sectf, sectfo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(0.95, 0, 0.08, 0),
        Position = UDim2.new(0.025, 0, 0.21, 0),
        Name = "SectionFrame"
    })

    local localBtn, localBtnO = cUI(sectf, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.2, 0, 0.7, 0),
        Position = UDim2.new(0.02, 0, 0.15, 0),
        Text = "📁 LOCAL",
        TextSize = 12,
        Name = "LocalBtn"
    })

    local cloudBtn, cloudBtnO = cUI(sectf, "button", {
        BackgroundColor3 = Color3.fromRGB(100, 100, 150),
        Size = UDim2.new(0.2, 0, 0.7, 0),
        Position = UDim2.new(0.24, 0, 0.15, 0),
        Text = "☁ CLOUD",
        TextSize = 12,
        Name = "CloudBtn"
    })

    local af, afo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(0.95, 0, 0.09, 0),
        Position = UDim2.new(0.025, 0, 0.3, 0),
        Name = "UnifiedInputFrame"
    })

    local ni, nio = cUI(af, "input", {
        Size = UDim2.new(0.25, 0, 0.6, 0),
        Position = UDim2.new(0.02, 0, 0.2, 0),
        PlaceholderText = "Music Name",
        TextSize = 13,
        Name = "NameInput"
    })

    local ui, uio = cUI(af, "input", {
        Size = UDim2.new(0.5, 0, 0.6, 0),
        Position = UDim2.new(0.29, 0, 0.2, 0),
        PlaceholderText = "Direct URL to music file (.mp3, .ogg, .wav, .m4a, .flac)",
        TextSize = 13,
        Name = "UrlInput"
    })

    local ab, abo = cUI(af, "button", {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.17, 0, 0.6, 0),
        Position = UDim2.new(0.81, 0, 0.2, 0),
        Text = "📥 ADD",
        TextSize = 12,
        Name = "AddBtn"
    })

    local sf, sfo = cUI(af, "input", {
        Size = UDim2.new(0.3, 0, 0.6, 0),
        Position = UDim2.new(0.02, 0, 0.2, 0),
        PlaceholderText = "🔍 Search music...",
        TextSize = 12,
        Name = "SearchInput",
        Visible = false
    })
    searchInput = sf

    local gdf, gdb, gdl = cUI(af, "dropdown", {
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.34, 0, 0.2, 0),
        Text = "🎵 All Genres",
        TextSize = 11,
        Name = "GenreDropdown",
        ZIndex = 50,
        Visible = false
    })

    local udf, udb, udl = cUI(af, "dropdown", {
        Size = UDim2.new(0.2, 0, 0.6, 0),
        Position = UDim2.new(0.56, 0, 0.2, 0),
        Text = "👤 All Users",
        TextSize = 11,
        Name = "UploaderDropdown",
        ZIndex = 50,
        Visible = false
    })

    local mlf, mlfo = cUI(mp, "container", {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(0.95, 0, 0.58, 0),
        Position = UDim2.new(0.025, 0, 0.4, 0),
        Name = "MusicListFrame"
    })

    local mls = FW.cSF(mlf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.98, 0, 0.95, 0),
        Position = UDim2.new(0.01, 0, 0.025, 0),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "MusicListScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210),
        Visible = true
    })
    sr = mls

    local cmls = FW.cSF(mlf, {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.98, 0, 0.95, 0),
        Position = UDim2.new(0.01, 0, 0.025, 0),
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
            if isfile(filePath) then
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
    local function getLocalFiles()
        return safeListFiles(md, { isLocal = true })
    end
    local function getCloudFiles()
        return safeListFiles(cd, { isCloud = true, isCached = true })
    end

    local function updateGenresAndUploaders()
        availableGenres = {}
        availableUploaders = {}

        for _, song in pairs(cl) do
            if song.genre and song.genre ~= "" and song.genre ~= "Unknown" then
                local found = false
                for _, g in pairs(availableGenres) do
                    if g:lower() == song.genre:lower() then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(availableGenres, song.genre)
                end
            end

            if song.uploader_name and song.uploader_name ~= "" and song.uploader_name ~= "Unknown" then
                local found = false
                for _, u in pairs(availableUploaders) do
                    if u:lower() == song.uploader_name:lower() then
                        found = true
                        break
                    end
                end
                if not found then
                    table.insert(availableUploaders, song.uploader_name)
                end
            end
        end

        table.sort(availableGenres, function(a, b) return a:lower() < b:lower() end)
        table.sort(availableUploaders, function(a, b) return a:lower() < b:lower() end)
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
            local searchQuery = qry:lower()

            for nm, dt in pairs(cl) do
                local matchesSearch = qry == "" or nm:lower():find(searchQuery) or
                                     (dt.title and dt.title:lower():find(searchQuery))

                local matchesGenre = currentGenreFilter == "" or (dt.genre and dt.genre:lower() == currentGenreFilter:lower())
                local matchesUploader = currentUploaderFilter == "" or (dt.uploader_name and dt.uploader_name:lower() == currentUploaderFilter:lower())

                if matchesSearch and matchesGenre and matchesUploader then
                    fcl[nm] = dt
                end
            end
        end
        upML()
    end

    local function updateDropdownPosition(dropdownList, dropdownButtonFrame)
        if dropdownList and dropdownButtonFrame then
            local buttonFramePos = dropdownButtonFrame.Position
            local buttonFrameSize = dropdownButtonFrame.Size

            local maxHeight = 150
            local itemCount = 0
            for _, child in pairs(dropdownList:GetChildren()) do
                if child:IsA("TextButton") then
                    itemCount = itemCount + 1
                end
            end

            local neededHeight = math.min(itemCount * 35 + 10, maxHeight)

            dropdownList.Position = UDim2.new(
                buttonFramePos.X.Scale, buttonFramePos.X.Offset,
                buttonFramePos.Y.Scale, buttonFramePos.Y.Offset - neededHeight - 10
            )

            dropdownList.Size = UDim2.new(buttonFrameSize.X.Scale, buttonFrameSize.X.Offset, 0, neededHeight)
        end
    end

    local function updateDropdowns()
        local children = gdl:GetChildren()
        for i = 1, #children do
            if children[i]:IsA("TextButton") then
                children[i]:Destroy()
            end
        end

        children = udl:GetChildren()
        for i = 1, #children do
            if children[i]:IsA("TextButton") then
                children[i]:Destroy()
            end
        end

        local yPos = 0
        local allGenreBtn = FW.cB(gdl, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, yPos),
            Text = "🎵 All Genres",
            TextColor3 = Color3.fromRGB(240, 245, 255),
            TextSize = 11,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Name = "AllGenres",
            ZIndex = 201
        })
        FW.cC(allGenreBtn, 0.15)
        FW.cTC(allGenreBtn, 11)
        yPos = yPos + 35

        allGenreBtn.MouseButton1Click:Connect(function()
            currentGenreFilter = ""
            gdb.Text = "🎵 All Genres"
            gdl.Visible = false
            ftM(searchInput and searchInput.Text or "")
        end)

        for _, genre in pairs(availableGenres) do
            local genreBtn = FW.cB(gdl, {
                BackgroundColor3 = Color3.fromRGB(35, 40, 50),
                Size = UDim2.new(1, -10, 0, 30),
                Position = UDim2.new(0, 5, 0, yPos),
                Text = "🎵 " .. genre,
                TextColor3 = Color3.fromRGB(240, 245, 255),
                TextSize = 11,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Name = "Genre_" .. genre,
                ZIndex = 201
            })
            FW.cC(genreBtn, 0.15)
            FW.cTC(genreBtn, 11)
            yPos = yPos + 35

            genreBtn.MouseButton1Click:Connect(function()
                currentGenreFilter = genre
                gdb.Text = "🎵 " .. genre
                gdl.Visible = false
                ftM(searchInput and searchInput.Text or "")
            end)
        end

        gdl.CanvasSize = UDim2.new(0, 0, 0, yPos)

        yPos = 0
        local allUserBtn = FW.cB(udl, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            Size = UDim2.new(1, -10, 0, 30),
            Position = UDim2.new(0, 5, 0, yPos),
            Text = "👤 All Users",
            TextColor3 = Color3.fromRGB(240, 245, 255),
            TextSize = 11,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Name = "AllUsers",
            ZIndex = 201
        })
        FW.cC(allUserBtn, 0.15)
        FW.cTC(allUserBtn, 11)
        yPos = yPos + 35

        allUserBtn.MouseButton1Click:Connect(function()
            currentUploaderFilter = ""
            udb.Text = "👤 All Users"
            udl.Visible = false
            ftM(searchInput and searchInput.Text or "")
        end)

        for _, uploader in pairs(availableUploaders) do
            local uploaderBtn = FW.cB(udl, {
                BackgroundColor3 = Color3.fromRGB(35, 40, 50),
                Size = UDim2.new(1, -10, 0, 30),
                Position = UDim2.new(0, 5, 0, yPos),
                Text = "👤 " .. uploader,
                TextColor3 = Color3.fromRGB(240, 245, 255),
                TextSize = 11,
                FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
                Name = "User_" .. uploader,
                ZIndex = 201
            })
            FW.cC(uploaderBtn, 0.15)
            FW.cTC(uploaderBtn, 11)
            yPos = yPos + 35

            uploaderBtn.MouseButton1Click:Connect(function()
                currentUploaderFilter = uploader
                udb.Text = "👤 " .. uploader
                udl.Visible = false
                ftM(searchInput and searchInput.Text or "")
            end)
        end

        udl.CanvasSize = UDim2.new(0, 0, 0, yPos)
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
                return game:HttpGet(CLOUD_TXT_URL)
            end)

            if success then
                local lines = {}
                for line in response:gmatch("([^\n]+)") do
                    table.insert(lines, line)
                end

                local cachedFiles = getCloudFiles()
                cl = {}

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

                        cl[key] = {
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

                fcl = cl
                updateGenresAndUploaders()
                updateDropdowns()
                if currentSection == "cloud" then upML() end

                local count = 0
                for _ in pairs(cl) do count = count + 1 end
                FW.showAlert("Success", "Cloud music list updated! Found " .. count .. " songs", 2)
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

    local function switchSection(section)
        currentSection = section
        if section == "local" then
            localBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
            cloudBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)

            ni.Visible = true
            nio.Visible = true
            ui.Visible = true
            uio.Visible = true
            ab.Visible = true
            abo.Visible = true

            sf.Visible = false
            sfo.Visible = false
            gdf.Visible = false
            udf.Visible = false
            gdl.Visible = false
            udl.Visible = false

            rfb.Text = "📁 SCAN"
            scb.Text = "📁 SCAN"
        else
            localBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 150)
            cloudBtn.BackgroundColor3 = Color3.fromRGB(50, 130, 210)

            ni.Visible = false
            nio.Visible = false
            ui.Visible = false
            uio.Visible = false
            ab.Visible = false
            abo.Visible = false

            sf.Visible = true
            sfo.Visible = true
            gdf.Visible = true
            udf.Visible = true

            rfb.Text = "🔄 REFRESH"
            scb.Text = "🔄 REFRESH"
        end
        ftM(searchInput and searchInput.Text or "")
    end

    function upML()
        local currentList = currentSection == "local" and fl or fcl
        local scrollFrame = currentSection == "local" and sr or csr

        sr.Visible = currentSection == "local"
        csr.Visible = currentSection == "cloud"

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

            table.sort(sortedMusic, function(a, b) return a.name:lower() < b.name:lower() end)

            for i = 1, #sortedMusic do
                local entry = sortedMusic[i]
                local nm = entry.name
                local dt = entry.data
                idx = idx + 1

                local mc = FW.cF(scrollFrame, {
                    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                    Size = UDim2.new(0.98, 0, 0, 75),
                    Position = UDim2.new(0.01, 0, 0, yp),
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
                    Size = UDim2.new(0, 55, 0, 55),
                    Position = UDim2.new(0, 10, 0, 10),
                    Name = "MusicIcon"
                })
                FW.cC(ico, 0.3)
                FW.cG(ico, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))

                cUI(ico, "text", {
                    Text = cp == nm and (cm and cm.IsPlaying and "♪" or "⏸") or (currentSection == "cloud" and "☁" or "♫"),
                    TextSize = cp == nm and 22 or 20,
                    TextColor3 = Color3.fromRGB(29, 29, 38),
                    Name = "MusicEmoji"
                })

                cUI(mc, "text", {
                    Text = nm,
                    TextSize = 15,
                    Size = UDim2.new(0.35, 0, 0.35, 0),
                    Position = UDim2.new(0, 75, 0, 2),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "MusicTitle"
                })

                local statusText = ""
                local infoText = ""
                if currentSection == "cloud" then
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

                cUI(mc, "text", {
                    Text = statusText,
                    TextSize = 12,
                    TextColor3 = Color3.fromRGB(160, 170, 190),
                    Size = UDim2.new(0.35, 0, 0.25, 0),
                    Position = UDim2.new(0, 75, 0, 28),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "MusicStatus"
                })

                if infoText ~= "" then
                    cUI(mc, "text", {
                        Text = infoText,
                        TextSize = 11,
                        TextColor3 = Color3.fromRGB(140, 150, 170),
                        Size = UDim2.new(0.35, 0, 0.25, 0),
                        Position = UDim2.new(0, 75, 0, 50),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "MusicInfo"
                    })
                end

                if downloadProgress[dt.filename] then
                    local prog = downloadProgress[dt.filename]
                    cUI(mc, "text", {
                        Text = "Downloading... " .. prog .. "%",
                        TextSize = 12,
                        TextColor3 = Color3.fromRGB(100, 200, 255),
                        Size = UDim2.new(0.35, 0, 0.25, 0),
                        Position = UDim2.new(0, 75, 0, 65),
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Name = "DownloadProgress"
                    })
                end

                local pb, po = cUI(mc, "button", {
                    BackgroundColor3 = cp == nm and (cm and cm.IsPlaying and Color3.fromRGB(255, 150, 100) or Color3.fromRGB(100, 200, 100)) or Color3.fromRGB(50, 170, 90),
                    Size = UDim2.new(0.13, 0, 0.4, 0),
                    Position = UDim2.new(0.63, 0, 0.1, 0),
                    Text = cp == nm and (cm and cm.IsPlaying and "PAUSE" or "RESUME") or "PLAY",
                    TextSize = 11,
                    Name = "PlayBtn"
                })

                local stb, sto = cUI(mc, "button", {
                    BackgroundColor3 = Color3.fromRGB(100, 100, 200),
                    Size = UDim2.new(0.13, 0, 0.4, 0),
                    Position = UDim2.new(0.63, 0, 0.55, 0),
                    Text = "STOP",
                    TextSize = 11,
                    Name = "StopBtn"
                })

                local rb, ro = cUI(mc, "button", {
                    BackgroundColor3 = Color3.fromRGB(200, 100, 100),
                    Size = UDim2.new(0.11, 0, 0.4, 0),
                    Position = UDim2.new(0.77, 0, 0.1, 0),
                    Text = "REMOVE",
                    TextSize = 10,
                    Name = "RemoveBtn"
                })

                local lb, lo = cUI(mc, "button", {
                    BackgroundColor3 = isLooped and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(100, 150, 200),
                    Size = UDim2.new(0.11, 0, 0.4, 0),
                    Position = UDim2.new(0.77, 0, 0.55, 0),
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

                yp = yp + 80
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
        if FW.isAnimating then FW.stopCurrentTweens() end
        switchSection("local")
    end)

    cloudBtn.MouseButton1Click:Connect(function()
        if FW.isAnimating then FW.stopCurrentTweens() end
        switchSection("cloud")
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

    gdb.MouseButton1Click:Connect(function()
        updateDropdownPosition(gdl, gdf)
        gdl.Visible = not gdl.Visible
        udl.Visible = false
    end)

    udb.MouseButton1Click:Connect(function()
        updateDropdownPosition(udl, udf)
        udl.Visible = not udl.Visible
        gdl.Visible = false
    end)

    game:GetService("UserInputService").InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local target = input.Target
            if target and target.Parent then
                local isDropdownElement = false
                local current = target
                while current and current ~= game do
                    if current.Name:find("Dropdown_Frame") or current.Name:find("Dropdown_List") then
                        isDropdownElement = true
                        break
                    end
                    current = current.Parent
                end

                if not isDropdownElement then
                    gdl.Visible = false
                    udl.Visible = false
                end
            end
        end
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

    switchSection("local")
    upML()
    updateNowPlaying("No music selected", "⏹ Stopped", Color3.fromRGB(200, 200, 200))
    upProg()

    spawn(function()
        wait(3)
        fetchCloudList()
        FW.showAlert("Success", "🎵 Music system loaded!", 2)
    end)

    spawn(function()
        while true do
            if cm and cm.IsPlaying then
                currentTime = cm.TimePosition
                totalTime = cm.TimeLength
                upProg()
            end
            wait(0.5)
        end
    end)
end)
