local ed=(e and e:FindFirstChild("Page-Editor"))or addTab("Editor","https://raw.githubusercontent.com/encharm/Font-Awesome-SVG-PNG/master/black/png/64/code.png")
local DIR="editor_tabs"
if not isfolder(DIR)then makefolder(DIR)end
local ICON_DIR="fw_icons"
if not isfolder(ICON_DIR)then makefolder(ICON_DIR)end
local TweenService=game:GetService("TweenService")
local function httpget(u)local ok,body=pcall(function()if syn and syn.request then local r=syn.request({Url=u,Method="GET"})return r.Body end;if request then local r=request({Url=u,Method="GET"})return r.Body end;return game:HttpGet(u)end)return ok and body or "" end
local function toAsset(p)local a=""pcall(function()if getcustomasset then a=getcustomasset(p)elseif getsynasset then a=getsynasset(p)else a="rbxasset://"..p end end)return a end
local function ensureIcon(name,url)local p=ICON_DIR.."/"..name..".fwtex"if not isfile(p)then local b=httpget(url)pcall(function()writefile(p,b)end)end;return toAsset(p),p end
local PRIMARY=Color3.fromRGB(120,95,205)
local PRIMARY_ACTIVE=Color3.fromRGB(95,75,175)
local PRIMARY_LIGHT=Color3.fromRGB(155,130,245)
local BTN_TEXT=Color3.new(1,1,1)
local K=Color3.new(0,0,0)
local W=Color3.new(1,1,1)
local MARGIN=0.03
local HEADER_H=0.09
local GAP_H=0.02
local BAR_H=0.10
local contentXScale=1-(MARGIN*2)
local headerY=MARGIN
local editorY=MARGIN+HEADER_H+GAP_H
local barY=1-MARGIN-BAR_H
local editorH=1-(editorY+BAR_H+MARGIN)
local function fpath(n)return DIR.."/"..n..".lua"end
local function savefile(n,tx)pcall(function()writefile(fpath(n),tx or "")end)end
local function loadfiletxt(n)local ok,tx=pcall(function()if isfile(fpath(n))then return readfile(fpath(n))else return "" end end)return ok and tx or "" end
local function mkbtn(p,n,t,sz,ps,zi,fn)local b=Instance.new("TextButton")b.Parent=p;b.Name=n;b.BorderSizePixel=0;b.BackgroundColor3=PRIMARY;b.TextColor3=BTN_TEXT;b.Text=t;b.TextSize=13;b.Font=Enum.Font.SourceSans;b.Size=sz or UDim2.new(0,120,0,36);b.Position=ps or UDim2.new(0,0,0,0);b.BackgroundTransparency=0;b.ZIndex=zi or 1;b.TextXAlignment=Enum.TextXAlignment.Center;b.TextYAlignment=Enum.TextYAlignment.Center;local uc=Instance.new("UICorner")uc.Parent=b;uc.CornerRadius=UDim.new(0.7,0);local st=Instance.new("UIStroke")st.Parent=b;st.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;st.Thickness=1;if fn then b.MouseButton1Click:Connect(fn)end;return b end
local function mkimgbtn(parent,name,asset,sz,ps,zi,fn,circle)local b=Instance.new("ImageButton")b.Parent=parent;b.Name=name;b.BackgroundColor3=Color3.fromRGB(0,0,0);b.BorderSizePixel=0;b.BackgroundTransparency=1;b.Size=sz or UDim2.new(0,120,0,36);b.Position=ps or UDim2.new(0,0,0,0);b.ZIndex=zi or 1;b.Image=asset;b.ScaleType=Enum.ScaleType.Fit;b.AutoButtonColor=false;if circle then local uc=Instance.new("UICorner")uc.Parent=b;uc.CornerRadius=UDim.new(1,0)end;if fn then b.MouseButton1Click:Connect(fn)end;return b end
local function attachPressFeedback(btn)local us=Instance.new("UIScale")us.Parent=btn;us.Scale=1;local tiIn=TweenInfo.new(0.06,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)local tiOut=TweenInfo.new(0.08,Enum.EasingStyle.Quad,Enum.EasingDirection.Out)local function down()TweenService:Create(us,tiIn,{Scale=0.94}):Play()end;local function up()TweenService:Create(us,tiOut,{Scale=1}):Play()end;btn.MouseButton1Down:Connect(down)btn.MouseButton1Up:Connect(up)btn.MouseLeave:Connect(up)btn.TouchEnded:Connect(up)end
local toastLayer=ed:FindFirstChild("ToastLayer")or(function()local f=Instance.new("Frame")f.Name="ToastLayer"f.Parent=ed;f.ZIndex=3000;f.BackgroundTransparency=1;f.Size=UDim2.new(1,0,1,0);f.Position=UDim2.new(0,0,0,0)return f end)()
local function notify(txt)local w=math.max(120,#txt*7+20)local f=Instance.new("Frame")f.Parent=toastLayer;f.ZIndex=3001;f.BackgroundColor3=Color3.fromRGB(20,20,20)f.BackgroundTransparency=1;f.Size=UDim2.new(0,w,0,28)f.Position=UDim2.new(1,-(w+12),0,2)local c=Instance.new("UICorner")c.Parent=f;c.CornerRadius=UDim.new(0.3,0)local l=Instance.new("TextLabel")l.Parent=f;l.BackgroundTransparency=1;l.Size=UDim2.new(1,0,1,0)l.Position=UDim2.new(0,0,0,0)l.Font=Enum.Font.SourceSansSemibold;l.TextColor3=BTN_TEXT;l.TextSize=13;l.TextXAlignment=Enum.TextXAlignment.Center;l.TextYAlignment=Enum.TextYAlignment.Center;l.Text=txt;l.TextTransparency=1;TweenService:Create(f,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=0.25,Position=UDim2.new(1,-(w+12),0,8)}):Play()TweenService:Create(l,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=0}):Play()task.delay(0.9,function()TweenService:Create(f,TweenInfo.new(0.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{BackgroundTransparency=1,Position=UDim2.new(1,-(w+12),0,0)}):Play()TweenService:Create(l,TweenInfo.new(0.12,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{TextTransparency=1}):Play()task.delay(0.18,function()f:Destroy()end)end)end
local tabs={}
local cur="Main"
local mainContent=""
local hdr=Instance.new("Frame")hdr.Parent=ed;hdr.Name="EdTabs";hdr.BorderSizePixel=0;hdr.BackgroundColor3=Color3.new(1,1,1);hdr.BackgroundTransparency=1;hdr.Size=UDim2.new(contentXScale,0,HEADER_H,0);hdr.Position=UDim2.new(MARGIN,0,headerY,0)local huc=Instance.new("UICorner")huc.Parent=hdr;huc.CornerRadius=UDim.new(0.18,0)local hus=Instance.new("UIStroke")hus.Parent=hdr;hus.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;hus.Thickness=1
local hll=Instance.new("UIListLayout")hll.Parent=hdr;hll.FillDirection=Enum.FillDirection.Horizontal;hll.HorizontalAlignment=Enum.HorizontalAlignment.Left;hll.VerticalAlignment=Enum.VerticalAlignment.Center;hll.Padding=UDim.new(0,6);hll.SortOrder=Enum.SortOrder.LayoutOrder
local bx=ed:FindFirstChild("EditorBox")
if not bx then bx=Instance.new("TextBox")bx.Parent=ed;bx.Name="EditorBox";bx.BorderSizePixel=0;bx.BackgroundColor3=Color3.fromRGB(40,40,48);bx.BackgroundTransparency=0;bx.Size=UDim2.new(contentXScale,0,editorH,0);bx.Position=UDim2.new(MARGIN,0,editorY,0);bx.TextColor3=W;bx.TextSize=15;bx.TextWrapped=true;bx.MultiLine=true;bx.ClearTextOnFocus=false;bx.Font=Enum.Font.SourceSans;local buc=Instance.new("UICorner")buc.Parent=bx;buc.CornerRadius=UDim.new(0.06,0)else bx.Size=UDim2.new(contentXScale,0,editorH,0)bx.Position=UDim2.new(MARGIN,0,editorY,0)end
local function findConsoleOut()local pc=e and e:FindFirstChild("Page-Console")if not pc then return nil end;local candidates={"ConsoleOut","Output","Out"}for _,name in ipairs(candidates)do local obj=pc:FindFirstChild(name,true)if obj and obj:IsA("TextBox")then return obj end end;for _,ch in ipairs(pc:GetDescendants())do if ch:IsA("TextBox")then return ch end end;return nil end
local function consoleWrite(line,kind)local tag="["..(kind or "info").."] "local msg=tag..tostring(line)if typeof(rconsoleprint)=="function"then pcall(function()rconsoleprint(msg.."\n")end)end;print(msg)local out=findConsoleOut()if out then local sep=((out.Text or "")~="")and"\n"or"";out.Text=(out.Text or "")..sep..msg;if out.CursorPosition then out.CursorPosition=#out.Text+1 end end end
local function restyle()for n,t in pairs(tabs)do local a=(n==cur)if t.sel then t.sel.Visible=a end;if t.l then t.l.TextTransparency=a and 0 or 0.25 end end end
local function selectTab(name)cur=name;if name=="Main"then bx.Text=mainContent or""else bx.Text=loadfiletxt(name)end;restyle()end
local ord=1
local function mkTab(name)local px=math.max(62,(#name*8)+(name~="Main"and 34 or 22)+20)local hold=Instance.new("Frame")hold.Parent=hdr;hold.Name="T-"..name;hold.BorderSizePixel=0;hold.BackgroundColor3=PRIMARY;hold.BackgroundTransparency=1;hold.Size=UDim2.new(0,px,1,0);hold.ZIndex=2;hold.LayoutOrder=ord;ord=ord+1;local huc=Instance.new("UICorner")huc.Parent=hold;huc.CornerRadius=UDim.new(0.8,0)local hus=Instance.new("UIStroke")hus.Parent=hold;hus.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;hus.Thickness=0
local lab=Instance.new("TextLabel")lab.Parent=hold;lab.Name="L";lab.Text=name;lab.TextSize=13;lab.TextColor3=BTN_TEXT;lab.Font=Enum.Font.SourceSans;lab.BorderSizePixel=0;lab.BackgroundTransparency=1;lab.Size=UDim2.new(1,0,1,0);lab.Position=UDim2.new(0,0,0,0);lab.TextXAlignment=Enum.TextXAlignment.Center;lab.TextYAlignment=Enum.TextYAlignment.Center;lab.TextTransparency=0.25
local hit=Instance.new("TextButton")hit.Parent=hold;hit.Name="Hit";hit.BorderSizePixel=0;hit.BackgroundTransparency=1;hit.Text="";hit.TextSize=1;hit.Font=Enum.Font.SourceSans;hit.Size=UDim2.new(1,0,1,0);hit.Position=UDim2.new(0,0,0,0);hit.ZIndex=3;hit.MouseButton1Click:Connect(function()selectTab(name)end)
local sel=Instance.new("Frame")sel.Parent=hold;sel.Name="Sel";sel.BorderSizePixel=0;sel.BackgroundColor3=PRIMARY_LIGHT;sel.BackgroundTransparency=0;sel.Size=UDim2.new(1,0,0,3);sel.Position=UDim2.new(0,0,1,-3);sel.ZIndex=4;sel.Visible=false;local suc=Instance.new("UICorner")suc.Parent=sel;suc.CornerRadius=UDim.new(1,0)
local close=nil
if name~="Main"then close=Instance.new("TextButton")close.Parent=hold;close.Name="X";close.BorderSizePixel=0;close.BackgroundTransparency=1;close.TextColor3=BTN_TEXT;close.Text="X";close.TextSize=12;close.Font=Enum.Font.SourceSans;close.Size=UDim2.new(0,16,0,16);close.Position=UDim2.new(1,-22,0,7);close.ZIndex=5;close.MouseButton1Click:Connect(function()if tabs[name]then if cur==name then cur="Main"selectTab("Main")end;pcall(function()if isfile(fpath(name))then delfile(fpath(name))end end)tabs[name]=nil;hold:Destroy()restyle()notify("Tab closed")end end)end
tabs[name]={h=hold,l=lab,x=close,sel=sel}
return hold end
local ov2=Instance.new("Frame")ov2.Parent=ed;ov2.Name="EdAddOv";ov2.Visible=false;ov2.ZIndex=999;ov2.BorderSizePixel=0;ov2.BackgroundColor3=K;ov2.BackgroundTransparency=0.35;ov2.Size=UDim2.new(1,0,1,0);ov2.Position=UDim2.new(0,0,0,0)
local blk=Instance.new("TextButton")blk.Parent=ov2;blk.Name="Block";blk.BorderSizePixel=0;blk.BackgroundTransparency=1;blk.Size=UDim2.new(1,0,1,0);blk.Position=UDim2.new(0,0,0,0);blk.ZIndex=999;blk.Text=""
local pv=Instance.new("Frame")pv.Parent=ov2;pv.Name="EdAddPv";pv.BorderSizePixel=0;pv.BackgroundColor3=Color3.fromRGB(96,96,104);pv.BackgroundTransparency=0;pv.Size=UDim2.new(0,300,0,140);pv.Position=UDim2.new(0.5,-150,0.5,-70);pv.ZIndex=1000;local pvc=Instance.new("UICorner")pvc.Parent=pv;pvc.CornerRadius=UDim.new(0.24,0);local pvs=Instance.new("UIStroke")pvs.Parent=pv;pvs.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;pvs.Thickness=1
local nb=Instance.new("TextBox")nb.Parent=pv;nb.Name="NameBox";nb.BorderSizePixel=0;nb.BackgroundColor3=Color3.fromRGB(180,180,190);nb.BackgroundTransparency=0;nb.Size=UDim2.new(0.86,0,0,34);nb.Position=UDim2.new(0.07,0,0.22,0);nb.TextColor3=W;nb.TextSize=15;nb.TextWrapped=false;nb.MultiLine=false;nb.ClearTextOnFocus=false;nb.Font=Enum.Font.SourceSans;local nbc=Instance.new("UICorner")nbc.Parent=nb;nbc.CornerRadius=UDim.new(0.24,0)
nb:GetPropertyChangedSignal("Text"):Connect(function()local t=nb.Text or"";if #t>12 then nb.Text=t:sub(1,12)end end)
local okBtn=mkbtn(pv,"OK","OK",UDim2.new(0,112,0,32),UDim2.new(0.07,0,0.68,0),1001,function()local name=(nb.Text or"Tab"):gsub("[%c%p%s]","")if name==""then name="Tab" end;if name=="Main"then ov2.Visible=false return end;if not tabs[name]then mkTab(name)savefile(name,"")end;selectTab(name)ov2.Visible=false;notify("Tab created")end)
local cxBtn=mkbtn(pv,"CX","X",UDim2.new(0,112,0,32),UDim2.new(0.59,0,0.68,0),1001,function()ov2.Visible=false end)
attachPressFeedback(okBtn)attachPressFeedback(cxBtn)
local addAsset=ensureIcon("add_tab","https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/icons/add%20tab.jpg")
local plus=mkimgbtn(hdr,"Plus",addAsset,UDim2.new(0,28,0,28),UDim2.new(0,0,0,0),2147480000,function()nb.Text=""ov2.Visible=true;notify("Add tab")end,true)
plus.LayoutOrder=2147480000
attachPressFeedback(plus)
blk.MouseButton1Click:Connect(function()ov2.Visible=false end)
local function scanAndBuild()local ok,files=pcall(function()return listfiles(DIR)end)if ok and files then for _,f in ipairs(files)do local filename=f:match("[^/\\]+$")or f;local name=filename:gsub("%.lua$","")if name~=""and name~="Main"then if not tabs[name]then mkTab(name)end end end end end
mkTab("Main")tabs["Main"].h.LayoutOrder=0;ord=1;scanAndBuild();selectTab("Main")
bx:GetPropertyChangedSignal("Text"):Connect(function()if cur=="Main"then mainContent=bx.Text or""else savefile(cur,bx.Text or "")end end)
local bar=Instance.new("Frame")bar.Parent=ed;bar.Name="EdBar";bar.BorderSizePixel=0;bar.BackgroundColor3=Color3.new(1,1,1);bar.BackgroundTransparency=1;bar.Size=UDim2.new(contentXScale,0,BAR_H,0);bar.Position=UDim2.new(MARGIN,0,barY,0);local buc=Instance.new("UICorner")buc.Parent=bar;buc.CornerRadius=UDim.new(0.16,0);local bus=Instance.new("UIStroke")bus.Parent=bar;bus.ApplyStrokeMode=Enum.ApplyStrokeMode.Border;bus.Thickness=1
local bl=Instance.new("UIListLayout")bl.Parent=bar;bl.FillDirection=Enum.FillDirection.Horizontal;bl.Padding=UDim.new(0,10);bl.HorizontalAlignment=Enum.HorizontalAlignment.Center;bl.VerticalAlignment=Enum.VerticalAlignment.Center
local function addBarImg(name,asset,onClick)local b=mkimgbtn(bar,name,asset,UDim2.new(0.22,0,0,36),UDim2.new(0,0,0,0),1,onClick,false)attachPressFeedback(b)return b end
local function runCode(code)if not code or code==""then return end;local fn,cerr=loadstring(code)if not fn then consoleWrite(cerr or"Compile error","error")return end;local env=setmetatable({},{__index=getfenv()})env.print=function(...)local parts={}for i=1,select("#",...)do parts[i]=tostring(select(i,...))end;consoleWrite(table.concat(parts,"\t"),"print")end;setfenv(fn,env)local ok,rerr=xpcall(fn,function(er)return debug.traceback(er,2)end)if not ok then consoleWrite(rerr,"error")end end
local icExec=ensureIcon("Execute","https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/icons/Execute.jpg")
local icClear=ensureIcon("Clear","https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/icons/Clear.jpg")
local icPaste=ensureIcon("Paste","https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/icons/Paste.jpg")
local icExecCb=ensureIcon("ExecClip","https://raw.githubusercontent.com/OneCreatorX/FrostWare/refs/heads/main/icons/Executer%20clipboard.jpg")
addBarImg("Exec",icExec,function()runCode(bx.Text or "")notify("Executed")end)
addBarImg("Clear",icClear,function()bx.Text=""notify("Cleared")end)
addBarImg("Paste",icPaste,function()local s=(getclipboard and getclipboard())or"";if #s>0 then bx.Text=s notify("Pasted")else notify("Clipboard empty")end end)
addBarImg("ExecClip",icExecCb,function()local s=(getclipboard and getclipboard())or"";runCode(s)notify("Executed from clipboard")end)
