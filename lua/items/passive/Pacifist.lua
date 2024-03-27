local Helpers = require("lua.helpers.Helpers")
local PacifistMod = {}
local game = Game()
local sfx = SFXManager()

local SpecialRoomPickups = {
	[RoomType.ROOM_TREASURE] = PickupVariant.PICKUP_LOCKEDCHEST,
	[RoomType.ROOM_SHOP] = PickupVariant.PICKUP_LOCKEDCHEST,
	[RoomType.ROOM_PLANETARIUM] = PickupVariant.PICKUP_LOCKEDCHEST,
	[RoomType.ROOM_DICE] = PickupVariant.PICKUP_LOCKEDCHEST,
	[RoomType.ROOM_CHEST] = PickupVariant.PICKUP_LOCKEDCHEST,

	[RoomType.ROOM_CURSE] = PickupVariant.PICKUP_REDCHEST,
	[RoomType.ROOM_DEVIL] = PickupVariant.PICKUP_REDCHEST,

	[RoomType.ROOM_CHALLENGE] = PickupVariant.PICKUP_BOMBCHEST,

	[RoomType.ROOM_SACRIFICE] = PickupVariant.ROOM_SACRIFICE,

	[RoomType.ROOM_LIBRARY] = PickupVariant.PICKUP_WOODENCHEST,
	[RoomType.ROOM_ISAACS] = PickupVariant.PICKUP_WOODENCHEST,

	[RoomType.ROOM_ANGEL] = PickupVariant.PICKUP_ETERNALCHEST,
}

local HasSelectedPickups = false
local PickupsToSpawn = {}

local function GetPacifistLevel()
	local level = game:GetLevel()
	local pacifistLevels = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "PacifistLevels")
	for _, pacifistLevel in ipairs(pacifistLevels) do
		if pacifistLevel.stage == level:GetStage() and
		pacifistLevel.ascent == level:IsAscent() then
			return pacifistLevel
		end
	end

	pacifistLevels[#pacifistLevels+1] = {
		stage = level:GetStage(),
		ascent = level:IsAscent()
	}

	return pacifistLevels[#pacifistLevels]
end


function PacifistMod:PacifistEffect(player)
	if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST) then return end
	if HasSelectedPickups then return end
	local sprite = player:GetSprite()
	if not sprite:IsPlaying("Trapdoor") then return end

	HasSelectedPickups = true

	local level = game:GetLevel()
	local rooms = level:GetRooms()

	for i = 0, rooms.Size - 1 do
		local roomDesc = rooms:Get(i)
		local roomData = roomDesc.Data
		local roomType = roomData.Type

		local pickupToSpawn = SpecialRoomPickups[roomType]

		if (roomType == RoomType.ROOM_SECRET or roomType == RoomType.ROOM_SUPERSECRET or
		roomType == RoomType.ROOM_ULTRASECRET) and roomDesc.DisplayFlags > 0 then
			pickupToSpawn = PickupVariant.PICKUP_OLDCHEST
		end

		if not pickupToSpawn then
			pickupToSpawn = PickupVariant.PICKUP_NULL
		end

		if not roomDesc.Clear then
			PickupsToSpawn[#PickupsToSpawn+1] = pickupToSpawn
		end
	end

	local pacifistLevel = GetPacifistLevel()

	if pacifistLevel.HasSpawnedAngel then
		local roomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)

		if not roomDesc.Clear then
			PickupsToSpawn[#PickupsToSpawn+1] = PickupVariant.PICKUP_ETERNALCHEST
		end
	end

	if pacifistLevel.HasSpawnedDevil then
		local roomDesc = level:GetRoomByIdx(GridRooms.ROOM_DEVIL_IDX)

		if not roomDesc.Clear then
			PickupsToSpawn[#PickupsToSpawn+1] = PickupVariant.PICKUP_REDCHEST
		end
	end

	if pacifistLevel.HasSpawnedCrawlSpace then
		local roomDesc = level:GetRoomByIdx(GridRooms.ROOM_DUNGEON_IDX)

		if not roomDesc.Clear then
			PickupsToSpawn[#PickupsToSpawn+1] = PickupVariant.PICKUP_HAUNTEDCHEST
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PacifistMod.PacifistEffect)


function PacifistMod:OnUpdate()
	local room = game:GetRoom()
	for doorSlot = 0, DoorSlot.NUM_DOOR_SLOTS, 1 do
		---@diagnostic disable-next-line: param-type-mismatch
		local door = room:GetDoor(doorSlot)

		if door then
			local isDealRoom = door.TargetRoomIndex == GridRooms.ROOM_DEVIL_IDX
			local isAngelRoom = door.TargetRoomType == RoomType.ROOM_ANGEL
			local isDevilRoom = door.TargetRoomType == RoomType.ROOM_DEVIL

			if isDealRoom then
				local pacifistLevel = GetPacifistLevel()
				
				if isAngelRoom then
					pacifistLevel.HasSpawnedAngel = true
				end

				if isDevilRoom then
					pacifistLevel.HasSpawnedDevil = true
				end
			end
		end
	end

	for i = 0, room:GetGridSize(), 1 do
		local gridEntity = room:GetGridEntity(i)

		if gridEntity and
		gridEntity:GetType() == GridEntityType.GRID_STAIRS and
		gridEntity:GetVariant() == 0 then
			local pacifistLevel = GetPacifistLevel()
			pacifistLevel.HasSpawnedCrawlSpace = true
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_UPDATE, PacifistMod.OnUpdate)


function PacifistMod:PickupsDrop() -- Spawn pickups every level after pickup
	if #PickupsToSpawn <= 0 then return end

	local pacifistPlayer
	for _, player in ipairs(Helpers.GetPlayers()) do
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST) then
			sfx:Play(SoundEffect.SOUND_THUMBSUP, 1, 0)
			player:AnimateHappy()
			pacifistPlayer = player
		end
	end

	if not pacifistPlayer then return end

	local helperPennies = {}
	for _, pickupVariant in ipairs(PickupsToSpawn) do
		local subtype = ChestSubType.CHEST_CLOSED

		if pickupVariant == PickupVariant.PICKUP_NULL then
			subtype = 2
		end

		local spawningPos = game:GetRoom():FindFreePickupSpawnPosition(pacifistPlayer.Position, 0, true)

		local lightRay = Isaac.Spawn(
			EntityType.ENTITY_EFFECT,
			EffectVariant.CRACK_THE_SKY,
			0,
			spawningPos,
			Vector.Zero,
			pacifistPlayer
		)
		lightRay.Visible = false
		--lightRay:GetSprite():Stop()
		local data = Helpers.GetData(lightRay)
		data.IsPacifistLightRay = true
		data.PickupToSpawn = {variant = pickupVariant, subtype = subtype}
		data.Delay = math.ceil(spawningPos:Distance(pacifistPlayer.Position) / 20)

		--We spawn a temporary penny so the FindFreePickupSpawnPosition function works properly
		helperPennies[#helperPennies+1] = Isaac.Spawn(
			EntityType.ENTITY_PICKUP,
			PickupVariant.PICKUP_COIN,
			CoinSubType.COIN_PENNY,
			spawningPos,
			Vector.Zero,
			nil
		)
	end

	for _, penny in ipairs(helperPennies) do
		penny:Remove()
	end

	PickupsToSpawn = {}
	HasSelectedPickups = false
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, PacifistMod.PickupsDrop)

---@param source EntityRef
function PacifistMod:OnEntityDMG(_, _, _, source)
	local entity = source.Entity

	if not entity then return end
	if entity.Type ~= EntityType.ENTITY_EFFECT then return end
	if entity.Variant ~= EffectVariant.CRACK_THE_SKY then return end

	local data = Helpers.GetData(entity)
	if not data.IsPacifistLightRay then return end

	return false
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, PacifistMod.OnEntityDMG)

---@param effect EntityEffect
function PacifistMod:OnLightRayUpdate(effect)
	local data = Helpers.GetData(effect)
	if not data.IsPacifistLightRay then return end

	local sprite = effect:GetSprite()
	if data.Delay then
		if effect.FrameCount > data.Delay then
			--So they're not visible while the game is paused in the getting up anim
			effect.Visible = true
			sprite:Play(sprite:GetAnimation(), true)
			data.Delay = nil
		end

		return
	end

	if sprite:IsEventTriggered("Hit") then
		local variant = data.PickupToSpawn.variant
		local subtype = data.PickupToSpawn.subtype
		Isaac.Spawn(EntityType.ENTITY_PICKUP, variant, subtype, effect.Position, Vector.Zero, effect)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PacifistMod.OnLightRayUpdate, EffectVariant.CRACK_THE_SKY)