local Helpers = require("lua.helpers.Helpers")


local function EnemyHpUp(_, enemy)
    local hpEnemy
    for _, hpUpDownEnemy in ipairs(TSIL.SaveManager.GetPersistentVariable(RestoredItemsPack, "HPUpDownEnemies")) do
        if hpUpDownEnemy.Type == enemy.Type and
        hpUpDownEnemy.Variant == enemy.Variant and
        hpUpDownEnemy.SubType == enemy.SubType then
            hpEnemy = hpUpDownEnemy
        end
    end

    if not hpEnemy then return end
    if hpEnemy.Count <= 0 then return end

    local mult = hpEnemy.Count
    enemy.MaxHitPoints = enemy.MaxHitPoints + 15 * mult
    enemy.HitPoints = enemy.HitPoints + 15 * mult
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_NPC_INIT, EnemyHpUp)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEALTH_UP, "Health Up",
function (_, _, _, isHorse)
    local HPUpDownEnemies = TSIL.SaveManager.GetPersistentVariable(RestoredItemsPack, "HPUpDownEnemies")
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        enemy.MaxHitPoints = enemy.MaxHitPoints + 15 * mult
        enemy.HitPoints = enemy.HitPoints + 15 * mult

        local hpEnemy
        for _, hpUpDownEnemy in ipairs(HPUpDownEnemies) do
            if hpUpDownEnemy.Type == enemy.Type and
            hpUpDownEnemy.Variant == enemy.Variant and
            hpUpDownEnemy.SubType == enemy.SubType then
                hpEnemy = hpUpDownEnemy
            end
        end

        if hpEnemy then
           hpEnemy.Count = hpEnemy.Count + mult
        else
            hpEnemy = {
                Type = enemy.Type,
                Variant = enemy.Variant,
                SubType = enemy.SubType,
                Count = mult
            }
            table.insert(HPUpDownEnemies, hpEnemy)
        end
    end
end)