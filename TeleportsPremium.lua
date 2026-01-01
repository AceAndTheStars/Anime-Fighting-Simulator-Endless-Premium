-- Anime Fighting Simulator Endless - Dynamic Training Areas Teleports (Standalone Module)

local trainingFolder = game:GetService("Workspace").Scriptable:WaitForChild("TrainingAreas")

local nameMap = {
    ["1"] = "[100 Strength]",
    ["2"] = "[100 Chakra]",
    ["3"] = "[100 Durability]",
    ["4"] = "[100 Speed]",
    ["5"] = "[100 Agility]",
    ["6"] = "[10K Speed & Agility]",
    ["8"] = "[10K Strength]",
    ["9"] = "[100K Strength]",
    ["10"] = "[1M Strength]",
    ["11"] = "[10M Strength]",
    ["12"] = "[100M Strength]",
    ["13"] = "[1B Strength]",
    ["14"] = "[100B Strength]",
    ["16"] = "[100K Speed & Agility]",
    ["17"] = "[10K Durability]",
    ["18"] = "[100K Durability]",
    ["19"] = "[1M Durability]",
    ["20"] = "[10M Durability]",
    ["21"] = "[100M Durability]",
    ["22"] = "[1B Durability]",
    ["23"] = "[100B Durability]",
    ["24"] = "[10K Chakra]",
    ["25"] = "[100K Chakra]",
    ["26"] = "[1M Chakra]",
    ["27"] = "[10M Chakra]",
    ["28"] = "[100M Chakra]",
    ["29"] = "[1B Chakra]",
    ["30"] = "[100B Chakra]",
    ["31"] = "[5T Strength]",
    ["32"] = "[250T Strength]",
    ["33"] = "[5T Durability]",
    ["34"] = "[250T Durability]",
    ["36"] = "[5M Speed & Agility]",
    ["37"] = "[5T Chakra]",
    ["38"] = "[250T Chakra]",
    ["39"] = "[150QD Durability]",
    ["40"] = "[25QN Durability]",
    ["41"] = "[10sx Durability]",
    ["42"] = "[150qd Strength]",
    ["43"] = "[25QN Strength]",
    ["44"] = "[10sx Strength]",
    ["45"] = "[150qd Chakra]",
    ["46"] = "[25QN Chakra]",
    ["47"] = "[10sx Chakra]"
}

local function getTrainingAreaDisplayNames()
    local areas = {}
    for _, area in ipairs(trainingFolder:GetChildren()) do
        if area:IsA("BasePart") or area:IsA("Model") then
            local num = tonumber(area.Name)
            if num then
                local displayName = nameMap[area.Name] or area.Name
                table.insert(areas, {num = num, display = displayName .. " (" .. area.Name .. ")"})
            end
        end
    end
    
    table.sort(areas, function(a, b) return a.num < b.num end)
    
    local displayNames = {}
    for _, entry in ipairs(areas) do
        table.insert(displayNames, entry.display)
    end
    
    return displayNames
end

local function getOriginalNameFromDisplay(displayName)
    local original = displayName:match("%((%d+)%)$")
    return original
end

local function isPlayerClipped()
    local character = game.Players.LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = character.HumanoidRootPart
    
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {character}
    params.FilterType = Enum.RaycastFilterType.Exclude
    
    local directions = {
        Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0),
        Vector3.new(0, 0, 1), Vector3.new(0, 0, -1),
        Vector3.new(0, 1, 0), Vector3.new(0, -1, 0)
    }
    
    for _, dir in ipairs(directions) do
        local result = workspace:Raycast(hrp.Position, dir * 5, params)
        if result then
            return true
        end
    end
    return false
end

-- Public function to create the dropdown in the given tab
_G.CreateTeleportsDropdown = function(tab)
    tab:CreateSection("Training Areas")

    tab:CreateParagraph({ Title = "Teleports", Content = "Select a training area below to teleport there." })
    tab:CreateParagraph({ Title = "Note", Content = "If you can't find your area in the list, explore a bit of the map to load it in!" })

    local trainingDropdown = tab:CreateDropdown({
        Name = "Training Areas",
        Options = getTrainingAreaDisplayNames(),
        CurrentOption = {"Select an area"},
        MultipleOptions = false,
        Flag = "TrainingAreaTeleport",
        Callback = function(selectedDisplayName)
            local targetOriginalName = getOriginalNameFromDisplay(selectedDisplayName[1] or selectedDisplayName)
            if not targetOriginalName then return end
            
            local character = game.Players.LocalPlayer.Character
            if not character or not character:FindFirstChild("HumanoidRootPart") then 
                Rayfield:Notify({Title = "Error", Content = "Character not loaded!", Duration = 5})
                return 
            end
            local hrp = character.HumanoidRootPart
            
            local area = trainingFolder:FindFirstChild(targetOriginalName)
            if not area then
                Rayfield:Notify({Title = "Not Loaded", Content = "Area not loaded yet. Wait a few seconds or move closer.", Duration = 5})
                return
            end
            
            local targetCFrame
            if area:IsA("Model") then
                if area.PrimaryPart then
                    targetCFrame = area.PrimaryPart.CFrame
                else
                    local cf, _ = area:GetBoundingBox()
                    targetCFrame = cf
                end
            else
                targetCFrame = area.CFrame
            end
            
            hrp.CFrame = targetCFrame
            
            task.wait(0.2)
            
            if isPlayerClipped() then
                hrp.CFrame = targetCFrame + Vector3.new(0, 110, 0)
            end
            
            Rayfield:Notify({Title = "Teleported", Content = selectedDisplayName[1] or selectedDisplayName, Duration = 3})
            
            local newValues = getTrainingAreaDisplayNames()
            trainingDropdown:Refresh(newValues, true)
        end
    })

    -- Auto-refresh
    task.spawn(function()
        while task.wait(5) do
            local newValues = getTrainingAreaDisplayNames()
            if #newValues > 0 then
                trainingDropdown:Refresh(newValues, true)
            end
        end
    end)
end

game.StarterGui:SetCore("SendNotification", {
    Title = "Teleports Module Loaded",
    Text = "Dynamic training areas teleporter ready!",
    Duration = 5
})