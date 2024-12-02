local MeltedCandle = {}
local Helpers = RestoredCollection.Helpers
MeltedCandle.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 0.5
MeltedCandle.BIG_FIRE_DELAY = 1.5
MeltedCandle.CostumeID = Isaac.GetCostumeIdByPath("gfx/characters/costume_meltedcandle2.anm2")

local function SpawnWaxTearEffect(tear)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant, 0, tear.Position, Vector.Zero, tear):ToEffect()
    effect.Parent = tear
    effect:FollowParent(tear)
end

---@param player EntityPlayer
---@param cache CacheFlag | integer
function MeltedCandle:Cache(player, cache)
    local num = player:GetCollectibleNum(MeltedCandle.ID)
    local tps = Helpers.ToTearsPerSecond(player.MaxFireDelay)
    if tps <= 5 then
        tps = math.min(5, tps + MeltedCandle.FIRE_DELAY * num)
    end
    player.MaxFireDelay = Helpers.ToMaxFireDelay(tps)
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MeltedCandle.Cache, CacheFlag.CACHE_FIREDELAY)

---@param player EntityPlayer
function MeltedCandle:OnPlayerUpdate(player)
    local data = Helpers.GetData(player)
    if not player:HasCollectible(MeltedCandle.ID) then
        if data.FireEffect then
            data.FireEffect:Remove()
            data.FireEffect = nil
        end
        return
    end
    local isShooting = false
    for i = 4, 7 do
        isShooting = isShooting or Input.IsActionPressed(i, player.ControllerIndex)
    end
    data.shootingScale = data.shootingScale or 0
    if not data.FireEffect then
        data.FireEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.WAX_FIRE_EFFECT.Variant, 0, player.Position, Vector.Zero, nil):ToEffect()
        data.FireEffect:FollowParent(player)
        data.FireEffect.Parent = player
        data.FireEffect.SpriteScale = Vector.Zero
    elseif data.FireEffect:IsDead() then
        data.FireEffect = nil
    end
    if data.FireEffect then
        local fireEffectData = Helpers.GetData(data.FireEffect)
        fireEffectData.shootingScale = fireEffectData.shootingScale or 0
        if isShooting then
            fireEffectData.shootingScale = Helpers.Lerp(fireEffectData.shootingScale, 3, 0.01)
        else
            fireEffectData.shootingScale = Helpers.Lerp(fireEffectData.shootingScale, 0, 0.05)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MeltedCandle.OnPlayerUpdate)

---@param tear EntityTear
function MeltedCandle:TearInit(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if player then
        if player:HasCollectible(MeltedCandle.ID) then
            local data = Helpers.GetData(tear)
            if TSIL.Random.GetRandomInt(0, 100) <= 30 then
                data.IsWaxTear = true
            end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, MeltedCandle.TearInit)
RestoredCollection:AddCallback(ModCallbacks.MC_POST_LASER_INIT, MeltedCandle.TearInit)

---@param tear EntityTear
---@param collider Entity
function MeltedCandle:TearCollide(tear, collider)
    local data = Helpers.GetData(tear)
    if data.IsWaxTear then
        if Helpers.IsEnemy(collider) then
            if not collider:HasEntityFlags(EntityFlag.FLAG_BURN) then
                collider:AddBurn(EntityRef(tear.SpawnerEntity), 60, tear.CollisionDamage / 6)
            end
            if not collider:HasEntityFlags(EntityFlag.FLAG_SLOW) then
                collider:AddSlowing(EntityRef(tear.SpawnerEntity), 60, 1.4, Color(2, 2, 2, 1, 0.196, 0.196, 0.196))
            end
            -- if TSIL.Random.GetRandomInt(0, 100, collider:GetDropRNG()) <= 20 then
            --     local flags = TSIL.Random.GetRandomElementFromWeightedList(collider:GetDropRNG() , {{chance = 0.25, value = TearFlags.TEAR_HP_DROP}, {chance = 0.75, value = TearFlags.TEAR_COIN_DROP_DEATH}})
            --     tear:AddTearFlags(flags)
            -- end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, MeltedCandle.TearCollide)
if REPENTOGON then
    RestoredCollection:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, MeltedCandle.TearCollide)
    RestoredCollection:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, MeltedCandle.TearCollide)
end

---@param tear EntityTear | EntityLaser
function MeltedCandle:TearUpdate(tear)
    local data = Helpers.GetData(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) or tear:ToKnife() then
        if data.IsWaxTear and TSIL.Random.GetRandomInt(0, 50) == 1 then
            data.IsWaxTear = nil
        elseif tear.FrameCount % 20 == 0 and TSIL.Random.GetRandomInt(0, 100) <= 30 and not data.IsWaxTear and player:HasCollectible(MeltedCandle.ID) then
            data.IsWaxTear = true
        end
    end
    if data.IsWaxTear then
        local tearColor = tear.Color
        tearColor:SetColorize(3, 3, 3, 1)
        tear.Color = tearColor
        if not data.WaxTearEffect and tear:ToTear() then
            SpawnWaxTearEffect(tear)
            data.WaxTearEffect = true
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, MeltedCandle.TearUpdate)
RestoredCollection:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, MeltedCandle.TearUpdate)
RestoredCollection:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, MeltedCandle.TearUpdate)

---@param effect EntityEffect
function MeltedCandle:WaxTearEffectInit(effect)
    local tear = effect.SpawnerEntity
    if not tear or not tear:ToTear() then
        effect:Remove()
        return
    end
    tear = tear:ToTear()
    effect.DepthOffset = -1
    local player = Helpers.GetPlayerFromTear(tear)
    local thp = player:GetTearHitParams(WeaponType.WEAPON_TEARS)
    local color = thp.TearColor
    effect.Color = Color(color.R, color.G, color.B, color.A, color.RO + 1, color.GO + 1, color.BO + 1)
    effect.SpriteRotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
    effect.SpriteScale = Vector.Zero
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MeltedCandle.WaxTearEffectInit, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant)

---@param effect EntityEffect
---@param offset Vector
function MeltedCandle:WaxTearEffectRender(effect, offset)
    local tear = effect.SpawnerEntity
    if not tear or not tear:ToTear() then
        effect:Remove()
        return
    end
    tear = tear:ToTear()
    local ludoRotation = tear.TearFlags & TearFlags.TEAR_LUDOVICO ~= TearFlags.TEAR_LUDOVICO and Vector(0, tear.FallingSpeed) or Vector.Zero
    effect.SpriteRotation = (tear.Velocity + ludoRotation):GetAngleDegrees()
    effect.SpriteScale = Helpers.GetData(tear).IsWaxTear and math.max(0.3, tear.Size * 0.07) * Vector.One or Vector.Zero
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, MeltedCandle.WaxTearEffectRender, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant)

---@param effect EntityEffect
function MeltedCandle:WaxFireEffectUpdate(effect)
    if (not effect.Parent or not effect.Parent:ToPlayer() or effect.Parent:IsDead()) then
        effect:Remove()
    end
    local player = effect.Parent:ToPlayer()
    local data = Helpers.GetData(effect)
    effect.DepthOffset = 999
    local scale = data.shootingScale or 0
    effect.SpriteScale = player.SpriteScale * (0.5 * scale)
    local yOffset = -7 * math.max(player.SpriteScale.Y, effect.SpriteScale.Y)
    effect.SpriteOffset = Vector(0, yOffset)
    for _, entity in ipairs(Isaac.FindInRadius(effect.Position, 40 * effect.SpriteScale.X / 0.5, EntityPartition.ENEMY)) do
        if Helpers.IsEnemy(entity) and not entity:HasEntityFlags(EntityFlag.FLAG_BURN) then
            entity:AddBurn(EntityRef(player), 120, player.Damage / 3.5)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MeltedCandle.WaxFireEffectUpdate, RestoredCollection.Enums.Entities.WAX_FIRE_EFFECT.Variant)