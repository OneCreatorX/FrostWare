repeat task.wait() until game:IsLoaded()
local hs2 = game:GetService("HttpService")
local ts2 = game:GetService("TweenService")
local cs2 = "Local"
local lf2, cf2, csc2, ss2, sf2 = nil, nil, {}, nil, nil
local ls2, aes2 = {}, {}
local ssr2 = nil
local csr2 = nil
local sb2 = nil
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
    local function sw2(sec)
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

    local function sv2()
        if not isfolder("FrostWare") then makefolder("FrostWare") end
        writefile(aef2, hs2:JSONEncode(aes2))
    end

    local function ld2()
        if not isfolder("FrostWare") then makefolder(sd2) end
        if isfile(aef2) then
            local ok, dt = pcall(function() return hs2:JSONDecode(readfile(aef2)) end)
            if ok and dt then aes2 = dt end
        end
    end

    local function tg2(nm)
        if aes2[nm] then
            aes2[nm] = nil
        else
            aes2[nm] = true
        end
        sv2()
        up2()
    end

    local function ex2()
        for nm, _ in pairs(aes2) do
            if ls2[nm] then
                spawn(function()
                    local ok, res = pcall(function() return loadstring(ls2[nm]) end)
                    if ok and res then pcall(res) end
                end)
            end
        end
    end

    local function sv3(nm, cont)
        if not isfolder(sd2) then makefolder(sd2) end
        ls2[nm] = cont
        writefile(sd2 .. nm .. ".lua", cont)
        local dt = {}
        for n, c in pairs(ls2) do dt[n] = c end
        writefile(sd2 .. "scripts.json", hs2:JSONEncode(dt))
        up2()
    end

    local function dl2(nm)
        if ds2[nm] then
            fw.sa("Error", "Cannot delete default script!", 2)
            return false
        end
        
        if ls2[nm] then
            if aes2[nm] then
                aes2[nm] = nil
                sv2()
            end
            
            ls2[nm] = nil
            
            if isfile(sd2 .. nm .. ".lua") then
                pcall(function() delfile(sd2 .. nm .. ".lua") end)
            end
            
            local dt = {}
            for n, c in pairs(ls2) do dt[n] = c end
            writefile(sd2 .. "scripts.json", hs2:JSONEncode(dt))
            
            up2()
            fw.sa("Success", "Script deleted: " .. nm, 2)
            return true
        end
        return false
    end

    local function ld3()
        if not isfolder(sd2) then makefolder(sd2) end
        for nm, cont in pairs(ds2) do ls2[nm] = cont end
        if isfile(sd2 .. "scripts.json") then
            local ok, dt = pcall(function() return hs2:JSONDecode(readfile(sd2 .. "scripts.json")) end)
            if ok and dt then
                for nm, cont in pairs(dt) do ls2[nm] = cont end
            end
        end
        up2()
    end

    local function cc2(parent, name, content, yPos)
        local scd = nf(parent, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-10,0,80), p=UDim2.new(0,5,0,yPos), n="ScriptCard_"..name})
        nc(scd, 0.15)
        
        local title = nt(scd, {t=name, ts=14, s=UDim2.new(0.4,0,0.4,0), p=UDim2.new(0.02,0,0.05,0), xa=Enum.TextXAlignment.Left, tc=Color3.fromRGB(240,245,255), bt=1, ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal), n="ScriptTitle"})
        ntc(title, 14)
        
        if ds2[name] then
            local vb = nf(scd, {c=Color3.fromRGB(20,60,110), s=UDim2.new(0.15,0,0.25,0), p=UDim2.new(0.02,0,0.45,0)})
            nc(vb, 0.18)
            local vt = nt(vb, {t="VERIFIED", ts=8, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,1,0), bt=1, n="VerifiedText"})
            ntc(vt, 8)
        end
        
        local aeb = nb(scd, {c=aes2[name] and Color3.fromRGB(50,170,90) or Color3.fromRGB(65,75,90), s=UDim2.new(0.15,0,0.35,0), p=UDim2.new(0.45,0,0.3,0), t=aes2[name] and "AUTO: ON" or "AUTO: OFF", tc=Color3.fromRGB(255,255,255), ts=9, n="AutoExecBtn"})
        nc(aeb, 0.15)
        ntc(aeb, 9)
        
        local exb = nb(scd, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.15,0,0.35,0), p=UDim2.new(0.62,0,0.3,0), t="EXECUTE", tc=Color3.fromRGB(255,255,255), ts=9, n="ExecuteBtn"})
        nc(exb, 0.15)
        ntc(exb, 9)
        
        local mrb = nb(scd, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.15,0,0.35,0), p=UDim2.new(0.79,0,0.3,0), t="MORE", tc=Color3.fromRGB(255,255,255), ts=9, n="MoreBtn"})
        nc(mrb, 0.15)
        ntc(mrb, 9)
        
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
        
        aeb.MouseButton1Click:Connect(function() tg2(name) end)
        
        return scd
    end

    function up2()
        if ssr2 then
            for _, ch in pairs(ssr2:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            
            local scs = {}
            for nm, cont in pairs(ls2) do
                table.insert(scs, {name = nm, content = cont})
            end
            
            for i, sc in pairs(scs) do
                local yp = (i - 1) * 90 + 5
                cc2(ssr2, sc.name, sc.content, yp)
            end
            
            ssr2.CanvasSize = UDim2.new(0, 0, 0, #scs * 90 + 10)
        end
    end

    local function sr2(qry, mr)
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

    local function cc3(parent, data, index)
        local yp = (index - 1) * 90 + 5
        local cc = nf(parent, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,-10,0,80), p=UDim2.new(0,5,0,yp), n="CloudCard"})
        nc(cc, 0.15)
        
        local title = nt(cc, {t=data.title or "Unknown Script", ts=14, s=UDim2.new(0.5,0,0.4,0), p=UDim2.new(0.02,0,0.05,0), xa=Enum.TextXAlignment.Left, tc=Color3.fromRGB(240,245,255), bt=1, n="ScriptTitle"})
        ntc(title, 14)
        
        local vb = nf(cc, {c=Color3.fromRGB(20,60,110), s=UDim2.new(0.15,0,0.25,0), p=UDim2.new(0.02,0,0.45,0)})
        nc(vb, 0.18)
        local vt = nt(vb, {t="VERIFIED", ts=8, tc=Color3.fromRGB(255,255,255), s=UDim2.new(1,0,1,0), bt=1})
        ntc(vt, 8)
        
        local views = nt(cc, {t=(data.views or "0") .. " Views", ts=10, tc=Color3.fromRGB(160,170,190), s=UDim2.new(0.25,0,0.3,0), p=UDim2.new(0.5,0,0.1,0), xa=Enum.TextXAlignment.Left, bt=1, n="ViewsLabel"})
        ntc(views, 10)
        
        local sb = nb(cc, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,0,0.4,0), p=UDim2.new(0.75,0,0.3,0), t="SELECT", tc=Color3.fromRGB(255,255,255), ts=10, n="SelectBtn"})
        nc(sb, 0.15)
        ntc(sb, 10)
        
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

    local function ds2(scs, sf)
        for _, ch in pairs(sf:GetChildren()) do
            if ch.Name == "CloudCard" then ch:Destroy() end
        end
        for i, sc in pairs(scs) do
            cc3(sf, sc, i)
        end
        sf.CanvasSize = UDim2.new(0, 0, 0, #scs * 90 + 10)
    end

    local function ps2()
        if cs2 == "Cloud" then
            local qry = sb2.Text
            if qry and qry ~= "" then
                fw.sa("Info", "Searching scripts...", 1)
                spawn(function()
                    local scs = sr2(qry, 50)
                    if #scs > 0 then
                        csc2 = scs
                        ds2(scs, csr2)
                        fw.sa("Success", "Found " .. #scs .. " scripts!", 2)
                    else
                        fw.sa("Error", "No scripts found!", 2)
                    end
                end)
            end
        elseif cs2 == "Local" then
            local qry = sb2.Text
            if not qry or qry == "" then
                up2()
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
                    local yp = (i - 1) * 90 + 5
                    cc2(ssr2, sc.name, sc.content, yp)
                end
                
                ssr2.CanvasSize = UDim2.new(0, 0, 0, #filteredScripts * 90 + 10)
            end
        end
    end

    local tb2 = nf(scriptsPageFrame, {c=Color3.fromRGB(25,30,40), s=UDim2.new(0.95,0,0.12,0), p=UDim2.new(0.025,0,0.02,0), n="TopBar"})
    nc(tb2, 0.18)

    local sbo2 = nf(tb2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.5,0,0.6,0), p=UDim2.new(0.02,0,0.2,0), n="SearchBox_Outer"})
    nc(sbo2, 0.18)

    sb2 = ntb(sbo2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=12, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="SearchBox"})
    nc(sb2, 0.15)
    ntc(sb2, 12)

    local lt2 = nb(tb2, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.55,0,0.2,0), t="LOCAL", tc=Color3.fromRGB(255,255,255), ts=12, n="LocalTab"})
    nc(lt2, 0.15)
    ntc(lt2, 12)

    local ct2 = nb(tb2, {c=Color3.fromRGB(65,75,90), s=UDim2.new(0.2,0,0.6,0), p=UDim2.new(0.77,0,0.2,0), t="CLOUD", tc=Color3.fromRGB(190,200,220), ts=12, n="CloudTab"})
    nc(ct2, 0.15)
    ntc(ct2, 12)

    lf2 = nf(scriptsPageFrame, {bt=1, s=UDim2.new(0.95,0,0.84,0), p=UDim2.new(0.025,0,0.15,0), n="LocalFrame", v=true})
    cf2 = nf(scriptsPageFrame, {bt=1, s=UDim2.new(0.95,0,0.84,0), p=UDim2.new(0.025,0,0.15,0), n="CloudFrame", v=false})

    local ap2 = nf(lf2, {c=Color3.fromRGB(25,30,40), s=UDim2.new(1,0,0.15,0), p=UDim2.new(0,0,0,0), n="AddPanel"})
    nc(ap2, 0.18)

    local nio2 = nf(ap2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.25,0,0.5,0), p=UDim2.new(0.02,0,0.25,0), n="NameInput_Outer"})
    nc(nio2, 0.18)

    local ni2 = ntb(nio2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.9,0,0.8,0), p=UDim2.new(0.05,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=10, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="NameInput"})
    nc(ni2, 0.15)
    ntc(ni2, 10)

    local cio2 = nf(ap2, {c=Color3.fromRGB(18,22,32), s=UDim2.new(0.4,0,0.5,0), p=UDim2.new(0.29,0,0.25,0), n="ContentInput_Outer"})
    nc(cio2, 0.18)

    local ci2 = ntb(cio2, {c=Color3.fromRGB(35,40,50), s=UDim2.new(0.95,0,0.8,0), p=UDim2.new(0.025,0,0.1,0), pc=Color3.fromRGB(120,130,150), t="", ts=10, tc=Color3.fromRGB(240,245,255), ff=Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Regular,Enum.FontStyle.Normal), n="ContentInput"})
    nc(ci2, 0.15)
    ntc(ci2, 10)

    local svb2 = nb(ap2, {c=Color3.fromRGB(50,170,90), s=UDim2.new(0.12,0,0.5,0), p=UDim2.new(0.71,0,0.25,0), t="SAVE", tc=Color3.fromRGB(255,255,255), ts=10, n="SaveBtn"})
    nc(svb2, 0.15)
    ntc(svb2, 10)

    local pb2 = nb(ap2, {c=Color3.fromRGB(50,130,210), s=UDim2.new(0.12,0,0.5,0), p=UDim2.new(0.85,0,0.25,0), t="PASTE", tc=Color3.fromRGB(255,255,255), ts=10, n="PasteBtn"})
    nc(pb2, 0.15)
    ntc(pb2, 10)

    local sc2 = nf(lf2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(1,0,0.83,0), p=UDim2.new(0,0,0.17,0), n="ScriptsContainer"})
    nc(sc2, 0.18)

    ssr2 = nsf(sc2, {bt=1, s=UDim2.new(0.98,0,0.98,0), p=UDim2.new(0.01,0,0.01,0), sb=6, cs=UDim2.new(0,0,0,0), n="ScriptsScroll", sic=Color3.fromRGB(50,130,210)})

    local cc4 = nf(cf2, {c=Color3.fromRGB(20,25,35), s=UDim2.new(1,0,1,0), p=UDim2.new(0,0,0,0), n="CloudContainer"})
    nc(cc4, 0.18)

    csr2 = nsf(cc4, {bt=1, s=UDim2.new(0.98,0,0.98,0), p=UDim2.new(0.01,0,0.01,0), cs=UDim2.new(0,0,0,0), sb=6, n="CloudScroll", sic=Color3.fromRGB(50,130,210)})

    svb2.MouseButton1Click:Connect(function()
        local nm = ni2.Text
        local cont = ci2.Text
        if nm and nm ~= "" and cont and cont ~= "" then
            sv3(nm, cont)
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

    sb2.FocusLost:Connect(function(ep)
        if ep then ps2() end
    end)

    sb2.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Return then
            ps2()
        end
    end)

    lt2.MouseButton1Click:Connect(function()
        sw2("Local")
        lt2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        ct2.BackgroundColor3 = Color3.fromRGB(65,75,90)
    end)

    ct2.MouseButton1Click:Connect(function()
        sw2("Cloud")
        ct2.BackgroundColor3 = Color3.fromRGB(50,130,210)
        lt2.BackgroundColor3 = Color3.fromRGB(65,75,90)
    end)

    ld2()
    ld3()
    ex2()

    spawn(function()
        fw.sa("Info", "Loading popular scripts...", 1)
        local ps = sr2("popular", 30)
        if #ps > 0 then
            csc2 = ps
            ds2(ps, csr2)
        end
    end)
end
