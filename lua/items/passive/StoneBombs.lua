local StoneBombs = {}
local Helpers = require("lua.helpers.Helpers")

local directions = {
	0,
	90,
	180,
	270
}

function StoneBombs:BombInit(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local data = Helpers.GetData(bomb)
		if player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS) then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredItemsCollection.Enums.BombVariant.BOMB_STONE
				end
			end
			data.isStoneBomb = true
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
		player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10 then
			data.isStoneBomb = true
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, StoneBombs.BombInit)

function StoneBombs:BombUpdate(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	local data = Helpers.GetData(bomb)
	
	if data.isStoneBomb then
		local sprite = bomb:GetSprite()

		if sprite:IsPlaying("Explode") then
			StoneBombs:SB_Explode(bomb, player)
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, StoneBombs.BombUpdate)

function StoneBombs:SB_Explode(bomb, player)
	for _, dir in pairs(directions) do
		--local crackwave = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACKWAVE, 1, bomb.Position, bomb.Velocity, player)
		--crackwave:ToEffect().Rotation = dir
		CustomShockwaveAPI:SpawnCustomCrackwave(bomb.Position, player, 30, dir, 2, 50)
		-- crackwave.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NOPITS
	end
end