addTab("Editor","https://img.icons8.com/ios-filled/100/ffffff/edit-file.png",function(page)
if not T.sf then T.sf="ScrollingFrame" end
local DIR="fw_editor_tabs"
if not isfolder(DIR) then makefolder(DIR) end
local function sanitizeName(s)
s=tostring(s or ""):gsub("[^%w%-%._%s]","_"):gsub("%s+","-")
if s=="" then s="script" end
return s
end
local function pathFor(name)
return DIR.."/"..sanitizeName(name)..".lua"
end
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
local editorWrap=x("fr",sc,{bs=0,bc=C.w,bt=1,sz=u(1,0,0,540),ps=u(0,0,0,0),ci=true})
local editorBox=x("fr",editorWrap,{bs=0,bc=C.g2,bt=0,sz=u(1,0,1,0),ps=u(0,0,0,0)})
x("uc",editorBox,{cr=D(0.12,0)})
x("us",editorBox,{ar=E.a,th=1,Color=C.st})
local lineCol=x("fr",editorBox,{bs=0,bc=C.w,bt=1,sz=u(0.06,0,1,0),ps=u(0,0,0,0)})
local lineLabel=x("tl",lineCol,{txw=true,tfx=E.lx,tfy=E.ly,txs=16,ft=F(R..A.i,E.r,E.n),tc=C.t2,bt=1,sz=u(1,-6,1,-12),ps=u(0,6,0,6),tx="",RichText=false})
local editFrame=x("sf",editorBox,{bs=0,bc=C.w,bt=1,sz=u(0.94,0,1,0),ps=u(0.06,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Both,ScrollBarImageTransparency=0.6})
editFrame.Active=true
editFrame.ScrollBarThickness=8
local code=x("TextBox",editFrame,{ClearTextOnFocus=false,MultiLine=true,TextEditable=true,TextWrapped=false,RichText=false,CursorPosition=-1,tx="",txs=18,tc=C.w,bt=1,bc=C.g2,sz=u(1,-24,0,0),ps=u(0,12,0,0),tfx=E.lx,tfy=E.ly,ft=F(R..A.i,E.r,E.n)})
local sxFolder=Instance.new("Folder")
sxFolder.Name="SyntaxHighlights"
sxFolder.Parent=code
local tabs={}
local current=nil
local switching=false
local saveGen=0
local function scheduleSave()
if not current or current.isMain then return end
local my=saveGen+1
saveGen=my
task.delay(0.4,function()
if my~=saveGen then return end
if current.path then pcall(function() writefile(current.path,current.text or "") end) end
end)
end
local function updateLines()
local t=code.Text or ""
local c=1
for _ in string.gmatch(t,"\n") do c+=1 end
local b={}
for i=1,c do b[i]=tostring(i) end
lineLabel.Text=table.concat(b,"\n")
end
code:GetPropertyChangedSignal("Text"):Connect(function()
if switching then return end
updateLines()
if current then current.text=code.Text or "" scheduleSave() end
end)
local function mkTabChip(name,isMain)
local cap=x("fr",tabsBar,{bs=0,bc=C.w,bt=0,sz=u(0,180,1,0)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
local lbl=x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-70,1,-16),ps=u(0,12,0,8),tx=name})
local sel=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",sel,{cr=D(0,18)})
local del=nil
if not isMain then
del=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(0,46,0,26),ps=u(1,-52,0.5,-13),bd=C.k,tx="×"})
x("uc",del,{cr=D(0,10)})
end
return cap,sel,lbl,del
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
updateLines()
end
local function confirmDelete(name,onYes)
local overlay=x("fr",sc,{bs=0,bc=C.k,bt=0.4,sz=u(1,0,1,0),ps=u(0,0,0,0),zi=50})
local modal=x("fr",overlay,{bs=0,bc=C.g2,bt=0,sz=u(0,420,0,180),ps=u(0.5,-210,0.5,-90)})
x("uc",modal,{cr=D(0.14,0)})
x("us",modal,{ar=E.a,th=1,Color=C.st})
x("tl",modal,{txw=true,tfx=E.lx,tfy=E.ly,txs=20,ft=F(R..A.i,E.s,E.n),tc=C.w,bt=1,sz=u(1,-24,0,26),ps=u(0,12,0,12),tx="Delete Tab: "..name})
x("tl",modal,{txw=true,tfx=E.lx,tfy=E.ly,txs=16,ft=F(R..A.i,E.r,E.n),tc=C.t2,bt=1,sz=u(1,-24,0,46),ps=u(0,12,0,44),tx="Are you sure? This cannot be undone.",AutomaticSize=Enum.AutomaticSize.Y})
local row=x("fr",modal,{bs=0,bc=C.w,bt=1,sz=u(1,-24,0,44),ps=u(0,12,1,-56)})
local rl=Instance.new("UIListLayout")
rl.Parent=row
rl.FillDirection=Enum.FillDirection.Horizontal
rl.HorizontalAlignment=Enum.HorizontalAlignment.Center
rl.SortOrder=Enum.SortOrder.LayoutOrder
rl.Padding=D(0,10)
local function mkMini(label,accent)
local cap=x("fr",row,{bs=0,bc=C.w,bt=0,sz=u(0,180,1,0)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=accent or s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-24,1,-16),ps=u(0,12,0,8),tx=label})
local btn=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",btn,{cr=D(0,18)})
return btn
end
local cancel=mkMini("Cancel",s(r(48,58,81),r(37,45,62)))
local del=mkMini("Delete")
y(cancel,function() overlay:Destroy() end)
y(del,function() overlay:Destroy() if onYes then onYes() end end)
end
local function closeTab(key)
local t=tabs[key]
if not t or t.isMain then return end
confirmDelete(key,function()
if t.path and isfile(t.path) then pcall(function() delfile(t.path) end) end
if t.cap then t.cap:Destroy() end
tabs[key]=nil
if current==t then selectTab("Main") end
end)
end
local function ensureUniqueName(name)
local base=name
local i=1
while tabs[name] or isfile(pathFor(name)) do
i+=1
name=base.."-"..i
end
return name
end
local function mkPrompt(titleText,placeholder,okText,cancelText,cb)
local overlay=x("fr",sc,{bs=0,bc=C.k,bt=0.4,sz=u(1,0,1,0),ps=u(0,0,0,0),zi=50})
local modal=x("fr",overlay,{bs=0,bc=C.g2,bt=0,sz=u(0,420,0,200),ps=u(0.5,-210,0.5,-100)})
x("uc",modal,{cr=D(0.14,0)})
x("us",modal,{ar=E.a,th=1,Color=C.st})
x("tl",modal,{txw=true,tfx=E.lx,tfy=E.ly,txs=20,ft=F(R..A.i,E.s,E.n),tc=C.w,bt=1,sz=u(1,-24,0,26),ps=u(0,12,0,12),tx=titleText})
local input=x("TextBox",modal,{ClearTextOnFocus=false,MultiLine=false,TextEditable=true,TextWrapped=false,RichText=false,CursorPosition=-1,tx="",txs=16,tc=C.w,bt=0,bc=C.g1,sz=u(1,-24,0,38),ps=u(0,12,0,52),tfx=E.lx,tfy=E.ly,ft=F(R..A.i,E.r,E.n),PlaceholderText=placeholder})
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
local cap=x("fr",row,{bs=0,bc=C.w,bt=0,sz=u(0,180,1,0)})
x("uc",cap,{cr=D(0.18,0)})
x("ug",cap,{rt=90,Color=s(r(166,190,255),r(93,117,160))})
x("us",cap,{ar=E.a,th=1,Color=C.st})
x("tl",cap,{txw=true,tfx=E.lx,tfy=E.ly,txs=18,ft=F(R..A.i,E.s,E.n),tc=C.t1,bt=1,sz=u(1,-24,1,-16),ps=u(0,12,0,8),tx=label})
local btn=x("tb",cap,{txw=true,bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=u(1,0,1,0),bt=1,bd=C.k,tx=""})
x("uc",btn,{cr=D(0,18)})
return btn
end
local ok=mkMini(okText or "Create")
local cancel=mkMini(cancelText or "Cancel")
y(ok,function()
local raw=input.Text
if cb then cb(raw) end
overlay:Destroy()
end)
y(cancel,function() overlay:Destroy() end)
input:CaptureFocus()
end
local function createTab(name,content,isMain)
name=ensureUniqueName(name)
local cap,sel,lbl,del=mkTabChip(name,isMain)
local t={name=name,text=content or "",path=isMain and nil or pathFor(name),cap=cap,sel=sel,lbl=lbl,del=del,isMain=isMain and true or false}
tabs[name]=t
y(sel,function() selectTab(name) end)
if del then y(del,function() closeTab(name) end) end
if not isMain and t.path and not isfile(t.path) then pcall(function() writefile(t.path,t.text or "") end) end
if not current then selectTab(name) end
return t
end
local function loadExisting()
local list={}
pcall(function() if listfiles then list=listfiles(DIR) or {} end end)
table.sort(list,function(a,b) return a<b end)
for _,fp in ipairs(list) do
local n=fp:match("([^/\\]+)%.lua$")
if n then
local content=""
pcall(function() content=readfile(fp) end)
createTab(n,content,false)
end
end
end
createTab("Main","",true)
loadExisting()
y(btnNew,function()
mkPrompt("Create New Tab","Tab Name","Create","Cancel",function(raw)
local safe=sanitizeName(raw~="" and raw or "Script")
local t=createTab(safe,"",false)
selectTab(t.name)
end)
end)
y(btnDel,function()
if not current or current.isMain then return end
closeTab(current.name)
end)
local function executeCode(src)
local f,err=loadstring(src)
if f then pcall(f) end
end
y(btnRun,function()
executeCode(code.Text or "")
end)
local getcb=getclipboard or (syn and syn.clipboard and syn.clipboard.get) or nil
y(btnClip,function()
if not getcb then return end
local ok,src=pcall(function() return getcb() end)
if ok and type(src)=="string" then executeCode(src) end
end)
y(btnClr,function()
switching=true
code.Text=""
switching=false
if current then current.text="" scheduleSave() end
end)
local function HighlighterFactory()
local Utility={}
function Utility.sanitizeRichText(s) return string.gsub(string.gsub(string.gsub(string.gsub(string.gsub(s,"&","&amp;"),"<","&lt;"),">","&gt;"),'"',"&quot;"),"'","&apos;") end
function Utility.convertTabsToSpaces(s) return string.gsub(s,"\t","    ") end
function Utility.removeControlChars(s) return string.gsub(s,"[\0\1\2\3\4\5\6\7\8\11\12\13\14\15\16\17\18\19\20\21\22\23\24\25\26\27\28\29\30\31]+","") end
function Utility.getInnerAbsoluteSize(textObject)
local fullSize=textObject.AbsoluteSize
local padding=textObject:FindFirstChildWhichIsA("UIPadding")
if padding then
local offsetX=padding.PaddingLeft.Offset+padding.PaddingRight.Offset
local scaleX=(fullSize.X*padding.PaddingLeft.Scale)+(fullSize.X*padding.PaddingRight.Scale)
local offsetY=padding.PaddingTop.Offset+padding.PaddingBottom.Offset
local scaleY=(fullSize.Y*padding.PaddingTop.Scale)+(fullSize.Y*padding.PaddingBottom.Scale)
return Vector2.new(fullSize.X-(scaleX+offsetX),fullSize.Y-(scaleY+offsetY))
else
return fullSize
end
end
function Utility.getTextBounds(textObject)
if textObject.ContentText=="" then return Vector2.zero end
local textBounds=textObject.TextBounds
while (textBounds.Y~=textBounds.Y) or (textBounds.Y<1) do task.wait() textBounds=textObject.TextBounds end
return textBounds
end
local Theme={}
local DEFAULT_TOKEN_COLORS={
background=Color3.fromRGB(40,42,54),
iden=Color3.fromRGB(150,171,193),
keyword=Color3.fromRGB(102,102,219),
builtin=Color3.fromRGB(100,149,237),
string=Color3.fromRGB(136,167,181),
number=Color3.fromRGB(161,138,205),
comment=Color3.fromRGB(88,88,99),
operator=Color3.fromRGB(103,116,238),
custom=Color3.fromRGB(87,87,226)
}
Theme.tokenColors={}
for k,v in pairs(DEFAULT_TOKEN_COLORS) do Theme.tokenColors[k]=v end
function Theme.getColoredRichText(color,text) return '<font color="#'..color:ToHex()..'">'..text.."</font>" end
function Theme.getColor(tokenName) return Theme.tokenColors[tokenName] end
local language={keyword={["and"]=true,["break"]=true,["continue"]=true,["do"]=true,["else"]=true,["elseif"]=true,["end"]=true,["export"]=true,["false"]=true,["for"]=true,["function"]=true,["if"]=true,["in"]=true,["local"]=true,["nil"]=true,["not"]=true,["or"]=true,["repeat"]=true,["return"]=true,["self"]=true,["then"]=true,["true"]=true,["type"]=true,["typeof"]=true,["until"]=true,["while"]=true,},builtin={["assert"]=true,["error"]=true,["ipairs"]=true,["loadstring"]=true,["next"]=true,["pairs"]=true,["pcall"]=true,["print"]=true,["rawequal"]=true,["rawget"]=true,["rawlen"]=true,["rawset"]=true,["select"]=true,["setmetatable"]=true,["tonumber"]=true,["tostring"]=true,["unpack"]=true,["xpcall"]=true,["collectgarbage"]=true,["require"]=true,["settings"]=true,["spawn"]=true,["tick"]=true,["time"]=true,["wait"]=true,["warn"]=true,["game"]=true,["workspace"]=true,["math"]=true,["string"]=true,["table"]=true,["os"]=true,["coroutine"]=true,["utf8"]=true,["Color3"]=true,["Instance"]=true,["Enum"]=true,["Vector2"]=true,["Vector3"]=true,["UDim2"]=true,["CFrame"]=true,},libraries={}}
local lexer={}
local Prefix,Suffix,Cleaner="^[%c%s]*","[%c%s]*","[%c%s]+"
local UNICODE="[%z\x01-\x7F\xC2-\xF4][\x80-\xBF]+"
local NUMBER_A="0[xX][%da-fA-F_]+"
local NUMBER_B="0[bB][01_]+"
local NUMBER_C="%d+%.?%d*[eE][%+%-]?%d+"
local NUMBER_D="%d+[%._]?[%d_eE]*"
local OPERATORS="[:;<>/~%*%(%)%-={},%.#%^%+%%]+"
local BRACKETS="[%[%]]+"
local IDEN="[%a_][%w_]*"
local STRING_EMPTY="(['\"])%1"
local STRING_PLAIN="(['\"])[^\n]-([^\\]%1)"
local STRING_INTER="`[^\n]-`"
local STRING_INCOMP_A="(['\"]).-\n"
local STRING_INCOMP_B="(['\"])[^\n]*"
local STRING_MULTI="%[(=*)%[.-%]%1%]"
local STRING_MULTI_INCOMP="%[=*%[.-.*"
local COMMENT_MULTI="%-%-%[(=*)%[.-%]%1%]"
local COMMENT_MULTI_INCOMP="%-%-%[=*%[.-.*"
local COMMENT_PLAIN="%-%-.-\n"
local COMMENT_INCOMP="%-%-.*"
local lua_matches={
{Prefix..IDEN..Suffix,"var"},
{Prefix..NUMBER_A..Suffix,"number"},
{Prefix..NUMBER_B..Suffix,"number"},
{Prefix..NUMBER_C..Suffix,"number"},
{Prefix..NUMBER_D..Suffix,"number"},
{Prefix..STRING_EMPTY..Suffix,"string"},
{Prefix..STRING_PLAIN..Suffix,"string"},
{Prefix..STRING_INCOMP_A..Suffix,"string"},
{Prefix..STRING_INCOMP_B..Suffix,"string"},
{Prefix..STRING_MULTI..Suffix,"string"},
{Prefix..STRING_MULTI_INCOMP..Suffix,"string"},
{Prefix..STRING_INTER..Suffix,"string_inter"},
{Prefix..COMMENT_MULTI..Suffix,"comment"},
{Prefix..COMMENT_MULTI_INCOMP..Suffix,"comment"},
{Prefix..COMMENT_PLAIN..Suffix,"comment"},
{Prefix..COMMENT_INCOMP..Suffix,"comment"},
{Prefix..OPERATORS..Suffix,"operator"},
{Prefix..BRACKETS..Suffix,"operator"},
{Prefix..UNICODE..Suffix,"iden"},
{"^.","iden"},
}
local PATTERNS,TOKENS={},{}
for i,m in ipairs(lua_matches) do PATTERNS[i]=m[1] TOKENS[i]=m[2] end
lexer.language=language
function lexer.scan(s)
local index,size=1,#s
local previousContent1,previousContent2,previousContent3,previousToken="","","",""
local thread=coroutine.create(function()
while index<=size do
local matched=false
for tokenType,pattern in ipairs(PATTERNS) do
local start,finish=string.find(s,pattern,index)
if start==nil then continue end
index=finish+1
matched=true
local content=string.sub(s,start,finish)
local rawToken=TOKENS[tokenType]
local processedToken=rawToken
if rawToken=="var" then
local cleanContent=string.gsub(content,Cleaner,"")
if language.keyword[cleanContent] then
processedToken="keyword"
elseif language.builtin[cleanContent] then
processedToken="builtin"
elseif string.find(previousContent1,"%.[%s%c]*$") and previousToken~="comment" then
processedToken="iden"
else
processedToken="iden"
end
elseif rawToken=="string_inter" then
processedToken="string"
end
previousContent3=previousContent2
previousContent2=previousContent1
previousContent1=content
previousToken=processedToken or rawToken
if processedToken then coroutine.yield(processedToken,content) end
break
end
if not matched then return end
end
return
end)
return function()
if coroutine.status(thread)=="dead" then return end
local success,token,content=coroutine.resume(thread)
if success and token then return token,content end
return
end
end
local Highlighter={}
Highlighter._textObjectData={}
Highlighter._cleanups={}
Highlighter.defaultLexer=lexer
local function getLabelingInfo(textObject)
local data=Highlighter._textObjectData[textObject]
if not data then return end
local src=Utility.convertTabsToSpaces(Utility.removeControlChars(textObject.Text))
local numLines=#string.split(src,"\n")
if numLines==0 then return end
local textBounds=Utility.getTextBounds(textObject)
local textHeight=textBounds.Y/numLines
return{
data=data,
numLines=numLines,
textBounds=textBounds,
textHeight=textHeight,
innerAbsoluteSize=Utility.getInnerAbsoluteSize(textObject),
textColor=Theme.getColor("iden"),
textFont=textObject.FontFace,
textSize=textObject.TextSize,
labelSize=UDim2.new(1,0,0,math.ceil(textHeight)),
}
end
local function alignLabels(textObject)
local labelingInfo=getLabelingInfo(textObject)
if not labelingInfo then return end
for lineNumber,lineLabel in labelingInfo.data.Labels do
lineLabel.TextColor3=labelingInfo.textColor
lineLabel.FontFace=labelingInfo.textFont
lineLabel.TextSize=labelingInfo.textSize
lineLabel.Size=labelingInfo.labelSize
lineLabel.Position=UDim2.fromScale(0,labelingInfo.textHeight*(lineNumber-1)/labelingInfo.innerAbsoluteSize.Y)
end
end
local function populateLabels(props)
local textObject=props.textObject
local src=Utility.convertTabsToSpaces(Utility.removeControlChars(props.src or textObject.Text))
local lexerInst=props.lexer or Highlighter.defaultLexer
local customLang=props.customLang
local forceUpdate=props.forceUpdate
local data=Highlighter._textObjectData[textObject]
if (data==nil) or (data.Text==src) then if forceUpdate~=true then return end end
textObject.Text=src
local lineLabels=data.Labels
local previousLines=data.Lines
local lines=string.split(src,"\n")
data.Lines=lines
data.Text=src
data.Lexer=lexerInst
data.CustomLang=customLang
if src=="" then
for l=1,#lineLabels do if lineLabels[l].Text~="" then lineLabels[l].Text="" end end
return
end
local idenColor=Theme.getColor("iden")
local labelingInfo=getLabelingInfo(textObject)
local richTextBuffer,bufferIndex,lineNumber={},0,1
for token,content in lexerInst.scan(src) do
local Color=(customLang and customLang[content]) and Theme.getColor("custom") or (Theme.getColor(token) or idenColor)
local tokenLines=string.split(Utility.sanitizeRichText(content),"\n")
for l,tokenLine in ipairs(tokenLines) do
local lineLabel=lineLabels[lineNumber]
if not lineLabel then
local newLabel=Instance.new("TextLabel")
newLabel.Name="Line_"..lineNumber
newLabel.AutoLocalize=false
newLabel.RichText=true
newLabel.BackgroundTransparency=1
newLabel.Text=""
newLabel.TextXAlignment=Enum.TextXAlignment.Left
newLabel.TextYAlignment=Enum.TextYAlignment.Top
newLabel.TextColor3=labelingInfo.textColor
newLabel.FontFace=labelingInfo.textFont
newLabel.TextSize=labelingInfo.textSize
newLabel.Size=labelingInfo.labelSize
newLabel.Position=UDim2.fromScale(0,labelingInfo.textHeight*(lineNumber-1)/labelingInfo.innerAbsoluteSize.Y)
newLabel.Parent=textObject.SyntaxHighlights
lineLabels[lineNumber]=newLabel
lineLabel=newLabel
end
if l>1 then
if forceUpdate or lines[lineNumber]~=previousLines[lineNumber] then
lineLabels[lineNumber].Text=table.concat(richTextBuffer)
end
lineNumber+=1
bufferIndex=0
table.clear(richTextBuffer)
end
if forceUpdate or lines[lineNumber]~=previousLines[lineNumber] then
bufferIndex+=1
if Color~=idenColor and string.find(tokenLine,"[%S%C]") then
richTextBuffer[bufferIndex]=Theme.getColoredRichText(Color,tokenLine)
else
richTextBuffer[bufferIndex]=tokenLine
end
end
end
end
if richTextBuffer[1] and lineLabels[lineNumber] then
lineLabels[lineNumber].Text=table.concat(richTextBuffer)
end
for l=lineNumber+1,#lineLabels do
if lineLabels[l].Text~="" then lineLabels[l].Text="" end
end
end
function Highlighter.highlight(props)
local textObject=props.textObject
local src=Utility.convertTabsToSpaces(Utility.removeControlChars(props.src or textObject.Text))
local lexerInst=props.lexer or Highlighter.defaultLexer
local customLang=props.customLang
if Highlighter._cleanups[textObject] then
populateLabels(props)
alignLabels(textObject)
return Highlighter._cleanups[textObject]
end
textObject.RichText=false
textObject.Text=src
textObject.TextXAlignment=Enum.TextXAlignment.Left
textObject.TextYAlignment=Enum.TextYAlignment.Top
textObject.BackgroundColor3=Theme.getColor("background")
textObject.TextColor3=Theme.getColor("iden")
textObject.TextTransparency=0.5
local lineFolder=textObject:FindFirstChild("SyntaxHighlights")
if not lineFolder then
local newLineFolder=Instance.new("Folder")
newLineFolder.Name="SyntaxHighlights"
newLineFolder.Parent=textObject
lineFolder=newLineFolder
end
local data={Text="",Labels={},Lines={},Lexer=lexerInst,CustomLang=customLang}
Highlighter._textObjectData[textObject]=data
local connections={}
local function cleanup()
if lineFolder then lineFolder:Destroy() end
Highlighter._textObjectData[textObject]=nil
Highlighter._cleanups[textObject]=nil
for _,c in pairs(connections) do c:Disconnect() end
end
Highlighter._cleanups[textObject]=cleanup
connections.AncestryChanged=textObject.AncestryChanged:Connect(function() if textObject.Parent then return end cleanup() end)
connections.TextChanged=textObject:GetPropertyChangedSignal("Text"):Connect(function() populateLabels(props) end)
connections.TextBoundsChanged=textObject:GetPropertyChangedSignal("TextBounds"):Connect(function() alignLabels(textObject) end)
connections.AbsoluteSizeChanged=textObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() alignLabels(textObject) end)
connections.FontFaceChanged=textObject:GetPropertyChangedSignal("FontFace"):Connect(function() alignLabels(textObject) end)
populateLabels(props)
alignLabels(textObject)
return cleanup
end
return {Highlighter=Highlighter}
end
local hl=HighlighterFactory().Highlighter
hl.highlight({textObject=code,forceUpdate=true,customLang={HttpGet="HttpGet",Players="Players",CoreGui="CoreGui"}})
local function syncCanvas()
editFrame.CanvasSize=UDim2.new(0,0,0,math.max(0,code.TextBounds.Y+24))
end
code:GetPropertyChangedSignal("TextBounds"):Connect(syncCanvas)
updateLines()
syncCanvas()
end)
