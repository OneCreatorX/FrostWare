local hs2 = game:GetService("HttpService")
local ts2 = game:GetService("TweenService")
local cs2 = "Local"
local lf2, cf2, csc2, ss2, sf2 = nil, nil, {}, nil, nil
local ls2, aes2 = {}, {}
local ssr2 = nil
local csr2 = nil
local searchBox2 = nil
local sd2 = "FrostWare/Scripts/"
local aef2 = "FrostWare/AutoExec.json"
local ds2 = {
    ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
    ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
    ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
}

local function swS2(sec)
    cs2 = sec
    if lf2 and cf2 then
        if sec == "Local" then
            lf2.Visible = true
            cf2.Visible = false
        else
            lf2.Visible = false
            cf2.Visible = true
        end
    end
end

local function svAE2()
    if not isfolder("FrostWare") then makefolder("FrostWare") end
    writefile(aef2, hs2:JSONEncode(aes2))
end

local function ldAE2()
    if not isfolder("FrostWare") then makefolder(sd2) end
    if isfile(aef2) then
        local ok, dt = pcall(function() return hs2:JSONDecode(readfile(aef2)) end)
        if ok and dt then aes2 = dt end
    end
end

local function tgAE2(nm)
    if aes2[nm] then
        aes2[nm] = nil
    else
        aes2[nm] = true
    end
    svAE2()
    upL2()
end

local function exAS2()
    for nm, _ in pairs(aes2) do
        if ls2[nm] then
            spawn(function()
                local ok, res = pcall(function() return loadstring(ls2[nm]) end)
                if ok and res then pcall(res) end
            end)
        end
    end
end

local function svS2(nm, cont)
    if not isfolder(sd2) then makefolder(sd2) end
    ls2[nm] = cont
    writefile(sd2 .. nm .. ".lua", cont)
    local dt = {}
    for n, c in pairs(ls2) do dt[n] = c end
    writefile(sd2 .. "scripts.json", hs2:JSONEncode(dt))
    upL2()
end

local function dlS2(nm)
    if ds2[nm] then
        fw.sa("Error", "Cannot delete default script!", 2)
        return false
    end
    
    if ls2[nm] then
        if aes2[nm] then
            aes2[nm] = nil
            svAE2()
        end
        
        ls2[nm] = nil
        
        if isfile(sd2 .. nm .. ".lua") then
            pcall(function() delfile(sd2 .. nm .. ".lua") end)
        end
        
        local dt = {}
        for n, c in pairs(ls2) do dt[n] = c end
        writefile(sd2 .. "scripts.json", hs2:JSONEncode(dt))
        
        upL2()
        fw.sa("Success", "Script deleted: " .. nm, 2)
        return true
    end
    return false
end

local function ldS2()
    if not isfolder(sd2) then makefolder(sd2) end
    for nm, cont in pairs(ds2) do ls2[nm] = cont end
    if isfile(sd2 .. "scripts.json") then
        local ok, dt = pcall(function() return hs2:JSONDecode(readfile(sd2 .. "scripts.json")) end)
        if ok and dt then
            for nm, cont in pairs(dt) do ls2[nm] = cont end
        end
    end
    upL2()
end

local function createScriptCard2(parent, name, content, yPos)
    local scd = fw.nf(parent, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 55),
        p = UDim2.new(0, 10, 0, yPos),
        n = "ScriptCard_" .. name
    })
    fw.nc(scd, 0.15)
    
    local title = fw.nt(scd, {
        t = name,
        ts = 16,
        s = UDim2.new(0.4, 0, 0.6, 0),
        p = UDim2.new(0, 15, 0, 5),
        xa = Enum.TextXAlignment.Left,
        tc = Color3.fromRGB(240, 245, 255),
        bt = 1,
        ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
        n = "ScriptTitle"
    })
    fw.ntc(title, 16)
    
    if ds2[name] then
        local vb = fw.nf(scd, {
            c = Color3.fromRGB(20, 60, 110),
            s = UDim2.new(0, 84, 0, 24),
            p = UDim2.new(0, 13, 0, 28)
        })
        fw.nc(vb, 0.18)
        
        local vt = fw.nt(vb, {
            t = "VERIFIED",
            ts = 10,
            tc = Color3.fromRGB(255, 255, 255),
            s = UDim2.new(1, 0, 1, 0),
            bt = 1,
            n = "VerifiedText"
        })
        fw.ntc(vt, 10)
    end
    
    local aeb = fw.nb(scd, {
        c = aes2[name] and Color3.fromRGB(50, 170, 90) or Color3.fromRGB(65, 75, 90),
        s = UDim2.new(0, 80, 0, 25),
        p = UDim2.new(0.45, 0, 0, 15),
        t = aes2[name] and "AUTO: ON" or "AUTO: OFF",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 10,
        n = "AutoExecBtn"
    })
    fw.nc(aeb, 0.15)
    fw.ntc(aeb, 10)
    
    local exb = fw.nb(scd, {
        c = Color3.fromRGB(50, 170, 90),
        s = UDim2.new(0, 80, 0, 25),
        p = UDim2.new(0.65, 0, 0, 15),
        t = "EXECUTE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 11,
        n = "ExecuteBtn"
    })
    fw.nc(exb, 0.15)
    fw.ntc(exb, 11)
    
    local mrb = fw.nb(scd, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0, 60, 0, 25),
        p = UDim2.new(0.85, 0, 0, 15),
        t = "MORE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 11,
        n = "MoreBtn"
    })
    fw.nc(mrb, 0.15)
    fw.ntc(mrb, 11)
    
    exb.MouseEnter:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(60, 180, 100) end)
    exb.MouseLeave:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(50, 170, 90) end)
    mrb.MouseEnter:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
    mrb.MouseLeave:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
    
    exb.MouseButton1Click:Connect(function()
        fw.sa("Success", name .. " executing...", 2)
        local ok, res = pcall(function() return loadstring(content) end)
        if ok and res then
            local eok, err = pcall(res)
            if eok then
                fw.sa("Success", name .. " executed!", 2)
            else
                fw.sa("Error", "Execution failed!", 3)
            end
        else
            fw.sa("Error", "Compilation failed!", 3)
        end
    end)
    
    aeb.MouseButton1Click:Connect(function() tgAE2(name) end)
    mrb.MouseButton1Click:Connect(function() shSO2(name, content) end)
    
    return scd
end

local function filterLocalScripts2(query)
    if not query or query == "" then
        upL2()
        return
    end
    
    if ssr2 then
        for _, ch in pairs(ssr2:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        
        local filteredScripts = {}
        for nm, cont in pairs(ls2) do
            if string.lower(nm):find(string.lower(query)) then
                table.insert(filteredScripts, {name = nm, content = cont})
            end
        end
        
        for i, sc in pairs(filteredScripts) do
            local yp = (i - 1) * 65 + 10
            createScriptCard2(ssr2, sc.name, sc.content, yp)
        end
        
        ssr2.CanvasSize = UDim2.new(0, 0, 0, #filteredScripts * 65 + 20)
    end
end

function upL2()
    if ssr2 then
        for _, ch in pairs(ssr2:GetChildren()) do
            if ch:IsA("Frame") then ch:Destroy() end
        end
        
        local scs = {}
        for nm, cont in pairs(ls2) do
            table.insert(scs, {name = nm, content = cont})
        end
        
        for i, sc in pairs(scs) do
            local yp = (i - 1) * 65 + 10
            createScriptCard2(ssr2, sc.name, sc.content, yp)
        end
        
        ssr2.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
    end
end

function shSO2(nm, cont)
    if sf2 then sf2:Destroy() end
    local ui = fw.gu()
    local mui = ui["11"]
    
    sf2 = fw.nf(mui, {
        c = Color3.fromRGB(0, 0, 0),
        bt = 0.4,
        s = UDim2.new(1, 0, 1, 0),
        p = UDim2.new(0, 0, 0, 0),
        n = "ScriptOptionsOverlay",
        z = 10
    })
    
    local op = fw.nf(sf2, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(0, 400, 0, ds2[nm] and 350 or 400),
        p = UDim2.new(0.5, -200, 0.5, ds2[nm] and -175 or -200),
        n = "OptionsPanel"
    })
    fw.nc(op, 0.18)
    
    local tb = fw.nf(op, {
        c = Color3.fromRGB(30, 35, 45),
        s = UDim2.new(1, 0, 0, 50),
        p = UDim2.new(0, 0, 0, 0),
        n = "TitleBar"
    })
    
    local title = fw.nt(tb, {
        t = "Script Options",
        ts = 18,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(0.8, 0, 1, 0),
        p = UDim2.new(0.1, 0, 0, 0),
        bt = 1,
        n = "Title"
    })
    fw.ntc(title, 18)
    
    local cb = fw.nb(tb, {
        c = Color3.fromRGB(190, 60, 60),
        s = UDim2.new(0, 30, 0, 30),
        p = UDim2.new(1, -40, 0, 10),
        t = "×",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 16,
        n = "CloseBtn"
    })
    fw.nc(cb, 0.15)
    fw.ntc(cb, 16)
    
    cb.MouseButton1Click:Connect(function()
        if sf2 then sf2:Destroy() sf2 = nil end
    end)
    
    local subtitle = fw.nt(op, {
        t = "Choose an action for: " .. nm,
        ts = 12,
        tc = Color3.fromRGB(190, 200, 220),
        s = UDim2.new(0.8, 0, 0, 40),
        p = UDim2.new(0.1, 0, 0, 60),
        ya = Enum.TextYAlignment.Top,
        bt = 1,
        n = "Subtitle"
    })
    fw.ntc(subtitle, 12)
    
    local btns = {
        {text = "EXECUTE SCRIPT", color = Color3.fromRGB(50, 170, 90), pos = UDim2.new(0.1, 0, 0, 120)},
        {text = "OPEN IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
        {text = "SAVE TO FILE", color = Color3.fromRGB(150, 100, 200), pos = UDim2.new(0.1, 0, 0, 220)},
        {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(100, 150, 200), pos = UDim2.new(0.1, 0, 0, 270)}
    }
    
    if not ds2[nm] then
        table.insert(btns, {text = "DELETE SCRIPT", color = Color3.fromRGB(200, 100, 100), pos = UDim2.new(0.1, 0, 0, 320)})
    end
    
    for i, bd in pairs(btns) do
        local btn = fw.nb(op, {
            c = bd.color,
            s = UDim2.new(0.8, 0, 0, 35),
            p = bd.pos,
            t = bd.text,
            tc = Color3.fromRGB(255, 255, 255),
            ts = 12,
            n = "OptionBtn" .. i
        })
        fw.nc(btn, 0.15)
        fw.ntc(btn, 12)
        
        btn.MouseEnter:Connect(function()
            if bd.text == "DELETE SCRIPT" then
                btn.BackgroundColor3 = Color3.fromRGB(220, 120, 120)
            else
                btn.BackgroundColor3 = Color3.fromRGB(bd.color.R * 255 + 20, bd.color.G * 255 + 20, bd.color.B * 255 + 20)
            end
        end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bd.color end)
        
        if bd.text == "EXECUTE SCRIPT" then
            btn.MouseButton1Click:Connect(function()
                fw.sa("Success", nm .. " executing...", 2)
                local ok, res = pcall(function() return loadstring(cont) end)
                if ok and res then
                    local eok, err = pcall(res)
                    if eok then
                        fw.sa("Success", nm .. " executed!", 2)
                    else
                        fw.sa("Error", "Execution failed!", 3)
                    end
                else
                    fw.sa("Error", "Compilation failed!", 3)
                end
                sf2:Destroy()
                sf2 = nil
            end)
        elseif bd.text == "OPEN IN EDITOR" then
            btn.MouseButton1Click:Connect(function()
                local ui = fw.gu()
                local sr = ui["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                if sr then
                    sr.Text = cont
                    fw.sp("Editor", ui["6"]:FindFirstChild("Sidebar"))
                    fw.sa("Success", "Script loaded to editor!", 2)
                    sf2:Destroy()
                    sf2 = nil
                end
            end)
        elseif bd.text == "SAVE TO FILE" then
            btn.MouseButton1Click:Connect(function()
                if not isfolder("FrostWare/Exports") then makefolder("FrostWare/Exports") end
                writefile("FrostWare/Exports/" .. nm .. ".lua", cont)
                fw.sa("Success", "Script saved to file!", 2)
                sf2:Destroy()
                sf2 = nil
            end)
        elseif bd.text == "COPY TO CLIPBOARD" then
            btn.MouseButton1Click:Connect(function()
                if setclipboard then
                    setclipboard(cont)
                    fw.sa("Success", "Script copied to clipboard!", 2)
                else
                    fw.sa("Error", "Clipboard not supported!", 3)
                end
                sf2:Destroy()
                sf2 = nil
            end)
        elseif bd.text == "DELETE SCRIPT" then
            btn.MouseButton1Click:Connect(function()
                dlS2(nm)
                sf2:Destroy()
                sf2 = nil
            end)
        end
    end
end

local function srS2(qry, mr)
    mr = mr or 20
    local ok, res = pcall(function()
        local url = "https://scriptblox.com/api/script/search?q=" .. hs2:UrlEncode(qry) .. "&max=" .. mr
        return game:HttpGet(url)
    end)
    if ok then
        local dt = hs2:JSONDecode(res)
        if dt.result and dt.result.scripts then
            return dt.result.scripts
        end
    end
    return {}
end

local function createCloudCard2(parent, data, index)
    local yp = (index - 1) * 65 + 10
    
    local cc = fw.nf(parent, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 55),
        p = UDim2.new(0, 10, 0, yp),
        n = "CloudCard"
    })
    fw.nc(cc, 0.15)
    
    local title = fw.nt(cc, {
        t = data.title or "Unknown Script",
        ts = 16,
        s = UDim2.new(0.35, 0, 0.6, 0),
        p = UDim2.new(0, 15, 0, 5),
        xa = Enum.TextXAlignment.Left,
        tc = Color3.fromRGB(240, 245, 255),
        bt = 1,
        n = "ScriptTitle"
    })
    fw.ntc(title, 16)
    
    local vb = fw.nf(cc, {
        c = Color3.fromRGB(20, 60, 110),
        s = UDim2.new(0, 84, 0, 24),
        p = UDim2.new(0, 13, 0, 28)
    })
    fw.nc(vb, 0.18)
    
    local vt = fw.nt(vb, {
        t = "VERIFIED",
        ts = 10,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(1, 0, 1, 0),
        bt = 1
    })
    fw.ntc(vt, 10)
    
    local views = fw.nt(cc, {
        t = (data.views or "0") .. " Views",
        ts = 12,
        tc = Color3.fromRGB(160, 170, 190),
        s = UDim2.new(0.2, 0, 0.6, 0),
        p = UDim2.new(0.4, 0, 0, 5),
        xa = Enum.TextXAlignment.Left,
        bt = 1,
        n = "ViewsLabel"
    })
    fw.ntc(views, 12)
    
    local sb = fw.nb(cc, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0, 100, 0, 35),
        p = UDim2.new(1, -110, 0, 10),
        t = "SELECT",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 12,
        n = "SelectBtn"
    })
    fw.nc(sb, 0.15)
    fw.ntc(sb, 12)
    
    sb.MouseEnter:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
    sb.MouseLeave:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
    sb.MouseButton1Click:Connect(function()
        ss2 = data
        shCO2(data)
    end)
    
    return cc
end

function shCO2(dt)
    if sf2 then sf2:Destroy() end
    local ui = fw.gu()
    local mui = ui["11"]
    
    sf2 = fw.nf(mui, {
        c = Color3.fromRGB(0, 0, 0),
        bt = 0.4,
        s = UDim2.new(1, 0, 1, 0),
        p = UDim2.new(0, 0, 0, 0),
        n = "CloudOptionsOverlay",
        z = 10
    })
    
    local op = fw.nf(sf2, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(0, 400, 0, 350),
        p = UDim2.new(0.5, -200, 0.5, -175),
        n = "OptionsPanel"
    })
    fw.nc(op, 0.18)
    
    local tb = fw.nf(op, {
        c = Color3.fromRGB(30, 35, 45),
        s = UDim2.new(1, 0, 0, 50),
        p = UDim2.new(0, 0, 0, 0),
        n = "TitleBar"
    })
    
    local title = fw.nt(tb, {
        t = "Cloud Script Options",
        ts = 18,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(0.8, 0, 1, 0),
        p = UDim2.new(0.1, 0, 0, 0),
        bt = 1,
        n = "Title"
    })
    fw.ntc(title, 18)
    
    local cb = fw.nb(tb, {
        c = Color3.fromRGB(190, 60, 60),
        s = UDim2.new(0, 30, 0, 30),
        p = UDim2.new(1, -40, 0, 10),
        t = "×",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 16,
        n = "CloseBtn"
    })
    fw.nc(cb, 0.15)
    fw.ntc(cb, 16)
    
    cb.MouseButton1Click:Connect(function()
        if sf2 then sf2:Destroy() sf2 = nil end
    end)
    
    local subtitle = fw.nt(op, {
        t = "Choose an action for: " .. (dt.title or "Unknown Script"),
        ts = 12,
        tc = Color3.fromRGB(190, 200, 220),
        s = UDim2.new(0.8, 0, 0, 40),
        p = UDim2.new(0.1, 0, 0, 60),
        ya = Enum.TextYAlignment.Top,
        bt = 1,
        n = "Subtitle"
    })
    fw.ntc(subtitle, 12)
    
    local btns = {
        {text = "EXECUTE SCRIPT", color = Color3.fromRGB(50, 170, 90), pos = UDim2.new(0.1, 0, 0, 120)},
        {text = "OPEN IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
        {text = "SAVE TO LOCAL", color = Color3.fromRGB(150, 100, 200), pos = UDim2.new(0.1, 0, 0, 220)},
        {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(100, 150, 200), pos = UDim2.new(0.1, 0, 0, 270)}
    }
    
    for i, bd in pairs(btns) do
        local btn = fw.nb(op, {
            c = bd.color,
            s = UDim2.new(0.8, 0, 0, 35),
            p = bd.pos,
            t = bd.text,
            tc = Color3.fromRGB(255, 255, 255),
            ts = 12,
            n = "CloudOptionBtn" .. i
        })
        fw.nc(btn, 0.15)
        fw.ntc(btn, 12)
        
        btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(bd.color.R * 255 + 20, bd.color.G * 255 + 20, bd.color.B * 255 + 20) end)
        btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bd.color end)
        
        if i == 1 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs2:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        fw.sa("Success", "Executing script...", 2)
                        local ok, res = pcall(function() return loadstring(sc) end)
                        if ok and res then
                            local eok, err = pcall(res)
                            if eok then
                                fw.sa("Success", "Script executed!", 2)
                            else
                                fw.sa("Error", "Execution failed!", 3)
                            end
                        else
                            fw.sa("Error", "Compilation failed!", 3)
                        end
                    else
                        fw.sa("Error", "Failed to fetch script!", 3)
                    end
                    sf2:Destroy()
                    sf2 = nil
                end)
            end)
        elseif i == 2 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs2:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        local ui = fw.gu()
                        local sr = ui["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                        if sr then
                            sr.Text = sc
                            fw.sp("Editor", ui["6"]:FindFirstChild("Sidebar"))
                            fw.sa("Success", "Script loaded to editor!", 2)
                        end
                    else
                        fw.sa("Error", "Failed to load script!", 3)
                    end
                    sf2:Destroy()
                    sf2 = nil
                end)
            end)
        elseif i == 3 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs2:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc then
                        svS2(dt.title or "CloudScript_" .. tick(), sc)
                        fw.sa("Success", "Script saved!", 2)
                    else
                        fw.sa("Error", "Failed to save!", 3)
                    end
                    sf2:Destroy()
                    sf2 = nil
                end)
            end)
        elseif i == 4 then
            btn.MouseButton1Click:Connect(function()
                spawn(function()
                    local sc = nil
                    if dt.script then
                        sc = dt.script
                    else
                        local ok, res = pcall(function()
                            return game:HttpGet("https://scriptblox.com/api/script/" .. dt._id)
                        end)
                        if ok then
                            local sd = hs2:JSONDecode(res)
                            if sd.script then sc = sd.script end
                        end
                    end
                    if sc and setclipboard then
                        setclipboard(sc)
                        fw.sa("Success", "Script copied!", 2)
                    else
                        fw.sa("Error", "Failed to copy!", 3)
                    end
                    sf2:Destroy()
                    sf2 = nil
                end)
            end)
        end
    end
end

local function dsCS2(scs, sf)
    for _, ch in pairs(sf:GetChildren()) do
        if ch.Name == "CloudCard" then ch:Destroy() end
    end
    for i, sc in pairs(scs) do
        createCloudCard2(sf, sc, i)
    end
    sf.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
end

local function performSearch2()
    if cs2 == "Cloud" then
        local qry = searchBox2.Text
        if qry and qry ~= "" then
            fw.sa("Info", "Searching scripts...", 1)
            spawn(function()
                local scs = srS2(qry, 50)
                if #scs > 0 then
                    csc2 = scs
                    dsCS2(scs, csr2)
                    fw.sa("Success", "Found " .. #scs .. " scripts!", 2)
                else
                    fw.sa("Error", "No scripts found!", 2)
                end
            end)
        end
    elseif cs2 == "Local" then
        local qry = searchBox2.Text
        filterLocalScripts2(qry)
    end
end

function fw.cstp()
    local g = fw.gu()
    local sp2 = fw.nim(g["11"], {
        it = 1,
        ic = Color3.fromRGB(15, 18, 25),
        i = "rbxassetid://18665679839",
        s = UDim2.new(1.001, 0, 1, 0),
        v = false,
        cl = true,
        bt = 1,
        n = "ScriptsPage",
        p = UDim2.new(-0.001, 0, 0, 0)
    })

    local tb2 = fw.nf(sp2, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 60),
        p = UDim2.new(0, 10, 0, 10),
        n = "TopBar"
    })
    fw.nc(tb2, 0.18)

    local sbo2 = fw.nf(tb2, {
        c = Color3.fromRGB(18, 22, 32),
        s = UDim2.new(0.5, -10, 0, 35),
        p = UDim2.new(0, 15, 0, 12),
        n = "SearchBox_Outer"
    })
    fw.nc(sbo2, 0.18)

    searchBox2 = fw.ntb(sbo2, {
        c = Color3.fromRGB(35, 40, 50),
        s = UDim2.new(1, -8, 1, -8),
        p = UDim2.new(0, 4, 0, 4),
        pc = Color3.fromRGB(120, 130, 150),
        t = "",
        ts = 14,
        tc = Color3.fromRGB(240, 245, 255),
        ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        n = "SearchBox"
    })
    fw.nc(searchBox2, 0.15)
    fw.ntc(searchBox2, 14)

    local lt2 = fw.nb(tb2, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0.2, -5, 0, 35),
        p = UDim2.new(0.55, 5, 0, 12),
        t = "LOCAL",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 14,
        n = "LocalTab"
    })
    fw.nc(lt2, 0.15)
    fw.ntc(lt2, 14)

    local ct2 = fw.nb(tb2, {
        c = Color3.fromRGB(65, 75, 90),
        s = UDim2.new(0.2, -5, 0, 35),
        p = UDim2.new(0.78, 5, 0, 12),
        t = "CLOUD",
        tc = Color3.fromRGB(190, 200, 220),
        ts = 14,
        n = "CloudTab"
    })
    fw.nc(ct2, 0.15)
    fw.ntc(ct2, 14)

    lf2 = fw.nf(sp2, {
        bt = 1,
        s = UDim2.new(1, 0, 1, -80),
        p = UDim2.new(0, 0, 0, 80),
        n = "LocalFrame",
        v = true
    })

    cf2 = fw.nf(sp2, {
        bt = 1,
        s = UDim2.new(1, 0, 1, -80),
        p = UDim2.new(0, 0, 0, 80),
        n = "CloudFrame",
        v = false
    })

    local ap2 = fw.nf(lf2, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(1, -20, 0, 80),
        p = UDim2.new(0, 10, 0, 10),
        n = "AddPanel"
    })
    fw.nc(ap2, 0.18)

    local nio2 = fw.nf(ap2, {
        c = Color3.fromRGB(18, 22, 32),
        s = UDim2.new(0.25, -5, 0, 30),
        p = UDim2.new(0, 10, 0, 10),
        n = "NameInput_Outer"
    })
    fw.nc(nio2, 0.18)

    local ni2 = fw.ntb(nio2, {
        c = Color3.fromRGB(35, 40, 50),
        s = UDim2.new(1, -8, 1, -8),
        p = UDim2.new(0, 4, 0, 4),
        pc = Color3.fromRGB(120, 130, 150),
        t = "",
        ts = 12,
        tc = Color3.fromRGB(240, 245, 255),
        ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        n = "NameInput"
    })
    fw.nc(ni2, 0.15)
    fw.ntc(ni2, 12)

    local cio2 = fw.nf(ap2, {
        c = Color3.fromRGB(18, 22, 32),
        s = UDim2.new(0.45, -5, 0, 30),
        p = UDim2.new(0.27, 5, 0, 10),
        n = "ContentInput_Outer"
    })
    fw.nc(cio2, 0.18)

    local ci2 = fw.ntb(cio2, {
        c = Color3.fromRGB(35, 40, 50),
        s = UDim2.new(1, -8, 1, -8),
        p = UDim2.new(0, 4, 0, 4),
        pc = Color3.fromRGB(120, 130, 150),
        t = "",
        ts = 12,
        tc = Color3.fromRGB(240, 245, 255),
        ff = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
        n = "ContentInput"
    })
    fw.nc(ci2, 0.15)
    fw.ntc(ci2, 12)

    local svb2 = fw.nb(ap2, {
        c = Color3.fromRGB(50, 170, 90),
        s = UDim2.new(0.12, -5, 0, 30),
        p = UDim2.new(0.74, 5, 0, 10),
        t = "SAVE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 12,
        n = "SaveBtn"
    })
    fw.nc(svb2, 0.15)
    fw.ntc(svb2, 12)

    local pb2 = fw.nb(ap2, {
        c = Color3.fromRGB(50, 130, 210),
        s = UDim2.new(0.12, -5, 0, 30),
        p = UDim2.new(0.88, 5, 0, 10),
        t = "PASTE",
        tc = Color3.fromRGB(255, 255, 255),
        ts = 12,
        n = "PasteBtn"
    })
    fw.nc(pb2, 0.15)
    fw.ntc(pb2, 12)

    local sc2 = fw.nf(lf2, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(1, -20, 1, -110),
        p = UDim2.new(0, 10, 0, 100),
        n = "ScriptsContainer"
    })
    fw.nc(sc2, 0.18)

    local ss2_scroll = fw.nsf(sc2, {
        bt = 1,
        s = UDim2.new(1, -10, 1, -10),
        p = UDim2.new(0, 5, 0, 5),
        sb = 8,
        cs = UDim2.new(0, 0, 0, 0),
        n = "ScriptsScroll",
        sic = Color3.fromRGB(50, 130, 210)
    })
    ssr2 = ss2_scroll

    local cc2 = fw.nf(cf2, {
        c = Color3.fromRGB(20, 25, 35),
        s = UDim2.new(1, -20, 1, -20),
        p = UDim2.new(0, 10, 0, 10),
        n = "CloudContainer"
    })
    fw.nc(cc2, 0.18)

    local cs2_scroll = fw.nsf(cc2, {
        bt = 1,
        s = UDim2.new(1, -10, 1, -10),
        p = UDim2.new(0, 5, 0, 5),
        cs = UDim2.new(0, 0, 0, 0),
        sb = 8,
        n = "CloudScroll",
        sic = Color3.fromRGB(50, 130, 210)
    })
    csr2 = cs2_scroll

    svb2.MouseButton1Click:Connect(function()
        local nm = ni2.Text
        local cont = ci2.Text
        if nm and nm ~= "" and cont and cont ~= "" then
            svS2(nm, cont)
            ni2.Text = ""
            ci2.Text = ""
            fw.sa("Success", "Script saved: " .. nm, 2)
        else
            fw.sa("Error", "Please enter name and content!", 2)
        end
    end)

    pb2.MouseButton1Click:Connect(function()
        local cb = getclipboard and getclipboard() or ""
        if cb ~= "" then
            ci2.Text = cb
            fw.sa("Success", "Content pasted!", 2)
        else
            fw.sa("Error", "Clipboard is empty!", 2)
        end
    end)

    searchBox2.FocusLost:Connect(function(ep)
        if ep then
            performSearch2()
        end
    end)

    searchBox2.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then
            performSearch2()
        end
    end)

    lt2.MouseButton1Click:Connect(function()
        swS2("Local")
        lt2.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        ct2.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
    end)

    ct2.MouseButton1Click:Connect(function()
        swS2("Cloud")
        ct2.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        lt2.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
    end)

    ldAE2()
    ldS2()
    exAS2()

    spawn(function()
        fw.sa("Info", "Loading popular scripts...", 1)
        local ps = srS2("popular", 30)
        if #ps > 0 then
            csc2 = ps
            dsCS2(ps, csr2)
        end
    end)

    return sp2
end

fw.addTab("Scripts", "Scripts", "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.44, 0), fw.cstp)

return true
