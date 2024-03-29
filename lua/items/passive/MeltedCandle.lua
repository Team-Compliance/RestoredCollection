local MeltedCandle = {}
local Helpers = require("lua.helpers.Helpers")
MeltedCandle.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 0.5
MeltedCandle.MAX_TIMER_PROC = 150

local function InitCandleTears(player)
    local data = Helpers.GetData(player)
    if not data.NumCandleTears then
        data.NumCandleTears = 0
    end
    if not data.CandleTearsTimer then
       data.CandleTearsTimer = 0
    end
end

local function SpawnWaxEffect(parent)
    local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.WAX.Variant, 0, parent.Position, Vector.Zero, parent):ToEffect()
    effect.Parent = parent
    effect:FollowParent(parent)
    effect.DepthOffset = -10
end

local function SpawnPoof(player)
    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, player.Position, Vector.Zero, nil):ToEffect()
    poof.SpriteScale = player.SpriteScale / 2
    poof.SpriteOffset = Vector(0, -33 * player.SpriteScale.Y)
end

---@param player EntityPlayer
local function CalculateCandleTears(player)
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    if TSIL.Random.GetRandomInt(0, 100) <= 10 or data.NumCandleTears == 0 then
        local prevCandleTears = data.NumCandleTears
        data.NumCandleTears = math.min(2, data.NumCandleTears + 1)
        if TSIL.Random.GetRandomInt(0, 100) <= 5 and data.NumCandleTears > 1 then
            data.NumCandleTears = 0
        end
        if data.NumCandleTears ~= prevCandleTears then
            SpawnPoof(player)
        end
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
    data.CandleTearsTimer = data.NumCandleTears > 0 and MeltedCandle.MAX_TIMER_PROC or 0
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
        data.CandleTearsTimer = data.NumCandleTears > 0 and MeltedCandle.MAX_TIMER_PROC or 0
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
                if tear:ToTear() then
                    SpawnWaxEffect(tear)
                end
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
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_LASER_COLLISION, MeltedCandle.TearCollide)
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_KNIFE_COLLISION, MeltedCandle.TearCollide)

---@param tear EntityTear | EntityLaser
function MeltedCandle:TearUpdate(tear)
    local data = Helpers.GetData(tear)
    if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) or tear:ToKnife() then
        if data.IsWaxTear and TSIL.Random.GetRandomInt(0, 20) == 1 then
            data.IsWaxTear = nil
        elseif tear.FrameCount % 20 == 0 and TSIL.Random.GetRandomInt(0, 100) <= 30 and not data.IsWaxTear then
            data.IsWaxTear = true
            if tear:ToTear() then
                SpawnWaxEffect(tear)
            end
        end
    end
    if data.IsWaxTear then
        local tearColor = tear.Color
        tearColor:SetColorize(3, 3, 3, 1)
        tear.Color = tearColor
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, MeltedCandle.TearUpdate)
RestoredCollection:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, MeltedCandle.TearUpdate)
RestoredCollection:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, MeltedCandle.TearUpdate)

---@param effect EntityEffect
function MeltedCandle:WaxEffectUpdate(effect)
    if not effect.Parent or not effect.Parent:ToTear() or effect.Parent:IsDead() 
    or not Helpers.GetData(effect.Parent).IsWaxTear then
        effect:Remove()
        return
    end
    local tear = effect.Parent:ToTear()
    local player = Helpers.GetPlayerFromTear(tear)
    effect.Position = tear.Position
    local tearHitParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS)
    local ludoMul = tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) and 1.4 or 1

    effect.SpriteScale = Vector(1, 1) * tearHitParams.TearScale * ludoMul
    effect.SpriteRotation = (tear.Velocity + Vector(0, tear.FallingSpeed):Resized(5)):GetAngleDegrees()
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, MeltedCandle.WaxEffectUpdate, RestoredCollection.Enums.Entities.WAX.Variant)