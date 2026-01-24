-- CodesPremium.lua — ONLY the codes list + redemption function, NO tabs, NO buttons, NO labels, NO Rayfield, NO prints about tabs

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
    local successCount = 0

    local remotes = game:GetService("ReplicatedStorage").Remotes
    local redeemRemote = remotes:FindFirstChild("RedeemCode") 
                      or remotes:FindFirstChild("Code") 
                      or remotes:FindFirstChild("Redeem")
                      or remotes:FindFirstChild("RemoteFunction")

    if not redeemRemote then
        return  -- silently fail, or add print if you want debug
    end

    for i, code in ipairs(codes) do
        local success, result = pcall(function()
            return redeemRemote:InvokeServer(code)
            -- if this doesn't work → try: redeemRemote:InvokeServer("Code", code)
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
            successCount = successCount + 1
        end

        task.wait(0.6)
    end

    -- optional: return successCount if you want to use it in main script later
end

_G.RedeemAllAFSECodes = redeemAllCodes