-- main.lua –- VL Mobile Core
-- NÃO remover nada / compatível com Delta Mobile

-- ===============================
-- SERVICES
-- ===============================
local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS        = game:GetService("UserInputService")
local TP         = game:GetService("TeleportService")

local lp = Players.LocalPlayer

-- ===============================
-- CONFIG (COMPARTILHADO COM UI)
-- ===============================
getgenv().VL_CFG = {
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
    rage        = true,

    espColor  = Color3.fromRGB(0,255,0),
    ballColor = Color3.fromRGB(255,0,255),
}

local cfg = getgenv().VL_CFG

-- ===============================
-- UTILS
-- ===============================
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    return getChar():WaitForChild("HumanoidRootPart")
end

local function getHum()
    return getChar():WaitForChild("Humanoid")
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
    return sideFromZ(getHRP().Position.Z)
end

local function ballSide(ball)
    return sideFromZ(ball.Position.Z)
end

local function nearestEnemy()
    local hrp = getHRP()
    local enemy, dist = nil, math.huge
    for _,p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
            if d < dist then
                enemy, dist = p, d
            end
        end
    end
    return enemy
end

-- ===============================
-- AUTO SPIKE
-- ===============================
RunService.Heartbeat:Connect(function()
    if not cfg.autoSpike then return end
    local ball = getBall()
    if not ball then return end

    if ball.AssemblyLinearVelocity.Y < -6 and ball.Position.Y < 14 then
        if mySide() ~= ballSide(ball) then
            getHRP().CFrame = CFrame.new(ball.Position + Vector3.new(0,-2,0))
            task.wait(0.05)
            for _,v in ipairs(getChar():GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("spike") then
                    v:FireServer()
                end
            end
        end
    end
end)

-- ===============================
-- AUTO RECEIVE
-- ===============================
RunService.Heartbeat:Connect(function()
    if not cfg.autoReceive then return end
    local ball = getBall()
    if not ball then return end
    if ball.Position.Y < 15 and mySide() == ballSide(ball) then
        getHRP().CFrame = getHRP().CFrame:Lerp(
            CFrame.new(ball.Position + Vector3.new(0,-1,0)), 0.25
        )
    end
end)

-- ===============================
-- AUTO BLOCK
-- ===============================
RunService.Heartbeat:Connect(function()
    if not cfg.autoBlock then return end
    local enemy = nearestEnemy()
    local ball = getBall()
    if not enemy or not ball then return end

    local erp = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
    if erp and (erp.Position - ball.Position).Magnitude < 12 and ball.Position.Y > 18 then
        getHRP().CFrame = CFrame.new(
            erp.Position + Vector3.new(0,5,(mySide()==1 and -4 or 4))
        )
    end
end)

-- ===============================
-- INF JUMP + SPEED
-- ===============================
RunService.Heartbeat:Connect(function()
    if cfg.infJump then
        local hum = getHum()
        if hum.FloorMaterial == Enum.Material.Air then
            hum.JumpPower = 60
        end
    end
end)

local function applySpeed()
    if cfg.speedMul > 1 then
        getHum().WalkSpeed = 16 * cfg.speedMul
    end
end
applySpeed()
lp.CharacterAdded:Connect(applySpeed)

-- ===============================
-- AUTO FARM (PREDIÇÃO)
-- ===============================
task.spawn(function()
    while task.wait(0.1) do
        if not cfg.autoFarm then continue end
        local ball = getBall()
        if not ball then continue end
        local predicted = ball.Position + ball.AssemblyLinearVelocity * 0.35
        getHRP().CFrame = getHRP().CFrame:Lerp(
            CFrame.new(predicted.X, getHRP().Position.Y, predicted.Z), 0.35
        )
    end
end)

-- ===============================
-- ANTI AFK + AUTO REJOIN
-- ===============================
task.spawn(function()
    while task.wait(45) do
        if cfg.antiAFK then
            getHRP().CFrame *= CFrame.Angles(0, math.rad(2), 0)
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

-- ===============================
-- LOAD UI
-- ===============================
loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/SAMU-SCPT/vl_mobile.lua/main/ui.lua"
))()