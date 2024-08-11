local Helpers = RestoredCollection.Helpers


local function ArmorDamage(_, entity, amount, flags, source, cd)
	if entity:ToPlayer() then return end

	local data = Helpers.GetData(entity)
	if not data or not data.Armor then return end

    local leftover = 0
    if data.Armor >= amount then
        data.Armor = data.Armor - amount
    else
        leftover = amount - data.Armor
        data.Armor = 0
    end

    if data.Armor == 0 then data.Armor = nil end

    if REPENTOGON then
        return {Damage = leftover, DamageFlags = flags, DamageCountdown = cd}
    else
        if leftover > 0 then
            entity:TakeDamage(leftover, flags, source, cd)
        end
        return false
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ArmorDamage)


local function BallsOfSteelArmorIndicator(_, npc)
	local data = Helpers.GetData(npc)
	if not data or not data.Armor then return end

    local color = Color(1, 1, 1)
    color:SetColorize(0, 0, 0.6, 0.35)
    npc:GetSprite().Color = color
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, BallsOfSteelArmorIndicator)


PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_BALLS_OF_STEEL, "Balls Of Steel",
function (_, _, _, isHorse)
    for _,enemy in ipairs(Helpers.GetEnemies(false)) do
        local mult = isHorse and 0.2 or 0.1
        local data = Helpers.GetData(enemy)
        data.Armor = enemy.MaxHitPoints * mult
    end
end)