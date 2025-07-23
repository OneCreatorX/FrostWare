spawn(function()
wait(1)
local FW = getgenv()._FW or {}
local ts = game:GetService("TweenService")
local rs = game:GetService("RunService")
local http = game:GetService("HttpService")

if not FW.cF then
    FW.cF = function(p, pr) local f = Instance.new("Frame"); for k,v in pairs(pr) do f[k]=v end; f.Parent = p; return f end
    FW.cT = function(p, pr) local t = Instance.new("TextLabel"); for k,v in pairs(pr) do t[k]=v end; t.Parent = p; return t end
    FW.cB = function(p, pr) local b = Instance.new("TextButton"); for k,v in pairs(pr) do b[k]=v end; b.Parent = p; return b end
    FW.cI = function(p, pr) local i = Instance.new("ImageLabel"); for k,v in pairs(pr) do i[k]=v end; i.Parent = p; return i end
    FW.cC = function(obj, radius) local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius); c.Parent = obj end
    FW.cTC = function(obj, size) obj.TextScaled = true; obj.TextSize = size end
    FW.cG = function(obj, c1, c2) local g = Instance.new("UIGradient"); g.Color = ColorSequence.new(c1, c2); g.Parent = obj end
    FW.cAR = function(obj, ratio) local ar = Instance.new("UIAspectRatioConstraint"); ar.AspectRatio = ratio; ar.Parent = obj end
    FW.showAlert = function(type, msg, duration) warn(type .. ": " .. msg) end
    FW.getUI = function() return {["11"] = game.Players.LocalPlayer:WaitForChild("PlayerGui"), ["6"] = game.Players.LocalPlayer:WaitForChild("PlayerGui")} end
    FW.switchPage = function(pageName, sidebar)
        local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")
        for _, child in pairs(playerGui:GetChildren()) do
            if child:IsA("Frame") and child.Name:find("Page") then
                child.Visible = false
            end
        end
        local targetPage = playerGui:FindFirstChild(pageName .. "Page")
        if targetPage then targetPage.Visible = true end
    end
end

local lv = {}
local cv = {}
local ci = 1
local cu = "https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/videos.json"
local dp = 0
local cs = "local"
local cc = "all"
local ct = {}
local sf = ""

local vp, vf, pb1, sb, nb, prb, fsb, pgb, pgh, pgbb, tl, vlf, clf, dui, dni, db, dpb, dpl
local pp, lp, cp, dp2, ctf, sif, fsf

local function fv(d)
    local v = {}
    local function sd(dr)
        for _, p in ipairs(listfiles(dr)) do
            if isfolder(p) then
                sd(p)
            elseif p:lower():match("%.mp4$") then
                table.insert(v, p)
            end
        end
    end
    sd(d)
    return v
end

local function ft(s)
    local m = math.floor(s / 60)
    local sc = math.floor(s % 60)
    return string.format("%02d:%02d", m, sc)
end

local function upb()
    if vf and pgh and tl and vf.TimeLength > 0 then
        local pr = vf.TimePosition / vf.TimeLength
        pgh.Size = UDim2.new(pr, 0, 1, 0)
        tl.Text = ft(vf.TimePosition) .. " / " .. ft(vf.TimeLength)
    else
        pgh.Size = UDim2.new(0, 0, 1, 0)
        tl.Text = "00:00 / 00:00"
    end
end

local function pcv()
    if #lv == 0 then 
        FW.showAlert("Info", "No videos available", 2)
        return 
    end
    vf.Playing = false
    wait(0.1)
    vf.Video = getsynasset(lv[ci])
    wait(0.1)
    vf.Playing = true
    local vn = lv[ci]:match("[^/]+$")
    FW.showAlert("Info", "Playing: " .. vn, 1)
    cs = "local"
end

local function pclv(u, n)
    vf.Playing = false
    wait(0.1)
    FW.showAlert("Info", "Loading video...", 2)
    spawn(function()
        local s, c = pcall(function()
            return game:HttpGet(u)
        end)
        if s and c and #c > 0 then
            local fn = n or u:match(".*/([^/%.]+)%.mp4$") or http:GenerateGUID(false)
            if not fn:match("%.mp4$") then
                fn = fn .. ".mp4"
            end
            local tp = "synapse/temp_videos/" .. fn
            if not isfolder("synapse") then makefolder("synapse") end
            if not isfolder("synapse/temp_videos") then makefolder("synapse/temp_videos") end
            local ws = pcall(function()
                writefile(tp, c)
            end)
            if ws then
                wait(0.1)
                vf.Video = getsynasset(tp)
                wait(0.1)
                vf.Playing = true
                FW.showAlert("Success", "Playing: " .. fn, 1)
                cs = "cloud"
            else
                FW.showAlert("Error", "Error saving video", 2)
            end
        else
            FW.showAlert("Error", "Error loading video", 2)
        end
    end)
end

local function tpp()
    if vf then
        if vf.Playing then
            vf:Pause()
            pb1.Text = "▶ Play"
        else
            vf:Play()
            pb1.Text = "⏸ Pause"
        end
    end
end

local function sv()
    if vf then
        vf:Stop()
        vf.TimePosition = 0
        pb1.Text = "▶ Play"
        upb()
    end
end

local function nv()
    if cs == "local" and #lv > 0 then
        ci = ci + 1
        if ci > #lv then ci = 1 end
        pcv()
    elseif cs == "cloud" and #cv > 0 then
        ci = ci + 1
        if ci > #cv then ci = 1 end
        local v = cv[ci]
        pclv(v.url, v.name)
    end
end

local function pv()
    if cs == "local" and #lv > 0 then
        ci = ci - 1
        if ci < 1 then ci = #lv end
        pcv()
    elseif cs == "cloud" and #cv > 0 then
        ci = ci - 1
        if ci < 1 then ci = #cv end
        local v = cv[ci]
        pclv(v.url, v.name)
    end
end

local function tfs()
    local pg = FW.getUI()["11"]
    local ifs = vf.Parent == fsf

    if ifs then
        vf.Parent = pp
        vf.Size = UDim2.new(0.95, 0, 0.7, 0)
        vf.Position = UDim2.new(0.025, 0, 0.02, 0)
        vf.ZIndex = 1
        pp.Visible = true
        fsb.Text = "⛶ Full"
        fsf.Visible = false
    else
        fsf.Visible = true
        vf.Parent = fsf
        vf.Size = UDim2.new(0.9, 0, 0.85, 0)
        vf.Position = UDim2.new(0.05, 0, 0.05, 0)
        vf.ZIndex = 15
        fsf.ZIndex = 10
        pp.Visible = false
        fsb.Text = "🗗 Exit"
    end
end

local function rlv()
    lv = fv("/")
    vlf.CanvasSize = UDim2.new(0,0,0,0)
    for _, ch in pairs(vlf:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    local yo = 0
    for i, vp2 in ipairs(lv) do
        local vn = vp2:match("[^/]+$")
        local vb = FW.cB(vlf, {
            Size = UDim2.new(0.96, 0, 0, 40),
            Position = UDim2.new(0.02, 0, 0, yo),
            Text = vn,
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Name = "VB" .. i
        })
        FW.cC(vb, 8)
        FW.cTC(vb, 14)
        vb.MouseButton1Click:Connect(function()
            ci = i
            pcv()
        end)
        yo = yo + 45
    end
    vlf.CanvasSize = UDim2.new(0,0,0,yo)
    if #lv == 0 then
        local nt = FW.cT(vlf, {
            Text = "No local videos found",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Size = UDim2.new(1,0,0,40),
            Position = UDim2.new(0,0,0,10),
            BackgroundTransparency = 1
        })
        FW.cTC(nt, 16)
    end
end

local function gct()
    ct = {}
    for _, v in ipairs(cv) do
        if v.category and not ct[v.category] then
            ct[v.category] = true
        end
    end
end

local function rct()
    ctf.CanvasSize = UDim2.new(0,0,0,0)
    for _, ch in pairs(ctf:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    
    local yo = 5
    local ab = FW.cB(ctf, {
        Size = UDim2.new(0.9, 0, 0, 25),
        Position = UDim2.new(0.05, 0, 0, yo),
        Text = "All",
        TextSize = 12,
        BackgroundColor3 = cc == "all" and Color3.fromRGB(0, 123, 255) or Color3.fromRGB(50, 60, 70),
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Name = "AllBtn"
    })
    FW.cC(ab, 6)
    FW.cTC(ab, 12)
    ab.MouseButton1Click:Connect(function()
        cc = "all"
        rct()
        fcv()
    end)
    yo = yo + 30
    
    for cat, _ in pairs(ct) do
        local cb = FW.cB(ctf, {
            Size = UDim2.new(0.9, 0, 0, 25),
            Position = UDim2.new(0.05, 0, 0, yo),
            Text = cat,
            TextSize = 12,
            BackgroundColor3 = cc == cat and Color3.fromRGB(0, 123, 255) or Color3.fromRGB(50, 60, 70),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Name = cat .. "Btn"
        })
        FW.cC(cb, 6)
        FW.cTC(cb, 12)
        cb.MouseButton1Click:Connect(function()
            cc = cat
            rct()
            fcv()
        end)
        yo = yo + 30
    end
    ctf.CanvasSize = UDim2.new(0,0,0,yo + 5)
end

local function fcv()
    FW.showAlert("Info", "Loading cloud videos...", 2)
    clf.CanvasSize = UDim2.new(0,0,0,0)
    for _, ch in pairs(clf:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    
    local fv2 = {}
    for i, v in ipairs(cv) do
        local mn = (cc == "all" or v.category == cc)
        local sn = (sf == "" or v.name:lower():find(sf:lower()))
        if mn and sn then
            table.insert(fv2, {index = i, video = v})
        end
    end
    
    local yo = 0
    for _, item in ipairs(fv2) do
        local v = item.video
        local i = item.index
        local vb = FW.cB(clf, {
            Size = UDim2.new(0.96, 0, 0, 50),
            Position = UDim2.new(0.02, 0, 0, yo),
            Text = "",
            TextSize = 14,
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Name = "CB" .. i
        })
        FW.cC(vb, 8)
        
        local nt = FW.cT(vb, {
            Text = v.name,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, -10, 0.6, 0),
            Position = UDim2.new(0, 5, 0, 2),
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1
        })
        FW.cTC(nt, 14)
        
        if v.category then
            local ct2 = FW.cT(vb, {
                Text = "Category: " .. v.category,
                TextSize = 11,
                TextColor3 = Color3.fromRGB(150, 150, 150),
                Size = UDim2.new(1, -10, 0.4, 0),
                Position = UDim2.new(0, 5, 0.6, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                BackgroundTransparency = 1
            })
            FW.cTC(ct2, 11)
        end
        
        vb.MouseButton1Click:Connect(function()
            ci = i
            pclv(v.url, v.name)
        end)
        yo = yo + 55
    end
    clf.CanvasSize = UDim2.new(0,0,0,yo)
    
    if #fv2 == 0 then
        local nt = FW.cT(clf, {
            Text = "No videos found",
            TextSize = 16,
            TextColor3 = Color3.fromRGB(150, 150, 150),
            Size = UDim2.new(1,0,0,40),
            Position = UDim2.new(0,0,0,10),
            BackgroundTransparency = 1
        })
        FW.cTC(nt, 16)
    end
end

local function lcv()
    spawn(function()
        local s, r = pcall(function()
            return game:HttpGet(cu)
        end)
        if s and r then
            local data = http:JSONDecode(r)
            cv = data.videos or {}
            gct()
            rct()
            fcv()
            FW.showAlert("Success", "Videos loaded: " .. #cv, 1)
        else
            FW.showAlert("Error", "Error loading cloud videos", 2)
        end
    end)
end

local function udp(pr)
    dp = pr
    if dpb and dpl then
        dpb.Size = UDim2.new(pr / 100, 0, 1, 0)
        dpl.Text = math.floor(pr) .. "%"
    end
end

local function dv()
    local u = dui.Text
    local n = dni.Text
    if not u or u == "" then
        FW.showAlert("Error", "URL required", 2)
        return
    end
    if not n or n == "" then
        n = u:match(".*/([^/%.]+)%.mp4$") or http:GenerateGUID(false)
    end
    if not n:lower():match("%.mp4$") then
        n = n .. ".mp4"
    end

    FW.showAlert("Info", "Downloading " .. n .. "...", 3)
    udp(0)
    
    spawn(function()
        local s, c = pcall(function()
            return game:HttpGet(u)
        end)
        if s and c and #c > 0 then
            if not isfolder("synapse") then makefolder("synapse") end
            if not isfolder("synapse/videos") then makefolder("synapse/videos") end
            
            for i = 1, 100, 5 do
                udp(i)
                wait(0.05)
            end
            
            local ws = pcall(function()
                writefile("synapse/videos/" .. n, c)
            end)
            if ws then
                udp(100)
                FW.showAlert("Success", n .. " downloaded!", 2)
                dui.Text = ""
                dni.Text = ""
                wait(1)
                udp(0)
                rlv()
            else
                FW.showAlert("Error", "Error saving file", 3)
                udp(0)
            end
        else
            FW.showAlert("Error", "Error downloading video", 3)
            udp(0)
        end
    end)
end

local function sp(pn)
    pp.Visible = false
    lp.Visible = false
    cp.Visible = false
    dp2.Visible = false

    if pn == "player" then
        pp.Visible = true
    elseif pn == "local" then
        lp.Visible = true
        rlv()
    elseif pn == "cloud" then
        cp.Visible = true
        lcv()
    elseif pn == "download" then
        dp2.Visible = true
    end
end

local function cui(p, t, pr)
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
            Name = props.Name or "ST"
        })
        FW.cTC(txt, props.TextSize or 16)
        return txt
    elseif t == "button" then
        local btn = FW.cB(p, {
            BackgroundColor3 = props.BackgroundColor3 or Color3.fromRGB(50, 130, 210),
            Size = props.Size,
            Position = props.Position,
            Text = props.Text or "",
            TextColor3 = props.TextColor3 or Color3.fromRGB(255, 255, 255),
            TextSize = props.TextSize or 14,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Name = props.Name or "B"
        })
        FW.cC(btn, 8)
        FW.cTC(btn, props.TextSize or 14)
        return btn
    elseif t == "slider" then
        local sf2 = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = props.Size,
            Position = props.Position,
            Name = (props.Name or "S") .. "_T"
        })
        local sh = FW.cF(sf2, {
            BackgroundColor3 = Color3.fromRGB(166, 190, 255),
            Size = UDim2.new(props.Value or 0, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = (props.Name or "S") .. "_H"
        })
        FW.cG(sh, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        local sb2 = FW.cB(sf2, {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Text = "",
            Name = (props.Name or "S") .. "_B"
        })
        return sf2, sh, sb2
    elseif t == "textbox" then
        local tb = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = props.Size,
            Position = props.Position,
            Name = (props.Name or "TB") .. "_O"
        })
        local inp = Instance.new("TextBox")
        inp.Parent = tb
        inp.Size = UDim2.new(0.96, 0, 0.8, 0)
        inp.Position = UDim2.new(0.02, 0, 0.1, 0)
        inp.BackgroundColor3 = Color3.fromRGB(30, 35, 45)
        inp.TextColor3 = Color3.fromRGB(240, 245, 255)
        inp.TextSize = props.TextSize or 14
        inp.Text = props.Text or ""
        inp.PlaceholderText = props.PlaceholderText or ""
        inp.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
        inp.Font = Enum.Font.SourceSans
        inp.ClearTextOnFocus = false
        inp.Name = props.Name or "TB"
        FW.cTC(inp, props.TextSize or 14)
        return inp, tb
    elseif t == "scrollingframe" then
        local sf3 = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 30),
            Size = props.Size,
            Position = props.Position,
            Name = (props.Name or "SF") .. "_O"
        })
        local scr = Instance.new("ScrollingFrame")
        scr.Parent = sf3
        scr.Size = UDim2.new(1, 0, 1, 0)
        scr.BackgroundTransparency = 1
        scr.CanvasSize = UDim2.new(0, 0, 0, 0)
        scr.ScrollBarThickness = 6
        scr.ScrollBarImageColor3 = Color3.fromRGB(93, 117, 160)
        scr.Name = props.Name or "SF"
        return scr, sf3
    end
end

vp = FW.cI(FW.getUI()["11"], {
    ImageTransparency = 1,
    ImageColor3 = Color3.fromRGB(15, 18, 25),
    Image = "rbxassetid://18665679839",
    Size = UDim2.new(1, 0, 1, 0),
    Visible = false,
    ClipsDescendants = true,
    BackgroundTransparency = 1,
    Name = "VideoPlayerPage",
    Position = UDim2.new(0, 0, 0, 0)
})

fsf = FW.cF(FW.getUI()["11"], {
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Visible = false,
    ZIndex = 10,
    Name = "FullscreenFrame"
})

local fec = FW.cB(fsf, {
    BackgroundColor3 = Color3.fromRGB(200, 50, 50),
    Size = UDim2.new(0, 80, 0, 25),
    Position = UDim2.new(1, -90, 0, 10),
    Text = "Exit",
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextSize = 12,
    ZIndex = 20,
    Name = "ExitFullBtn"
})
FW.cC(fec, 6)
FW.cTC(fec, 12)
fec.MouseButton1Click:Connect(tfs)

local tl2 = cui(vp, "text", {
    Text = "🎥 ONX-DEV Video Player",
    TextSize = 24,
    TextColor3 = Color3.fromRGB(0, 123, 255),
    Size = UDim2.new(1, 0, 0.08, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Name = "TL"
})

local nf = FW.cF(vp, {
    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
    Size = UDim2.new(1, 0, 0.06, 0),
    Position = UDim2.new(0, 0, 0.08, 0),
    Name = "NF"
})
FW.cC(nf, 8)

local pnb = cui(nf, "button", {
    Size = UDim2.new(0.22, 0, 0.9, 0),
    Position = UDim2.new(0.04, 0, 0.05, 0),
    Text = "Player",
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
    Name = "PNB"
})
pnb.MouseButton1Click:Connect(function() sp("player") end)

local lnb = cui(nf, "button", {
    Size = UDim2.new(0.22, 0, 0.9, 0),
    Position = UDim2.new(0.27, 0, 0.05, 0),
    Text = "Local",
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
    Name = "LNB"
})
lnb.MouseButton1Click:Connect(function() sp("local") end)

local cnb = cui(nf, "button", {
    Size = UDim2.new(0.22, 0, 0.9, 0),
    Position = UDim2.new(0.5, 0, 0.05, 0),
    Text = "Cloud",
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
    Name = "CNB"
})
cnb.MouseButton1Click:Connect(function() sp("cloud") end)

local dnb = cui(nf, "button", {
    Size = UDim2.new(0.22, 0, 0.9, 0),
    Position = UDim2.new(0.73, 0, 0.05, 0),
    Text = "Download",
    TextSize = 14,
    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
    Name = "DNB"
})
dnb.MouseButton1Click:Connect(function() sp("download") end)

pp = FW.cF(vp, {
    BackgroundColor3 = Color3.fromRGB(15, 18, 25),
    Size = UDim2.new(1, 0, 0.86, 0),
    Position = UDim2.new(0, 0, 0.14, 0),
    Name = "PP",
    ClipsDescendants = true
})

vf = Instance.new("VideoFrame")
vf.Size = UDim2.new(0.95, 0, 0.7, 0)
vf.Position = UDim2.new(0.025, 0, 0.02, 0)
vf.AnchorPoint = Vector2.new(0, 0)
vf.Looped = false
vf.Playing = false
vf.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
vf.Parent = pp

local cf = FW.cF(pp, {
    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
    Size = UDim2.new(0.95, 0, 0.26, 0),
    Position = UDim2.new(0.025, 0, 0.73, 0),
    Name = "CF"
})

pgb, pgh, pgbb = cui(cf, "slider", {
    Size = UDim2.new(0.65, 0, 0.15, 0),
    Position = UDim2.new(0.03, 0, 0.08, 0),
    Value = 0,
    Name = "PGB"
})

tl = cui(cf, "text", {
    Text = "00:00 / 00:00",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(180, 180, 180),
    Size = UDim2.new(0.28, 0, 0.15, 0),
    Position = UDim2.new(0.7, 0, 0.08, 0),
    TextXAlignment = Enum.TextXAlignment.Center,
    Name = "TL"
})

pb1 = cui(cf, "button", {
    BackgroundColor3 = Color3.fromRGB(50, 170, 90),
    Size = UDim2.new(0.18, 0, 0.25, 0),
    Position = UDim2.new(0.03, 0, 0.35, 0),
    Text = "▶ Play",
    TextSize = 12,
    Name = "PB1"
})

sb = cui(cf, "button", {
    BackgroundColor3 = Color3.fromRGB(200, 100, 100),
    Size = UDim2.new(0.18, 0, 0.25, 0),
    Position = UDim2.new(0.22, 0, 0.35, 0),
    Text = "■ Stop",
    TextSize = 12,
    Name = "SB"
})

nb = cui(cf, "button", {
    BackgroundColor3 = Color3.fromRGB(100, 150, 200),
    Size = UDim2.new(0.18, 0, 0.25, 0),
    Position = UDim2.new(0.41, 0, 0.35, 0),
    Text = "Next",
    TextSize = 12,
    Name = "NB"
})

prb = cui(cf, "button", {
    BackgroundColor3 = Color3.fromRGB(100, 150, 200),
    Size = UDim2.new(0.18, 0, 0.25, 0),
    Position = UDim2.new(0.6, 0, 0.35, 0),
    Text = "Prev",
    TextSize = 12,
    Name = "PRB"
})

fsb = cui(cf, "button", {
    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
    Size = UDim2.new(0.18, 0, 0.25, 0),
    Position = UDim2.new(0.79, 0, 0.35, 0),
    Text = "⛶ Full",
    TextSize = 12,
    Name = "FSB"
})

lp = FW.cF(vp, {
    BackgroundColor3 = Color3.fromRGB(15, 18, 25),
    Size = UDim2.new(1, 0, 0.86, 0),
    Position = UDim2.new(0, 0, 0.14, 0),
    Name = "LP",
    Visible = false
})

vlf, _ = cui(lp, "scrollingframe", {
    Size = UDim2.new(0.96, 0, 0.95, 0),
    Position = UDim2.new(0.02, 0, 0.02, 0),
    Name = "VLF"
})

cp = FW.cF(vp, {
    BackgroundColor3 = Color3.fromRGB(15, 18, 25),
    Size = UDim2.new(1, 0, 0.86, 0),
    Position = UDim2.new(0, 0, 0.14, 0),
    Name = "CP",
    Visible = false
})

cui(cp, "text", {
    Text = "Categories:",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(200, 200, 200),
    Size = UDim2.new(0.2, 0, 0.04, 0),
    Position = UDim2.new(0.02, 0, 0.02, 0),
    TextXAlignment = Enum.TextXAlignment.Left,
    Name = "CTL"
})

ctf, _ = cui(cp, "scrollingframe", {
    Size = UDim2.new(0.2, 0, 0.93, 0),
    Position = UDim2.new(0.02, 0, 0.06, 0),
    Name = "CTF"
})

sif, _ = cui(cp, "textbox", {
    Size = UDim2.new(0.76, 0, 0.06, 0),
    Position = UDim2.new(0.23, 0, 0.02, 0),
    PlaceholderText = "Search videos...",
    Name = "SIF"
})

sif.Changed:Connect(function(prop)
    if prop == "Text" then
        sf = sif.Text
        fcv()
    end
end)

clf, _ = cui(cp, "scrollingframe", {
    Size = UDim2.new(0.76, 0, 0.89, 0),
    Position = UDim2.new(0.23, 0, 0.09, 0),
    Name = "CLF"
})

dp2 = FW.cF(vp, {
    BackgroundColor3 = Color3.fromRGB(15, 18, 25),
    Size = UDim2.new(1, 0, 0.86, 0),
    Position = UDim2.new(0, 0, 0.14, 0),
    Name = "DP2",
    Visible = false
})

cui(dp2, "text", {
    Text = "Download Video by URL",
    TextSize = 20,
    TextColor3 = Color3.fromRGB(0, 123, 255),
    Size = UDim2.new(1, 0, 0.08, 0),
    Position = UDim2.new(0, 0, 0.05, 0),
    Name = "DT"
})

dui, _ = cui(dp2, "textbox", {
    Size = UDim2.new(0.94, 0, 0.08, 0),
    Position = UDim2.new(0.03, 0, 0.18, 0),
    PlaceholderText = "Video URL (e.g: https://example.com/video.mp4)",
    Name = "DUI"
})

dni, _ = cui(dp2, "textbox", {
    Size = UDim2.new(0.94, 0, 0.08, 0),
    Position = UDim2.new(0.03, 0, 0.28, 0),
    PlaceholderText = "File name (optional)",
    Name = "DNI"
})

local pf = FW.cF(dp2, {
    BackgroundColor3 = Color3.fromRGB(30, 35, 45),
    Size = UDim2.new(0.94, 0, 0.06, 0),
    Position = UDim2.new(0.03, 0, 0.38, 0),
    Name = "PF"
})

dpb = FW.cF(pf, {
    BackgroundColor3 = Color3.fromRGB(0, 170, 90),
    Size = UDim2.new(0, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Name = "DPB"
})

dpl = cui(pf, "text", {
    Text = "0%",
    TextSize = 14,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    Size = UDim2.new(1, 0, 1, 0),
    Position = UDim2.new(0, 0, 0, 0),
    Name = "DPL"
})

db = cui(dp2, "button", {
    Size = UDim2.new(0.94, 0, 0.1, 0),
    Position = UDim2.new(0.03, 0, 0.48, 0),
    Text = "Download Video",
    TextSize = 16,
    BackgroundColor3 = Color3.fromRGB(0, 170, 90),
    Name = "DB"
})

pb1.MouseButton1Click:Connect(tpp)
sb.MouseButton1Click:Connect(sv)
nb.MouseButton1Click:Connect(nv)
prb.MouseButton1Click:Connect(pv)
fsb.MouseButton1Click:Connect(tfs)
db.MouseButton1Click:Connect(dv)

pgbb.MouseButton1Down:Connect(function()
    local m = game.Players.LocalPlayer:GetMouse()
    local c
    c = m.Button1Up:Connect(function()
        c:Disconnect()
    end)
    local mc
    mc = m.Move:Connect(function()
        if c.Connected then
            local rx = math.max(0, math.min(1, (m.X - pgb.AbsolutePosition.X) / pgb.AbsoluteSize.X))
            if vf and vf.TimeLength > 0 then
                vf.TimePosition = rx * vf.TimeLength
            end
            upb()
        else
            mc:Disconnect()
        end
    end)
end)

rs.RenderStepped:Connect(upb)

vf.Ended:Connect(function()
    nv()
end)

local sb2 = FW.getUI()["6"]:FindFirstChild("Sidebar")
if sb2 then
    local function csb(nm, txt, ico, pos, sel)
        local btn = FW.cF(sb2, {
            BackgroundColor3 = sel and Color3.fromRGB(30, 36, 51) or Color3.fromRGB(31, 34, 50),
            Size = UDim2.new(0.68, 0, 0.064, 0),
            Position = pos,
            Name = nm,
            BackgroundTransparency = sel and 0 or 1
        })
        FW.cC(btn, 12)
        local bx = FW.cF(btn, {
            ZIndex = sel and 2 or 0,
            BackgroundColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.15, 0, 0.6, 0),
            Position = UDim2.new(0.08, 0, 0.2, 0),
            Name = "BX"
        })
        FW.cC(bx, 8)
        FW.cAR(bx, 1)
        if sel then
            FW.cG(bx, Color3.fromRGB(166, 190, 255), Color3.fromRGB(93, 117, 160))
        else
            FW.cG(bx, Color3.fromRGB(66, 79, 113), Color3.fromRGB(36, 44, 63))
        end
        FW.cI(bx, {
            ZIndex = sel and 2 or 0,
            ScaleType = Enum.ScaleType.Fit,
            Image = ico,
            Size = UDim2.new(0.6, 0, 0.6, 0),
            BackgroundTransparency = 1,
            Name = "IC",
            Position = UDim2.new(0.2, 0, 0.2, 0)
        })
        local lb = FW.cT(btn, {
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
            Name = "LB",
            Position = UDim2.new(0.3, 0, 0.2, 0)
        })
        FW.cTC(lb, 16)
        local ck = FW.cB(btn, {
            TextWrapped = true,
            TextColor3 = Color3.fromRGB(0, 0, 0),
            TextSize = 12,
            TextScaled = true,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Name = "CK",
            Text = "  ",
            ZIndex = 5
        })
        FW.cC(ck, 0)
        FW.cTC(ck, 12)
        return btn, ck
    end
    local vb, vc = csb("VideoPlayer", "Video Player", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.6, 0), false)
    vc.MouseButton1Click:Connect(function()
        if FW.isAnimating then FW.stopCurrentTweens() end
        FW.switchPage("VideoPlayer", FW.getUI()["6"]:FindFirstChild("Sidebar"))
    end)
end

if not isfolder("synapse") then makefolder("synapse") end
if not isfolder("synapse/videos") then makefolder("synapse/videos") end
if not isfolder("synapse/temp_videos") then makefolder("synapse/temp_videos") end

lv = fv("/")
sp("player")
FW.showAlert("Success", "ONX-DEV Video Player Loaded!", 2)
end)