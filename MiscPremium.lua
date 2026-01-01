-- MiscPremium.lua - Standalone module for AFSE Hub
-- Contains: Anti-AFK (clicks bottom-right twice every 10 minutes)

local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")

_G.AntiAFKEnabled = _G.AntiAFKEnabled or false

-- This will be called by the toggle in the main hub
_G.ToggleAntiAFK = function(enabled)
    _G.AntiAFKEnabled = enabled

    if enabled then
        spawn(function()
            while _G.AntiAFKEnabled do
                wait(600) -- Every 10 minutes

                if _G.AntiAFKEnabled then
                    local screenSize = GuiService:GetScreenResolution()
                    local clickPos = Vector2.new(screenSize.X - 50, screenSize.Y - 50)

                    -- First click down/up
                    VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)

                    -- Small delay between clicks
                    wait(0.2)

                    -- Second click down/up
                    VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, true, game, 1)
                    wait(0.1)
                    VirtualInputManager:SendMouseButtonEvent(clickPos.X, clickPos.Y, 0, false, game, 1)
                end
            end
        end)
    end
end

print("MiscPremium.lua loaded - Anti-AFK ready")