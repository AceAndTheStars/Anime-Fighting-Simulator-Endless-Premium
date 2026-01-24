-- ABAPremium.lua - Auto Best Area TP ONLY (NO auto-training)
-- Keeps all teleport logic, portal clicks, tier detection, respawn handling
-- Removed: all training RemoteEvent fires and TrainingActive logic

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvent")

-- Entrance positions (unchanged)
local EntrancePositions = {
    Strength = {
        Vector3.new(-6.535,    65.000,  127.964),
        Vector3.new(1341.183, 153.963, -134.552),
        Vector3.new(-1247.836,  59.000, 481.151),
        Vector3.new(-905.422,   84.882, 170.033),
        Vector3.new(-2257.115, 617.105, 546.753),
        Vector3.new(-51.014,    63.736, -1302.732),
        Vector3.new(714.433,   151.732, 926.474),
        Vector3.new(1846.153,  141.200,  90.468),
        Vector3.new(604.720,   653.458, 413.728),
        Vector3.new(4284.651,   60.000, -534.592),
        Vector3.new(797.981,   232.382, -1002.742),
        Vector3.new(3873.921,  136.388, 855.103),
        Vector3.new(3933.355,  724.772, -1197.858),
        Vector3.new(2317.814,  261.246, -625.500),
        Vector3.new(-2359.330, 411.794, 1795.281),
        Vector3.new(-2101.241,1484.821, -2167.363),
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

-- Inside positions (unchanged)
local InsidePositions = {
    Durability = {
        [8] = Vector3.new(-2695.975, -229.010, 352.760),  -- 100B Durability inside
    },
    Chakra = {
        [12] = Vector3.new(3254.880, -440.978, -242.199),  -- 1qn Chakra inside
    },
    SpeedAgility = {
        [2] = Vector3.new(-416.484, 121.465, -77.764),     -- 10K Speed & Agility inside
    }
}

-- Tier thresholds (unchanged)
local TierRequirements = {
    0, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 100000000000,
    5000000000000, 250000000000000, 50000000000000000, 1000000000000000000,
    100000000000000000000, 1000000000000000000000, 100000000000000000000000,
    1000000000000000000000000
}

-- Portal click paths (unchanged)
local PortalMap = {
    Durability = { [8] = "DragonTeleport" },
    Chakra = { [12] = "Ighicho" },
    SpeedAgility = { [2] = "ThePodTeleport" }
}

-- ────────────────────────────────────────────────
-- Stat value & best tier logic (unchanged)
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

local function GetBestEntrancePosition(statName)
    local key, positionsKey
    if statName == "Strength"   then key, positionsKey = "1", "Strength"
    elseif statName == "Durability" then key, positionsKey = "2", "Durability"
    elseif statName == "Chakra" then key, positionsKey = "3", "Chakra"
    elseif statName == "Speed"  then key, positionsKey = "5", "SpeedAgility"
    elseif statName == "Agility" then key, positionsKey = "6", "SpeedAgility"
    else return nil end

    local current = GetStatValue(key)
    if current <= 0 then return EntrancePositions[positionsKey][1] end

    local index = GetBestTierIndex(current)
    local pos = EntrancePositions[positionsKey][index] or EntrancePositions[positionsKey][1]
    return pos
end

-- ────────────────────────────────────────────────
-- Teleport + portal logic ONLY (no training)
-- ────────────────────────────────────────────────

local function teleportToBest(statName)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Get current best tier
    local statKey = (statName == "Speed" or statName == "Agility") and "SpeedAgility" or statName
    local current = GetStatValue(
        statName == "Speed" and "5" or
        statName == "Agility" and "6" or
        statName == "Strength" and "1" or
        statName == "Durability" and "2" or "3"
    )
    local tierIndex = GetBestTierIndex(current)

    -- Get entrance and inside positions
    local entrancePos = GetBestEntrancePosition(statName)
    if not entrancePos then return end

    local insidePos = InsidePositions[statKey] and InsidePositions[statKey][tierIndex]

    -- Decide current target
    local targetPos = insidePos or entrancePos

    local dist = (hrp.Position - targetPos).Magnitude

    -- If already close → just stay (no training starts)
    if dist <= 45 then
        return
    end

    -- Teleport to current target
    hrp.CFrame = CFrame.new(targetPos)

    -- If we need to click portal (only when targeting entrance)
    if not insidePos and PortalMap[statKey] then
        local portalPath = PortalMap[statKey][tierIndex]
        if portalPath then
            task.spawn(function()
                task.wait(1.5)
                pcall(function()
                    local folder = workspace:WaitForChild("Scriptable", 8):WaitForChild("NPC", 8):WaitForChild("Teleport", 8)
                    local clickDetector = folder:WaitForChild(portalPath, 5):WaitForChild("ClickBox", 5):WaitForChild("ClickDetector", 3)
                    if clickDetector then
                        fireclickdetector(clickDetector)
                    end
                end)
            end)
        end

        -- Wait for teleport inside
        task.wait(3)
    end
end

-- ────────────────────────────────────────────────
-- Loop & toggle control (0.1s delay, no training)
-- ────────────────────────────────────────────────

local Loops = {
    Strength   = { Active = false },
    Durability = { Active = false },
    Chakra     = { Active = false },
    Speed      = { Active = false },
    Agility    = { Active = false }
}

local function StartTp(statName)
    local loop = Loops[statName]
    if loop.Active then return end
    loop.Active = true

    task.spawn(function()
        while loop.Active do
            local char = LocalPlayer.Character
            if not char then 
                task.wait(0.5) 
                continue 
            end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then 
                task.wait(0.5) 
                continue 
            end

            teleportToBest(statName)

            task.wait(0.1)
        end
    end)
end

local function StopTp(statName)
    local loop = Loops[statName]
    if loop then
        loop.Active = false
    end
end

-- Toggle functions (unchanged names so main script still works)
_G.ToggleAutoTpBestStrength   = function(v) if v then StartTp("Strength")   else StopTp("Strength")   end end
_G.ToggleAutoTpBestDurability = function(v) if v then StartTp("Durability") else StopTp("Durability") end end
_G.ToggleAutoTpBestChakra     = function(v) if v then StartTp("Chakra")     else StopTp("Chakra")     end end
_G.ToggleAutoTpBestSpeed      = function(v) if v then StartTp("Speed")      else StopTp("Speed")      end end
_G.ToggleAutoTpBestAgility    = function(v) if v then StartTp("Agility")    else StopTp("Agility")    end end

-- Cleanup on death/respawn (no training to stop anymore)
LocalPlayer.CharacterRemoving:Connect(function()
    -- Nothing needed here anymore since no TrainingActive
end)