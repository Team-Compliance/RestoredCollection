local IllusionModLocal = {} --For local functions, so other mods don't have access to these
local game = Game()
local hud = game:GetHUD()
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

local TransformationItems = {
	[PlayerForm.PLAYERFORM_DRUGS] = Isaac.GetItemIdByName("Spun transform"),
	[PlayerForm.PLAYERFORM_MOM] = Isaac.GetItemIdByName("Mom transform"),
	[PlayerForm.PLAYERFORM_GUPPY] = Isaac.GetItemIdByName("Guppy transform"),
	[PlayerForm.PLAYERFORM_LORD_OF_THE_FLIES] = Isaac.GetItemIdByName("Fly transform"),
	[PlayerForm.PLAYERFORM_BOB] = Isaac.GetItemIdByName("Bob transform"),
	[PlayerForm.PLAYERFORM_MUSHROOM] = Isaac.GetItemIdByName("Mushroom transform"),
	[PlayerForm.PLAYERFORM_BABY] = Isaac.GetItemIdByName("Baby transform"),
	[PlayerForm.PLAYERFORM_ANGEL] = Isaac.GetItemIdByName("Angel transform"),
	[PlayerForm.PLAYERFORM_EVIL_ANGEL] = Isaac.GetItemIdByName("Devil transform"),
	[PlayerForm.PLAYERFORM_POOP] = Isaac.GetItemIdByName("Poop transform"),
	[PlayerForm.PLAYERFORM_BOOK_WORM] = Isaac.GetItemIdByName("Book transform"),
	[PlayerForm.PLAYERFORM_SPIDERBABY] = Isaac.GetItemIdByName("Spider transform"),
}

local ForbiddenItems = {
	CollectibleType.COLLECTIBLE_1UP,
	CollectibleType.COLLECTIBLE_DEAD_CAT,
	CollectibleType.COLLECTIBLE_INNER_CHILD,
	CollectibleType.COLLECTIBLE_GUPPYS_COLLAR,
	CollectibleType.COLLECTIBLE_LAZARUS_RAGS,
	CollectibleType.COLLECTIBLE_ANKH,
	CollectibleType.COLLECTIBLE_JUDAS_SHADOW,
	CollectibleType.COLLECTIBLE_STRAW_MAN
}

local ForbiddenTrinkets = {
	TrinketType.TRINKET_MISSING_POSTER,
	TrinketType.TRINKET_BROKEN_ANKH
}

local ForbiddenPCombos = {
	{PlayerType = PlayerType.PLAYER_THELOST_B, Item = CollectibleType.COLLECTIBLE_BIRTHRIGHT},
}

function IllusionMod.AddForbiddenItem(i)
	table.insert(ForbiddenItems,i)
end

function IllusionMod.AddForbiddenTrinket(i)
	table.insert(ForbiddenTrinkets,i)
end

function IllusionMod.AddForbiddenCharItem(type, i)
	table.insert(ForbiddenPCombos,{PlayerType = type, Item = i})
end

local function BlackList(collectible)
	for _,i in ipairs(ForbiddenItems) do
		if i == collectible then
			return true
		end
	end
	return false
end

local function BlackListTrinket(trinket)
	for _,i in ipairs(ForbiddenTrinkets) do
		if i == trinket then
			return true
		end
	end
	return false
end

local function CanBeRevived(pType,withItem)
	for _,v in ipairs(ForbiddenPCombos) do
		if v.PlayerType == pType and v.Item == withItem then
			return true
		end
	end
	return false
end

function IllusionModLocal:UpdateClones(p)
	local data = Helpers.GetEntityData(p)
    if not data then return end
	if data.IsIllusion then
		if p:IsDead()  then
			--p.Visible = false
			if p:GetPlayerType() ~= PlayerType.PLAYER_THELOST and p:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B 
			and p:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B then
				p:GetSprite():SetLayerFrame(PlayerSpriteLayer.SPRITE_GHOST,0)
			end
			if p:GetSprite():IsFinished("Death") or p:GetSprite():IsFinished("ForgottenDeath") then
				p:GetSprite():SetFrame(70)
				if p:GetPlayerType() ~= PlayerType.PLAYER_THELOST and p:GetPlayerType() ~= PlayerType.PLAYER_THELOST_B and
				p:GetPlayerType() ~= PlayerType.PLAYER_THESOUL and p:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B  and p:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B
				and not p:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) then
					p:ChangePlayerType(PlayerType.PLAYER_THELOST)
					local offset = (p:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN or p:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B) and Vector(30 * p.SpriteScale.X,0) or Vector.Zero
                    ---@diagnostic disable-next-line: param-type-mismatch
					local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, p.Position + offset, Vector.Zero, p)
					local sColor = poof:GetSprite().Color
					local color = Color(sColor.R, sColor.G, sColor.B, 0.7, 0.518, 0.15, 0.8)
					local s = poof:GetSprite()
					s.Color = color
					sfx:Play(SoundEffect.SOUND_BLACK_POOF)
				end
			end
		end
		if not p:IsDead() then
			if p.Parent and (not p.Parent:Exists() or p.Parent:IsDead()) then
				p:Die()
				p:AddMaxHearts(-p:GetMaxHearts())
				p:AddSoulHearts(-p:GetSoulHearts())
				p:AddBoneHearts(-p:GetBoneHearts())
				p:AddGoldenHearts(-p:GetGoldenHearts())
				p:AddEternalHearts(-p:GetEternalHearts())
				p:AddHearts(-p:GetHearts())
				--Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, p.Position, Vector.Zero, p)
			end
		end
		p:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, IllusionModLocal.UpdateClones)

function IllusionModLocal:CloneRoomUpdate()
	for i = 0, game:GetNumPlayers()-1 do
		local p = Isaac.GetPlayer(i)
		local data = Helpers.GetEntityData(p)
        if not data then return end
		if data.IsIllusion and p:IsDead() then
			p:GetSprite():SetFrame(70)
			p:ChangePlayerType(PlayerType.PLAYER_THELOST)
			Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, -1, p.Position, Vector.Zero, p)
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, IllusionModLocal.CloneRoomUpdate)


---@param player EntityPlayer
---@param illusionPlayer EntityPlayer
---@param playerType PlayerType
local function AddItemsToIllusion(player, illusionPlayer, playerType)
	if REPENTOGON then
		local history = player:GetHistory():GetCollectiblesHistory()
		for index, item in ipairs(history) do
			if not item:IsTrinket() then
				local id = item:GetItemID()
				if not BlackList(id) and not CanBeRevived(playerType, id) then
					local itemCollectible = Isaac.GetItemConfig():GetCollectible(id)
					if not illusionPlayer:HasCollectible(id) and player:HasCollectible(id) and
					itemCollectible.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then
						if itemCollectible.Type ~= ItemType.ITEM_ACTIVE then
							for _ = 1, player:GetCollectibleNum(id) do
								illusionPlayer:AddCollectible(id, 0, false)
							end
						end
					end
				end
			end
		end
	else
		for i=1, Isaac.GetItemConfig():GetCollectibles().Size - 1 do
			if not BlackList(i) and not CanBeRevived(playerType, i) then
				local itemConfig = Isaac.GetItemConfig()
				local itemCollectible = itemConfig:GetCollectible(i)
				if itemCollectible then
					if not illusionPlayer:HasCollectible(i) and player:HasCollectible(i) and
					itemCollectible.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST then
						if itemCollectible.Type ~= ItemType.ITEM_ACTIVE then
							for _ = 1, player:GetCollectibleNum(i) do
								illusionPlayer:AddCollectible(i, 0, false)
							end
						end
					end
				end
			end
		end
	end
end

---@param illusionPlayer EntityPlayer
local function RemoveActiveItemsFromIllusion(illusionPlayer)
	for i = 2, 0, -1 do
		local c = illusionPlayer:GetActiveItem(i)
		if c > 0 then
			illusionPlayer:RemoveCollectible(c,false,i)
		end
	end
end

---@param player EntityPlayer
---@param illusionPlayer EntityPlayer
local function AddTrinketsToIllusion(player, illusionPlayer)
	if REPENTOGON then
		local history = player:GetHistory():GetCollectiblesHistory()
		for index, item in ipairs(history) do
			if item:IsTrinket() then
				local id = item:GetItemID()
				local itemTrinket = Isaac.GetItemConfig():GetTrinket(id)
				if not BlackListTrinket(id) and itemTrinket then
					if not illusionPlayer:HasTrinket(id) and player:HasTrinket(id) then
						for _ = 1, player:GetTrinketMultiplier(id) do
							illusionPlayer:AddSmeltedTrinket(id, false)
						end
					end
				end
			end
		end
	else
		for i=1, Isaac.GetItemConfig():GetTrinkets().Size - 1 do
			if not BlackListTrinket(i) then
				local itemConfig = Isaac.GetItemConfig()
				local itemTrinket = itemConfig:GetTrinket(i)
				if itemTrinket then
					if not illusionPlayer:HasTrinket(i) and player:HasTrinket(i) then
						for _ = 1, player:GetTrinketMultiplier(i) do
							illusionPlayer:AddTrinket(i,false)
							illusionPlayer:UseActiveItem(CollectibleType.COLLECTIBLE_SMELTER,false)
						end
					end
				end
			end
		end
	end
end

local function AddTransformationsToIllusion(player, illusionPlayer)
	for transformation, transformationItem in pairs(TransformationItems) do
		if player:HasPlayerForm(transformation) and not illusionPlayer:HasPlayerForm(transformation) then
			if REPENTOGON then
				illusionPlayer:IncrementPlayerFormCounter(transformation, 3)
			else
				for _ = 1, 3, 1 do
					illusionPlayer:AddCollectible(transformationItem)
				end
			end
		end
	end
end

---@param illusionPlayer EntityPlayer
local function SetIllusionHealth(illusionPlayer)
	illusionPlayer:AddMaxHearts(-illusionPlayer:GetMaxHearts())
	illusionPlayer:AddSoulHearts(-illusionPlayer:GetSoulHearts())
	illusionPlayer:AddBoneHearts(-illusionPlayer:GetBoneHearts())
	illusionPlayer:AddGoldenHearts(-illusionPlayer:GetGoldenHearts())
	illusionPlayer:AddEternalHearts(-illusionPlayer:GetEternalHearts())
	illusionPlayer:AddHearts(-illusionPlayer:GetHearts())

	illusionPlayer:AddMaxHearts(2)
	illusionPlayer:AddHearts(2)
end

---@param illusionPlayer EntityPlayer
local function SpawnIllusionPoof(illusionPlayer)
	local poof = Isaac.Spawn(
		EntityType.ENTITY_EFFECT,
		EffectVariant.POOF01,
		-1,
		illusionPlayer.Position,
		Vector.Zero,
		illusionPlayer
	)

	local sColor = poof:GetSprite().Color
	local color = Color(sColor.R, sColor.G, sColor.B, 0.7, 0.518, 0.15, 0.8)
	local sprite = poof:GetSprite()
	sprite.Color = color
end

---@param player EntityPlayer
---@param isIllusion boolean
---@param addWisp boolean
---@return EntityPlayer?
function IllusionMod:addIllusion(player, isIllusion, addWisp)
	if addWisp == nil then addWisp = false end

	local playerType = player:GetPlayerType()

	if playerType == PlayerType.PLAYER_JACOB then
		player = player:GetOtherTwin()
		playerType = PlayerType.PLAYER_ESAU
	elseif playerType == PlayerType.PLAYER_THESOUL_B then
		playerType = PlayerType.PLAYER_THEFORGOTTEN_B
	elseif playerType == PlayerType.PLAYER_THESOUL then
		playerType = PlayerType.PLAYER_THEFORGOTTEN
	end

	Isaac.ExecuteCommand("addplayer 15 " .. player.ControllerIndex)

	local newPlayerIndex = game:GetNumPlayers() - 1
	local illusionPlayer = Isaac.GetPlayer(newPlayerIndex)

	local data = Helpers.GetEntityData(illusionPlayer)
	if not data then return nil end

	if playerType == PlayerType.PLAYER_LAZARUS_B or playerType == PlayerType.PLAYER_LAZARUS2_B then
		playerType = PlayerType.PLAYER_ISAAC
		local costume

		if playerType == PlayerType.PLAYER_LAZARUS_B then
			data.TaintedLazA = true
			costume = NullItemID.ID_LAZARUS_B
		else
			data.TaintedLazB = true
			costume = NullItemID.ID_LAZARUS2_B
		end

		illusionPlayer:AddNullCostume(costume)
	end

	illusionPlayer:ChangePlayerType(playerType)

	if isIllusion then
		AddItemsToIllusion(player, illusionPlayer, playerType)

		RemoveActiveItemsFromIllusion(illusionPlayer)

		AddTrinketsToIllusion(player, illusionPlayer)

		AddTransformationsToIllusion(player, illusionPlayer)

		data.IsIllusion = true

		SetIllusionHealth(illusionPlayer)

		if playerType == PlayerType.PLAYER_THEFORGOTTEN_B then
			local twinData = Helpers.GetEntityData(illusionPlayer:GetOtherTwin())
            if not twinData then return end

			twinData.IsIllusion = true
			illusionPlayer:GetOtherTwin().Parent = player:GetOtherTwin()
		end

		SpawnIllusionPoof(illusionPlayer)
	end

	if addWisp then
		local wisp = player:AddWisp(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, player.Position)
		local wispData = Helpers.GetEntityData(wisp)

		wispData.isIllusion = true
		wispData.illusionId = illusionPlayer:GetCollectibleRNG(1):GetSeed()
		data.hasWisp = true
	end

	illusionPlayer:PlayExtraAnimation("Appear")
	illusionPlayer:AddCacheFlags(CacheFlag.CACHE_ALL)
	illusionPlayer:EvaluateItems()
	illusionPlayer.Parent = player
	hud:AssignPlayerHUDs()
	return illusionPlayer
end

function IllusionModLocal:CloneCache(p, _)
	local d = Helpers.GetEntityData(p)
    if not d then return end
	if d.IsIllusion then
		--local color = Color(0.518, 0.22, 1, 0.45)
		local sColor = p:GetSprite().Color
		local color = Color(sColor.R, sColor.G, sColor.B, 0.45, 0.518, 0.15, 0.8)
		local s = p:GetSprite()
		s.Color = color
		if p:GetBoneHearts() > 0 then
			p:AddBoneHearts(-p:GetBoneHearts())
		end
		if p:GetGoldenHearts() > 0 then
			p:AddGoldenHearts(-p:GetGoldenHearts())
		end
		if p:GetEternalHearts() > 0 then
			p:AddEternalHearts(-p:GetEternalHearts())
		end
	else
		d = nil
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, IllusionModLocal.CloneCache)

function IllusionModLocal:HackyLazWorkAround(player,cache)
	local d = Helpers.GetEntityData(player)
    if not d then return end
	if d.IsIllusion then
		if d.TaintedLazA == true then
			if cache == CacheFlag.CACHE_RANGE then
				player.TearRange = player.TearRange - 80
			end
		elseif d.TaintedLazB == true then
			if cache == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * 1.50
			elseif cache == CacheFlag.CACHE_FIREDELAY then
				player.MaxFireDelay = player.MaxFireDelay + 1
			elseif cache == CacheFlag.CACHE_SPEED then
				player.MoveSpeed = player.MoveSpeed - 0.1
			elseif cache == CacheFlag.CACHE_LUCK then
				player.Luck = player.Luck - 2
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, IllusionModLocal.HackyLazWorkAround)

function IllusionModLocal:preIllusionHeartPickup(pickup, collider)
	local player = collider:ToPlayer()
	if player then
		local d = Helpers.GetEntityData(player)
        if not d then return end
		if d.IsIllusion then
			return d.IsIllusion and true or pickup:IsShopItem()
		else
			d = nil
		end
		if pickup.Variant == PickupVariant.PICKUP_HEART and pickup.SubType == RestoredCollection.Enums.Pickups.Hearts.HEART_ILLUSION and not player.Parent then
			pickup.Velocity = Vector.Zero
			pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			pickup:GetSprite():Play("Collect", true)
			pickup:Die()
			IllusionMod:addIllusion(player, true, false)
			sfx:Play(RestoredCollection.Enums.SFX.Hearts.ILLUSION_PICKUP, 1, 0, false)
			return true
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, IllusionModLocal.preIllusionHeartPickup)

function IllusionModLocal:preIllusionWhiteFlame(p, collider)
	if collider.Type == EntityType.ENTITY_FIREPLACE and collider.Variant == 4 then
		local d = Helpers.GetEntityData(p)
        if not d then return end
		if d.IsIllusion or p.Parent then
			p:Kill()
			p:AddMaxHearts(-p:GetMaxHearts())
			p:AddSoulHearts(-p:GetSoulHearts())
			p:AddBoneHearts(-p:GetBoneHearts())
			p:AddGoldenHearts(-p:GetGoldenHearts())
			p:AddEternalHearts(-p:GetEternalHearts())
			p:AddHearts(-p:GetHearts())
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, IllusionModLocal.preIllusionWhiteFlame)

---@param pickup EntityPickup
function IllusionModLocal:PreGoldenSpawn(pickup)
	if TSIL.Random.GetRandom(pickup.InitSeed) >= (1 - TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "IllusionHeartSpawnChance") / 100) 
	and pickup.SubType == HeartSubType.HEART_GOLDEN then
		pickup:Morph(pickup.Type, PickupVariant.PICKUP_HEART, RestoredCollection.Enums.Pickups.Hearts.HEART_ILLUSION, true, true)
	end
end
RestoredCollection:AddCallback(TSIL.Enums.CustomCallback.POST_PICKUP_INIT_FIRST, IllusionModLocal.PreGoldenSpawn, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
local function KillIllusion(player)
	player:Kill()

	player:AddMaxHearts(-player:GetMaxHearts())
	player:AddSoulHearts(-player:GetSoulHearts())
	player:AddBoneHearts(-player:GetBoneHearts())
	player:AddGoldenHearts(-player:GetGoldenHearts())
	player:AddEternalHearts(-player:GetEternalHearts())
	player:AddHearts(-player:GetHearts())
end

function IllusionModLocal:onEntityTakeDamage(tookDamage)
	local data = Helpers.GetEntityData(tookDamage)
    if not data then return end
	if data.IsIllusion then
		if data.hasWisp then return false end
        --doples always die in one hit, so the hud looks nicer. ideally i'd just get rid of the hud but that doesnt seem possible
        local player = tookDamage:ToPlayer()
       	KillIllusion(player)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, IllusionModLocal.onEntityTakeDamage, EntityType.ENTITY_PLAYER)

function IllusionModLocal:AfterDeath(e)
	if e and e:ToPlayer() then
		if e:ToPlayer():GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B then
			local data = Helpers.GetEntityData(e)
			if data and data.isIllusion then
				Helpers.RemoveEntityData(e)
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, IllusionModLocal.AfterDeath)

function IllusionModLocal:DarkEsau(e)
	if e.SpawnerEntity and e.SpawnerEntity:ToPlayer() then
		local p = e.SpawnerEntity:ToPlayer()
		local d = Helpers.GetEntityData(p)
        if not d then return end
		if d.IsIllusion then
			local s = e:GetSprite().Color
			local color = Color(s.R, s.G, s.B, 0.45,0.518, 0.15, 0.8)
			local s = e:GetSprite()
			s.Color = color
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, IllusionModLocal.DarkEsau, EntityType.ENTITY_DARK_ESAU)

function IllusionModLocal:ClonesControls(entity,hook,action)
	if entity ~= nil and entity.Type == EntityType.ENTITY_PLAYER and TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "IllusionClonesPlaceBombs") == 1 then
		local p = entity:ToPlayer()
		local d = Helpers.GetEntityData(p)
        if not d then return end
		if d.IsIllusion then
			if (hook == InputHook.GET_ACTION_VALUE or hook == InputHook.IS_ACTION_PRESSED) and p:GetSprite():IsPlaying("Appear") then
				return hook == InputHook.GET_ACTION_VALUE and 0 or false
			end
			if hook == InputHook.IS_ACTION_TRIGGERED and (action == ButtonAction.ACTION_BOMB or action == ButtonAction.ACTION_PILLCARD or
			action == ButtonAction.ACTION_ITEM or p:GetSprite():IsPlaying("Appear")) then
				return false
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_INPUT_ACTION, IllusionModLocal.ClonesControls)