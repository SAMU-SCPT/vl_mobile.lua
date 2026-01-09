-- main.lua – VL CORE PRO (RAGE/PRO)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local lp = Players.LocalPlayer

-- ===============================
-- STATE CONTROLADO PELA UI
-- ===============================
local State = {
    AutoSpike   = false,
    AutoBlock   = false,
    AutoReceive = false,
    AutoFarm    = false,
    AutoServe   = false,
    BallTracker = false,
    Speed       = 30,
    MaxSpeed    = 60
}

-- ===============================
-- UTILS
-- ===============================
local function Char() return lp.Character or lp.CharacterAdded:Wait() end
local function HRP() return Char():FindFirstChild("HumanoidRootPart") end
local function Hum() return Char():FindFirstChildOfClass("Humanoid") end

local function getBall()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("ball") then
            v.CanCollide = true -- aumentar colisão
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

local function nearestEnemy()
    local hrp = HRP()
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
-- BALL TRACKER (VISUAL)
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
        beam.Color = ColorSequence.new(Color3.fromRGB(0,255,0))
        beam.Parent = ball
    end
    a1.WorldPosition = predict(ball,0.6)
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

    -- SPEED
    hum.WalkSpeed = State.Speed

    -- BALL TRACKER
    updateTracker(ball)

    -- DISTÂNCIAS
    local dist = (ball.Position - hrp.Position).Magnitude
    local velY = ball.AssemblyLinearVelocity.Y
    local enemy = nearestEnemy()

    -- ===========================
    -- AUTO SERVE
    -- ===========================
    if State.AutoServe then
        local serveRemote = Char():FindFirstChild("Serve",true)
        if serveRemote and canAct(0.5) then
            hrp.CFrame = CFrame.new(0,hrp.Position.Y,-20) -- posição de serve padrão
            serveRemote:FireServer()
            return
        end
    end

    -- ===========================
    -- AUTO SPIKE
    -- ===========================
    if State.AutoSpike then
        -- mover lateralmente pro campo
        local targetX = ball.Position.X
        local targetZ = mySide()==1 and 25 or -25
        hrp.CFrame = CFrame.new(targetX,hrp.Position.Y,targetZ)

        -- pular se bola acima
        if velY > 1 then
            hum.JumpPower = 60
            hum.Jump = true
        end

        -- spikar quando bola baixa (Y <=1)
        if ball.Position.Y <= 1 and dist < 5 and canAct(0.35) then
            for _,v in ipairs(Char():GetDescendants()) do
                if v:IsA("RemoteEvent") and v.Name:lower():find("spike") then
                    v:FireServer()
                    return
                end
            end
        end
    end

    -- ===========================
    -- AUTO BLOCK
    -- ===========================
    if State.AutoBlock and enemy then
        if ballSide(ball) ~= mySide() then
            local targetX = ball.Position.X
            local targetZ = mySide()==1 and 25 or -25
            hrp.CFrame = CFrame.new(targetX,hrp.Position.Y,targetZ)
            if velY > 1 then
                hum.JumpPower = 60
                hum.Jump = true
            end
        end
    end

    -- ===========================
    -- AUTO RECEIVE / FARM
    -- ===========================
    if State.AutoReceive or State.AutoFarm then
        local target = predict(ball,0.2)
        hrp.CFrame = hrp.CFrame:Lerp(CFrame.new(target.X,hrp.Position.Y,target.Z),0.15)
    end

end)

return State