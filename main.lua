-- main.lua – VL Core (FIXED & OPTIMIZED)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===============================
-- STATE
-- ===============================
local State = {
    AutoSpike = true,
    AutoReceive = true,
    AutoFarm = true,
    BallTracker = true
}

-- ===============================
-- UTILS
-- ===============================
local function Char()
    return lp.Character or lp.CharacterAdded:Wait()
end

local function HRP()
    return Char():FindFirstChild("HumanoidRootPart")
end

local function Hum()
    return Char():FindFirstChildOfClass("Humanoid")
end

local function getBall()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("ball") then
            return v
        end
    end
end

local function predict(ball, t)
    return ball.Position + ball.AssemblyLinearVelocity * t
end

local function mySide()
    local hrp = HRP()
    if not hrp then return 0 end
    return hrp.Position.Z > 0 and 1 or 2
end

local function ballSide(ball)
    return ball.Position.Z > 0 and 1 or 2
end

-- ===============================
-- BALL TRACKER (FIXED)
-- ===============================
local beam, a0, a1

local function updateTracker(ball)
    if not beam then
        a0 = Instance.new("Attachment", ball)
        a1 = Instance.new("Attachment", ball)

        beam = Instance.new("Beam")
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = 0.15
        beam.Width1 = 0.05
        beam.Color = ColorSequence.new(Color3.fromRGB(255,0,255))
        beam.Parent = ball
    end

    local future = predict(ball, 0.6)
    a1.WorldPosition = future
end

-- ===============================
-- ACTION CONTROLLER
-- ===============================
local lastAction = 0
local function canAct(delay)
    if os.clock() - lastAction < delay then return false end
    lastAction = os.clock()
    return true
end

-- ===============================
-- CORE LOOP
-- ===============================
RunService.Heartbeat:Connect(function()
    local ball = getBall()
    local hrp = HRP()
    if not ball or not hrp then return end

    -- BALL TRACKER
    if State.BallTracker then
        updateTracker(ball)
    end

    local velY = ball.AssemblyLinearVelocity.Y
    local dist = (ball.Position - hrp.Position).Magnitude

    -- ===========================
    -- AUTO SPIKE (PRIORIDADE 1)
    -- ===========================
    if State.AutoSpike
        and velY < -6
        and ball.Position.Y > 10
        and dist < 6
        and mySide() ~= ballSide(ball)
        and canAct(0.35)
    then
        hrp.CFrame = CFrame.new(ball.Position + Vector3.new(0,-2,0))

        for _,v in ipairs(Char():GetDescendants()) do
            if v:IsA("RemoteEvent") and v.Name:lower():find("spike") then
                v:FireServer()
                return
            end
        end
    end

    -- ===========================
    -- AUTO RECEIVE (PRIORIDADE 2)
    -- ===========================
    if State.AutoReceive
        and velY < 0
        and mySide() == ballSide(ball)
    then
        local target = predict(ball, 0.35)
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(target.X, hrp.Position.Y, target.Z),
            0.25
        )
        return
    end

    -- ===========================
    -- AUTO FARM (PRIORIDADE 3)
    -- ===========================
    if State.AutoFarm then
        local target = predict(ball, 0.2)
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(target.X, hrp.Position.Y, target.Z),
            0.15
        )
    end
end)

return State