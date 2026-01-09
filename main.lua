-- main.lua – VL CORE FINAL (UI CONTROLLED)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===============================
-- STATE (CONTROLADO PELA UI)
-- ===============================
local State = {
    AutoSpike   = false,
    AutoReceive = false,
    AutoFarm    = false,
    BallTracker = false,
    Speed       = 16
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
    if not State.BallTracker then
        if beam then beam:Destroy() beam=nil end
        return
    end

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

    a1.WorldPosition = predict(ball, 0.6)
end

-- ===============================
-- ACTION CONTROL (ANTI SPAM)
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
    local hum = Hum()
    if not ball or not hrp or not hum then return end

    -- SPEED EM TEMPO REAL
    hum.WalkSpeed = State.Speed

    -- BALL TRACKER
    updateTracker(ball)

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
        hrp.CFrame = CFrame.new(
            ball.Position.X,
            math.clamp(ball.Position.Y - 2, hrp.Position.Y, ball.Position.Y),
            ball.Position.Z
        )

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
        local target = predict(ball, 0.4)
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(
                target.X,
                math.max(hrp.Position.Y, target.Y - 1),
                target.Z
            ),
            0.3
        )
        return
    end

    -- ===========================
    -- AUTO FARM (PRIORIDADE 3)
    -- ===========================
    if State.AutoFarm then
        local target = predict(ball, 0.25)
        hrp.CFrame = hrp.CFrame:Lerp(
            CFrame.new(target.X, hrp.Position.Y, target.Z),
            0.15
        )
    end
end)

return State