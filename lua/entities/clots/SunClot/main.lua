local SunClotLocal = {}
local sfx = SFXManager()

---@param clot Entity
function SunClotLocal:SunClotDeath(clot)
	if clot.Variant == FamiliarVariant.BLOOD_BABY and clot.SubType == 30 then
		local player = clot:ToFamiliar().Player
		for slot = 0,2 do
			if player:GetActiveItem(slot) ~= nil and player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_ALABASTER_BOX then
				local itemConfig = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot))
				if itemConfig and itemConfig.ChargeType ~= 2 then
					local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
					local battery = itemConfig.MaxCharges * (player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1)
					if charge < battery then
						if itemConfig.ChargeType == 1 then
							player:FullCharge(slot)
						else
							--player:SetActiveCharge(charge + 1, slot)
							player:AddActiveCharge(1, slot, true, true, true)
							Game():GetHUD():FlashChargeBar(player, slot)
						end
						sfx:Play(RestoredCollection.Enums.SFX.Hearts.SUN_PICKUP, 1, 0)
						local BatteryEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BATTERY, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
						BatteryEffect:GetSprite().Offset = Vector(0, -15)
						break
					end
				end
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, SunClotLocal.SunClotDeath, EntityType.ENTITY_FAMILIAR)