local Helpers = RestoredCollection.Helpers
local localversion = 1.0
local game = Game()
local hud = game:GetHUD()

local function load(data)
	IllusionMod = RegisterMod("Illusion Hearts API", 1)
	IllusionMod.Version = localversion
    IllusionMod.Loaded = false

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

	local ForbiddenCharacters = {

	}

	if data ~= nil then
		TransformationItems = data.TransformationItems or TransformationItems
		ForbiddenItems = data.ForbiddenItems or ForbiddenItems
		ForbiddenTrinkets = data.ForbiddenTrinkets or ForbiddenTrinkets
		ForbiddenPCombos = data.ForbiddenPCombos or ForbiddenPCombos
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

	local function ChangeCharacter(pType)
		for _,v in ipairs(ForbiddenCharacters) do
			if v.PlayerType and v.PlayerType == pType then
				if v.PlayerTypeToChange then
					return v.PlayerTypeToChange
				end
			end
		end
		return pType
	end
	
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
						itemCollectible.Tags & ItemConfig.TAG_QUEST ~= ItemConfig.TAG_QUEST and 
						not itemCollectible:HasCustomTag("revive") and 
						not itemCollectible:HasCustomTag("reviveeffect") then
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
						if not illusionPlayer:HasTrinket(id) and player:HasTrinket(id) and
						not itemTrinket:HasCustomTag("revive") and 
						not itemTrinket:HasCustomTag("reviveeffect") then
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
	
		if illusionPlayer:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
			illusionPlayer:AddBoneHearts(1)
		else
			illusionPlayer:AddMaxHearts(2)
		end
		
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

	function IllusionMod.AddForbiddenItem(i)
		table.insert(ForbiddenItems,i)
	end
	
	function IllusionMod.AddForbiddenTrinket(i)
		table.insert(ForbiddenTrinkets,i)
	end
	
	function IllusionMod.AddForbiddenCharItem(type, i)
		table.insert(ForbiddenPCombos,{PlayerType = type, Item = i})
	end

	function IllusionMod.AddForbiddenChar(type, changeType)
		table.insert(ForbiddenCharacters,{PlayerType = type, PlayerTypeToChange = changeType})
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
		playerType = ChangeCharacter(playerType)
		if (TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "PerfectIllusion") == 2
		or playerType < 41) then
			illusionPlayer:ChangePlayerType(playerType)
		else
			illusionPlayer:ChangePlayerType(PlayerType.PLAYER_ISAAC)
		end
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

	---@param illusionPlayer EntityPlayer
	function IllusionMod.KillIllusion(illusionPlayer, die)
		if die then
			illusionPlayer:Die()
		else
			illusionPlayer:Kill()
		end

		illusionPlayer:AddMaxHearts(-illusionPlayer:GetMaxHearts())
		illusionPlayer:AddSoulHearts(-illusionPlayer:GetSoulHearts())
		illusionPlayer:AddBoneHearts(-illusionPlayer:GetBoneHearts())
		illusionPlayer:AddGoldenHearts(-illusionPlayer:GetGoldenHearts())
		illusionPlayer:AddEternalHearts(-illusionPlayer:GetEternalHearts())
		illusionPlayer:AddHearts(-illusionPlayer:GetHearts())
	end

	function IllusionMod.GetTablesData()
		return {TransformationItems = TransformationItems, ForbiddenItems = ForbiddenItems, ForbiddenTrinkets = ForbiddenTrinkets, ForbiddenPCombos = ForbiddenPCombos}
	end

	function IllusionMod:ModReset()
        IllusionMod.Loaded = false
    end
    IllusionMod:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, IllusionMod.ModReset)

	if RedBaby then
		IllusionMod.AddForbiddenChar(RedBaby.enums.PlayerType.RED_BABY_A, PlayerType.PLAYER_BLUEBABY)
		IllusionMod.AddForbiddenItem(RedBaby.enums.CollectibleType.REDBABY_HEART)
	end

	print("[".. IllusionMod.Name .."]", "is loaded. Version "..IllusionMod.Version)
	IllusionMod.Loaded = true
end

if IllusionMod then
	if IllusionMod.Version < localversion or not IllusionMod.Loaded then
		if not IllusionMod.Loaded then
			print("Reloading [".. IllusionMod.Name .."]")
		else
			print("[".. IllusionMod.Name .."]", " found old script V" .. IllusionMod.Version .. ", found new script V" .. localversion .. ". replacing...")
		end
		local data = IllusionMod.GetTablesData()
		IllusionMod = nil
		load(data)
	end
elseif not IllusionMod then
	load()
end