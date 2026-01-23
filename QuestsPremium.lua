-- QuestsPremium.lua (Rewritten - Clean & Robust Version)
-- Handles Boom quest data extraction with strong nil/type protection

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Reusable safe number formatter (unchanged core logic)
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
    return formatted:gsub("%.0$", "")  -- Clean up trailing .0
end

-- Main data extractor - returns display-ready info
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

    -- Collect all BoomX folders and find the one with highest number
    local boomQuests = {}
    for _, child in ipairs(questsFolder:GetChildren()) do
        if child:IsA("Folder") then
            local numStr = child.Name:match("^Boom(%d+)$")
            if numStr then
                local num = tonumber(numStr)
                if num then
                    table.insert(boomQuests, {folder = child, number = num})
                end
            end
        end
    end

    if #boomQuests == 0 then
        return {
            statusText = "No Boom quest active",
            tasks = {},
            questNumber = nil,
            isCompleted = false,
            totalTasks = 0
        }
    end

    -- Sort descending → highest number is most likely current/active
    table.sort(boomQuests, function(a, b) return a.number > b.number end)
    local active = boomQuests[1]
    local activeQuest = active.folder
    local questNumber = active.number

    local statusText = "Active: Boom #" .. questNumber

    local progressFolder    = activeQuest:FindFirstChild("Progress")
    local requirementsFolder = activeQuest:FindFirstChild("Requirements")

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
    local completedCount = 0
    local maxIndex = math.max(#progressFolder:GetChildren(), #requirementsFolder:GetChildren())

    for i = 1, maxIndex do
        local progValue = progressFolder:FindFirstChild(tostring(i))
        local reqValue  = requirementsFolder:FindFirstChild(tostring(i))

        local current = (progValue and type(progValue.Value) == "number") and progValue.Value or 0
        local needed  = (reqValue  and type(reqValue.Value)  == "number")  and reqValue.Value  or 0

        table.insert(tasks, "Task " .. i .. ": " .. formatNumber(current) .. " / " .. formatNumber(needed))

        if current >= needed and needed > 0 then
            completedCount = completedCount + 1
        end
    end

    local isCompleted = (completedCount == maxIndex) and (maxIndex > 0)

    if isCompleted then
        statusText = "Boom #" .. questNumber .. " — Completed (claim/next)"
    end

    return {
        statusText   = statusText,
        tasks        = tasks,
        questNumber  = questNumber,
        isCompleted  = isCompleted,
        totalTasks   = maxIndex,
        completedTasks = completedCount
    }
end

-- Expose to main hub script (UI polling)
_G.GetBoomQuestDisplayData = getBoomQuestData

-- Auto-quest toggle (placeholder — expand later)
_G.ToggleAutoQuestBoom = function(enabled)
    -- Future implementation:
    --   - If enabled → start loop that reads tasks → auto-trains/kills/runs → claims when done
    --   - Use existing autofarms (ToggleAutoStrength etc.) for stat tasks
    --   - Fire claim remote when isCompleted == true
    -- For now: just a stub
    if enabled then
        warn("[AutoQuestBoom] Enabled — logic not yet implemented")
    else
        warn("[AutoQuestBoom] Disabled")
    end
end

-- Optional: for debugging in console
-- print("QuestsPremium loaded - ready for polling")