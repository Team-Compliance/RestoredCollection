local MaxsHead = {}
local Helpers = require("lua.helpers.Helpers")
MaxsHead.ID = RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD
MaxsHead.FIRE_DELAY = 1.5
MaxsHead.FIRE_RATE_MULT = 0.5
--The effect will proc every x tears
MaxsHead.NUM_TEARS_PROC = 4


---@param player EntityPlayer
function MaxsHead:OnFireDelayCache(player)
    local num = player:GetCollectibleNum(MaxsHead.ID)

    local tps = Helpers.ToTearsPerSecond(player.MaxFireDelay)
    if tps > 5 then
        tps = tps + MaxsHead.FIRE_DELAY * num
    else
        tps = math.min(5, tps + MaxsHead.FIRE_DELAY * num)
    end
    player.MaxFireDelay = Helpers.ToMaxFireDelay(tps)
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    MaxsHead.OnFireDelayCache,
    CacheFlag.CACHE_FIREDELAY
)


if REPENTOGON then
    function MaxsHead:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player or amount < 1 then return end
            if not player:HasCollectible(MaxsHead.ID) then return end
            local data = Helpers.GetData(player)
			local numTears = data.NumTears or 1

            if numTears >= MaxsHead.NUM_TEARS_PROC then
                data.NumTears = 1
                player.FireDelay = Helpers.Round(player.FireDelay * MaxsHead.FIRE_RATE_MULT, 2)
            else
                data.NumTears = numTears + 1
            end
		end
	end
	RestoredItemsCollection:AddCallback(
        ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED,
        MaxsHead.ChargeOnFire
    )
else
    ---@param player EntityPlayer
    function MaxsHead:OnPlayerUpdate(player)
        if not player:HasCollectible(MaxsHead.ID) then return end

        local data = Helpers.GetData(player)
        local prevFireDelay = data.PreviousFireDelay or 10
        local currentFireDelay = player.FireDelay
        data.PreviousFireDelay = currentFireDelay

        if prevFireDelay < currentFireDelay then
            local numTears = data.NumTears or 1

            if numTears >= MaxsHead.NUM_TEARS_PROC then
                data.NumTears = 1
                player.FireDelay = Helpers.Round(currentFireDelay * MaxsHead.FIRE_RATE_MULT, 2)
            else
                data.NumTears = numTears + 1
            end
        end
    end
    RestoredItemsCollection:AddCallback(
        ModCallbacks.MC_POST_PEFFECT_UPDATE,
        MaxsHead.OnPlayerUpdate
    )
end