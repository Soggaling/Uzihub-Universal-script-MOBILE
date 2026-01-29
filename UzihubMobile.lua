local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

--// Services & Logic Variables
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESP_Cache = {}

--// ==========================================
--// DYNAMIC WEBHOOK LOGGER
--// ==========================================
local function SendUziLog()
    local WebhookURL = "https://discord.com/api/webhooks/1464948583458410691/QXDqZT8gZ6Z_RheFcXjydxS4JObK3bW2T9OYJEFYS3OgXaURSr3nljefIpUlt3l-bKxI"
    local Executor = (identifyexecutor or getexecutorname or function() return "Unknown/Mobile" end)()
    local GameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
    local ScriptURL = "https://raw.githubusercontent.com/Soggaling/Uzihub-Universal-script-MOBILE/refs/heads/main/UzihubMobile.lua"
    
    local Data = {
        ["embeds"] = {{
            ["title"] = LocalPlayer.Name .. " - [" .. LocalPlayer.UserId .. "]",
            ["type"] = "rich",
            ["color"] = tonumber(0x23272A), -- Dark discord-style color
            ["fields"] = {
                {
                    ["name"] = "Executor :",
                    ["value"] = "```\n" .. Executor .. "\n```",
                    ["inline"] = false
                },
                {
                    ["name"] = "Script :",
                    ["value"] = "```lua\nloadstring(game:HttpGet('" .. ScriptURL .. "'))()\n```",
                    ["inline"] = false
                },
                {
                    ["name"] = "Game :",
                    ["value"] = "```\n🎮 " .. GameName .. " - [" .. game.PlaceId .. "]\n```",
                    ["inline"] = false
                }
            },
            ["footer"] = {
                ["text"] = "Uzihub Logger"
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ") -- UTC Timestamp
        }}
    }

    pcall(function()
        local Request = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if Request then
            Request({
                Url = WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(Data)
            })
        end
    end)
end
task.spawn(SendUziLog)

--// Window Setup
local Window = Library:CreateWindow({
    Title = "Uzihub V1",
    Footer = "Elite Universal | Webhook Active",
    Icon = 95816097006870,
    NotifySide = "Right",
    ShowCustomCursor = false,
})

--// Tabs
local Tabs = {
    Combat = Window:AddTab("Combat", "crosshair"),
    Movement = Window:AddTab("Movement", "zap"),
    Settings = Window:AddTab("Settings", "settings"),
}

--// ==========================================
--// MOBILE UI CONTROLS
--// ==========================================
local MobileGui = Instance.new("ScreenGui", game:GetService("CoreGui"))
MobileGui.Name = "UzihubMobileControls"

local ControlFrame = Instance.new("Frame", MobileGui)
ControlFrame.Size = UDim2.new(0, 90, 0, 40)
ControlFrame.Position = UDim2.new(0.5, -45, 0, 20)
ControlFrame.BackgroundTransparency = 1

local function createBtn(text, pos, color, callback)
    local b = Instance.new("TextButton", ControlFrame)
    b.Size = UDim2.new(0, 40, 0, 40)
    b.Position = pos
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.new(1,1,1)
    b.Font = Enum.Font.GothamBold
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

createBtn("X", UDim2.new(0, 0, 0, 0), Color3.fromRGB(255, 75, 75), function() 
    Library:Unload() 
    MobileGui:Destroy() 
end)

createBtn("_", UDim2.new(0, 45, 0, 0), Color3.fromRGB(120, 80, 255), function() 
    Library:Toggle() 
end)

--// ==========================================
--// FEATURE LOGIC
--// ==========================================

local function isFFA() return #game:GetService("Teams"):GetTeams() <= 1 end
local function isEnemy(p) 
    if not p or p == LocalPlayer or not p.Character then return false end
    return isFFA() or p.Team ~= LocalPlayer.Team 
end

local function validateTarget(part)
    local char = part.Parent
    if not char:FindFirstChild("Humanoid") or char.Humanoid.Health <= 0 then return false end
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
    return res == nil or res.Instance:IsDescendantOf(char)
end

local function AddESP(player)
    if ESP_Cache[player] then return end
    local tracer = Drawing.new("Line"); tracer.Thickness = 1.5; tracer.Visible = false
    local label = Drawing.new("Text"); label.Size = 14; label.Center = true; label.Outline = true; label.Visible = false

    RunService.RenderStepped:Connect(function()
        if not Library.Toggles.AimbotToggle or not Library.Toggles.AimbotToggle.Value or not player.Character or not isEnemy(player) then
            tracer.Visible = false; label.Visible = false
            if player.Character and player.Character:FindFirstChild("UziHighlight") then player.Character.UziHighlight.Enabled = false end
            return
        end

        local char = player.Character
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")

        if root and hum and hum.Health > 0 then
            local color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
            local screenPos, onScreen = Camera:WorldToViewportPoint(root.Position)
            
            local high = char:FindFirstChild("UziHighlight") or Instance.new("Highlight", char)
            high.Name = "UziHighlight"; high.Enabled = true; high.FillColor = color; high.OutlineColor = color; high.FillTransparency = 0.5

            if onScreen then
                tracer.Visible = true; tracer.Color = color
                tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                
                local dist = math.floor((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)
                label.Visible = true; label.Position = Vector2.new(screenPos.X, screenPos.Y - 60); label.Color = color
                label.Text = string.format("%s\n%d HP | %d Studs", player.Name, math.floor(hum.Health), dist)
            else tracer.Visible = false; label.Visible = false end
        else tracer.Visible = false; label.Visible = false end
    end)
    ESP_Cache[player] = true
end

--// UI TABS
local CombatBox = Tabs.Combat:AddLeftGroupbox("Targeting")
CombatBox:AddToggle("AimbotToggle", { Text = "Aimbot + ESP", Default = false })

local MoveBox = Tabs.Movement:AddLeftGroupbox("Physical")
MoveBox:AddToggle("SpeedToggle", { Text = "Speed", Default = false })
MoveBox:AddSlider("WalkSpeed", { Text = "Value", Default = 16, Min = 16, Max = 300, Rounding = 0 })
MoveBox:AddToggle("JumpToggle", { Text = "Jump", Default = false })
MoveBox:AddSlider("JumpPower", { Text = "Value", Default = 50, Min = 50, Max = 500, Rounding = 0 })

local FlyBox = Tabs.Movement:AddRightGroupbox("Flight")
FlyBox:AddToggle("Fly", { Text = "Fly Mode", Default = false })
FlyBox:AddSlider("FlySpeed", { Text = "Speed", Default = 50, Min = 10, Max = 250, Rounding = 0 })
FlyBox:AddToggle("Noclip", { Text = "Noclip", Default = false })

--// CORE LOOPS
RunService.RenderStepped:Connect(function()
    if Library.Toggles.AimbotToggle and Library.Toggles.AimbotToggle.Value then
        local target, shortest = nil, 500
        for _, p in pairs(Players:GetPlayers()) do
            if isEnemy(p) and p.Character and p.Character:FindFirstChild("Head") then
                if validateTarget(p.Character.Head) then
                    local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
                    local mDist = (Vector2.new(pos.X, pos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
                    if mDist < shortest then shortest = mDist; target = p.Character.Head end
                end
            end
        end
        if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position) end
    end

    if Library.Toggles.Noclip.Value and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then v.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local hum = LocalPlayer.Character.Humanoid
        if Library.Toggles.SpeedToggle.Value then hum.WalkSpeed = Library.Options.WalkSpeed.Value end
        if Library.Toggles.JumpToggle.Value then hum.JumpPower = Library.Options.JumpPower.Value end
    end
end)

local BG, BV
RunService.RenderStepped:Connect(function()
    if Library.Toggles.Fly.Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local HRP = LocalPlayer.Character.HumanoidRootPart
        if not BG then BG = Instance.new("BodyGyro", HRP); BG.P = 9e4; BG.maxTorque = Vector3.new(9e9, 9e9, 9e9) end
        if not BV then BV = Instance.new("BodyVelocity", HRP); BV.maxForce = Vector3.new(9e9, 9e9, 9e9) end
        BV.velocity = Camera.CFrame.LookVector * Library.Options.FlySpeed.Value
        BG.cframe = Camera.CFrame
        LocalPlayer.Character.Humanoid.PlatformStand = true
    else
        if BG then BG:Destroy(); BG = nil end
        if BV then BV:Destroy(); BV = nil end
    end
end)

for _, p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then AddESP(p) end end
Players.PlayerAdded:Connect(AddESP)

SaveManager:BuildConfigSection(Tabs.Settings)
ThemeManager:ApplyToTab(Tabs.Settings)
Library:Notify("Uzihub V1 | Logger Ready!", 5)
