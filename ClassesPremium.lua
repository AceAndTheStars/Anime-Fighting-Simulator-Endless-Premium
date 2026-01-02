-- ClassesPremium.lua - External Classes System Module (UPDATED WITH STAT PROGRESS)

-- Class name mapping
local ClassNames = {
    [1] = "Fighter", [2] = "Shinobi", [3] = "Pirate", [4] = "Ghoul", [5] = "Hero",
    [6] = "Reaper", [7] = "Saiyan", [8] = "Sin", [9] = "Magi", [10] = "Akuma",
    [11] = "Yonko", [12] = "Gorosei", [13] = "Overlord", [14] = "Hokage", [15] = "Kaioshin",
    [16] = "Sage", [17] = "Espada", [18] = "Shinigami", [19] = "Hashira", [20] = "Hakaishin",
    [21] = "Otsutsuki", [22] = "Pirate King", [23] = "Kishin", [24] = "Angel",
    [25] = "Demon King", [26] = "Ultra Instinct", [27] = "Upper Moon"
}

-- Class Requirements (Strength, Durability, Chakra)
local ClassRequirements = {
    [1] = 0,
    [2] = 1000,              -- 1k
    [3] = 10000,             -- 10k
    [4] = 100000,            -- 100k
    [5] = 1000000,           -- 1m
    [6] = 10000000,          -- 10m
    [7] = 1000000000,        -- 1b
    [8] = 100000000000,      -- 100b
    [9] = 1000000000000,     -- 1t
    [10] = 100000000000000,  -- 100t
    [11] = 1000000000000000, -- 1qd (quadrillion)
    [12] = 100000000000000000, -- 100qd
    [13] = 1000000000000000000, -- 1qn (quintillion)
    [14] = 100000000000000000000, -- 100qn
    [15] = 1000000000000000000000, -- 1sx (sextillion)
    [16] = 100000000000000000000000, -- 100sx
    [17] = 1000000000000000000000000, -- 1sp (septillion)
    [18] = 100000000000000000000000000, -- 100sp
    [19] = 1000000000000000000000000000, -- 1oc (octillion)
    [20] = 100000000000000000000000000000, -- 100oc
    [21] = 1000000000000000000000000000000, -- 1no (nonillion)
    [22] = 100000000000000000000000000000000, -- 100no
    [23] = 1000000000000000000000000000000000, -- 1dc (decillion)
    [24] = 100000000000000000000000000000000000, -- 100dc
    [25] = 1000000000000000000000000000000000000, -- 1ud (undecillion)
    [26] = 100000000000000000000000000000000000000, -- 100ud
    [27] = 1000000000000000000000000000000000000000 -- 1dd (duodecillion)
}

-- Format numbers with abbreviations
local function formatNumber(num)
    if num >= 1e36 then return string.format("%.2fdd", num / 1e36) -- duodecillion
    elseif num >= 1e33 then return string.format("%.2fud", num / 1e33) -- undecillion
    elseif num >= 1e30 then return string.format("%.2fdc", num / 1e30) -- decillion
    elseif num >= 1e27 then return string.format("%.2fno", num / 1e27) -- nonillion
    elseif num >= 1e24 then return string.format("%.2foc", num / 1e24) -- octillion
    elseif num >= 1e21 then return string.format("%.2fsp", num / 1e21) -- septillion
    elseif num >= 1e18 then return string.format("%.2fsx", num / 1e18) -- sextillion
    elseif num >= 1e15 then return string.format("%.2fqn", num / 1e15) -- quintillion
    elseif num >= 1e12 then return string.format("%.2fqd", num / 1e12) -- quadrillion
    elseif num >= 1e9 then return string.format("%.2ft", num / 1e9) -- trillion
    elseif num >= 1e6 then return string.format("%.2fb", num / 1e6) -- billion
    elseif num >= 1e3 then return string.format("%.2fm", num / 1e3) -- million
    else return tostring(math.floor(num))
    end
end

-- Get player stats safely
local function getPlayerStat(player, statName)
    local success, value = pcall(function()
        return player.leaderstats[statName].Value
    end)
    if success then
        return value or 0
    else
        return 0
    end
end

-- Live Updater (Current Class + Progress)
spawn(function()
    local previousClass = ""
    while true do
        task.wait(2)

        local player = game.Players.LocalPlayer

        -- Current Class
        local classSuccess, classValue = pcall(function()
            return player.OtherData.Class.Value
        end)

        if classSuccess and classValue then
            local className = ClassNames[classValue] or ("Unknown (" .. tostring(classValue) .. ")")
            if _G.CurrentClassLabel then
                _G.CurrentClassLabel:Set("Current Class: " .. className .. " (Rank " .. classValue .. ")")
            end

            if className ~= previousClass and previousClass ~= "" then
                Rayfield:Notify({
                    Title = "Class Rank Up!",
                    Content = "Successfully ranked up to " .. className .. "!",
                    Duration = 8,
                    Image = 4483362458
                })
            end
            previousClass = className

            -- Progress (only if enabled and we know the next rank requirement)
            if _G.ShowClassProgress and _G.ProgressLabel then
                local nextClass = classValue + 1
                local requiredStat = ClassRequirements[nextClass]
                
                if requiredStat then
                    -- Get current stats
                    local strength = getPlayerStat(player, "Strength")
                    local durability = getPlayerStat(player, "Durability")
                    local chakra = getPlayerStat(player, "Chakra")
                    
                    -- Calculate percentages
                    local strPercent = math.floor((strength / requiredStat) * 100)
                    local durPercent = math.floor((durability / requiredStat) * 100)
                    local chakPercent = math.floor((chakra / requiredStat) * 100)
                    
                    -- Check if all requirements are met
                    local allMet = strength >= requiredStat and durability >= requiredStat and chakra >= requiredStat
                    
                    local progressText = string.format(
                        "STR: %s/%s (%d%%) | DUR: %s/%s (%d%%) | CHK: %s/%s (%d%%)%s",
                        formatNumber(strength), formatNumber(requiredStat), strPercent,
                        formatNumber(durability), formatNumber(requiredStat), durPercent,
                        formatNumber(chakra), formatNumber(requiredStat), chakPercent,
                        allMet and " ✓ READY!" or ""
                    )
                    
                    _G.ProgressLabel:Set(progressText)
                else
                    _G.ProgressLabel:Set("Progress: MAX RANK REACHED!")
                end
            end
        else
            if _G.CurrentClassLabel then
                _G.CurrentClassLabel:Set("Current Class: Error Detecting")
            end
            if _G.ShowClassProgress and _G.ProgressLabel then
                _G.ProgressLabel:Set("Progress: Error - Cannot detect class")
            end
        end
    end
end)

-- Auto Rank Up (Fixed version)
_G.ToggleAutoRankUpClass = function(enabled)
    if enabled then
        if _G.AutoRankUpLoop then return end
        _G.AutoRankUpLoop = true

        Rayfield:Notify({
            Title = "Auto Rank Up Class",
            Content = "Enabled! Attempting to rank up every ~2 seconds.",
            Duration = 7,
            Image = 4483362458
        })
        if _G.ClassStatusLabel then 
            _G.ClassStatusLabel:Set("Status: ACTIVE (working...)") 
        end

        spawn(function()
            -- Try to find the correct remote (common names in AFSE-like games)
            local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
            local possibleRemoteNames = {
                "Class", "RankUpClass", "UpgradeClass", "ClassRankUp", 
                "RankUp", "RequestClass", "ClassUpgrade", "ClassRemote"
            }

            local classRemote = nil

            for _, name in ipairs(possibleRemoteNames) do
                local found = Remotes:FindFirstChild(name)
                if found and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then
                    classRemote = found
                    print("[AFSE Premium] Using class remote: " .. name .. " (" .. found.ClassName .. ")")
                    break
                end
            end

            if not classRemote then
                warn("[AFSE Premium] WARNING: No class rank-up remote found in Remotes!")
                Rayfield:Notify({
                    Title = "Auto Rank Up Error",
                    Content = "Couldn't find the class rank-up remote.\nCheck console (F9) for details.",
                    Duration = 12,
                    Image = 4483362458
                })
                _G.AutoRankUpLoop = false
                if _G.ClassStatusLabel then 
                    _G.ClassStatusLabel:Set("Status: FAILED - Remote not found") 
                end
                return
            end

            -- Main loop
            while _G.AutoRankUpLoop do
                task.wait(2) -- safer delay to avoid kick/rate limit

                pcall(function()
                    if classRemote:IsA("RemoteEvent") then
                        classRemote:FireServer()
                    elseif classRemote:IsA("RemoteFunction") then
                        classRemote:InvokeServer("RankUp") -- fallback arg if function
                    end
                end)
            end
        end)

    else
        _G.AutoRankUpLoop = false
        Rayfield:Notify({
            Title = "Auto Rank Up Class",
            Content = "Disabled.",
            Duration = 5,
            Image = 4483362458
        })
        if _G.ClassStatusLabel then 
            _G.ClassStatusLabel:Set("Status: Idle") 
        end
    end
end

-- Display Progress Toggle
_G.ToggleDisplayProgress = function(enabled)
    _G.ShowClassProgress = enabled
    if _G.ProgressLabel then
        if enabled then
            _G.ProgressLabel:Set("Progress: Loading...")
        else
            _G.ProgressLabel:Set("Progress: Disabled")
        end
    end
end

print("[AFSE Premium] Classes module loaded - with stat-based progress tracking")