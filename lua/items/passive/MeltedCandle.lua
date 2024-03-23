local MeltedCandle = {}
local Helpers = require("lua.helpers.Helpers")
MeltedCandle.ID = RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 1.05
MeltedCandle.MIN_TIMER_PROC = 120
MeltedCandle.MAX_TIMER_PROC = 360

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
    if TSIL.Random.GetRandomInt(0, 100) <= 25 then
        local prevCandleTears = data.NumCandleTears
        data.NumCandleTears = math.min(4, data.NumCandleTears + 1)
        if TSIL.Random.GetRandomInt(0, 100) <= 15 then
            data.NumCandleTears = 0
        end
        if data.NumCandleTears ~= prevCandleTears then
            SpawnPoof(player)
        end
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
        data.CandleTearsTimer = data.NumCandleTears > 0 and MeltedCandle.MAX_TIMER_PROC or 0
    end
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
            mul = mul + MeltedCandle.FIRE_DELAY / i
        end
    end
    player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, mul)
    player:ReplaceCostumeSprite(Isaac.GetItemConfig():GetCollectible(MeltedCandle.ID), "gfx/characters/costumes/costume_meltedcandle"..data.NumCandleTears..".png", 0)
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, MeltedCandle.Cache, CacheFlag.CACHE_FIREDELAY)

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
	RestoredItemsCollection:AddCallback(
        ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
        MeltedCandle.ChargeOnFire
    )
else
    function MeltedCandle:ChargeOnFire(player)
		if not player:HasCollectible(MeltedCandle.ID) then return end
        CalculateCandleTears(player)
	end
	RestoredItemsCollection:AddCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, MeltedCandle.ChargeOnFire)
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
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    MeltedCandle.OnPlayerUpdate
)