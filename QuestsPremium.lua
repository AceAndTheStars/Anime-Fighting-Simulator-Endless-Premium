-- QuestsPremium.lua
-- Safe version - uses manual max finding instead of table.sort to avoid conflicts

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

    -- Find the Boom quest with the highest number (manual loop - no sort)
    local highestNum = -1
    local activeQuestFolder = nil

    for _, child in ipairs(questsFolder:GetChildren()) do
        if child:IsA("Folder") then
            local numStr = child.Name:match("^Boom(%d+)$")
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

    local progressFolder     = activeQuestFolder:FindFirstChild("Progress")
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
    local completedCount = 0
    local maxIndex = math.max(#progressFolder:GetChildren(), #requirementsFolder:GetChildren())

    for i = 1, maxIndex do
        local progValue = progressFolder:FindFirstChild(tostring(i))
        local reqValue  = requirementsFolder:FindFirstChild(tostring(i))

        local current = (progValue and type(progValue.Value) == "number") and progValue.Value or 0
        local needed  = (reqValue  and type(reqValue.Value) == "number") and reqValue.Value or 0

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
        statusText     = statusText,
        tasks          = tasks,
        questNumber    = questNumber,
        isCompleted    = isCompleted,
        totalTasks     = maxIndex,
        completedTasks = completedCount
    }
end

_G.GetBoomQuestDisplayData = getBoomQuestData

_G.ToggleAutoQuestBoom = function(enabled)
    if enabled then
        warn("[AutoQuestBoom] Enabled — auto logic not yet implemented")
    else
        warn("[AutoQuestBoom] Disabled")
    end
end