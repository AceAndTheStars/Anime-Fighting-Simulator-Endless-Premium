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
                local prettyName = nameMap[area.Name] or ("[Unknown] (" .. area.Name .. ")")
                local displayName = prettyName .. " (" .. area.Name .. ")"
                table.insert(areas, {num = num, display = displayName, original = area.Name})
            end
        end
    end
    
    table.sort(areas, function(a, b) return a.num < b.num end)
    
    local displayNames = {}
    for _, entry in ipairs(areas) do
        table.insert(displayNames, entry.display)
    end
    
    return areas, displayNames
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

-- Public function to create the dropdown
_G.CreateTeleportsDropdown = function(tab)
    if not tab then return end

    tab:CreateSection("Training Areas")

    tab:CreateParagraph({ 
        Title = "Teleports", 
        Content = "Select a training area below to teleport there." 
    })
    tab:CreateParagraph({ 
        Title = "Note", 
        Content = "If you can't find your area in the list, explore a bit of the map to load it in!" 
    })

    local allAreas, initialDisplayNames = getTrainingAreaDisplayNames()

    local trainingDropdown = tab:CreateDropdown({
        Name = "Training Areas",
        Options = initialDisplayNames,
        CurrentOption = {"Select an area"},
        MultipleOptions = false,
        Flag = "TrainingAreaTeleport",
        Callback = function(selected)
            local selectedDisplayName = type(selected) == "table" and selected[1] or selected
            if not selectedDisplayName then return end

            local targetOriginalName
            for _, entry in ipairs(allAreas) do
                if entry.display == selectedDisplayName then
                    targetOriginalName = entry.original
                    break
                end
            end

            if not targetOriginalName then
                return
            end

            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            if not character or not character:FindFirstChild("HumanoidRootPart") then 
                return 
            end
            local hrp = character.HumanoidRootPart
            
            local area = trainingFolder:FindFirstChild(targetOriginalName)
            if not area then
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
            
            -- Refresh dropdown after teleport
            task.spawn(function()
                task.wait(1)
                local newAreas, newDisplayNames = getTrainingAreaDisplayNames()
                allAreas = newAreas
                trainingDropdown:Refresh(newDisplayNames, true)
            end)
        end
    })

    task.spawn(function()
        while task.wait(5) do
            pcall(function()
                local newAreas, newDisplayNames = getTrainingAreaDisplayNames()
                if #newDisplayNames > 0 then
                    allAreas = newAreas
                    trainingDropdown:Refresh(newDisplayNames, true)
                end
            end)
        end
    end)

    -- === Quest NPCs Teleport Dropdown (Direct Teleport) ===

    tab:CreateSection("Quest NPCs")

    tab:CreateParagraph({ 
        Title = "Quest NPCs Teleports", 
        Content = "Select a quest NPC below to teleport directly to it." 
    })
    tab:CreateParagraph({ 
        Title = "Note", 
        Content = "If an NPC is not in the list, it may not be loaded yet. Move around the map to load more areas!" 
    })

    local questFolder = game:GetService("Workspace").Scriptable.NPC.Quest

    local function getQuestNPCs()
        local npcs = {}
        for _, npc in ipairs(questFolder:GetChildren()) do
            if npc:IsA("Model") or npc:IsA("BasePart") then
                local display = npc.Name
                table.insert(npcs, {display = display, object = npc})
            end
        end
        table.sort(npcs, function(a, b) return a.display < b.display end)
        
        local displayNames = {}
        for _, entry in ipairs(npcs) do
            table.insert(displayNames, entry.display)
        end
        
        return npcs, displayNames
    end

    local allNPCs, initialNPCNames = getQuestNPCs()

    local questDropdown = tab:CreateDropdown({
        Name = "Quest NPCs",
        Options = initialNPCNames,
        CurrentOption = {"Select an NPC"},
        MultipleOptions = false,
        Flag = "QuestNPCTeleport",
        Callback = function(selected)
            local selectedName = type(selected) == "table" and selected[1] or selected
            if not selectedName then return end

            local targetNPC = nil
            for _, entry in ipairs(allNPCs) do
                if entry.display == selectedName then
                    targetNPC = entry.object
                    break
                end
            end

            if not targetNPC then
                return
            end

            local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
            if not character or not character:FindFirstChild("HumanoidRootPart") then 
                return 
            end
            local hrp = character.HumanoidRootPart

            local npcInFolder = questFolder:FindFirstChild(selectedName)
            if not npcInFolder then
                return
            end

            local targetCFrame
            if targetNPC:IsA("Model") then
                if targetNPC:FindFirstChild("HumanoidRootPart") then
                    targetCFrame = targetNPC.HumanoidRootPart.CFrame
                elseif targetNPC.PrimaryPart then
                    targetCFrame = targetNPC.PrimaryPart.CFrame
                else
                    local cf, _ = targetNPC:GetBoundingBox()
                    targetCFrame = cf
                end
            else
                targetCFrame = targetNPC.CFrame
            end

            hrp.CFrame = targetCFrame

            -- Refresh dropdown after teleport
            task.spawn(function()
                task.wait(1)
                local newNPCs, newNames = getQuestNPCs()
                allNPCs = newNPCs
                questDropdown:Refresh(newNames, true)
            end)
        end
    })

    -- Auto-refresh every 10 seconds
    task.spawn(function()
        while task.wait(10) do
            pcall(function()
                local newNPCs, newNames = getQuestNPCs()
                if #newNames > 0 then
                    allNPCs = newNPCs
                    questDropdown:Refresh(newNames, true)
                end
            end)
        end
    end)
end

-- Loading notification removed (silent now)