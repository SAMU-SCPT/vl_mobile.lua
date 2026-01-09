-- ui.lua | VL HUB UI
-- CARREGA O MAIN

local Core = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SAMU-SCPT/vl_mobile.lua/main/main.lua"
))()

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "VL_HUB"
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,380,0,420)
main.Position = UDim2.new(0.5,-190,0.5,-210)
main.BackgroundColor3 = Color3.fromRGB(20,20,20)
main.Active = true
main.Draggable = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

-- TITLE
local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,45)
title.Text = "VL HUB | MOBILE"
title.TextColor3 = Color3.fromRGB(255,80,80)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextScaled = true

-- ===============================
-- TOGGLE MAKER
-- ===============================
local y = 55
local function Toggle(text, key)
    local b = Instance.new("TextButton", main)
    b.Size = UDim2.new(0.9,0,0,38)
    b.Position = UDim2.new(0.05,0,0,y)
    b.BackgroundColor3 = Color3.fromRGB(40,40,40)
    b.TextColor3 = Color3.new(1,1,1)
    b.Text = text .. ": OFF"
    b.Font = Enum.Font.Gotham
    b.TextScaled = true
    Instance.new("UICorner", b)

    b.MouseButton1Click:Connect(function()
        Core.Config[key] = not Core.Config[key]
        b.Text = text .. (Core.Config[key] and ": ON" or ": OFF")
        b.BackgroundColor3 = Core.Config[key]
            and Color3.fromRGB(180,60,60)
            or Color3.fromRGB(40,40,40)
    end)

    y += 45
end

-- ===============================
-- TOGGLES
-- ===============================
Toggle("Auto Spike","AutoSpike")
Toggle("Auto Receive","AutoReceive")
Toggle("Auto Block","AutoBlock")
Toggle("Auto Farm","AutoFarm")
Toggle("Infinite Jump","InfJump")
Toggle("Ball Tracker","BallTracker")
Toggle("Anti AFK","AntiAFK")

-- ===============================
-- SPEED SLIDER (SIMPLIFICADO)
-- ===============================
local speed = Instance.new("TextButton", main)
speed.Size = UDim2.new(0.9,0,0,38)
speed.Position = UDim2.new(0.05,0,0,y)
speed.Text = "Speed: 1x"
speed.BackgroundColor3 = Color3.fromRGB(60,60,60)
speed.TextColor3 = Color3.new(1,1,1)
speed.TextScaled = true
Instance.new("UICorner", speed)

speed.MouseButton1Click:Connect(function()
    Core.Config.SpeedMul += 0.25
    if Core.Config.SpeedMul > 3 then
        Core.Config.SpeedMul = 1
    end
    speed.Text = "Speed: "..Core.Config.SpeedMul.."x"
end)