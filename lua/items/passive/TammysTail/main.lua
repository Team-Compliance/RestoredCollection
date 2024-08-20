local TammysTail = {}
local Helpers = RestoredCollection.Helpers
TammysTail.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC
TammysTail.FIRE_DELAY = .5
TammysTail.DOUBLE_HEART_CHANCE = 20
TammysTail.ROOM_CLEAR_HEART_CHANCE = 50

---@param player EntityPlayer
function TammysTail:OnFireDelayCache(player)
    local num = player:GetCollectibleNum(TammysTail.ID)

    player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, TammysTail.FIRE_DELAY * num)
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    TammysTail.OnFireDelayCache,
    CacheFlag.CACHE_FIREDELAY
)


---@function
function TammysTail:SpawnClearReward(type, variant, subtype, pos, vel, spawner, seed)
    if type == EntityType.ENTITY_PICKUP then

        for _, player in ipairs(Helpers.GetPlayers(true)) do
            local data = Helpers.GetData(player)
            if data.TammysTailHeartIncrease == true then
                local chance = TammysTail.ROOM_CLEAR_HEART_CHANCE * player:GetCollectibleNum(TammysTail.ID)

                if TSIL.Random.GetRandomInt(0, 100, seed) <= chance then
                    data.TammysTailHeartIncrease = nil
                    return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, seed}
                end
            end
        end

        if variant == PickupVariant.PICKUP_HEART then

            for _, player in pairs(Helpers.GetPlayersByCollectible(TammysTail.ID))  do
                local chance = TammysTail.DOUBLE_HEART_CHANCE * player:GetCollectibleNum(TammysTail.ID)

                if TSIL.Random.GetRandomInt(0, 100, player:GetCollectibleRNG(TammysTail.ID):GetSeed()) <= chance then
                    return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, seed}
                end
            end
        end
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_PRE_ENTITY_SPAWN,
    TammysTail.SpawnClearReward
)

---@param player EntityPlayer
function TammysTail:OnDamage(player, _, _, _, _)
    if player:ToPlayer():HasCollectible(TammysTail.ID) then

        local data = Helpers.GetData(player)

        data.TammysTailHeartIncrease = true
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    TammysTail.OnDamage,
    EntityType.ENTITY_PLAYER
)

---@function
function TammysTail:OnNewRoom()
    for _, player in ipairs(Helpers.GetPlayers(true)) do
        local data = Helpers.GetData(player)
        if data.TammysTailHeartIncrease == true then
            data.TammysTailHeartIncrease = nil
        end
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN,
    TammysTail.OnNewRoom
)