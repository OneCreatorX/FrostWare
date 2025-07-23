local fw = {}
local e = {}
e.fn = function(f) return f end
e.sr = function(n) return cloneref(game:GetService(n)) end
e.gh = gethui or function() return game:GetService("CoreGui") end
e.gc = getclipboard or function() return "" end
e.sc = setclipboard or function() end
e.iff = isfile or function() return false end
e.rf = readfile or function() return "" end
e.wf = writefile or function() end
e.mf = makefolder or function() end
e.isf = isfolder or function() return false end
local da = false
local rs,lp,ws,tws,ms,cs,uis,ls = e.sr("RunService"),e.sr("Players").LocalPlayer,workspace,e.sr("TweenService"),e.sr("MarketplaceService"),e.gh(),e.sr("UserInputService"),e.sr("LogService")
local g = {}
local tb = {}
local ct = 1
local tc = 1
local td = "FrostWare/Tabs/"
local sr = nil
local lr = nil
local co = {}
local csr = nil
local ce = true
local op, ow, oelocal ss = tick()
local tbr = nil
local tsr = nil
local pbr = nil
local ee = false
local ha = false
local sbr = nil
local pgr = nil
local obr = nil
local cpn = "Editor"
local cfp = nil
local ctp = nil
local ia = false
local ctw = {}
local pm = {
    s = "Size", p = "Position", c = "BackgroundColor3", t = "Text", ts = "TextSize",
    tc = "TextColor3", bt = "BackgroundTransparency", v = "Visible", n = "Name",
    i = "Image", ic = "ImageColor3", z = "ZIndex", sc = "TextScaled",
    xa = "TextXAlignment", ya = "TextYAlignment", tw = "TextWrapped",
    ff = "FontFace", st = "ScaleType", cs = "CanvasSize", sb = "ScrollBarThickness",
    cl = "ClipsDescendants", ml = "MultiLine", cf = "ClearTextOnFocus", cp = "CursorPosition",
    rt = "RichText", tt = "TextTransparency", pc = "PlaceholderColor3",
    ac = "Active", dr = "Draggable", ro = "Rotation", eb = "ElasticBehavior",
    ti = "TopImage", mi = "MidImage", bi = "BottomImage", vs = "VerticalScrollBarInset",
    hs = "HorizontalScrollBarInset", sit = "ScrollBarImageTransparency",
    sic = "ScrollBarImageColor3", fd = "FillDirection", so = "SortOrder", pd = "Padding"
}
local function ap(o, pr)
    if pr then
        for k, v in pairs(pr) do
            if pm[k] then
                o[pm[k]] = v
            else
                o[k] = v
            end
        end
    end
    return o
end
local function ni(t, p, pr)
    local o = Instance.new(t, p)
    return ap(o, pr)
end
local function nf(p, pr) return ni("Frame", p, pr) end
local function nt(p, pr) return ni("TextLabel", p, pr) end
local function nb(p, pr) return ni("TextButton", p, pr) end
local function ntb(p, pr) return ni("TextBox", p, pr) end
local function nim(p, pr) return ni("ImageLabel", p, pr) end
local function nib(p, pr) return ni("ImageButton", p, pr) end
local function nsf(p, pr) return ni("ScrollingFrame", p, pr) end
local function ng(p, c1, c2, r)
    return ap(ni("UIGradient", p), {
        ro = r or 90,
        Color = ColorSequence.new{ColorSequenceKeypoint.new(0, c1), ColorSequenceKeypoint.new(1, c2)}
    })
end
local function nc(p, r)
    return ap(ni("UICorner", p), {CornerRadius = UDim.new(r or 0, 0)})
end
local function ns(p, th, col)
    return ap(ni("UIStroke", p), {Thickness = th, Color = col, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function ntc(p, max)
    return ap(ni("UITextSizeConstraint", p), {MaxTextSize = max})
end
local function nar(p, ratio)
    return ap(ni("UIAspectRatioConstraint", p), {AspectRatio = ratio})
end
local gvt = e.fn(function()
    return 999, 59, 59
end)
function fw.aio()
    if not obr or not g["3"] then return end
    local tp = UDim2.new(0.018,0,0.031,0)
    local tsz = UDim2.new(0.964,0,0.936,0)
    if da then
        g["3"].Position = tp
        g["3"].Size = tsz
        g["3"].Visible = true
        obr.Visible = false
        if sbr and pgr then
            sbr.Position = UDim2.new(0, 0, 0, 0)
            pgr.Position = UDim2.new(0.255, 0, 0, 0)
        end
        return
    end
    local bp = obr.AbsolutePosition
    local bs = obr.AbsoluteSize
    local ssz = obr.Parent.AbsoluteSize
    local cx = bp.X + bs.X/2
    local cy = bp.Y + bs.Y/2
    g["3"].Position = UDim2.new(0, cx - ssz.X * tsz.X.Scale/2, 0, cy - ssz.Y * tsz.Y.Scale/2)
    g["3"].Size = UDim2.new(0, bs.X, 0, bs.Y)
    g["3"].Visible = true
    obr.Visible = false
    local et = tws:Create(g["3"], TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = tsz, Position = tp
    })
    et:Play()
    et.Completed:Connect(function()
        if sbr and pgr then
            sbr.Position = UDim2.new(-0.25, 0, 0, 0)
            pgr.Position = UDim2.new(1, 0, 0, 0)
            local st = tws:Create(sbr, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 0, 0, 0)
            })
            local pt = tws:Create(pgr, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                Position = UDim2.new(0.255, 0, 0, 0)
            })
            st:Play()
            wait(0.1)
            pt:Play()
        end
    end)
end
function fw.aic()
    if not obr or not g["3"] then return end
    local cbp = obr.Position
    local cbs = obr.Size
    if da then
        g["3"].Visible = false
        obr.Visible = true
        if sbr and pgr then
            sbr.Position = UDim2.new(0, 0, 0, 0)
            pgr.Position = UDim2.new(0.255, 0, 0, 0)
        end
        return
    end
    if sbr and pgr then
        local st = tws:Create(sbr, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(-0.25, 0, 0, 0)
        })
        local pt = tws:Create(pgr, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Position = UDim2.new(1, 0, 0, 0)
        })
        st:Play()
        pt:Play()
        pt.Completed:Connect(function()
            local ssz = g["3"].Parent.AbsoluteSize
            local bap = Vector2.new(
                ssz.X * cbp.X.Scale + cbp.X.Offset,
                ssz.Y * cbp.Y.Scale + cbp.Y.Offset
            )
            local bas = Vector2.new(
                ssz.X * cbs.X.Scale + cbs.X.Offset,
                ssz.Y * cbs.Y.Scale + cbs.Y.Offset
            )
            local cx = bap.X + bas.X/2
            local cy = bap.Y + bas.Y/2
            local sht = tws:Create(g["3"], TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Size = UDim2.new(0, bas.X, 0, bas.Y),
                Position = UDim2.new(0, cx - bas.X/2, 0, cy - bas.Y/2)
            })
            sht:Play()
            sht.Completed:Connect(function()
                g["3"].Visible = false
                obr.Visible = true
                obr.Size = UDim2.new(0, 0, 0, 0)
                obr.Position = UDim2.new(0, cx, 0, cy)
                local bat = tws:Create(obr, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = cbs, Position = cbp
                })
                bat:Play()
            end)
        end)
    end
end
function fw.sct()
    for _, tw in pairs(ctw) do
        if tw then tw:Cancel() end
    end
    ctw = {}
    if cfp then
        cfp.Visible = false
        cfp.Position = UDim2.new(-0.001, 0, 0, 0)
    end
    if ctp then
        ctp.Visible = false
        ctp.Position = UDim2.new(0.1, 0, 0, 0)
    end
    cfp = nil
    ctp = nil
    ia = false
end
function fw.apt(fp, tp, cb)
    if ia then fw.sct() end
    cfp = fp
    ctp = tp
    if da then
        if fp then fp.Visible = false end
        if tp then tp.Visible = true end
        ia = false
        if cb then cb() end
        return
    end
    ia = true
    if fp and tp then
        if fp == tp then
            ia = false
            cfp = nil
            ctp = nil
            if cb then cb() end
            return
        end
        tp.Visible = true
        tp.Position = UDim2.new(0.1, 0, 0, 0)
        local so = tws:Create(fp, TweenInfo.new(0.15, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.1, 0, 0, 0)
        })
        local si = tws:Create(tp, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.001, 0, 0, 0)
        })
        ctw[1] = so
        ctw[2] = si
        so:Play()
        so.Completed:Connect(function()
            if not ia then return end
            fp.Visible = false
            fp.Position = UDim2.new(-0.001, 0, 0, 0)
            si:Play()
            si.Completed:Connect(function()
                ia = false
                ctw = {}
                cfp = nil
                ctp = nil
                if cb then cb() end
            end)
        end)
    elseif tp then
        tp.Visible = true
        tp.Position = UDim2.new(0.1, 0, 0, 0)
        local si = tws:Create(tp, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Position = UDim2.new(-0.001, 0, 0, 0)
        })
        ctw[1] = si
        si:Play()
        si.Completed:Connect(function()
            ia = false
            ctw = {}
            cfp = nil
            ctp = nil
            if cb then cb() end
        end)
    else
        ia = false
        cfp = nil
        ctp = nil
        if cb then cb() end
    end
end
local function csb(p, nm, txt, ico, pos, sz)
    local btn = nf(p, {c=Color3.fromRGB(255,255,255), s=sz, p=pos, n=nm})
    nc(btn, 0.2)
    ng(btn, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    local lbl = nt(btn, {tw=true, ts=16, xa=Enum.TextXAlignment.Left, ya=Enum.TextYAlignment.Top,
        sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),
        tc=Color3.fromRGB(29,29,38), bt=1, s=UDim2.new(0.65,0,0.4,0), t=txt, n="Lbl", p=UDim2.new(0.25,0,0.3,0)})
    ntc(lbl, 16)
    nim(btn, {st=Enum.ScaleType.Fit, i=ico, s=UDim2.new(0.15,0,0.4,0), bt=1, n="Ico", p=UDim2.new(0.05,0,0.3,0)})
    local clk = nb(btn, {tw=true, tc=Color3.fromRGB(0,0,0), ts=12, sc=true, bt=1, s=UDim2.new(1,0,1,0), n="Clk", t="  "})
    nc(clk, 0)
    ntc(clk, 12)
    return clk
end
local function crb(p, nm, ico, pos, sz)
    local btn = nf(p, {z=2, c=Color3.fromRGB(255,255,255), s=sz, p=pos, n=nm})
    nc(btn, 1)
    nim(btn, {z=2, st=Enum.ScaleType.Fit, i=ico, s=UDim2.new(0.4,0,0.4,0), bt=1, n="Ico", p=UDim2.new(0.3,0,0.3,0)})
    ng(btn, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    local clk = nb(btn, {tw=true, tc=Color3.fromRGB(0,0,0), ts=12, sc=true, bt=1, z=3, s=UDim2.new(1,0,1,0), n="Clk", t="  "})
    nc(clk, 0)
    ntc(clk, 12)
    nar(btn, 1)
    return clk
end
function fw.ut()
    if tbr and tsr and pbr then
        local el = tick() - ss
        local h = math.floor(el / 3600)
        local m = math.floor((el % 3600) / 60)
        local s = math.floor(el % 60)
        tbr.Text = string.format("Session: %02d:%02d:%02d", h, m, s)
        local h2, m2, s2 = gvt()
        local tsec = h2 * 3600 + m2 * 60 + s2
        local msec = 50 * 3600
        local pc = math.min(tsec / msec, 1)
        if tsec > 0 then
            tsr.Text = string.format("Remaining: %02d:%02d:%02d", h2, m2, s2)
            tsr.TextColor3 = Color3.fromRGB(255, 255, 255)
            if da then
                pbr.Size = UDim2.new(pc, 0, 1, 0)
            else
                local st = tws:Create(pbr, TweenInfo.new(0.5, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(pc, 0, 1, 0)
                })
                st:Play()
            end
            if pc > 0.5 then
                ng(pbr, Color3.fromRGB(100, 255, 100), Color3.fromRGB(50, 200, 50))
            elseif pc > 0.2 then
                ng(pbr, Color3.fromRGB(255, 200, 100), Color3.fromRGB(200, 150, 50))
            else
                ng(pbr, Color3.fromRGB(255, 100, 100), Color3.fromRGB(200, 50, 50))
            end
        else
            tsr.Text = "Status: EXPIRED"
            tsr.TextColor3 = Color3.fromRGB(255, 100, 100)
            pbr.Size = UDim2.new(0, 0, 1, 0)
        end
    end
end
function fw.st()
    if not e.isf(td) then e.mf(td) end
    local tbd = {}
    for id, tab in pairs(tb) do
        tbd[tostring(id)] = {name = tab.name, content = tab.content, id = tab.id}
    end
    tbd.currentTab = ct
    tbd.tabCounter = tc
    e.wf(td .. "tabs.json", game:GetService("HttpService"):JSONEncode(tbd))
end
function fw.lt()
    if e.iff(td .. "tabs.json") then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(e.rf(td .. "tabs.json"))
        end)
        if success and data then
            ct = data.currentTab or 1
            tc = data.tabCounter or 1
            for id, ti in pairs(data) do
                if type(ti) == "table" and ti.name then
                    tb[tonumber(id)] = {name = ti.name, content = ti.content, id = ti.id, button = nil, closeButton = nil}
                end
            end
            return true
        end
    end
    return false
end
function fw.al(msg, mt, cc, fe)
    if not ce then return end
    local tst = os.date("[%H:%M:%S]")
    local cl = Color3.fromRGB(255, 255, 255)
    local pf = ""
    if mt == "error" then
        cl = Color3.fromRGB(255, 100, 100)
        pf = "[ERROR] "
    elseif mt == "warn" then
        cl = Color3.fromRGB(255, 200, 100)
        pf = "[WARN] "
    elseif mt == "info" then
        cl = Color3.fromRGB(100, 200, 255)
        pf = "[INFO] "
    elseif mt == "editor" then
        cl = Color3.fromRGB(255, 150, 255)
        pf = "[EDITOR] "
    end
    local le = {
        text = tst .. " " .. pf .. tostring(msg),
        color = cl,
        canCopy = cc ~= false,
        fullText = tostring(msg),
        type = mt or "info",
        fromEditor = fe or false
    }
    table.insert(co, le)
    if #co > 200 then table.remove(co, 1) end
    fw.uc()
end
function fw.uc()
    if csr then
        for _, ch in pairs(csr:GetChildren()) do
            if ch:IsA("TextButton") then ch:Destroy() end
        end
        local yp = 0
        for i, lg in ipairs(co) do
            local lb = nb(csr, {
                c = i % 2 == 0 and Color3.fromRGB(20, 23, 30) or Color3.fromRGB(16, 19, 27),
                s = UDim2.new(1, 0, 0, 35), p = UDim2.new(0, 0, 0, yp), n = "LogEntry" .. i,
                t = lg.text, ts = 16, tc = lg.color, xa = Enum.TextXAlignment.Left,
                ff = Font.new("rbxassetid://11702779409", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
                tw = true, sc = false
            })
            ntc(lb, 16)
            lb.MouseButton1Click:Connect(function()
                if e.sc and lg.canCopy then
                    e.sc(lg.fullText)
                    fw.sa("Success", "Copied to clipboard!", 1)
                end
            end)
            yp = yp + 35
        end
        csr.CanvasSize = UDim2.new(0, 0, 0, yp)
        csr.CanvasPosition = Vector2.new(0, yp)
    end
end
function fw.cc()
    co = {}
    fw.uc()
end
function fw.tc()
    ce = not ce
    if ce then fw.al("Console enabled", "info") end
    return ce
end
function fw.cac()
    local at = ""
    for i, lg in ipairs(co) do
        at = at .. lg.text
        if i < #co then at = at .. "\n" end
    end
    if e.sc then
        e.sc(at)
        fw.sa("Success", "All console output copied!", 2)
    end
end
function fw.ca() return true end
function fw.csb(p,nm,txt,ico,pos,sz) return csb(p,nm,txt,ico,pos,sz) end
function fw.crb(p,nm,ico,pos,sz) return crb(p,nm,ico,pos,sz) end
function fw.cbu()
    g["1"] = ap(ni("ScreenGui", cs), {IgnoreGuiInset=true, DisplayOrder=999999999, ScreenInsets=Enum.ScreenInsets.None, n="FW", ZIndexBehavior=Enum.ZIndexBehavior.Sibling, ResetOnSpawn=false})
    g["3"] = nf(g["1"], {v=false, BorderSizePixel=0, c=Color3.fromRGB(16,19,27), bt=0.6, cl=true, s=UDim2.new(0.964,0,0.936,0), p=UDim2.new(0.018,0,0.031,0), n="UI"})
    nc(g["3"], 0.04)
    ns(g["3"], 10, Color3.fromRGB(35,39,54))
    g["6"] = ap(ni("Folder", g["3"]), {n="Main"})
    g["7"] = nim(g["6"], {z=6, ic=Color3.fromRGB(36,42,60), i="rbxassetid://133620562515152", s=UDim2.new(0.314,0,0.185,0), v=false, cl=true, bt=1, n="Alert", p=UDim2.new(0.398,0,0.074,0)})
    local at = nt(g["7"], {tw=true, LineHeight=0, ts=31, xa=Enum.TextXAlignment.Left, ya=Enum.TextYAlignment.Top, sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal), tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.505,0,0.175,0), t="FrostWare Notification", p=UDim2.new(0.147,0,0.21,0)})
    ntc(at, 31)
    local am = nt(g["7"], {tw=true, ts=23, xa=Enum.TextXAlignment.Left, ya=Enum.TextYAlignment.Top, sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal), tc=Color3.fromRGB(162,177,234), bt=1, s=UDim2.new(0.45,0,0.321,0), t="Message content", n="MSG", p=UDim2.new(0.148,0,0.449,0)})
    ntc(am, 23)
    local ai = nim(g["7"], {z=2, i="rbxassetid://107516337694688", s=UDim2.new(0.031,0,0.54,0), bt=1, p=UDim2.new(0.059,0,0.21,0)})
    ng(ai, Color3.fromRGB(166,190,255), Color3.fromRGB(121,152,207), 91.1)
    nim(g["7"], {ic=Color3.fromRGB(16,19,27), i="rbxassetid://82022759470861", s=UDim2.new(0.067,0,0.941,0), bt=1, n="Shd", p=UDim2.new(0.036,0,0,0)})
    nib(g["7"], {i="rbxassetid://88951128464748", s=UDim2.new(0.05,0,0.16,0), bt=1, n="Ico", p=UDim2.new(0.84,0,0.396,0)})
    nim(g["6"], {z=22, ic=Color3.fromRGB(16,19,27), i="rbxassetid://102023075611323", s=UDim2.new(0.019,0,1,0), bt=1, n="Shd", p=UDim2.new(0.254,0,0,0)})
    g["11"] = nim(g["6"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(0.745,0,1,0), cl=true, bt=1, n="Pages", p=UDim2.new(0.255,0,0,0)})
    local ob = nim(g["1"], {i="rbxassetid://132133828845126", s=UDim2.new(0.116,0,0.208,0), v=false, bt=1, n="OpenBtn", p=UDim2.new(0.442,0,0.045,0), ac=true, dr=true})
    nc(ob, 0)
    nim(ob, {st=Enum.ScaleType.Fit, ic=Color3.fromRGB(255,255,255), i="rbxassetid://102761807757832", s=UDim2.new(0.221,0,0.244,0), bt=1, p=UDim2.new(0.388,0,0.367,0)})
    local oc = nb(ob, {tc=Color3.fromRGB(0,0,0), ts=14, bt=1, z=6, s=UDim2.new(0.441,0,0.427,0), n="OpenClk", t="  ", p=UDim2.new(0.279,0,0.284,0)})
    nc(oc, 0)
    ap(ni("Folder", g["6"]), {n="Alerts"})
    obr = ob
    pgr = g["11"]
    return g, oc
end

function fw.createSidebarButton(p, nm, txt, ico, pos, sel)
    local btn = nf(p, {c=sel and Color3.fromRGB(30,36,51) or Color3.fromRGB(31,34,50), s=UDim2.new(0.68,0,0.064,0), p=pos, n=nm, bt=sel and 0 or 1})
    nc(btn, 0.15)
    local bx = nf(btn, {z=sel and 2 or 0, c=Color3.fromRGB(255,255,255), s=UDim2.new(0.15,0,0.6,0), p=UDim2.new(0.08,0,0.2,0), n="Box"})
    nc(bx, 0.2)
    nar(bx, 1)
    if sel then
        ng(bx, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    else
        ng(bx, Color3.fromRGB(66,79,113), Color3.fromRGB(36,44,63))
    end
    nim(bx, {z=sel and 2 or 0, st=Enum.ScaleType.Fit, i=ico, s=UDim2.new(0.6,0,0.6,0), bt=1, n="Ico", p=UDim2.new(0.2,0,0.2,0)})
    local lbl = nt(btn, {tw=true, ts=16, xa=Enum.TextXAlignment.Left, ya=Enum.TextYAlignment.Top, sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal), tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.6,0,0.6,0), t=txt, n="Lbl", p=UDim2.new(0.3,0,0.2,0)})
    ntc(lbl, 16)
    local clk = nb(btn, {tw=true, tc=Color3.fromRGB(0,0,0), ts=12, sc=true, bt=1, s=UDim2.new(1,0,1,0), n="Clk", t="  ", z=5})
    nc(clk, 0)
    ntc(clk, 12)
    return btn, clk
end

function fw.csid()
    local sb = nim(g["6"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://133862668499122", s=UDim2.new(0.25,0,1,0), bt=1, n="Sidebar"})
    sbr = sb
    local pf = nf(sb, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0.85,0,0.12,0), p=UDim2.new(0.075,0,0.75,0), n="ProgressFrame"})
    nc(pf, 0.15)
    ns(pf, 2, Color3.fromRGB(35,39,54))
    local sl = nt(pf, {t="Session Time", ts=14, tc=Color3.fromRGB(200,200,200), bt=1, s=UDim2.new(0.9,0,0.2,0), p=UDim2.new(0.05,0,0.05,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(sl, 14)
    local tt = nt(pf, {t="00:00:00", ts=16, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(0.9,0,0.25,0), p=UDim2.new(0.05,0,0.25,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal)})
    ntc(tt, 16)
    tbr = tt
    local pb = nf(pf, {c=Color3.fromRGB(30,35,45), s=UDim2.new(0.9,0,0.15,0), p=UDim2.new(0.05,0,0.55,0), n="ProgressBg"})
    nc(pb, 0.1)
    local pr = nf(pb, {c=Color3.fromRGB(100,255,100), s=UDim2.new(1,0,1,0), p=UDim2.new(0,0,0,0), n="ProgressBar"})
    nc(pr, 0.1)
    ng(pr, Color3.fromRGB(100,255,100), Color3.fromRGB(50,200,50))
    pbr = pr
    local st = nt(pf, {t="Checking...", ts=12, tc=Color3.fromRGB(180,180,180), bt=1, s=UDim2.new(0.9,0,0.2,0), p=UDim2.new(0.05,0,0.75,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular,Enum.FontStyle.Normal)})
    ntc(st, 12)
    tsr = st
    local ub = nf(sb, {c=Color3.fromRGB(255,255,255), s=UDim2.new(0.68,0,0.064,0), p=UDim2.new(0.075,0,0.9,0), n="UpBtn"})
    nc(ub, 0.15)
    ng(ub, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    local ul = nt(ub, {tw=true, ts=14, xa=Enum.TextXAlignment.Left, ya=Enum.TextYAlignment.Top, sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal), tc=Color3.fromRGB(29,29,38), bt=1, s=UDim2.new(0.7,0,0.6,0), t="Upgrade Plan", n="UpLbl", p=UDim2.new(0.25,0,0.2,0)})
    ntc(ul, 14)
    nim(ub, {st=Enum.ScaleType.Fit, i="rbxassetid://110667923648139", s=UDim2.new(0.15,0,0.6,0), bt=1, n="UpIco", p=UDim2.new(0.05,0,0.2,0)})
    local uc = nb(ub, {tw=true, tc=Color3.fromRGB(0,0,0), ts=12, sc=true, bt=1, s=UDim2.new(1,0,1,0), n="UpClk", t=""})
    nc(uc, 0)
    ntc(uc, 12)
    uc.MouseButton1Click:Connect(function() e.sc("https://discord.gg/getfrost") end)

    local edBtn, edc = fw.createSidebarButton(sb, "Editor", "Editor", "rbxassetid://94595204123047", UDim2.new(0.075,0,0.2,0), true)
    local coBtn, coc = fw.createSidebarButton(sb, "Console", "Console", "rbxassetid://107390243416427", UDim2.new(0.075,0,0.28,0), false)
    local exBtn, exc = fw.createSidebarButton(sb, "Extra", "Extra", "rbxassetid://128679881757557", UDim2.new(0.075,0,0.36,0), false)

    local lg = nim(sb, {st=Enum.ScaleType.Fit, i="rbxassetid://102761807757832", s=UDim2.new(0.2,0,0.08,0), bt=1, n="Logo", p=UDim2.new(0.4,0,0.05,0)})
    nc(lg, 0)
    local cl = nim(sb, {z=2, ic=Color3.fromRGB(34,41,58), i="rbxassetid://124705542662472", s=UDim2.new(0.13,0,1,0), bt=1, n="Close", p=UDim2.new(0.891,0,0,0)})
    local sl = nb(cl, {tw=true, tc=Color3.fromRGB(0,0,0), ts=14, sc=true, bt=1, s=UDim2.new(1,0,0.189,0), n="Slide", t="  ", p=UDim2.new(0,0,0.43,0)})
    ntc(sl, 14)
    return sb, uc, edc, coc, exc, sl
end
function fw.ce()
    local ep = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), cl=true, bt=1, n="EditorPage", p=UDim2.new(-0.001,0,0,0)})
    local tbar = nf(ep, {c=Color3.fromRGB(16,19,27), s=UDim2.new(1,0,0.08,0), p=UDim2.new(0,0,0,0), n="TabBar"})
    nc(tbar, 0.02)
    ns(tbar, 2, Color3.fromRGB(35,39,54))
    local tscr = nsf(tbar, {bt=1, s=UDim2.new(0.85,0,1,0), p=UDim2.new(0,0,0,0), n="TabScroll", sb=0, cs=UDim2.new(0,0,0,0)})
    ap(ni("UIListLayout", tscr), {fd=Enum.FillDirection.Horizontal, so=Enum.SortOrder.LayoutOrder, pd=UDim.new(0,2)})
    local at = nb(tbar, {c=Color3.fromRGB(166,190,255), s=UDim2.new(0.08,0,0.7,0), p=UDim2.new(0.9,0,0.15,0), t="+", tc=Color3.fromRGB(29,29,38), ts=28, n="AddTab", ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    nc(at, 0.2)
    ng(at, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    ntc(at, 28)
    local epp = nim(ep, {ic=Color3.fromRGB(32,39,57), i="rbxassetid://136761835814725", s=UDim2.new(0.84,0,0.92,0), cl=true, bt=1, n="EditorPage", p=UDim2.new(0,0,0.08,0)})
    local txb = nf(epp, {c=Color3.fromRGB(24,24,32), s=UDim2.new(1,0,1,0), p=UDim2.new(0,0,0,0), n="TxtBox", bt=1})
    local ef = nsf(txb, {eb=Enum.ElasticBehavior.Always, ti="rbxassetid://148970562", mi="rbxassetid://148970562", vs=Enum.ScrollBarInset.Always, c=Color3.fromRGB(32,31,32), n="EditorFrame", sit=1, hs=Enum.ScrollBarInset.Always, bi="rbxassetid://148970562", s=UDim2.new(1,0,1,0), sic=Color3.fromRGB(38,40,46), sb=10, bt=1})
    local src = ntb(ef, {cp=-1, n="Source", xa=Enum.TextXAlignment.Left, pc=Color3.fromRGB(205,205,205), z=3, tw=true, tt=0, ts=20, tc=Color3.fromRGB(255,255,255), ya=Enum.TextYAlignment.Top, rt=false, ff=Font.new("rbxassetid://11702779409",Enum.FontWeight.Medium,Enum.FontStyle.Normal), ml=true, cf=false, cl=true, s=UDim2.new(0.7,0,2,0), p=UDim2.new(0.08,0,0,0), t="-- FrostWare V2 Editor\nprint('Hello World!')", bt=1})
    local ln = nt(ef, {tw=true, ts=20, ya=Enum.TextYAlignment.Top, sc=true, c=Color3.fromRGB(32,31,32), ff=Font.new("rbxassetid://11702779409",Enum.FontWeight.Regular,Enum.FontStyle.Normal), tc=Color3.fromRGB(193,191,235), bt=1, s=UDim2.new(0.05,0,2,0), p=UDim2.new(0.021,0,-0.003,0)})
    ntc(ln, 20)
    nc(ef)
    local btns = nim(ep, {z=2, ic=Color3.fromRGB(16,19,27), i="rbxassetid://123590482033481", s=UDim2.new(0.16,0,0.92,0), cl=true, bt=1, n="Btns", p=UDim2.new(0.84,0,0.08,0)})
    local eb = csb(btns, "Exec", "Execute", "rbxassetid://89434276213036", UDim2.new(0.05,0,0.05,0), UDim2.new(0.9,0,0.12,0))
    local cb = csb(btns, "Clr", "Clear", "rbxassetid://73909411554012", UDim2.new(0.05,0,0.19,0), UDim2.new(0.9,0,0.12,0))
    local pb = csb(btns, "Pst", "Paste", "rbxassetid://133018045821797", UDim2.new(0.05,0,0.33,0), UDim2.new(0.9,0,0.12,0))
    local ecb = csb(btns, "ExecClp", "Exec Clipboard", "rbxassetid://89434276213036", UDim2.new(0.05,0,0.47,0), UDim2.new(0.9,0,0.12,0))
    sr = src
    lr = ln
    return ep, src, ln, tscr, at, eb, cb, pb, ecb
end
function fw.ccp()
    local cop = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), v=false, cl=true, bt=1, n="ConsolePage", p=UDim2.new(-0.001,0,0,0)})
    local tit = nt(cop, {t="Console Output", ts=32, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.08,0), p=UDim2.new(0,0,0.02,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 32)
    local cf = nf(cop, {c=Color3.fromRGB(16,19,27), s=UDim2.new(0.95,0,0.75,0), p=UDim2.new(0.025,0,0.12,0), n="ConsoleFrame"})
    nc(cf, 0.02)
    ns(cf, 2, Color3.fromRGB(35,39,54))
    local cs = nsf(cf, {c=Color3.fromRGB(12,15,22), s=UDim2.new(1,0,0.85,0), p=UDim2.new(0,0,0,0), sb=8, cs=UDim2.new(0,0,0,0), n="ConsoleScroll"})
    nc(cs, 0.02)
    local bf = nf(cf, {bt=1, s=UDim2.new(1,0,0.15,0), p=UDim2.new(0,0,0.85,0), n="ButtonFrame"})
    local ccb = csb(bf, "ClearConsole", "Clear Console", "rbxassetid://73909411554012", UDim2.new(0.02,0,0.2,0), UDim2.new(0.14,0,0.48,0))
    local cab = csb(bf, "CopyAll", "Copy All", "rbxassetid://133018045821797", UDim2.new(0.18,0,0.2,0), UDim2.new(0.14,0,0.48,0))
    local tgb = csb(bf, "Toggle", "Toggle Console", "rbxassetid://94595204123047", UDim2.new(0.34,0,0.2,0), UDim2.new(0.14,0,0.48,0))
    csr = cs
    ccb.MouseButton1Click:Connect(function()
        fw.cc()
        fw.sa("Success", "Console cleared!", 2)
    end)
    cab.MouseButton1Click:Connect(function() fw.cac() end)
    tgb.MouseButton1Click:Connect(function()
        local en = fw.tc()
        fw.sa("Info", en and "Console enabled!" or "Console disabled!", 2)
    end)
    return cop
end
function fw.cep()
    local exp = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), v=false, cl=true, bt=1, n="ExtraPage", p=UDim2.new(-0.001,0,0,0)})
    local tit = nt(exp, {t="Extra Features", ts=48, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.3,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 48)
    return exp
end
function fw.ul(src, ln)
    if src and src.Text then
        local lns = src.Text:split("\n")
        local txt = ""
        for i = 1, #lns do
            txt = txt .. tostring(i)
            if i < #lns then txt = txt .. "\n" end
        end
        if ln then ln.Text = txt end
    end
end
function fw.ctb(tscr, nm, cont)
    local td = {name = nm or "Tab " .. tc, content = cont or "-- New Tab\nprint('Hello from " .. (nm or "Tab " .. tc) .. "!')", id = tc}
    local tf = nf(tscr, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0,140,0.7,0), p=UDim2.new(0,0,0.15,0), n="TabFrame" .. td.id})
    nc(tf, 0.2)
    ns(tf, 1, Color3.fromRGB(35,39,54))
    ng(tf, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
    local tbb = nb(tf, {bt=1, s=UDim2.new(0.8,0,1,0), p=UDim2.new(0,0,0,0), t=td.name, tc=Color3.fromRGB(29,29,38), ts=16, n="TabBtn" .. td.id, sc=true, z=2, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tbb, 16)
    local cb = nf(tf, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0,18,0,18), p=UDim2.new(1,-22,0,4), n="CloseFrame", z=3})
    nc(cb, 0.4)
    ng(cb, Color3.fromRGB(200,100,100), Color3.fromRGB(150,50,50))
    local cbb = nb(cb, {bt=1, s=UDim2.new(1,0,1,0), t="×", tc=Color3.fromRGB(255,255,255), ts=14, n="CloseBtn", z=4, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(cbb, 14)
    td.button = tbb
    td.closeButton = cbb
    td.frame = tf
    tb[td.id] = td
    tbb.MouseButton1Click:Connect(function() fw.swt(td.id) end)
    cbb.MouseButton1Click:Connect(function() fw.clt(td.id, tscr) end)
    tscr.CanvasSize = UDim2.new(0, tscr.UIListLayout.AbsoluteContentSize.X, 0, 0)
    tc = tc + 1
    fw.st()
    return td.id, tbb, cbb
end
function fw.swt(tid)
    if tb[tid] then
        if tb[ct] and sr then tb[ct].content = sr.Text end
        for _, tab in pairs(tb) do
            if tab.frame then
                tab.frame.BackgroundColor3 = Color3.fromRGB(20,25,32)
                ng(tab.frame, Color3.fromRGB(66,79,113), Color3.fromRGB(36,44,63))
                if tab.button then tab.button.TextColor3 = Color3.fromRGB(255,255,255) end
            end
        end
        ct = tid
        if tb[tid].frame then
            tb[tid].frame.BackgroundColor3 = Color3.fromRGB(30,36,51)
            ng(tb[tid].frame, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160))
            if tb[tid].button then tb[tid].button.TextColor3 = Color3.fromRGB(29,29,38) end
        end
        if sr then
            sr.Text = tb[tid].content
            fw.ul(sr, lr)
        end
        fw.st()
        return true
    end
    return false
end
function fw.clt(tid, tscr)
    local cnt = 0
    for _ in pairs(tb) do cnt = cnt + 1 end
    if cnt <= 1 then
        fw.sa("Info", "Cannot close last tab!", 2)
        return false
    end
    if tb[tid] then
        if tb[tid].frame then tb[tid].frame:Destroy() end
        tb[tid] = nil
        if ct == tid then
            for id, _ in pairs(tb) do
                ct = id
                fw.swt(id)
                break
            end
        end
        tscr.CanvasSize = UDim2.new(0, tscr.UIListLayout.AbsoluteContentSize.X, 0, 0)
        fw.st()
        return true
    end
    return false
end
function fw.sa(tit, msg, dur)
    local al = g["7"]:Clone()
    local als = g["6"]:FindFirstChild("Alerts")
    if als then
        al.Parent = als
        al.Visible = true
        al.Name = "Alert_" .. tick()
        al:FindFirstChild("MSG").Text = msg
        al:FindFirstChild("TextLabel").Text = tit
        if da then
            al.Position = UDim2.new(0.398,0,0.074,0)
            spawn(function()
                wait(dur or 3)
                al:Destroy()
            end)
        else
            local tw = tws:Create(al, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0.398,0,0.074,0)})
            tw:Play()
            spawn(function()
                wait(dur or 3)
                local fo = tws:Create(al, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0.398,0,-0.3,0)})
                fo:Play()
                fo.Completed:Connect(function() al:Destroy() end)
            end)
        end
    end
end
function fw.sp(pn, sb)
    if ia then return end
    local cp = nil
    local tp = nil
    for _, pg in pairs(g["11"]:GetChildren()) do
        if pg:IsA("ImageLabel") then
            if pg.Visible then cp = pg end
            if pg.Name == pn .. "Page" then tp = pg end
        end
    end
    if cp == tp then return end
    for _, btn in pairs(sb:GetChildren()) do
        if btn:IsA("Frame") and btn.Name ~= "UpBtn" and btn.Name ~= "ProgressFrame" then
            btn.BackgroundTransparency = 1
            local bx = btn:FindFirstChild("Box")
            if bx then ng(bx, Color3.fromRGB(66,79,113), Color3.fromRGB(36,44,63)) end
        end
    end
    local sbb = sb:FindFirstChild(pn)
    if sbb then
        sbb.BackgroundTransparency = 0
        local bx = sbb:FindFirstChild("Box")
        if bx then ng(bx, Color3.fromRGB(166,190,255), Color3.fromRGB(93,117,160)) end
    end
    cpn = pn
    fw.apt(cp, tp, function() end)
end
function fw.rt(tscr)
    if fw.lt() then
        for id, tab in pairs(tb) do
            if tab.name and tab.content then
                local tf = nf(tscr, {c=Color3.fromRGB(20,25,32), s=UDim2.new(0,140,0.7,0), p=UDim2.new(0,0,0.15,0), n="TabFrame" .. id})
                nc(tf, 0.2)
                ns(tf, 1, Color3.fromRGB(35,39,54))
                ng(tf, Color3.fromRGB(66,79,113), Color3.fromRGB(36,44,63))
                local tbb = nb(tf, {bt=1, s=UDim2.new(0.8,0,1,0), p=UDim2.new(0,0,0,0), t=tab.name, tc=Color3.fromRGB(255,255,255), ts=16, n="TabBtn" .. id, sc=true, z=2, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
                ntc(tbb, 16)
                local cb = nf(tf, {c=Color3.fromRGB(200,100,100), s=UDim2.new(0,18,0,18), p=UDim2.new(1,-22,0,4), n="CloseFrame", z=3})
                nc(cb, 0.4)
                ng(cb, Color3.fromRGB(200,100,100), Color3.fromRGB(150,50,50))
                local cbb = nb(cb, {bt=1, s=UDim2.new(1,0,1,0), t="×", tc=Color3.fromRGB(255,255,255), ts=14, n="CloseBtn", z=4, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
                ntc(cbb, 14)
                tb[id].button = tbb
                tb[id].closeButton = cbb
                tb[id].frame = tf
                tbb.MouseButton1Click:Connect(function() fw.swt(id) end)
                cbb.MouseButton1Click:Connect(function() fw.clt(id, tscr) end)
            end
        end
        tscr.CanvasSize = UDim2.new(0, tscr.UIListLayout.AbsoluteContentSize.X, 0, 0)
        return true
    end
    return false
end
function fw.gu() return g end
function fw.gct() return ct end
function fw.gt() return tb end
function fw.sh() fw.aio() end
function fw.hd() fw.aic() end

function fw.cscp()
    local scp = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), v=false, cl=true, bt=1, n="ScriptsPage", p=UDim2.new(-0.001,0,0,0)})
    local tit = nt(scp, {t="Scripts", ts=48, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.3,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 48)
    local info = nt(scp, {t="Aquí podrás gestionar tus scripts.", ts=24, tc=Color3.fromRGB(180,180,180), bt=1, s=UDim2.new(1,0,0.1,0), p=UDim2.new(0,0,0.5,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular,Enum.FontStyle.Normal)})
    ntc(info, 24)
    return scp
end

function fw.cstp()
    local testp = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), v=false, cl=true, bt=1, n="TestPage", p=UDim2.new(-0.001,0,0,0)})
    local tit = nt(testp, {t="Test Page", ts=48, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.3,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 48)
    local info = nt(testp, {t="Esta es una página de prueba.", ts=24, tc=Color3.fromRGB(180,180,180), bt=1, s=UDim2.new(1,0,0.1,0), p=UDim2.new(0,0,0.5,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular,Enum.FontStyle.Normal)})
    ntc(info, 24)
    return testp
end

function fw.addTab(tabName, tabText, iconId, position, pageCreationFunction)
    local sb = sbr
    if not sb then return end

    local tabButtonFrame, tabClickDetector = fw.createSidebarButton(sb, tabName, tabText, iconId, position, false)

    local page = pageCreationFunction()

    tabClickDetector.MouseButton1Click:Connect(function()
        fw.sp(tabName, sb)
    end)
end

function fw.iwa()
    ha = true
    local sb, uc, edc, coc, exc, sl = fw.csid()
    spawn(function()
        if not da then wait(0.5) end
        local ed, src, ln, tscr, at, eb, cb, pb, ecb = fw.ce()
        if not da then wait(0.5) end
        local cop = fw.ccp()
        if not da then wait(0.5) end
        local exp = fw.cep()

        local function se()
            local tr = fw.rt(tscr)
            if not tr then
                local mt = fw.ctb(tscr, "Main", "-- FrostWare V2 Editor\nprint('Hello World!')")
                fw.swt(mt)
            else
                local ct = fw.gct()
                fw.swt(ct)
            end
            fw.ul(src, ln)
            src:GetPropertyChangedSignal("Text"):Connect(function()
                fw.ul(src, ln)
                local ct = fw.gct()
                local tb = fw.gt()
                if tb[ct] then
                    tb[ct].content = src.Text
                    spawn(function()
                        wait(0.5)
                        fw.st()
                    end)
                end
            end)
            at.MouseButton1Click:Connect(function()
                local ni, tbb, cbb = fw.ctb(tscr, "New Tab", "-- New Tab\nprint('Hello!')")
                fw.swt(ni)
            end)
        end

        local function sbt()
            eb.MouseButton1Click:Connect(function()
                local cd = src.Text
                if cd and cd ~= "" then
                    ee = true
                    local suc, res = pcall(function()
                        return loadstring(cd)
                    end)
                    if suc and res then
                        local es, er = pcall(res)
                        if es then
                            fw.al("Script executed successfully", "editor", true, true)
                        else
                            fw.al("Execution error: " .. tostring(er), "error", true, true)
                        end
                    else
                        fw.al("Compilation error: " .. tostring(res), "error", true, true)
                    end
                    ee = false
                end
            end)
            cb.MouseButton1Click:Connect(function()
                src.Text = ""
                local ct = fw.gct()
                local tb = fw.gt()
                if tb[ct] then tb[ct].content = "" end
                fw.ul(src, ln)
                fw.st()
            end)
            pb.MouseButton1Click:Connect(function()
                local cb = e.gc()
                if cb ~= "" then
                    src.Text = cb
                    local ct = fw.gct()
                    local tb = fw.gt()
                    if tb[ct] then tb[ct].content = cb end
                    fw.ul(src, ln)
                    fw.st()
                end
            end)
            ecb.MouseButton1Click:Connect(function()
                local cb = e.gc()
                if cb ~= "" then
                    ee = true
                    local suc, res = pcall(function()
                        return loadstring(cb)
                    end)
                    if suc and res then
                        local es, er = pcall(res)
                        if es then
                            fw.al("Clipboard script executed successfully", "editor", true, true)
                        else
                            fw.al("Clipboard execution error: " .. tostring(er), "error", true, true)
                        end
                    else
                        fw.al("Clipboard compilation error: " .. tostring(res), "error", true, true)
                    end
                    ee = false
                end
            end)
        end

        local function sn()
            edc.MouseButton1Click:Connect(function() fw.sp("Editor", sb) end)
            coc.MouseButton1Click:Connect(function() fw.sp("Console", sb) end)
            exc.MouseButton1Click:Connect(function() fw.sp("Extra", sb) end)
            sl.MouseButton1Click:Connect(function() fw.hd() end)
        end

        se()
        sbt()
        sn()
        fw.sp("Editor", sb)
        spawn(function()
            if not da then wait(1) end
            fw.al("FrostWare Console initialized", "info")
            fw.al("Console captures print(), warn(), and error() automatically", "info")
            print("FrostWare V2 loaded successfully!")
        end)
    end)
end
op = print
ow = warn
oe = error
print = function(...)
    local ar = {...}
    local mg = ""
    for i, v in ipairs(ar) do
        mg = mg .. tostring(v)
        if i < #ar then mg = mg .. " " end
    end
    if not ee then fw.al(mg, "info") end
    op(...)
end
warn = function(...)
    local ar = {...}
    local mg = ""
    for i, v in ipairs(ar) do
        mg = mg .. tostring(v)
        if i < #ar then mg = mg .. " " end
    end
    if not ee then fw.al(mg, "warn") end
    ow(...)
end
error = function(...)
    local ar = {...}
    local mg = ""
    for i, v in ipairs(ar) do
        mg = mg .. tostring(v)
        if i < #ar then mg = mg .. " " end
    end
    if not ee then fw.al(mg, "error") end
    oe(...)
end
ls.MessageOut:Connect(function(msg, mt)
    if not ee then
        if mt == Enum.MessageType.MessageError then
            fw.al(msg, "error")
        elseif mt == Enum.MessageType.MessageWarning then
            fw.al(msg, "warn")
        elseif mt == Enum.MessageType.MessageInfo then
            fw.al(msg, "info")
        else
            fw.al(msg, "info")
        end
    end
end)
local function ifw()
    local ui, oc = fw.cbu()
    spawn(function()
        while wait(1) do fw.ut() end
    end)
    fw.sh()
    fw.iwa()
    oc.MouseButton1Click:Connect(function() fw.sh() end)
end
ifw()
