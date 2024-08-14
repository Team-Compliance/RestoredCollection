local MeltedCandle = {}
local Helpers = RestoredCollection.Helpers
MeltedCandle.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 0.5
MeltedCandle.BIG_FIRE_DELAY = 1.5
MeltedCandle.CostumeID = Isaac.GetCostumeIdByPath("gfx/characters/costume_meltedcandle2.anm2")

local function InitCandleTears(player)
    local data = Helpers.GetData(player)
    if not data.NumCandleTears then
        data.NumCandleTears = 0
    end
    if not data.CandleTearsTimer then
       data.CandleTearsTimer = 0
    end
end

---@param player EntityPlayer
local function SpawnPoof(player)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, player.Position, Vector.Zero, nil):ToEffect()
    poof.SpriteScale = player.SpriteScale / 2
    local headDir = player:GetHeadDirection()
    local posX = player.SpriteScale.X * 10 * (headDir == Direction.LEFT and -1 or (headDir == Direction.RIGHT and 1 or 0))
    poof.SpriteOffset = Vector(posX, -33 * player.SpriteScale.Y)
end

local function SpawnWaxTearEffect(tear)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant, 0, tear.Position, Vector.Zero, tear):ToEffect()
    effect.Parent = tear
    effect:FollowParent(tear)
end

---@param player EntityPlayer
local function CalculateCandleTears(player)
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    if TSIL.Random.GetRandomInt(0, 100, player:GetCollectibleRNG(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE)) <= 10 
    and data.NumCandleTears ~= 1 and data.CandleTearsTimer <= 0 then
        data.NumCandleTears = 1
        SpawnPoof(player)
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        data.CandleTearsTimer = 210
    end
end

---@param player EntityPlayer
---@param cache CacheFlag | integer
function MeltedCandle:Cache(player, cache)
    if not player:HasCollectible(MeltedCandle.ID) then player:TryRemoveNullCostume(MeltedCandle.CostumeID) return end
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    player:AddNullCostume(MeltedCandle.CostumeID)
    local mul = MeltedCandle.FIRE_DELAY
    if data.NumCandleTears > 0 then
        mul = mul + MeltedCandle.BIG_FIRE_DELAY
    end
    player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, mul)
    local candle = data.NumCandleTears > 0 and 2 or 1
    player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetNullItem(MeltedCandle.CostumeID), "gfx/characters/costumes/costume_candle_overlay"..candle..".png", 0)
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MeltedCandle.Cache, CacheFlag.CACHE_FIREDELAY)

if REPENTOGON then
    function MeltedCandle:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player or amount < 1 then return end
            ---@cast player EntityPlayer
            if not player:HasCollectible(MeltedCandle.ID) then return end
            CalculateCandleTears(player)
		end
	end
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, MeltedCandle.ChargeOnFire)
else
    function MeltedCandle:ChargeOnFire(player)
		if not player:HasCollectible(MeltedCandle.ID) then return end
        CalculateCandleTears(player)
	end
	RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, MeltedCandle.ChargeOnFire)
end

---@param player EntityPlayer
function MeltedCandle:OnPlayerUpdate(player)
    local data = Helpers.GetData(player)
    if not player:HasCollectible(MeltedCandle.ID) then
        data.MeltedCandleShooting = nil
        if data.FireEffect then
            data.FireEffect:Remove()
            data.FireEffect = nil
        end
        return
    end
    InitCandleTears(player)
    local timer = data.CandleTearsTimer or 0
    data.CandleTearsTimer = math.max(0, timer - 1)
    local isShooting = false
    for i = 4, 7 do
        isShooting = isShooting or Input.IsActionPressed(i, player.ControllerIndex)
    end
    if data.NumCandleTears > 0 and (data.CandleTearsTimer <= 60 and isShooting or not isShooting) then
        data.NumCandleTears = 0
        data.CandleTearsTimer = 0
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        SpawnPoof(player)
    end
    if not data.FireEffect then
        data.FireEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.WAX_FIRE_EFFECT.Variant, 0, player.Position, Vector.Zero, nil):ToEffect()
        data.FireEffect:FollowParent(player)
        data.FireEffect.Parent = player
        data.FireEffect:GetSprite():Play("Disappear", true)
        data.FireEffect:GetSprite():SetFrame(7)
    elseif data.FireEffect:IsDead() then
        data.FireEffect = nil
    end
    data.IsShooting = isShooting
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MeltedCandle.OnPlayerUpdate)

---@param tear EntityTear
function MeltedCandle:TearInit(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if player then
        if player:HasCollectible(MeltedCandle.ID) then
            local data = Helpers.GetData(tear)
            if Helpers.GetData(player).NumCandleTears == 0 and TSIL.Random.GetRandomInt(0, 100) <= math.min(70, math.max(30, 30 + player.Luck * 2.5)) then
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
            if TSIL.Random.GetRandomInt(0, 100, collider:GetDropRNG()) <= 20 then
                local flags = TSIL.Random.GetRandomElementFromWeightedList(collider:GetDropRNG() , {{chance = 0.25, value = TearFlags.TEAR_HP_DROP}, {chance = 0.75, value = TearFlags.TEAR_COIN_DROP_DEATH}})
                tear:AddTearFlags(flags)
            end
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
        if data.IsWaxTear and TSIL.Random.GetRandomInt(0, math.min(100, math.max(20, 20 + player.Luck))) == 1 then
            data.IsWaxTear = nil
        elseif tear.FrameCount % 20 == 0 and TSIL.Random.GetRandomInt(0, 100) <= math.min(70, math.max(30, 30 + player.Luck * 1.6)) and not data.IsWaxTear and player:HasCollectible(MeltedCandle.ID) then
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
    local sprite = effect:GetSprite()
    if not effect.Parent or not effect.Parent:ToPlayer() then
        effect:Remove()
        return
    end
    local player = effect.Parent:ToPlayer()
    local pData = Helpers.GetData(player)
    if pData.IsShooting and not player:IsDead() then
        if sprite:IsFinished("Disappear") then
            sprite:Play("Appear", true)
        elseif sprite:IsFinished("Appear") then
            sprite:Play("Idle", true)
        end
    elseif sprite:IsFinished("Appear") or sprite:IsPlaying("Idle") then
        sprite:Play("Disappear", true)
    end
    effect.Color = Color(1, 0, 0, 3)
    effect.DepthOffset = 10
    effect.SpriteOffset = Vector(0, -15) * effect.SpriteScale
    effect.SpriteScale = Helpers.Lerp(effect.SpriteScale, player.SpriteScale * (1 + 0.5 * pData.NumCandleTears) * 0.6, 0.1, 0.7)
    if sprite:IsPlaying("Idle") or sprite:IsPlaying("Appear") and sprite:GetFrame() >= 5  then
        for _, entity in ipairs(Isaac.FindInRadius(effect.Position, 40 * effect.SpriteScale.X / 0.6, EntityPartition.ENEMY)) do
            if Helpers.IsEnemy(entity) and not entity:HasEntityFlags(EntityFlag.FLAG_BURN) then
                entity:AddBurn(EntityRef(player), 120, player.Damage / 3.5)
            end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MeltedCandle.WaxFireEffectUpdate, RestoredCollection.Enums.Entities.WAX_FIRE_EFFECT.Variant)

---@param pickup EntityPickup
function MeltedCandle:DoubleHeartSpawn(pickup)
    if pickup.SubType == HeartSubType.HEART_FULL or pickup.SubType == HeartSubType.HEART_SCARED then
        if TSIL.Random.GetRandomInt(0, 100, pickup.InitSeed) <= 5 then
            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, true, true, true)
        end
    end
end
RestoredCollection:AddCallback(TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST, MeltedCandle.DoubleHeartSpawn, PickupVariant.PICKUP_HEART)