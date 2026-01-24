-- QuestsPremium.lua - Boom Quest Tracker & Auto-Progress (Premium)
-- Fixed remote firing to match exact working format: "Train", statID via unpack
-- NO auto-TP to best areas — pure remote training + claim via NPC click

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local TrainRemote = Remotes:WaitForChild("RemoteEvent")

-- Constants
local BOOM_TELEPORT_POS = Vector3.new(-30.936, 80.224, 3.065)
local BOOM_CLICK_DETECTOR_PATH = {"Scriptable", "NPC", "Quest", "Boom", "ClickBox", "ClickDetector"}

-- Number formatting (same as main script)
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

-- Suffix multipliers for parsing displayed progress (full numbers)
local suffixMultipliers = {
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

-- Parse "1.2M" → raw number
local function parseFormatted(str)
    if not str or str:match("—") or str == "" then return 0 end
    str = str:gsub("[,%s]", ""):upper()
    local numStr, suffix = str:match("^([%d%.]+)([A-Z]*)$")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    local mult = suffixMultipliers[suffix] or 1
    return num * mult
end

-- Task index → stat ID mapping
local taskToStat = {
    [1] = 1,  -- Strength
    [2] = 2,  -- Durability
    [3] = 3,  -- Chakra
    [4] = 4,  -- Sword
    [5] = 5,  -- Speed
    [6] = 6   -- Agility
}

-- Safe way to get Boom ClickDetector
local function getBoomClickDetector()
    local current = Workspace
    for _, name in ipairs(BOOM_CLICK_DETECTOR_PATH) do
        current = current:FindFirstChild(name)
        if not current then return nil end
    end
    return current:IsA("ClickDetector") and current or nil
end

-- Teleport near Boom NPC and click to claim/next
local function claimQuest()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    hrp.CFrame = CFrame.new(BOOM_TELEPORT_POS + Vector3.new(0, 3, 0))
    task.wait(0.7)
    
    local detector = getBoomClickDetector()
    if detector then
        pcall(fireclickdetector, detector)
    end
end

-- Fetch current Boom quest data for UI display
local function fetchBoomQuestData()
    local questsFolder = LocalPlayer:FindFirstChild("Quests")
    if not questsFolder then return nil end

    local highestNum = 0
    local boomFolder = nil
    for _, child in ipairs(questsFolder:GetChildren()) do
        if child:IsA("Folder") then
            local num = tonumber(child.Name:match("^Boom(%d+)$"))
            if num and num > highestNum then
                highestNum = num
                boomFolder = child
            end
        end
    end

    if not boomFolder then
        return {
            statusText = "No Boom quest active",
            tasks = {"— / —", "— / —", "— / —", "— / —", "— / —", "— / —"},
            questNumber = 0,
            isCompleted = false
        }
    end

    local progressFolder = boomFolder:FindFirstChild("Progress")
    local requirementsFolder = boomFolder:FindFirstChild("Requirements")
    if not progressFolder or not requirementsFolder then return nil end

    local tasks = {}
    local isCompleted = true
    for i = 1, 6 do
        local prog = progressFolder:FindFirstChild(tostring(i))
        local req = requirementsFolder:FindFirstChild(tostring(i))
        local progVal = (prog and (prog:IsA("IntValue") or prog:IsA("NumberValue"))) and prog.Value or 0
        local reqVal = (req and (req:IsA("IntValue") or req:IsA("NumberValue"))) and req.Value or 0
        
        tasks[i] = formatNumber(progVal) .. " / " .. formatNumber(reqVal)
        
        if progVal < reqVal then
            isCompleted = false
        end
    end

    local statusText = isCompleted and "Boom quest completed!" or ("Boom quest active: #" .. highestNum)
    return {
        statusText = statusText,
        tasks = tasks,
        questNumber = highestNum,
        isCompleted = isCompleted
    }
end

-- Exported for main script UI updates
_G.GetBoomQuestDisplayData = function()
    local success, data = pcall(fetchBoomQuestData)
    return success and data or nil
end

-- Train one specific task until it reaches the target
local function trainTask(taskIndex, targetValue)
    local statID = taskToStat[taskIndex]
    if not statID then return end

    while _G.BoomQuestRunning do
        local data = _G.GetBoomQuestDisplayData()
        if not data or not data.tasks[taskIndex] then
            task.wait(2)
            continue
        end

        local progStr = data.tasks[taskIndex]
        local parts = string.split(progStr, "/")
        if #parts < 2 then
            task.wait(2)
            continue
        end

        local currentStr = parts[1]:match("^%s*(.-)%s*$") or ""
        local currentValue = parseFormatted(currentStr)

        if currentValue >= targetValue then
            break
        end

        pcall(function()
            local args = {
                "Train",
                statID
            }
            TrainRemote:FireServer(unpack(args))
        end)

        task.wait(0.1 + math.random() * 0.05)  -- slight variation to look more natural
    end
end

-- Main auto-quest toggle logic
_G.ToggleAutoQuestBoom = function(enabled)
    if enabled then
        if _G.BoomQuestRunning then return end
        _G.BoomQuestRunning = true
        
        task.spawn(function()
            while _G.BoomQuestRunning do
                local data = _G.GetBoomQuestDisplayData()
                if not data then
                    task.wait(2)
                    continue
                end

                if data.isCompleted then
                    claimQuest()
                    task.wait(4.5)  -- give time for next quest to load
                else
                    local didTrain = false
                    
                    for i = 1, 6 do
                        local progStr = data.tasks[i]
                        if progStr == "— / —" or progStr == "0 / 0" then continue end

                        local parts = string.split(progStr, "/")
                        if #parts < 2 then continue end

                        local curStr = parts[1]:match("^%s*(.-)%s*$") or ""
                        local reqStr = parts[2]:match("^%s*(.-)%s*$") or ""

                        local curVal = parseFormatted(curStr)
                        local reqVal = parseFormatted(reqStr)

                        if curVal < reqVal then
                            trainTask(i, reqVal)
                            didTrain = true
                            break  -- only do one task at a time
                        end
                    end
                    
                    if not didTrain then
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