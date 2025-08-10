addTab("Editor",{icon=A.d},function(frame)
  local title=x("tl",frame,{n="Title",tx="Editor",txw=true,tfx=E.lx,tfy=E.ly,txsc=true,txs=26,ft=F(R..A.i,E.s,E.n),tc=C.t2,bt=1,sz=UDim2.new(0.9,0,0,36),ps=UDim2.new(0.05,0,0.06,0)})
  local runHolder=x("fr",frame,{n="RunBtn",bs=0,bc=C.w,bt=1,sz=UDim2.new(0,140,0,40),ps=UDim2.new(0.05,0,0.11,0)})
  local runCap=x("fr",runHolder,{n="Cap",bs=0,bc=C.w,bt=0,sz=UDim2.new(1,0,1,0)})
  x("uc",runCap,{cr=D(0.18,0)})
  x("ug",runCap,{rt=90,Color=CS({K(0,Color3.fromRGB(166,190,255)),K(1,Color3.fromRGB(93,117,160))})})
  local runLbl=x("tl",runCap,{n="Label",tx="Run",txw=true,tfx=E.lx,tfy=E.ly,txsc=true,txs=24,ft=F(R..A.i,E.b,E.n),tc=C.t1,bt=1,sz=UDim2.new(0.7,0,0.6,0),ps=UDim2.new(0.15,0,0.2,0)})
  local runClick=x("tb",runCap,{n="Click",bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=UDim2.new(1,0,1,0),bt=1,bd=C.k,tx=""})
  x("uc",runClick,{cr=D(0,18)})

  local clearHolder=x("fr",frame,{n="ClearBtn",bs=0,bc=C.w,bt=1,sz=UDim2.new(0,140,0,40),ps=UDim2.new(0.19,0,0.11,0)})
  local clearCap=x("fr",clearHolder,{n="Cap",bs=0,bc=C.w,bt=0,sz=UDim2.new(1,0,1,0)})
  x("uc",clearCap,{cr=D(0.18,0)})
  x("ug",clearCap,{rt=90,Color=CS({K(0,Color3.fromRGB(166,190,255)),K(1,Color3.fromRGB(93,117,160))})})
  local clearLbl=x("tl",clearCap,{n="Label",tx="Clear",txw=true,tfx=E.lx,tfy=E.ly,txsc=true,txs=24,ft=F(R..A.i,E.b,E.n),tc=C.t1,bt=1,sz=UDim2.new(0.7,0,0.6,0),ps=UDim2.new(0.15,0,0.2,0)})
  local clearClick=x("tb",clearCap,{n="Click",bs=0,txs=14,tc=C.k,txsc=true,bc=C.w,ft=F(A.j,E.b,E.n),sz=UDim2.new(1,0,1,0),bt=1,bd=C.k,tx=""})
  x("uc",clearClick,{cr=D(0,18)})

  local card=x("fr",frame,{n="EditorCard",bs=0,bc=C.g1,bt=0,sz=UDim2.new(0.9,0,0.7,0),ps=UDim2.new(0.05,0,0.18,0)})
  x("uc",card,{cr=D(0.04,0)})
  local stroke=x("us",card,{ar=E.a,th=10})
  stroke.Color=C.st

  local code=Instance.new("TextBox")
  code.Name="Code"
  code.Parent=card
  code.BackgroundTransparency=1
  code.Size=UDim2.new(1,-24,1,-24)
  code.Position=UDim2.new(0,12,0,12)
  code.ClearTextOnFocus=false
  code.MultiLine=true
  code.TextWrapped=false
  code.TextXAlignment=E.lx
  code.TextYAlignment=E.ly
  code.FontFace=F(A.j,E.r,E.n)
  code.TextSize=18
  code.TextColor3=C.w
  code.PlaceholderText="print('Hello from Editor')"
  code.Text="print('Hello from Editor')"

  local status=x("tl",frame,{n="Status",tx="Ready",txw=true,tfx=E.lx,tfy=E.ly,txsc=true,txs=18,ft=F(R..A.i,E.n,E.n),tc=C.a1,bt=1,sz=UDim2.new(0.9,0,0,24),ps=UDim2.new(0.05,0,0.89,0)})

  y(runClick,function()
    local ok,err=pcall(function()
      local f=loadstring(code.Text)
      if f then f() end
    end)
    if ok then
      status.Text="Executed ✔"
      status.TextColor3=Color3.fromRGB(120,200,120)
    else
      status.Text="Error: "..tostring(err)
      status.TextColor3=Color3.fromRGB(220,120,120)
    end
  end)

  y(clearClick,function()
    code.Text=""
    status.Text="Cleared"
    status.TextColor3=C.a1
  end)
end)
