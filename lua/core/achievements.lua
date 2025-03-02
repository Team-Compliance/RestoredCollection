if not REPENTOGON then return end

local tiedAchievements = {
    [251] = "KEEPERS_ROPE",
    [404] = "BETHS_HEART",
    [452] = "DONKEY_JAWBONE",
    [470] = "ANCIENT_REVELATION",
}

local Achievements = {}
local pgd = Isaac.GetPersistentGameData()

local function NotUnlockable(key)
    for _, achievementKey in pairs(tiedAchievements) do
        if achievementKey == key then
            return false
        end
    end
    return true
end

function Achievements:PlayExtraAchievements(achievementID)
    if tiedAchievements[achievementID] then
        if not pgd:Unlocked(RestoredCollection.Enums.Achievements[tiedAchievements[achievementID]]) then
            pgd:TryUnlock(RestoredCollection.Enums.Achievements[tiedAchievements[achievementID]])
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, Achievements.PlayExtraAchievements)

function Achievements:ExtraAchievementsCheck()
    local achs = RestoredCollection.Enums.Achievements
    for id, achievement in pairs(tiedAchievements) do
        if achs[achievement] ~= -1 and pgd:Unlocked(id) and not pgd:Unlocked(achs[achievement]) then
            pgd:TryUnlock(achs[achievement])
        end
    end
    for id, achievement in pairs(achs) do
        if not pgd:Unlocked(achievement) and NotUnlockable(id) then
            pgd:TryUnlock(achievement)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Achievements.ExtraAchievementsCheck)