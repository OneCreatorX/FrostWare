function fw.cstp()
    local setp = nim(g["11"], {ImageTransparency=1, ic=Color3.fromRGB(13,15,20), i="rbxassetid://76734110237026", s=UDim2.new(1.001,0,1,0), v=false, cl=true, bt=1, n="SettingsPage", p=UDim2.new(-0.001,0,0,0)})
    local tit = nt(setp, {t="Settings", ts=48, tc=Color3.fromRGB(255,255,255), bt=1, s=UDim2.new(1,0,0.2,0), p=UDim2.new(0,0,0.3,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Bold,Enum.FontStyle.Normal)})
    ntc(tit, 48)
    local info = nt(setp, {t="Configura tus preferencias aquí.", ts=24, tc=Color3.fromRGB(180,180,180), bt=1, s=UDim2.new(1,0,0.1,0), p=UDim2.new(0,0,0.5,0), sc=true, ff=Font.new("rbxassetid://12187365364",Enum.FontWeight.Regular,Enum.FontStyle.Normal)})
    ntc(info, 24)
    return setp
end

fw.addTab("Settings", "Settings", "rbxassetid://YOUR_SETTINGS_ICON_ID", UDim2.new(0.075,0,0.60,0), fw.cstp)
