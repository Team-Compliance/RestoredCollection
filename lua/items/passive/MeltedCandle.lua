local MeltedCandle = {}
local Helpers = require("lua.helpers.Helpers")
MeltedCandle.ID = RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE
MeltedCandle.FIRE_DELAY = 1.05
MeltedCandle.MIN_NUM_TEARS_PROC = 10

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
local function CalculateCandleTears(player)
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    local numTears = data.NumTears or 1
    if numTears >= MeltedCandle.MIN_NUM_TEARS_PROC then
        if TSIL.Random.GetRandomInt(0, 100) <= 15 then
            data.NumCandleTears = TSIL.Random.GetRandomInt(1,4)
            player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
            player:EvaluateItems()
            data.NumTears = 1
            data.CandleTearsTimer = 120
        else
            data.NumTears = numTears + 1
        end
    else
        data.NumTears = numTears + 1
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
end

---@param player EntityPlayer
function MeltedCandle:OnPlayerUpdate(player)
    if not player:HasCollectible(MeltedCandle.ID) then return end
    InitCandleTears(player)
    local data = Helpers.GetData(player)
    
    local timer = data.CandleTearsTimer or 0
    local prevFireDelay = data.PreviousFireDelay or 10
    local currentFireDelay = player.FireDelay
    data.PreviousFireDelay = currentFireDelay
    print(timer)
    if prevFireDelay < currentFireDelay and not REPENTOGON then
        CalculateCandleTears(player)
    else
        data.CandleTearsTimer = math.max(0, timer - 1)
    end
    if data.NumCandleTears > 0 and data.CandleTearsTimer <= 0 then
        data.CandleTearsTimer = 0
        data.NumCandleTears = 0
        player:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
        player:EvaluateItems()
    end
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    MeltedCandle.OnPlayerUpdate
)