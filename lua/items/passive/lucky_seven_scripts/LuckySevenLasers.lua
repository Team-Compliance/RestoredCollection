local LuckySevenLasers = {}
local Helpers = require("lua.helpers.Helpers")


---@param laser EntityLaser
function LuckySevenLasers:OnLaserInit(laser)
    --Ludovico laser
    if laser.SubType == 1 then return end
    if laser.SpawnerType ~= EntityType.ENTITY_PLAYER and not laser.Parent then return end

    local player = laser.SpawnerEntity:ToPlayer()

    if not player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local laserData = Helpers.GetData(laser)

    local rng = RNG()
    rng:SetSeed(laser.InitSeed, 35)

    local mult = player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 1

    local chance = math.max(0, math.min(15, 5 + player.Luck))

    if rng:RandomInt(100) <= chance * mult then
        laserData.IsLuckySevenLaser = true
    end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_LASER_INIT, LuckySevenLasers.OnLaserInit)


---@param laser EntityLaser
function LuckySevenLasers:OnLaserRender(laser)
    local laserData = Helpers.GetData(laser)
    if not laserData.IsLuckySevenLaser then return end

    local color = Color(1, 1, 1, 1, 252/255, 210/255, 83/255)
    --Shoop da woop and trisagion
    if laser.Variant == 3 then
        color = Color(1, 1, 1)
        --232, 181, 23
        color:SetColorize(232/255, 181/255, 23/255, 0.7)
    end
    laser.Color = color
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_LASER_RENDER, LuckySevenLasers.OnLaserRender)


---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
function LuckySevenLasers:OnEntityDamage(entity, _, flags, source)
    if not Helpers.IsTargetableEnemy(entity) then return end
    if source.Type ~= EntityType.ENTITY_PLAYER then return end
    local player = source.Entity:ToPlayer()
    if not player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) or
    player:HasCollectible(CollectibleType.COLLECTIBLE_LUDOVICO_TECHNIQUE) then return end
    if flags & DamageFlag.DAMAGE_LASER == 0 then return end

    local entityRNG = RNG()
    entityRNG:SetSeed(entity.InitSeed, 35)
    if entityRNG:RandomInt(100) < 50 then return end

    for _, laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER)) do
        laser = laser:ToLaser()
        local laserData = Helpers.GetData(laser)
        if laserData.IsLuckySevenLaser then
            if Helpers.DoesLaserHitEntity(laser, entity) then
                local rng = RNG()
                rng:SetSeed(laser.InitSeed, 35)
                Helpers.TurnEnemyIntoGoldenMachine(entity, player, rng)
                break
            end
        end
    end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LuckySevenLasers.OnEntityDamage)