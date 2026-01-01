-- Anime Fighting Simulator Endless - Fruits Finder Premium (Standalone)
local player = game.Players.LocalPlayer

-- Default colors (can be overridden by main script)
_G.FruitHighlightFillColor = _G.FruitHighlightFillColor or Color3.fromRGB(255, 255, 0)
_G.FruitHighlightOutlineColor = _G.FruitHighlightOutlineColor or Color3.fromRGB(255, 0, 0)

local fruitsRunning = false
local highlightTable = {}

-- Main toggle function
_G.ToggleAutoFindFruits = function(Value)
   fruitsRunning = Value

   if Value then
      game.StarterGui:SetCore("SendNotification", {
         Title = "Auto Find Fruits",
         Text = "Advanced fruit finder + teleport GUI enabled!",
         Duration = 6
      })

      -- === Advanced Fruit Counter GUI with Dropdown Teleport ===
      local ScreenGui = Instance.new("ScreenGui")
      local FruitCounterFrame = Instance.new("Frame")
      local FruitCounterLabel = Instance.new("TextLabel")
      local TeleportButton = Instance.new("TextButton")
      local DropdownFrame = Instance.new("Frame")
      local DropdownList = Instance.new("ScrollingFrame")
      local UIListLayout = Instance.new("UIListLayout")

      ScreenGui.Name = "FruitCounterGUI"
      ScreenGui.Parent = player:WaitForChild("PlayerGui")
      ScreenGui.ResetOnSpawn = false

      FruitCounterFrame.Parent = ScreenGui
      FruitCounterFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
      FruitCounterFrame.BackgroundTransparency = 0.3
      FruitCounterFrame.BorderSizePixel = 0
      FruitCounterFrame.Position = UDim2.new(0, 10, 0, 10)
      FruitCounterFrame.Size = UDim2.new(0, 260, 0, 180)
      FruitCounterFrame.Active = true
      FruitCounterFrame.Draggable = true

      local corner = Instance.new("UICorner")
      corner.CornerRadius = UDim.new(0, 8)
      corner.Parent = FruitCounterFrame

      FruitCounterLabel.Parent = FruitCounterFrame
      FruitCounterLabel.BackgroundTransparency = 1
      FruitCounterLabel.Position = UDim2.new(0, 5, 0, 5)
      FruitCounterLabel.Size = UDim2.new(1, -10, 0, 50)
      FruitCounterLabel.Font = Enum.Font.GothamBold
      FruitCounterLabel.Text = "Current Fruits Detected: 0"
      FruitCounterLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
      FruitCounterLabel.TextSize = 18
      FruitCounterLabel.TextXAlignment = Enum.TextXAlignment.Left
      FruitCounterLabel.TextYAlignment = Enum.TextYAlignment.Top
      FruitCounterLabel.TextWrapped = true

      TeleportButton.Parent = FruitCounterFrame
      TeleportButton.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
      TeleportButton.BorderSizePixel = 0
      TeleportButton.Position = UDim2.new(0, 10, 0, 60)
      TeleportButton.Size = UDim2.new(1, -20, 0, 35)
      TeleportButton.Font = Enum.Font.GothamBold
      TeleportButton.Text = "▼ Teleport to Fruit"
      TeleportButton.TextColor3 = Color3.fromRGB(255, 255, 255)
      TeleportButton.TextSize = 16

      local buttonCorner = Instance.new("UICorner")
      buttonCorner.CornerRadius = UDim.new(0, 6)
      buttonCorner.Parent = TeleportButton

      DropdownFrame.Parent = FruitCounterFrame
      DropdownFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
      DropdownFrame.BackgroundTransparency = 0.2
      DropdownFrame.BorderSizePixel = 0
      DropdownFrame.Position = UDim2.new(0, 10, 0, 100)
      DropdownFrame.Size = UDim2.new(1, -20, 0, 70)
      DropdownFrame.Visible = false

      local dropdownCorner = Instance.new("UICorner")
      dropdownCorner.CornerRadius = UDim.new(0, 6)
      dropdownCorner.Parent = DropdownFrame

      DropdownList.Parent = DropdownFrame
      DropdownList.BackgroundTransparency = 1
      DropdownList.Position = UDim2.new(0, 5, 0, 5)
      DropdownList.Size = UDim2.new(1, -10, 1, -10)
      DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
      DropdownList.ScrollBarThickness = 6

      UIListLayout.Parent = DropdownList
      UIListLayout.Padding = UDim.new(0, 2)

      local dropdownOpen = false

      local function teleportToFruit(fruitName)
         local character = player.Character or player.CharacterAdded:Wait()
         if not character or not character:FindFirstChild("HumanoidRootPart") then return end
         
         local hrp = character.HumanoidRootPart
         local fruitsFolder = workspace:FindFirstChild("Scriptable") and workspace.Scriptable:FindFirstChild("Fruits")
         if not fruitsFolder then return end
         
         local targetFruit = fruitsFolder:FindFirstChild(fruitName)
         if not targetFruit then return end
         
         local targetCFrame = targetFruit:IsA("Model") and (targetFruit.PrimaryPart and targetFruit.PrimaryPart.CFrame or targetFruit:GetBoundingBox()) or targetFruit.CFrame
         hrp.CFrame = targetCFrame + Vector3.new(0, 8, 0)
      end

      local function updateFruitCounter()
         local fruitsFolder = workspace:FindFirstChild("Scriptable") and workspace.Scriptable:FindFirstChild("Fruits")
         if not fruitsFolder then
            FruitCounterLabel.Text = "Current Fruits Detected: Error"
            TeleportButton.Text = "▼ No Fruits Available"
            TeleportButton.Active = false
            return
         end
         
         local children = fruitsFolder:GetChildren()
         local fruitCount = #children
         local fruitNames = {}
         for _, child in ipairs(children) do
            if child:IsA("Model") or child:IsA("BasePart") then
               table.insert(fruitNames, child.Name)
            end
         end
         table.sort(fruitNames)
         
         local listText = #fruitNames > 0 and table.concat(fruitNames, "\n") or "None"
         FruitCounterLabel.Text = "Current Fruits Detected: " .. fruitCount .. "\n\n" .. listText
         
         for _, gui in ipairs(DropdownList:GetChildren()) do
            if gui:IsA("TextButton") then gui:Destroy() end
         end
         
         if #fruitNames == 0 then
            TeleportButton.Text = "▼ No Fruits Available"
            TeleportButton.Active = false
         else
            TeleportButton.Text = "▼ Teleport to Fruit (" .. #fruitNames .. ")"
            TeleportButton.Active = true
            
            for _, name in ipairs(fruitNames) do
               local btn = Instance.new("TextButton")
               btn.Parent = DropdownList
               btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
               btn.BorderSizePixel = 0
               btn.Size = UDim2.new(1, 0, 0, 30)
               btn.Font = Enum.Font.Gotham
               btn.Text = name
               btn.TextColor3 = Color3.fromRGB(220, 220, 220)
               btn.TextSize = 15
               
               local btnCorner = Instance.new("UICorner")
               btnCorner.CornerRadius = UDim.new(0, 4)
               btnCorner.Parent = btn
               
               btn.MouseButton1Click:Connect(function()
                  teleportToFruit(name)
                  dropdownOpen = false
                  DropdownFrame.Visible = false
                  TeleportButton.Text = "▼ Teleport to Fruit (" .. #fruitNames .. ")"
               end)
            end
            
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y + 10)
         end
      end

      TeleportButton.MouseButton1Click:Connect(function()
         if TeleportButton.Active then
            dropdownOpen = not dropdownOpen
            DropdownFrame.Visible = dropdownOpen
            TeleportButton.Text = dropdownOpen and "▲ Teleport to Fruit" or "▼ Teleport to Fruit (" .. #DropdownList:GetChildren() - 1 .. ")"
         end
      end)

      -- Main loop
      task.spawn(function()
         local fruitFolder = game:GetService("Workspace").Scriptable:WaitForChild("Fruits")

         while fruitsRunning do
            local currentFruits = fruitFolder:GetChildren()

            for _, fruit in ipairs(currentFruits) do
               if not highlightTable[fruit] then
                  local hl = Instance.new("Highlight")
                  hl.FillColor = _G.FruitHighlightFillColor
                  hl.OutlineColor = _G.FruitHighlightOutlineColor
                  hl.FillTransparency = 0.5
                  hl.OutlineTransparency = 0
                  hl.Adornee = fruit
                  hl.Parent = fruit
                  highlightTable[fruit] = hl
               end
            end

            updateFruitCounter()

            task.wait(1)
         end
      end)
   else
      -- Cleanup
      for _, hl in pairs(highlightTable) do
         if hl and hl.Parent then hl:Destroy() end
      end
      highlightTable = {}

      local gui = player.PlayerGui:FindFirstChild("FruitCounterGUI")
      if gui then gui:Destroy() end
   end
end

game.StarterGui:SetCore("SendNotification", {
   Title = "Fruits Module Loaded",
   Text = "Premium fruit finder ready!",
   Duration = 5
})