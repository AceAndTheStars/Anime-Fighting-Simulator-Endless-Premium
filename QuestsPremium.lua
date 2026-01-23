-- QuestsPremium.lua
local player = game.Players.LocalPlayer

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

local function getBoomQuestData()
    local questsFolder = player:FindFirstChild("Quests")
    if not questsFolder then
        return { statusText = "No Quests folder", tasks = {} }
    end

    local activeQuest = nil
    for _, folder in ipairs(questsFolder:GetChildren()) do
        if folder:IsA("Folder") and folder.Name:match("^Boom%d+$") then
            activeQuest = folder
            break
        end
    end

    if not activeQuest then
        return { statusText = "No active Boom quest", tasks = {} }
    end

    local questNumber = activeQuest.Name:match("^Boom(%d+)$") or "?"
    local statusText = "Active: Boom Nr." .. questNumber

    local progressFolder = activeQuest:FindFirstChild("Progress")
    local requirementsFolder = activeQuest:FindFirstChild("Requirements")

    if not progressFolder or not requirementsFolder then
        return { statusText = statusText .. " (no progress data)", tasks = {} }
    end

    local tasks = {}
    local maxTasks = math.max(#progressFolder:GetChildren(), #requirementsFolder:GetChildren())

    for i = 1, maxTasks do
        local prog = progressFolder:FindFirstChild(tostring(i))
        local req = requirementsFolder:FindFirstChild(tostring(i))
        local current = prog and prog.Value or 0
        local needed = req and req.Value or 0
        table.insert(tasks, "Task " .. i .. ": " .. formatNumber(current) .. " / " .. formatNumber(needed))
    end

    local isCompleted = true
    for i = 1, maxTasks do
        local prog = progressFolder:FindFirstChild(tostring(i))
        local req = requirementsFolder:FindFirstChild(tostring(i))
        if prog and req and prog.Value < req.Value then
            isCompleted = false
            break
        end
    end

    if isCompleted then
        statusText = "Completed — waiting for next"
    end

    return { statusText = statusText, tasks = tasks }
end

_G.GetBoomQuestDisplayData = getBoomQuestData

_G.ToggleAutoQuestBoom = function(enabled)
    -- Add your auto logic here later
end