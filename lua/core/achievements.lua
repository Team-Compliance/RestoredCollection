if not REPENTOGON then return end

local achievements = {
    [251] = Isaac.GetAchievementIdByName("Keeper's Rope"),
    [404] = Isaac.GetAchievementIdByName("Beth's Heart"),
    [452] = Isaac.GetAchievementIdByName("Donkey Jawbone"),
    [470] = Isaac.GetAchievementIdByName("Ancient Revelation"),
}

local Achievements = {}
local pgd = Isaac.GetPersistentGameData()

function Achievements:PlayExtraAchievements(achievementID)
    if achievements[achievementID] then
        if not pgd:Unlocked(achievements[achievementID]) then
            pgd:TryUnlock(achievements[achievementID])
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ACHIEVEMENT_UNLOCK, Achievements.PlayExtraAchievements)

function Achievements:ExtraAchievementsCheck(slot, selected, rawslot)
    for id, achievement in pairs(achievements) do
        if achievement ~= -1 and pgd:Unlocked(id) and not pgd:Unlocked(achievement) then
            pgd:TryUnlock(achievement)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Achievements.ExtraAchievementsCheck)