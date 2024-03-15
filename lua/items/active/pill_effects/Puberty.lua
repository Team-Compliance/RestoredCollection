local Helpers = require("lua.helpers.Helpers")


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_PUBERTY, "Puberty",
function ()
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        if not enemy:IsBoss() and not enemy:IsChampion() then
            local hpMul = enemy.HitPoints / enemy.MaxHitPoints
            enemy:MakeChampion(enemy.InitSeed)
            enemy.HitPoints = enemy.MaxHitPoints * hpMul
        end
    end
end)