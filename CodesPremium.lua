-- CodesPremium.lua - AFSE Premium Hub
-- Minimal output, redeems all codes silently

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteFunction = Remotes:WaitForChild("RemoteFunction")

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
    "ChristmasTime",
    "HappyNewYear",
    "50kLikes",
    "10MVisits",
    "NewBloodlines",
    "NewSpecials",
    "MinorBugs",
    "BadActors",
    "JanuaryIncident",
    "15kLikes",
    "25kLikes",
    "30kLikes",
    "175KLIKES",
    "200KLIKES",
    "SMALLCHIKARACODE",
    "BIGCHIKARACODE",
    "FIGHTINGPASS",
    "KURAMAUPDATE",
    "NewFridayYenCode",
    "NewFridayBoostsCode",
    "ThursdayYenNewCode",
    "ThursdayBoostsNewCode",
    "KuramaUpdateSoon",
    "BUGSPATCH4",
    "BUGSPATCH3",
    "BUGSPATCH2",
    "125KLIKES",
    "75KLIKES",
    "50KFAVORITES"
}

for _, code in ipairs(codes) do
    pcall(function()
        local args = {
            "Code",
            code
        }
        RemoteFunction:InvokeServer(unpack(args))
    end)
    
    task.wait(0.4)
end