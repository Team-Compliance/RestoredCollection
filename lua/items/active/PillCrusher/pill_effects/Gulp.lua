PillCrusher:AddPillCrusherEffect(PillEffect.PILLEFFECT_GULP, "Gulp!",
function (player, rng, _, isHorse)
        for _, trinket in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
        local goldFlag = 0
        if (isHorse and rng:RandomInt(2) == 1) then
            goldFlag = TrinketType.TRINKET_GOLDEN_FLAG
        end

        ---@diagnostic disable-next-line: param-type-mismatch
        player:AddSmeltedTrinket(trinket.SubType | goldFlag)

        Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, trinket.Position,Vector.Zero,nil)
        trinket:Remove()
    end
end)