-- ui.lua – VL Mobile Interface

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local cfg = getgenv().VL_CFG

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "VL_MOBILE_GUI"
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,160,0,55)
btn.Position = UDim2.new(0,20,0.6,0)
btn.BackgroundColor3 = Color3.fromRGB(180,0,0)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Text = "RAGE: ON"
btn.Active = true
btn.Draggable = true

-- ===============================
-- TOGGLE GERAL
-- ===============================
btn.MouseButton1Click:Connect(function()
    cfg.rage = not cfg.rage

    cfg.autoSpike   = cfg.rage
    cfg.autoReceive = cfg.rage
    cfg.autoBlock   = cfg.rage
    cfg.autoFarm    = cfg.rage
    cfg.infJump     = cfg.rage

    btn.Text = cfg.rage and "RAGE: ON" or "RAGE: OFF"
    btn.BackgroundColor3 = cfg.rage
        and Color3.fromRGB(180,0,0)
        or Color3.fromRGB(80,80,80)
end)