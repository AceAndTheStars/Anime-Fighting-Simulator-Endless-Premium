-- Anime Fighting Simulator Endless - Auto Stats Farm (Standalone Loadstring)
local RemoteEvent = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteEvent")

local statsRunning = {
    Strength = false,
    Durability = false,
    Chakra = false,
    Sword = false,
    SpeedAgility = false
}

-- Start individual stat farm
local function startStat(statName, statId, extraAction)
    if statsRunning[statName] then return end
    statsRunning[statName] = true

    task.spawn(function()
        -- Special case for Sword: equip once
        if statName == "Sword" and extraAction then
            pcall(function()
                RemoteEvent:FireServer("ActivateSword")
            end)
        end

        while statsRunning[statName] do
            pcall(function()
                if statName == "SpeedAgility" then
                    -- Trains both Speed (5) and Agility (6)
                    RemoteEvent:FireServer("Train", 5)
                    RemoteEvent:FireServer("Train", 6)
                else
                    RemoteEvent:FireServer("Train", statId)
                end
            end)
            task.wait(0.1)
        end
    end)
end

-- Stop individual stat farm
local function stopStat(statName)
    statsRunning[statName] = false
end

-- Public toggle functions - call these from your main hub
_G.ToggleAutoStrength = function(value)
    if value then
        startStat("Strength", 1)
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Strength Enabled", Duration = 4})
    else
        stopStat("Strength")
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Strength Disabled", Duration = 4})
    end
end

_G.ToggleAutoDurability = function(value)
    if value then
        startStat("Durability", 2)
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Durability Enabled", Duration = 4})
    else
        stopStat("Durability")
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Durability Disabled", Duration = 4})
    end
end

_G.ToggleAutoChakra = function(value)
    if value then
        startStat("Chakra", 3)
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Chakra Enabled", Duration = 4})
    else
        stopStat("Chakra")
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Chakra Disabled", Duration = 4})
    end
end

_G.ToggleAutoSword = function(value)
    if value then
        startStat("Sword", 4, true)  -- true = equip sword once
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Sword Enabled (equipped)", Duration = 4})
    else
        stopStat("Sword")
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Sword Disabled", Duration = 4})
    end
end

_G.ToggleAutoSpeedAgility = function(value)
    if value then
        startStat("SpeedAgility", nil)  -- no single ID, handled inside
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Speed & Agility Enabled", Duration = 4})
    else
        stopStat("SpeedAgility")
        game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "Speed & Agility Disabled", Duration = 4})
    end
end

-- Optional: Stop all at once
_G.StopAllAutofarms = function()
    for stat, _ in pairs(statsRunning) do
        statsRunning[stat] = false
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Autofarm", Text = "All autofarms stopped", Duration = 5})
end

game.StarterGui:SetCore("SendNotification", {
    Title = "Autofarm Module Loaded",
    Text = "Standalone stat autofarms ready! Toggle from your hub.",
    Duration = 6
})