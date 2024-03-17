local AncientRevelation = {}
local Helpers = require("lua.helpers.Helpers")

function AncientRevelation:EvaluateCache(player, cacheFlag)
	if player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION) then
		local acNum = player:GetCollectibleNum(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION)
		if cacheFlag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = Helpers.tearsUp(player.MaxFireDelay, acNum)
		elseif cacheFlag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed + 0.48 * acNum
		elseif cacheFlag == CacheFlag.CACHE_FLYING then
			player.CanFly = true
		elseif cacheFlag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(player.TearColor.R, player.TearColor.G, player.TearColor.B, player.TearColor.A, 260/255, 250/255, 40/255)
			player.LaserColor = Color(player.LaserColor.R, player.LaserColor.G, player.LaserColor.B, player.LaserColor.A, 260/255, 250/255, 40/255)
		elseif cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL
			player.TearFlags = player.TearFlags | TearFlags.TEAR_TURN_HORIZONTAL
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AncientRevelation.EvaluateCache)

if REPENTOGON then
	function AncientRevelation:AddImmortalHearts(collectible, charge, firstTime, slot, VarData, player)
		if firstTime and collectible == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION then
			player:AddSoulHearts(-4)
			ComplianceImmortal.AddImmortalHearts(player, 4)
		end
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, AncientRevelation.AddImmortalHearts)
else
	---@param player EntityPlayer
	function AncientRevelation:OnPlayerInit(player)
		local data = Helpers.GetData(player)
		data.AncientCount = player:GetCollectibleNum(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION)
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, AncientRevelation.OnPlayerInit)

	function AncientRevelation:ARUpdate(player, cache)
		if player.Parent ~= nil then return end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		local data = Helpers.GetData(player)
		if player:GetCollectibleNum(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION) > data.AncientCount then
			local p = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
			p:AddSoulHearts(-4)
			ComplianceImmortal.AddImmortalHearts(p, 4)
		end
		data.AncientCount = player:GetCollectibleNum(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION)
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, AncientRevelation.ARUpdate, CacheFlag.CACHE_TEARFLAG)
end