local StoneBombs = {}
local Helpers = require("lua.helpers.Helpers")

local directions = {
	0,
	90,
	180,
	270
}

function StoneBombs:StoneRocketInit(rocket)
    local player = Helpers.GetPlayerFromTear(rocket)
	if player then
        local rng = rocket:GetDropRNG()
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS) and rng:RandomInt(100) < 20 then
            Helpers.GetData(rocket).StoneBomb = true
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, StoneBombs.StoneRocketInit, EffectVariant.ROCKET)

function StoneBombs:StoneRocketExplode(rocket)
    if rocket.Type == EntityType.ENTITY_EFFECT and rocket.Variant == EffectVariant.ROCKET then
        local player = Helpers.GetPlayerFromTear(rocket)
        if not player then return end
        local data = Helpers.GetData(rocket)
        if data.StoneBomb then
			for _, dir in pairs(directions) do
				CustomShockwaveAPI:SpawnCustomCrackwave(rocket.Position, player, 30, dir, 2, player.Damage * 5, player.Damage * 10)
			end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, StoneBombs.StoneRocketExplode)

function StoneBombs:BombInit(bomb)
	if Helpers.GetData(bomb).BombInit then return end
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local data = Helpers.GetData(bomb)
		local rng = bomb:GetDropRNG()
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS) and 
        (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20) then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredCollection.Enums.BombVariant.BOMB_STONE
				end
			end
			BombFlagsAPI.AddCustomBombFlag(bomb, "STONE_BOMB")
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
		player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10 then
			BombFlagsAPI.AddCustomBombFlag(bomb, "STONE_BOMB")
		end
	end
end
--RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, StoneBombs.BombInit)

function StoneBombs:BombUpdate(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	local data = Helpers.GetData(bomb)

	if bomb.FrameCount == 1 then
        StoneBombs:BombInit(bomb)
        if bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_STONE then
            local sprite = bomb:GetSprite()
            local anim = sprite:GetAnimation()
            local file = sprite:GetFilename()
            sprite:Load("gfx/items/pick ups/bombs/stone"..file:sub(file:len()-5), true)
            sprite:Play(anim, true)
        end
    end

	if BombFlagsAPI.HasCustomBombFlag(bomb, "STONE_BOMB") then
		local sprite = bomb:GetSprite()

		if sprite:IsPlaying("Explode") then
			StoneBombs:SB_Explode(bomb, player)
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, StoneBombs.BombUpdate)

function StoneBombs:SB_Explode(bomb, player)
	for _, dir in pairs(directions) do
		CustomShockwaveAPI:SpawnCustomCrackwave(bomb.Position, player, 30, dir, 2, bomb.ExplosionDamage / 2, bomb.ExplosionDamage)
	end
end

RestoredCollection:AddCallback("ON_STOMP_EXPLOSION", function(_, player, bombDamage, radius)
	for _, dir in pairs(directions) do
		CustomShockwaveAPI:SpawnCustomCrackwave(player.Position, player, 30, dir, 2, bombDamage / 2, bombDamage)
	end
end, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS)