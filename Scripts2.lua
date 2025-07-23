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

fw.addTab("Scripts", "Scripts", "rbxassetid://107390243416427", UDim2.new(0.075, 0, 0.44, 0), fw.cscp)

local pagesContainer = fw.gu()["11"]
local scriptsPageFrame = pagesContainer:FindFirstChild("ScriptsPage")

if scriptsPageFrame then
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
        local scd = nf(parent, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-20,0,55), p=UDim2.new(0,10,0,yPos), n="ScriptCard_"..name})
        nc(scd, 0.15)
        
        local title = nt(scd, {t=name, ts=16, s=UDim2.new(0.4,0,0.6,0), p=UDim2.new(0,15,0,5), xa=Enum.TextXAlignment.Left, tc=Color3.fromRGB(240,245,255), bt=1, ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal), n="ScriptTitle"})
        ntc(title, 16)
        
        if ds2[name] then
            local vb = nf(scd, {c=Color3.fromRGB(20,60,110), s=UDim2.new(0,84,0,24), p=UDim2.new(0,13,0,28)})
            nc(vb, 0.18)
            local vt = nt(vb, {t="VERIFIED", ts=10, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,1,0), bt=1, n="VerifiedText"})
            ntc(vt, 10)
        end
        
        local aeb = nb(scd, {c=aes2[name] and Color3.fromRGB(50,170,90) or Color3.fromRGB(65,75,90), s=UDim2.new(0,80,0,25), p=UDim2.new(0.45,0,0,15), t=aes2[name] and "AUTO: ON" or "AUTO: OFF", tc=Color3.fromRGB(255,255,255), ts=10, n="AutoExecBtn"})
        nc(aeb, 0.15)
        ntc(aeb, 10)
        
        local exb = nb(scd, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0,80,0,25), p=UDim2.new(0.65,0,0,15), t="EXECUTE", tc=Color3.fromRGB(255,255,255), ts=11, n="ExecuteBtn"})
        nc(exb, 0.15)
        ntc(exb, 11)
        
        local mrb = nb(scd, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0,60,0,25), p=UDim2.new(0.85,0,0,15), t="MORE", tc=Color3.fromRGB(255,255,255), ts=11, n="MoreBtn"})
        nc(mrb, 0.15)
        ntc(mrb, 11)
        
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
        
        return scd
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
        local cc = nf(parent, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-20,0,55), p=UDim2.new(0,10,0,yp), n="CloudCard"})
        nc(cc, 0.15)
        
        local title = nt(cc, {t=data.title or "Unknown Script", ts=16, s=UDim2.new(0.35,0,0.6,0), p=UDim2.new(0,15,0,5), xa=Enum.TextXAlignment.Left, tc=Color3.fromRGB(240,245,255), bt=1, n="ScriptTitle"})
        ntc(title, 16)
        
        local vb = nf(cc, {c=Color3.fromRGB(20,60,110), s=UDim2.new(0,84,0,24), p=UDim2.new(0,13,0,28)})
        nc(vb, 0.18)
        local vt = nt(vb, {t="VERIFIED", ts=10, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,1,0), bt=1})
        ntc(vt, 10)
        
        local views = nt(cc, {t=(data.views or "0") .. " Views", ts=12, tc=Color3.fromRGB(160,170,190), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.4,0,0,5), xa=Enum.TextXAlignment.Left, bt=1, n="ViewsLabel"})
        ntc(views, 12)
        
        local sb = nb(cc, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0,100,0,35), p=UDim2.new(1,-110,0,10), t="SELECT", tc=Color3.fromRGB(255,255,255), ts=12, n="SelectBtn"})
        nc(sb, 0.15)
        ntc(sb, 12)
        
        sb.MouseButton1Click:Connect(function()
            fw.sa("Success", "Executing cloud script...", 2)
            spawn(function()
                local sc = nil
                if data.script then
                    sc = data.script
                else
                    local ok, res = pcall(function()
                        return game:HttpGet("https://scriptblox.com/api/script/" .. data._id)
                    end)
                    if ok then
                        local sd = hs2:JSONDecode(res)
                        if sd.script then sc = sd.script end
                    end
                end
                if sc then
                    local ok, res = pcall(function() return loadstring(sc) end)
                    if ok and res then
                        local eok, err = pcall(res)
                        if eok then
                            fw.sa("Success", "Cloud script executed!", 2)
                        else
                            fw.sa("Error", "Execution failed!", 3)
                        end
                    else
                        fw.sa("Error", "Compilation failed!", 3)
                    end
                else
                    fw.sa("Error", "Failed to fetch script!", 3)
                end
            end)
        end)
        
        return cc
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
            if not qry or qry == "" then
                upL2()
                return
            end
            
            if ssr2 then
                for _, ch in pairs(ssr2:GetChildren()) do
                    if ch:IsA("Frame") then ch:Destroy() end
                end
                
                local filteredScripts = {}
                for nm, cont in pairs(ls2) do
                    if string.lower(nm):find(string.lower(qry)) then
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
    end

    local tit = nt(scriptsPageFrame, {t="Scripts", ts=48, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.1,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 48)
    
    local info = nt(scriptsPageFrame, {t="Administra y ejecuta scripts locales y de la nube.", ts=24, tc=Color3.fromRGB(180,180,180), bt=1, s=UDim2.new(1,0,0.1,0), p=UDim2.new(0,0,0.25,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular,Enum.FontStyle.Normal)})
    ntc(info, 24)

    local tb2 = nf(scriptsPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-20,0,60), p=UDim2.new(0,10,0,200), n="TopBar"})
    nc(tb2, 0.18)

    local sbo2 = nf(tb2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.5,-10,0,35), p=UDim2.new(0,15,0,12), n="SearchBox_Outer"})
    nc(sbo2, 0.18)

    searchBox2 = ntb(sbo2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(1,-8,1,-8), p=UDim2.new(0,4,0,4), pc=Color3.fromRGB(120,130,150), t="", ts=14, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="SearchBox"})
    nc(searchBox2, 0.15)
    ntc(searchBox2, 14)

    local lt2 = nb(tb2, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,-5,0,35), p=UDim2.new(0.55,5,0,12), t="LOCAL", tc=Color3.fromRGB(255,255,255), ts=14, n="LocalTab"})
    nc(lt2, 0.15)
    ntc(lt2, 14)

    local ct2 = nb(tb2, {c=Color3.fromRGB(65,75,90), s=UDim2.new(0.2,-5,0,35), p=UDim2.new(0.78,5,0,12), t="CLOUD", tc=Color3.fromRGB(190,200,220), ts=14, n="CloudTab"})
    nc(ct2, 0.15)
    ntc(ct2, 14)

    lf2 = nf(scriptsPageFrame, {bt=1, s=UDim2.new(1,0,1,-280), p=UDim2.new(0,0,0,270), n="LocalFrame", v=true})
    cf2 = nf(scriptsPageFrame, {bt=1, s=UDim2.new(1,0,1,-280), p=UDim2.new(0,0,0,270), n="CloudFrame", v=false})

    local ap2 = nf(lf2, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-20,0,80), p=UDim2.new(0,10,0,10), n="AddPanel"})
    nc(ap2, 0.18)

    local nio2 = nf(ap2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.25,-5,0,30), p=UDim2.new(0,10,0,10), n="NameInput_Outer"})
    nc(nio2, 0.18)

    local ni2 = ntb(nio2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(1,-8,1,-8), p=UDim2.new(0,4,0,4), pc=Color3.fromRGB(120,130,150), t="", ts=12, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="NameInput"})
    nc(ni2, 0.15)
    ntc(ni2, 12)

    local cio2 = nf(ap2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.45,-5,0,30), p=UDim2.new(0.27,5,0,10), n="ContentInput_Outer"})
    nc(cio2, 0.18)

    local ci2 = ntb(cio2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(1,-8,1,-8), p=UDim2.new(0,4,0,4), pc=Color3.fromRGB(120,130,150), t="", ts=12, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="ContentInput"})
    nc(ci2, 0.15)
    ntc(ci2, 12)

    local svb2 = nb(ap2, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.12,-5,0,30), p=UDim2.new(0.74,5,0,10), t="SAVE", tc=Color3.fromRGB(255,255,255), ts=12, n="SaveBtn"})
    nc(svb2, 0.15)
    ntc(svb2, 12)

    local pb2 = nb(ap2, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.12,-5,0,30), p=UDim2.new(0.88,5,0,10), t="PASTE", tc=Color3.fromRGB(255,255,255), ts=12, n="PasteBtn"})
    nc(pb2, 0.15)
    ntc(pb2, 12)

    local sc2 = nf(lf2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(1,-20,1,-110), p=UDim2.new(0,10,0,100), n="ScriptsContainer"})
    nc(sc2, 0.18)

    ssr2 = nsf(sc2, {bt=1, s=UDim2.new(1,-10,1,-10), p=UDim2.new(0,5,0,5), sb=8, cs=UDim2.new(0,0,0,0), n="ScriptsScroll", sic=Color3.fromRGB(50,130,210)})

    local cc2 = nf(cf2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(1,-20,1,-20), p=UDim2.new(0,10,0,10), n="CloudContainer"})
    nc(cc2, 0.18)

    csr2 = nsf(cc2, {bt=1, s=UDim2.new(1,-10,1,-10), p=UDim2.new(0,5,0,5), cs=UDim2.new(0,0,0,0), sb=8, n="CloudScroll", sic=Color3.fromRGB(50,130,210)})

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
        if ep then performSearch2() end
    end)

    searchBox2.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then
            performSearch2()
        end
    end)

    lt2.MouseButton1Click:Connect(function()
        swS2("Local")
        lt2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        ct2.BackgroundColor3 = Color3.fromRGB(65,75,90)
    end)

    ct2.MouseButton1Click:Connect(function()
        swS2("Cloud")
        ct2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        lt2.BackgroundColor3 = Color3.fromRGB(65,75,90)
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
end

return true
