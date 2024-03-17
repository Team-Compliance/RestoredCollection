local ComplianceImmortalLocal = {}
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

function ComplianceImmortal.GetImmortalHeartsNum(player)
	if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
		player = player:GetSubPlayer()
	end
	return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_IMMORTAL")
end

function ComplianceImmortal.GetImmortalHearts(player)
	return ComplianceImmortal.GetImmortalHeartsNum(player)
end

function ComplianceImmortal.AddImmortalHearts(player, hp)
	CustomHealthAPI.Library.AddHealth(player, "HEART_IMMORTAL", hp)
end

function ComplianceImmortal.CanPickImmortalHearts(player)
	return CustomHealthAPI.Library.CanPickKey(player, "HEART_IMMORTAL")
end

function ComplianceImmortal.HealImmortalHeart(player) -- returns true if successful
	if ComplianceImmortal.GetImmortalHeartsNum(player) > 0 and ComplianceImmortal.GetImmortalHeartsNum(player) % 2 ~= 0 then
		local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -22)
		sfx:Play(RestoredItemsCollection.Enums.SFX.Hearts.IMMORTAL_PICKUP, 1, 0)
		ComplianceImmortal.AddImmortalHearts(player, 1)
		return true
	end
	return false
end

function ComplianceImmortalLocal:ImmortalHeartCollision(pickup, collider)
	if collider.Type == EntityType.ENTITY_PLAYER and pickup.SubType == RestoredItemsCollection.Enums.Pickups.Hearts.HEART_IMMORTAL then
		local player = collider:ToPlayer()
		if not Helpers.CanCollectCustomShopPickup(player, pickup) then
			return true
		end
		if ComplianceImmortal.CanPickImmortalHearts(player) then
			local collect = Helpers.CollectCustomPickup(player,pickup)
			if collect ~= nil then
				return collect
			end
			if not Helpers.IsLost(player) then
				ComplianceImmortal.AddImmortalHearts(player, 2)
			end
			sfx:Play(RestoredItemsCollection.Enums.SFX.Hearts.IMMORTAL_PICKUP, 1, 0)
			Game():GetLevel():SetHeartPicked()
			Game():ClearStagesWithoutHeartsPicked()
			Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
			return true
		else
			return pickup:IsShopItem()
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ComplianceImmortalLocal.ImmortalHeartCollision, PickupVariant.PICKUP_HEART)

if REPENTOGON then
	function ComplianceImmortalLocal:ActOfImmortal(collectible, charge, firstTime, slot, VarData, player)
		if firstTime and collectible == CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION
		and TSIL.SaveManager.GetPersistentVariable(RestoredItemsCollection, "ActOfContrictionImmortal") then
			player:AddEternalHearts(-1)
			ComplianceImmortal.AddImmortalHearts(player, 2)
		end
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, ComplianceImmortalLocal.ActOfImmortal)

	function ComplianceImmortalLocal:ImmortalHeartIFrames(player, damage, flags, source, cd)
		if player:GetData().ImmortalHeartDamage then
			player = player:ToPlayer()
			local cd = 20
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(cd)
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(cd)
			end
			player:GetData().ImmortalHeartDamage = nil
		end
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_TAKE_DMG, ComplianceImmortalLocal.ImmortalHeartIFrames, EntityType.ENTITY_PLAYER)
else
	function ComplianceImmortalLocal:OnPlayerInit(player)
		local data = Helpers.GetData(player)
		data.ActCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ComplianceImmortalLocal.OnPlayerInit)

	function ComplianceImmortalLocal:ActOfImmortal(player, cache)
		if player.Parent ~= nil then return end
		if not TSIL.SaveManager.GetPersistentVariable(RestoredItemsCollection, "ActOfContrictionImmortal") then return end
		if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
			player = player:GetMainTwin()
		end
		local data = Helpers.GetData(player)
		if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION) > data.ActCount then
			local p = player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN and player:GetSubPlayer() or player
			player:AddEternalHearts(-1)
			ComplianceImmortal.AddImmortalHearts(p, 2)
		end
		data.ActCount = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_ACT_OF_CONTRITION)
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ComplianceImmortalLocal.ActOfImmortal, CacheFlag.CACHE_FIREDELAY)

	function ComplianceImmortalLocal:ImmortalHeartIFrames(player)
		if player:GetData().ImmortalHeartDamage then
			local cd = 20
			player:ResetDamageCooldown()
			player:SetMinDamageCooldown(cd)
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B or player:GetPlayerType() == PlayerType.PLAYER_ESAU
			or player:GetPlayerType() == PlayerType.PLAYER_JACOB then
				player:GetOtherTwin():ResetDamageCooldown()
				player:GetOtherTwin():SetMinDamageCooldown(cd)
			end
			player:GetData().ImmortalHeartDamage = nil
		end
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ComplianceImmortalLocal.ImmortalHeartIFrames)
end

function ComplianceImmortalLocal:ImmortalHeal()
	for i = 0, Game():GetNumPlayers() - 1 do
		ComplianceImmortal.HealImmortalHeart(Isaac.GetPlayer(i))
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ComplianceImmortalLocal.ImmortalHeal)

---@param pickup EntityPickup
function ComplianceImmortalLocal:PreEternalSpawn(pickup)
	if TSIL.Random.GetRandom(pickup.InitSeed) >= (1 - TSIL.SaveManager.GetPersistentVariable(RestoredItemsCollection, "ImmortalHeartSpawnChance") / 100) 
	and pickup.SubType == HeartSubType.HEART_ETERNAL then
		pickup:Morph(pickup.Type, PickupVariant.PICKUP_HEART, RestoredItemsCollection.Enums.Pickups.Hearts.HEART_IMMORTAL, true, true)
	end
end
RestoredItemsCollection:AddCallback(TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST, ComplianceImmortalLocal.PreEternalSpawn, PickupVariant.PICKUP_HEART)