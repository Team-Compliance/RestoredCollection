local IllusionModLocal = {}
local game = Game()
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

function IllusionModLocal:onUseBookOfIllusions(_, _, player, flags)
	if REPENTOGON then
		ItemOverlay.Show(RestoredItemsCollection.Enums.GiantBook.BOOK_OF_ILLUSIONS, 0 , player)
	elseif GiantBookAPI then
		GiantBookAPI.playGiantBook("Appear", "Illusions.png", Color(0.2, 0.1, 0.3, 1, 0, 0, 0), Color(0.117, 0.0117, 0.2, 1, 0, 0, 0), Color(0, 0, 0, 0.8, 0, 0, 0), SoundEffect.SOUND_BOOK_PAGE_TURN_12)
	end
	
	sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 1, 0, false, 1)

	IllusionMod:addIllusion(player, true, player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES))

	-- returning any values interrupts any callbacks that come after it
	if flags & UseFlag.USE_NOANIM == 0 then
		player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, "UseItem", "PlayerPickupSparkle")
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_USE_ITEM, IllusionModLocal.onUseBookOfIllusions, RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS)

---@param familiar EntityFamiliar
function IllusionModLocal:OnIllusionWispUpdate(familiar)
	local data = Helpers.GetEntityData(familiar)
	if not data then return end
	if not data.isIllusion and familiar.SubType == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS then
		familiar:Remove()
		return
	end

	local healthRatio = familiar.HitPoints / familiar.MaxHitPoints
	local spriteScale = Vector(0.75, 0.75) + Vector(0.25, 0.25) * healthRatio
	familiar.SpriteScale = spriteScale
end
RestoredItemsCollection:AddCallback(
	ModCallbacks.MC_FAMILIAR_UPDATE,
	IllusionModLocal.OnIllusionWispUpdate,
	FamiliarVariant.WISP
)

---@param entity Entity
function IllusionModLocal:OnIllusionWispRemove(entity)
	local familiar = entity:ToFamiliar()
	if familiar.Variant ~= FamiliarVariant.WISP then return end

	local data = Helpers.GetEntityData(familiar)
	if not data then return end
	if not data.isIllusion then return end

	for i = 0, game:GetNumPlayers() - 1, 1 do
		local player = game:GetPlayer(i)
		local playerIndex = player:GetCollectibleRNG(1):GetSeed()

		if data.illusionId == playerIndex then
			local illusionData = Helpers.GetEntityData(player)
			if illusionData and illusionData.IsIllusion then
				illusionData.hasWisp = false
			end

			player:TakeDamage(2, 0, EntityRef(familiar), -1)
		end
	end
end
RestoredItemsCollection:AddCallback(
	ModCallbacks.MC_POST_ENTITY_REMOVE,
	IllusionModLocal.OnIllusionWispRemove,
	EntityType.ENTITY_FAMILIAR
)

---@param tear EntityTear
function IllusionModLocal:OnTearInit(tear)
	local spawner = tear.SpawnerEntity
	if not spawner then return end

	local familiar = spawner:ToFamiliar()
	if not familiar then return end

	if familiar.Variant ~= FamiliarVariant.WISP then return end

	local data = Helpers.GetEntityData(familiar)
	if not data then return end
	if not data.isIllusion then return end

	tear:Remove()
end
RestoredItemsCollection:AddCallback(
	ModCallbacks.MC_POST_TEAR_INIT,
	IllusionModLocal.OnTearInit
)