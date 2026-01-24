-- QuestsPremium.lua (Cleaned - No Console Output)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Number formatter
local function formatNumber(num)
    if not num or num == 0 then return "0" end
    local suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx"}
    local i = 1
    while num >= 1000 and i < #suffixes do
        num = num / 1000
        i = i + 1
    end
    if i == 1 then return tostring(math.floor(num)) end
    return string.format("%.1f%s", num, suffixes[i]):gsub("%.0$", "")
end

local function getCurrentBoomQuestData()
    local questsFolder = LocalPlayer:FindFirstChild("Quests")
    if not questsFolder then
        return nil
    end

    local highestNum = 0
    local boomFolder = nil

    for _, child in ipairs(questsFolder:GetChildren()) do
        if child:IsA("Folder") and child.Name:match("^Boom(%d+)$") then
            local num = tonumber(child.Name:match("%d+"))
            if num and num > highestNum then
                highestNum = num
                boomFolder = child
            end
        end
    end

    if not boomFolder then
        return {
            statusText = "No Boom quest active",
            tasks = {"—","—","—","—","—","—"},
            questNumber = 0,
            isCompleted = false
        }
    end

    local progressFolder = boomFolder:FindFirstChild("Progress")
    local requirementsFolder = boomFolder:FindFirstChild("Requirements")

    if not progressFolder or not requirementsFolder then
        return nil
    end

    local tasks = {}
    local isDone = true

    for i = 1, 6 do
        local prog = progressFolder:FindFirstChild(tostring(i))
        local req = requirementsFolder:FindFirstChild(tostring(i))

        local currentStr = "—"
        local requiredStr = "—"

        if prog and (prog:IsA("IntValue") or prog:IsA("NumberValue")) then
            currentStr = formatNumber(prog.Value)
        end
        if req and (req:IsA("IntValue") or req:IsA("NumberValue")) then
            requiredStr = formatNumber(req.Value)
        end

        table.insert(tasks, currentStr .. " / " .. requiredStr)

        if prog and req and prog.Value < req.Value then
            isDone = false
        end
    end

    local status = isDone and "Boom quest completed!" or ("Boom quest active: #" .. highestNum)

    return {
        statusText = status,
        tasks = tasks,
        questNumber = highestNum,
        isCompleted = isDone
    }
end

_G.GetBoomQuestDisplayData = function()
    local success, result = pcall(getCurrentBoomQuestData)
    if not success then
        return nil
    end
    return result
end

-- =====================================================================
-- ==================== AUTO QUEST (BOOM) LOGIC ========================
-- ==================== FULLY SELF-CONTAINED - BEST AREA TP INCLUDED ====================
-- =====================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TrainRemote = Remotes:WaitForChild("RemoteEvent")

local Workspace = game:GetService("Workspace")

-- ==================== CONFIG ====================

local BOOM_TELEPORT_POS = Vector3.new(-30.936, 80.224, 3.065)

local BOOM_CLICK_DETECTOR = Workspace:WaitForChild("Scriptable", 5)
    :WaitForChild("NPC", 5)
    :WaitForChild("Quest", 5)
    :WaitForChild("Boom", 5)
    :WaitForChild("ClickBox", 5)
    :WaitForChild("ClickDetector", 5)

local taskToStatID = {
    [1] = 1, [2] = 2, [3] = 3, [4] = 4, [5] = 5, [6] = 6
}

local phrasing = {
    [""]   = 1,
    ["K"]  = 1000,
    ["M"]  = 1000000,
    ["B"]  = 1000000000,
    ["T"]  = 1000000000000,
    ["QD"] = 1000000000000000,
    ["QN"] = 1000000000000000000,
    ["SX"] = 1000000000000000000000,
    ["SP"] = 1000000000000000000000000,
    ["OC"] = 1000000000000000000000000000
}

-- Entrance positions (from your ABAPremium script)
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
    Sword = {  -- ADD REAL SWORD POSITIONS HERE (placeholders for now)
        Vector3.new(0, 0, 0),
        -- Add as many as needed...
    },
    SpeedAgility = {
        Vector3.new(-104.639,  61.000, -508.363),
        Vector3.new(-386.277, 105.000, -47.382),
        Vector3.new(3484.517,  60.000, 144.701),
        Vector3.new(4111.812,  60.922, 849.557),
    }
}

-- Inside positions (after portal)
local InsidePositions = {
    Durability = {
        [8] = Vector3.new(-2695.975, -229.010, 352.760),
    },
    Chakra = {
        [12] = Vector3.new(3254.880, -440.978, -242.199),
    },
    SpeedAgility = {
        [2] = Vector3.new(-416.484, 121.465, -77.764),
    }
}

-- Tier thresholds
local TierRequirements = {
    0, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 100000000000,
    5000000000000, 250000000000000, 50000000000000000, 1000000000000000000,
    100000000000000000000, 1000000000000000000000, 100000000000000000000000,
    1000000000000000000000000
}

-- Portal click paths
local PortalMap = {
    Durability = { [8] = "DragonTeleport" },
    Chakra = { [12] = "Ighicho" },
    SpeedAgility = { [2] = "ThePodTeleport" }
}

-- ==================== BEST AREA HELPERS ====================

local function GetStatValue(key)
    local stats = LocalPlayer:FindFirstChild("Stats")
    if not stats then return 0 end
    local obj = stats:FindFirstChild(key)
    return obj and obj.Value or 0
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
    elseif statName == "Sword" then key, positionsKey = "4", "Sword"
    elseif statName == "Agility" or statName == "Speed" then key, positionsKey = "5", "SpeedAgility"
    else return nil end

    local current = GetStatValue(key)
    if current <= 0 then return EntrancePositions[positionsKey][1] end

    local index = GetBestTierIndex(current)
    return EntrancePositions[positionsKey][index] or EntrancePositions[positionsKey][1]
end

local function GoToBestArea(statName)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local entrancePos = GetBestEntrancePosition(statName)
    if not entrancePos then return end

    -- TP to entrance
    hrp.CFrame = CFrame.new(entrancePos)

    -- If portal needed
    local tierIndex = GetBestTierIndex(GetStatValue(tostring(taskToStatID[statName == "Speed" and 5 or statName == "Agility" and 6 or statName == "Strength" and 1 or statName == "Durability" and 2 or 3])))
    local statKey = (statName == "Speed" or statName == "Agility") and "SpeedAgility" or statName
    local portalPath = PortalMap[statKey] and PortalMap[statKey][tierIndex]

    if portalPath then
        task.wait(1.5)
        pcall(function()
            local folder = Workspace:WaitForChild("Scriptable"):WaitForChild("NPC"):WaitForChild("Teleport")
            local clickDetector = folder:WaitForChild(portalPath):WaitForChild("ClickBox"):WaitForChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
            end
        end)
        task.wait(3)  -- wait for portal to teleport you inside
    end
end

-- ==================== TRAINING FUNCTION ====================

local function trainUntilDone(taskIndex, targetRaw)
    local statID = taskToStatID[taskIndex]
    if not statID or not targetRaw then return end
    
    -- One-time TP to best area
    local statName = ({[1]="Strength", [2]="Durability", [3]="Chakra", [4]="Sword", [5]="Agility", [6]="Speed"})[taskIndex]
    GoToBestArea(statName)
    
    while _G.BoomQuestRunning do
        local data = _G.GetBoomQuestDisplayData and _G.GetBoomQuestDisplayData()
        if not data or not data.tasks then break end
        
        local progStr = data.tasks[taskIndex]
        if not progStr or type(progStr) ~= "string" then break end
        
        local parts = {}
        for part in (progStr .. "/"):gmatch("([^/]+)/") do
            table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
        end
        
        if #parts < 2 then break end
        
        local currentVal = parseFormatted(parts[1])
        
        if currentVal >= targetRaw then
            break
        end
        
        pcall(function()
            TrainRemote:FireServer("Train", statID)
        end)
        
        task.wait(0.1)
    end
end

-- ==================== MAIN TOGGLE ====================

_G.ToggleAutoQuestBoom = function(enabled)
    if enabled then
        if _G.BoomQuestRunning then return end
        _G.BoomQuestRunning = true
        
        task.spawn(function()
            while _G.BoomQuestRunning do
                local data = _G.GetBoomQuestDisplayData and _G.GetBoomQuestDisplayData()
                if not data or not data.tasks then
                    task.wait(2)
                    continue
                end

                if data.isCompleted then
                    claimAndNext()
                    task.wait(4.5)
                else
                    local trainedSomething = false
                    
                    for i = 1, 6 do
                        local progStr = data.tasks[i]
                        if not progStr or progStr == "— / —" or progStr == "0 / 0" then
                            continue
                        end
                        
                        local parts = {}
                        for part in (progStr .. "/"):gmatch("([^/]+)/") do
                            table.insert(parts, part:gsub("^%s*(.-)%s*$", "%1"))
                        end
                        
                        if #parts < 2 then continue end
                        
                        local curVal = parseFormatted(parts[1])
                        local reqVal = parseFormatted(parts[2])
                        
                        if curVal < reqVal then
                            trainUntilDone(i, reqVal)
                            trainedSomething = true
                            break
                        end
                    end
                    
                    if not trainedSomething then
                        task.wait(3)
                    end
                end
                
                task.wait(1.2)
            end
        end)
    else
        _G.BoomQuestRunning = false
    end
end