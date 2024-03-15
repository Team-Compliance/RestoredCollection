local LuckySevenLudovico = {}
local Helpers = require("lua.helpers.Helpers")


---@param entity Entity
---@param tear EntityTear
local function CheckForLudoTear(entity, tear)
    ---@diagnostic disable-next-line: param-type-mismatch
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    if (tear.SpawnerType ~= EntityType.ENTITY_PLAYER and tear.SpawnerType ~= EntityType.ENTITY_FAMILIAR) and not tear.Parent then return end
    local player
    
    if tear.Parent:ToPlayer() then
        player = tear.Parent:ToPlayer()
    elseif tear.Parent:ToFamiliar() then
        local familiar = tear.Parent:ToFamiliar()
        if familiar.Variant == FamiliarVariant.INCUBUS or familiar.Variant == FamiliarVariant.TWISTED_BABY then
            player = familiar.Player
        else
            return
        end
    else
        return
    end

    if not player:HasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local rng = tear:GetDropRNG()

    local chance = Helpers.GetLuckySevenTearChance(player) * 5

    if rng:RandomInt(1000) < chance then
        Helpers.TurnEnemyIntoGoldenMachine(entity, player, rng)
    end
end


---@param entity Entity
---@param player EntityPlayer
local function CheckForLudoLaser(entity, player)
    if not player:HasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local hitLaser

    for _, laser in ipairs(Isaac.FindByType(EntityType.ENTITY_LASER, -1, 1)) do
        laser = laser:ToLaser()

        if Helpers.DoesLaserHitEntity(laser, entity) then
            if laser.SpawnerEntity and laser.SpawnerType == EntityType.ENTITY_PLAYER then
                local laserPlayerIndex = Helpers.GetPlayerIndex(laser.SpawnerEntity:ToPlayer())

                if laserPlayerIndex == Helpers.GetPlayerIndex(player) then
                    hitLaser = laser
                end
            end
        end
    end

    if not hitLaser then return end

    local rng = hitLaser:GetDropRNG()

    local chance = Helpers.GetLuckySevenTearChance(player) * 5

    if rng:RandomInt(1000) < chance then
        Helpers.TurnEnemyIntoGoldenMachine(entity, player, rng)
    end
end


---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
function LuckySevenLudovico:OnEntityDamage(entity, _, flags, source)
    if not Helpers.IsTargetableEnemy(entity) then return end

    if source.Type == EntityType.ENTITY_TEAR then
        local tear = source.Entity:ToTear()
        CheckForLudoTear(entity, tear)
    elseif source.Type == EntityType.ENTITY_PLAYER and flags & DamageFlag.DAMAGE_LASER ~= 0 then
        local player = source.Entity:ToPlayer()
        CheckForLudoLaser(entity, player)
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, LuckySevenLudovico.OnEntityDamage)