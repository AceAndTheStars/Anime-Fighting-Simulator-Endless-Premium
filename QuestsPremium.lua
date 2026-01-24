-- QuestsPremium.lua - SEQUENTIAL AUTO TRAIN (one stat at a time, toggle-controlled)

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG: Boom NPC CFrame (updated with your position + orientation for accurate facing)
local BOOM_NPC_CFRAME = CFrame.new(-34.0972023, 80.228693, 3.52807498, -0.0349256732, -0.10755586, 0.993619407, 1, 0.382658899e-09, -0.99389887, 1.0350725e-07, -0.0349256732, -0.0349256732)  -- From your console output (rotation might be approximate due to cutoff, but should work!)

local statConfig = {
    [1] = {name = "Strength",   farm = "ToggleAutoStrength",     aba = "ToggleAutoTpBestStrength"},
    [2] = {name = "Durability", farm = "ToggleAutoDurability",   aba = "ToggleAutoTpBestDurability"},
    [3] = {name = "Chakra",     farm = "ToggleAutoChakra",       aba = "ToggleAutoTpBestChakra"},
    [4] = {name = "Sword",      farm = "ToggleAutoSword"},  -- no ABA
    [5] = {name = "Agility",    farm = "ToggleAutoSpeedAgility"}, -- shared with Speed
    [6] = {name = "Speed",      farm = "ToggleAutoSpeedAgility"}  -- shared
}

-- Helpers (formatNumber from main script - copy if needed, but assuming it's global or local)
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

local function safeToggle(name, state)
    pcall(function()
        local f = _G[name]
        if f and type(f) == "function" then f(state) end
    end)
end

local function disableAll()
    for _, cfg in pairs(statConfig) do
        safeToggle(cfg.farm, false)
        if cfg.aba then safeToggle(cfg.aba, false) end
    end
end

local function tpToBoom()
    pcall(function()
        local char = player.Character or player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart", 5)
        if hrp then
            hrp.CFrame = BOOM_NPC_CFRAME * CFrame.new(0, 0, -5)  -- Slight offset to stand in front (adjust if needed)
        end
    end)
end

-- Read current quest data
local function getCurrentQuestData()
    local quests = player:FindFirstChild("Quests")
    if not quests then return nil end

    local highest, folder = -1, nil
    for _, child in ipairs(quests:GetChildren()) do
        if child:IsA("Folder") then
            local n = tonumber(string.match(child.Name, "^Boom(%d+)$"))
            if n and n > highest then highest, folder = n, child end
        end
    end
    if not folder then return nil end

    local progress = folder:FindFirstChild("Progress")
    local reqs = folder:FindFirstChild("Requirements")
    if not progress or not reqs then return nil end

    local tasks = {}
    for i = 1, 6 do
        local p = progress:FindFirstChild(tostring(i))
        local r = reqs:FindFirstChild(tostring(i))
        tasks[i] = {
            current = p and type(p.Value) == "number" and p.Value or 0,
            required = r and type(r.Value) == "number" and r.Value or 0
        }
    end

    return {questNumber = highest, tasks = tasks, folder = folder}
end

-- Display function
_G.GetBoomQuestDisplayData = function()
    local data = getCurrentQuestData()
    if not data then
        return {statusText = "No Boom quest active", tasks = {}, questNumber = nil, isCompleted = false}
    end

    local tasksDisplay = {}
    local completed = 0
    local realTasks = 0
    local isDone = true

    for i = 1, 6 do
        local t = data.tasks[i]
        local name = statConfig[i].name or ("Task " .. i)
        table.insert(tasksDisplay, name .. ": " .. formatNumber(t.current) .. " / " .. formatNumber(t.required))

        if t.required > 0 then
            realTasks = realTasks + 1
            if t.current < t.required then isDone = false end
            if t.current >= t.required then completed = completed + 1 end
        end
    end

    return {
        statusText = isDone and ("Boom #" .. data.questNumber .. " — Completed (claim/next)") or ("Active: Boom #" .. data.questNumber),
        tasks = tasksDisplay,
        questNumber = data.questNumber,
        isCompleted = isDone,
        totalTasks = realTasks,
        completedTasks = completed
    }
end

-- Auto logic
local autoLoop = false

_G.ToggleAutoQuestBoom = function(enabled)
    autoLoop = enabled
    if not enabled then
        disableAll()
        return
    end

    task.spawn(function()
        while autoLoop do
            local data = getCurrentQuestData()
            if not data then
                disableAll()
                task.wait(3)
                continue
            end

            local isDone = true
            for i = 1, 6 do
                local t = data.tasks[i]
                if t.required > 0 and t.current < t.required then
                    isDone = false
                    break
                end
            end

            if isDone then
                disableAll()
                tpToBoom()
                task.wait(5)  -- Wait for claim/next
                continue
            end

            -- Find and enable FIRST unfinished stat
            local targetI = nil
            for i = 1, 6 do
                local t = data.tasks[i]
                if t.required > 0 and t.current < t.required then
                    targetI = i
                    break
                end
            end

            disableAll()  -- Ensure only one active

            if targetI then
                local cfg = statConfig[targetI]
                safeToggle(cfg.farm, true)
                if cfg.aba then safeToggle(cfg.aba, true) end
            end

            task.wait(1.5)  -- Check freq
        end
        disableAll()
    end)
end