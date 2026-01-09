-- vl_mobile.lua – Mobile GUI Edition
-- Cole inteiro e use RAW no Delta Mobile

-- ===============================
-- SERVICES
-- ===============================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TP         = game:GetService("TeleportService")

local lp = Players.LocalPlayer

-- ===============================
-- CONFIG
-- ===============================
local cfg = {
    autoSpike   = true,
    autoReceive = true,
    autoBlock   = true,
    infJump     = true,
    speedMul    = 1.8,
    ballTracker = true,
    playerESP   = true,
    antiAFK     = true,
    autoFarm    = true,
    clickTP     = true,
    espColor    = Color3.fromRGB(0,255,0),
    ballColor   = Color3.fromRGB(255,0,255),
    thickness   = 2
}

-- ===============================
-- UTILS
-- ===============================
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():FindFirstChild("HumanoidRootPart")
end

local function getHum()
    return getChar():FindFirstChildOfClass("Humanoid")
end

local function getBall()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("ball") then
            return v
        end
    end
end

local function sideFromZ(z)
    return z > 0 and 1 or 2
end

local function mySide()
    local hrp = getHRP()
    if not hrp then return 0 end
    return sideFromZ(hrp.Position.Z)
end

local function ballSide(ball)
    if not ball then return 0 end
    return sideFromZ(ball.Position.Z)
end

local function nearestEnemy()
    local hrp = getHRP()
    if not hrp then return end
    local enemy, dist = nil, math.huge

    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not lp.Team or p.Team ~= lp.Team then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    enemy, dist = p, d
                end
            end
        end
    end
    return enemy
end

-- ===============================
-- ORIGINAL FEATURES
-- ===============================
if cfg.autoSpike then
    RunService.Heartbeat:Connect(function()
        local ball, hrp = getBall(), getHRP()
        if not ball or not hrp then return end
        if ball.AssemblyLinearVelocity.Y < -6 and ball.Position.Y < 14 then
            if mySide() ~= ballSide(ball) then
                hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0,-2,0))
                task.wait(0.05)
                for _,v in ipairs(getChar():GetDescendants()) do
                    if v:IsA("RemoteEvent") and v.Name:lower():find("spike") then
                        v:FireServer()
                        break
                    end
                end
            end
        end
    end)
end

if cfg.autoReceive then
    RunService.Heartbeat:Connect(function()
        local ball, hrp = getBall(), getHRP()
        if not ball or not hrp then return end
        if ball.Position.Y < 15 and mySide() == ballSide(ball) then
            hrp.CFrame = hrp.CFrame:Lerp(
                CFrame.new(ball.Position + Vector3.new(0,-1,0)), 0.25
            )
        end
    end)
end

if cfg.autoBlock then
    RunService.Heartbeat:Connect(function()
        local enemy, ball, hrp = nearestEnemy(), getBall(), getHRP()
        if not enemy or not ball or not hrp then return end
        local erp = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
        if erp and (erp.Position - ball.Position).Magnitude < 12 and ball.Position.Y > 18 then
            hrp.CFrame = CFrame.new(
                erp.Position + Vector3.new(0,5,(mySide()==1 and -4 or 4))
            )
        end
    end)
end

if cfg.infJump then
    RunService.Heartbeat:Connect(function()
        local hum = getHum()
        if hum and hum.FloorMaterial == Enum.Material.Air then
            hum.JumpPower = 60
        end
    end)
end

if cfg.speedMul > 1 then
    local function apply()
        local hum = getHum()
        if hum then hum.WalkSpeed = 16 * cfg.speedMul end
    end
    apply()
    lp.CharacterAdded:Connect(apply)
end

-- ===============================
-- EXTENDED RAGE SYSTEM (ADD-ON)
-- ===============================
local Rage = {
    enabled = true,
    humanize = true,
    maxActionsPerSec = 18,
    lastAction = 0
}

local function canAct()
    local t = os.clock()
    if t - Rage.lastAction < (1 / Rage.maxActionsPerSec) then
        return false
    end
    Rage.lastAction = t
    return true
end

local function randDelay(min, max)
    if not Rage.humanize then return end
    task.wait(math.random(min*100, max*100)/1000)
end

local function predictBall(ball, timeAhead)
    if not ball then return end
    return ball.Position + ball.AssemblyLinearVelocity * timeAhead
end

task.spawn(function()
    while task.wait(0.1) do
        if not cfg.autoFarm then continue end
        local ball, hrp = getBall(), getHRP()
        if not ball or not hrp then continue end
        local predicted = predictBall(ball, 0.35)
        if predicted then
            hrp.CFrame = hrp.CFrame:Lerp(
                CFrame.new(predicted.X, hrp.Position.Y, predicted.Z), 0.35
            )
        end
    end
end)

task.spawn(function()
    while task.wait(0.03) do
        if not cfg.autoSpike or not Rage.enabled or not canAct() then continue end
        local ball, hrp = getBall(), getHRP()
        if not ball or not hrp then continue end
        if ball.Position.Y > 15 then
            hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0,-2.5,0))
            randDelay(5,15)
            local spike = getChar():FindFirstChild("Spike", true)
            if spike then spike:FireServer() end
        end
    end
end)

-- ===============================
-- BALL TRAJECTORY
-- ===============================
local beam
task.spawn(function()
    while task.wait(0.1) do
        if not cfg.ballTracker then
            if beam then beam:Destroy() beam=nil end
            continue
        end
        local ball = getBall()
        if not ball then continue end
        if not beam then
            beam = Instance.new("Beam", ball)
            local a0 = Instance.new("Attachment", ball)
            local a1 = Instance.new("Attachment", ball)
            beam.Attachment0 = a0
            beam.Attachment1 = a1
            beam.Width0 = 0.15
            beam.Width1 = 0.05
            beam.Color = ColorSequence.new(cfg.ballColor)
        end
        local future = predictBall(ball, 0.6)
        if future then
            beam.Attachment1.WorldPosition = future
        end
    end
end)

-- ===============================
-- MOBILE QUICK GUI
-- ===============================
local gui = Instance.new("ScreenGui", lp.PlayerGui)
gui.Name = "VL_RAGE_GUI"
gui.ResetOnSpawn = false

local btn = Instance.new("TextButton", gui)
btn.Size = UDim2.new(0,140,0,50)
btn.Position = UDim2.new(0,20,0.6,0)
btn.Text = "RAGE: ON"
btn.BackgroundColor3 = Color3.fromRGB(180,0,0)
btn.TextColor3 = Color3.new(1,1,1)
btn.TextScaled = true
btn.Active = true
btn.Draggable = true

btn.MouseButton1Click:Connect(function()
    Rage.enabled = not Rage.enabled
    cfg.autoFarm = Rage.enabled
    cfg.autoSpike = Rage.enabled
    btn.Text = Rage.enabled and "RAGE: ON" or "RAGE: OFF"
end)

-- ===============================
-- ANTI AFK + AUTO REJOIN
-- ===============================
task.spawn(function()
    while task.wait(45) do
        local hrp = getHRP()
        if hrp then
            hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(2), 0)
        end
    end
end)

task.spawn(function()
    while task.wait(5) do
        if #Players:GetPlayers() <= 1 then
            TP:Teleport(game.PlaceId, lp)
        end
    end
end)