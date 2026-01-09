-- ui.lua – VL HUB PRO

local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- LOAD CORE
local State = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SAMU-SCPT/vl_mobile.lua/main/main.lua"
))()

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "VL_HUB"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0,300,0,400)
frame.Position = UDim2.new(0.05,0,0.25,0)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.Active = true
frame.Draggable = true
frame.BorderSizePixel = 0

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,0,0,50)
title.Text = "VL HUB PRO | SAMU"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.TextScaled = true

-- ===============================
-- TOGGLE BUTTONS
-- ===============================
local y = 60
local function toggle(text,key)
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1,-20,0,40)
    b.Position = UDim2.new(0,10,0,y)
    b.BackgroundColor3 = Color3.fromRGB(120,0,0)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextScaled = true
    b.Text = text.." : OFF"

    b.MouseButton1Click:Connect(function()
        State[key] = not State[key]
        b.Text = text.." : "..(State[key] and "ON" or "OFF")
        b.BackgroundColor3 = State[key] and Color3.fromRGB(0,200,0) or Color3.fromRGB(120,0,0)
    end)
    y += 50
end

toggle("Auto Spike","AutoSpike")
toggle("Auto Block","AutoBlock")
toggle("Auto Receive","AutoReceive")
toggle("Auto Farm","AutoFarm")
toggle("Auto Serve","AutoServe")
toggle("Ball Tracker","BallTracker")

-- ===============================
-- SPEED SLIDER
-- ===============================
local speedBtn = Instance.new("TextButton", frame)
speedBtn.Size = UDim2.new(1,-20,0,40)
speedBtn.Position = UDim2.new(0,10,0,y)
speedBtn.Text = "Speed: 30"
speedBtn.TextScaled = true
speedBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
speedBtn.TextColor3 = Color3.new(1,1,1)

speedBtn.MouseButton1Click:Connect(function()
    State.Speed += 10
    if State.Speed > State.MaxSpeed then State.Speed = 30 end
    speedBtn.Text = "Speed: "..State.Speed
end)