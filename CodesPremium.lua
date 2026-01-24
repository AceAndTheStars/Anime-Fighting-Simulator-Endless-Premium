local isRedeeming = false

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

local function redeemAllCodes()
    if isRedeeming then 
        print("[Codes] Already running — wait a moment")
        return 
    end

    isRedeeming = true

    print("[Codes] Starting redemption (" .. #codes .. " codes) — this will take some time")

    local successCount = 0

    local remotes = game:GetService("ReplicatedStorage").Remotes
    local redeemRemote = remotes:FindFirstChild("RedeemCode") 
                      or remotes:FindFirstChild("Code") 
                      or remotes:FindFirstChild("Redeem")
                      or remotes:FindFirstChild("RemoteFunction")

    if not redeemRemote then
        print("[Codes] ERROR: Could not find the redeem remote in ReplicatedStorage.Remotes")
        isRedeeming = false
        return
    end

    for i, code in ipairs(codes) do
        print(string.format("[%02d/%02d] Trying: %s", i, #codes, code))

        local success, result = pcall(function()
            return redeemRemote:InvokeServer(code)
            -- If nothing redeems → try changing the line above to:
            -- return redeemRemote:InvokeServer("Code", code)
        end)

        local redeemed = false
        if success then
            if result == true 
               or (type(result) == "number" and result > 0) 
               or (type(result) == "string" and result:lower():find("success")) then
                redeemed = true
            end
        end

        if redeemed then
            print("     → SUCCESS!")
            successCount = successCount + 1
        else
            print("     → Failed / Already used / Invalid")
        end

        task.wait(0.6)
    end

    print("[Codes] Finished! " .. successCount .. "/" .. #codes .. " codes succeeded")

    isRedeeming = false
end

CodesTab:CreateButton({
    Name = "Redeem All Codes",
    Callback = redeemAllCodes
})

CodesTab:CreateLabel("Trying all listed codes — most older ones are expired but will be attempted anyway")