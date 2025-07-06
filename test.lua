local FrostWareBase = {}

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
local pr=_e.pr

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

local editorTabs = {}
local currentTabIndex = 1
local tabCounter = 1

function FrostWareBase.createBaseUI()
    g["1"]=c(n("ScreenGui",cs.RobloxGui),{IgnoreGuiInset=true,DisplayOrder=999999999,ScreenInsets=Enum.ScreenInsets.None,Name="FW",ZIndexBehavior=Enum.ZIndexBehavior.Sibling,ResetOnSpawn=false})

    g["2"]=cI(g["1"],{BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(255,255,255),Image="rbxassetid://102455275740647",Size=UDim2.new(1,0,1,0),Visible=false,Position=UDim2.new(0,0,-0.00741,0)})

    g["3"]=cF(g["1"],{Visible=false,BorderSizePixel=0,BackgroundColor3=Color3.fromRGB(16,19,27),ClipsDescendants=true,Size=UDim2.new(0.96403,0,0.93611,0),Position=UDim2.new(0.01762,0,0.03138,0),Name="UI"})
    cC(g["3"],0.04)
    cS(g["3"],10,Color3.fromRGB(35,39,54))

    g["6"]=c(n("Folder",g["3"]),{Name="MainGui"})

    g["7"]=cI(g["6"],{ZIndex=6,ImageColor3=Color3.fromRGB(36,42,60),Image="rbxassetid://133620562515152",Size=UDim2.new(0.31368,0,0.18497,0),Visible=false,ClipsDescendants=true,BackgroundTransparency=1,Name="Alert",Position=UDim2.new(0.39798,0,0.07387,0)})

    local at=cT(g["7"],{TextWrapped=true,LineHeight=0,TextSize=31,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Size=UDim2.new(0.50517,0,0.17468,0),Text="FrostWare Notification",Position=UDim2.new(0.14655,0,0.21035,0)})
    cTC(at,31)

    local am=cT(g["7"],{TextWrapped=true,TextSize=23,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.SemiBold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(162,177,234),BackgroundTransparency=1,Size=UDim2.new(0.45,0,0.32086,0),Text="Message content",Name="TEXTLABEL",Position=UDim2.new(0.14828,0,0.4492,0)})
    cTC(am,23)

    local ai=cI(g["7"],{ZIndex=2,Image="rbxassetid://107516337694688",Size=UDim2.new(0.03103,0,0.54011,0),BackgroundTransparency=1,Position=UDim2.new(0.05852,0,0.21035,0)})
    cG(ai,Color3.fromRGB(166,190,255),Color3.fromRGB(121,152,207),91.10171)

    cI(g["7"],{ImageColor3=Color3.fromRGB(16,19,27),Image="rbxassetid://82022759470861",Size=UDim2.new(0.06724,0,0.94118,0),BackgroundTransparency=1,Name="ShadowBackk",Position=UDim2.new(0.03621,0,0,0)})
    cIB(g["7"],{Image="rbxassetid://88951128464748",Size=UDim2.new(0.05,0,0.16043,0),BackgroundTransparency=1,Name="Icon",Position=UDim2.new(0.83966,0,0.39572,0)})

    cI(g["6"],{ZIndex=22,ImageColor3=Color3.fromRGB(16,19,27),Image="rbxassetid://102023075611323",Size=UDim2.new(0.01947,0,1,0),BackgroundTransparency=1,Name="shadow",Position=UDim2.new(0.25403,0,0,0)})

    g["11"]=cI(g["6"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://76734110237026",Size=UDim2.new(0.74473,0,1,0),ClipsDescendants=true,BackgroundTransparency=1,Name="Pages",Position=UDim2.new(0.25499,0,0,0)})

    local openBtn=cI(g["1"],{Image="rbxassetid://132133828845126",Size=UDim2.new(0.11575,0,0.20833,0),Visible=false,BackgroundTransparency=1,Name="OpenBtn",Position=UDim2.new(0.44168,0,0.04537,0)})
    cC(openBtn,0)
    cI(openBtn,{ScaleType=Enum.ScaleType.Fit,ImageColor3=Color3.fromRGB(255,255,255),Image="rbxassetid://102761807757832",Size=UDim2.new(0.22072,0,0.24444,0),BackgroundTransparency=1,Position=UDim2.new(0.38762,0,0.36733,0)})
    local openClick=cB(openBtn,{TextColor3=Color3.fromRGB(0,0,0),TextSize=14,BackgroundTransparency=1,ZIndex=6,Size=UDim2.new(0.44144,0,0.42667,0),Name="OpenClick",Text="  ",Position=UDim2.new(0.27903,0,0.28444,0)})
    cC(openClick,0)

    local alerts=c(n("Folder",g["6"]),{Name="Alerts"})

    return g, openClick
end

function FrostWareBase.createSidebar()
    local sb=cI(g["6"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://133862668499122",Size=UDim2.new(0.24986,0,1,0),BackgroundTransparency=1,Name="Sidebar"})
    
    local ub=cF(sb,{BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(0.61039,0,0.08803,0),Position=UDim2.new(0.19229,0,0.82613,0),Name="UpgradeBtn"})
    cC(ub,0.18)
    cG(ub,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))
    local ubl=cT(ub,{TextWrapped=true,TextSize=28,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(29,29,38),BackgroundTransparency=1,Size=UDim2.new(0.58149,0,0.35955,0),Text="Upgrade Plan",Name="Upgrade Plan",Position=UDim2.new(0.31206,0,0.32584,0)})
    cTC(ubl,28)
    cI(ub,{ScaleType=Enum.ScaleType.Fit,Image="rbxassetid://110667923648139",Size=UDim2.new(0.14184,0,0.35955,0),BackgroundTransparency=1,Name="icons8-key-100 145",Position=UDim2.new(0.10638,0,0.30337,0)})
    local ubclk=cB(ub,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Name="Click",Text=""})
    cC(ubclk,0)
    cTC(ubclk,14)
    
    local cSBtn=_e.fn(function(name,text,icon,pos,selected)
        local btn=cF(sb,{BackgroundColor3=selected and Color3.fromRGB(30,36,51)or Color3.fromRGB(31,34,50),Size=UDim2.new(0.71429,0,0.08803,0),Position=pos,Name=name,BackgroundTransparency=selected and 0 or 1})
        cC(btn,0.18)
        local box=cF(btn,{ZIndex=selected and 2 or 0,BackgroundColor3=Color3.fromRGB(255,255,255),Size=UDim2.new(0.16667,0,0.62921,0),Position=UDim2.new(0.0927,0,0.2,0),Name="Box"})
        cC(box,0.24)
        cAR(box,0.98214)
        if selected then cG(box,Color3.fromRGB(166,190,255),Color3.fromRGB(93,117,160))else cG(box,Color3.fromRGB(66,79,113),Color3.fromRGB(36,44,63))end
        cI(box,{ZIndex=selected and 2 or 0,ScaleType=Enum.ScaleType.Fit,Image=icon,Size=UDim2.new(0.52727,0,selected and 0.57143 or 0.5,0),BackgroundTransparency=1,Name="Icon",Position=UDim2.new(0.23636,0,selected and 0.23214 or 0.25,0)})
        local lbl=cT(btn,{TextWrapped=true,TextSize=32,TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,FontFace=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(255,255,255),BackgroundTransparency=1,Size=UDim2.new(selected and 0.2479 or 0.35939,0,0.35955,0),Text=text,Name="Editor",Position=UDim2.new(0.37879,0,0.34831,0)})
        cTC(lbl,32)
        local clk=cB(btn,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Name="Click",Text="  "})
        cC(clk,0)
        cTC(clk,14)
        return btn,clk
    end)
    
    local editor,editorClk=cSBtn("Editor","Editor","rbxassetid://94595204123047",UDim2.new(0.08772,0,0.18611,0),true)
    local cloud,cloudClk=cSBtn("Cloud","Cloud","rbxassetid://93729735363108",UDim2.new(0.08772,0,0.28502,0),false)
    local console,consoleClk=cSBtn("Console","Console","rbxassetid://107390243416427",UDim2.new(0.08772,0,0.38394,0),false)
    local extra,extraClk=cSBtn("Extra","Extra","rbxassetid://128679881757557",UDim2.new(0.08772,0,0.48285,0),false)
    
    local logo=cI(sb,{ScaleType=Enum.ScaleType.Fit,Image="rbxassetid://102761807757832",Size=UDim2.new(0.14502,0,0.06924,0),BackgroundTransparency=1,Name="Logo",Position=UDim2.new(0.14069,0,0.06726,0)})
    cC(logo,0)
    local close=cI(sb,{ZIndex=2,ImageColor3=Color3.fromRGB(34,41,58),Image="rbxassetid://124705542662472",Size=UDim2.new(0.12987,0,1,0),BackgroundTransparency=1,Name="Close",Position=UDim2.new(0.891,0,0,0)})
    local slide=cB(close,{TextWrapped=true,TextColor3=Color3.fromRGB(0,0,0),TextSize=14,TextScaled=true,BackgroundTransparency=1,Size=UDim2.new(1,0,0.18856,0),Name="Slide",Text="  ",Position=UDim2.new(0,0,0.43042,0)})
    cTC(slide,14)
    
    return sb,ubclk,editorClk,cloudClk,consoleClk,extraClk,slide
end

function FrostWareBase.createEditor()
    local ep=cI(g["11"],{ImageTransparency=1,ImageColor3=Color3.fromRGB(13,15,20),Image="rbxassetid://76734110237026",Size=UDim2.new(1.00073,0,1,0),ClipsDescendants=true,BackgroundTransparency=1,Name="EditorPage",Position=UDim2.new(-0.00064,0,-0.00021,0)})
    
    local tabBar=cF(ep,{BackgroundColor3=Color3.fromRGB(20,23,30),Size=UDim2.new(1,0,0.08,0),Position=UDim2.new(0,0,0,0),Name="TabBar"})
    cC(tabBar,0)
    
    local tabScroll=cSF(tabBar,{BackgroundTransparency=1,Size=UDim2.new(0.85,0,1,0),Position=UDim2.new(0,0,0,0),Name="TabScroll",ScrollBarThickness=0,CanvasSize=UDim2.new(0,0,0,0)})
    c(n("UIListLayout",tabScroll),{FillDirection=Enum.FillDirection.Horizontal,SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)})
    
    local addTabBtn=cB(tabBar,{BackgroundColor3=Color3.fromRGB(30,36,51),Size=UDim2.new(0.08,0,0.8,0),Position=UDim2.new(0.9,0,0.1,0),Text="+",TextColor3=Color3.fromRGB(255,255,255),TextSize=24,Name="AddTabBtn"})
    cC(addTabBtn,0.2)
    
    local epp=cI(ep,{ImageColor3=Color3.fromRGB(32,39,57),Image="rbxassetid://136761835814725",Size=UDim2.new(1.00073,0,0.75581,0),ClipsDescendants=true,BackgroundTransparency=1,Name="EditorPage",Position=UDim2.new(-0.00064,0,0.08,0)})
    
    local tb=cF(epp,{BackgroundColor3=Color3.fromRGB(24,24,32),Size=UDim2.new(1,0,0.68651,0),Position=UDim2.new(0,0,0.05377,0),Name="txtbox",BackgroundTransparency=0.9})
    local ef=cSF(tb,{ElasticBehavior=Enum.ElasticBehavior.Always,TopImage="rbxassetid://148970562",MidImage="rbxassetid://148970562",VerticalScrollBarInset=Enum.ScrollBarInset.Always,BackgroundColor3=Color3.fromRGB(32,31,32),Name="EditorFrame",ScrollBarImageTransparency=1,HorizontalScrollBarInset=Enum.ScrollBarInset.Always,BottomImage="rbxassetid://148970562",Size=UDim2.new(1,0,1,0),ScrollBarImageColor3=Color3.fromRGB(38,40,46),ScrollBarThickness=10,BackgroundTransparency=1})
    local src=cTB(ef,{CursorPosition=-1,Name="Source",TextXAlignment=Enum.TextXAlignment.Left,PlaceholderColor3=Color3.fromRGB(205,205,205),ZIndex=3,TextWrapped=true,TextTransparency=0,TextSize=23,TextColor3=Color3.fromRGB(255,255,255),TextYAlignment=Enum.TextYAlignment.Top,RichText=false,FontFace=Font.new("rbxassetid://11702779409",Enum.FontWeight.Medium,Enum.FontStyle.Normal),MultiLine=true,ClearTextOnFocus=false,ClipsDescendants=true,Size=UDim2.new(0.7,0,2,0),Position=UDim2.new(0.08,0,0,0),Text="-- FrostWare V2 Editor\nprint('Hello World!')",BackgroundTransparency=1})
    local ln=cT(ef,{TextWrapped=true,TextSize=25,TextYAlignment=Enum.TextYAlignment.Top,TextScaled=true,BackgroundColor3=Color3.fromRGB(32,31,32),FontFace=Font.new("rbxassetid://11702779409",Enum.FontWeight.Regular,Enum.FontStyle.Normal),TextColor3=Color3.fromRGB(193,191,235),BackgroundTransparency=1,Size=UDim2.new(0.05,0,2,0),Text="1",Position=UDim2.new(0.02103,0,-0.00262,0)})
    cTC(ln,25)
    cC(ef)
    
    return ep,src,ln,tabScroll,addTabBtn
end

function FrostWareBase.updateLineNumbers(src, lineNumbers)
    if src and src.Text then
        local lines=src.Text:split("\n")
        local lineText=""
        for i=1,#lines do lineText=lineText..tostring(i)if i<#lines then lineText=lineText.."\n"end end
        if lineNumbers then lineNumbers.Text=lineText end
    end
end

function FrostWareBase.createTab(tabScroll, name, content)
    local tabData={
        name=name or "Tab "..tabCounter,
        content=content or "-- New Tab\nprint('Hello from "..(name or "Tab "..tabCounter).."!')",
        id=tabCounter
    }
    
    local tabBtn=cB(tabScroll,{
        BackgroundColor3=Color3.fromRGB(30,36,51),
        Size=UDim2.new(0,120,0.8,0),
        Position=UDim2.new(0,0,0.1,0),
        Text=tabData.name,
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=18,
        Name="Tab"..tabData.id,
        TextScaled=true
    })
    cC(tabBtn,0.2)
    
    local closeBtn=cB(tabBtn,{
        BackgroundColor3=Color3.fromRGB(200,100,100),
        Size=UDim2.new(0,20,0,20),
        Position=UDim2.new(1,-25,0,5),
        Text="×",
        TextColor3=Color3.fromRGB(255,255,255),
        TextSize=16,
        Name="CloseBtn"
    })
    cC(closeBtn,0.5)
    
    tabData.button=tabBtn
    tabData.closeButton=closeBtn
    editorTabs[tabData.id]=tabData
    
    tabScroll.CanvasSize=UDim2.new(0,tabScroll.UIListLayout.AbsoluteContentSize.X,0,0)
    tabCounter=tabCounter+1
    
    return tabData.id, tabBtn, closeBtn
end

function FrostWareBase.switchToTab(tabId, src, lineNumbers)
    if editorTabs[tabId] then
        if editorTabs[currentTabIndex] then
            editorTabs[currentTabIndex].content=src.Text
        end
        
        for _,tab in pairs(editorTabs)do
            if tab.button then
                tab.button.BackgroundColor3=Color3.fromRGB(30,36,51)
            end
        end
        
        currentTabIndex=tabId
        if editorTabs[tabId].button then
            editorTabs[tabId].button.BackgroundColor3=Color3.fromRGB(50,56,71)
        end
        src.Text=editorTabs[tabId].content
        FrostWareBase.updateLineNumbers(src, lineNumbers)
    end
end

function FrostWareBase.closeTab(tabId, tabScroll)
    local tabCount=0
    for _ in pairs(editorTabs)do tabCount=tabCount+1 end
    
    if tabCount<=1 then
        return false
    end
    
    if editorTabs[tabId] then
        if editorTabs[tabId].button then
            editorTabs[tabId].button:Destroy()
        end
        editorTabs[tabId]=nil
        
        if currentTabIndex==tabId then
            for id,_ in pairs(editorTabs)do
                currentTabIndex=id
                break
            end
        end
        
        tabScroll.CanvasSize=UDim2.new(0,tabScroll.UIListLayout.AbsoluteContentSize.X,0,0)
        return true
    end
    return false
end

function FrostWareBase.renameTab(tabId, newName)
    if editorTabs[tabId] then
        editorTabs[tabId].name=newName
        if editorTabs[tabId].button then
            editorTabs[tabId].button.Text=newName
        end
        return true
    end
    return false
end

function FrostWareBase.showAlert(title, message, duration)
    local alert=g["7"]:Clone()
    local alerts=g["6"]:FindFirstChild("Alerts")
    if alerts then
        alert.Parent=alerts
        alert.Visible=true
        alert.Name="Alert_"..tick()
        alert:FindFirstChild("TEXTLABEL").Text=message
        alert:FindFirstChild("TextLabel").Text=title
        local tween=ts:Create(alert,TweenInfo.new(0.5,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.new(0.39798,0,0.07387,0)})
        tween:Play()
        spawn(function()
            wait(duration or 3)
            local fadeOut=ts:Create(alert,TweenInfo.new(0.3,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Position=UDim2.new(0.39798,0,-0.3,0)})
            fadeOut:Play()
            fadeOut.Completed:Connect(function()alert:Destroy()end)
        end)
    end
end

function FrostWareBase.switchPage(pageName, sidebar)
    for _,page in pairs(g["11"]:GetChildren())do if page:IsA("ImageLabel")then page.Visible=false end end
    for _,btn in pairs(sidebar:GetChildren())do
        if btn:IsA("Frame")and btn.Name~="UpgradeBtn"and btn.Name~="TimeBarFrame"then
            btn.BackgroundTransparency=1
            local box=btn:FindFirstChild("Box")
            if box then box.UIGradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(66,79,113)),ColorSequenceKeypoint.new(1,Color3.fromRGB(36,44,63))}end
        end
    end
    
    local pageObj=g["11"]:FindFirstChild(pageName.."Page")
    if pageObj then
        pageObj.Visible=true
        local sidebarBtn=sidebar:FindFirstChild(pageName)
        if sidebarBtn then
            sidebarBtn.BackgroundTransparency=0
            local box=sidebarBtn:FindFirstChild("Box")
            if box then box.UIGradient.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(166,190,255)),ColorSequenceKeypoint.new(1,Color3.fromRGB(93,117,160))}end
        end
    end
end

function FrostWareBase.getUI()
    return g
end

function FrostWareBase.getCurrentTab()
    return currentTabIndex
end

function FrostWareBase.getEditorTabs()
    return editorTabs
end

function FrostWareBase.show()
    if g["3"] then g["3"].Visible=true end
    if g["2"] then g["2"].Visible=true end
    local openBtn=g["1"]:FindFirstChild("OpenBtn")
    if openBtn then openBtn.Visible=false end
end

function FrostWareBase.hide()
    if g["3"] then g["3"].Visible=false end
    if g["2"] then g["2"].Visible=false end
    local openBtn=g["1"]:FindFirstChild("OpenBtn")
    if openBtn then openBtn.Visible=true end
end

return FrostWareBase
