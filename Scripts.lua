while not getgenv()._FW_ACCESS_GRANTED do
    wait(0.5)
end

spawn(function()
    wait(1)
    local FW = getgenv()._FW or {}
    local hs = game:GetService("HttpService")
    local ts = game:GetService("TweenService")
    local cs = curSec or "Local"
    local lf, cf, csc, ss, sf = nil, nil, {}, nil, nil
    local ls, aes = {}, {}
    local ssr = nil
    local sd = "FrostWare/Scripts/"
    local aef = "FrostWare/AutoExec.json"
    
    local ds = {
        ["Infinite Yield"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()",
        ["Dark Dex"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/infyiff/backup/main/dex.lua'))()",
        ["Remote Spy"] = "loadstring(game:HttpGet('https://raw.githubusercontent.com/exxtremestuffs/SimpleSpySource/master/SimpleSpy.lua'))()"
    }
    
    local function gImg(url, fn)
        local fd = "Images/"
        local pt = fd .. fn
        if not isfolder(fd) then makefolder(fd) end
        if not isfile(pt) then
            local ok, dt = pcall(function() return game:HttpGet(url) end)
            if not ok then warn("Error downloading image: " .. tostring(dt)) return nil end
            writefile(pt, dt)
        end
        return getcustomasset(pt)
    end
    
    local function cST(p, pr)
        local t = FW.cT(p, {
            Text = pr.Text,
            TextSize = pr.TextSize or 14,
            TextColor3 = pr.TextColor3 or Color3.fromRGB(240, 245, 255),
            BackgroundTransparency = pr.BackgroundTransparency or 1,
            Size = pr.Size,
            Position = pr.Position,
            TextXAlignment = pr.TextXAlignment or Enum.TextXAlignment.Center,
            TextYAlignment = pr.TextYAlignment or Enum.TextYAlignment.Center,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Name = pr.Name or "StyledText"
        })
        FW.cTC(t, pr.TextSize or 14)
        return t
    end
    
    local function cSB(p, pr)
        local of = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(12, 16, 24),
            Size = pr.Size,
            Position = pr.Position,
            Name = pr.Name .. "_Outer"
        })
        FW.cC(of, 0.18)
        
        local ib = FW.cB(of, {
            BackgroundColor3 = pr.BackgroundColor3,
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2),
            Text = pr.Text,
            TextColor3 = pr.TextColor3,
            TextSize = pr.TextSize,
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
            Name = pr.Name
        })
        FW.cC(ib, 0.15)
        FW.cTC(ib, pr.TextSize)
        
        return ib, of
    end
    
    local function cSI(p, pr)
        local of = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(18, 22, 32),
            Size = pr.Size,
            Position = pr.Position,
            Name = pr.Name .. "_Outer"
        })
        FW.cC(of, 0.18)
        
        local inp = FW.cTB(of, {
            BackgroundColor3 = Color3.fromRGB(35, 40, 50),
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            PlaceholderText = pr.PlaceholderText,
            PlaceholderColor3 = Color3.fromRGB(120, 130, 150),
            Text = pr.Text or "",
            TextSize = pr.TextSize,
            TextColor3 = Color3.fromRGB(240, 245, 255),
            FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
            Name = pr.Name
        })
        FW.cC(inp, 0.15)
        FW.cTC(inp, pr.TextSize)
        
        return inp, of
    end
    
    local function cSC(p, pr)
        local of = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(8, 12, 20),
            Size = pr.Size,
            Position = pr.Position,
            Name = pr.Name .. "_Outer"
        })
        FW.cC(of, 0.18)
        
        local inf = FW.cF(of, {
            BackgroundColor3 = pr.BackgroundColor3 or Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(1, -8, 1, -8),
            Position = UDim2.new(0, 4, 0, 4),
            Name = pr.Name
        })
        FW.cC(inf, 0.15)
        
        return inf, of
    end
    
    local function cVB(p, pos)
        local vo = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(20, 60, 110),
            Size = UDim2.new(0, 84, 0, 24),
            Position = pos
        })
        FW.cC(vo, 0.18)
        
        local vb = FW.cF(vo, {
            BackgroundColor3 = Color3.fromRGB(50, 130, 210),
            Size = UDim2.new(1, -4, 1, -4),
            Position = UDim2.new(0, 2, 0, 2)
        })
        FW.cC(vb, 0.15)
        
        cST(vb, {
            Text = "VERIFIED",
            TextSize = 10,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(1, 0, 1, 0),
            Name = "VerifiedText"
        })
        
        return vb
    end
    
    local sia = gImg("https://cdn-icons-png.flaticon.com/512/1126/1126012.png", "script_icon.png")
    
    local function swS(sec)
        cs = sec
        if lf and cf then
            if sec == "Local" then
                lf.Visible = true
                cf.Visible = false
            else
                lf.Visible = false
                cf.Visible = true
            end
        end
    end
    
    local function svAE()
        if not isfolder("FrostWare") then makefolder("FrostWare") end
        writefile(aef, hs:JSONEncode(aes))
    end
    
    local function ldAE()
        if not isfolder("FrostWare") then makefolder(sd) end
        if isfile(aef) then
            local ok, dt = pcall(function() return hs:JSONDecode(readfile(aef)) end)
            if ok and dt then aes = dt end
        end
    end
    
    local function tgAE(nm)
        if aes[nm] then
            aes[nm] = nil
        else
            aes[nm] = true
        end
        svAE()
        upL()
    end
    
    local function exAS()
        for nm, _ in pairs(aes) do
            if ls[nm] then
                spawn(function()
                    local ok, res = pcall(function() return loadstring(ls[nm]) end)
                    if ok and res then pcall(res) end
                end)
            end
        end
    end
    
    local function svS(nm, cont)
        if not isfolder(sd) then makefolder(sd) end
        ls[nm] = cont
        writefile(sd .. nm .. ".lua", cont)
        local dt = {}
        for n, c in pairs(ls) do dt[n] = c end
        writefile(sd .. "scripts.json", hs:JSONEncode(dt))
        upL()
    end
    
    local function ldS()
        if not isfolder(sd) then makefolder(sd) end
        for nm, cont in pairs(ds) do ls[nm] = cont end
        if isfile(sd .. "scripts.json") then
            local ok, dt = pcall(function() return hs:JSONDecode(readfile(sd .. "scripts.json")) end)
            if ok and dt then
                for nm, cont in pairs(dt) do ls[nm] = cont end
            end
        end
        upL()
    end
    
    function upL()
        if ssr then
            for _, ch in pairs(ssr:GetChildren()) do
                if ch:IsA("Frame") then ch:Destroy() end
            end
            
            local scs = {}
            for nm, cont in pairs(ls) do
                table.insert(scs, {name = nm, content = cont})
            end
            
            for i, sc in pairs(scs) do
                local yp = (i - 1) * 65 + 10
                
                local scd = FW.cF(ssr, {
                    BackgroundColor3 = Color3.fromRGB(25, 30, 40),
                    Size = UDim2.new(1, -20, 0, 55),
                    Position = UDim2.new(0, 10, 0, yp),
                    Name = "ScriptCard_" .. sc.name
                })
                FW.cC(scd, 0.15)
                
                cST(scd, {
                    Text = sc.name,
                    TextSize = 16,
                    Size = UDim2.new(0.4, 0, 0.6, 0),
                    Position = UDim2.new(0, 15, 0, 5),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Name = "ScriptTitle"
                })
                
                if ds[sc.name] then
                    cVB(scd, UDim2.new(0, 13, 0, 28))
                end
                
                local aeb, aeo = cSB(scd, {
                    BackgroundColor3 = aes[sc.name] and Color3.fromRGB(50, 170, 90) or Color3.fromRGB(65, 75, 90),
                    Size = UDim2.new(0, 80, 0, 25),
                    Position = UDim2.new(0.45, 0, 0, 15),
                    Text = aes[sc.name] and "AUTO: ON" or "AUTO: OFF",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 10,
                    Name = "AutoExecBtn"
                })
                
                local exb, exo = cSB(scd, {
                    BackgroundColor3 = Color3.fromRGB(50, 170, 90),
                    Size = UDim2.new(0, 80, 0, 25),
                    Position = UDim2.new(0.65, 0, 0, 15),
                    Text = "EXECUTE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Name = "ExecuteBtn"
                })
                
                local mrb, mro = cSB(scd, {
                    BackgroundColor3 = Color3.fromRGB(50, 130, 210),
                    Size = UDim2.new(0, 60, 0, 25),
                    Position = UDim2.new(0.85, 0, 0, 15),
                    Text = "MORE",
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 11,
                    Name = "MoreBtn"
                })
                
                exb.MouseEnter:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(60, 180, 100) end)
                exb.MouseLeave:Connect(function() exb.BackgroundColor3 = Color3.fromRGB(50, 170, 90) end)
                mrb.MouseEnter:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
                mrb.MouseLeave:Connect(function() mrb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
                
                exb.MouseButton1Click:Connect(function()
                    FW.showAlert("Success", sc.name .. " executing...", 2)
                    local ok, res = pcall(function() return loadstring(sc.content) end)
                    if ok and res then
                        local eok, err = pcall(res)
                        if eok then
                            FW.showAlert("Success", sc.name .. " executed!", 2)
                        else
                            FW.showAlert("Error", "Execution failed!", 3)
                        end
                    else
                        FW.showAlert("Error", "Compilation failed!", 3)
                    end
                end)
                
                aeb.MouseButton1Click:Connect(function() tgAE(sc.name) end)
                mrb.MouseButton1Click:Connect(function() shSO(sc.name, sc.content) end)
            end
            
            ssr.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
        end
    end
    
    function shSO(nm, cont)
        if sf then sf:Destroy() end
        local ui = FW.getUI()
        local mui = ui["11"]
        
        sf = FW.cF(mui, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "ScriptOptionsOverlay",
            ZIndex = 10
        })
        
        local op, opo = cSC(sf, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(0, 400, 0, 350),
            Position = UDim2.new(0.5, -200, 0.5, -175),
            Name = "OptionsPanel"
        })
        
        local tb = FW.cF(op, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        
        cST(tb, {
            Text = "Select Your Option",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            Name = "Title"
        })
        
        local cb, cbo = cSB(tb, {
            BackgroundColor3 = Color3.fromRGB(190, 60, 60),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0, 10),
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Name = "CloseBtn"
        })
        
        cb.MouseButton1Click:Connect(function()
            if sf then sf:Destroy() sf = nil end
        end)
        
        cST(op, {
            Text = "Choose whether to execute,\nopen in a new tab, etc...",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(190, 200, 220),
            Size = UDim2.new(0.8, 0, 0, 40),
            Position = UDim2.new(0.1, 0, 0, 60),
            TextYAlignment = Enum.TextYAlignment.Top,
            Name = "Subtitle"
        })
        
        local btns = {
            {text = "EXECUTE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 120)},
            {text = "OPEN SCRIPT IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
            {text = "SAVE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 220)},
            {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 270)}
        }
        
        for i, bd in pairs(btns) do
            local btn, bo = cSB(op, {
                BackgroundColor3 = bd.color,
                Size = UDim2.new(0.8, 0, 0, 35),
                Position = bd.pos,
                Text = bd.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Name = "OptionBtn" .. i
            })
            
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
            btn.MouseLeave:Connect(function() btn.BackgroundColor3 = bd.color end)
            
            if i == 1 then
                btn.MouseButton1Click:Connect(function()
                    FW.showAlert("Success", nm .. " executing...", 2)
                    local ok, res = pcall(function() return loadstring(cont) end)
                    if ok and res then
                        local eok, err = pcall(res)
                        if eok then
                            FW.showAlert("Success", nm .. " executed!", 2)
                        else
                            FW.showAlert("Error", "Execution failed!", 3)
                        end
                    else
                        FW.showAlert("Error", "Compilation failed!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            elseif i == 2 then
                btn.MouseButton1Click:Connect(function()
                    local sr = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                    if sr then
                        sr.Text = cont
                        FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                        FW.showAlert("Success", "Script loaded to editor!", 2)
                        sf:Destroy()
                        sf = nil
                    end
                end)
            elseif i == 3 then
                btn.MouseButton1Click:Connect(function()
                    if not isfolder("FrostWare/Exports") then makefolder("FrostWare/Exports") end
                    writefile("FrostWare/Exports/" .. nm .. ".lua", cont)
                    FW.showAlert("Success", "Script saved to file!", 2)
                    sf:Destroy()
                    sf = nil
                end)
            elseif i == 4 then
                btn.MouseButton1Click:Connect(function()
                    if setclipboard then
                        setclipboard(cont)
                        FW.showAlert("Success", "Script copied to clipboard!", 2)
                    else
                        FW.showAlert("Error", "Clipboard not supported!", 3)
                    end
                    sf:Destroy()
                    sf = nil
                end)
            end
        end
    end
    
    local function cCC(p, dt, idx)
        local yp = (idx - 1) * 65 + 10
        
        local cc = FW.cF(p, {
            BackgroundColor3 = Color3.fromRGB(25, 30, 40),
            Size = UDim2.new(1, -20, 0, 55),
            Position = UDim2.new(0, 10, 0, yp),
            Name = "CloudCard"
        })
        FW.cC(cc, 0.15)
        
        cST(cc, {
            Text = dt.title or "Unknown Script",
            TextSize = 16,
            Size = UDim2.new(0.35, 0, 0.6, 0),
            Position = UDim2.new(0, 15, 0, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "ScriptTitle"
        })
        
        cVB(cc, UDim2.new(0, 13, 0, 28))
        
        cST(cc, {
            Text = (dt.views or "0") .. " Views",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(160, 170, 190),
            Size = UDim2.new(0.2, 0, 0.6, 0),
            Position = UDim2.new(0.4, 0, 0, 5),
            TextXAlignment = Enum.TextXAlignment.Left,
            Name = "ViewsLabel"
        })
        
        local sb, so = cSB(cc, {
            BackgroundColor3 = Color3.fromRGB(50, 130, 210),
            Size = UDim2.new(0, 100, 0, 35),
            Position = UDim2.new(1, -110, 0, 10),
            Text = "SELECT",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 12,
            Name = "SelectBtn"
        })
        
        sb.MouseEnter:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
        sb.MouseLeave:Connect(function() sb.BackgroundColor3 = Color3.fromRGB(50, 130, 210) end)
        sb.MouseButton1Click:Connect(function()
            ss = dt
            shCO(dt)
        end)
        
        return cc
    end
    
    function shCO(dt)
        if sf then sf:Destroy() end
        local ui = FW.getUI()
        local mui = ui["11"]
        
        sf = FW.cF(mui, {
            BackgroundColor3 = Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = 0.4,
            Size = UDim2.new(1, 0, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "CloudOptionsOverlay",
            ZIndex = 10
        })
        
        local op, opo = cSC(sf, {
            BackgroundColor3 = Color3.fromRGB(20, 25, 35),
            Size = UDim2.new(0, 400, 0, 350),
            Position = UDim2.new(0.5, -200, 0.5, -175),
            Name = "OptionsPanel"
        })
        
        local tb = FW.cF(op, {
            BackgroundColor3 = Color3.fromRGB(30, 35, 45),
            Size = UDim2.new(1, 0, 0, 50),
            Position = UDim2.new(0, 0, 0, 0),
            Name = "TitleBar"
        })
        
        cST(tb, {
            Text = "Select Your Option",
            TextSize = 18,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            Size = UDim2.new(0.8, 0, 1, 0),
            Position = UDim2.new(0.1, 0, 0, 0),
            Name = "Title"
        })
        
        local cb, cbo = cSB(tb, {
            BackgroundColor3 = Color3.fromRGB(190, 60, 60),
            Size = UDim2.new(0, 30, 0, 30),
            Position = UDim2.new(1, -40, 0, 10),
            Text = "×",
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 16,
            Name = "CloseBtn"
        })
        
        cb.MouseButton1Click:Connect(function()
            if sf then sf:Destroy() sf = nil end
        end)
        
        cST(op, {
            Text = "Choose whether to execute,\nopen in a new tab, etc...",
            TextSize = 12,
            TextColor3 = Color3.fromRGB(190, 200, 220),
            Size = UDim2.new(0.8, 0, 0, 40),
            Position = UDim2.new(0.1, 0, 0, 60),
            TextYAlignment = Enum.TextYAlignment.Top,
            Name = "Subtitle"
        })
        
        local btns = {
            {text = "EXECUTE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 120)},
            {text = "OPEN SCRIPT IN EDITOR", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 170)},
            {text = "SAVE SELECTED SCRIPT", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 220)},
            {text = "COPY TO CLIPBOARD", color = Color3.fromRGB(50, 130, 210), pos = UDim2.new(0.1, 0, 0, 270)}
        }
        
        for i, bd in pairs(btns) do
            local btn, bo = cSB(op, {
                BackgroundColor3 = bd.color,
                Size = UDim2.new(0.8, 0, 0, 35),
                Position = bd.pos,
                Text = bd.text,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Name = "CloudOptionBtn" .. i
            })
            
            btn.MouseEnter:Connect(function() btn.BackgroundColor3 = Color3.fromRGB(60, 140, 220) end)
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
                                local sd = hs:JSONDecode(res)
                                if sd.script then sc = sd.script end
                            end
                        end
                        if sc then
                            FW.showAlert("Success", "Executing script...", 2)
                            local ok, res = pcall(function() return loadstring(sc) end)
                            if ok and res then
                                local eok, err = pcall(res)
                                if eok then
                                    FW.showAlert("Success", "Script executed!", 2)
                                else
                                    FW.showAlert("Error", "Execution failed!", 3)
                                end
                            else
                                FW.showAlert("Error", "Compilation failed!", 3)
                            end
                        else
                            FW.showAlert("Error", "Failed to fetch script!", 3)
                        end
                        sf:Destroy()
                        sf = nil
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
                                local sd = hs:JSONDecode(res)
                                if sd.script then sc = sd.script end
                            end
                        end
                        if sc then
                            local sr = FW.getUI()["11"]:FindFirstChild("EditorPage"):FindFirstChild("EditorPage"):FindFirstChild("TxtBox"):FindFirstChild("EditorFrame"):FindFirstChild("Source")
                            if sr then
                                sr.Text = sc
                                FW.switchPage("Editor", FW.getUI()["6"]:FindFirstChild("Sidebar"))
                                FW.showAlert("Success", "Script loaded to editor!", 2)
                            end
                        else
                            FW.showAlert("Error", "Failed to load script!", 3)
                        end
                        sf:Destroy()
                        sf = nil
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
                                local sd = hs:JSONDecode(res)
                                if sd.script then sc = sd.script end
                            end
                        end
                        if sc then
                            svS(dt.title or "CloudScript_" .. tick(), sc)
                            FW.showAlert("Success", "Script saved!", 2)
                        else
                            FW.showAlert("Error", "Failed to save!", 3)
                        end
                        sf:Destroy()
                        sf = nil
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
                                local sd = hs:JSONDecode(res)
                                if sd.script then sc = sd.script end
                            end
                        end
                        if sc and setclipboard then
                            setclipboard(sc)
                            FW.showAlert("Success", "Script copied!", 2)
                        else
                            FW.showAlert("Error", "Failed to copy!", 3)
                        end
                        sf:Destroy()
                        sf = nil
                    end)
                end)
            end
        end
    end
    
    local function srS(qry, mr)
        mr = mr or 20
        local ok, res = pcall(function()
            local url = "https://scriptblox.com/api/script/search?q=" .. hs:UrlEncode(qry) .. "&max=" .. mr
            return game:HttpGet(url)
        end)
        if ok then
            local dt = hs:JSONDecode(res)
            if dt.result and dt.result.scripts then
                return dt.result.scripts
            end
        end
        return {}
    end
    
    local function dsCS(scs, sf)
        for _, ch in pairs(sf:GetChildren()) do
            if ch.Name == "CloudCard" then ch:Destroy() end
        end
        for i, sc in pairs(scs) do
            cCC(sf, sc, i)
        end
        sf.CanvasSize = UDim2.new(0, 0, 0, #scs * 65 + 20)
    end
    
    local sp = FW.cI(FW.getUI()["11"], {
        ImageTransparency = 1,
        ImageColor3 = Color3.fromRGB(15, 18, 25),
        Image = "rbxassetid://18665679839",
        Size = UDim2.new(1.001, 0, 1, 0),
        Visible = false,
        ClipsDescendants = true,
        BackgroundTransparency = 1,
        Name = "ScriptsPage",
        Position = UDim2.new(-0.001, 0, 0, 0)
    })
    
    local tb, tbo = cSC(sp, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 60),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "TopBar"
    })
    
    local sb, sbo = cSI(tb, {
        Size = UDim2.new(0.5, -10, 0, 35),
        Position = UDim2.new(0, 15, 0, 12),
        PlaceholderText = "Search for scripts...",
        TextSize = 14,
        Name = "SearchBox"
    })
    
    local lt, lto = cSB(tb, {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0.55, 5, 0, 12),
        Text = "LOCAL",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 14,
        Name = "LocalTab"
    })
    
    local ct, cto = cSB(tb, {
        BackgroundColor3 = Color3.fromRGB(65, 75, 90),
        Size = UDim2.new(0.2, -5, 0, 35),
        Position = UDim2.new(0.78, 5, 0, 12),
        Text = "CLOUD",
        TextColor3 = Color3.fromRGB(190, 200, 220),
        TextSize = 14,
        Name = "CloudTab"
    })
    
    lf = FW.cF(sp, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        Name = "LocalFrame",
        Visible = true
    })
    
    cf = FW.cF(sp, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, -80),
        Position = UDim2.new(0, 0, 0, 80),
        Name = "CloudFrame",
        Visible = false
    })
    
    local ap, apo = cSC(lf, {
        BackgroundColor3 = Color3.fromRGB(25, 30, 40),
        Size = UDim2.new(1, -20, 0, 80),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "AddPanel"
    })
    
    local ni, nio = cSI(ap, {
        Size = UDim2.new(0.25, -5, 0, 30),
        Position = UDim2.new(0, 10, 0, 10),
        PlaceholderText = "Script Name",
        TextSize = 12,
        Name = "NameInput"
    })
    
    local ci, cio = cSI(ap, {
        Size = UDim2.new(0.45, -5, 0, 30),
        Position = UDim2.new(0.27, 5, 0, 10),
        PlaceholderText = "Paste script content here",
        TextSize = 12,
        Name = "ContentInput"
    })
    
    local svb, svbo = cSB(ap, {
        BackgroundColor3 = Color3.fromRGB(50, 170, 90),
        Size = UDim2.new(0.12, -5, 0, 30),
        Position = UDim2.new(0.74, 5, 0, 10),
        Text = "SAVE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Name = "SaveBtn"
    })
    
    local pb, pbo = cSB(ap, {
        BackgroundColor3 = Color3.fromRGB(50, 130, 210),
        Size = UDim2.new(0.12, -5, 0, 30),
        Position = UDim2.new(0.88, 5, 0, 10),
        Text = "PASTE",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Name = "PasteBtn"
    })
    
    local sc, sco = cSC(lf, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(1, -20, 1, -110),
        Position = UDim2.new(0, 10, 0, 100),
        Name = "ScriptsContainer"
    })
    
    local ss = FW.cSF(sc, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        ScrollBarThickness = 8,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Name = "ScriptsScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210)
    })
    ssr = ss
    
    local cc, cco = cSC(cf, {
        BackgroundColor3 = Color3.fromRGB(20, 25, 35),
        Size = UDim2.new(1, -20, 1, -20),
        Position = UDim2.new(0, 10, 0, 10),
        Name = "CloudContainer"
    })
    
    local cs = FW.cSF(cc, {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -10),
        Position = UDim2.new(0, 5, 0, 5),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 8,
        Name = "CloudScroll",
        ScrollBarImageColor3 = Color3.fromRGB(50, 130, 210)
    })
    
    svb.MouseButton1Click:Connect(function()
        local nm = ni.Text
        local cont = ci.Text
        if nm and nm ~= "" and cont and cont ~= "" then
            svS(nm, cont)
            ni.Text = ""
            ci.Text = ""
            FW.showAlert("Success", "Script saved: " .. nm, 2)
        else
            FW.showAlert("Error", "Please enter name and content!", 2)
        end
    end)
    
    pb.MouseButton1Click:Connect(function()
        local cb = getclipboard and getclipboard() or ""
        if cb ~= "" then
            ci.Text = cb
            FW.showAlert("Success", "Content pasted!", 2)
        else
            FW.showAlert("Error", "Clipboard is empty!", 2)
        end
    end)
    
    sb.FocusLost:Connect(function(ep)
        if ep and cs == "Cloud" then
            local qry = sb.Text
            if qry and qry ~= "" then
                FW.showAlert("Info", "Searching scripts...", 1)
                spawn(function()
                    local scs = srS(qry, 50)
                    if #scs > 0 then
                        csc = scs
                        dsCS(scs, cs)
                        FW.showAlert("Success", "Found " .. #scs .. " scripts!", 2)
                    else
                        FW.showAlert("Error", "No scripts found!", 2)
                    end
                end)
            end
        end
    end)
    
    lt.MouseButton1Click:Connect(function()
        swS("Local")
        lt.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        lt.TextColor3 = Color3.fromRGB(255, 255, 255)
        ct.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
        ct.TextColor3 = Color3.fromRGB(190, 200, 220)
    end)
    
    ct.MouseButton1Click:Connect(function()
        swS("Cloud")
        ct.BackgroundColor3 = Color3.fromRGB(50, 130, 210)
        ct.TextColor3 = Color3.fromRGB(255, 255, 255)
        lt.BackgroundColor3 = Color3.fromRGB(65, 75, 90)
        lt.TextColor3 = Color3.fromRGB(190, 200, 220)
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
        
        local sb, sc = cSBtn("Scripts", "Scripts", sia or "rbxassetid://7733779610", UDim2.new(0.075, 0, 0.44, 0), false)
        sc.MouseButton1Click:Connect(function()
            FW.switchPage("Scripts", FW.getUI()["6"]:FindFirstChild("Sidebar"))
        end)
    end
    
    ldAE()
    ldS()
    exAS()
    
    spawn(function()
        FW.showAlert("Info", "Loading popular scripts...", 1)
        local ps = srS("popular", 30)
        if #ps > 0 then
            csc = ps
            dsCS(ps, cs)
        end
    end)
end)
