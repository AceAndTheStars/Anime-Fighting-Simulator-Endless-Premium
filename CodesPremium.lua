-- Codes Tab
local CodesTab = Window:CreateTab("Codes", "gift")
CodesTab:CreateSection("Redeem Codes")

local isRedeeming = false

local function redeemAllCodes()
    if isRedeeming then return end
    
    isRedeeming = true
    print("Starting code redemption (" .. #codes .. " codes)")
    
    local successCount = 0
    
    for i, code in ipairs(codes) do
        print("[" .. i .. "/" .. #codes .. "] Trying: " .. code)
        
        local success, result = pcall(function()
            return remote:InvokeServer("Code", code)
        end)
        
        if success and result ~= false then
            print("   → Success!")
            successCount = successCount + 1
        else
            print("   → Failed / Already used")
        end
        
        task.wait(0.4)
    end
    
    print("Finished! " .. successCount .. "/" .. #codes .. " succeeded.")
    isRedeeming = false
end

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

CodesTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = redeemAllCodes
})