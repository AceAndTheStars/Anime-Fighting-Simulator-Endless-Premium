-- QuestsPremium.lua (Cleaned - No Console Output - Simplified Auto Quest)

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
-- ==================== ONLY TRAIN REQUIRED STATS - NO TP ====================
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
    [1] = 1,  -- Strength
    [2] = 2,  -- Durability
    [3] = 3,  -- Chakra
    [4] = 4,  -- Sword
    [5] = 5,  -- Agility
    [6] = 6   -- Speed
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

-- ==================== HELPERS ====================

local function teleportToBoom()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(BOOM_TELEPORT_POS + Vector3.new(0, 3, 0))
        task.wait(0.7)
    end
end

local function claimAndNext()
    teleportToBoom()
    if BOOM_CLICK_DETECTOR and BOOM_CLICK_DETECTOR:IsA("ClickDetector") then
        pcall(fireclickdetector, BOOM_CLICK_DETECTOR)
    end
end

local function parseFormatted(str)
    if not str or str:match("—") or str == "" then return 0 end
    
    str = str:gsub("%s+", ""):gsub(",", ""):upper()
    
    local numStr, suffix = str:match("^([%d%.]+)([A-Z]*)$")
    if not numStr then return 0 end
    
    local num = tonumber(numStr) or 0
    local mult = phrasing[suffix] or 1
    
    return num * mult
end

local function trainUntilDone(taskIndex, targetRaw)
    local statID = taskToStatID[taskIndex]
    if not statID or not targetRaw then return end
    
    while _G.BoomQuestRunning do
        local data = _G.GetBoomQuestDisplayData and _G.GetBoomQuestDisplayData()
        if not data or not data.tasks then
            task.wait(2)
            continue
        end
        
        local progStr = data.tasks[taskIndex]
        if not progStr or type(progStr) ~= "string" then
            task.wait(2)
            continue
        end
        
        -- Simple split on "/"
        local split = string.split(progStr, "/")
        if #split < 2 then
            task.wait(2)
            continue
        end
        
        local currentPart = split[1]:gsub("^%s*(.-)%s*$", "%1")
        local reqPart     = split[2]:gsub("^%s*(.-)%s*$", "%1")
        
        local currentVal = parseFormatted(currentPart)
        
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
                        
                        local split = string.split(progStr, "/")
                        if #split < 2 then continue end
                        
                        local curPart = split[1]:gsub("^%s*(.-)%s*$", "%1")
                        local reqPart = split[2]:gsub("^%s*(.-)%s*$", "%1")
                        
                        local curVal = parseFormatted(curPart)
                        local reqVal = parseFormatted(reqPart)
                        
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