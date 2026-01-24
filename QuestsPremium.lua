-- QuestsPremium.lua - SEQUENTIAL AUTO QUEST + SELF-CONTAINED TRAINING LOOP

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

local RemoteEvent = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteEvent")

local BOOM_NPC_CFRAME = CFrame.new(
    -33.017746, 80.2238693, 3.40424752,
    -0.0262032673, -4.25549507e-09, 0.999656618,
    3.95084276e-09, 1, 4.36051728e-09,
    -0.999656618, 4.06374623e-09, -0.0262032673
)

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

local TierRequirements = {
    0, 10000, 100000, 1000000, 10000000, 100000000, 1000000000, 100000000000,
    5000000000000, 250000000000000, 50000000000000000, 1000000000000000000,
    100000000000000000000, 1000000000000000000000, 100000000000000000000000,
    1000000000000000000000000
}

local PortalMap = {
    Durability = { [8] = "DragonTeleport" },
    Chakra = { [12] = "Ighicho" },
    SpeedAgility = { [2] = "ThePodTeleport" }
}

local statConfig = {
    [1] = {name = "Strength"},
    [2] = {name = "Durability"},
    [3] = {name = "Chakra"},
    [4] = {name = "Sword"},
    [5] = {name = "Agility"},
    [6] = {name = "Speed"}
}

local TrainingActive = {}

local function GetTrainId(statName)
    if statName == "Strength"   then return 1 end
    if statName == "Durability" then return 2 end
    if statName == "Chakra"     then return 3 end
    if statName == "Sword"      then return 4 end
    if statName == "Speed"      then return 5 end
    if statName == "Agility"    then return 6 end
    return nil
end

local function StartTraining(statName)
    if TrainingActive[statName] then return end
    TrainingActive[statName] = true

    task.spawn(function()
        if statName == "Sword" then
            pcall(function()
                RemoteEvent:FireServer("ActivateSword")
            end)
        end

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
            task.wait(0.08 + math.random()/20)
        end
    end)
end

local function StopTraining(statName)
    TrainingActive[statName] = false
end

local function getCurrentQuestData()
    local quests = player:FindFirstChild("Quests")
    if not quests then return nil end

    local folder = nil
    for _, child in ipairs(quests:GetChildren()) do
        if child:IsA("Folder") and string.match(child.Name, "^Boom%d+$") then
            folder = child
            break
        end
    end

    if not folder then return nil end

    local progress = folder:FindFirstChild("Progress")
    local reqs = folder:FindFirstChild("Requirements")
    if not progress or not reqs then return nil end

    local tasks = {}
    for i = 1, 6 do
        local p = progress:FindFirstChild(tostring(i))
        local r = reqs:FindFirstChild(tostring(i))
        tasks[i] = {
            current = p and p.Value or 0,
            required = r and r.Value or 0
        }
    end

    return {tasks = tasks, folder = folder}
end

_G.GetBoomQuestDisplayData = function()
    local data = getCurrentQuestData()
    if not data then
        return {statusText = "No Boom quest active", tasks = {"—", "—", "—", "—", "—", "—"}}
    end

    local tasksDisplay = {}
    local isDone = true

    for i = 1, 6 do
        local t = data.tasks[i] or {current = 0, required = 0}
        local name = statConfig[i].name or ("Task " .. i)
        table.insert(tasksDisplay, name .. ": " .. formatNumber(t.current) .. " / " .. formatNumber(t.required))

        if t.required > 0 and t.current < t.required then
            isDone = false
        end
    end

    return {
        statusText = isDone and "Completed" or "Active",
        tasks = tasksDisplay
    }
end

local function getBestEntrance(statId)
    local statName = statConfig[statId].name
    local key, positionsKey
    if statName == "Strength"   then key, positionsKey = "1", "Strength"
    elseif statName == "Durability" then key, positionsKey = "2", "Durability"
    elseif statName == "Chakra" then key, positionsKey = "3", "Chakra"
    elseif statName == "Speed" or statName == "Agility" then key, positionsKey = "5", "SpeedAgility"
    else return nil end

    local current = player.Stats and player.Stats:FindFirstChild(key) and player.Stats[key].Value or 0
    if current <= 0 then return EntrancePositions[positionsKey][1] end

    local index = 1
    for i = #TierRequirements, 1, -1 do
        if current >= TierRequirements[i] then index = i break end
    end

    return EntrancePositions[positionsKey][index] or EntrancePositions[positionsKey][1]
end

local function getInsidePosition(statId)
    local statName = statConfig[statId].name
    local statKey = (statName == "Speed" or statName == "Agility") and "SpeedAgility" or statName
    local key = statName == "Speed" and "5" or statName == "Agility" and "6" or
                statName == "Strength" and "1" or
                statName == "Durability" and "2" or "3"
    local current = player.Stats and player.Stats:FindFirstChild(key) and player.Stats[key].Value or 0

    local index = 1
    for i = #TierRequirements, 1, -1 do
        if current >= TierRequirements[i] then index = i break end
    end

    return InsidePositions[statKey] and InsidePositions[statKey][index]
end

local function tpToBestTraining(statId)
    local entrancePos = getBestEntrance(statId)
    if not entrancePos then return end

    local insidePos = getInsidePosition(statId)
    local targetPos = insidePos or entrancePos

    local char = player.Character or player.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 5)
    if not hrp then return end

    local dist = (hrp.Position - targetPos).Magnitude
    if dist <= 45 then
        StartTraining(statConfig[statId].name)
        return
    end

    hrp.CFrame = CFrame.new(targetPos)

    if not insidePos then
        local statName = statConfig[statId].name
        local statKey = (statName == "Speed" or statName == "Agility") and "SpeedAgility" or statName
        local key = statName == "Speed" and "5" or statName == "Agility" and "6" or
                    statName == "Strength" and "1" or
                    statName == "Durability" and "2" or "3"
        local current = player.Stats and player.Stats:FindFirstChild(key) and player.Stats[key].Value or 0

        local tierIndex = 1
        for i = #TierRequirements, 1, -1 do
            if current >= TierRequirements[i] then
                tierIndex = i
                break
            end
        end

        local portalPath = PortalMap[statKey] and PortalMap[statKey][tierIndex]
        if portalPath then
            task.spawn(function()
                task.wait(1.5)
                pcall(function()
                    local folder = workspace:WaitForChild("Scriptable"):WaitForChild("NPC"):WaitForChild("Teleport")
                    local cd = folder:WaitForChild(portalPath):WaitForChild("ClickBox"):WaitForChild("ClickDetector")
                    fireclickdetector(cd)
                end)
            end)
            task.wait(3)
        end
    end
end

local function tpToBoom()
    pcall(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if not hrp then return end
        
        hrp.CFrame = BOOM_NPC_CFRAME * CFrame.new(0, 0, -4.5)
        
        task.wait(0.3)
        
        local clickDetector = workspace:FindFirstChild("Scriptable") and
                              workspace.Scriptable:FindFirstChild("NPC") and
                              workspace.Scriptable.NPC:FindFirstChild("Quest") and
                              workspace.Scriptable.NPC.Quest:FindFirstChild("Boom") and
                              workspace.Scriptable.NPC.Quest.Boom:FindFirstChild("ClickBox") and
                              workspace.Scriptable.NPC.Quest.Boom.ClickBox:FindFirstChild("ClickDetector")
        
        if clickDetector then
            fireclickdetector(clickDetector)
        end
        
        task.wait(2.5)
    end)
end

local autoLoop = false

_G.ToggleAutoQuestBoom = function(enabled)
    autoLoop = enabled
    if not enabled then
        for stat in pairs(TrainingActive) do
            StopTraining(stat)
        end
        return
    end

    task.spawn(function()
        while autoLoop do
            local data = getCurrentQuestData()
            if not data then
                task.wait(3)
                continue
            end

            local isDone = true
            for i = 1, 6 do
                local t = data.tasks[i]
                if t.required > 0 and t.current < t.required then
                    isDone = false
                    break
                end
            end

            if isDone then
                for stat in pairs(TrainingActive) do
                    StopTraining(stat)
                end
                tpToBoom()
                task.wait(5)
                continue
            end

            local targetI = nil
            for i = 1, 6 do
                local t = data.tasks[i]
                if t.required > 0 and t.current < t.required then
                    targetI = i
                    break
                end
            end

            for stat in pairs(TrainingActive) do
                if stat ~= (targetI and statConfig[targetI].name) then
                    StopTraining(stat)
                end
            end

            if targetI then
                tpToBestTraining(targetI)
                StartTraining(statConfig[targetI].name)
            end

            task.wait(1.5)
        end

        for stat in pairs(TrainingActive) do
            StopTraining(stat)
        end
    end)
end