addTab("Editor","https://img.icons8.com/ios-filled/100/ffffff/edit-file.png",function(page)
if not T.sf then T.sf="ScrollingFrame" end
local DIR="fw_editor"
if not isfolder(DIR) then makefolder(DIR) end
local sc=x("sf",page,{bs=0,bc=C.w,bt=1,sz=u(1,0,1,0),ps=u(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y,ScrollBarImageTransparency=0.4})
sc.Active=true
sc.ScrollBarThickness=6
local pad=Instance.new("UIPadding")
pad.PaddingLeft=D(0,16) pad.PaddingRight=D(0,16) pad.PaddingTop=D(0,16) pad.PaddingBottom=D(0,16)
pad.Parent=sc
local layout=Instance.new("UIListLayout")
layout.Parent=sc
layout.FillDirection=Enum.FillDirection.Vertical
layout.HorizontalAlignment=Enum.HorizontalAlignment.Left
layout.SortOrder=Enum.SortOrder.LayoutOrder
layout.Padding=D(0,12)
local title=x("tl",sc,{txw=true,tfx=E.lx,tfy=E.ly,txs=28,ft=F(R..A.i,E.b,E.n),tc=C.w,bt=1,sz=u(1,0,0,36),ps=u(0,0,0,0),tx="Editor"})
local tabsBar=x("sf",sc,{bs=0,bc=C.w,bt=1,sz=u(1,0,0,56),ps=u(0,0,0,0),ScrollingDirection=Enum.ScrollingDirection.X,AutomaticCanvasSize=Enum.AutomaticSize.X,ScrollBarImageTransparency=1})
tabsBar.Active=true
tabsBar.ScrollBarThickness=0
local tabsLayout=Instance.new("UIListLayout")
tabsLayout.Parent=tabsBar
tabsLayout.FillDirection=Enum.FillDirection.Horizontal
tabsLayout.HorizontalAlignment=Enum.HorizontalAlignment.Left
tabsLayout.SortOrder=Enum.SortOrder.LayoutOrder
tabsLayout.Padding=D(0,10)
local actions=x("fr",sc,{bs=0,bc=C.w,bt=1,sz=u(1,0,0,60),ps=u(0,0,0,0)})
local al=Instance.new("UIListLayout")
al.Parent=actions
al.FillDirection=Enum.FillDirection.Horizontal
al.HorizontalAlignment=Enum.HorizontalAlignment.Left
al.VerticalAlignment=Enum.VerticalAlignment.Center
al.SortOrder=Enum.SortOrder.LayoutOrder
al.Padding=D(0,12)
local function mkAction(parent,label)
local cap=x("fr",parent,{bs=0,bc=C.w,bt=0,sz=u(0,164,0,44)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
local lbl=x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-24,1,-16),ps=u(0,12,0,8),tx=label})
local btn=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",btn,{cr=D(0,18)})
return cap,btn,lbl
end
local btnNewCap,btnNew=mkAction(actions,"New Tab")
local btnDelCap,btnDel=mkAction(actions,"Delete Tab")
local btnRunCap,btnRun=mkAction(actions,"Execute")
local btnClrCap,btnClr=mkAction(actions,"Clear")
local btnClipCap,btnClip=mkAction(actions,"Run Clipboard")
local editorBox=x("fr",sc,{bs=0,bc=C.g2,bt=0,sz=u(1,0,0,420),ps=u(0,0,0,0)})
x("uc",editorBox,{cr=D(0.12,0)})
x("us",editorBox,{ar=E.a,th=1,Color=C.st})
local code=x("TextBox",editorBox,{ClearTextOnFocus=false,MultiLine=true,TextEditable=true,TextWrapped=false,RichText=false,CursorPosition=-1,tx="",txs=16,tc=C.w,bt=1,bc=C.g2,sz=u(1,-24,1,-24),ps=u(0,12,0,12),tfx=E.lx,tfy=E.ly,ft=F(R..A.i,E.r,E.n)})
local tabs={}
local current=nil
local switching=false
local getcb=getclipboard or (syn and syn.clipboard and syn.clipboard.get) or (Clipboard and Clipboard.get)
local function sanitizeName(s)
s=tostring(s or ""):gsub("[^%w%-%._%s]","_")
s=s:gsub("%s+","-")
if s=="" then s="script" end
return s
end
local function fileFor(name)
local base=sanitizeName(name)
local path=DIR.."/"..base..".lua"
local idx=1
while isfile(path) do
idx=idx+1
path=DIR.."/"..base.."-"..idx..".lua"
end
return path
end
local function mkTabChip(name,isMain)
local cap=x("fr",tabsBar,{bs=0,bc=C.w,bt=0,sz=u(0,164,1,0)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
local lbl=x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-24,1,-16),ps=u(0,12,0,8),tx=name})
local btn=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",btn,{cr=D(0,18)})
return cap,btn,lbl
end
local saveGen=0
local function scheduleSave()
if not current then return end
if current.isMain then return end
local my=saveGen+1
saveGen=my
task.delay(0.5,function()
if my~=saveGen then return end
if current.path then
pcall(function() writefile(current.path,current.text or "") end)
end
end)
end
local function selectTab(key)
local t=tabs[key]
if not t then return end
for k,tab in pairs(tabs) do
tab.cap.BackgroundTransparency=(k==key) and 0 or 0.35
end
current=t
switching=true
code.Text=t.text or ""
switching=false
end
local function closeTab(key)
local t=tabs[key]
if not t then return end
if t.isMain then return end
if t.path and isfile(t.path) then pcall(function() delfile(t.path) end) end
if t.cap then t.cap:Destroy() end
tabs[key]=nil
if current==t then
if tabs["Main"] then selectTab("Main") else
for k,_ in pairs(tabs) do selectTab(k) break end
end
end
end
local function ensureUniqueName(name)
local base=name
local i=1
while tabs[name] do
i=i+1
name=base.."-"..i
end
return name
end
local function createTab(name,content,path,isMain)
name=ensureUniqueName(name)
local cap,btn,lbl=mkTabChip(name,isMain)
local t={name=name,text=content or "",path=path,cap=cap,btn=btn,lbl=lbl,isMain=isMain and true or false}
tabs[name]=t
y(btn,function() selectTab(name) end)
if not current then selectTab(name) end
return t
end
local function showNamePrompt(cb)
local overlay=x("fr",sc,{bs=0,bc=Color3.new(0,0,0),bt=0.4,sz=u(1,0,1,0),ps=u(0,0,0,0),zi=50})
local modal=x("fr",overlay,{bs=0,bc=C.g2,bt=0,sz=u(0,380,0,160),ps=u(0.5,-190,0.5,-80)})
x("uc",modal,{cr=D(0.14,0)})
x("us",modal,{ar=E.a,th=1,Color=C.st})
local label=x("tl",modal,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.w,bt=1,sz=u(1,-24,0,24),ps=u(0,12,0,12),tx="New tab name"})
local input=x("TextBox",modal,{ClearTextOnFocus=false,MultiLine=false,TextEditable=true,TextWrapped=false,RichText=false,CursorPosition=-1,tx="Script",txs=16,tc=C.w,bt=0,bc=C.g1,sz=u(1,-24,0,36),ps=u(0,12,0,44),tfx=E.lx,tfy=E.ly,ft=F(R..A.i,E.r,E.n)})
x("uc",input,{cr=D(0.12,0)})
x("us",input,{ar=E.a,th=1,Color=C.st})
local row=x("fr",modal,{bs=0,bc=C.w,bt=1,sz=u(1,-24,0,44),ps=u(0,12,1,-56)})
local rl=Instance.new("UIListLayout")
rl.Parent=row
rl.FillDirection=Enum.FillDirection.Horizontal
rl.HorizontalAlignment=Enum.HorizontalAlignment.Center
rl.SortOrder=Enum.SortOrder.LayoutOrder
rl.Padding=D(0,10)
local function mkMini(label)
local cap=x("fr",row,{bs=0,bc=C.w,bt=0,sz=u(0,160,1,0)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-24,1,-16),ps=u(0,12,0,8),tx=label})
local btn=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",btn,{cr=D(0,18)})
return btn
end
local ok=mkMini("Create")
local cancel=mkMini("Cancel")
y(ok,function()
local raw=input.Text or "Script"
cb(raw)
overlay:Destroy()
end)
y(cancel,function() overlay:Destroy() end)
input:CaptureFocus()
end
local function newTabFlow()
showNamePrompt(function(raw)
local safe=sanitizeName(raw)
local path=fileFor(safe)
pcall(function() writefile(path,"") end)
local t=createTab(safe,"",path,false)
selectTab(t.name)
end)
end
local function loadExisting()
local list={}
pcall(function()
if listfiles then list=listfiles(DIR) or {} end
end)
for _,fp in ipairs(list) do
local n=fp:match("([^/\\]+)%.%w+$")
if n then
local content=""
pcall(function() content=readfile(fp) end)
createTab(n,content,fp,false)
end
end
end
createTab("Main","",nil,true)
loadExisting()
y(btnNew,function() newTabFlow() end)
y(btnDel,function()
if not current or current.isMain then return end
closeTab(current.name)
end)
y(btnClr,function()
if not current then return end
switching=true
code.Text=""
switching=false
current.text=""
scheduleSave()
end)
y(btnRun,function()
if not current then return end
local src=code.Text or ""
pcall(function() local f=loadstring(src) if f then f() end end)
end)
y(btnClip,function()
if not getcb then return end
local ok,src=pcall(function() return getcb() end)
if ok and type(src)=="string" then pcall(function() local f=loadstring(src) if f then f() end end) end
end)
code:GetPropertyChangedSignal("Text"):Connect(function()
if switching or not current then return end
current.text=code.Text or ""
scheduleSave()
end)
end)
