repeat wait() until game:IsLoaded()
repeat wait() until lp
repeat wait() until lp.Character
repeat wait() until lp.Character:FindFirstChild("HumanoidRootPart")

fw.cp("Scripts", "rbxassetid://7733779610", function()
    local sp2 = e.ci2("Frame", fw.gu()["11"])
    e.sp2(sp2, {
        c = Color3.fromRGB(15, 18, 25),
        s = UDim2.new(1, 0, 1, 0),
        p = UDim2.new(0, 0, 0, 0),
        vis = false,
        n = "ScriptsPage"
    })
    
    local title2 = e.ci2("TextLabel", sp2)
    e.sp2(title2, {
        t = "🔧 Scripts Module",
        ts = 24,
        tc = Color3.fromRGB(255, 255, 255),
        s = UDim2.new(1, 0, 0, 50),
        p = UDim2.new(0, 0, 0, 20),
        bt = 1,
        n = "Title"
    })
    
    local content2 = e.ci2("Frame", sp2)
    e.sp2(content2, {
        c = Color3.fromRGB(25, 30, 40),
        s = UDim2.new(0.9, 0, 0.7, 0),
        p = UDim2.new(0.05, 0, 0.15, 0),
        n = "Content"
    })
    e.ci2("UICorner", content2).CornerRadius = UDim.new(0, 8)
    
    local info2 = e.ci2("TextLabel", content2)
    e.sp2(info2, {
        t = "Scripts module loaded successfully!\nThis is a test version.",
        ts = 16,
        tc = Color3.fromRGB(200, 200, 200),
        s = UDim2.new(1, -20, 1, -20),
        p = UDim2.new(0, 10, 0, 10),
        bt = 1,
        n = "Info"
    })
    
    fw.sa("Success", "Scripts module initialized!", 2)
end)

return true
