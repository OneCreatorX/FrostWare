repeat task.wait(0.1) until game:IsLoaded()
        
        local sg = Instance.new("ScreenGui")
        sg.Name = "FW_AN_" .. tostring(math.random(10000, 99999))
        sg.Parent = gethui()
        sg.ResetOnSpawn = false
        
        local f = Instance.new("Frame")
        f.Size = UDim2.new(0, 380, 0, 160)
        f.Position = UDim2.new(1, -400, 0, -200)
        f.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
        f.BorderSizePixel = 0
        f.Parent = sg
        
        local c = Instance.new("UICorner")
        c.CornerRadius = UDim.new(0, 16)
        c.Parent = f
        
        local s = Instance.new("UIStroke")
        s.Color = Color3.fromRGB(96, 165, 250)
        s.Thickness = 2
        s.Parent = f
        
        local g = Instance.new("UIGradient")
        g.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 23, 42)),
            ColorSequenceKeypoint.new(0.3, Color3.fromRGB(30, 41, 59)),
            ColorSequenceKeypoint.new(0.7, Color3.fromRGB(48, 164, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 23, 42))
        }
        g.Rotation = 135
        g.Transparency = NumberSequence.new{
            NumberSequenceKeypoint.new(0, 0.1),
            NumberSequenceKeypoint.new(0.5, 0.8),
            NumberSequenceKeypoint.new(1, 0.1)
        }
        g.Parent = f
        
        local sh = Instance.new("ImageLabel")
        sh.Size = UDim2.new(1, 20, 1, 20)
        sh.Position = UDim2.new(0, -10, 0, -10)
        sh.BackgroundTransparency = 1
        sh.Image = "rbxasset://textures/ui/Controls/DropShadow.png"
        sh.ImageColor3 = Color3.fromRGB(96, 165, 250)
        sh.ImageTransparency = 0.4
        sh.ScaleType = Enum.ScaleType.Slice
        sh.SliceCenter = Rect.new(12, 12, 12, 12)
        sh.ZIndex = f.ZIndex - 1
        sh.Parent = f
        
        local hd = Instance.new("Frame")
        hd.Size = UDim2.new(1, 0, 0, 50)
        hd.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
        hd.BorderSizePixel = 0
        hd.Parent = f
        
        local hc = Instance.new("UICorner")
        hc.CornerRadius = UDim.new(0, 16)
        hc.Parent = hd
        
        local hb = Instance.new("Frame")
        hb.Size = UDim2.new(1, 0, 0, 16)
        hb.Position = UDim2.new(0, 0, 1, -16)
        hb.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
        hb.BorderSizePixel = 0
        hb.Parent = hd
        
        local hg = Instance.new("UIGradient")
        hg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
        }
        hg.Rotation = 45
        hg.Parent = hd
        
        local i = Instance.new("TextLabel")
        i.Size = UDim2.new(0, 40, 0, 40)
        i.Position = UDim2.new(0, 15, 0, 5)
        i.BackgroundTransparency = 1
        i.Text = "❄️"
        i.TextColor3 = Color3.fromRGB(255, 255, 255)
        i.TextSize = 28
        i.Font = Enum.Font.Gotham
        i.Parent = hd
        
        local t = Instance.new("TextLabel")
        t.Size = UDim2.new(1, -65, 0, 50)
        t.Position = UDim2.new(0, 55, 0, 0)
        t.BackgroundTransparency = 1
        t.Text = "FROSTWARE PREMIUM"
        t.TextColor3 = Color3.fromRGB(255, 255, 255)
        t.TextSize = 16
        t.Font = Enum.Font.GothamBold
        t.TextXAlignment = Enum.TextXAlignment.Left
        t.Parent = hd
        
        local st = Instance.new("TextLabel")
        st.Size = UDim2.new(1, -30, 0, 25)
        st.Position = UDim2.new(0, 15, 0, 60)
        st.BackgroundTransparency = 1
        st.Text = "✅ Access Verified & Active"
        st.TextColor3 = Color3.fromRGB(52, 211, 153)
        st.TextSize = 14
        st.Font = Enum.Font.GothamBold
        st.TextXAlignment = Enum.TextXAlignment.Left
        st.Parent = f
        
        local tf = Instance.new("Frame")
        tf.Size = UDim2.new(1, -30, 0, 45)
        tf.Position = UDim2.new(0, 15, 0, 95)
        tf.BackgroundColor3 = Color3.fromRGB(96, 165, 250)
        tf.BorderSizePixel = 0
        tf.Parent = f
        
        local tc = Instance.new("UICorner")
        tc.CornerRadius = UDim.new(0, 12)
        tc.Parent = tf
        
        local tg = Instance.new("UIGradient")
        tg.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(96, 165, 250)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(52, 211, 153))
        }
        tg.Rotation = 45
        tg.Parent = tf
        
        local tt = Instance.new("TextLabel")
        tt.Size = UDim2.new(1, 0, 1, 0)
        tt.BackgroundTransparency = 1
        tt.Text = "⏰ " .. hours .. " HOURS REMAINING"
        tt.TextColor3 = Color3.fromRGB(255, 255, 255)
        tt.TextSize = 16
        tt.Font = Enum.Font.GothamBold
        tt.Parent = tf
        
        local cb = Instance.new("TextButton")
        cb.Size = UDim2.new(0, 25, 0, 25)
        cb.Position = UDim2.new(1, -35, 0, 10)
        cb.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
        cb.Text = "✕"
        cb.TextColor3 = Color3.fromRGB(255, 255, 255)
        cb.TextSize = 14
        cb.Font = Enum.Font.GothamBold
        cb.Parent = f
        
        local cc = Instance.new("UICorner")
        cc.CornerRadius = UDim.new(0, 6)
        cc.Parent = cb
        
        local ts = game:GetService("TweenService")
        
        local ot = ts:Create(f, TweenInfo.new(0.8, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = UDim2.new(1, -400, 0, 20)
        })
        ot:Play()
        
        spawn(function()
            for j = 1, 4 do
                ts:Create(i, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 32}):Play()
                wait(0.4)
                ts:Create(i, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextSize = 28}):Play()
                wait(0.6)
            end
        end)
        
        spawn(function()
            while f.Parent do
                local glow = ts:Create(s, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
                    Transparency = 0.8
                })
                glow:Play()
                wait(0.1)
            end
        end)
        
        cb.MouseButton1Click:Connect(function()
            local ct = ts:Create(f, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(1, -400, 0, -200)
            })
            ct:Play()
            ct.Completed:Connect(function()
                sg:Destroy()
            end)
        end)
        
        spawn(function()
            wait(6)
            if f.Parent then
                local ct = ts:Create(f, TweenInfo.new(0.6, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                    Position = UDim2.new(1, -400, 0, -200)
                })
                ct:Play()
                ct.Completed:Connect(function()
                    sg:Destroy()
                end)
            end
        end)
    
