-- TeleportsPremium.lua - Manual Training Teleports for AFSE Premium (Updated for Nerfs)

_G.CreateManualTeleports = function(tab)
    if not tab then return end

    local trainingFolder = game:GetService("Workspace").Scriptable:WaitForChild("TrainingAreas")

    -- Placeholder teleport function (do nothing for now)
    local function teleportToArea(areaName)
        -- Actual teleport logic will go here later
    end

    -- Strength Section
    tab:CreateSection("Strength")
    tab:CreateButton({ Name = "[100 Strength] (1)", Callback = function() teleportToArea("1") end })
    tab:CreateButton({ Name = "[10K Strength] (8)", Callback = function() teleportToArea("8") end })
    tab:CreateButton({ Name = "[100K Strength] (9)", Callback = function() teleportToArea("9") end })
    tab:CreateButton({ Name = "[1M Strength] (10)", Callback = function() teleportToArea("10") end })
    tab:CreateButton({ Name = "[10M Strength] (11)", Callback = function() teleportToArea("11") end })
    tab:CreateButton({ Name = "[100M Strength] (12)", Callback = function() teleportToArea("12") end })
    tab:CreateButton({ Name = "[1B Strength] (13)", Callback = function() teleportToArea("13") end })
    tab:CreateButton({ Name = "[100B Strength] (14)", Callback = function() teleportToArea("14") end })
    tab:CreateButton({ Name = "[5T Strength] (31)", Callback = function() teleportToArea("31") end })
    tab:CreateButton({ Name = "[250T Strength] (32)", Callback = function() teleportToArea("32") end })
    tab:CreateButton({ Name = "[150qd Strength] (42)", Callback = function() teleportToArea("42") end })
    tab:CreateButton({ Name = "[2.5QN Strength] (43)", Callback = function() teleportToArea("43") end })  -- Updated
    tab:CreateButton({ Name = "[1sx Strength] (44)", Callback = function() teleportToArea("44") end })      -- Updated

    -- Durability Section
    tab:CreateSection("Durability")
    tab:CreateButton({ Name = "[100 Durability] (3)", Callback = function() teleportToArea("3") end })
    tab:CreateButton({ Name = "[10K Durability] (17)", Callback = function() teleportToArea("17") end })
    tab:CreateButton({ Name = "[100K Durability] (18)", Callback = function() teleportToArea("18") end })
    tab:CreateButton({ Name = "[1M Durability] (19)", Callback = function() teleportToArea("19") end })
    tab:CreateButton({ Name = "[10M Durability] (20)", Callback = function() teleportToArea("20") end })
    tab:CreateButton({ Name = "[100M Durability] (21)", Callback = function() teleportToArea("21") end })
    tab:CreateButton({ Name = "[1B Durability] (22)", Callback = function() teleportToArea("22") end })
    tab:CreateButton({ Name = "[100B Durability] (23)", Callback = function() teleportToArea("23") end })
    tab:CreateButton({ Name = "[5T Durability] (33)", Callback = function() teleportToArea("33") end })
    tab:CreateButton({ Name = "[250T Durability] (34)", Callback = function() teleportToArea("34") end })
    tab:CreateButton({ Name = "[150QD Durability] (39)", Callback = function() teleportToArea("39") end })
    tab:CreateButton({ Name = "[2.5QN Durability] (40)", Callback = function() teleportToArea("40") end })  -- Updated
    tab:CreateButton({ Name = "[1sx Durability] (41)", Callback = function() teleportToArea("41") end })      -- Updated

    -- Chakra Section
    tab:CreateSection("Chakra")
    tab:CreateButton({ Name = "[100 Chakra] (2)", Callback = function() teleportToArea("2") end })
    tab:CreateButton({ Name = "[10K Chakra] (24)", Callback = function() teleportToArea("24") end })
    tab:CreateButton({ Name = "[100K Chakra] (25)", Callback = function() teleportToArea("25") end })
    tab:CreateButton({ Name = "[1M Chakra] (26)", Callback = function() teleportToArea("26") end })
    tab:CreateButton({ Name = "[10M Chakra] (27)", Callback = function() teleportToArea("27") end })
    tab:CreateButton({ Name = "[100M Chakra] (28)", Callback = function() teleportToArea("28") end })
    tab:CreateButton({ Name = "[1B Chakra] (29)", Callback = function() teleportToArea("29") end })
    tab:CreateButton({ Name = "[100B Chakra] (30)", Callback = function() teleportToArea("30") end })
    tab:CreateButton({ Name = "[5T Chakra] (37)", Callback = function() teleportToArea("37") end })
    tab:CreateButton({ Name = "[250T Chakra] (38)", Callback = function() teleportToArea("38") end })
    tab:CreateButton({ Name = "[150qd Chakra] (45)", Callback = function() teleportToArea("45") end })
    tab:CreateButton({ Name = "[2.5QN Chakra] (46)", Callback = function() teleportToArea("46") end })  -- Updated
    tab:CreateButton({ Name = "[1sx Chakra] (47)", Callback = function() teleportToArea("47") end })      -- Updated

    -- Speed & Agility Section
    tab:CreateSection("Speed & Agility")
    tab:CreateButton({ Name = "[100 Speed] (4)", Callback = function() teleportToArea("4") end })
    tab:CreateButton({ Name = "[100 Agility] (5)", Callback = function() teleportToArea("5") end })
    tab:CreateButton({ Name = "[10K Speed & Agility] (6)", Callback = function() teleportToArea("6") end })
    tab:CreateButton({ Name = "[100K Speed & Agility] (16)", Callback = function() teleportToArea("16") end })
    tab:CreateButton({ Name = "[5M Speed & Agility] (36)", Callback = function() teleportToArea("36") end })
end