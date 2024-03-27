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
	RestoredCollection:AddCallback(
        ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
        MeltedCandle.ChargeOnFire
    )
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
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    MeltedCandle.OnPlayerUpdate
)

---@param tear EntityTear
function MeltedCandle:TearInit(tear)
    local player = Helpers.GetPlayerFromTear(tear)
    if player then
        if player:HasCollectible(MeltedCandle.ID) then
            local data = Helpers.GetData(tear)
            
            if Helpers.GetData(player).NumCandleTears == 1 and TSIL.Random.GetRandomInt(0, 100) <= 30 then
                data.IsWaxTear = true
                local sprite = tear:GetSprite()
                local animation = sprite:GetAnimation()
                sprite:Load("gfx/wax tear.anm2", true)
                sprite:Play(animation, true)
                tear:AddTearFlags(TearFlags.TEAR_SLOW)
                tear:AddTearFlags(TearFlags.TEAR_BURN)
            end
        end
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_TEAR_INIT,
    MeltedCandle.TearInit
)

---@param tear EntityTear
function MeltedCandle:TearCollide(tear, collider)
    local data = Helpers.GetData(tear)
    if data.IsWaxTear then
        tear:AddTearFlags(TearFlags.TEAR_SLOW)
        tear:AddTearFlags(TearFlags.TEAR_BURN)
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_PRE_TEAR_COLLISION,
    MeltedCandle.TearCollide
)

---@param tear EntityTear
function MeltedCandle:TearUpdate(tear)
    local data = Helpers.GetData(tear)
    if data.IsWaxTear then
        tear:GetSprite().Rotation = (tear.Velocity + Vector(0, tear.FallingSpeed)):GetAngleDegrees()
    end
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_TEAR_UPDATE,
    MeltedCandle.TearUpdate
)