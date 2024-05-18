local MeltedCandle = {}
local Helpers = require("lua.helpers.Helpers")
MeltedCandle.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 0.5

local function InitCandleTears(player)
    local data = Helpers.GetData(player)
    if not data.NumCandleTears then
        data.NumCandleTears = 0
    end
    if not data.CandleTearsTimer then
       data.CandleTearsTimer = 0
    end
end

local function CandleTimer(player, effnum)
    if effnum == 2 then
        return player.MaxFireDelay * 3
    end
    return 150
end

local function SpawnPoof(player)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, player.Position, Vector.Zero, nil):ToEffect()
    poof.SpriteScale = player.SpriteScale / 2
    poof.SpriteOffset = Vector(0, -33 * player.SpriteScale.Y)
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
    if TSIL.Random.GetRandomInt(0, 100) <= 10 or data.NumCandleTears ~= 1 then
        local prevCandleTears = data.NumCandleTears
        data.NumCandleTears = math.min(2, data.NumCandleTears + 1)
        if data.NumCandleTears ~= prevCandleTears then
            SpawnPoof(player)
        end
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
    data.CandleTearsTimer = data.NumCandleTears > 0 and CandleTimer(player, data.NumCandleTears) or 0
end

---@param player EntityPlayer
---@param cache CacheFlag | integer
function MeltedCandle:Cache(player, cache)
    if not player:HasCollectible(MeltedCandle.ID) then return end
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    local mul = 0
    if data.NumCandleTears > 0 then
        for i = 1, data.NumCandleTears do
            mul = mul + MeltedCandle.FIRE_DELAY * i
        end
    end
    player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, mul)
    player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetCollectible(MeltedCandle.ID), "gfx/characters/costumes/costume_meltedcandle"..data.NumCandleTears..".png", 0)
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
    if not player:HasCollectible(MeltedCandle.ID) then return end
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    local timer = data.CandleTearsTimer or 0
    data.CandleTearsTimer = math.max(0, timer - 1)
    if data.NumCandleTears > 0 and data.CandleTearsTimer <= 0 then
        data.NumCandleTears = math.max(0, data.NumCandleTears - 1)
        data.CandleTearsTimer = data.NumCandleTears > 0 and CandleTimer(player, data.NumCandleTears) or 0
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        SpawnPoof(player)
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MeltedCandle.OnPlayerUpdate)

---@param tear EntityTear
function MeltedCandle:TearInit(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if player then
        if player:HasCollectible(MeltedCandle.ID) then
            local data = Helpers.GetData(tear)
            
            if Helpers.GetData(player).NumCandleTears == 1 and TSIL.Random.GetRandomInt(0, 100) <= 30 then
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
            tear:AddTearFlags(TSIL.Random.GetRandomElementsFromTable({TearFlags.TEAR_HP_DROP, TearFlags.TEAR_COIN_DROP_DEATH})[1])
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, MeltedCandle.TearCollide)
--RestoredCollection:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, MeltedCandle.TearCollide)
--RestoredCollection:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, MeltedCandle.TearCollide)

---@param tear EntityTear | EntityLaser
function MeltedCandle:TearUpdate(tear)
    local data = Helpers.GetData(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) or tear:ToKnife() then
        if data.IsWaxTear and TSIL.Random.GetRandomInt(0, 20) == 1 then
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
    effect.SpriteScale = thp.TearScale * 0.7 * Vector.One
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, MeltedCandle.WaxTearEffectInit, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant)

---@param effect EntityEffect
function MeltedCandle:WaxTearEffectRender(effect, offset)
    local tear = effect.SpawnerEntity
    if not tear or not tear:ToTear() then
        effect:Remove()
        return
    end
    tear = tear:ToTear()
    effect.DepthOffset = -1
    local visible = Helpers.GetData(tear).IsWaxTear and tear.FrameCount > 0
    local player = Helpers.GetPlayerFromTear(tear)
    local thp = player:GetTearHitParams(WeaponType.WEAPON_TEARS)
    local ludoRotation = thp.TearFlags & TearFlags.TEAR_LUDOVICO > 0 and Vector(0, tear.FallingSpeed) or Vector.Zero
    effect.SpriteRotation = (tear.Velocity + ludoRotation):GetAngleDegrees()
    effect.SpriteScale = visible and (thp.TearScale * Vector.One) or Vector.Zero
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, MeltedCandle.WaxTearEffectRender, RestoredCollection.Enums.Entities.WAX_TEAR_EFFECT.Variant)