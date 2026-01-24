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
-- ==================== SEPARATE FROM DISPLAY CODE ====================
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
    if not str or str:match("—") then return 0 end
    str = str:gsub("%s+", ""):gsub(",", ""):upper()
    local numStr, suffix = str:match("^([%d%.]+)([KM BTQ]*)$")
    local num = tonumber(numStr) or 0
    local mult = ({K=1e3,M=1e6,B=1e9,T=1e12,QD=1e15,QN=1e18,SX=1e21})[suffix] or 1
    return num * mult
end

local function trainUntilDone(statID, targetRaw)
    if not statID then return end
    
    while _G.BoomQuestRunning do
        local data = _G.GetBoomQuestDisplayData and _G.GetBoomQuestDisplayData()
        if not data then break end
        
        local progStr = data.tasks[statID] or "— / —"
        local currentPart = progStr:match("^([^/]+)") or "0"
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
                if not data then
                    task.wait(2)
                    continue
                end

                if data.isCompleted then
                    claimAndNext()
                    task.wait(4.5)
                else
                    local found = false
                    
                    for i = 1, 6 do
                        local progStr = data.tasks[i] or "— / —"
                        if progStr ~= "— / —" and progStr ~= "0 / 0" then
                            local currentPart, reqPart = progStr:match("^([^/]+)%s*/%s*(.+)$")
                            if currentPart and reqPart then
                                local curVal = parseFormatted(currentPart)
                                local reqVal = parseFormatted(reqPart)
                                
                                if curVal < reqVal then
                                    local statID = taskToStatID[i]
                                    trainUntilDone(statID, reqVal)
                                    found = true
                                    break
                                end
                            end
                        end
                    end
                    
                    if not found then
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