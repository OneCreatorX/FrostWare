setreadonly(dtc,false)
dtc.securestring=function()end
dtc._securestring=function()end
setreadonly(dtc,true)
dtc.pushautoexec()
local w={}
local e={}
local s={"RunService","Players","TweenService","MarketplaceService","UserInputService","LogService","CoreGui","HttpService"}
local t={"Size","Position","BackgroundColor3","Text","TextSize","TextColor3","BackgroundTransparency","Visible","Name","Image","ImageColor3","ZIndex","TextScaled","TextXAlignment","TextYAlignment","TextWrapped","FontFace","ScaleType","CanvasSize","ScrollBarThickness","ClipsDescendants","MultiLine","ClearTextOnFocus","CursorPosition","RichText","TextTransparency","PlaceholderColor3","Active","Draggable","Rotation","ElasticBehavior","TopImage","MidImage","BottomImage","VerticalScrollBarInset","HorizontalScrollBarInset","ScrollBarImageTransparency","ScrollBarImageColor3","FillDirection","SortOrder","Padding"}
local u={"ScreenGui","Frame","TextLabel","TextButton","TextBox","ImageLabel","ImageButton","ScrollingFrame","UIGradient","UICorner","UIStroke","UITextSizeConstraint","UIAspectRatioConstraint","Folder","UIListLayout"}
local c={"rbxassetid://12187365364","rbxassetid://11702779409","rbxassetid://133620562515152","rbxassetid://107516337694688","rbxassetid://82022759470861","rbxassetid://88951128464748","rbxassetid://102023075611323","rbxassetid://76734110237026","rbxassetid://132133828845126","rbxassetid://102761807757832","rbxassetid://133862668499122","rbxassetid://94595204123047","rbxassetid://107390243416427","rbxassetid://128679881757557","rbxassetid://124705542662472","rbxassetid://89434276213036","rbxassetid://73909411554012","rbxassetid://133018045821797","rbxassetid://136761835814725","rbxassetid://148970562","rbxassetid://123590482033481","rbxassetid://110667923648139"}
local m={s=t[1],p=t[2],c=t[3],t=t[4],ts=t[5],tc=t[6],bt=t[7],v=t[8],n=t[9],i=t[10],ic=t[11],z=t[12],sc=t[13],xa=t[14],ya=t[15],tw=t[16],ff=t[17],st=t[18],cs=t[19],sb=t[20],cl=t[21],ml=t[22],cf=t[23],cp=t[24],rt=t[25],tt=t[26],pc=t[27],ac=t[28],dr=t[29],ro=t[30],eb=t[31],ti=t[32],mi=t[33],bi=t[34],vs=t[35],hs=t[36],sit=t[37],sic=t[38],fd=t[39],so=t[40],pd=t[41]}
e.f=function(f)return f end
e.s=function(n)return cloneref(game:GetService(n))end
e.h=gethui or function()return game:GetService(s[7])end
e.gc=getclipboard or function()return""end
e.sc=setclipboard or function()end
e.iff=isfile or function()return false end
e.rf=readfile or function()return""end
e.wf=writefile or function()end
e.mf=makefolder or function()end
e.isf=isfolder or function()return false end
local d,r,lp,ws,tw,ms,cs,ui,ls=false,e.s(s[1]),e.s(s[2]).LocalPlayer or e.s(s[2]).PlayerAdded:Wait(),workspace,game:GetService("TweenService"),e.s(s[4]),e.h(),e.s(s[5]),e.s(s[6])
local g,tb,ct,tc,td,sr,lr,co,csr,ce={},{},1,1,"FrostWare/Tabs/",nil,nil,{},nil,true
local op,ow,oe,ss,tbr,tsr,pbr,ee,ha,sbr,pgr,obr=nil,nil,nil,tick(),nil,nil,nil,false,false,nil,nil,nil
local cpn,cfp,ctp,ia,ctw="Editor",nil,nil,false,{}
local pcl1,pgl1,fpl1,mml1,tml1=nil,nil,nil,nil,nil
local stt1=tick()
local fpc1=0
local lfu1=tick()
local esp1=false
local xry1=false
local ctp1=false
local fbr1=false
local aaf1=true
local frz1=false
local ncp1=false
local cam1=false
local gra1=false
local ani1=1
local fov1=70
local anh1=false
local anhc=nil
local t=0
local fc1=nil
local sc1=nil
local ec1={}
local ot1={}
local cc1=nil
local ac1=nil
local gc1=nil
local function gsafe(name,timeout)
    local s=nil
    local success, result = pcall(function()
        s = game:GetService(name)
    end)
    if success and s then return s end
    local t0=tick()
    repeat task.wait() until tick()-t0>timeout or game:FindService(name)
    success, result = pcall(function()
        s = game:FindService(name)
    end)
    return success and s or nil
end
local function isafe(parent,name,timeout)
    if not parent then return nil end
    local inst=parent:FindFirstChild(name)
    if inst then return cloneref(inst) end
    local t0=tick()
    repeat task.wait() until tick()-t0>(timeout or 3) or parent:FindFirstChild(name)
    local found=parent:FindFirstChild(name)
    return found and cloneref(found) or nil
end
local function wsafe(parent,name,timeout)
    if not parent then return nil end
    local success,result=pcall(function()
        return parent:WaitForChild(name,timeout or 3)
    end)
    return success and cloneref(result) or nil
end
local ap=function(o,pr)if pr then for k,v in pairs(pr)do o[m[k]or k]=v end end return o end
local ni=function(t,p,pr)return ap(Instance.new(t,p),pr)end
local nf=function(p,pr)return ni(u[2],p,pr)end
local nt=function(p,pr)return ni(u[3],p,pr)end
local nb=function(p,pr)return ni(u[4],p,pr)end
local ntb=function(p,pr)return ni(u[5],p,pr)end
local nim=function(p,pr)return ni(u[6],p,pr)end
local nib=function(p,pr)return ni(u[7],p,pr)end
local nsf=function(p,pr)return ni(u[8],p,pr)end
local ng=function(p,c1,c2,r)return ap(ni(u[9],p),{ro=r or 90,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}})end
local nc=function(p,r)return ap(ni(u[10],p),{CornerRadius=UDim.new(r or 0,0)})end
local ns=function(p,th,col)return ap(ni(u[11],p),{Thickness=th,Color=col,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end
local ntc=function(p,max)return ap(ni(u[12],p),{MaxTextSize=max})end
local nar=function(p,ratio)return ap(ni(u[13],p),{AspectRatio=ratio})end
local gvt=e.f(function()return 999,59,59 end)
local function ci1(t,p)
    local inst=Instance.new(t)
    if p then inst.Parent=p end
    return inst
end
local function sp1(inst,props)
    for k,v in pairs(props) do
        if k=="c" then inst.BackgroundColor3=v
        elseif k=="s" then inst.Size=v
        elseif k=="p" then inst.Position=v
        elseif k=="n" then inst.Name=v
        elseif k=="t" then inst.Text=v
        elseif k=="ts" then inst.TextSize=v
        elseif k=="tc" then inst.TextColor3=v
        elseif k=="bt" then inst.BackgroundTransparency=v
        elseif k=="sc" then inst.TextScaled=v
        elseif k=="xa" then inst.TextXAlignment=v
        elseif k=="ya" then inst.TextYAlignment=v
        elseif k=="fnt" then inst.Font=v
        elseif k=="ffc" then inst.FontFace=v
        elseif k=="bs" then inst.BorderSizePixel=v
        elseif k=="cs" then inst.CanvasSize=v
        elseif k=="sbt" then inst.ScrollBarThickness=v
        elseif k=="sbc" then inst.ScrollBarImageColor3=v
        elseif k=="vis" then inst.Visible=v
        elseif k=="anc" then inst.Anchored=v
        elseif k=="cc" then inst.CanCollide=v
        elseif k=="tr" then inst.Transparency=v
        elseif k=="mat" then inst.Material=v
        elseif k=="ref" then inst.Reflectance=v
        elseif k=="fc" then inst.FillColor=v
        elseif k=="oc" then inst.OutlineColor=v
        elseif k=="ft" then inst.FillTransparency=v
        elseif k=="ot" then inst.OutlineTransparency=v
        elseif k=="dm" then inst.DepthMode=v
        elseif k=="so" then inst.StudsOffset=v
        elseif k=="ao" then inst.AlwaysOnTop=v
        elseif k=="tst" then inst.TextStrokeTransparency=v
        elseif k=="tsc" then inst.TextStrokeColor3=v
        elseif k=="cr" then inst.CornerRadius=v
        elseif k=="ss" then inst.SliceScale=v
        elseif k=="st" then inst.SliceCenter=v
        elseif k=="img" then inst.Image=v
        elseif k=="it" then inst.ImageTransparency=v
        elseif k=="ic" then inst.ImageColor3=v
        elseif k=="col" then inst.Color=v
        elseif k=="th" then inst.Thickness=v
        end
    end
    return inst
end
local function cf1(parent,props)
    return sp1(ci1("Frame",parent),props)
end
local function ct1(parent,props)
    return sp1(ci1("TextLabel",parent),props)
end
local function cb1(parent,props)
    return sp1(ci1("TextButton",parent),props)
end
local function cs1(parent,props)
    return sp1(ci1("ScrollingFrame",parent),props)
end
local function cc1_ui(parent,props)
    return sp1(ci1("UICorner",parent),props)
end
local function cst1(parent,props)
    return sp1(ci1("UIStroke",parent),props)
end
local function ch1(parent,props)
    return sp1(ci1("Highlight",parent),props)
end
local function cbg1(parent,props)
    return sp1(ci1("BillboardGui",parent),props)
end
local function us1()
    return gsafe("UserInputService",3)
end
local function gs1()
    local success, uset = pcall(function()
        return game:GetService("UserGameSettings")
    end)
    return success and uset or nil
end
local function upd1()
    spawn(function()
        local rs=gsafe("RunService",3)
        if rs then
            rs.Heartbeat:Connect(function()
                fpc1=fpc1+1
            end)
        end
        while task.wait(1) do
            if not lp or not lp.Character then continue end
            if pcl1 and pcl1.Parent then
                local ps=gsafe("Players",3)
                if ps then
                    local cp=#ps:GetPlayers()
                    local mp=ps.MaxPlayers
                    pcl1.Text="👥 "..cp.."/"..mp
                end
            end
            if pgl1 and pgl1.Parent then
                local png=lp:GetNetworkPing()*1000
                pgl1.Text="📡 "..math.floor(png).."ms"
            end
            if fpl1 and fpl1.Parent then
                local ct=tick()
                local fps=math.floor(fpc1/(ct-lfu1))
                fpl1.Text="🎯 "..fps.." FPS"
                fpc1=0
                lfu1=ct
            end
            if mml1 and mml1.Parent then
                local stats=gsafe("Stats",3)
                if stats then
                    local mem=stats:GetTotalMemoryUsageMb()
                    mml1.Text="💾 "..math.floor(mem).."MB"
                end
            end
            if tml1 and tml1.Parent then
                local el=tick()-stt1
                local m=math.floor(el/60)
                local s=math.floor(el%60)
                tml1.Text="⏱️ "..m..":"..string.format("%02d",s)
            end
        end
    end)
end
local function cep1(p)
    if p==lp or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then return end
    local h=ch1(p.Character,{fc=Color3.new(1,0.2,0.2),oc=Color3.new(1,1,1),ft=0.6,ot=0,dm=Enum.HighlightDepthMode.AlwaysOnTop})
    local bg=cbg1(p.Character:FindFirstChild("Head"),{s=UDim2.new(0,200,0,50),so=Vector3.new(0,2,0),ao=true})
    local nl=ct1(bg,{s=UDim2.new(1,0,0.5,0),bt=1,t=p.Name,tc=Color3.new(1,1,1),sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal),tst=0,tsc=Color3.new(0,0,0)})
    local dl=ct1(bg,{s=UDim2.new(1,0,0.5,0),p=UDim2.new(0,0,0.5,0),bt=1,tc=Color3.new(1,1,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),tst=0,tsc=Color3.new(0,0,0)})
    local rs=gsafe("RunService",3)
    if rs then
        local con=rs.Heartbeat:Connect(function()
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                local dist=(p.Character.HumanoidRootPart.Position-lp.Character.HumanoidRootPart.Position).Magnitude
                dl.Text=math.floor(dist).."m"
                local hue=math.min(dist/100,1)
                h.FillColor=Color3.fromHSV(0.3-hue*0.3,1,1)
            end
        end)
        ec1[p]={h,bg,con}
    end
end
local function tep1()
    esp1=not esp1
    if esp1 then
        local ps=gsafe("Players",3)
        if ps then
            for _,p in pairs(ps:GetPlayers()) do
                cep1(p)
            end
            ps.PlayerAdded:Connect(function(p)
                if esp1 then
                    p.CharacterAdded:Connect(function()
                        task.wait(1)
                        cep1(p)
                    end)
                end
            end)
        end
    else
        for p,objs in pairs(ec1) do
            if objs[1] then objs[1]:Destroy() end
            if objs[2] then objs[2]:Destroy() end
            if objs[3] then objs[3]:Disconnect() end
        end
        ec1={}
    end
    fw.sa("Success","Advanced ESP "..(esp1 and "ON" or "OFF").."!",2)
end
local function txr1()
    xry1=not xry1
    if xry1 then
        for _,obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local ps=gsafe("Players",3)
                if not ps or not ps:GetPlayerFromCharacter(obj.Parent) then
                    ot1[obj]={obj.Transparency,obj.CanCollide,obj.Material}
                    obj.Transparency=0.8
                    obj.CanCollide=true
                    obj.Material=Enum.Material.ForceField
                end
            end
        end
    else
        for obj,props in pairs(ot1) do
            if obj and obj.Parent then
                obj.Transparency=props[1]
                obj.CanCollide=props[2]
                obj.Material=props[3]
            end
        end
        ot1={}
    end
    fw.sa("Success","Advanced X-Ray "..(xry1 and "ON" or "OFF").."!",2)
end
local function tctp1()
    ctp1=not ctp1
    if ctp1 then
        local uis=us1()
        if uis then
            cc1=uis.InputBegan:Connect(function(input,gp)
                if not gp and (input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1) then
                    local mouse=lp:GetMouse()
                    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
                        local cf=CFrame.new(mouse.Hit.Position+Vector3.new(0,5,0))
                        lp.Character.HumanoidRootPart.CFrame=cf
                        local beam=ci1("Beam",workspace)
                        local a0=ci1("Attachment",lp.Character.HumanoidRootPart)
                        local a1=ci1("Attachment",workspace.Terrain)
                        a1.WorldPosition=mouse.Hit.Position
                        beam.Attachment0=a0
                        beam.Attachment1=a1
                        beam.Color=ColorSequence.new(Color3.new(0,1,1))
                        beam.Width0=1
                        beam.Width1=1
                        spawn(function()
                            task.wait(0.5)
                            beam:Destroy()
                            a0:Destroy()
                            a1:Destroy()
                        end)
                    end
                end
            end)
        end
    else
        if cc1 then
            cc1:Disconnect()
            cc1=nil
        end
    end
    fw.sa("Success","Touch TP "..(ctp1 and "ON" or "OFF").."!",2)
end
local function tfbr1()
    fbr1=not fbr1
    local lt=gsafe("Lighting",3)
    if lt then
        if fbr1 then
            lt.Brightness=3
            lt.ClockTime=12
            lt.FogEnd=1e10
            lt.GlobalShadows=false
            lt.OutdoorAmbient=Color3.new(1,1,1)
            lt.Ambient=Color3.new(1,1,1)
            lt.ColorShift_Bottom=Color3.new(1,1,1)
            lt.ColorShift_Top=Color3.new(1,1,1)
            for _,obj in pairs(lt:GetChildren()) do
                if obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("ColorCorrectionEffect") or obj:IsA("SunRaysEffect") then
                    obj.Enabled=false
                end
            end
            if workspace.CurrentCamera and workspace.CurrentCamera:FindFirstChild("ColorCorrection") then
                workspace.CurrentCamera.ColorCorrection.Brightness=0.3
                workspace.CurrentCamera.ColorCorrection.Contrast=0.2
                workspace.CurrentCamera.ColorCorrection.Saturation=0
            end
        else
            lt.Brightness=1
            lt.ClockTime=14
            lt.FogEnd=100000
            lt.GlobalShadows=true
            lt.OutdoorAmbient=Color3.fromRGB(70,70,70)
            lt.Ambient=Color3.fromRGB(128,128,128)
            lt.ColorShift_Bottom=Color3.new(0,0,0)
            lt.ColorShift_Top=Color3.new(0,0,0)
            if workspace.CurrentCamera and workspace.CurrentCamera:FindFirstChild("ColorCorrection") then
                workspace.CurrentCamera.ColorCorrection.Brightness=0
                workspace.CurrentCamera.ColorCorrection.Contrast=0
                workspace.CurrentCamera.ColorCorrection.Saturation=0
            end
        end
    end
    fw.sa("Success","Advanced Fullbright "..(fbr1 and "ON" or "OFF").."!",2)
end
local function tfrz1()
    frz1=not frz1
    if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.Anchored=frz1
        fw.sa("Success","Character "..(frz1 and "FROZEN" or "UNFROZEN").."!",2)
    end
end
local function tncp1()
    ncp1=not ncp1
    fw.sa("Success","NoClip "..(ncp1 and "ON" or "OFF").."!",2)
end
local function tcam1()
    cam1=not cam1
    local cam=workspace.CurrentCamera
    if cam1 then
        cam.CameraSubject=nil
        cam.CameraType=Enum.CameraType.Scriptable
        local uis=us1()
        if uis then
            ac1=uis.InputBegan:Connect(function(input)
                if input.KeyCode==Enum.KeyCode.W or input.KeyCode==Enum.KeyCode.ButtonY then
                    spawn(function()
                        while (uis:IsKeyDown(Enum.KeyCode.W) or uis:IsKeyDown(Enum.KeyCode.ButtonY)) and cam1 do
                            cam.CFrame=cam.CFrame*CFrame.new(0,0,-2)
                            task.wait()
                        end
                    end)
                elseif input.KeyCode==Enum.KeyCode.S or input.KeyCode==Enum.KeyCode.ButtonA then
                    spawn(function()
                        while (uis:IsKeyDown(Enum.KeyCode.S) or uis:IsKeyDown(Enum.KeyCode.ButtonA)) and cam1 do
                            cam.CFrame=cam.CFrame*CFrame.new(0,0,2)
                            task.wait()
                        end
                    end)
                elseif input.KeyCode==Enum.KeyCode.A or input.KeyCode==Enum.KeyCode.ButtonX then
                    spawn(function()
                        while (uis:IsKeyDown(Enum.KeyCode.A) or uis:IsKeyDown(Enum.KeyCode.ButtonX)) and cam1 do
                            cam.CFrame=cam.CFrame*CFrame.new(-2,0,0)
                            task.wait()
                        end
                    end)
                elseif input.KeyCode==Enum.KeyCode.D or input.KeyCode==Enum.KeyCode.ButtonB then
                    spawn(function()
                        while (uis:IsKeyDown(Enum.KeyCode.D) or uis:IsKeyDown(Enum.KeyCode.ButtonB)) and cam1 do
                            cam.CFrame=cam.CFrame*CFrame.new(2,0,0)
                            task.wait()
                        end
                    end)
                end
            end)
        end
    else
        if ac1 then ac1:Disconnect() ac1=nil end
        cam.CameraSubject=lp.Character and lp.Character:FindFirstChild("Humanoid")
        cam.CameraType=Enum.CameraType.Custom
    end
    fw.sa("Success","Free Camera "..(cam1 and "ON" or "OFF").."!",2)
end
local function tgra1()
    gra1=not gra1
    if gra1 then
        workspace.Gravity=0
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local bv=ci1("BodyVelocity",lp.Character.HumanoidRootPart)
            bv.MaxForce=Vector3.new(4000,4000,4000)
            bv.Velocity=Vector3.new(0,0,0)
            local uis=us1()
            if uis then
                gc1=uis.InputBegan:Connect(function(input)
                    if input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonR1 then
                        bv.Velocity=Vector3.new(0,50,0)
                    elseif input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.ButtonL1 then
                        bv.Velocity=Vector3.new(0,-50,0)
                    end
                end)
                uis.InputEnded:Connect(function(input)
                    if input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonR1 or input.KeyCode==Enum.KeyCode.LeftShift or input.KeyCode==Enum.KeyCode.ButtonL1 then
                        if bv and bv.Parent then
                            bv.Velocity=Vector3.new(0,0,0)
                        end
                    end
                end)
            end
        end
    else
        workspace.Gravity=196.2
        if gc1 then gc1:Disconnect() gc1=nil end
        if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            local bv=lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity")
            if bv then bv:Destroy() end
        end
    end
    fw.sa("Success","Zero Gravity "..(gra1 and "ON" or "OFF").."!",2)
end
local function sani1(val)
    ani1=val
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        for _,track in pairs(lp.Character.Humanoid:GetPlayingAnimationTracks()) do
            track:AdjustSpeed(ani1)
        end
    end
end
local function sfov1(val)
    fov1=val
    workspace.CurrentCamera.FieldOfView=fov1
end
local function anhl(dt)
t=t+dt
local c=lp.Character
if not c or not c:FindFirstChild("HumanoidRootPart")then return end
local ata={}
for _,ac in ipairs(c:GetChildren())do
if ac:IsA("Accessory")and ac:FindFirstChild("Handle")then
local h=ac.Handle
if not h:FindFirstChild("BodyPosition")then
for _,d in ipairs(h:GetDescendants())do
if d:IsA("Weld")or d:IsA("Motor6D")or d:IsA("AlignPosition")or d:IsA("AlignOrientation")then
d:Destroy()
end
end
pcall(function()sethiddenproperty(ac,"BackendAccoutrementState",0)end)
h.Anchored,h.Massless,h.CanCollide=false,true,false
ci1("BodyPosition",h).MaxForce=Vector3.new(9e9,9e9,9e9)
ci1("BodyGyro",h).MaxTorque=Vector3.new(9e9,9e9,9e9)
end
table.insert(ata,h)
end
end
local rp=c:FindFirstChild("HumanoidRootPart")
if rp then
for i,h in ipairs(ata)do
local A=(math.pi*2/#ata)*i+t
local p=rp.Position+Vector3.new(math.cos(A)*4,2+math.sin(t*3)*.5,math.sin(A)*4)
h.BodyPosition.Position=p
h.BodyGyro.CFrame=CFrame.lookAt(p,rp.Position)
end
end
end
local function rav()
local c=lp.Character
if c then
for _,ac in ipairs(c:GetChildren())do
if ac:IsA("Accessory")and ac:FindFirstChild("Handle")then
local h=ac.Handle
local bp,bg=h:FindFirstChild("BodyPosition"),h:FindFirstChild("BodyGyro")
if bp then bp:Destroy()end
if bg then bg:Destroy()end
pcall(function()sethiddenproperty(ac,"BackendAccoutrementState",1)end)
h.Anchored,h.Massless,h.CanCollide=false,false,true
end
end
end
end
local function sahar()
if anhc then
anhc:Disconnect()
anhc=nil
end
rav()
end
local function tanh1()
anh1=not anh1
if anh1 then
local function oca(c)
sahar()
if sc1 then sc1:Disconnect()end
if c:FindFirstChild("Humanoid")then
sc1=c.Humanoid.Died:Connect(function()
if anh1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")then
if not anhc then
t=0
anhc=gsafe("RunService",3).Heartbeat:Connect(anhl)
end
end
end)
end
end
if fc1 then fc1:Disconnect()end
fc1=lp.CharacterAdded:Connect(oca)
if lp.Character then
oca(lp.Character)
if lp.Character:FindFirstChild("Humanoid")and lp.Character.Humanoid.Health<=0 then
if not anhc then
t=0
anhc=gsafe("RunService",3).Heartbeat:Connect(anhl)
end
end
end
else
if fc1 then fc1:Disconnect()fc1=nil end
if sc1 then sc1:Disconnect()sc1=nil end
sahar()
end
fw.sa("Success","Animation Head "..(anh1 and"ON"or"OFF").."!",2)
end
local function hui1()
    local ui=fw.gu()
    if ui and ui["3"] then
        ui["3"].Visible=false
        spawn(function()
            task.wait(5)
            ui["3"].Visible=true
            fw.sa("Success","UI restored!",2)
        end)
    end
end
local function eal1()
    local uset=gs1()
    local lt=gsafe("Lighting",3)
    local ws=workspace
    if uset then
        pcall(function()
            uset.MasterVolume=0
            uset.GraphicsQualityLevel=1
            uset.SavedQualityLevel=1
        end)
    end
    if lt then
        pcall(function()
            lt.GlobalShadows=false
            lt.FogEnd=9e9
            lt.Brightness=0
            lt.ColorShift_Bottom=Color3.fromRGB(11,11,11)
            lt.ColorShift_Top=Color3.fromRGB(240,240,240)
            lt.OutdoorAmbient=Color3.fromRGB(34,34,34)
            lt.Ambient=Color3.fromRGB(34,34,34)
        end)
    end
    for _,obj in pairs(ws:GetDescendants()) do
        pcall(function()
            if obj:IsA("Part") or obj:IsA("Union") or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                obj.Material=Enum.Material.Plastic
                obj.Reflectance=0
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency=1
            elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                obj.Enabled=false
            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
                obj.Enabled=false
            end
        end)
    end
    fw.sa("Success","Extreme anti-lag applied!",2)
end
local function ceb1(p,e,t,pos,sz,cb)
    local btn=fw.csb(p,t:gsub(" ",""),t,e,pos,sz)
    btn.MouseButton1Click:Connect(cb)
    return btn
end
local function csl1(p,t,pos,sz)
    local f=cf1(p,{c=Color3.fromRGB(16,19,27),s=sz,p=pos,n=t:gsub(" ","")})
    cc1_ui(f,{cr=UDim.new(0,6)})
    cst1(f,{col=Color3.fromRGB(35,39,54),th=1})
    local l=ct1(f,{t=t,ts=14,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.9,0,0.8,0),p=UDim2.new(0.05,0,0.1,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    return l
end
local function csg1(p,t,pos,sz,min,max,def,cb)
    local f=cf1(p,{c=Color3.fromRGB(16,19,27),s=sz,p=pos,n=t:gsub(" ","")})
    cc1_ui(f,{cr=UDim.new(0,8)})
    cst1(f,{col=Color3.fromRGB(35,39,54),th=1})
    local l=ct1(f,{t=t..": "..def,ts=12,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.9,0,0.25,0),p=UDim2.new(0.05,0,0.05,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    local sf=cf1(f,{c=Color3.fromRGB(35,39,54),s=UDim2.new(0.9,0,0.35,0),p=UDim2.new(0.05,0,0.35,0),n="SliderFrame"})
    cc1_ui(sf,{cr=UDim.new(0,15)})
    local sb=cf1(sf,{c=Color3.fromRGB(0,150,255),s=UDim2.new(0.08,0,0.8,0),p=UDim2.new(0,0,0.1,0),n="SliderButton"})
    cc1_ui(sb,{cr=UDim.new(0.5,0)})
    local dragging=false
    local val=def
    local function updateSlider(input)
        if dragging then
            local relativeX=(input.Position.X-sf.AbsolutePosition.X)/sf.AbsoluteSize.X
            relativeX=math.clamp(relativeX,0,1)
            val=min+(max-min)*relativeX
            sb.Position=UDim2.new(relativeX-0.04,0,0.1,0)
            l.Text=t..": "..math.floor(val*100)/100
            cb(val)
        end
    end
    sb.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true
        end
    end)
    local uis=us1()
    if uis then
        uis.InputEnded:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
                dragging=false
            end
        end)
        uis.InputChanged:Connect(function(input)
            if input.UserInputType==Enum.UserInputType.MouseMovement or input.UserInputType==Enum.UserInputType.Touch then
                updateSlider(input)
            end
        end)
        uis.TouchMoved:Connect(function(input)
            updateSlider(input)
        end)
    end
    return f
end
local function ctg1(p,t,pos,sz,def,cb)
    local f=cf1(p,{c=Color3.fromRGB(16,19,27),s=sz,p=pos,n=t:gsub(" ","")})
    cc1_ui(f,{cr=UDim.new(0,8)})
    cst1(f,{col=Color3.fromRGB(35,39,54),th=1})
    local l=ct1(f,{t=t,ts=12,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.65,0,0.8,0),p=UDim2.new(0.05,0,0.1,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    local tb=cf1(f,{c=def and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60),s=UDim2.new(0.2,0,0.6,0),p=UDim2.new(0.75,0,0.2,0),n="ToggleButton"})
    cc1_ui(tb,{cr=UDim.new(0.5,0)})
    local tc=cf1(tb,{c=Color3.fromRGB(255,255,255),s=UDim2.new(0.35,0,0.8,0),p=def and UDim2.new(0.6,0,0.1,0) or UDim2.new(0.05,0,0.1,0),n="ToggleCircle"})
    cc1_ui(tc,{cr=UDim.new(0.5,0)})
    local state=def
    tb.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch then
            state=not state
            tb.BackgroundColor3=state and Color3.fromRGB(0,150,255) or Color3.fromRGB(60,60,60)
            tc:TweenPosition(state and UDim2.new(0.6,0,0.1,0) or UDim2.new(0.05,0,0.1,0),"Out","Quad",0.2,true)
            cb(state)
        end
    end)
    return f
end
local function sh1()
    local hs=gsafe("HttpService",3)
    local ts=gsafe("TeleportService",3)
    if hs and ts then
        local ok,svs=pcall(function()
            return hs:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if ok and svs.data then
            for _,sv in pairs(svs.data) do
                if sv.playing<sv.maxPlayers and sv.id~=game.JobId then
                    ts:TeleportToPlaceInstance(game.PlaceId,sv.id)
                    break
                end
            end
        else
            fw.sa("Error","Failed to get servers!",2)
        end
    else
        fw.sa("Error","Required services not available!",2)
    end
end
local function cws1()
    local c=0
    local ps=gsafe("Players",3)
    for _,obj in pairs(workspace:GetChildren()) do
        if not obj:IsA("Terrain") and not obj:IsA("Camera") and obj~=workspace.CurrentCamera and (not ps or not ps:GetPlayerFromCharacter(obj)) then
            pcall(function()
                obj:Destroy()
                c=c+1
            end)
        end
    end
    fw.sa("Success","Cleared "..c.." objects!",2)
end
local function ts1()
    local uset=gs1()
    if uset then
        if uset.MasterVolume>0 then
            uset.MasterVolume=0
            fw.sa("Info","Sound OFF!",2)
        else
            uset.MasterVolume=1
            fw.sa("Info","Sound ON!",2)
        end
    end
end
w.aio=function()
if not obr or not g["3"]then return end
local tp,tsz=UDim2.new(0.018,0,0.031,0),UDim2.new(0.964,0,0.936,0)
if d then g["3"].Position,g["3"].Size,g["3"].Visible,obr.Visible=tp,tsz,true,false if sbr and pgr then sbr.Position,pgr.Position=UDim2.new(0,0,0,0),UDim2.new(0.255,0,0,0)end return end
local bp,bs,ssz=obr.AbsolutePosition,obr.AbsoluteSize,obr.Parent.AbsoluteSize
local cx,cy=bp.X+bs.X/2,bp.Y+bs.Y/2
g["3"].Position=UDim2.new(0,cx-ssz.X*tsz.X.Scale/2,0,cy-ssz.Y*tsz.Y.Scale/2)
g["3"].Size,g["3"].Visible,obr.Visible=UDim2.new(0,bs.X,0,bs.Y),true,false
local et=tw:Create(g["3"],TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=tsz,Position=tp})
et:Play()et.Completed:Connect(function()if sbr and pgr then sbr.Position,pgr.Position=UDim2.new(-0.25,0,0,0),UDim2.new(1,0,0,0)local st=tw:Create(sbr,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0,0,0,0)})local pt=tw:Create(pgr,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.255,0,0,0)})st:Play()spawn(function()task.wait(0.1)pt:Play()end)end end)
end
w.aic=function()
if not obr or not g["3"]then return end
local cbp,cbs=obr.Position,obr.Size
if d then g["3"].Visible,obr.Visible=false,true if sbr and pgr then sbr.Position,pgr.Position=UDim2.new(0,0,0,0),UDim2.new(0.255,0,0,0)end return end
if sbr and pgr then local st=tw:Create(sbr,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(-0.25,0,0,0)})local pt=tw:Create(pgr,TweenInfo.new(0.25,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(1,0,0,0)})st:Play()pt:Play()pt.Completed:Connect(function()local ssz=g["3"].Parent.AbsoluteSize local bap=Vector2.new(ssz.X*cbp.X.Scale+cbp.X.Offset,ssz.Y*cbp.Y.Scale+cbp.Y.Offset)local bas=Vector2.new(ssz.X*cbs.X.Scale+cbs.X.Offset,ssz.Y*cbs.Y.Scale+cbs.Y.Offset)local cx,cy=bap.X+bas.X/2,bap.Y+bas.Y/2 local sht=tw:Create(g["3"],TweenInfo.new(0.4,Enum.EasingStyle.Back,Enum.EasingDirection.In),{Size=UDim2.new(0,bas.X,0,bas.Y),Position=UDim2.new(0,cx-bas.X/2,0,cy-bas.Y/2)})sht:Play()sht.Completed:Connect(function()g["3"].Visible,obr.Visible=false,true obr.Size,obr.Position=UDim2.new(0,0,0,0),UDim2.new(0,cx,0,cy)local bat=tw:Create(obr,TweenInfo.new(0.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=cbs,Position=cbp})bat:Play()end)end)end
end
w.sct=function()for _,tw in pairs(ctw)do if tw then tw:Cancel()end end ctw={}if cfp then cfp.Visible,cfp.Position=false,UDim2.new(-0.001,0,0,0)end if ctp then ctp.Visible,ctp.Position=false,UDim2.new(0.1,0,0,0)end cfp,ctp,ia=nil,nil,false end
w.apt=function(fp,tp,cb)
if ia then w.sct()end cfp,ctp=fp,tp
if d then if fp then fp.Visible=false end if tp then tp.Visible=true end ia=false if cb then cb()end return end
ia=true if fp and tp then if fp==tp then ia,cfp,ctp=false,nil,nil if cb then cb()end return end tp.Visible,tp.Position=true,UDim2.new(0.1,0,0,0)local so=tw:Create(fp,TweenInfo.new(0.15,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(-0.1,0,0,0)})local si=tw:Create(tp,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(-0.001,0,0,0)})ctw[1],ctw[2]=so,si so:Play()so.Completed:Connect(function()if not ia then return end fp.Visible,fp.Position=false,UDim2.new(-0.001,0,0,0)si:Play()si.Completed:Connect(function()ia,ctw,cfp,ctp=false,{},nil,nil if cb then cb()end end)end)elseif tp then tp.Visible,tp.Position=true,UDim2.new(0.1,0,0,0)local si=tw:Create(tp,TweenInfo.new(0.2,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(-0.001,0,0,0)})ctw[1]=si si:Play()si.Completed:Connect(function()ia,ctw,cfp,ctp=false,{},nil,nil if cb then cb()end end)else ia,cfp,ctp=false,nil,nil if cb then cb()end end
end
local csb=function(p,nm,txt,ico,pos,sz)local btn=nf(p,{c=Color3.fromRGB(255,255,255),s=sz,p=pos,n=nm})nc(btn,0.2)ng(btn,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))local lbl=nt(btn,{tw=true,ts=16,xa=Enum.TextXAlignment.Left,ya=Enum.TextYAlignment.Top,sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal),tc=Color3.fromRGB(29,29,38),bt=1,s=UDim2.new(0.65,0,0.4,0),t=txt,n="Lbl",p=UDim2.new(0.25,0,0.3,0)})ntc(lbl,16)nim(btn,{st=Enum.ScaleType.Fit,i=ico,s=UDim2.new(0.15,0,0.4,0),bt=1,n="Ico",p=UDim2.new(0.05,0,0.3,0)})local clk=nb(btn,{tw=true,tc=Color3.fromRGB(0,0,0),ts=12,sc=true,bt=1,s=UDim2.new(1,0,1,0),n="Clk",t="  "})nc(clk,0)ntc(clk,12)return clk end
local crb=function(p,nm,ico,pos,sz)local btn=nf(p,{z=2,c=Color3.fromRGB(255,255,255),s=sz,p=pos,n=nm})nc(btn,1)nim(btn,{z=2,st=Enum.ScaleType.Fit,i=ico,s=UDim2.new(0.4,0,0.4,0),bt=1,n="Ico",p=UDim2.new(0.3,0,0.3,0)})ng(btn,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))local clk=nb(btn,{tw=true,tc=Color3.fromRGB(0,0,0),ts=12,sc=true,bt=1,z=3,s=UDim2.new(1,0,1,0),n="Clk",t="  "})nc(clk,0)ntc(clk,12)nar(btn,1)return clk end
w.ut=function()
if tbr and tsr and pbr then local el=tick()-ss local h,m,s=math.floor(el/3600),math.floor((el%3600)/60),math.floor(el%60)tbr.Text=string.format("Session: %02d:%02d:%02d",h,m,s)local h2,m2,s2=gvt()local tsec,msec,pc=(h2 or 0)*3600+(m2 or 0)*60+(s2 or 0),50*3600,0 if tsec>0 then pc=math.min(tsec/msec,1)tsr.Text,tsr.TextColor3=string.format("Remaining: %02d:%02d:%02d",h2 or 0,m2 or 0,s2 or 0),Color3.fromRGB(255,255,255)if d then pbr.Size=UDim2.new(pc,0,1,0)else local st=tw:Create(pbr,TweenInfo.new(0.5,Enum.EasingStyle.Quad),{Size=UDim2.new(pc,0,1,0)})st:Play()end local cl=(pc>0.5 and {Color3.fromRGB(100,255,100),Color3.fromRGB(50,200,50)})or(pc>0.2 and {Color3.fromRGB(255,200,100),Color3.fromRGB(200,150,50)})or{Color3.fromRGB(255,100,100),Color3.fromRGB(200,50,50)}ng(pbr,cl[1],cl[2])else tsr.Text,tsr.TextColor3="Status: EXPIRED",Color3.fromRGB(255,100,100)pbr.Size=UDim2.new(0,0,1,0)end end
end
w.st=function()if not e.isf(td)then e.mf(td)end local tbd={}for id,tab in pairs(tb)do tbd[tostring(id)]={name=tab.name,content=tab.content,id=tab.id}end tbd.currentTab,tbd.tabCounter=ct,tc e.wf(td.."tabs.json",game:GetService(s[8]):JSONEncode(tbd))end
w.lt=function()if e.iff(td.."tabs.json")then local success,data=pcall(function()return game:GetService(s[8]):JSONDecode(e.rf(td.."tabs.json"))end)if success and data then ct,tc=data.currentTab or 1,data.tabCounter or 1 for id,ti in pairs(data)do if type(ti)=="table"and ti.name then tb[tonumber(id)]={name=ti.name,content=ti.content,id=ti.id,button=nil,closeButton=nil}end end return true end end return false end
w.al=function(msg,mt,cc,fe)if not ce then return end local tst,cl,pf=os.date("[%H:%M:%S]"),Color3.fromRGB(255,255,255),""local colors={error={Color3.fromRGB(255,100,100),"[ERROR] "},warn={Color3.fromRGB(255,200,100),"[WARN] "},info={Color3.fromRGB(100,200,255),"[INFO] "},editor={Color3.fromRGB(255,150,255),"[EDITOR] "}}if colors[mt]then cl,pf=colors[mt][1],colors[mt][2]end local le={text=tst.." "..pf..tostring(msg),color=cl,canCopy=cc~=false,fullText=tostring(msg),type=mt or"info",fromEditor=fe or false}table.insert(co,le)if#co>200 then table.remove(co,1)end w.uc()end
w.uc=function()if csr then for _,ch in pairs(csr:GetChildren())do if ch:IsA(u[4])then ch:Destroy()end end local yp=0 for i,lg in ipairs(co)do local lb=nb(csr,{c=i%2==0 and Color3.fromRGB(20,23,30)or Color3.fromRGB(16,19,27),s=UDim2.new(1,0,0,35),p=UDim2.new(0,0,0,yp),n="LogEntry"..i,t=lg.text,ts=16,tc=lg.color,xa=Enum.TextXAlignment.Left,ff=Font.new(c[2],Enum.FontWeight.Medium,Enum.FontStyle.Normal),tw=true,sc=false})ntc(lb,16)lb.MouseButton1Click:Connect(function()if e.sc and lg.canCopy then e.sc(lg.fullText)w.sa("Success","Copied to clipboard!",1)end end)yp=yp+35 end csr.CanvasSize,csr.CanvasPosition=UDim2.new(0,0,0,yp),Vector2.new(0,yp)end end
w.cc=function()co={}w.uc()end
w.tc=function()ce=not ce if ce then w.al("Console enabled","info")end return ce end
w.cac=function()local at=""for i,lg in ipairs(co)do at=at..lg.text if i<#co then at=at.."\n"end end if e.sc then e.sc(at)w.sa("Success","All console output copied!",2)end end
w.ca=function()return true end
w.csb=function(p,nm,txt,ico,pos,sz)return csb(p,nm,txt,ico,pos,sz)end
w.crb=function(p,nm,ico,pos,sz)return crb(p,nm,ico,pos,sz)end
w.cbu=function()g["1"]=ap(ni(u[1],cs),{IgnoreGuiInset=true,DisplayOrder=999999999,ScreenInsets=Enum.ScreenInsets.None,n="FW",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ResetOnSpawn=false})g["3"]=nf(g["1"],{v=false,BorderSizePixel=0,c=Color3.fromRGB(16,19,27),bt=0.6,cl=true,s=UDim2.new(0.964,0,0.936,0),p=UDim2.new(0.018,0,0.031,0),n="UI"})nc(g["3"],0.04)ns(g["3"],10,Color3.fromRGB(35,39,54))g["6"]=ap(ni(u[14],g["3"]),{n="Main"})g["7"]=nim(g["6"],{z=6,ic=Color3.fromRGB(36,42,60),i=c[3],s=UDim2.new(0.314,0,0.185,0),v=false,cl=true,bt=1,n="Alert",p=UDim2.new(0.398,0,0.074,0)})local at=nt(g["7"],{tw=true,LineHeight=0,ts=31,xa=Enum.TextXAlignment.Left,ya=Enum.TextYAlignment.Top,sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal),tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.505,0,0.175,0),t="FrostWare Notification",p=UDim2.new(0.147,0,0.21,0)})ntc(at,31)local am=nt(g["7"],{tw=true,ts=23,xa=Enum.TextXAlignment.Left,ya=Enum.TextYAlignment.Top,sc=true,ff=Font.new(c[1],Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),tc=Color3.fromRGB(162,177,234),bt=1,s=UDim2.new(0.45,0,0.321,0),t="Message content",n="MSG",p=UDim2.new(0.148,0,0.449,0)})ntc(am,23)local ai=nim(g["7"],{z=2,i=c[4],s=UDim2.new(0.031,0,0.54,0),bt=1,p=UDim2.new(0.059,0,0.21,0)})ng(ai,Color3.fromRGB(166,190,255),Color3.fromRGB(121,152,207),91.1)nim(g["7"],{ic=Color3.fromRGB(16,19,27),i=c[5],s=UDim2.new(0.067,0,0.941,0),bt=1,n="Shd",p=UDim2.new(0.036,0,0,0)})nib(g["7"],{i=c[6],s=UDim2.new(0.05,0,0.16,0),bt=1,n="Ico",p=UDim2.new(0.84,0,0.396,0)})nim(g["6"],{z=22,ic=Color3.fromRGB(16,19,27),i=c[7],s=UDim2.new(0.019,0,1,0),bt=1,n="Shd",p=UDim2.new(0.254,0,0,0)})g["11"]=nim(g["6"],{ImageTransparency=1,ic=Color3.fromRGB(13,15,20),i=c[8],s=UDim2.new(0.745,0,1,0),cl=true,bt=1,n="Pages",p=UDim2.new(0.255,0,0,0)})local ob=nim(g["1"],{i=c[9],s=UDim2.new(0.116,0,0.208,0),v=false,bt=1,n="OpenBtn",p=UDim2.new(0.442,0,0.045,0),ac=true,dr=true})nc(ob,0)nim(ob,{st=Enum.ScaleType.Fit,ic=Color3.fromRGB(255,255,255),i=c[10],s=UDim2.new(0.221,0,0.244,0),bt=1,p=UDim2.new(0.388,0,0.367,0)})local oc=nb(ob,{tc=Color3.fromRGB(0,0,0),ts=14,bt=1,z=6,s=UDim2.new(0.441,0,0.427,0),n="OpenClk",t="  ",p=UDim2.new(0.279,0,0.284,0)})nc(oc,0)ntc(oc,12)ap(ni(u[14],g["6"]),{n="Alerts"})obr,pgr=ob,g["11"]return g,oc end
w.createSidebarButton=function(p,nm,txt,ico,pos,sel)local btn=nf(p,{c=sel and Color3.fromRGB(30,36,51)or Color3.fromRGB(31,34,50),s=UDim2.new(0.68,0,0.064,0),p=pos,n=nm,bt=sel and 0 or 1})nc(btn,0.15)local bx=nf(btn,{z=sel and 2 or 0,c=Color3.fromRGB(255,255,255),s=UDim2.new(0.15,0,0.6,0),p=UDim2.new(0.08,0,0.2,0),n="Box"})nc(bx,0.2)nar(bx,1)local cl=sel and {Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160)}or{Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63)}ng(bx,cl[1],cl[2])nim(bx,{z=sel and 2 or 0,st=Enum.ScaleType.Fit,i=ico,s=UDim2.new(0.6,0,0.6,0),bt=1,n="Ico",p=UDim2.new(0.2,0,0.2,0)})local lbl=nt(btn,{tw=true,ts=16,xa=Enum.TextXAlignment.Left,ya=Enum.TextYAlignment.Top,sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal),tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.6,0,0.6,0),t=txt,n="Lbl",p=UDim2.new(0.3,0,0.2,0)})ntc(lbl,16)local clk=nb(btn,{tw=true,tc=Color3.fromRGB(0,0,0),ts=12,sc=true,bt=1,s=UDim2.new(1,0,1,0),n="Clk",t="  ",z=5})nc(clk,0)ntc(clk,12)return btn,clk end
w.csid=function()local sb=nim(g["6"],{ImageTransparency=1,ic=Color3.fromRGB(13,15,20),i=c[11],s=UDim2.new(0.25,0,1,0),bt=1,n="Sidebar"})sbr=sb local pf=nf(sb,{c=Color3.fromRGB(20,25,32),s=UDim2.new(0.85,0,0.12,0),p=UDim2.new(0.075,0,0.75,0),n="ProgressFrame"})nc(pf,0.15)ns(pf,2,Color3.fromRGB(35,39,54))local sl=nt(pf,{t="Session Time",ts=14,tc=Color3.fromRGB(200,200,200),bt=1,s=UDim2.new(0.9,0,0.2,0),p=UDim2.new(0.05,0,0.05,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(sl,14)local tt=nt(pf,{t="00:00:00",ts=16,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.9,0,0.25,0),p=UDim2.new(0.05,0,0.25,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.Medium,Enum.FontStyle.Normal)})ntc(tt,16)tbr=tt local pb=nf(pf,{c=Color3.fromRGB(30,35,45),s=UDim2.new(0.9,0,0.15,0),p=UDim2.new(0.05,0,0.55,0),n="ProgressBg"})nc(pb,0.1)local pr=nf(pb,{c=Color3.fromRGB(100,255,100),s=UDim2.new(1,0,1,0),p=UDim2.new(0,0,0,0),n="ProgressBar"})nc(pr,0.1)ng(pr,Color3.fromRGB(100,255,100),Color3.fromRGB(50,200,50))pbr=pr local st=nt(pf,{t="Checking...",ts=12,tc=Color3.fromRGB(180,180,180),bt=1,s=UDim2.new(0.9,0,0.2,0),p=UDim2.new(0.05,0,0.75,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.Regular,Enum.FontStyle.Normal)})ntc(st,12)tsr=st local ub=nf(sb,{c=Color3.fromRGB(255,255,255),s=UDim2.new(0.68,0,0.064,0),p=UDim2.new(0.075,0,0.9,0),n="UpBtn"})nc(ub,0.15)ng(ub,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))local ul=nt(ub,{tw=true,ts=14,xa=Enum.TextXAlignment.Left,ya=Enum.TextYAlignment.Top,sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal),tc=Color3.fromRGB(29,29,38),bt=1,s=UDim2.new(0.7,0,0.6,0),t="Upgrade Plan",n="UpLbl",p=UDim2.new(0.25,0,0.2,0)})ntc(ul,14)nim(ub,{st=Enum.ScaleType.Fit,i=c[22],s=UDim2.new(0.15,0,0.6,0),bt=1,n="UpIco",p=UDim2.new(0.05,0,0.2,0)})local uc=nb(ub,{tw=true,tc=Color3.fromRGB(0,0,0),ts=12,sc=true,bt=1,s=UDim2.new(1,0,1,0),n="UpClk",t=""})nc(uc,0)ntc(uc,12)uc.MouseButton1Click:Connect(function()e.sc("https://discord.gg/getfrost")end)local edBtn,edc=w.createSidebarButton(sb,"Editor","Editor",c[12],UDim2.new(0.075,0,0.2,0),true)local coBtn,coc=w.createSidebarButton(sb,"Console","Console",c[13],UDim2.new(0.075,0,0.28,0),false)local exBtn,exc=w.createSidebarButton(sb,"Extra","Extra",c[14],UDim2.new(0.075,0,0.36,0),false)local lg=nim(sb,{st=Enum.ScaleType.Fit,i=c[10],s=UDim2.new(0.2,0,0.08,0),bt=1,n="Logo",p=UDim2.new(0.4,0,0.05,0)})nc(lg,0)local cl=nim(sb,{z=2,ic=Color3.fromRGB(34,41,58),i=c[15],s=UDim2.new(0.13,0,1,0),bt=1,n="Close",p=UDim2.new(0.891,0,0,0)})local sl=nb(cl,{tw=true,tc=Color3.fromRGB(0,0,0),ts=14,sc=true,bt=1,s=UDim2.new(1,0,0.189,0),n="Slide",t="  ",p=UDim2.new(0,0,0.43,0)})ntc(sl,14)return sb,uc,edc,coc,exc,sl end
w.ce=function()local ep=nim(g["11"],{ImageTransparency=1,ic=Color3.fromRGB(13,15,20),i=c[8],s=UDim2.new(1.001,0,1,0),cl=true,bt=1,n="EditorPage",p=UDim2.new(-0.001,0,0,0)})local tbar=nf(ep,{c=Color3.fromRGB(16,19,27),s=UDim2.new(1,0,0.08,0),p=UDim2.new(0,0,0,0),n="TabBar"})nc(tbar,0.02)ns(tbar,2,Color3.fromRGB(35,39,54))local tscr=nsf(tbar,{bt=1,s=UDim2.new(0.85,0,1,0),p=UDim2.new(0,0,0,0),n="TabScroll",sb=0,cs=UDim2.new(0,0,0,0)})ap(ni(u[15],tscr),{fd=Enum.FillDirection.Horizontal,so=Enum.SortOrder.LayoutOrder,pd=UDim.new(0,2)})local at=nb(tbar,{c=Color3.fromRGB(166,190,255),s=UDim2.new(0.08,0,0.7,0),p=UDim2.new(0.9,0,0.15,0),t="+",tc=Color3.fromRGB(29,29,38),ts=28,n="AddTab",ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})nc(at,0.2)ng(at,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))ntc(at,28)local epp=nim(ep,{ic=Color3.fromRGB(32,39,57),i=c[19],s=UDim2.new(0.84,0,0.92,0),cl=true,bt=1,n="EditorPage",p=UDim2.new(0,0,0.08,0)})local txb=nf(epp,{c=Color3.fromRGB(24,24,32),s=UDim2.new(1,0,1,0),p=UDim2.new(0,0,0,0),n="TxtBox",bt=1})local ef=nsf(txb,{eb=Enum.ElasticBehavior.Always,ti=c[20],mi=c[20],vs=Enum.ScrollBarInset.Always,c=Color3.fromRGB(32,31,32),n="EditorFrame",sit=1,hs=Enum.ScrollBarInset.Always,bi=c[20],s=UDim2.new(1,0,1,0),sic=Color3.fromRGB(38,40,46),sb=10,bt=1})local src=ntb(ef,{cp=-1,n="Source",xa=Enum.TextXAlignment.Left,pc=Color3.fromRGB(205,205,205),z=3,tw=true,tt=0,ts=20,tc=Color3.fromRGB(255,255,255),ya=Enum.TextYAlignment.Top,rt=false,ff=Font.new(c[2],Enum.FontWeight.Medium,Enum.FontStyle.Normal),ml=true,cf=false,cl=true,s=UDim2.new(0.7,0,2,0),p=UDim2.new(0.08,0,0,0),t="-- FrostWare V3 Advanced System\nprint('Hello World!')",bt=1})local ln=nt(ef,{tw=true,ts=20,ya=Enum.TextYAlignment.Top,sc=true,c=Color3.fromRGB(32,31,32),ff=Font.new(c[2],Enum.FontWeight.Regular,Enum.FontStyle.Normal),tc=Color3.fromRGB(193,191,235),bt=1,s=UDim2.new(0.05,0,2,0),p=UDim2.new(0.021,0,-0.003,0)})ntc(ln,20)nc(ef)local btns=nim(ep,{z=2,ic=Color3.fromRGB(16,19,27),i=c[21],s=UDim2.new(0.16,0,0.92,0),cl=true,bt=1,n="Btns",p=UDim2.new(0.84,0,0.08,0)})local eb=csb(btns,"Exec","Execute",c[16],UDim2.new(0.05,0,0.05,0),UDim2.new(0.9,0,0.12,0))local cb=csb(btns,"Clr","Clear",c[17],UDim2.new(0.05,0,0.19,0),UDim2.new(0.9,0,0.12,0))local pb=csb(btns,"Pst","Paste",c[18],UDim2.new(0.05,0,0.33,0),UDim2.new(0.9,0,0.12,0))local ecb=csb(btns,"ExecClp","Exec Clipboard",c[16],UDim2.new(0.05,0,0.47,0),UDim2.new(0.9,0,0.12,0))sr,lr=src,ln return ep,src,ln,tscr,at,eb,cb,pb,ecb end
w.ccp=function()local cop=nim(g["11"],{ImageTransparency=1,ic=Color3.fromRGB(13,15,20),i=c[8],s=UDim2.new(1.001,0,1,0),v=false,cl=true,bt=1,n="ConsolePage",p=UDim2.new(-0.001,0,0,0)})local tit=nt(cop,{t="Console Output",ts=32,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(1,0,0.08,0),p=UDim2.new(0,0,0.02,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(tit,32)local cf=nf(cop,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.95,0,0.75,0),p=UDim2.new(0.025,0,0.12,0),n="ConsoleFrame"})nc(cf,0.02)ns(cf,2,Color3.fromRGB(35,39,54))local cs=nsf(cf,{c=Color3.fromRGB(12,15,22),s=UDim2.new(1,0,0.85,0),p=UDim2.new(0,0,0,0),sb=8,cs=UDim2.new(0,0,0,0),n="ConsoleScroll"})nc(cs,0.02)local bf=nf(cf,{bt=1,s=UDim2.new(1,0,0.15,0),p=UDim2.new(0,0,0.85,0),n="ButtonFrame"})local ccb=csb(bf,"ClearConsole","Clear Console",c[17],UDim2.new(0.02,0,0.2,0),UDim2.new(0.14,0,0.48,0))local cab=csb(bf,"CopyAll","Copy All",c[18],UDim2.new(0.18,0,0.2,0),UDim2.new(0.14,0,0.48,0))local tgb=csb(bf,"Toggle","Toggle Console",c[12],UDim2.new(0.34,0,0.2,0),UDim2.new(0.14,0,0.48,0))csr=cs ccb.MouseButton1Click:Connect(function()w.cc()w.sa("Success","Console cleared!",2)end)cab.MouseButton1Click:Connect(function()w.cac()end)tgb.MouseButton1Click:Connect(function()local en=w.tc()w.sa("Info",en and"Console enabled!"or"Console disabled!",2)end)return cop end
local function uep1()
    local ui=fw.gu()
    local ep=ui["11"]:FindFirstChild("ExtraPage")
    if not ep then return end
    for _,ch in pairs(ep:GetChildren()) do
        if ch.Name~="TextLabel" then
            ch:Destroy()
        end
    end
    local tt=ep:FindFirstChild("TextLabel")
    if tt then
        tt.Text="🛠️ Advanced System Tools"
        tt.Size=UDim2.new(1,0,0.04,0)
        tt.Position=UDim2.new(0,0,0.01,0)
    end
    local mf=cs1(ep,{c=Color3.fromRGB(20,25,32),s=UDim2.new(0.95,0,0.94,0),p=UDim2.new(0.025,0,0.05,0),n="MainFrame",cs=UDim2.new(0,0,2.2,0),sbt=8,sbc=Color3.fromRGB(166,190,255),bs=0})
    cc1_ui(mf,{cr=UDim.new(0,12)})
    cst1(mf,{col=Color3.fromRGB(35,39,54),th=2})
    local sf=cf1(mf,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.96,0,0.08,0),p=UDim2.new(0.02,0,0.01,0),n="StatsFrame"})
    cc1_ui(sf,{cr=UDim.new(0,8)})
    cst1(sf,{col=Color3.fromRGB(35,39,54),th=1})
    local st=ct1(sf,{t="📊 Live Stats",ts=16,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.96,0,0.25,0),p=UDim2.new(0.02,0,0.05,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    pcl1=csl1(sf,"👥 0/0",UDim2.new(0.02,0,0.35,0),UDim2.new(0.18,0,0.6,0))
    pgl1=csl1(sf,"📡 0ms",UDim2.new(0.22,0,0.35,0),UDim2.new(0.18,0,0.6,0))
    fpl1=csl1(sf,"🎯 0 FPS",UDim2.new(0.42,0,0.35,0),UDim2.new(0.18,0,0.6,0))
    mml1=csl1(sf,"💾 0MB",UDim2.new(0.62,0,0.35,0),UDim2.new(0.18,0,0.6,0))
    tml1=csl1(sf,"⏱️ 0:00",UDim2.new(0.82,0,0.35,0),UDim2.new(0.16,0,0.6,0))
    local tf=cf1(mf,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.46,0,0.18,0),p=UDim2.new(0.02,0,0.11,0),n="ToggleFrame"})
    cc1_ui(tf,{cr=UDim.new(0,8)})
    cst1(tf,{col=Color3.fromRGB(35,39,54),th=1})
    local tft=ct1(tf,{t="🔧 Toggle Features",ts=14,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.96,0,0.12,0),p=UDim2.new(0.02,0,0.02,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    ctg1(tf,"👀 Advanced ESP",UDim2.new(0.02,0,0.16,0),UDim2.new(0.96,0,0.08,0),esp1,tep1)
    ctg1(tf,"🔍 Advanced X-Ray",UDim2.new(0.02,0,0.26,0),UDim2.new(0.96,0,0.08,0),xry1,txr1)
    ctg1(tf,"📱 Touch Teleport",UDim2.new(0.02,0,0.36,0),UDim2.new(0.96,0,0.08,0),ctp1,tctp1)
    ctg1(tf,"💡 Advanced Fullbright",UDim2.new(0.02,0,0.46,0),UDim2.new(0.96,0,0.08,0),fbr1,tfbr1)
    ctg1(tf,"😴 Anti-AFK (Always ON)",UDim2.new(0.02,0,0.56,0),UDim2.new(0.96,0,0.08,0),true,function() end)
    ctg1(tf,"🧊 Freeze Character",UDim2.new(0.02,0,0.66,0),UDim2.new(0.96,0,0.08,0),frz1,tfrz1)
    ctg1(tf,"👻 NoClip Mode",UDim2.new(0.02,0,0.76,0),UDim2.new(0.96,0,0.08,0),ncp1,tncp1)
    ctg1(tf,"📷 Free Camera",UDim2.new(0.02,0,0.86,0),UDim2.new(0.96,0,0.08,0),cam1,tcam1)
    local tf2=cf1(mf,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.46,0,0.18,0),p=UDim2.new(0.5,0,0.11,0),n="ToggleFrame2"})
    cc1_ui(tf2,{cr=UDim.new(0,8)})
    cst1(tf2,{col=Color3.fromRGB(35,39,54),th=1})
    local tf2t=ct1(tf2,{t="⚡ Movement Features",ts=14,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.96,0,0.12,0),p=UDim2.new(0.02,0,0.02,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    ctg1(tf2,"🌌 Zero Gravity",UDim2.new(0.02,0,0.16,0),UDim2.new(0.96,0,0.08,0),gra1,tgra1)
    ctg1(tf2,"💫 Animation Head",UDim2.new(0.02,0,0.26,0),UDim2.new(0.96,0,0.08,0),anh1,tanh1)
    local cf=cf1(mf,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.96,0,0.12,0),p=UDim2.new(0.02,0,0.31,0),n="ControlFrame"})
    cc1_ui(cf,{cr=UDim.new(0,8)})
    cst1(cf,{col=Color3.fromRGB(35,39,54),th=1})
    local cft=ct1(cf,{t="🎮 Advanced Controls",ts=14,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.96,0,0.15,0),p=UDim2.new(0.02,0,0.02,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    csg1(cf,"🎭 Animation Speed",UDim2.new(0.02,0,0.2,0),UDim2.new(0.46,0,0.75,0),0,10,ani1,sani1)
    csg1(cf,"🔭 Field of View",UDim2.new(0.52,0,0.2,0),UDim2.new(0.46,0,0.75,0),30,120,fov1,sfov1)
    local bsz=UDim2.new(0.18,0,0.04,0)
    ceb1(mf,"🔄","Rejoin",UDim2.new(0.02,0,0.45,0),bsz,function()
        local ts=gsafe("TeleportService",3)
        if ts then
            ts:Teleport(game.PlaceId,lp)
        else
            fw.sa("Error","TeleportService not available!",2)
        end
    end)
    ceb1(mf,"🌐","Server Hop",UDim2.new(0.22,0,0.45,0),bsz,function()
        sh1()
    end)
    ceb1(mf,"📋","Copy ID",UDim2.new(0.42,0,0.45,0),bsz,function()
        if e.sc then
            e.sc(tostring(lp.UserId))
            fw.sa("Success","ID copied!",2)
        end
    end)
    ceb1(mf,"👁️","Hide UI",UDim2.new(0.62,0,0.45,0),bsz,function()
        hui1()
    end)
    ceb1(mf,"⚡","Anti-Lag",UDim2.new(0.82,0,0.45,0),bsz,function()
        eal1()
    end)
    ceb1(mf,"🧹","Clear WS",UDim2.new(0.02,0,0.51,0),bsz,function()
        cws1()
    end)
    ceb1(mf,"🎵","Sound",UDim2.new(0.22,0,0.51,0),bsz,function()
        ts1()
    end)
    ceb1(mf,"🔄","Refresh",UDim2.new(0.42,0,0.51,0),bsz,function()
        fw.hd()
        task.wait(0.5)
        fw.sh()
        fw.sa("Success","UI refreshed!",2)
    end)
    ceb1(mf,"📊","Game Info",UDim2.new(0.62,0,0.51,0),bsz,function()
        local ms=gsafe("MarketplaceService",3)
        if ms then
            local success,info=pcall(function()
                return ms:GetProductInfo(game.PlaceId)
            end)
            local gameName=success and info.Name or "Unknown"
            local inf="Game: "..gameName.."\nPlace ID: "..game.PlaceId.."\nJob ID: "..game.JobId
            if e.sc then
                e.sc(inf)
                fw.sa("Success","Info copied!",2)
            else
                fw.sa("Info",inf,4)
            end
        else
            fw.sa("Error","MarketplaceService not available!",2)
        end
    end)
    ceb1(mf,"🔧","Console",UDim2.new(0.82,0,0.51,0),bsz,function()
        local sg=gsafe("StarterGui",3)
        if sg then
            pcall(function()
                sg:SetCore("DevConsoleVisible",true)
            end)
            fw.sa("Info","Console opened!",2)
        else
            fw.sa("Error","StarterGui not available!",2)
        end
    end)
    local if1=cf1(mf,{c=Color3.fromRGB(16,19,27),s=UDim2.new(0.96,0,0.12,0),p=UDim2.new(0.02,0,0.58,0),n="InfoFrame"})
    cc1_ui(if1,{cr=UDim.new(0,8)})
    cst1(if1,{col=Color3.fromRGB(35,39,54),th=1})
    local it=ct1(if1,{t="ℹ️ System Information",ts=14,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(0.96,0,0.2,0),p=UDim2.new(0.02,0,0.05,0),sc=true,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    local ei=ct1(if1,{t="Executor: "..(identifyexecutor and identifyexecutor() or "Unknown"),ts=11,tc=Color3.fromRGB(200,200,200),bt=1,s=UDim2.new(0.46,0,0.25,0),p=UDim2.new(0.02,0,0.3,0),sc=true,xa=Enum.TextXAlignment.Left,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    local hid=gethwid and gethwid() or "Unknown"
    local hi=ct1(if1,{t="HWID: "..hid:sub(1,8).."...",ts=11,tc=Color3.fromRGB(200,200,200),bt=1,s=UDim2.new(0.46,0,0.25,0),p=UDim2.new(0.52,0,0.3,0),sc=true,xa=Enum.TextXAlignment.Left,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Medium,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    local vi=ct1(if1,{t="FrostWare V3 - Advanced System",ts=11,tc=Color3.fromRGB(166,190,255),bt=1,s=UDim2.new(0.96,0,0.25,0),p=UDim2.new(0.02,0,0.65,0),sc=true,xa=Enum.TextXAlignment.Center,ffc=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),fnt=Enum.Font.SourceSans})
    upd1()
end
w.cep=function()local exp=nim(g["11"],{ImageTransparency=1,ic=Color3.fromRGB(13,15,20),i=c[8],s=UDim2.new(1.001,0,1,0),v=false,cl=true,bt=1,n="ExtraPage",p=UDim2.new(-0.001,0,0,0)})local tit=nt(exp,{t="Extra Features",ts=48,tc=Color3.fromRGB(255,255,255),bt=1,s=UDim2.new(1,0,0.2,0),p=UDim2.new(0,0,0.3,0),sc=true,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(tit,48)return exp end
w.ul=function(src,ln)if src and src.Text then local lns=src.Text:split("\n")local txt=""for i=1,#lns do txt=txt..tostring(i)if i<#lns then txt=txt.."\n"end end if ln then ln.Text=txt end end end
w.ctb=function(tscr,nm,cont)local td={name=nm or"Tab "..tc,content=cont or"-- New Tab\nprint('Hello from "..(nm or"Tab "..tc).."!')",id=tc}local tf=nf(tscr,{c=Color3.fromRGB(20,25,32),s=UDim2.new(0,140,0.7,0),p=UDim2.new(0,0,0.15,0),n="TabFrame"..td.id})nc(tf,0.2)ns(tf,1,Color3.fromRGB(35,39,54))ng(tf,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))local tbb=nb(tf,{bt=1,s=UDim2.new(0.8,0,1,0),p=UDim2.new(0,0,0,0),t=td.name,tc=Color3.fromRGB(29,29,38),ts=16,n="TabBtn"..td.id,sc=true,z=2,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(tbb,16)local cb=nf(tf,{c=Color3.fromRGB(200,100,100),s=UDim2.new(0,18,0,18),p=UDim2.new(1,-22,0,4),n="CloseFrame",z=3})nc(cb,0.4)ng(cb,Color3.fromRGB(200,100,100),Color3.fromRGB(150,50,50))local cbb=nb(cb,{bt=1,s=UDim2.new(1,0,1,0),t="×",tc=Color3.fromRGB(255,255,255),ts=14,n="CloseBtn",z=4,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(cbb,14)td.button,td.closeButton,td.frame=tbb,cbb,tf tb[td.id]=td tbb.MouseButton1Click:Connect(function()w.swt(td.id)end)cbb.MouseButton1Click:Connect(function()w.clt(td.id,tscr)end)tscr.CanvasSize=UDim2.new(0,tscr.UIListLayout.AbsoluteContentSize.X,0,0)tc=tc+1 w.st()return td.id,tbb,cbb end
w.swt=function(tid)if tb[tid]then if tb[ct]and sr then tb[ct].content=sr.Text end for _,tab in pairs(tb)do if tab.frame then tab.frame.BackgroundColor3=Color3.fromRGB(20,25,32)ng(tab.frame,Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63))if tab.button then tab.button.TextColor3=Color3.fromRGB(255,255,255)end end end ct=tid if tb[tid].frame then tb[tid].frame.BackgroundColor3=Color3.fromRGB(30,36,51)ng(tb[tid].frame,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))if tb[tid].button then tb[tid].button.TextColor3=Color3.fromRGB(29,29,38)end end if sr then sr.Text=tb[tid].content w.ul(sr,lr)end w.st()return true end return false end
w.clt=function(tid,tscr)local cnt=0 for _ in pairs(tb)do cnt=cnt+1 end if cnt<=1 then w.sa("Info","Cannot close last tab!",2)return false end if tb[tid]then if tb[tid].frame then tb[tid].frame:Destroy()end tb[tid]=nil if ct==tid then for id,_ in pairs(tb)do ct=id w.swt(id)break end end tscr.CanvasSize=UDim2.new(0,tscr.UIListLayout.AbsoluteContentSize.X,0,0)w.st()return true end return false end
w.sa=function(tit,msg,dur)local al=g["7"]:Clone()local als=g["6"]:FindFirstChild("Alerts")if als then al.Parent,al.Visible,al.Name=als,true,"Alert_"..tick()al:FindFirstChild("MSG").Text=msg al:FindFirstChild("TextLabel").Text=tit if d then al.Position=UDim2.new(0.398,0,0.074,0)spawn(function()task.wait(dur or 3)al:Destroy()end)else local tw=tw:Create(al,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.398,0,0.074,0)})tw:Play()spawn(function()task.wait(dur or 3)local fo=tw:Create(al,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0.398,0,-0.3,0)})fo:Play()fo.Completed:Connect(function()al:Destroy()end)end)end end end
w.sp=function(pn,sb)if ia then return end local cp,tp=nil,nil for _,pg in pairs(g["11"]:GetChildren())do if pg:IsA(u[6])then if pg.Visible then cp=pg end if pg.Name==pn.."Page"then tp=pg end end end if cp==tp then return end for _,btn in pairs(sb:GetChildren())do if btn:IsA(u[2])and btn.Name~="UpBtn"and btn.Name~="ProgressFrame"then btn.BackgroundTransparency=1 local bx=btn:FindFirstChild("Box")if bx then ng(bx,Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63))end end end local sbb=sb:FindFirstChild(pn)if sbb then sbb.BackgroundTransparency=0 local bx=sbb:FindFirstChild("Box")if bx then ng(bx,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))end end cpn=pn w.apt(cp,tp,function()end)end
w.rt=function(tscr)if w.lt()then for id,tab in pairs(tb)do if tab.name and tab.content then local tf=nf(tscr,{c=Color3.fromRGB(20,25,32),s=UDim2.new(0,140,0.7,0),p=UDim2.new(0,0,0.15,0),n="TabFrame"..id})nc(tf,0.2)ns(tf,1,Color3.fromRGB(35,39,54))ng(tf,Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63))local tbb=nb(tf,{bt=1,s=UDim2.new(0.8,0,1,0),p=UDim2.new(0,0,0,0),t=tab.name,tc=Color3.fromRGB(255,255,255),ts=16,n="TabBtn"..id,sc=true,z=2,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(tbb,16)local cb=nf(tf,{c=Color3.fromRGB(200,100,100),s=UDim2.new(0,18,0,18),p=UDim2.new(1,-22,0,4),n="CloseFrame",z=3})nc(cb,0.4)ng(cb,Color3.fromRGB(200,100,100),Color3.fromRGB(150,50,50))local cbb=nb(cb,{bt=1,s=UDim2.new(1,0,1,0),t="×",tc=Color3.fromRGB(255,255,255),ts=14,n="CloseBtn",z=4,ff=Font.new(c[1],Enum.FontWeight.Bold,Enum.FontStyle.Normal)})ntc(cbb,14)tb[id].button,tb[id].closeButton,tb[id].frame=tbb,cbb,tf tbb.MouseButton1Click:Connect(function()w.swt(id)end)cbb.MouseButton1Click:Connect(function()w.clt(id,tscr)end)end end tscr.CanvasSize=UDim2.new(0,tscr.UIListLayout.AbsoluteContentSize.X,0,0)return true end return false end
w.gu=function()return g end
w.gct=function()return ct end
w.gt=function()return tb end
w.sh=function()w.aio()end
w.hd=function()w.aic()end
w.iwa=function()ha=true local sb,uc,edc,coc,exc,sl=w.csid()spawn(function()local ed,src,ln,tscr,at,eb,cb,pb,ecb=w.ce()local cop=w.ccp()local exp=w.cep()local se=function()local tr=w.rt(tscr)if not tr then local mt=w.ctb(tscr,"Main","-- FrostWare V3 Advanced System\nprint('Hello World!')")w.swt(mt)else local ct=w.gct()w.swt(ct)end w.ul(src,ln)src:GetPropertyChangedSignal("Text"):Connect(function()w.ul(src,ln)local ct=w.gct()local tb=w.gt()if tb[ct]then tb[ct].content=src.Text spawn(function()task.wait(0.5)w.st()end)end end)at.MouseButton1Click:Connect(function()local ni,tbb,cbb=w.ctb(tscr,"New Tab","-- New Tab\nprint('Hello!')")w.swt(ni)end)end local sbt=function()eb.MouseButton1Click:Connect(function()local cd=src.Text if cd and cd~=""then ee=true local suc,res=pcall(function()return loadstring(cd)end)if suc and res then local es,er=pcall(res)if es then w.al("Script executed successfully","editor",true,true)else w.al("Execution error: "..tostring(er),"error",true,true)end else w.al("Compilation error: "..tostring(res),"error",true,true)end ee=false end end)cb.MouseButton1Click:Connect(function()src.Text=""local ct=w.gct()local tb=w.gt()if tb[ct]then tb[ct].content=""end w.ul(src,ln)w.st()end)pb.MouseButton1Click:Connect(function()local cb=e.gc()if cb~=""then src.Text=cb local ct=w.gct()local tb=w.gt()if tb[ct]then tb[ct].content=cb end w.ul(src,ln)w.st()end end)ecb.MouseButton1Click:Connect(function()local cb=e.gc()if cb~=""then ee=true local suc,res=pcall(function()return loadstring(cb)end)if suc and res then local es,er=pcall(res)if es then w.al("Clipboard script executed successfully","editor",true,true)else w.al("Clipboard execution error: "..tostring(er),"error",true,true)end else w.al("Clipboard compilation error: "..tostring(res),"error",true,true)end ee=false end end)end local sn=function()edc.MouseButton1Click:Connect(function()w.sp("Editor",sb)end)coc.MouseButton1Click:Connect(function()w.sp("Console",sb)end)exc.MouseButton1Click:Connect(function()w.sp("Extra",sb)end)sl.MouseButton1Click:Connect(function()w.hd()end)end se()sbt()sn()w.sp("Editor",sb)spawn(function()task.wait(1)w.al("FrostWare Console initialized","info")w.al("Console captures print(), warn(), and error() automatically","info")print("FrostWare V3 loaded successfully!")end)end)end
op,ow,oe=print,warn,error
print=function(...)local ar={...}local mg=""for i,v in ipairs(ar)do mg=mg..tostring(v)if i<#ar then mg=mg.." "end end if not ee then w.al(mg,"info")end op(...)end
warn=function(...)local ar={...}local mg=""for i,v in ipairs(ar)do mg=mg..tostring(v)if i<#ar then mg=mg.." "end end if not ee then w.al(mg,"warn")end ow(...)end
error=function(...)local ar={...}local mg=""for i,v in ipairs(ar)do mg=mg..tostring(v)if i<#ar then mg=mg.." "end end if not ee then w.al(mg,"error")end oe(...)end
ls.MessageOut:Connect(function(msg,mt)if not ee then if mt==Enum.MessageType.MessageError then w.al(msg,"error")elseif mt==Enum.MessageType.MessageWarning then w.al(msg,"warn")elseif mt==Enum.MessageType.MessageInfo then w.al(msg,"info")else w.al(msg,"info")end end end)
local ifw=function()local ui,oc=w.cbu()spawn(function()while task.wait(1)do w.ut()end end)w.sh()w.iwa()oc.MouseButton1Click:Connect(function()w.sh()end)end
local function optimizar()
    local ws = game:GetService("Workspace")
    settings().Rendering.QualityLevel = "Level01"
    if ws.Terrain then
        ws.Terrain.WaterWaveSize = 0
        ws.Terrain.WaterWaveSpeed = 0
        ws.Terrain.WaterReflectance = 0
        ws.Terrain.WaterTransparency = 1
    end
    local lt = game:GetService("Lighting")
    if lt then
        lt.GlobalShadows = false
        lt.FogEnd = 9e9
    end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Smoke") or v:IsA("Fire") then
            v:Destroy()
        elseif v:IsA("Decal") then
            v.Transparency = 1
        elseif v:IsA("Sound") then
            v.Volume = 0
        elseif v:IsA("BasePart") then
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end
    end
end
local function setupAntiAFK()
    local vu = game:GetService("VirtualUser")
    local rs = game:GetService("RunService")
    local lastAntiAFKSimTime = tick()

    lp.Idled:Connect(function()
        setthreadidentity(2)
        pcall(function()
            vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
            vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
        end)
        setthreadidentity(7)
    end)

    for _,v in ipairs(getconnections(lp.Idled)) do
        pcall(function()
            if islclosure(v.Function) or isexecutorclosure(v.Function) then
                v:Disable()
            end
        end)
    end

    rs.Heartbeat:Connect(function()
        if aaf1 then
            local currentTime = tick()
            if currentTime - lastAntiAFKSimTime > 10 then
                setthreadidentity(2)
                pcall(function()
                    vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
                    vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
                end)
                setthreadidentity(7)
                lastAntiAFKSimTime = currentTime
            end
        end
    end)
end
spawn(function()
    local ui = fw.gu()
    local extraPage = wsafe(ui["11"], "ExtraPage", 5)
    if extraPage then
        pcall(function()
            uep1()
        end)
    else
        fw.sa("Error", "ExtraPage no encontrada después del tiempo de espera!", 5)
    end
end)
spawn(function()
    while task.wait() do
        if not lp or not lp.Character then task.wait() continue end
        if lp.Character and lp.Character:FindFirstChild("Humanoid") then
            for _,track in pairs(lp.Character.Humanoid:GetPlayingAnimationTracks()) do
                if track.Speed~=ani1 then
                    track:AdjustSpeed(ani1)
                end
            end
        end
        if ncp1 and lp.Character then
            for _,part in pairs(lp.Character:GetChildren()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide=false
                end
            end
        end
        if frz1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            if not lp.Character.HumanoidRootPart.Anchored then
                lp.Character.HumanoidRootPart.Anchored=true
            end
        end
        if gra1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
            if not lp.Character.HumanoidRootPart:FindFirstChild("BodyVelocity") then
                local bv=ci1("BodyVelocity",lp.Character.HumanoidRootPart)
                bv.MaxForce=Vector3.new(4000,4000,4000)
                bv.Velocity=Vector3.new(0,0,0)
            end
        end
        if esp1 then
            local ps=gsafe("Players",3)
            if ps then
                for _,p in pairs(ps:GetPlayers()) do
                    if p~=lp and p.Character and not ec1[p] then
                        cep1(p)
                    end
                end
            end
        end
    end
end)
lp.CharacterAdded:Connect(function()
    task.wait(1)
    if ncp1 then
        spawn(function()
            while ncp1 and lp.Character do
                for _,part in pairs(lp.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide=false
                    end
                end
                task.wait()
            end
        end)
    end
    if frz1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        lp.Character.HumanoidRootPart.Anchored=true
    end
    if gra1 and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
        local bv=ci1("BodyVelocity",lp.Character.HumanoidRootPart)
        bv.MaxForce=Vector3.new(4000,4000,4000)
        bv.Velocity=Vector3.new(0,0,0)
    end
    if ani1~=1 and lp.Character and lp.Character:FindFirstChild("Humanoid") then
        lp.Character.Humanoid.AnimationPlayed:Connect(function(track)
            track:AdjustSpeed(ani1)
        end)
    end
end)
fw=w
ifw()
optimizar()
setupAntiAFK()
