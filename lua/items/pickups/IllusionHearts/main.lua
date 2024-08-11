local IllusionModLocal = {} --For local functions, so other mods don't have access to these
local game = Game()
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

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

function IllusionModLocal:onEntityTakeDamage(tookDamage)
	local data = Helpers.GetEntityData(tookDamage)
    if not data then return end
	if data.IsIllusion then
		if data.hasWisp then return false end
        --doples always die in one hit, so the hud looks nicer. ideally i'd just get rid of the hud but that doesnt seem possible
        local player = tookDamage:ToPlayer()
		IllusionMod.KillIllusion(player)
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

function IllusionModLocal:Familiar(e)
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
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, IllusionModLocal.Familiar)

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