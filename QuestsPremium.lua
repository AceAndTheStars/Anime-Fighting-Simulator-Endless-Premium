-- QuestsPremium.lua - SEQUENTIAL AUTO TRAIN (one stat at a time, toggle-controlled)
-- Updated for Anime Fighting Simulator: Endless (AFSE) - Boom quest auto-claim via ClickDetector

local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG: Boom NPC CFrame (updated position + orientation)
local BOOM_NPC_CFRAME = CFrame.new(
    -33.017746, 80.2238693, 3.40424752,
    -0.0262032673, -4.25549507e-09, 0.999656618,
    3.95084276e-09, 1, 4.36051728e-09,
    -0.999656618, 4.06374623e-09, -0.0262032673
)

-- Direct path to Boom's ClickDetector (for auto-talk/claim)
local function getBoomClickDetector()
    local path = workspace
    path = path:FindFirstChild("Scriptable")
    if not path then return nil end
    path = path:FindFirstChild("NPC")
    if not path then return nil end
    path = path:FindFirstChild("Quest")
    if not path then return nil end
    path = path:FindFirstChild("Boom")
    if not path then return nil end
    path = path:FindFirstChild("ClickBox")
    if not path then return nil end
    return path:FindFirstChild("ClickDetector")
end

local statConfig = {
    [1] = {name = "Strength",   farm = "ToggleAutoStrength",     aba = "ToggleAutoTpBestStrength"},
    [2] = {name = "Durability", farm = "ToggleAutoDurability",   aba = "ToggleAutoTpBestDurability"},
    [3] = {name = "Chakra",     farm = "ToggleAutoChakra",       aba = "ToggleAutoTpBestChakra"},
    [4] = {name = "Sword",      farm = "ToggleAutoSword"},  -- no ABA
    [5] = {name = "Agility",    farm = "ToggleAutoSpeedAgility"}, -- shared with Speed
    [6] = {name = "Speed",      farm = "ToggleAutoSpeedAgility"}  -- shared
}

-- Helpers
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
        if not hrp then return end
        
        -- Teleport player in front of Boom, facing him
        hrp.CFrame = BOOM_NPC_CFRAME * CFrame.new(0, 0, -4.5)  -- adjust -4 / -5 / -6 if needed
        
        task.wait(0.3)  -- let character settle
        
        -- Fire the ClickDetector directly
        local clickDetector = getBoomClickDetector()
        if clickDetector and clickDetector:IsA("ClickDetector") then
            fireclickdetector(clickDetector)
            -- Optional: double-click for reliability on some servers
            -- task.wait(0.15)
            -- fireclickdetector(clickDetector)
            print("Clicked Boom → quest should claim / next!")
        else
            warn("Could not find Boom ClickDetector! Check workspace.Scriptable.NPC.Quest.Boom.ClickBox.ClickDetector")
        end
        
        task.wait(2.5)  -- time for claim/next quest animation & server response
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

-- Display function (for GUI/HUD)
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
                task.wait(5)  -- extra safety wait after claim
                continue
            end

            -- Find and enable FIRST unfinished stat only
            local targetI = nil
            for i = 1, 6 do
                local t = data.tasks[i]
                if t.required > 0 and t.current < t.required then
                    targetI = i
                    break
                end
            end

            disableAll()  -- make sure only one is active

            if targetI then
                local cfg = statConfig[targetI]
                safeToggle(cfg.farm, true)
                if cfg.aba then safeToggle(cfg.aba, true) end
            end

            task.wait(1.5)  -- check interval
        end
        disableAll()
    end)
end