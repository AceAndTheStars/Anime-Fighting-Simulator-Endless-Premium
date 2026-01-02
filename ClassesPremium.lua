-- ClassesPremium.lua - External Classes System Module (FIXED - 2025/2026 Update)

-- Class name mapping
local ClassNames = {
    [1] = "Fighter", [2] = "Shinobi", [3] = "Pirate", [4] = "Ghoul", [5] = "Hero",
    [6] = "Reaper", [7] = "Saiyan", [8] = "Sin", [9] = "Magi", [10] = "Akuma",
    [11] = "Yonko", [12] = "Gorosei", [13] = "Overlord", [14] = "Hokage", [15] = "Kaioshin",
    [16] = "Sage", [17] = "Espada", [18] = "Shinigami", [19] = "Hashira", [20] = "Hakaishin",
    [21] = "Otsutsuki", [22] = "Pirate King", [23] = "Kishin", [24] = "Angel",
    [25] = "Demon King", [26] = "Ultra Instinct", [27] = "Upper Moon"
}

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
                _G.CurrentClassLabel:Set("Current Class: " .. className)
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
        else
            if _G.CurrentClassLabel then
                _G.CurrentClassLabel:Set("Current Class: Error Detecting")
            end
        end

        -- Progress (only if enabled)
        if _G.ShowClassProgress and _G.ProgressLabel then
            local expSuccess, currentExp = pcall(function()
                return player.OtherData.ClassExp.Value
            end)

            if expSuccess and currentExp then
                local reqSuccess, requiredExp = pcall(function()
                    return player.OtherData.ClassExpRequired.Value
                end)

                local function formatNumber(num)
                    return tostring(num):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
                end

                if reqSuccess and requiredExp and requiredExp > 0 then
                    local percentage = math.floor((currentExp / requiredExp) * 100)
                    _G.ProgressLabel:Set(string.format("Progress: %s / %s (%d%%)", formatNumber(currentExp), formatNumber(requiredExp), percentage))
                else
                    _G.ProgressLabel:Set("Progress: " .. formatNumber(currentExp) .. " EXP")
                end
            else
                _G.ProgressLabel:Set("Progress: Not Found")
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

-- Display Progress Toggle (unchanged)
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

print("[AFSE Premium] Classes module loaded - fixed auto rank-up version")