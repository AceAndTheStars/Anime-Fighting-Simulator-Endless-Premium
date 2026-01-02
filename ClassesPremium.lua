-- ClassesPremium.lua - External Classes System Module (Simplified)

-- Get Rayfield from global if available
local Rayfield = _G.Rayfield or (function()
    warn("[ClassesPremium] Rayfield not found in _G, notifications may not work")
    return nil
end)()

-- Class name mapping
local ClassNames = {
    [1] = "Fighter", [2] = "Shinobi", [3] = "Pirate", [4] = "Ghoul", [5] = "Hero",
    [6] = "Reaper", [7] = "Saiyan", [8] = "Sin", [9] = "Magi", [10] = "Akuma",
    [11] = "Yonko", [12] = "Gorosei", [13] = "Overlord", [14] = "Hokage", [15] = "Kaioshin",
    [16] = "Sage", [17] = "Espada", [18] = "Shinigami", [19] = "Hashira", [20] = "Hakaishin",
    [21] = "Otsutsuki", [22] = "Pirate King", [23] = "Kishin", [24] = "Angel",
    [25] = "Demon King", [26] = "Ultra Instinct", [27] = "Upper Moon"
}

-- Live Current Class Updater
task.spawn(function()
    local previousClass = ""
    local getClassValue = nil -- Cache the working function
    
    while true do
        task.wait(2)

        local player = game.Players.LocalPlayer
        local classValue = nil
        local classSuccess = false

        -- Try multiple paths to find class value (cache the working one)
        if getClassValue then
            -- Use cached function
            classSuccess, classValue = pcall(getClassValue)
        else
            -- Try common paths
            local pathsToTry = {
                function() return player.OtherData.Class.Value end,
                function() return player.Data.Class.Value end,
                function() return player.leaderstats.Class.Value end,
                function() return player.Stats.Class.Value end,
                function() return player.PlayerData.Class.Value end,
                function() 
                    local otherData = player:FindFirstChild("OtherData")
                    if otherData then
                        local classObj = otherData:FindFirstChild("Class")
                        if classObj then return classObj.Value end
                    end
                end,
                function()
                    local data = player:FindFirstChild("Data")
                    if data then
                        local classObj = data:FindFirstChild("Class")
                        if classObj then return classObj.Value end
                    end
                end
            }
            
            for _, tryFunc in ipairs(pathsToTry) do
                classSuccess, classValue = pcall(tryFunc)
                
                if classSuccess and classValue and type(classValue) == "number" then
                    getClassValue = tryFunc
                    print("[AFSE Premium] Found class value: " .. tostring(classValue))
                    break
                end
            end
        end

        if classSuccess and classValue and type(classValue) == "number" then
            local className = ClassNames[classValue] or ("Unknown (" .. tostring(classValue) .. ")")
            
            if _G.CurrentClassLabel then
                _G.CurrentClassLabel:Set("Current Class: " .. className .. " (Rank " .. classValue .. ")")
            end

            -- Notify on rank up
            if className ~= previousClass and previousClass ~= "" and Rayfield then
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
                _G.CurrentClassLabel:Set("Current Class: Detecting...")
            end
        end
    end
end)

-- Auto Rank Up Function
_G.ToggleAutoRankUpClass = function(enabled)
    if enabled then
        if _G.AutoRankUpLoop then return end
        _G.AutoRankUpLoop = true

        if Rayfield then
            Rayfield:Notify({
                Title = "Auto Rank Up Class",
                Content = "Enabled! Attempting to rank up every ~2 seconds.",
                Duration = 7,
                Image = 4483362458
            })
        end
        if _G.ClassStatusLabel then 
            _G.ClassStatusLabel:Set("Status: ACTIVE (working...)") 
        end

        task.spawn(function()
            -- Use the standard RemoteEvent like other modules
            local Remotes = game:GetService("ReplicatedStorage"):WaitForChild("Remotes")
            local RemoteEvent = Remotes:WaitForChild("RemoteEvent")
            
            -- Try to find a specific class remote first
            local classRemote = nil
            local possibleRemoteNames = {
                "Class", "RankUpClass", "UpgradeClass", "ClassRankUp", 
                "RankUp", "RequestClass", "ClassUpgrade", "ClassRemote"
            }

            for _, name in ipairs(possibleRemoteNames) do
                local found = Remotes:FindFirstChild(name)
                if found and (found:IsA("RemoteEvent") or found:IsA("RemoteFunction")) then
                    classRemote = found
                    print("[AFSE Premium] Using class remote: " .. name .. " (" .. found.ClassName .. ")")
                    break
                end
            end

            -- If no specific remote found, use RemoteEvent with class method
            if not classRemote then
                classRemote = RemoteEvent
                print("[AFSE Premium] Using standard RemoteEvent for class rank-up")
            end

            -- Main loop
            local methodNames = {"RankUpClass", "Class", "UpgradeClass", "RankUp"}
            local currentMethodIndex = 1
            local lastError = nil
            local errorCount = 0
            
            while _G.AutoRankUpLoop do
                task.wait(2) -- safer delay to avoid kick/rate limit

                local success, err = pcall(function()
                    if classRemote:IsA("RemoteEvent") then
                        if classRemote == RemoteEvent then
                            -- Use RemoteEvent with method name like other features
                            local methodName = methodNames[currentMethodIndex] or methodNames[1]
                            RemoteEvent:FireServer(methodName)
                        else
                            -- Specific class remote, try without args first
                            classRemote:FireServer()
                        end
                    elseif classRemote:IsA("RemoteFunction") then
                        -- Try different argument patterns
                        local methodName = methodNames[currentMethodIndex] or methodNames[1]
                        classRemote:InvokeServer(methodName)
                    end
                end)
                
                if success then
                    errorCount = 0 -- Reset error count on success
                    if _G.ClassStatusLabel then 
                        _G.ClassStatusLabel:Set("Status: ACTIVE (working...)") 
                    end
                else
                    errorCount = errorCount + 1
                    lastError = tostring(err)
                    warn("[AFSE Premium] Class rank-up error (" .. errorCount .. "): " .. lastError)
                    
                    -- Try next method name if current one fails
                    if errorCount >= 3 then
                        currentMethodIndex = (currentMethodIndex % #methodNames) + 1
                        errorCount = 0
                        print("[AFSE Premium] Trying method: " .. methodNames[currentMethodIndex])
                    end
                    
                    -- If all methods fail consistently, show error
                    if errorCount >= 10 then
                        if _G.ClassStatusLabel then 
                            _G.ClassStatusLabel:Set("Status: ERROR - Check console") 
                        end
                        if Rayfield then
                            Rayfield:Notify({
                                Title = "Auto Rank Up Warning",
                                Content = "Having trouble ranking up. Check console (F9) for details.",
                                Duration = 8,
                                Image = 4483362458
                            })
                        end
                        errorCount = 0 -- Reset to avoid spam
                    end
                end
            end
        end)

    else
        _G.AutoRankUpLoop = false
        if Rayfield then
            Rayfield:Notify({
                Title = "Auto Rank Up Class",
                Content = "Disabled.",
                Duration = 5,
                Image = 4483362458
            })
        end
        if _G.ClassStatusLabel then 
            _G.ClassStatusLabel:Set("Status: Idle") 
        end
    end
end

print("[AFSE Premium] Classes module loaded - simplified version")