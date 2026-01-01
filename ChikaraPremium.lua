-- Anime Fighting Simulator Endless - Auto Farm Chikara Shards (Standalone)
local player = game.Players.LocalPlayer
local chikaraRunning = false

local fallbackPositions = {
    Vector3.new(-905.508, 84.471, 173.780),
    Vector3.new(178.180, 61.000, -1325.945),
    Vector3.new(1323.146, 244.000, -132.530),
    Vector3.new(-80.555, 155.231, 2031.298),
    Vector3.new(3263.230, 60.000, 1206.900),
    Vector3.new(3725.708, 55.000, -127.417)
}

local function startChikaraFarm()
    if chikaraRunning then return end
    chikaraRunning = true

    game.StarterGui:SetCore("SendNotification", {
        Title = "Chikara Farm",
        Text = "Auto Farm Chikara Shards Enabled!",
        Duration = 5
    })

    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
        local chikaraFolder = game:GetService("Workspace").Scriptable:WaitForChild("ChikaraBoxes")

        player.CharacterAdded:Connect(function(newChar)
            character = newChar
            humanoidRootPart = newChar:WaitForChild("HumanoidRootPart")
        end)

        while chikaraRunning do
            local boxes = chikaraFolder:GetChildren()
            local foundBox = false

            if #boxes > 0 then
                local closestDetector = nil
                local closestClickBox = nil
                local closestDistance = math.huge

                for _, box in ipairs(boxes) do
                    local clickBox = box:FindFirstChild("ClickBox")
                    if clickBox then
                        local detector = clickBox:FindFirstChild("ClickDetector")
                        if detector then
                            local distance = (humanoidRootPart.Position - clickBox.Position).Magnitude
                            if distance < closestDistance then
                                closestDistance = distance
                                closestDetector = detector
                                closestClickBox = clickBox
                            end
                        end
                    end
                end

                if closestDetector and closestClickBox then
                    foundBox = true
                    humanoidRootPart.CFrame = closestClickBox.CFrame
                    pcall(function()
                        fireclickdetector(closestDetector)
                    end)
                end
            end

            if not foundBox then
                local randomPos = fallbackPositions[math.random(1, #fallbackPositions)]
                humanoidRootPart.CFrame = CFrame.new(randomPos)
            end

            task.wait(0.25)
        end
    end)
end

local function stopChikaraFarm()
    chikaraRunning = false
    game.StarterGui:SetCore("SendNotification", {
        Title = "Chikara Farm",
        Text = "Auto Farm Chikara Shards Disabled",
        Duration = 4
    })
end

-- Toggle function - call this from your Rayfield toggle
_G.ToggleChikaraFarm = function(value)
    if value then
        startChikaraFarm()
    else
        stopChikaraFarm()
    end
end

-- Initial notification
game.StarterGui:SetCore("SendNotification", {
    Title = "Chikara Farm Loaded",
    Text = "Standalone Chikara farm ready! Toggle it in your hub.",
    Duration = 6
})