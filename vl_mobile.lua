-- vl_mobile.lua – Mobile GUI Edition
-- Repo: cole inteiro e use raw.githubusercontent link no Delta mobile
local players = game:GetService("Players")
local run     = game:GetService("RunService")
local input   = game:GetService("UserInputService")
local tween   = game:GetService("TweenService")
local tp      = game:GetService("TeleportService")

local lp      = players.LocalPlayer
local mouse   = lp:GetMouse()

-- ===== CONFIG =====
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
    espColor    = Color3.new(0,1,0),
    ballColor   = Color3.new(1,0,1),
    thickness   = 2
}
-- ==================

-- ===== UTILS =====
local function getBall()
    for _,v in ipairs(workspace:GetChildren()) do
        if v.Name:lower():find("ball") and v:IsA("BasePart") then return v end
    end
end

local function getCourtSide(part)
    if part and part.Name:lower():find("blue") then return 1 end
    if part and part.Name:lower():find("red")  then return 2 end
    return 0
end

local function mySide()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return 0 end
    return getCourtSide(root.Position.Z > 0 and workspace:FindFirstChild("BlueCourt") or workspace:FindFirstChild("RedCourt"))
end

local function nearestEnemy()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local enemy, dist = nil, math.huge
    for _,p in ipairs(players:GetPlayers()) do
        if p == lp or (p.Team and p.Team == lp.Team) then continue end
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local d = (r.Position - root.Position).Magnitude
            if d < dist then enemy, dist = p, d end
        end
    end
    return enemy
end

-- ===== FEATURES (mesmo código desktop, mas ativado por cfg) =====
if cfg.autoSpike then
    run.Heartbeat:Connect(function()
        local ball = getBall()
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not ball or not root then return end
        local bv = ball:FindFirstChildOfClass("BodyVelocity") or ball:FindFirstChild("Velocity")
        if not bv then return end
        if bv.Velocity.Y < -6 and ball.Position.Y < 12 and mySide() ~= getCourtSide(ball.Position.Z > 0) then
            root.CFrame = CFrame.new(Vector3.new(ball.Position.X, ball.Position.Y - 2, ball.Position.Z))
            wait(0.05)
            local rem = lp.Character and lp.Character:FindFirstChild("Spike", true)
            if rem and rem:IsA("RemoteEvent") then rem:FireServer() end
        end
    end)
end

if cfg.autoReceive then
    run.Heartbeat:Connect(function()
        local ball = getBall()
        local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if not ball or not root then return end
        if ball.Position.Y < 14 and mySide() == getCourtSide(ball.Position.Z > 0) then
            root.CFrame = CFrame.new(Vector3.new(ball.Position.X, ball.Position.Y - 1, ball.Position.Z))
        end
    end)
end

if cfg.autoBlock then
    run.Heartbeat:Connect(function()
        local enemy = nearestEnemy()
        local ball = getBall()
        if not enemy or not ball then return end
        local r = enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart")
        if r and (r.Position - ball.Position).Magnitude < 10 and ball.Position.Y > 20 then
            local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if root then
                root.CFrame = CFrame.new(r.Position + Vector3.new(0, 5, enemy.Team.Name:lower():find("blue") and 5 or -5))
            end
        end
    end)
end

if cfg.infJump then
    local function hook()
        local hum = lp.Character and lp.Character:WaitForChild("Humanoid")
        if hum then
            run.Heartbeat:Connect(function()
                if input:IsKeyDown(Enum.KeyCode.Space) then
                    hum.JumpPower = 60
                    hum.Jump = true
                end
            end)
        end
    end
    hook()
    lp.CharacterAdded:Connect(hook)
end

if cfg.speedMul > 1 then
    local function apply()
        local hum = lp.Character and lp.Character:WaitForChild("Humanoid")
        if hum then hum.WalkSpeed = 32 * cfg.speedMul end
    end
    apply()
    lp.CharacterAdded:Connect(apply)
end

if cfg.ballTracker then
    local ball = getBall()
    if ball then
        local hl = Instance.new("Highlight")
        hl.Name = "BallHL"
        hl.FillColor = cfg.ballColor
        hl.OutlineColor = cfg.ballColor
        hl.FillTransparency = 0.5
        hl.Parent = ball
    end
end

if cfg.playerESP then
    local function addEsp(p)
        if p == lp then return end
        local ch = p.Character or p.CharacterAdded:Wait()
        local hl = Instance.new("Highlight")
        hl.Name = p.Name.."_ESP"
        hl.FillColor = cfg.espColor
        hl.OutlineColor = cfg.espColor
        hl.FillTransparency = 0.75
        hl.Parent = ch:WaitForChild("HumanoidRootPart")
        local bbg = Instance.new("BillboardGui")
        bbg.Name = p.Name.."_TAG"
        bbg.AlwaysOnTop = true
        bbg.Size = UDim2.new(0,200,0,50)
        bbg.StudsOffset = Vector3.new(0,3,0)
        local txt = Instance.new("TextLabel")
        txt.Text = p.Name.."\n"..math.floor((ch:WaitForChild("HumanoidRootPart").Position - lp.Character:WaitForChild("HumanoidRootPart").Position).Magnitude).."m"
        txt.Size = UDim2.new(1,0,1,0)
        txt.TextColor3 = cfg.espColor
        txt.BackgroundTransparency = 1
        txt.Parent = bbg
        bbg.Parent = ch:WaitForChild("HumanoidRootPart")
        spawn(function()
            while wait(0.3) do
                if not ch.Parent then break end
                txt.Text = p.Name.."\n"..math.floor((ch.HumanoidRootPart.Position - lp.Character.HumanoidRootPart.Position).Magnitude).."m"
            end
        end)
    end
    for _,p in ipairs(players:GetPlayers()) do addEsp(p) end
    players.PlayerAdded:Connect(addEsp)
end

if cfg.antiAFK then
    spawn(function()
        while wait(50) do
            lp.Character:WaitForChild("HumanoidRootPart").CFrame = lp.Character.HumanoidRootPart.CFrame * CFrame.Angles(0,math.
