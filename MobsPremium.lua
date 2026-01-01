-- Anime Fighting Simulator Endless - Fast Boss Farming (Wind Grimoire Method)
local player = game.Players.LocalPlayer
local RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RemoteFunction")

local farmStates = {
    Sarka = false,
    Gen = false,
    Igicho = false,
    Booh = false,
    Remgonuk = false,
    Saytamu = false
}

local bossConfigs = {
    Sarka = {
        pos = Vector3.new(277.47, 60.99, 305.44),
        look = Vector3.new(-0.017, -0.000, -1.000)
    },
    Gen = {
        pos = Vector3.new(-424.065, 60.999, 723.472),
        look = Vector3.new(1.000, 0.000, 0.026)
    },
    Igicho = {
        pos = Vector3.new(535.10, 60.99, -1538.90),
        look = Vector3.new(1.000, 0.000, 0.017)
    },
    Booh = {
        pos = Vector3.new(931.16, 242.99, 919.85),
        look = Vector3.new(-0.259, -0.000, 0.966)
    },
    Remgonuk = {
        pos = Vector3.new(3077.19, 59.99, -491.97),
        look = Vector3.new(-0.933, 0.000, -0.122)
    },
    Saytamu = {
        pos = Vector3.new(527.87, 61.00, 1761.96),
        look = Vector3.new(-1.000, -0.000, 0.000)
    }
}

local function startFarm(bossName)
    if farmStates[bossName] then return end
    farmStates[bossName] = true

    local config = bossConfigs[bossName]
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")

    -- Teleport with precise rotation
    local targetCFrame = CFrame.new(config.pos, config.pos + config.look)
    hrp.CFrame = targetCFrame

    -- Summon Wind Grimoire once
    pcall(function()
        RemoteFunction:InvokeServer("SummonSpecial", "Grimoires")
    end)

    -- Spam Z ability
    task.spawn(function()
        while farmStates[bossName] do
            pcall(function()
                RemoteFunction:InvokeServer("UseSpecialPower", Enum.KeyCode.Z)
            end)
            task.wait(1.55)
        end
    end)
end

local function stopFarm(bossName)
    farmStates[bossName] = false
end

-- Global toggles
_G.ToggleAutoFarmSarka = function(v) if v then startFarm("Sarka") else stopFarm("Sarka") end end
_G.ToggleAutoFarmGen = function(v) if v then startFarm("Gen") else stopFarm("Gen") end end
_G.ToggleAutoFarmIgicho = function(v) if v then startFarm("Igicho") else stopFarm("Igicho") end end
_G.ToggleAutoFarmBooh = function(v) if v then startFarm("Booh") else stopFarm("Booh") end end
_G.ToggleAutoFarmRemgonuk = function(v) if v then startFarm("Remgonuk") else stopFarm("Remgonuk") end end
_G.ToggleAutoFarmSaytamu = function(v) if v then startFarm("Saytamu") else stopFarm("Saytamu") end end

game.StarterGui:SetCore("SendNotification", {
    Title = "Mobs Module Loaded",
    Text = "Fast boss farming with Wind Grimoire ready!",
    Duration = 6
})