-- ABAPremium.lua - Auto Best Area TP (Updated with Speed & Agility)
-- Conservative: only moves when stat >= threshold

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Positions
local TrainingPositions = {
    Strength = {
        Vector3.new(-6.535,    65.000,  127.964),   -- [100]
        Vector3.new(1341.183, 153.963, -134.552),   -- [10K]
        Vector3.new(-1247.836,  59.000, 481.151),   -- [100K]
        Vector3.new(-905.422,   84.882, 170.033),   -- [1M]
        Vector3.new(-2257.115, 617.105, 546.753),   -- [10M]
        Vector3.new(-51.014,    63.736, -1302.732), -- [100M]
        Vector3.new(714.433,   151.732, 926.474),   -- [1B]
        Vector3.new(1846.153,  141.200,  90.468),   -- [100B]
        Vector3.new(604.720,   653.458, 413.728),   -- [5T]
        Vector3.new(4284.651,   60.000, -534.592),  -- [250T]
        Vector3.new(797.981,   232.382, -1002.742), -- [75qd]
        Vector3.new(3873.921,  136.388, 855.103),   -- [2.5QN]
        Vector3.new(3933.355,  724.772, -1197.858), -- [1sx]
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
    },
    SpeedAgility = {  -- Shared zones for Speed & Agility
        Vector3.new(-104.639,  61.000, -508.363),   -- [100]
        Vector3.new(-386.277, 105.000, -47.382),    -- [10K Speed & Agility]
        Vector3.new(3484.517,  60.000, 144.701),    -- [100K Speed & Agility]
        Vector3.new(4111.812,  60.922, 849.557),    -- [5M Speed & Agility]
        -- Add more tiers later if you find higher ones (50M, 500M, etc.)
    }
}

-- Tier requirements (same pattern)
local TierRequirements = {
    0,           -- 1: [100] or lowest
    10000,       -- 2: [10K]
    100000,      -- 3: [100K]
    5000000,     -- 4: [5M]
    -- No higher — stays at [5M] forever (conservative)
}

-- Get current stat value
local function GetStatValue(key)
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats then return 0 end
    local obj = stats:FindFirstChild(key)
    return (obj and (obj:IsA("IntValue") or obj:IsA("NumberValue"))) and obj.Value or 0
end

-- Find highest allowed tier
local function GetBestTierIndex(current)
    local best = 1
    for i = #TierRequirements, 1, -1 do
        if current >= TierRequirements[i] then
            best = i
            break
        end
    end
    return best
end

-- Get best position
local function GetBestPosition(statName)
    local key, posTable
    if statName == "Strength" then
        key, posTable = "1", "Strength"
    elseif statName == "Durability" then
        key, posTable = "2", "Durability"
    elseif statName == "Chakra" then
        key, posTable = "3", "Chakra"
    elseif statName == "Speed" then
        key, posTable = "5", "SpeedAgility"
    elseif statName == "Agility" then
        key, posTable = "6", "SpeedAgility"
    else
        return nil
    end

    local current = GetStatValue(key)
    if current <= 0 then return TrainingPositions[posTable][1] end

    local index = GetBestTierIndex(current)
    return TrainingPositions[posTable][index] or TrainingPositions[posTable][1]
end

-- Loop controllers
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
        if not loop.Active then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local target = GetBestPosition(statName)
        if not target then return end

        local dist = (hrp.Position - target).Magnitude
        if dist > 45 then
            local offset = Vector3.new(math.random(-6,6), 5, math.random(-6,6))
            hrp.CFrame = CFrame.new(target + offset)
        end
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
end

-- Toggle functions
_G.ToggleAutoTpBestStrength   = function(v) if v then StartTp("Strength")   else StopTp("Strength")   end end
_G.ToggleAutoTpBestDurability = function(v) if v then StartTp("Durability") else StopTp("Durability") end end
_G.ToggleAutoTpBestChakra     = function(v) if v then StartTp("Chakra")     else StopTp("Chakra")     end end
_G.ToggleAutoTpBestSpeed      = function(v) if v then StartTp("Speed")      else StopTp("Speed")      end end
_G.ToggleAutoTpBestAgility    = function(v) if v then StartTp("Agility")    else StopTp("Agility")    end end

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    for _, l in pairs(Loops) do
        if l.Active and l.Connection then
            l.Connection:Disconnect()
        end
    end
end)