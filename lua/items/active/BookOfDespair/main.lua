local BookOfDespair = {}
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

function BookOfDespair:UseBookOfDespair(_Type, RNG, player, flags, slot, data)
	if flags & UseFlag.USE_CARBATTERY == 0 then
		local tempEffects = player:GetEffects():GetCollectibleEffectNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
		if tempEffects == 0 then
			if REPENTOGON then
				ItemOverlay.Show(RestoredCollection.Enums.GiantBook.BOOK_OF_DESPAIR, 0 , player)
			elseif GiantBookAPI then
				GiantBookAPI.playGiantBook("Appear", "Despair.png", Color(228/255, 228/255, 228/255, 1, 0, 0, 0), Color(228/255, 228/255, 228/255, 153/255, 0, 0, 0), Color(225/255, 225/255, 225/255, 128/255, 0, 0, 0))
			end
		end
		sfx:Play(SoundEffect.SOUND_BOOK_PAGE_TURN_12, 0.8, 0, false, 1)
	end
	
	return true
end

function BookOfDespair:Despair_CacheEval(player, cacheFlag)
	local tempEffects = player:GetEffects():GetCollectibleEffectNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
	if tempEffects > 0 then
		local currentTears = Helpers.ToTearsPerSecond(player.MaxFireDelay)
		local usesMul = 0
		for count = 1, tempEffects do
			usesMul = usesMul + (2 / count)
		end
		local newTears = currentTears * usesMul
		player.MaxFireDelay = math.max(Helpers.ToMaxFireDelay(newTears), -0.75)
	end
end

RestoredCollection:AddCallback(ModCallbacks.MC_USE_ITEM, BookOfDespair.UseBookOfDespair, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BookOfDespair.Despair_CacheEval, CacheFlag.CACHE_FIREDELAY)