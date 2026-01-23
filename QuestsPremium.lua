-- QuestsPremium.lua

local player = game.Players.LocalPlayer

-- Returns { statusText = "Active: Boom Nr.3", tasks = {"Task 1: 23/50", "Task 2: 0/30", ...} }
-- or { statusText = "No active Boom quest", tasks = {} }
local function getBoomQuestData()
    local quests = player:FindFirstChild("Quests")
    if not quests then
        return { statusText = "No Quests folder", tasks = {} }
    end

    local active = nil
    for _, f in ipairs(quests:GetChildren()) do
        if f:IsA("Folder") and f.Name:match("^Boom%d+$") then
            active = f
            break
        end
    end

    if not active then
        return { statusText = "No active Boom quest", tasks = {} }
    end

    local num = active.Name:match("^Boom(%d+)$") or "?"
    local status = "Active: Boom Nr." .. num

    local progress = active:FindFirstChild("Progress")
    local reqs = active:FindFirstChild("Requirements")
    if not progress or not reqs then
        return { statusText = status .. " (no progress data)", tasks = {} }
    end

    local taskList = {}
    local maxT = math.max(#progress:GetChildren(), #reqs:GetChildren())
    for i = 1, maxT do
        local p = progress:FindFirstChild(tostring(i))
        local r = reqs:FindFirstChild(tostring(i))
        local pv = p and p.Value or 0
        local rv = r and r.Value or 0
        table.insert(taskList, "Task " .. i .. ": " .. formatNumber(pv) .. " / " .. formatNumber(rv))
    end

    -- Check if completed (all progress >= requirements)
    local completed = true
    for i = 1, maxT do
        local p = progress:FindFirstChild(tostring(i))
        local r = reqs:FindFirstChild(tostring(i))
        if p and r and p.Value < r.Value then
            completed = false
            break
        end
    end

    if completed then
        status = "Completed — waiting for next"
    end

    return { statusText = status, tasks = taskList }
end

-- Format function (same as in main script — we can share or duplicate)
local function formatNumber(num)
    if not num then return "0" end
    local suffixes = {"", "K", "M", "B", "T", "Qd", "Qn", "Sx"}
    local i = 1
    while num >= 1000 and i < #suffixes do
        num = num / 1000
        i = i + 1
    end
    if i == 1 then return tostring(num) end
    return string.format("%.1f%s", num, suffixes[i])
end

-- Public function for main script to call
_G.GetBoomQuestDisplayData = getBoomQuestData

-- Toggle (still empty for now)
_G.ToggleAutoQuestBoom = function(enabled)
    -- your future auto logic here
end