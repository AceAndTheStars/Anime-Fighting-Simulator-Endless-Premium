-- Anime Fighting Simulator Endless - Fast Boss Farming (White Eyes Bloodline Method)
-- Requires: White Eyes Bloodline equipped + manually summoned BEFORE enabling any farm

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteFunction = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteFunction")

local player = Players.LocalPlayer

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
        pos = Vector3.new(275.783, 61.000, 284.725),
        look = Vector3.new(-0.017, -0.000, -1.000)
    },
    Gen = {
        pos = Vector3.new(-400.931, 61.000, 724.455),
        look = Vector3.new(1.000, 0.000, 0.026)
    },
    Igicho = {
        pos = Vector3.new(578.871, 61.000, -1537.395),
        look = Vector3.new(1.000, 0.000, 0.017)
    },
    Booh = {
        pos = Vector3.new(923.588, 243.000, 946.123),
        look = Vector3.new(-0.259, -0.000, 0.966)
    },
    Remgonuk = {
        pos = Vector3.new(3035.528, 60.000, -496.740),
        look = Vector3.new(-0.933, 0.000, -0.122)
    },
    Saytamu = {
        pos = Vector3.new(489.211, 61.008, 1762.043),
        look = Vector3.new(-1.000, -0.000, 0.000)
    }
}

-- Safe ground part for reliable MouseHit
local safeGroundPart = workspace:WaitForChild("Map"):WaitForChild("Other"):WaitForChild("RoadParts"):WaitForChild("Part")

-- X Ability args (your optimized values)
local xAbilityArgs = {
    "UseSpecialPower",
    Enum.KeyCode.X,
    {
        MouseCF = CFrame.new(-139.1046142578125, 59, -212.29611206054688, 0.9975171685218811, 0.04779018089175224, -0.0517275370657444, -0, 0.7345084547996521, 0.6785996556282043, 0.07042470574378967, -0.6769148111343384, 0.7326846718788147),
        MouseHit = safeGroundPart,
        MousePos = Vector3.new(-139.1046142578125, 59, -212.29611206054688)
    }
}

local function startFarm(bossName)
    if farmStates[bossName] then return end
    farmStates[bossName] = true

    local config = bossConfigs[bossName]

    -- No auto-summon - user must do it manually (as requested)

    spawn(function()
        while farmStates[bossName] do
            local character = player.Character or player.CharacterAdded:Wait()
            local hrp = character:WaitForChild("HumanoidRootPart")

            -- Teleport to the exact position + correct rotation for this boss
            local targetCFrame = CFrame.new(config.pos, config.pos + config.look)
            hrp.CFrame = targetCFrame

            -- Spam X ability
            pcall(function()
                RemoteFunction:InvokeServer(unpack(xAbilityArgs))
            end)

            task.wait(0.35)  -- Fast and stable rate
        end
    end)
end

local function stopFarm(bossName)
    farmStates[bossName] = false
end

-- Toggle functions (matches your main hub flags)
_G.ToggleAutoFarmSarka = function(enabled) if enabled then startFarm("Sarka") else stopFarm("Sarka") end end
_G.ToggleAutoFarmGen = function(enabled) if enabled then startFarm("Gen") else stopFarm("Gen") end end
_G.ToggleAutoFarmIgicho = function(enabled) if enabled then startFarm("Igicho") else stopFarm("Igicho") end end
_G.ToggleAutoFarmBooh = function(enabled) if enabled then startFarm("Booh") else stopFarm("Booh") end end
_G.ToggleAutoFarmRemgonuk = function(enabled) if enabled then startFarm("Remgonuk") else stopFarm("Remgonuk") end end
_G.ToggleAutoFarmSaytamu = function(enabled) if enabled then startFarm("Saytamu") else stopFarm("Saytamu") end end

-- Notification on load
game:GetService("StarterGui"):SetCore("SendNotification", {
    Title = "Mobs Module Loaded",
    Text = "White Eyes Bloodline Meta - Remember to summon manually before farming!",
    Duration = 8
})