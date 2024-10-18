local TammysTail = {}
local Helpers = RestoredCollection.Helpers
TammysTail.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC
TammysTail.FIRE_DELAY = .5
TammysTail.DOUBLE_HEART_CHANCE = 25
TammysTail.ROOM_CLEAR_HEART_CHANCE = 80

local rewardSpawnFrame --a check for the frame is done to handle stuff like contract from below

local PickupBlacklist = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_THROWABLEBOMB] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true,
    [PickupVariant.PICKUP_BROKEN_SHOVEL] = true,
}


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


function TammysTail:RoomClear()
    rewardSpawnFrame = Game():GetFrameCount()
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD,
    TammysTail.RoomClear
)

---@function
function TammysTail:SpawnClearReward(type, variant, subtype, pos, vel, spawner, seed)
    if rewardSpawnFrame == Game():GetFrameCount() and type == EntityType.ENTITY_PICKUP and not PickupBlacklist[variant] then

        for _, player in ipairs(Helpers.GetPlayers(true)) do
            local data = Helpers.GetData(player)
            if data.TammysTailHeartIncrease == true then
                local chance = TammysTail.ROOM_CLEAR_HEART_CHANCE * player:GetCollectibleNum(TammysTail.ID)

                if TSIL.Random.GetRandomInt(0, 100, seed) <= chance then
                    data.TammysTailHeartIncrease = nil

                    local doublechance = TammysTail.DOUBLE_HEART_CHANCE * player:GetCollectibleNum(TammysTail.ID)
                    if TSIL.Random.GetRandomInt(0, 100, seed) <= doublechance then
                        return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, seed}
                    else

                        return {EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, 0, seed}
                    end
                end
            end
        end

        if variant == PickupVariant.PICKUP_HEART then

            for _, player in pairs(Helpers.GetPlayersByCollectible(TammysTail.ID))  do
                local chance = TammysTail.DOUBLE_HEART_CHANCE * player:GetCollectibleNum(TammysTail.ID)

                if TSIL.Random.GetRandomInt(0, 100, seed) <= chance then
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
        rewardSpawnFrame = 0
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_PRE_ROOM_ENTITY_SPAWN,
    TammysTail.OnNewRoom
)