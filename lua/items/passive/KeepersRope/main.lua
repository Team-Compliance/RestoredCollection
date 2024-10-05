local KeepersRope = {}
local game = Game()
local Helpers = RestoredCollection.Helpers

local coinIndicator = Sprite()
coinIndicator:Load("gfx/005.021_penny.anm2",true)
coinIndicator:SetFrame("Idle",10)
coinIndicator.Color = Color(1,1,1,0.55)
coinIndicator.Scale = Vector(0.8, 0.8)

KeepersRope.NoCoinList = {
	{EntityType.ENTITY_STONEHEAD},
	{EntityType.ENTITY_POKY},
	{EntityType.ENTITY_MASK},
	{EntityType.ENTITY_ETERNALFLY},
	{EntityType.ENTITY_STONE_EYE},
	{EntityType.ENTITY_CONSTANT_STONE_SHOOTER},
	{EntityType.ENTITY_BRIMSTONE_HEAD},
	{EntityType.ENTITY_DEATHS_HEAD,0},
	{EntityType.ENTITY_DEATHS_HEAD,2},
	{EntityType.ENTITY_DEATHS_HEAD,3},
	{EntityType.ENTITY_WALL_HUGGER},
	{EntityType.ENTITY_GAPING_MAW},
	{EntityType.ENTITY_BROKEN_GAPING_MAW},
	{EntityType.ENTITY_PITFALL},
	{EntityType.ENTITY_CORN_MINE},
	{EntityType.ENTITY_STONEY},
	{EntityType.ENTITY_PORTAL},
	{EntityType.ENTITY_BLOOD_PUPPY},
	{EntityType.ENTITY_QUAKE_GRIMACE},
	{EntityType.ENTITY_BOMB_GRIMACE},
	{EntityType.ENTITY_FISSURE},
	{EntityType.ENTITY_SPIKEBALL},
	{EntityType.ENTITY_SMALL_MAGGOT},
	{EntityType.ENTITY_MOCKULUS},
	{EntityType.ENTITY_GRUDGE},
	{EntityType.ENTITY_DUSTY_DEATHS_HEAD},
	{EntityType.ENTITY_SINGE,1},
	{EntityType.ENTITY_GIDEON},
	{EntityType.ENTITY_ROTGUT,1},
	{EntityType.ENTITY_ROTGUT,2}
}

--Functionality Code
local function GetRope(player,bool)
	bool = bool or false
	for _,rope in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.KEEPERS_ROPE.Variant)) do
		rope = rope:ToEffect()
		if GetPtrHash(rope.SpawnerEntity) == GetPtrHash(player) then
			return bool and true or rope
		end
	end
	return bool and false or nil
end

function KeepersRope:Rope(player)
	local BeastFight = game:GetLevel():GetAbsoluteStage() == LevelStage.STAGE8 and game:GetRoom():GetType() == RoomType.ROOM_DUNGEON
	local hasMorphedKeepersRope = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "HasMorphedKeepersRope")
	if not hasMorphedKeepersRope then
		for _, _ in ipairs(Isaac.FindByType(5,100,RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE)) do
			TSIL.SaveManager.SetPersistentVariable(RestoredCollection, "HasMorphedKeepersRope", true)
		end
	end
	if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE) and not hasMorphedKeepersRope then
		TSIL.SaveManager.SetPersistentVariable(RestoredCollection, "HasMorphedKeepersRope", true)
		--[[if not BeastFight and not player:IsDead() then
			if not GetRope(player, true) then
				local rope = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.KEEPERS_ROPE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
				rope:FollowParent(player)
			else
				local rope = GetRope(player)
				--rope.Position = player.Position
				rope.DepthOffset = -10
			end
		end]]
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, KeepersRope.Rope)


function KeepersRope:RopeInit(rope)
	local sprite = rope:GetSprite()
	sprite:SetFrame("Rope",0)
end
--RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, KeepersRope.RopeInit, RestoredCollection.Enums.Entities.KEEPERS_ROPE.Variant)


function KeepersRope:RopeUpdate(rope)
	local BeastFight = game:GetLevel():GetAbsoluteStage() == LevelStage.STAGE8 and game:GetRoom():GetType() == RoomType.ROOM_DUNGEON
	if not rope.SpawnerEntity:Exists() or rope.SpawnerType ~= EntityType.ENTITY_PLAYER or BeastFight then
		rope:Remove()
	end
	local player = rope.SpawnerEntity:ToPlayer()
	--rope.Position = player.Position
	if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE) == false or player:IsDead() then
		rope:Remove()
	elseif player:GetPlayerType() ~= PlayerType.PLAYER_THELOST and player:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B
	and player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL and player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B and
	player:GetPlayerType() ~= PlayerType.PLAYER_JACOB2_B then
		local sprite = player:GetSprite()
		if sprite:IsPlaying("WalkLeft") or sprite:IsPlaying("WalkRight")
		or sprite:IsPlaying("WalkUp") or sprite:IsPlaying("WalkDown") 
		or sprite:IsPlaying("PickupWalkLeft") or sprite:IsPlaying("PickupWalkRight")
		or sprite:IsPlaying("PickupWalkUp") or sprite:IsPlaying("PickupWalkDown")then
			sprite:Stop()
		end
	end
end
--RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, KeepersRope.RopeUpdate, RestoredCollection.Enums.Entities.KEEPERS_ROPE.Variant)


local function DontGiveCoins(npc)
	if npc.SpawnerEntity ~= nil or game:GetLevel():GetAbsoluteStage() == LevelStage.STAGE8 then
		return true
	end
	if not npc:IsVulnerableEnemy() then
		return true
	end
	if not npc:IsActiveEnemy(false) then
		return true
	end
	if npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:HasEntityFlags(EntityFlag.FLAG_PERSISTENT) then
		return true
	end
	for _,entity in pairs(KeepersRope.NoCoinList) do
		if entity[1] == npc.Type then
			if entity[2] then
				if entity[2] == npc.Variant then
					return true
				end	
			else
				return true
			end
		end
	end
	return false
end


function KeepersRope:HereComesTheMoney(npc)
	if DontGiveCoins(npc) then return end
	local rng = TSIL.RNG.NewRNG(npc.InitSeed)
	for _, player in ipairs(Helpers.GetPlayers()) do
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE) then
			local isKeeper = player:GetPlayerType() == PlayerType.PLAYER_KEEPER
			local isTaintedKeeper = player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B
			local chance = isTaintedKeeper and 8 or (isKeeper and 6 or 4)
			local coins = isTaintedKeeper and 1 or (isKeeper and 2 or 3)
			if rng:RandomInt(chance) == 1 then
				local entityData = Helpers.GetData(npc)
				local mul = npc:IsBoss() and 2 or 1
				entityData.CoinsToBeat = (rng:RandomInt(coins + 1)) * mul
				if entityData.CoinsToBeat == 0 then entityData.CoinsToBeat = nil end
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NPC_INIT, KeepersRope.HereComesTheMoney)


function KeepersRope:MoneyMoneyMoneyMoney(entity, _, damageflags, source)
	if source.Type > 0 and damageflags & DamageFlag.DAMAGE_NOKILL ~= DamageFlag.DAMAGE_NOKILL then
		local data = Helpers.GetData(entity)
		if entity:IsVulnerableEnemy() and data.CoinsToBeat then			
			if data.CoinsToBeat > 0 then
				for _, player in ipairs(Helpers.GetPlayers()) do
					local pickup = {Variant = PickupVariant.PICKUP_COIN, SubType = CoinSubType.COIN_PENNY}
					local rng = player:GetCollectibleRNG(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE)
					local vector
					if REPENTOGON then
						vector = EntityPickup.GetRandomPickupVelocity(entity.Position, rng)
					else
						vector = TSIL.Vector.GetRandomVector(rng) * TSIL.Random.GetRandomElementsFromTable({1, -1}, 1, rng)[1]
						vector:Resize(1)
						rng:Next()
						vector = Vector(vector.X * TSIL.Random.GetRandomInt(1,3, rng), vector.Y * TSIL.Random.GetRandomInt(1,3, rng))
						rng:Next()
					end
					Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, pickup.SubType, entity.Position, vector, nil):ToPickup().Timeout = 60
					data.CoinsToBeat = data.CoinsToBeat - 1
				end
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, KeepersRope.MoneyMoneyMoneyMoney)


function KeepersRope:MoneyMoneyMoneyMoneyMoney(npc)
	local data = Helpers.GetData(npc)
	if Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	if data.CoinsToBeat and data.CoinsToBeat > 0 and npc.Visible then
		local color = Color(1,1,1,1)
		color:SetColorize(1,0.5,0,0.6)
		npc:GetSprite().Color = color
		coinIndicator:Render((Isaac.WorldToScreen(npc.Position) + Vector(0,-2.3)*(npc.Size <20 and npc.Size or 20) ),Vector.Zero,Vector.Zero)
		coinIndicator.Color = Color(1,1,1,0.5)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, KeepersRope.MoneyMoneyMoneyMoneyMoney)


function KeepersRope:DollarDollar(npc)
	local data = Helpers.GetData(npc)
	if data.CoinsToBeat and data.CoinsToBeat > 0 then
		local rng = npc:GetDropRNG()
		for _ = 1, data.CoinsToBeat do
			local vector
			if REPENTOGON then
				vector = EntityPickup.GetRandomPickupVelocity(npc.Position, rng)
			else
				vector = TSIL.Vector.GetRandomVector(rng) * TSIL.Random.GetRandomElementsFromTable({1, -1}, 1, rng)[1]
				rng:Next()
				vector = Vector(vector.X * TSIL.Random.GetRandomInt(1,3, rng), vector.Y * TSIL.Random.GetRandomInt(1,3, rng))
				rng:Next()
			end
			local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, npc.Position, vector, nil):ToPickup()
			data.CoinsToBeat = data.CoinsToBeat - 1
			pickup.Timeout = 90
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, KeepersRope.DollarDollar)


function KeepersRope:NoSoap(player,cacheFlag)
	if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE) then
		if cacheFlag == CacheFlag.CACHE_LUCK and not Helpers.IsAnyPlayerType(player, PlayerType.PLAYER_KEEPER, PlayerType.PLAYER_KEEPER_B) then
			player.Luck = player.Luck - 2
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, KeepersRope.NoSoap)

function KeepersRope:RopeReplacement(keeper)
	if not TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "HasMorphedKeepersRope") then
		for __,pickup in ipairs(Isaac.FindByType(5,100)) do
			pickup = pickup:ToPickup()
			if (pickup.Position - keeper.Position):Length() <= 10 and pickup.FrameCount == 0 and
			(pickup.SubType == CollectibleType.COLLECTIBLE_STEAM_SALE or pickup.SubType == CollectibleType.COLLECTIBLE_HEAD_OF_THE_KEEPER
			or pickup.SubType == CollectibleType.COLLECTIBLE_COUPON) then
				local pickData = Helpers.GetData(pickup)
				if not pickData.RNG then
					pickData.RNG = RNG()
					pickData.RNG:SetSeed(pickup.InitSeed, 35)
				end
				if pickData.RNG:RandomInt(3) == 0 and pickup.SubType ~= RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE then
					pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, true, true, false)
					break
				end
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, KeepersRope.RopeReplacement, EntityType.ENTITY_SHOPKEEPER)