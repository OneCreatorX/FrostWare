local FW = {}

_e=getgenv()._e or{}
getgenv()._e=_e
_e.fn=function(f)return f end
_e.v=function(x)return x end
_e.sref=function(n)return cloneref(game:GetService(n))end
_e.s=function(c,p)return Instance.new(c,p)end
_e.c=function(o,props)for k,v in pairs(props)do o[k]=v end return o end
_e.cr=function(t,p,props)return _e.c(_e.s(t,p),props)end
_e.pr=function(...)print(...)end
_e.w=function(t)wait(t)end

local rs,lp,ws,ts,ms,cs,uis,ls=_e.sref("RunService"),_e.sref("Players").LocalPlayer,workspace,_e.sref("TweenService"),_e.sref("MarketplaceService"),_e.sref("CoreGui"),_e.sref("UserInputService"),_e.sref("LogService")

local g={}
local n=_e.s
local c=_e.c
local cr=_e.cr

local cF=_e.fn(function(p,props)return cr("Frame",p,props)end)
local cT=_e.fn(function(p,props)return cr("TextLabel",p,props)end)
local cB=_e.fn(function(p,props)return cr("TextButton",p,props)end)
local cTB=_e.fn(function(p,props)return cr("TextBox",p,props)end)
local cI=_e.fn(function(p,props)return cr("ImageLabel",p,props)end)
local cIB=_e.fn(function(p,props)return cr("ImageButton",p,props)end)
local cSF=_e.fn(function(p,props)return cr("ScrollingFrame",p,props)end)

local cG=_e.fn(function(p,c1,c2,r)return c(n("UIGradient",p),{Rotation=r or 90,Color=ColorSequence.new{ColorSequenceKeypoint.new(0,c1),ColorSequenceKeypoint.new(1,c2)}})end)
local cC=_e.fn(function(p,r)return c(n("UICorner",p),{CornerRadius=UDim.new(r or 0,0)})end)
local cS=_e.fn(function(p,t,col)return c(n("UIStroke",p),{Thickness=t,Color=col,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})end)
local cTC=_e.fn(function(p,max)return c(n("UITextSizeConstraint",p),{MaxTextSize=max})end)
local cAR=_e.fn(function(p,ratio)return c(n("UIAspectRatioConstraint",p),{AspectRatio=ratio})end)

local tabs = {}
local curTab = 1
local tabCnt = 1
local tabsDir = "FrostWare/Tabs/"
local srcRef = nil
local lnRef = nil

local cStdBtn=_e.fn(function(p,nm,txt,ico,pos,sz)
    local btn=cF(p,{BackgroundColor3=Color3.fromRGB(255,255,255),Size=sz,Position=pos,Name=nm})
    cC(btn,0.2)
    cG(btn,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))
    local lbl=cT(btn,{TextWrapped=true,TextSize=28,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(29,29,38),BackgroundTransparency=1,Size=UDim2.new(0.617,0,0.337,0),Text=txt,Name="Lbl",Position=UDim2.new(0.276,0,0.348,0)})
    cTC(lbl,28)
    cI(btn,{ScaleType=Enum.ScaleType.Fit,Image=ico,Size=UDim2.new(0.098,0,0.36,0),BackgroundTransparency=1,Name="Ico",Position=UDim2.new(0.101,0,0.326,0)})
    local clk=cB(btn,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Name="Clk",Text="  "})
    cC(clk,0)
    cTC(clk,14)
    return clk
end)

local cRndBtn=_e.fn(function(p,nm,ico,pos,sz)
    local btn=cF(p,{ZIndex=2,BackgroundColor3=Color3.fromRGB(255,255,255),Size=sz,Position=pos,Name=nm})
    cC(btn,1)
    cI(btn,{ZIndex=2,ScaleType=Enum.ScaleType.Fit,Image=ico,Size=UDim2.new(0.296,0,0.361,0),BackgroundTransparency=1,Name="Ico",Position=UDim2.new(0.352,0,0.315,0)})
    cG(btn,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))
    local clk=cB(btn,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,ZIndex=3,Size=UDim2.new(1,0,1,0),Name="Clk",Text="  "})
    cC(clk,0)
    cTC(clk,14)
    cAR(btn,1)
    return clk
end)

local cSBtn=_e.fn(function(p,nm,txt,ico,pos,sel)
    local btn=cF(p,{BackgroundColor3=sel and Color3.fromRGB(30,36,51)or Color3.fromRGB(31,34,50),Size=UDim2.new(0.714,0,0.088,0),Position=pos,Name=nm,BackgroundTransparency=sel and 0 or 1})
    cC(btn,0.18)
    local box=cF(btn,{ZIndex=sel and 2 or 0,BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(0.167,0,0.629,0),Position=UDim2.new(0.093,0,0.2,0),Name="Box"})
    cC(box,0.24)
    cAR(box,0.982)
    if sel then cG(box,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))else cG(box,Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63))end
    cI(box,{ZIndex=sel and 2 or 0,ScaleType=Enum.ScaleType.Fit,Image=ico,Size=UDim2.new(0.527,0,sel and 0.571 or 0.5,0),BackgroundTransparency=1,Name="Ico",Position=UDim2.new(0.236,0,sel and 0.232 or 0.25,0)})
    local lbl=cT(btn,{TextWrapped=true,TextSize=32,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Size=UDim2.new(sel and 0.248 or 0.359,0,0.36,0),Text=txt,Name="Lbl",Position=UDim2.new(0.379,0,0.348,0)})
    cTC(lbl,32)
    local clk=cB(btn,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Name="Clk",Text="  "})
    cC(clk,0)
    cTC(clk,14)
    return btn,clk
end)

function FW.saveTabs()
    if not isfolder(tabsDir) then makefolder(tabsDir) end
    local tabData = {}
    for id, tab in pairs(tabs) do
        tabData[tostring(id)] = {
            name = tab.name,
            content = tab.content,
            id = tab.id
        }
    end
    tabData.currentTab = curTab
    tabData.tabCounter = tabCnt
    writefile(tabsDir .. "tabs.json", game:GetService("HttpService"):JSONEncode(tabData))
end

function FW.loadTabs()
    if isfile(tabsDir .. "tabs.json") then
        local success, data = pcall(function()
            return game:GetService("HttpService"):JSONDecode(readfile(tabsDir .. "tabs.json"))
        end)
        if success and data then
            curTab = data.currentTab or 1
            tabCnt = data.tabCounter or 1
            for id, tabInfo in pairs(data) do
                if type(tabInfo) == "table" and tabInfo.name then
                    tabs[tonumber(id)] = {
                        name = tabInfo.name,
                        content = tabInfo.content,
                        id = tabInfo.id,
                        button = nil,
                        closeButton = nil
                    }
                end
            end
            return true
        end
    end
    return false
end

function FW.cStdBtn(p,nm,txt,ico,pos,sz)return cStdBtn(p,nm,txt,ico,pos,sz)end
function FW.cRndBtn(p,nm,ico,pos,sz)return cRndBtn(p,nm,ico,pos,sz)end
function FW.cF(p,props)return cF(p,props)end
function FW.cT(p,props)return cT(p,props)end
function FW.cB(p,props)return cB(p,props)end
function FW.cTB(p,props)return cTB(p,props)end
function FW.cI(p,props)return cI(p,props)end
function FW.cSF(p,props)return cSF(p,props)end
function FW.cG(p,c1,c2,r)return cG(p,c1,c2,r)end
function FW.cC(p,r)return cC(p,r)end
function FW.cS(p,t,col)return cS(p,t,col)end
function FW.cTC(p,max)return cTC(p,max)end
function FW.cAR(p,ratio)return cAR(p,ratio)end

function FW.cBaseUI()
g["1"]=c(n("ScreenGui",cs.RobloxGui),{IgnoreGuiInset=true,DisplayOrder=999999999,ScreenInsets=Enum.ScreenInsets.None,Name="FW",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ResetOnSpawn=false})
g["2"]=cI(g["1"],{BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(255,255,255),Image="rbxassetid://102455275740647",Size=UDim2.new(1,0,1,0),Visible=false,Position=UDim2.new(0,0,-0.007,0)})
g["3"]=cF(g["1"],{Visible=false,BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(16,19,27),ClipsDescendants=true,Size=UDim2.new(0.964,0,0.936,0),Position=UDim2.new(0.018,0,0.031,0),Name="UI"})
cC(g["3"],0.04)
cS(g["3"],10,Color3.fromRGB(35,39,54))
g["6"]=c(n("Folder",g["3"]),{Name="Main"})
g["7"]=cI(g["6"],{ZIndex=6,ImageColor3=Color3.fromRGB(36,42,60),Image="rbxassetid://133620562515152",Size=UDim2.new(0.314,0,0.185,0),Visible=false,ClipsDescendants=true,BackgroundTransparency=1,Name="Alert",Position=UDim2.new(0.398,0,0.074,0)})
local at=cT(g["7"],{TextWrapped=true,LineHeight=0,TextSize=31,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Size=UDim2.new(0.505,0,0.175,0),Text="FrostWare Notification",Position=UDim2.new(0.147,0,0.21,0)})
cTC(at,31)
local am=cT(g["7"],{TextWrapped=true,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(162,177,234),BackgroundTransparency=1,Size=UDim2.new(0.45,0,0.321,0),Text="Message content",Name="MSG",Position=UDim2.new(0.148,0,0.449,0)})
cTC(am,23)
local ai=cI(g["7"],{ZIndex=2,Image="rbxassetid://107516337694688",Size=UDim2.new(0.031,0,0.54,0),BackgroundTransparency=1,Position=UDim2.new(0.059,0,0.21,0)})
cG(ai,Color3.fromRGB(166,190,255),Color3.fromRGB(121,152,207),91.1)
cI(g["7"],{ImageColor3=Color3.fromRGB(16,19,27),Image="rbxassetid://82022759470861",Size=UDim2.new(0.067,0,0.941,0),BackgroundTransparency=1,Name="Shd",Position=UDim2.new(0.036,0,0,0)})
cIB(g["7"],{Image="rbxassetid://88951128464748",Size=UDim2.new(0.05,0,0.16,0),BackgroundTransparency=1,Name="Ico",Position=UDim2.new(0.84,0,0.396,0)})
cI(g["6"],{ZIndex=22,ImageColor3=Color3.fromRGB(16,19,27),Image="rbxassetid://102023075611323",Size=UDim2.new(0.019,0,1,0),BackgroundTransparency=1,Name="Shd",Position=UDim2.new(0.254,0,0,0)})
g["11"]=cI(g["6"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://76734110237026",Size=UDim2.new(0.745,0,1,0),ClipsDescendants=true,BackgroundTransparency=1,Name="Pages",Position=UDim2.new(0.255,0,0,0)})
local openBtn=cI(g["1"],{Image="rbxassetid://132133828845126",Size=UDim2.new(0.116,0,0.208,0),Visible=false,BackgroundTransparency=1,Name="OpenBtn",Position=UDim2.new(0.442,0,0.045,0)})
cC(openBtn,0)
cI(openBtn,{ScaleType=Enum.ScaleType.Fit,ImageColor3=Color3.fromRGB(255,255,255),Image="rbxassetid://102761807757832",Size=UDim2.new(0.221,0,0.244,0),BackgroundTransparency=1,Position=UDim2.new(0.388,0,0.367,0)})
local openClk=cB(openBtn,{TextColor3=Color3.fromRGB(0,0,0),TextSize=14,BackgroundTransparency=1,ZIndex=6,Size=UDim2.new(0.441,0,0.427,0),Name="OpenClk",Text="  ",Position=UDim2.new(0.279,0,0.284,0)})
cC(openClk,0)
c(n("Folder",g["6"]),{Name="Alerts"})
return g, openClk
end

function FW.cSidebar()
local sb=cI(g["6"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://133862668499122",Size=UDim2.new(0.25,0,1,0),BackgroundTransparency=1,Name="Sidebar"})
local ub=cF(sb,{BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(0.61,0,0.088,0),Position=UDim2.new(0.192,0,0.826,0),Name="UpBtn"})
cC(ub,0.18)
cG(ub,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))
local ubl=cT(ub,{TextWrapped=true,TextSize=28,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(29,29,38),BackgroundTransparency=1,Size=UDim2.new(0.581,0,0.36,0),Text="Upgrade Plan",Name="UpLbl",Position=UDim2.new(0.312,0,0.326,0)})
cTC(ubl,28)
cI(ub,{ScaleType=Enum.ScaleType.Fit,Image="rbxassetid://110667923648139",Size=UDim2.new(0.142,0,0.36,0),BackgroundTransparency=1,Name="UpIco",Position=UDim2.new(0.106,0,0.303,0)})
local ubClk=cB(ub,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Name="UpClk",Text=""})
cC(ubClk,0)
cTC(ubClk,14)
local ed,edClk=cSBtn(sb,"Editor","Editor","rbxassetid://94595204123047",UDim2.new(0.088,0,0.186,0),true)
local cl,clClk=cSBtn(sb,"Cloud","Cloud","rbxassetid://93729735363108",UDim2.new(0.088,0,0.285,0),false)
local co,coClk=cSBtn(sb,"Console","Console","rbxassetid://107390243416427",UDim2.new(0.088,0,0.384,0),false)
local ex,exClk=cSBtn(sb,"Extra","Extra","rbxassetid://128679881757557",UDim2.new(0.088,0,0.483,0),false)
local logo=cI(sb,{ScaleType=Enum.ScaleType.Fit,Image="rbxassetid://102761807757832",Size=UDim2.new(0.145,0,0.069,0),BackgroundTransparency=1,Name="Logo",Position=UDim2.new(0.141,0,0.067,0)})
cC(logo,0)
local close=cI(sb,{ZIndex=2,ImageColor3=Color3.fromRGB(34,41,58),Image="rbxassetid://124705542662472",Size=UDim2.new(0.13,0,1,0),BackgroundTransparency=1,Name="Close",Position=UDim2.new(0.891,0,0,0)})
local slide=cB(close,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,0.189,0),Name="Slide",Text="  ",Position=UDim2.new(0,0,0.43,0)})
cTC(slide,14)
return sb,ubClk,edClk,clClk,coClk,exClk,slide
end

function FW.cEditor()
local ep=cI(g["11"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://76734110237026",Size=UDim2.new(1.001,0,1,0),ClipsDescendants=true,BackgroundTransparency=1,Name="EditorPage",Position=UDim2.new(-0.001,0,0,0)})
local tb=cF(ep,{BackgroundColor3=Color3.fromRGB(20,23,30),Size=UDim2.new(1,0,0.08,0),Position=UDim2.new(0,0,0,0),Name="TabBar"})
cC(tb,0)
local ts=cSF(tb,{BackgroundTransparency=1,Size=UDim2.new(0.85,0,1,0),Position=UDim2.new(0,0,0,0),Name="TabScroll",ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0)})
c(n("UIListLayout",ts),{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)})
local addTab=cB(tb,{BackgroundColor3=Color3.fromRGB(30,36,51),Size=UDim2.new(0.08,0,0.8,0),Position=UDim2.new(0.9,0,0.1,0),Text="+",TextColor3=Color3.fromRGB(255,255,255),TextSize=24,Name="AddTab"})
cC(addTab,0.2)
local epp=cI(ep,{ImageColor3=Color3.fromRGB(32,39,57),Image="rbxassetid://136761835814725",Size=UDim2.new(1.001,0,0.756,0),ClipsDescendants=true,BackgroundTransparency=1,Name="EditorPage",Position=UDim2.new(-0.001,0,0.08,0)})
local txtBox=cF(epp,{BackgroundColor3=Color3.fromRGB(24,24,32),Size=UDim2.new(1,0,0.687,0),Position=UDim2.new(0,0,0.054,0),Name="TxtBox",BackgroundTransparency=0.9})
local ef=cSF(txtBox,{ElasticBehavior=Enum.ElasticBehavior.Always,TopImage="rbxassetid://148970562",MidImage="rbxassetid://148970562",VerticalScrollBarInset=Enum.ScrollBarInset.Always,BackgroundColor3=Color3.fromRGB(32,31,32),Name="EditorFrame",ScrollBarImageTransparency=1,HorizontalScrollBarInset=Enum.ScrollBarInset.Always,BottomImage="rbxassetid://148970562",Size=UDim2.new(1,0,1,0),ScrollBarImageColor3=Color3.fromRGB(38,40,46),ScrollBarThickness=10,BackgroundTransparency=1})
local src=cTB(ef,{CursorPosition=-1,Name="Source",TextXAlignment=Enum.TextXAlignment.Left,PlaceholderColor3=Color3.fromRGB(205,205,205),ZIndex=3,TextWrapped=true,TextTransparency=0,TextSize=23,TextColor3=Color3.fromRGB(255,255,255),TextYAlignment=Enum.TextYAlignment.Top,RichText=false,FontFace=Font.new("rbxassetid://11702779409",Enum.FontWeight.Medium,Enum.FontStyle.Normal),MultiLine=true,ClearTextOnFocus=false,ClipsDescendants=true,Size=UDim2.new(0.7,0,2,0),Position=UDim2.new(0.08,0,0,0),Text="-- FrostWare V2 Editor\nprint('Hello World!')",BackgroundTransparency=1})
local ln=cT(ef,{TextWrapped=true,TextSize=25,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,BackgroundColor3=Color3.fromRGB(32,31,32),FontFace=Font.new("rbxassetid://11702779409",Enum.FontWeight.Regular,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(193,191,235),BackgroundTransparency=1,Size=UDim2.new(0.05,0,2,0),Text="1",Position=UDim2.new(0.021,0,-0.003,0)})
cTC(ln,25)
cC(ef)
local btns=cI(ep,{ZIndex=2,ImageColor3=Color3.fromRGB(16,19,27),Image="rbxassetid://123590482033481",Size=UDim2.new(1.001,0,0.161,0),ClipsDescendants=true,BackgroundTransparency=1,Name="Btns",Position=UDim2.new(-0.001,0,0.836,0)})
local execBtn=cStdBtn(btns,"Exec","Execute Script","rbxassetid://89434276213036",UDim2.new(0.043,0,0.37,0),UDim2.new(0.15,0,0.325,0))
local clrBtn=cStdBtn(btns,"Clr","Clear Editor","rbxassetid://73909411554012",UDim2.new(0.2,0,0.37,0),UDim2.new(0.15,0,0.325,0))
local pstBtn=cStdBtn(btns,"Pst","Paste Clipboard","rbxassetid://133018045821797",UDim2.new(0.36,0,0.37,0),UDim2.new(0.15,0,0.325,0))
local execClpBtn=cStdBtn(btns,"ExecClp","Execute Clipboard","rbxassetid://89434276213036",UDim2.new(0.52,0,0.37,0),UDim2.new(0.15,0,0.325,0))
srcRef = src
lnRef = ln
return ep,src,ln,ts,addTab,execBtn,clrBtn,pstBtn,execClpBtn
end

function FW.updLines(src,ln)
if src and src.Text then
local lines=src.Text:split("\n")
local txt=""
for i=1,#lines do txt=txt..tostring(i)if i<#lines then txt=txt.."\n"end end
if ln then ln.Text=txt end
end
end

function FW.cTab(ts,nm,cont)
local td={name=nm or "Tab "..tabCnt,content=cont or "-- New Tab\nprint('Hello from "..(nm or "Tab "..tabCnt).."!')",id=tabCnt}
local tb=cB(ts,{BackgroundColor3=Color3.fromRGB(30,36,51),Size=UDim2.new(0,120,0.8,0),Position=UDim2.new(0,0,0.1,0),Text=td.name,TextColor3=Color3.fromRGB(255,255,255),TextSize=18,Name="Tab"..td.id,TextScaled=true})
cC(tb,0.2)
local cb=cB(tb,{BackgroundColor3=Color3.fromRGB(200,100,100),Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-25,0,5),Text="×",TextColor3=Color3.fromRGB(255,255,255),TextSize=16,Name="CloseBtn"})
cC(cb,0.5)
td.button=tb
td.closeButton=cb
tabs[td.id]=td
ts.CanvasSize=UDim2.new(0,ts.UIListLayout.AbsoluteContentSize.X,0,0)
tabCnt=tabCnt+1
FW.saveTabs()
return td.id,tb,cb
end

function FW.switchTab(tid)
if tabs[tid] then
if tabs[curTab] and srcRef then 
tabs[curTab].content=srcRef.Text 
end
for _,tab in pairs(tabs)do 
if tab.button then 
tab.button.BackgroundColor3=Color3.fromRGB(30,36,51)
end 
end
curTab=tid
if tabs[tid].button then 
tabs[tid].button.BackgroundColor3=Color3.fromRGB(50,56,71)
end
if srcRef then 
srcRef.Text=tabs[tid].content
FW.updLines(srcRef,lnRef)
end
FW.saveTabs()
return true
end
return false
end

function FW.closeTab(tid,ts)
local cnt=0
for _ in pairs(tabs)do cnt=cnt+1 end
if cnt<=1 then return false end
if tabs[tid] then
if tabs[tid].button then tabs[tid].button:Destroy()end
tabs[tid]=nil
if curTab==tid then 
for id,_ in pairs(tabs)do 
curTab=id 
FW.switchTab(id)
break 
end 
end
ts.CanvasSize=UDim2.new(0,ts.UIListLayout.AbsoluteContentSize.X,0,0)
FW.saveTabs()
return true
end
return false
end

function FW.renameTab(tid,nm)
if tabs[tid] then
tabs[tid].name=nm
if tabs[tid].button then tabs[tid].button.Text=nm end
FW.saveTabs()
return true
end
return false
end

function FW.showAlert(title,msg,dur)
local alert=g["7"]:Clone()
local alerts=g["6"]:FindFirstChild("Alerts")
if alerts then
alert.Parent=alerts
alert.Visible=true
alert.Name="Alert_"..tick()
alert:FindFirstChild("MSG").Text=msg
alert:FindFirstChild("TextLabel").Text=title
local tw=ts:Create(alert,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.398,0,0.074,0)})
tw:Play()
spawn(function()
wait(dur or 3)
local fo=ts:Create(alert,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0.398,0,-0.3,0)})
fo:Play()
fo.Completed:Connect(function()alert:Destroy()end)
end)
end
end

function FW.switchPage(pn,sb)
for _,pg in pairs(g["11"]:GetChildren())do if pg:IsA("ImageLabel")then pg.Visible=false end end
for _,btn in pairs(sb:GetChildren())do
if btn:IsA("Frame")and btn.Name~="UpBtn"and btn.Name~="TimeBarFrame"then
btn.BackgroundTransparency=1
local box=btn:FindFirstChild("Box")
if box then box.UIGradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(66,79,113)),ColorSequenceKeypoint.new(1,Color3.fromRGB(36,44,63))}end
end
end
local po=g["11"]:FindFirstChild(pn.."Page")
if po then
po.Visible=true
local sbb=sb:FindFirstChild(pn)
if sbb then
sbb.BackgroundTransparency=0
local box=sbb:FindFirstChild("Box")
if box then box.UIGradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(166,190,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(93,117,160))}end
end
end
end

function FW.restoreTabs(ts)
if FW.loadTabs() then
for id, tab in pairs(tabs) do
if tab.name and tab.content then
local tb=cB(ts,{BackgroundColor3=Color3.fromRGB(30,36,51),Size=UDim2.new(0,120,0.8,0),Position=UDim2.new(0,0,0.1,0),Text=tab.name,TextColor3=Color3.fromRGB(255,255,255),TextSize=18,Name="Tab"..id,TextScaled=true})
cC(tb,0.2)
local cb=cB(tb,{BackgroundColor3=Color3.fromRGB(200,100,100),Size=UDim2.new(0,20,0,20),Position=UDim2.new(1,-25,0,5),Text="×",TextColor3=Color3.fromRGB(255,255,255),TextSize=16,Name="CloseBtn"})
cC(cb,0.5)
tabs[id].button=tb
tabs[id].closeButton=cb
end
end
ts.CanvasSize=UDim2.new(0,ts.UIListLayout.AbsoluteContentSize.X,0,0)
return true
end
return false
end

function FW.getUI()return g end
function FW.getCurTab()return curTab end
function FW.getTabs()return tabs end
function FW.show()
if g["3"] then g["3"].Visible=true end
if g["2"] then g["2"].Visible=true end
local ob=g["1"]:FindFirstChild("OpenBtn")
if ob then ob.Visible=false end
end
function FW.hide()
if g["3"] then g["3"].Visible=false end
if g["2"] then g["2"].Visible=false end
local ob=g["1"]:FindFirstChild("OpenBtn")
if ob then ob.Visible=true end
end

return FW
