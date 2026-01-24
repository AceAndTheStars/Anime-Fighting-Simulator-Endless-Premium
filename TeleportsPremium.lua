-- TeleportsPremium.lua - Auto-Click Portals for Specific Areas (100B Dura, 1Qn Chakra, 10K Speed)

_G.CreateManualTeleports = function(tab)
    if not tab then return end

    -- Smart teleport with auto-click for portals
    local function teleportToArea(position, clickDetectorPath)
        local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
        if not character or not character:FindFirstChild("HumanoidRootPart") then return end
        local hrp = character.HumanoidRootPart

        -- Teleport
        hrp.CFrame = CFrame.new(position)
        
        -- Auto-click portal if path provided
        if clickDetectorPath then
            task.spawn(function()
                task.wait(1)  -- Wait 1 second for load
                pcall(function()
                    local clickDetector = workspace:WaitForChild("Scriptable"):WaitForChild("NPC"):WaitForChild("Teleport"):WaitForChild(clickDetectorPath):WaitForChild("ClickBox"):WaitForChild("ClickDetector")
                    fireclickdetector(clickDetector)
                end)
            end)
        end
    end

    -- Strength (with previous tier name updates)
    tab:CreateSection("Strength")
    tab:CreateButton({ Name = "[100 Strength]", Callback = function() teleportToArea(Vector3.new(-6.535, 65.000, 127.964)) end })
    tab:CreateButton({ Name = "[10K Strength]", Callback = function() teleportToArea(Vector3.new(1341.183, 153.963, -134.552)) end })
    tab:CreateButton({ Name = "[100K Strength]", Callback = function() teleportToArea(Vector3.new(-1247.836, 59.000, 481.151)) end })
    tab:CreateButton({ Name = "[1M Strength]", Callback = function() teleportToArea(Vector3.new(-905.422, 84.882, 170.033)) end })
    tab:CreateButton({ Name = "[10M Strength]", Callback = function() teleportToArea(Vector3.new(-2257.115, 617.105, 546.753)) end })
    tab:CreateButton({ Name = "[100M Strength]", Callback = function() teleportToArea(Vector3.new(-51.014, 63.736, -1302.732)) end })
    tab:CreateButton({ Name = "[1B Strength]", Callback = function() teleportToArea(Vector3.new(714.433, 151.732, 926.474)) end })
    tab:CreateButton({ Name = "[100B Strength]", Callback = function() teleportToArea(Vector3.new(1846.153, 141.200, 90.468)) end })
    tab:CreateButton({ Name = "[5T Strength]", Callback = function() teleportToArea(Vector3.new(604.720, 653.458, 413.728)) end })
    tab:CreateButton({ Name = "[250T Strength]", Callback = function() teleportToArea(Vector3.new(4284.651, 60.000, -534.592)) end })
    tab:CreateButton({ Name = "[50qd Strength]", Callback = function() teleportToArea(Vector3.new(797.981, 232.382, -1002.742)) end })
    tab:CreateButton({ Name = "[1qn Strength]", Callback = function() teleportToArea(Vector3.new(3873.921, 136.388, 855.103)) end })
    tab:CreateButton({ Name = "[100QN Strength]", Callback = function() teleportToArea(Vector3.new(3933.355, 724.772, -1197.858)) end })
    tab:CreateButton({ Name = "[1sx Strength]", Callback = function() teleportToArea(Vector3.new(2317.814, 261.246, -625.500)) end })
    tab:CreateButton({ Name = "[100sx Strength]", Callback = function() teleportToArea(Vector3.new(-2359.330, 411.794, 1795.281)) end })
    tab:CreateButton({ Name = "[1SP Strength]", Callback = function() teleportToArea(Vector3.new(-2101.241, 1484.821, -2167.363)) end })

    -- Durability (100B needs auto-click!)
    tab:CreateSection("Durability")
    tab:CreateButton({ Name = "[100 Durability]", Callback = function() teleportToArea(Vector3.new(72.340, 69.263, 877.353)) end })
    tab:CreateButton({ Name = "[10K Durability]", Callback = function() teleportToArea(Vector3.new(-1602.088, 61.502, -532.064)) end })
    tab:CreateButton({ Name = "[100K Durability]", Callback = function() teleportToArea(Vector3.new(-77.845, 61.008, 2037.284)) end })
    tab:CreateButton({ Name = "[1M Durability]", Callback = function() teleportToArea(Vector3.new(-621.543, 179.000, 741.890)) end })
    tab:CreateButton({ Name = "[10M Durability]", Callback = function() teleportToArea(Vector3.new(-1102.311, 212.630, -946.145)) end })
    tab:CreateButton({ Name = "[100M Durability]", Callback = function() teleportToArea(Vector3.new(-341.295, 72.620, -1653.579)) end })
    tab:CreateButton({ Name = "[1B Durability]", Callback = function() teleportToArea(Vector3.new(2495.276, 1540.875, -356.906)) end })
    tab:CreateButton({ Name = "[100B Durability]", Callback = function() teleportToArea(Vector3.new(-2171.543, 617.517, 525.640), "DragonTeleport") end })  -- AUTO-CLICK!
    tab:CreateButton({ Name = "[5T Durability]", Callback = function() teleportToArea(Vector3.new(2188.043, 518.649, 576.627)) end })
    tab:CreateButton({ Name = "[250T Durability]", Callback = function() teleportToArea(Vector3.new(1671.975, 423.930, -1291.617)) end })
    tab:CreateButton({ Name = "[50qd Durability]", Callback = function() teleportToArea(Vector3.new(165.322, 773.591, -716.061)) end })
    tab:CreateButton({ Name = "[1qn Durability]", Callback = function() teleportToArea(Vector3.new(2590.823, 63.229, 1697.295)) end })
    tab:CreateButton({ Name = "[100QN Durability]", Callback = function() teleportToArea(Vector3.new(1726.687, 2305.067, 61.937)) end })
    tab:CreateButton({ Name = "[1sx Durability]", Callback = function() teleportToArea(Vector3.new(3485.344, 274.992, 1443.937)) end })
    tab:CreateButton({ Name = "[100sx Durability]", Callback = function() teleportToArea(Vector3.new(-2313.594, 84.296, -83.242)) end })
    tab:CreateButton({ Name = "[1SP Durability]", Callback = function() teleportToArea(Vector3.new(-1182.596, 82.653, -1886.213)) end })

    -- Chakra (1Qn needs auto-click!)
    tab:CreateSection("Chakra")
    tab:CreateButton({ Name = "[100 Chakra]", Callback = function() teleportToArea(Vector3.new(-3.768, 65.000, -117.034)) end })
    tab:CreateButton({ Name = "[10K Chakra]", Callback = function() teleportToArea(Vector3.new(1423.010, 147.000, -582.122)) end })
    tab:CreateButton({ Name = "[100K Chakra]", Callback = function() teleportToArea(Vector3.new(917.247, 141.000, 781.455)) end })
    tab:CreateButton({ Name = "[1M Chakra]", Callback = function() teleportToArea(Vector3.new(1576.373, 388.750, 675.160)) end })
    tab:CreateButton({ Name = "[10M Chakra]", Callback = function() teleportToArea(Vector3.new(334.134, -129.590, -1840.660)) end })
    tab:CreateButton({ Name = "[100M Chakra]", Callback = function() teleportToArea(Vector3.new(1028.428, 251.000, -627.812)) end })
    tab:CreateButton({ Name = "[1B Chakra]", Callback = function() teleportToArea(Vector3.new(3053.941, 110.900, 1105.880)) end })
    tab:CreateButton({ Name = "[100B Chakra]", Callback = function() teleportToArea(Vector3.new(1552.188, 88.724, 1717.498)) end })
    tab:CreateButton({ Name = "[5T Chakra]", Callback = function() teleportToArea(Vector3.new(-17.094, 62.073, -478.995)) end })
    tab:CreateButton({ Name = "[250T Chakra]", Callback = function() teleportToArea(Vector3.new(-396.257, 1237.356, 670.550)) end })
    tab:CreateButton({ Name = "[50qd Chakra]", Callback = function() teleportToArea(Vector3.new(-737.839, 2792.597, 567.334)) end })
    tab:CreateButton({ Name = "[1qn Chakra]", Callback = function() teleportToArea(Vector3.new(3151.687, 163.000, -102.653), "Ighicho") end })  -- AUTO-CLICK!
    tab:CreateButton({ Name = "[100QN Chakra]", Callback = function() teleportToArea(Vector3.new(358.822, 292.742, 1864.116)) end })
    tab:CreateButton({ Name = "[1sx Chakra]", Callback = function() teleportToArea(Vector3.new(-1092.224, 613.690, 1486.990)) end })
    tab:CreateButton({ Name = "[100sx Chakra]", Callback = function() teleportToArea(Vector3.new(1412.806, 232.000, -729.297)) end })
    tab:CreateButton({ Name = "[1SP Chakra]", Callback = function() teleportToArea(Vector3.new(3346.103, 59.500, -1654.329)) end })

    -- Speed & Agility (10K needs auto-click!)
    tab:CreateSection("Speed & Agility")
    tab:CreateButton({ Name = "[100 Speed]", Callback = function() teleportToArea(Vector3.new(-104.639, 61.000, -508.363)) end })
    tab:CreateButton({ Name = "[100 Agility]", Callback = function() teleportToArea(Vector3.new(39.896, 69.183, 462.580)) end })
    tab:CreateButton({ Name = "[10K Speed & Agility]", Callback = function() teleportToArea(Vector3.new(-386.277, 105.000, -47.382), "ThePodTeleport") end })  -- AUTO-CLICK!
    tab:CreateButton({ Name = "[100K Speed & Agility]", Callback = function() teleportToArea(Vector3.new(3484.517, 60.000, 144.701)) end })
    tab:CreateButton({ Name = "[5M Speed & Agility]", Callback = function() teleportToArea(Vector3.new(4111.812, 60.922, 849.557)) end })

    -- Quest NPCs (Kirito rename applied)
    tab:CreateSection("Teleport to Quest NPCs")
    tab:CreateButton({ Name = "Boom", Callback = function() teleportToArea(Vector3.new(-33.801, 80.224, 3.453)) end })
    tab:CreateButton({ Name = "Ghoul", Callback = function() teleportToArea(Vector3.new(1695.234, 142.400, -172.643)) end })
    tab:CreateButton({ Name = "Giovanni", Callback = function() teleportToArea(Vector3.new(151.815, 62.400, -231.939)) end })
    tab:CreateButton({ Name = "Kirito", Callback = function() teleportToArea(Vector3.new(23.235, 105.143, 36.597)) end })
    tab:CreateButton({ Name = "Reindeer", Callback = function() teleportToArea(Vector3.new(-31.839, 105.146, 35.543)) end })
    tab:CreateButton({ Name = "Sword Master", Callback = function() teleportToArea(Vector3.new(325.219, 69.576, -1990.182)) end })
end