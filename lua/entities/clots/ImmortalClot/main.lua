local ImmortalClotLocal = {}
local sfx = SFXManager()

function ImmortalClotLocal:ClotHeal()
	local playsfx = false
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY, 20)) do
		entity = entity:ToFamiliar()
		if entity.HitPoints > 5 then
			local healed = 0
			for _, entity2 in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY)) do
				entity2 = entity2:ToFamiliar()
				if not entity2:GetData().Healed 
				and GetPtrHash(entity2.Player) == GetPtrHash(entity.Player) 
				and entity2.HitPoints < entity2.MaxHitPoints then
					if entity2.SubType == 0 then
						entity2.HitPoints = entity2.MaxHitPoints
					elseif entity2.SubType ~= 20 then
						entity2.HitPoints = entity2.HitPoints + 2
					end
					local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.IMMORTAL_HEART_CHARGE.Variant, 0, entity2.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
					ImmortalEffect:GetSprite().Offset = Vector(0, -10)
					entity2:GetData().Healed = true
					if not sfx:IsPlaying(RestoredCollection.Enums.SFX.Hearts.IMMORTAL_PICKUP) then
						playsfx = true
					end
				end
			end
			if entity:GetData().RC_HP < entity.MaxHitPoints then
				entity:GetData().RC_HP = entity:GetData().RC_HP + 1 / (1 + #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY))
				playsfx = true
			end
		else
			entity:GetData().RC_HP = entity:GetData().RC_HP + 2
		end
		local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.IMMORTAL_HEART_CHARGE.Variant, 0, entity.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
		ImmortalEffect:GetSprite().Offset = Vector(0, -10)
		ImmortalEffect:GetSprite().Offset = Vector(0, -10)
		
	end
	if playsfx then
		sfx:Play(RestoredCollection.Enums.SFX.Hearts.IMMORTAL_PICKUP, 1, 0, false, 1.4)
	end
	for _, entity in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY)) do
		entity = entity:ToFamiliar()
		if entity:GetData().Healed then
			entity:GetData().Healed = nil
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ImmortalClotLocal.ClotHeal)
