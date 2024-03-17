local Helpers = require("lua.helpers.Helpers")


local function EnemyHpDown(_, enemy)
    local hpEnemy
    for _, hpUpDownEnemy in ipairs(TSIL.SaveManager.GetPersistentVariable(RestoredItemsCollection, "HPUpDownEnemies")) do
        if hpUpDownEnemy.Type == enemy.Type and
        hpUpDownEnemy.Variant == enemy.Variant and
        hpUpDownEnemy.SubType == enemy.SubType then
            hpEnemy = hpUpDownEnemy
        end
    end

    if not hpEnemy then return end
    if hpEnemy.Count >= 0 then return end

    local mult = hpEnemy.Count
    for _ = 1, mult, 1 do
        enemy.MaxHitPoints = enemy.MaxHitPoints - math.min(15 * mult, enemy.MaxHitPoints / 2)
	    enemy.HitPoints = enemy.HitPoints - math.min(15 * mult, enemy.HitPoints / 2)
    end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_NPC_INIT, EnemyHpDown)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_HEALTH_DOWN, "Health Down",
function (_, _, _, isHorse)
    local HPUpDownEnemies = TSIL.SaveManager.GetPersistentVariable(RestoredItemsCollection, "HPUpDownEnemies")
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 2 or 1
        for _ = 1, mult, 1 do
            enemy.MaxHitPoints = enemy.MaxHitPoints - math.min(15 * mult, enemy.MaxHitPoints / 2)
            enemy.HitPoints = enemy.HitPoints - math.min(15 * mult, enemy.HitPoints / 2)
        end

        local hpEnemy
        for _, hpUpDownEnemy in ipairs(HPUpDownEnemies) do
            if hpUpDownEnemy.Type == enemy.Type and
            hpUpDownEnemy.Variant == enemy.Variant and
            hpUpDownEnemy.SubType == enemy.SubType then
                hpEnemy = hpUpDownEnemy
            end
        end

        if hpEnemy then
           hpEnemy.Count = hpEnemy.Count - mult
        else
            hpEnemy = {
                Type = enemy.Type,
                Variant = enemy.Variant,
                SubType = enemy.SubType,
                Count = -mult
            }
            table.insert(HPUpDownEnemies, hpEnemy)
        end
    end
end)