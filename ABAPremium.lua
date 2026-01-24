-- ABAPremium.lua - Auto Best Area TP + Manual Training Loop (self-contained)
-- Updated with NEW high-end tiers 2026 + Portal Auto-Click + Built-in Training

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvent")

-- Positions - exact coordinates (no offset added)
local TrainingPositions = {
    Strength = {
        Vector3.new(-6.535,    65.000,  127.964),   -- 1: [100]
        Vector3.new(1341.183, 153.963, -134.552),   -- 2: [10K]
        Vector3.new(-1247.836,  59.000, 481.151),   -- 3: [100K]
        Vector3.new(-905.422,   84.882, 170.033),   -- 4: [1M]
        Vector3.new(-2257.115, 617.105, 546.753),   -- 5: [10M]
        Vector3.new(-51.014,    63.736, -1302.732), -- 6: [100M]
        Vector3.new(714.433,   151.732, 926.474),   -- 7: [1B]
        Vector3.new(1846.153,  141.200,  90.468),   -- 8: [100B]
        Vector3.new(604.720,   653.458, 413.728),   -- 9: [5T]
        Vector3.new(4284.651,   60.000, -534.592),  -- 10: [250T]
        Vector3.new(797.981,   232.382, -1002.742), -- 11: [50qd]
        Vector3.new(3873.921,  136.388, 855.103),   -- 12: [1qn]
        Vector3.new(3933.355,  724.772, -1197.858), -- 13: [100QN]
        Vector3.new(2317.814,  261.246, -625.500),  -- 14: [1sx]
        Vector3.new(-2359.330, 411.794, 1795.281),  -- 15: [100sx]
        Vector3.new(-2101.241,1484.821, -2167.363), -- 16: [1SP]
    },
    Durability = {
        Vector3.new(72.340,    69.263,  877.353),
        Vector3.new(-1602.088, 61.502, -532.064),
        Vector3.new(-77.845,   61.008, 2037.284),
        Vector3.new(-621.543,  179.000, 741.890),
        Vector3.new(-1102.311, 212.630, -946.145),
        Vector3.new(-341.295,   72.620, -1653.579),
        Vector3.new(2495.276, 1540.875, -356.906),
        Vector3.new(-2171.543, 617.517, 525.640),
        Vector3.new(2188.043,  518.649, 576.627),
        Vector3.new(1671.975,  423.930, -1291.617),
        Vector3.new(165.322,   773.591, -716.061),
        Vector3.new(2590.823,   63.229, 1697.295),
        Vector3.new(1726.687, 2305.067,  61.937),
        Vector3.new(3485.344,  274.992, 1443.937),
        Vector3.new(-2313.594,  84.296,  -83.242),
        Vector3.new(-1182.596,  82.653, -1886.213),
    },
    Chakra = {
        Vector3.new(-3.768,    65.000, -117.034),
        Vector3.new(1423.010,  147.000, -582.122),
        Vector3.new(917.247,   141.000, 781.455),
        Vector3.new(1576.373,  388.750, 675.160),
        Vector3.new(334.134,  -129.590, -1840.660),
        Vector3.new(1028.428,  251.000, -627.812),
        Vector3.new(3053.941,  110.900, 1105.880),
        Vector3.new(1552.188,   88.724, 1717.498),
        Vector3.new(-17.094,    62.073, -478.995),
        Vector3.new(-396.257, 1237.356, 670.550),
        Vector3.new(-737.839, 2792.597, 567.334),
        Vector3.new(3151.687,  163.000, -102.653),
        Vector3.new(358.822,   292.742, 1864.116),
        Vector3.new(-1092.224, 613.690, 1486.990),
        Vector3.new(1412.806,  232.000, -729.297),
        Vector3.new(3346.103,   59.500, -1654.329),
    },
    SpeedAgility = {
        Vector3.new(-104.639,  61.000, -508.363),
        Vector3.new(-386.277, 105.000, -47.382),
        Vector3.new(3484.517,  60.000, 144.701),
        Vector3.new(4111.812,  60.922, 849.557),
    }
}

-- Tier thresholds
local TierRequirements = {
    0, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 100000000000,
    5000000000000, 250000000000000, 50000000000000000, 1000000000000000000,
    100000000000000000000, 1000000000000000000000, 100000000000000000000000,
    1000000000000000000000000
}

-- Portal click paths for premium tiers
local PortalMap = {
    Durability = { [8] = "DragonTeleport" },
    Chakra = { [12] = "Ighicho" },
    SpeedAgility = { [2] = "ThePodTeleport" }
}

-- ────────────────────────────────────────────────
-- Training loop helpers (self-contained)
-- ────────────────────────────────────────────────

local TrainingActive = {
    Strength   = false,
    Durability = false,
    Chakra     = false,
    Speed      = false,
    Agility    = false
}

local function GetTrainId(statName)
    if statName == "Strength"   then return 1 end
    if statName == "Durability" then return 2 end
    if statName == "Chakra"     then return 3 end
    if statName == "Speed"      then return 5 end
    if statName == "Agility"    then return 6 end
    return nil
end

local function StartTraining(statName)
    if TrainingActive[statName] then return end
    TrainingActive[statName] = true

    task.spawn(function()
        while TrainingActive[statName] do
            local id = GetTrainId(statName)
            if id then
                pcall(function()
                    if statName == "Speed" or statName == "Agility" then
                        RemoteEvent:FireServer("Train", 5)
                        RemoteEvent:FireServer("Train", 6)
                    else
                        RemoteEvent:FireServer("Train", id)
                    end
                end)
            end
            task.wait(0.08 + math.random()/20)  -- slight jitter ~0.08–0.13s
        end
    end)
end

local function StopTraining(statName)
    TrainingActive[statName] = false
end

-- ────────────────────────────────────────────────
-- Stat value & best tier logic
-- ────────────────────────────────────────────────

local function GetStatValue(key)
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats then return 0 end
    local obj = stats:FindFirstChild(key)
    return (obj and (obj:IsA("IntValue") or obj:IsA("NumberValue"))) and obj.Value or 0
end

local function GetBestTierIndex(current)
    local bestIndex = 1
    for i = #TierRequirements, 1, -1 do
        if current >= TierRequirements[i] then
            bestIndex = i
            break
        end
    end
    return bestIndex
end

local function GetBestPosition(statName)
    local key, positionsKey
    if statName == "Strength"   then key, positionsKey = "1", "Strength"
    elseif statName == "Durability" then key, positionsKey = "2", "Durability"
    elseif statName == "Chakra" then key, positionsKey = "3", "Chakra"
    elseif statName == "Speed"  then key, positionsKey = "5", "SpeedAgility"
    elseif statName == "Agility" then key, positionsKey = "6", "SpeedAgility"
    else return nil end

    local current = GetStatValue(key)
    if current <= 0 then return TrainingPositions[positionsKey][1] end

    local index = GetBestTierIndex(current)
    local pos = TrainingPositions[positionsKey][index] or TrainingPositions[positionsKey][1]
    return pos
end

-- ────────────────────────────────────────────────
-- Teleport + portal + START TRAINING when close
-- ────────────────────────────────────────────────

local function teleportToBest(statName)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = GetBestPosition(statName)
    if not targetPos then return end

    local dist = (hrp.Position - targetPos).Magnitude

    if dist <= 45 then
        -- Already in zone → ensure training is active
        StartTraining(statName)
        return
    end

    -- Exact teleport (no offset)
    hrp.CFrame = CFrame.new(targetPos)

    -- Portal auto-click if required for this tier
    local statKey = (statName == "Speed" or statName == "Agility") and "SpeedAgility" or statName
    local statMap = PortalMap[statKey]
    if statMap then
        local current = GetStatValue(
            statName == "Speed" and "5" or
            statName == "Agility" and "6" or
            statName == "Strength" and "1" or
            statName == "Durability" and "2" or "3"
        )
        local tierIndex = GetBestTierIndex(current)
        local portalPath = statMap[tierIndex]

        if portalPath then
            task.spawn(function()
                task.wait(1.2)  -- wait for area/portal to load
                pcall(function()
                    local folder = workspace:WaitForChild("Scriptable"):WaitForChild("NPC"):WaitForChild("Teleport")
                    local clickDetector = folder:WaitForChild(portalPath):WaitForChild("ClickBox"):WaitForChild("ClickDetector")
                    fireclickdetector(clickDetector)
                end)
            end)
        end
    end

    -- Short delay after teleport before starting training
    task.delay(1.5, function()
        if char and hrp and (hrp.Position - targetPos).Magnitude <= 60 then
            StartTraining(statName)
        end
    end)
end

-- ────────────────────────────────────────────────
-- Loop & toggle control
-- ────────────────────────────────────────────────

local Loops = {
    Strength   = { Active = false, Connection = nil },
    Durability = { Active = false, Connection = nil },
    Chakra     = { Active = false, Connection = nil },
    Speed      = { Active = false, Connection = nil },
    Agility    = { Active = false, Connection = nil }
}

local function StartTp(statName)
    local loop = Loops[statName]
    if loop.Active then return end
    loop.Active = true

    loop.Connection = RunService.Heartbeat:Connect(function()
        if not loop.Active then
            StopTraining(statName)
            return
        end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        teleportToBest(statName)
    end)
end

local function StopTp(statName)
    local loop = Loops[statName]
    if not loop.Active then return end
    loop.Active = false
    if loop.Connection then
        loop.Connection:Disconnect()
        loop.Connection = nil
    end
    StopTraining(statName)
end

-- Toggle functions
_G.ToggleAutoTpBestStrength   = function(v) if v then StartTp("Strength")   else StopTp("Strength")   end end
_G.ToggleAutoTpBestDurability = function(v) if v then StartTp("Durability") else StopTp("Durability") end end
_G.ToggleAutoTpBestChakra     = function(v) if v then StartTp("Chakra")     else StopTp("Chakra")     end end
_G.ToggleAutoTpBestSpeed      = function(v) if v then StartTp("Speed")      else StopTp("Speed")      end end
_G.ToggleAutoTpBestAgility    = function(v) if v then StartTp("Agility")    else StopTp("Agility")    end end

-- Cleanup on death/respawn
LocalPlayer.CharacterRemoving:Connect(function()
    for _, l in pairs(Loops) do
        if l.Active and l.Connection then
            l.Connection:Disconnect()
        end
    end
    for stat in pairs(TrainingActive) do
        StopTraining(stat)
    end
end)