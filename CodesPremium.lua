-- AFSE Codes Redeemer - Standalone Script
-- Redeems all codes one by one with safe delay

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remote = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("RemoteFunction")

local codes = {
    "YenCode",
    "FreeChikara",
    "FreeChikara2",
    "FreeChikara3",
    "BugFixes1",
    "10Favs",
    "10Likes",
    "LASTFIX",
    "Update1Point1",
    "SorryForBugsLol",
    "1kVisits",
    "50Likes",
    "1000Members",
    "MobsUpdate",
    "1WeekAnniversary",
    "400CCU",
    "10kVisits",
    "100Favs",
    "100CCU",
    "Gullible67",
    "ChristmasDelay",
    "Krampus",
    "1MVisits",
    "10kLikes",
    "ChristmasTime"
}

print("Starting to redeem " .. #codes .. " codes...")

for i, code in ipairs(codes) do
    print("[" .. i .. "/" .. #codes .. "] Attempting code: " .. code)
    
    local args = {
        "Code",
        code
    }
    
    local success, result = pcall(function()
        return remote:InvokeServer(unpack(args))
    end)
    
    if success and result ~= false then
        print("✅ Success: " .. code)
    else
        print("❌ Failed/Already Used: " .. code)
    end
    
    wait(0.3) -- Safe delay to avoid rate limiting
end

print("All codes processed!")