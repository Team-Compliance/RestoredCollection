local GameSquid = {}
local Helpers = RestoredCollection.Helpers
GameSquid.ID = RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC
GameSquid.BASE_CHANCE = 0.05
--This chance will be added for each multiplier
GameSquid.EXTRA_CHANCE = 0.03
--This stuff is used for things that deal on tick damage, like lasers or ludo
GameSquid.BASE_ONTICK_CHANCE = 0.02
GameSquid.EXTRA_ONTICK_CHANCE = 0.05
GameSquid.LASER_SLOW_DURATION = 0.0
GameSquid.TEAR_COLOR = Color(0.1, 0.1, 0.1, 1)


---@param tear EntityTear
function GameSquid:OnFireTear(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if not player then return end
    if not player:HasTrinket(GameSquid.ID) then return end

    local rng = player:GetTrinketRNG(GameSquid.ID)

    local extraChance = GameSquid.EXTRA_CHANCE * player:GetTrinketMultiplier(GameSquid.ID)
    local chance = GameSquid.BASE_CHANCE + extraChance + (GameSquid.BASE_CHANCE + extraChance) * player.Luck / 1.56
    if rng:RandomFloat() < chance then
        tear:AddTearFlags(TearFlags.TEAR_SLOW)
        tear:AddTearFlags(TearFlags.TEAR_GISH)
        Helpers.GetData(tear).IsGameSquidTear = true
        tear.Color = Color(GameSquid.TEAR_COLOR.R, GameSquid.TEAR_COLOR.G, GameSquid.TEAR_COLOR.B)
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_FIRE_TEAR,
    GameSquid.OnFireTear
)

---@param bomb EntityBomb
function GameSquid:OnBombInit(bomb)
    --if not bomb.IsFetus then return end
    GameSquid:OnFireTear(bomb)
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_BOMB_INIT,
    GameSquid.OnBombInit
)

---@param rocket EntityEffect
function GameSquid:OnFetusRocketInit(rocket)
    local player = Helpers.GetPlayerFromTear(rocket)
    if not player then return end
    if not player:HasTrinket(GameSquid.ID) then return end
    local rng = player:GetTrinketRNG(GameSquid.ID)

    local extraChance = GameSquid.EXTRA_CHANCE * player:GetTrinketMultiplier(GameSquid.ID)
    local chance = GameSquid.BASE_CHANCE + extraChance + (GameSquid.BASE_CHANCE + extraChance) * player.Luck / 1.56

    if rng:RandomFloat() < chance then
        Helpers.GetData(rocket).IsGameSquidTear = true        
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    GameSquid.OnFetusRocketInit,
    EffectVariant.ROCKET
)


---@param entity Entity
function GameSquid:OnEntityRemoved(entity)
    local data = Helpers.GetData(entity)

    if data.IsGameSquidTear then
        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.PLAYER_CREEP_BLACK,
            0,
            entity.Position,
            Vector.Zero,
            entity
        )
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_ENTITY_REMOVE,
    GameSquid.OnEntityRemoved
)

---@param entity Entity
---@param tear EntityTear
local function CheckForLudoTear(entity, tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if not player then return end
    if not player:HasTrinket(GameSquid.ID) then return end
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end

    local rng = player:GetTrinketRNG(GameSquid.ID)

    local extraChance = GameSquid.EXTRA_ONTICK_CHANCE * player:GetTrinketMultiplier(GameSquid.ID)
    local chance = GameSquid.BASE_ONTICK_CHANCE + extraChance + (GameSquid.BASE_ONTICK_CHANCE + extraChance) * player.Luck / 1.55

    if rng:RandomFloat() < chance then
        entity:AddSlowing(EntityRef(player), 60, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))

        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.PLAYER_CREEP_BLACK,
            0,
            entity.Position,
            Vector.Zero,
            player
        )
    end
end


---@param entity Entity
---@param player EntityPlayer
local function CheckForLaser(entity, player)
    if not player:HasTrinket(GameSquid.ID) then return end

    local rng = player:GetTrinketRNG(GameSquid.ID)

    local extraChance = GameSquid.EXTRA_ONTICK_CHANCE * player:GetTrinketMultiplier(GameSquid.ID)
    local chance = GameSquid.BASE_ONTICK_CHANCE + extraChance + (GameSquid.BASE_ONTICK_CHANCE + extraChance) * player.Luck / 1.55

    if rng:RandomFloat() < chance then
        entity:AddSlowing(EntityRef(player), 60, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))

        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.PLAYER_CREEP_BLACK,
            0,
            entity.Position,
            Vector.Zero,
            player
        )
    end
end

---@param entity Entity
---@param bomb EntityBomb | EntityEffect
local function CheckForExplosion(entity, bomb)
    local player = Helpers.GetPlayerFromTear(bomb)
    if not player then return end
    if not player:HasTrinket(GameSquid.ID) then return end
    
    local data = Helpers.GetData(bomb)
    if data.IsGameSquidTear then
        entity:AddSlowing(EntityRef(player), 30, 1, Color(0.15, 0.15, 0.15, 1, 0, 0, 0))

        Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.PLAYER_CREEP_BLACK,
            0,
            entity.Position,
            Vector.Zero,
            player
        )
    end
end


---@param entity Entity
---@param flags DamageFlag
---@param source EntityRef
function GameSquid:OnEntityDamage(entity, _, flags, source)
    if not Helpers.IsTargetableEnemy(entity) then return end
    if not source.Entity then return end
    if source.Entity:ToTear() then
        CheckForLudoTear(entity, source.Entity:ToTear())
    elseif source.Entity:ToPlayer() and flags & DamageFlag.DAMAGE_LASER ~= 0 then
        CheckForLaser(entity, source.Entity:ToPlayer())
    elseif (source.Entity:ToBomb() or source.Entity:ToEffect()) and flags & DamageFlag.DAMAGE_EXPLOSION ~= 0 then
        CheckForExplosion(entity, source.Entity)
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_ENTITY_TAKE_DMG,
    GameSquid.OnEntityDamage
)