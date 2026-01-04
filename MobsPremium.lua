-- Mobs Tab
local MobsTab = Window:CreateTab("Mobs", "swords") -- Or "skull" if you want something darker
MobsTab:CreateSection("Boss / Mob Farming (Fast)")

MobsTab:CreateButton({
    Name = "Get White Eyes Bloodline",
    Callback = function()
        local player = game.Players.LocalPlayer
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        Rayfield:Notify({
            Title = "White Eyes Bloodline",
            Content = "Teleporting to White Eyes Bloodline location...",
            Duration = 5,
            Image = 4483362458
        })
        -- Replace this CFrame with the actual location of White Eyes Bloodline when you find it
        humanoidRootPart.CFrame = CFrame.new(0, 100, 0) -- Placeholder - update with real coords
    end
})

-- New clean toggles - ready for your completely remade farming logic
MobsTab:CreateToggle({ Name = "Auto Farm Sarka (fast)", CurrentValue = false, Flag = "AutoFarmSarka", Callback = safeToggle("ToggleAutoFarmSarka") })
MobsTab:CreateToggle({ Name = "Auto Farm Gen (fast)", CurrentValue = false, Flag = "AutoFarmGen", Callback = safeToggle("ToggleAutoFarmGen") })
MobsTab:CreateToggle({ Name = "Auto Farm Igicho (fast)", CurrentValue = false, Flag = "AutoFarmIgicho", Callback = safeToggle("ToggleAutoFarmIgicho") })
MobsTab:CreateToggle({ Name = "Auto Farm Booh (fast)", CurrentValue = false, Flag = "AutoFarmBooh", Callback = safeToggle("ToggleAutoFarmBooh") })
MobsTab:CreateToggle({ Name = "Auto Farm Remgonuk (fast)", CurrentValue = false, Flag = "AutoFarmRemgonuk", Callback = safeToggle("ToggleAutoFarmRemgonuk") })
MobsTab:CreateToggle({ Name = "Auto Farm Saytamu (fast)", CurrentValue = false, Flag = "AutoFarmSaytamu", Callback = safeToggle("ToggleAutoFarmSaytamu") })