-- main.lua | VL HUB CORE
-- NÃO EXECUTA SOZINHO — carregado pelo ui.lua

local Core = {}

-- ===============================
-- SERVICES
-- ===============================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local TP = game:GetService("TeleportService")

local lp = Players.LocalPlayer

-- ===============================
-- CONFIG GLOBAL (EDITADA PELA UI)
-- ===============================
Core.Config = {
    AutoSpike   = false,
    AutoReceive = false,
    AutoBlock   = false,
    AutoFarm    = false,
    InfJump     = false,
    SpeedMul    = 1,
    BallTracker = false,
    AntiAFK     = true,

    ESPEnabled  = false,
    ESPColor    = Color3.fromRGB(0,255,0),
    BallColor   = Color3.fromRGB(255,0,255)
}

-- ===============================
-- UTILS
-- ===============================
local function getChar()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function getHRP()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
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
    return hrp and sideFromZ(hrp.Position.Z) or 0
end

local function ballSide(ball)
    return ball and sideFromZ(ball.Position.Z) or 0
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
-- MAIN LOOP (OTIMIZADO)
-- ===============================
RunService.Heartbeat:Connect(function()
    local cfg = Core.Config
    local ball = getBall()
    local hrp  = getHRP()
    local hum  = getHum()

    if not hrp or not hum then return end

    -- INF JUMP
    if cfg.InfJump and hum.FloorMaterial == Enum.Material.Air then
        hum.JumpPower = 65
    end

    -- SPEED
    hum.WalkSpeed = 16 * cfg.SpeedMul

    -- AUTO RECEIVE
    if cfg.AutoReceive and ball and mySide() == ballSide(ball) and ball.Position.Y < 15 then
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(ball.Position + Vector3.new(0,-1,0)), 0.2
        )
    end

    -- AUTO SPIKE
    if cfg.AutoSpike and ball and mySide() ~= ballSide(ball) and ball.Position.Y > 14 then
        hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0,-2,0))
    end

    -- AUTO BLOCK
    if cfg.AutoBlock and ball then
        local enemy = nearestEnemy()
        if enemy and enemy.Character then
            local erp = enemy.Character:FindFirstChild("HumanoidRootPart")
            if erp and (erp.Position - ball.Position).Magnitude < 12 then
                hrp.CFrame = CFrame.new(
                    erp.Position + Vector3.new(0,5,(mySide()==1 and -4 or 4))
                )
            end
        end
    end

    -- AUTO FARM (SMART FOLLOW BALL)
    if cfg.AutoFarm and ball then
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(ball.Position.X, hrp.Position.Y, ball.Position.Z), 0.15
        )
    end
end)

-- ===============================
-- ANTI AFK
-- ===============================
task.spawn(function()
    while task.wait(40) do
        if Core.Config.AntiAFK then
            local hrp = getHRP()
            if hrp then
                hrp.CFrame *= CFrame.Angles(0, math.rad(5), 0)
            end
        end
    end
end)

return Core