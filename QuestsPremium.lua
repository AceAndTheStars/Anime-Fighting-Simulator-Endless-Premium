-- QuestsPremium.lua
-- Safe version with extra nil checks

local player = game.Players.LocalPlayer

-- Safe number formatter
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
    
    -- Avoid chaining if possible
    local formatted = string.format("%.1f%s", value, suffixes[i] or "")
    formatted = formatted:gsub("%.0$", "")  -- remove .0 if present
    return formatted
end

-- Main data function with heavy nil protection
local function getBoomQuestData()
    local questsFolder = player:FindFirstChild("Quests")
    if not questsFolder then
        return { statusText = "No Quests folder", tasks = {} }
    end

    local activeQuest = nil
    for _, folder in ipairs(questsFolder:GetChildren()) do
        if folder and folder:IsA("Folder") and folder.Name and folder.Name:match("^Boom%d+$") then
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
        
        local current = (prog and type(prog.Value) == "number") and prog.Value or 0
        local needed  = (req  and type(req.Value)  == "number") and req.Value  or 0
        
        table.insert(tasks, "Task " .. i .. ": " .. formatNumber(current) .. " / " .. formatNumber(needed))
    end

    -- Completion check with nil safety
    local isCompleted = true
    for i = 1, maxTasks do
        local prog = progressFolder:FindFirstChild(tostring(i))
        local req = requirementsFolder:FindFirstChild(tostring(i))
        if prog and req and type(prog.Value) == "number" and type(req.Value) == "number" then
            if prog.Value < req.Value then
                isCompleted = false
                break
            end
        end
    end

    if isCompleted then
        statusText = "Completed — waiting for next"
    end

    return { statusText = statusText, tasks = tasks }
end

-- Expose for main script
_G.GetBoomQuestDisplayData = getBoomQuestData

-- Toggle placeholder
_G.ToggleAutoQuestBoom = function(enabled)
    -- Your future auto logic goes here
end