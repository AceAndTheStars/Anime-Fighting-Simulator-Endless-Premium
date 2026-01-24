-- QuestsPremium.lua - Enhanced Display (Always Show Stat Names 1-6)
-- Changes:
-- * ALWAYS generates 6 task lines (Str, Dur, Cha, Sword, Agi, Speed) — even if folder missing children (shows 0/0).
-- * UI will show first 5: Strength → Agility (Sword now visible!).
-- * Completion logic: SMART — only counts tasks with needed > 0 (ignores 0/0 padding).
-- * Keeps placeholder auto & everything else identical.

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local function formatNumber(num)
    if not num or type(num) ~= "number" then return "0" end
    if num == 0 then return "0" end
    
    local suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx"}
    local i = 1
    local value = num
    
    while value >= 1000 and i < #suffixes do
        value = value / 1000
        i = i + 1
    end
    
    if i == 1 then
        return tostring(math.floor(num))
    end
    
    local formatted = string.format("%.1f%s", value, suffixes[i] or "")
    return formatted:gsub("%.0$", "")
end

-- Stat mapping for Boom quest tasks (1-6 fixed)
local statNames = {
    [1] = "Strength",
    [2] = "Durability", 
    [3] = "Chakra",
    [4] = "Sword",
    [5] = "Agility",
    [6] = "Speed"
}

local function getBoomQuestData()
    local questsFolder = player:FindFirstChild("Quests")
    if not questsFolder then
        return {
            statusText = "Quests folder not found",
            tasks = {},
            questNumber = nil,
            isCompleted = false,
            totalTasks = 0
        }
    end

    -- Find highest Boom
    local highestNum = -1
    local activeQuestFolder = nil
    for _, child in ipairs(questsFolder:GetChildren()) do
        if child:IsA("Folder") then
            local numStr = string.match(child.Name, "^Boom(%d+)$")
            if numStr then
                local num = tonumber(numStr)
                if num and num > highestNum then
                    highestNum = num
                    activeQuestFolder = child
                end
            end
        end
    end

    if not activeQuestFolder then
        return {
            statusText = "No Boom quest active",
            tasks = {},
            questNumber = nil,
            isCompleted = false,
            totalTasks = 0
        }
    end

    local questNumber = highestNum
    local statusText = "Active: Boom #" .. questNumber

    local progressFolder = activeQuestFolder:FindFirstChild("Progress")
    local requirementsFolder = activeQuestFolder:FindFirstChild("Requirements")

    if not progressFolder or not requirementsFolder then
        return {
            statusText = statusText .. " (missing progress/reqs)",
            tasks = {},
            questNumber = questNumber,
            isCompleted = false,
            totalTasks = 0
        }
    end

    local tasks = {}
    local realTasks = 0
    local completedCount = 0

    -- FIXED LOOP: Always 1-6 for full stat display (pad 0/0 if missing)
    for i = 1, 6 do
        local progValue = progressFolder:FindFirstChild(tostring(i))
        local reqValue = requirementsFolder:FindFirstChild(tostring(i))

        local current = (progValue and type(progValue.Value) == "number") and progValue.Value or 0
        local needed = (reqValue and type(reqValue.Value) == "number") and reqValue.Value or 0

        -- Stat name or fallback (won't happen for 1-6)
        local taskName = statNames[i] or ("Task " .. i)
        table.insert(tasks, taskName .. ": " .. formatNumber(current) .. " / " .. formatNumber(needed))

        -- Only count REAL tasks (needed > 0)
        if needed > 0 then
            realTasks = realTasks + 1
            if current >= needed then
                completedCount = completedCount + 1
            end
        end
    end

    local isCompleted = (completedCount == realTasks) and (realTasks > 0)

    if isCompleted then
        statusText = "Boom #" .. questNumber .. " — Completed (claim/next)"
    end

    return {
        statusText = statusText,
        tasks = tasks,
        questNumber = questNumber,
        isCompleted = isCompleted,
        totalTasks = realTasks,
        completedTasks = completedCount
    }
end

_G.GetBoomQuestDisplayData = getBoomQuestData

_G.ToggleAutoQuestBoom = function(enabled)
    -- Placeholder - no action yet
end