-- ABA.lua - Auto Best Area TP
-- Uses player.Stats["1/2/3"].Value + real positions & thresholds from button names

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Real positions from TeleportsPremium.lua (ordered: lowest → highest tier)
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
        Vector3.new(72.340,    69.263,  877.353),   -- [100]
        Vector3.new(-1602.088, 61.502, -532.064),   -- [10K]
        Vector3.new(-77.845,   61.008, 2037.284),   -- [100K]
        Vector3.new(-621.543,  179.000, 741.890),   -- [1M]
        Vector3.new(-1102.311, 212.630, -946.145),  -- [10M]
        Vector3.new(-341.295,   72.620, -1653.579), -- [100M]
        Vector3.new(2495.276, 1540.875, -356.906),  -- [1B]
        Vector3.new(-2171.543, 617.517, 525.640),   -- [100B]
        Vector3.new(2188.043,  518.649, 576.627),   -- [5T]
        Vector3.new(1671.975,  423.930, -1291.617), -- [250T]
        Vector3.new(165.322,   773.591, -716.061),  -- [75QD]
        Vector3.new(2590.823,   63.229, 1697.295),  -- [2.5QN]
        Vector3.new(1726.687, 2305.067,  61.937),   -- [1sx]
    },
    Chakra = {
        Vector3.new(-3.768,    65.000, -117.034),   -- [100]
        Vector3.new(1423.010,  147.000, -582.122),  -- [10K]
        Vector3.new(917.247,   141.000, 781.455),   -- [100K]
        Vector3.new(1576.373,  388.750, 675.160),   -- [1M]
        Vector3.new(334.134,  -129.590, -1840.660), -- [10M]
        Vector3.new(1028.428,  251.000, -627.812),  -- [100M]
        Vector3.new(3053.941,  110.900, 1105.880),  -- [1B]
        Vector3.new(1552.188,   88.724, 1717.498),  -- [100B]
        Vector3.new(-17.094,    62.073, -478.995),  -- [5T]
        Vector3.new(-396.257, 1237.356, 670.550),   -- [250T]
        Vector3.new(-737.839, 2792.597, 567.334),   -- [75qd]
        Vector3.new(3151.687,  163.000, -102.653),  -- [2.5QN]
        Vector3.new(358.822,   292.742, 1864.116),  -- [1sx]
    }
}

-- Thresholds based directly on the button names (minimum stat to unlock/use that area)
-- These are the MINIMUM values where that tier becomes available
local TierThresholds = {
    0,               -- [100]          tier 1
    100,             -- technically starts at 100, but placeholder for [100]
    10000,           -- [10K]
    100000,          -- [100K]
    1000000,         -- [1M]
    10000000,        -- [10M]
    100000000,       -- [100M]
    1000000000,      -- [1B]
    100000000000,    -- [100B]
    5000000000000,   -- [5T] = 5 trillion
    250000000000000, -- [250T] = 250 trillion
    75000000000000000, -- [75qd] = 75 quadrillion
    2500000000000000000, -- [2.5QN] = 2.5 quintillion
    -- [1sx] is the last one, unlocked at extremely high stats (sextillion range) — no need for higher threshold
}

-- Get current stat value from player.Stats
local function GetStatValue(key)
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats then return 0 end
    local valObj = stats:FindFirstChild(key)
    return (valObj and (valObj:IsA("IntValue") or valObj:IsA("NumberValue"))) and valObj.Value or 0
end

-- Find the highest tier index your current stat qualifies for
local function GetBestTierIndex(current)
    local index = 1
    for i, thresh in ipairs(TierThresholds) do
        if current >= thresh then
            index = i
        else
            break
        end
    end
    return index
end

-- Best position for the stat
local function GetBestPosition(statName)
    local key = (statName == "Strength" and "1") or (statName == "Durability" and "2") or (statName == "Chakra" and "3") or nil
    if not key then return nil end

    local current = GetStatValue(key)
    if current <= 0 then return nil end

    local idx = GetBestTierIndex(current)
    local posList = TrainingPositions[statName]
    return posList and posList[idx] or posList[1]  -- fallback to lowest
end

-- Per-stat loop management
local Loops = {
    Strength   = { Active = false, Connection = nil },
    Durability = { Active = false, Connection = nil },
    Chakra     = { Active = false, Connection = nil }
}

local function StartTp(statName)
    local loopData = Loops[statName]
    if loopData.Active then return end
    loopData.Active = true

    loopData.Connection = RunService.Heartbeat:Connect(function()
        if not loopData.Active then return end

        local char = LocalPlayer.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local target = GetBestPosition(statName)
        if not target then return end

        if (hrp.Position - target).Magnitude > 40 then
            local offset = Vector3.new(math.random(-5,5), 5, math.random(-5,5))
            hrp.CFrame = CFrame.new(target + offset)
        end
    end)
end

local function StopTp(statName)
    local loopData = Loops[statName]
    if not loopData.Active then return end
    loopData.Active = false
    if loopData.Connection then
        loopData.Connection:Disconnect()
        loopData.Connection = nil
    end
end

-- UI toggle callbacks
_G.ToggleAutoTpBestStrength = function(on) if on then StartTp("Strength") else StopTp("Strength") end end
_G.ToggleAutoTpBestDurability = function(on) if on then StartTp("Durability") else StopTp("Durability") end end
_G.ToggleAutoTpBestChakra = function(on) if on then StartTp("Chakra") else StopTp("Chakra") end end

-- Cleanup
LocalPlayer.CharacterRemoving:Connect(function()
    for _, l in pairs(Loops) do
        if l.Active and l.Connection then l.Connection:Disconnect() end
    end
end)