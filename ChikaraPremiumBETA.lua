-- Anime Fighting Simulator Endless - Chikara Premium BETA Farm
-- No-Teleport / Max Distance ClickDetector Method - ORIGINAL PATH ONLY
-- Clean & low-detection style

if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local chikaraRunning = false

local FALLBACK_POSITIONS = {
    Vector3.new(-905.508, 84.471, 173.780),
    Vector3.new(178.180, 61.000, -1325.945),
    Vector3.new(1323.146, 244.000, -132.530),
    Vector3.new(-80.555, 155.231, 2031.298),
    Vector3.new(3263.230, 60.000, 1206.900),
    Vector3.new(3725.708, 55.000, -127.417)
}

local function notify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title or "Chikara BETA",
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function startChikaraFarm()
    if chikaraRunning then return end
    chikaraRunning = true

    notify("Chikara BETA", "Max Distance Farm ENABLED\n(No constant TP)", 6)

    task.spawn(function()
        local character = player.Character or player.CharacterAdded:Wait()
        local root = character:WaitForChild("HumanoidRootPart", 8)

        local chikaraFolder = Workspace:WaitForChild("Scriptable", 10)
            and Workspace.Scriptable:WaitForChild("ChikaraBoxes", 10)

        if not chikaraFolder then
            notify("CRITICAL ERROR", "workspace.Scriptable.ChikaraBoxes not found!\nThe path has most likely changed.", 10)
            chikaraRunning = false
            return
        end

        local originalDistances = {}

        -- Apply to existing
        for _, box in ipairs(chikaraFolder:GetChildren()) do
            task.spawn(function()
                local clickBox = box:FindFirstChild("ClickBox")
                if clickBox then
                    local detector = clickBox:FindFirstChildOfClass("ClickDetector")
                    if detector then
                        originalDistances[detector] = detector.MaxActivationDistance
                        detector.MaxActivationDistance = 9999
                    end
                end
            end)
        end

        -- New boxes
        local childAddedConn = chikaraFolder.ChildAdded:Connect(function(child)
            task.delay(0.5, function()
                local clickBox = child:FindFirstChild("ClickBox")
                if clickBox then
                    local detector = clickBox:FindFirstChildOfClass("ClickDetector")
                    if detector and not originalDistances[detector] then
                        originalDistances[detector] = detector.MaxActivationDistance
                        detector.MaxActivationDistance = 9999
                    end
                end
            end)
        end)

        local charAddedConn = player.CharacterAdded:Connect(function(newChar)
            character = newChar
            root = newChar:WaitForChild("HumanoidRootPart", 8)
        end)

        local noBoxTimer = 0
        local MAX_NO_BOX_WAIT = 110

        while chikaraRunning and root and root.Parent do
            local foundAny = false

            for _, box in ipairs(chikaraFolder:GetChildren()) do
                local clickBox = box:FindFirstChild("ClickBox")
                if clickBox then
                    local detector = clickBox:FindFirstChildOfClass("ClickDetector")
                    if detector and detector.MaxActivationDistance >= 9000 then
                        pcall(function()
                            fireclickdetector(detector)
                            task.wait(0.035)
                            fireclickdetector(detector)
                        end)
                        foundAny = true
                    end
                end
            end

            if foundAny then
                noBoxTimer = 0
            else
                noBoxTimer = noBoxTimer + 1
                if noBoxTimer >= MAX_NO_BOX_WAIT then
                    local pos = FALLBACK_POSITIONS[math.random(1, #FALLBACK_POSITIONS)]
                    root.CFrame = CFrame.new(pos)
                    noBoxTimer = 0
                end
            end

            task.wait(0.8)
        end

        -- Cleanup
        for det, orig in pairs(originalDistances) do
            pcall(function()
                if det and det.Parent then det.MaxActivationDistance = orig end
            end)
        end

        childAddedConn:Disconnect()
        charAddedConn:Disconnect()

        notify("Chikara BETA", "Disabled - detectors restored", 5)
    end)
end

local function stopChikaraFarm()
    chikaraRunning = false
end

_G.ToggleOPRemoteChikaraFarmBeta = function(state)
    if state then
        startChikaraFarm()
    else
        stopChikaraFarm()
    end
end

notify("Chikara BETA", "Loaded - use the toggle in hub", 4)