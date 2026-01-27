--[[
    UZIHUB V1 - OBSIDIAN ELITE [MOBILE EDITION]
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Configuration States
local Toggles = {Fly = false, Noclip = false, ["Aimbot + ESP"] = false, Speed = false, Jump = false}
local Values = {WalkSpeed = 16, JumpPower = 50, FlySpeed = 50}
local locking = false
local ESP_Cache = {}

--// Professional Theme
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Surface = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(120, 80, 255),
    Text = Color3.fromRGB(240, 240, 240),
    Inactive = Color3.fromRGB(150, 150, 150),
    Danger = Color3.fromRGB(255, 75, 75)
}

--// UI Setup
local ScreenGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
ScreenGui.ResetOnSpawn = false

-- Persistent Mobile Toggle Button
local OpenBtn = Instance.new("TextButton", ScreenGui)
OpenBtn.Size = UDim2.new(0, 60, 0, 60)
OpenBtn.Position = UDim2.new(0, 10, 0.5, -30)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "UZI"
OpenBtn.TextColor3 = Theme.Text
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 18
local Corner = Instance.new("UICorner", OpenBtn)
Corner.CornerRadius = Bold.new(0, 30)

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0.8, 0, 0.7, 0) -- Scaled for mobile
Main.Position = UDim2.new(0.1, 0, 0.15, 0)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Visible = false
Instance.new("UICorner", Main)

OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, -50, 0, 40)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.Text = "Uzihub V1 | MOBILE"; Title.TextColor3 = Theme.Text; Title.Font = Enum.Font.GothamBold; Title.TextSize = 16; Title.TextXAlignment = Enum.TextXAlignment.Left; Title.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(0.95, 0, 0.85, 0)
Content.Position = UDim2.new(0.025, 0, 0.12, 0)
Content.BackgroundTransparency = 1; Content.CanvasSize = UDim2.new(0, 0, 0, 600); Content.ScrollBarThickness = 4
local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 10)

--// Logic Core
local function isFFA() return #game:GetService("Teams"):GetTeams() <= 1 end
local function isEnemy(p) 
    if not p or p == LocalPlayer or not p.Character then return false end
    return isFFA() or p.Team ~= LocalPlayer.Team 
end

--// High-Performance Rainbow ESP
local function AddESP(player)
    if ESP_Cache[player] then return end
    local tracer = Drawing.new("Line"); tracer.Thickness = 1.5; tracer.Visible = false
    local label = Drawing.new("Text"); label.Size = 14; label.Center = true; label.Outline = true; label.Visible = false

    local function update()
        local conn; conn = RunService.RenderStepped:Connect(function()
            if not Toggles["Aimbot + ESP"] or not player.Parent or not player.Character or not isEnemy(player) then
                tracer.Visible = false; label.Visible = false
                if player.Character and player.Character:FindFirstChild("UziHighlight") then player.Character.UziHighlight.Enabled = false end
                if not player.Parent then tracer:Remove(); label:Remove(); conn:Disconnect(); ESP_Cache[player] = nil end
                return
            end

            local char, root, hum = player.Character, player.Character:FindFirstChild("HumanoidRootPart"), player.Character:FindFirstChild("Humanoid")
            if root and hum and hum.Health > 0 then
                local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
                local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                local high = char:FindFirstChild("UziHighlight") or Instance.new("Highlight", char)
                high.Name = "UziHighlight"; high.Enabled = true; high.FillColor = color; high.OutlineColor = color; high.FillTransparency = 0.5

                if onScreen then
                    tracer.Visible = true; tracer.Color = color; tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y); tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                    label.Visible = true; label.Position = Vector2.new(screenPos.X, screenPos.Y - 60); label.Color = color
                    label.Text = string.format("%s\n%d HP | %d Studs", player.Name, math.floor(hum.Health), dist)
                else tracer.Visible = false; label.Visible = false end
            else tracer.Visible = false; label.Visible = false end
        end)
    end
    task.spawn(update); ESP_Cache[player] = true
end

--// UI Component Factories
local function CreateToggle(name, callback)
    local Btn = Instance.new("TextButton", Content)
    Btn.Size = UDim2.new(1, -5, 0, 45); Btn.BackgroundColor3 = Theme.Surface; Btn.Text = "  " .. name; Btn.TextColor3 = Theme.Inactive
    Btn.Font = Enum.Font.Gotham; Btn.TextSize = 14; Btn.TextXAlignment = Enum.TextXAlignment.Left; Instance.new("UICorner", Btn)
    local Ind = Instance.new("Frame", Btn); Ind.Size = UDim2.new(0, 30, 0, 30); Ind.Position = UDim2.new(1, -40, 0.5, -15); Ind.BackgroundColor3 = Color3.fromRGB(50, 50, 50); Instance.new("UICorner", Ind)
    
    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        Btn.TextColor3 = Toggles[name] and Theme.Text or Theme.Inactive
        Ind.BackgroundColor3 = Toggles[name] and Theme.Accent or Color3.fromRGB(50, 50, 50)
        callback(Toggles[name])
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Con = Instance.new("Frame", Content); Con.Size = UDim2.new(1, -5, 0, 60); Con.BackgroundTransparency = 1
    local Lab = Instance.new("TextLabel", Con); Lab.Size = UDim2.new(1, 0, 0, 20); Lab.Text = name .. ": " .. default; Lab.TextColor3 = Theme.Inactive; Lab.Font = Enum.Font.Gotham; Lab.TextSize = 12; Lab.BackgroundTransparency = 1; Lab.TextXAlignment = Enum.TextXAlignment.Left
    local Bar = Instance.new("Frame", Con); Bar.Size = UDim2.new(1, 0, 0, 10); Bar.Position = UDim2.new(0, 0, 0, 35); Bar.BackgroundColor3 = Theme.Surface; Instance.new("UICorner", Bar)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)
    
    local function move(input)
        local pos = math.clamp((input.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
        Fill.Size = UDim2.new(pos, 0, 1, 0)
        local val = math.floor(min + (pos * (max - min)))
        Lab.Text = name .. ": " .. val
        callback(val)
    end

    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local connection
            connection = UserInputService.TouchMoved:Connect(function(touch)
                move(touch)
            end)
            UserInputService.TouchEnded:Connect(function()
                connection:Disconnect()
            end)
            move(input)
        end
    end)
end

--// Features Setup
CreateToggle("Aimbot + ESP", function(v) locking = v end)
CreateToggle("Fly", function(v) 
    if v then 
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local BG = Instance.new("BodyGyro", HRP); local BV = Instance.new("BodyVelocity", HRP)
        BG.P = 9e4; BG.maxTorque = Vector3.new(9e9, 9e9, 9e9); BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while Toggles.Fly and LocalPlayer.Character do
                RunService.RenderStepped:Wait()
                -- Mobile Fly Logic (Moves toward where camera looks)
                BV.velocity = Camera.CFrame.LookVector * Values.FlySpeed
                BG.cframe = Camera.CFrame; LocalPlayer.Character.Humanoid.PlatformStand = true
            end
            BG:Destroy(); BV:Destroy(); if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
        end)
    end 
end)
CreateSlider("Fly Speed", 10, 250, 50, function(v) Values.FlySpeed = v end)
CreateToggle("Noclip", function() end)
CreateToggle("Speed", function(v) if not v then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)
CreateSlider("WalkSpeed", 16, 300, 16, function(v) Values.WalkSpeed = v end)
CreateToggle("Jump", function(v) if not v then LocalPlayer.Character.Humanoid.JumpPower = 50 end end)
CreateSlider("JumpPower", 50, 500, 50, function(v) Values.JumpPower = v end)

--// Final Loops
RunService.RenderStepped:Connect(function()
    if Toggles["Aimbot + ESP"] and locking then
        local target, shortest = nil, 500
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mDist < shortest then shortest = mDist; target = p.Character.Head end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end
end)

RunService.Stepped:Connect(function()
    if Toggles.Noclip and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        if Toggles.Speed then LocalPlayer.Character.Humanoid.WalkSpeed = Values.WalkSpeed end
        if Toggles.Jump then LocalPlayer.Character.Humanoid.JumpPower = Values.JumpPower end
    end
end)

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)
