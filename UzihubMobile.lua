--[[
    UZIHUB V1 - OBSIDIAN ELITE [MOBILE FIX]
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
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
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "UzihubMobile"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Persistent Mobile Toggle Button (Top Layer)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "Toggle"
OpenBtn.Parent = ScreenGui
OpenBtn.Size = UDim2.new(0, 55, 0, 55)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Theme.Accent
OpenBtn.Text = "UZI"
OpenBtn.TextColor3 = Theme.Text
OpenBtn.Font = Enum.Font.GothamBold
OpenBtn.TextSize = 16
OpenBtn.ZIndex = 10 -- Always on top
local Corner = Instance.new("UICorner", OpenBtn)
Corner.CornerRadius = Tool.new(0, 12)

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = ScreenGui
Main.Size = UDim2.new(0.7, 0, 0.6, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.Visible = false
Main.ZIndex = 5
Instance.new("UICorner", Main)

-- Open/Close Logic (Tap)
OpenBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
end)

-- Dragging Logic for the Button (So you can move it out of the way)
local draggingBtn, dragInput, dragStart, startPos
OpenBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = true
        dragStart = input.Position
        startPos = OpenBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if draggingBtn and input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch then
        draggingBtn = false
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "UZIHUB V1 | MOBILE"
Title.TextColor3 = Theme.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.BackgroundTransparency = 1

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(0.9, 0, 0.8, 0)
Content.Position = UDim2.new(0.05, 0, 0.15, 0)
Content.BackgroundTransparency = 1
Content.ScrollBarThickness = 2
Content.CanvasSize = UDim2.new(0, 0, 0, 500)
local Layout = Instance.new("UIListLayout", Content); Layout.Padding = UDim.new(0, 10)

--// Component Functions
local function CreateToggle(name, callback)
    local Btn = Instance.new("TextButton", Content)
    Btn.Size = UDim2.new(1, 0, 0, 45)
    Btn.BackgroundColor3 = Theme.Surface
    Btn.Text = name
    Btn.TextColor3 = Theme.Inactive
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Instance.new("UICorner", Btn)

    Btn.MouseButton1Click:Connect(function()
        Toggles[name] = not Toggles[name]
        Btn.TextColor3 = Toggles[name] and Theme.Accent or Theme.Inactive
        callback(Toggles[name])
    end)
end

local function CreateSlider(name, min, max, default, callback)
    local Con = Instance.new("Frame", Content); Con.Size = UDim2.new(1, 0, 0, 55); Con.BackgroundTransparency = 1
    local Lab = Instance.new("TextLabel", Con); Lab.Size = UDim2.new(1, 0, 0, 20); Lab.Text = name .. ": " .. default; Lab.TextColor3 = Theme.Inactive; Lab.Font = Enum.Font.Gotham; Lab.TextSize = 12; Lab.BackgroundTransparency = 1
    local Bar = Instance.new("Frame", Con); Bar.Size = UDim2.new(1, 0, 0, 8); Bar.Position = UDim2.new(0, 0, 0, 30); Bar.BackgroundColor3 = Theme.Surface; Instance.new("UICorner", Bar)
    local Fill = Instance.new("Frame", Bar); Fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); Fill.BackgroundColor3 = Theme.Accent; Instance.new("UICorner", Fill)
    
    Bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            local function move()
                local pos = math.clamp((UserInputService:GetMouseLocation().X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local val = math.floor(min + (pos * (max - min)))
                Lab.Text = name .. ": " .. val
                callback(val)
            end
            local moveConn = RunService.RenderStepped:Connect(move)
            local endConn; endConn = UserInputService.InputEnded:Connect(function(inputEnd)
                if inputEnd.UserInputType == Enum.UserInputType.Touch then
                    moveConn:Disconnect()
                    endConn:Disconnect()
                end
            end)
        end
    end)
end

--// Feature Setup
CreateToggle("Aimbot + ESP", function(v) locking = v end)
CreateToggle("Fly", function(v) 
    if v then 
        local HRP = LocalPlayer.Character.HumanoidRootPart
        local BG = Instance.new("BodyGyro", HRP); local BV = Instance.new("BodyVelocity", HRP)
        BG.P = 9e4; BG.maxTorque = Vector3.new(9e9, 9e9, 9e9); BV.maxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while Toggles.Fly and LocalPlayer.Character do
                RunService.RenderStepped:Wait()
                BV.velocity = Camera.CFrame.LookVector * Values.FlySpeed
                BG.cframe = Camera.CFrame
                LocalPlayer.Character.Humanoid.PlatformStand = true
            end
            BG:Destroy(); BV:Destroy()
            if LocalPlayer.Character:FindFirstChild("Humanoid") then LocalPlayer.Character.Humanoid.PlatformStand = false end
        end)
    end 
end)
CreateSlider("Fly Speed", 10, 250, 50, function(v) Values.FlySpeed = v end)
CreateToggle("Noclip", function() end)
CreateToggle("Speed", function(v) if not v then LocalPlayer.Character.Humanoid.WalkSpeed = 16 end end)
CreateSlider("WalkSpeed", 16, 300, 16, function(v) Values.WalkSpeed = v end)
CreateToggle("Jump", function(v) if not v then LocalPlayer.Character.Humanoid.JumpPower = 50 end end)
CreateSlider("JumpPower", 50, 500, 50, function(v) Values.JumpPower = v end)

--// Loops
RunService.RenderStepped:Connect(function()
    if Toggles["Aimbot + ESP"] and locking then
        local target, shortest = nil, 500
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if vis then
                    local dist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if dist < shortest then shortest = dist; target = p.Character.Head end
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
