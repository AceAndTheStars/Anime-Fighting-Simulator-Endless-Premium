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
local TrainRemote = Remotes:WaitForChild("RemoteEvent")  -- your training remote

-- ==================== CONFIG ====================
-- REPLACE THESE

local BOOM_NPC_POSITION = Vector3.new(150, 10, 200)  -- TODO: REAL POSITION HERE

-- Quest accept/claim remote (placeholder - update!)
local QUEST_REMOTE = Remotes:WaitForChild("Quest")  -- change name if different
local ACCEPT_ARGS = {"Accept"}                      -- e.g. {"Boom", "Accept"}
local CLAIM_ARGS  = {"Claim"}                       -- e.g. {"Boom", "Claim"}

-- Stat ID mapping (matches your remote args)
local taskToStatID = {
    [1] = 1,  -- Strength
    [2] = 2,  -- Durability
    [3] = 3,  -- Chakra
    [4] = 4,  -- Sword
    [5] = 5,  -- Agility
    [6] = 6   -- Speed
}

-- ==================== HELPERS ====================

local function teleportToBoom()
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        hrp.CFrame = CFrame.new(BOOM_NPC_POSITION + Vector3.new(0, 3, 0))
        task.wait(0.5)
    end
end

local function fireQuestAction(args)
    pcall(function()
        QUEST_REMOTE:FireServer(unpack(args))
    end)
end

-- Rough parse formatted string back to number (e.g. "1.2M" → 1200000)
local function parseFormatted(numStr)
    if not numStr or numStr == "—" then return 0 end
    local num = tonumber(numStr:match("^[%d%.]+")) or 0
    local suffix = numStr:match("[KM BTQ]+$") or ""
    local multipliers = {K = 1e3, M = 1e6, B = 1e9, T = 1e12, Qd = 1e15, Qn = 1e18, Sx = 1e21}
    return num * (multipliers[suffix] or 1)
end

-- Train spam loop for a specific stat ID
local function trainStat(statID, requiredVal)
    if not statID then return end
    while _G.BoomQuestRunning do
        local data = _G.GetBoomQuestDisplayData and _G.GetBoomQuestDisplayData()
        if not data then break end
        
        local currentStr = data.tasks[statID] or "— / —"
        local currentVal = parseFormatted(currentStr:match("^([^/]+)"))
        
        if currentVal >= requiredVal then
            break  -- done with this stat
        end
        
        pcall(function()
            TrainRemote:FireServer("Train", statID)
        end)
        
        task.wait(0.12)  -- standard training spam rate
    end
end

-- ==================== MAIN TOGGLE LOGIC ====================

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
                    -- Claim & accept next
                    teleportToBoom()
                    fireQuestAction(CLAIM_ARGS)
                    task.wait(3)  -- wait for reward/next quest
                    fireQuestAction(ACCEPT_ARGS)
                    task.wait(2)
                else
                    -- Find first incomplete task and train it sequentially
                    local trained = false
                    for i = 1, 6 do
                        local progStr = data.tasks[i] or "— / —"
                        if progStr ~= "— / —" and progStr ~= "0 / 0" then
                            local currentStr, reqStr = progStr:match("^([^/]+)%s*/%s*(.+)$")
                            if currentStr and reqStr then
                                local curVal = parseFormatted(currentStr)
                                local reqVal = parseFormatted(reqStr)
                                if curVal < reqVal then
                                    local statID = taskToStatID[i]
                                    trainStat(statID, reqVal)  -- blocks until done
                                    trained = true
                                    break  -- after finishing one, re-check for next
                                end
                            end
                        end
                    end
                    
                    if not trained then
                        task.wait(3)  -- wait if nothing to train
                    end
                end
                
                task.wait(1)  -- main loop tick
            end
        end)
    else
        _G.BoomQuestRunning = false
    end
end