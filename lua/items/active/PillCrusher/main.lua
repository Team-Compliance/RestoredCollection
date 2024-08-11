local PillCrusherLocal = {} --So all the callback functions are not in a global
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()
local hud = Game():GetHUD()

local BloomAmount = 0
local blurspeed = 0.07
local ActivateBloom = false

local pillCrusherPathRoot = "lua.items.active.PillCrusher.pill_effects."
--Vanilla pill effects
include(pillCrusherPathRoot.."48HourEnergy")
include(pillCrusherPathRoot.."Addicted")
include(pillCrusherPathRoot.."Amnesia")
include(pillCrusherPathRoot.."BadGas")
include(pillCrusherPathRoot.."BadTrip")
include(pillCrusherPathRoot.."BallsOfSteel")
include(pillCrusherPathRoot.."BombsAreKeys")
include(pillCrusherPathRoot.."ExplosiveDiarrhea")
include(pillCrusherPathRoot.."FriendsTillTheEnd")
include(pillCrusherPathRoot.."FullHealth")
include(pillCrusherPathRoot.."Gulp")
include(pillCrusherPathRoot.."HealthDown")
include(pillCrusherPathRoot.."HealthUp")
include(pillCrusherPathRoot.."Hematemesis")
include(pillCrusherPathRoot.."Horf")
include(pillCrusherPathRoot.."IFoundPills")
include(pillCrusherPathRoot.."ImDrowsy")
include(pillCrusherPathRoot.."ImExcited")
include(pillCrusherPathRoot.."InfestedExclamation")
include(pillCrusherPathRoot.."InfestedQuestion")
include(pillCrusherPathRoot.."Larger")
include(pillCrusherPathRoot.."LemonParty")
include(pillCrusherPathRoot.."LuckDown")
include(pillCrusherPathRoot.."LuckUp")
include(pillCrusherPathRoot.."Paralysis")
include(pillCrusherPathRoot.."Percs")
include(pillCrusherPathRoot.."Pheromones")
include(pillCrusherPathRoot.."PowerPill")
include(pillCrusherPathRoot.."PrettyFly")
include(pillCrusherPathRoot.."Puberty")
include(pillCrusherPathRoot.."QuestionMark")
include(pillCrusherPathRoot.."RangeDown")
include(pillCrusherPathRoot.."RangeUp")
include(pillCrusherPathRoot.."Relax")
include(pillCrusherPathRoot.."RetroVision")
include(pillCrusherPathRoot.."RUAWizard")
include(pillCrusherPathRoot.."SeeForever")
include(pillCrusherPathRoot.."ShotSpeedDown")
include(pillCrusherPathRoot.."ShotSpeedUp")
include(pillCrusherPathRoot.."Smaller")
include(pillCrusherPathRoot.."SomethingsWrong")
include(pillCrusherPathRoot.."SpeedDown")
include(pillCrusherPathRoot.."SpeedUp")
include(pillCrusherPathRoot.."Sunshine")
include(pillCrusherPathRoot.."TearsDown")
include(pillCrusherPathRoot.."TearsUp")
include(pillCrusherPathRoot.."Telepills")
include(pillCrusherPathRoot.."Vurp")
include(pillCrusherPathRoot.."XLax")

--Main mod
local function Lerp(a, b, t)
	return a + (b-a) * 0.2 * t
end


function PillCrusherLocal:BloomShader(shader)
	if shader == "PillCrusherBloom" then
		local params = {
			BloomAmount = BloomAmount / 2,
			Ratio = {BloomAmount / 3, BloomAmount / 2}
		}
		if ActivateBloom == true then
			if BloomAmount >= 2.1 then
				ActivateBloom = false
				blurspeed = 0.01
			else
				BloomAmount = BloomAmount + blurspeed
				blurspeed = Lerp(blurspeed, 0.01, 0.06)
			end
		elseif BloomAmount > 0.1 then
			BloomAmount = BloomAmount - blurspeed
			blurspeed = Lerp(blurspeed, 0.2, 0.08)
		elseif BloomAmount < 0.1 then
			BloomAmount = 0
			blurspeed = 0.07
		end
		return params
	end
end
--RestoredCollection:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, PillCrusherLocal.BloomShader)


---@param rng RNG
---@param player EntityPlayer
function PillCrusherLocal:UsePillCrusher(_, rng, player)
	local truePillColor = player:GetPill(0)
	if truePillColor == 0 then return end

	local pillColorToCheckEffect = truePillColor
	local itemPool = Game():GetItemPool()
	local pillEffect = itemPool:GetPillEffect(pillColorToCheckEffect, player)

	--Fiend folio compatibility bs (ffs why wouldn't they just make it an api)
	if FiendFolio then
		if PillCrusher:IsFiendFolioPill(truePillColor) then
			if truePillColor > PillColor.PILL_GIANT_FLAG then
				pillColorToCheckEffect = FiendFolio.savedata.run.PillCopies[tostring(truePillColor-PillColor.PILL_GIANT_FLAG)]
				pillEffect = itemPool:GetPillEffect(pillColorToCheckEffect, player)
				--FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillColorToCheckEffect)] = true
			else
				pillColorToCheckEffect = FiendFolio.savedata.run.PillCopies[tostring(truePillColor)]
				pillEffect = itemPool:GetPillEffect(pillColorToCheckEffect, player)
				--FiendFolio.savedata.run.IdentifiedRunPills[tostring(pillColorToCheckEffect)] = true
			end
		end
	end

	local showName = itemPool:IsPillIdentified(pillColorToCheckEffect)

	local lastPill = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "LastPillUsed")
	if pillEffect == PillEffect.PILLEFFECT_VURP and lastPill >= 0 then
		pillEffect = lastPill
		TSIL.SaveManager.SetPersistentVariable(RestoredCollection, "LastPillUsed", PillEffect.PILLEFFECT_VURP)
	else
		TSIL.SaveManager.SetPersistentVariable(RestoredCollection, "LastPillUsed", pillEffect)
	end

	local crushedPillEffect = PillCrusher:GetPillCrusherEffect(pillEffect)

	local isGolden = truePillColor == PillColor.PILL_GOLD or truePillColor == (PillColor.PILL_GOLD | PillColor.PILL_GIANT_FLAG)
	local isHorse = truePillColor & PillColor.PILL_GIANT_FLAG == PillColor.PILL_GIANT_FLAG

	if isGolden or pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
		crushedPillEffect, pillEffect = table.unpack(PillCrusher:GetRandomPillCrusherEffect(rng))
	end

	local name
	if not crushedPillEffect then
		name = Isaac.GetItemConfig():GetPillEffect(pillEffect).Name
	else
		if pillEffect == PillEffect.PILLEFFECT_EXPERIMENTAL then
			name = "Experimental Treatment"
		else
			name = crushedPillEffect.name
		end

		crushedPillEffect.func(player, rng, isGolden, isHorse, truePillColor)
	end

	PillCrusher:AddCrushedPillEffectForRoom(pillEffect, isHorse)

	if isHorse then
		sfx:Play(SoundEffect.SOUND_BONE_SNAP)
	else
		sfx:Play(SoundEffect.SOUND_BONE_BREAK)
	end

	--player:UsePill(-1, 1, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
	if REPENTOGON then
		Game():SetBloom(30, 1)
	end
	
	if showName then
		hud:ShowItemText(name, "")
	else
		hud:ShowItemText("???", "")
	end
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, player.Position, Vector.Zero, nil)
	poof.Color = Color(1, 1, 1, 1, 0.5, 0.5, 0.5)
	poof.SpriteScale = Vector(0.6, 0.6)

	if not isGolden or rng:RandomInt(100) < 10 then
		player:SetPill(0, 0)

		if player:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) and rng:RandomInt(100) < 25 then
			local spawningPos = Game():GetRoom():FindFreePickupSpawnPosition(player.Position, 1, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, truePillColor, spawningPos, Vector.Zero, nil)
		end
	end

	local pillCrushingAnim = Sprite()
	pillCrushingAnim:Load("gfx/pillcrusher_active_anim.anm2", true)
	pillCrushingAnim:Play("Idle", true)

	player:AnimatePickup(pillCrushingAnim)
end
RestoredCollection:AddCallback(ModCallbacks.MC_USE_ITEM, PillCrusherLocal.UsePillCrusher, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER)

if REPENTOGON then
	function PillCrusherLocal:AddPill(collectible, charge, firstTime, slot, VarData, player)
		if firstTime and collectible == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER then
			local room = Game():GetRoom()
			local spawningPos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawningPos, Vector.Zero, player):ToPickup()
		end
	end
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, PillCrusherLocal.AddPill)
else
	function PillCrusherLocal:AddPill(player)
		local data = Helpers.GetData(player)
		if not data then return end

		data.pilldrop = data.pilldrop or player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER)

		if data.pilldrop < player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
			local room = Game():GetRoom()
			local spawningPos = room:FindFreePickupSpawnPosition(player.Position, 1, true)
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, spawningPos, Vector.Zero, player):ToPickup()
			data.pilldrop = player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		end
	end
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PillCrusherLocal.AddPill)
end


function PillCrusherLocal:spawnPill(rng, pos)
	local room = Game():GetRoom()
	local spawnposition = room:FindFreePickupSpawnPosition(pos)
	local spawned = false
	for _,player in ipairs(Helpers.GetPlayers()) do
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER) and rng:RandomInt(100) < 15 and not spawned then
			local pill = Isaac.Spawn(5, 70, 0, spawnposition, Vector.Zero, player)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_CONTRACT_FROM_BELOW) then
				Isaac.Spawn(5, 70, pill.SubType, spawnposition, Vector.Zero, player)
			end
			spawned = true
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, PillCrusherLocal.spawnPill)

function PillCrusherLocal:item_effect()
	for _,player in ipairs(Helpers.GetPlayers()) do
		local rng = player:GetCollectibleRNG(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER)
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER) == true and Game():IsGreedMode() == true then
			for _ = 1, 3 do
				Isaac.Spawn(5, 70, 0, player.Position, Vector.FromAngle(TSIL.Random.GetRandomInt(0, 360, rng)):Resized(3), player)
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PillCrusherLocal.item_effect)


function PillCrusherLocal:DefaultWispInit(wisp)
	local player = wisp.Player
	if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER) then
		if wisp.SubType == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER then
			--Wtf is this
			wisp.SubType = CollectibleType.COLLECTIBLE_MOMS_BOTTLE_PILLS
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, PillCrusherLocal.DefaultWispInit, FamiliarVariant.WISP)