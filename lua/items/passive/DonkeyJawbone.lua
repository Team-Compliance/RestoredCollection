local DonkeyJawbone = {}
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

function DonkeyJawbone:PostNewRoom()
	for _, player in pairs(Helpers.GetPlayers()) do
		local data = Helpers.GetData(player)
		data.ExtraSpins = 0 --just in case it gets interrupted
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DonkeyJawbone.PostNewRoom)

function DonkeyJawbone:PlayerHurt(TookDamage, DamageAmount, DamageFlags, DamageSource, DamageCountdownFrames)
	local player = TookDamage:ToPlayer()
	local data = Helpers.GetData(player)
	if player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE) then
		--[[if player:HasCollectible(CollectibleType.COLLECTIBLE_20_20) then
			data.ExtraSpins = data.ExtraSpins + 1
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_INNER_EYE) then
			data.ExtraSpins = data.ExtraSpins + 2
		end
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) then
			data.ExtraSpins = data.ExtraSpins + 3
		end]]
		if data.ExtraSpins <= 0 then
			if REPENTOGON then
				local weapon = player:GetWeapon(1)
				local weaponType = weapon:GetWeaponType()
				local multiShotParams = player:GetMultiShotParams(weaponType)
				---@cast multiShotParams MultiShotParams
				data.ExtraSpins = multiShotParams:GetNumTears()
			else
				data.ExtraSpins = data.ExtraSpins + (Helpers.GetEntityData(player).MenorahFlames and Helpers.GetEntityData(player).MenorahFlames or 0)
				local startMax = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_20_20)
				if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE) > 0 then
					startMax = startMax + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_INNER_EYE) + 2 - (startMax > 0 and 1 or 0)
				end
				if player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) > 0 then
					startMax = startMax + player:GetCollectibleNum(CollectibleType.COLLECTIBLE_MUTANT_SPIDER) + 3 - (startMax > 0 and 2 or 0)
				end
				data.ExtraSpins = data.ExtraSpins + startMax
			end
			DonkeyJawbone:SpawnJawbone(player)
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DonkeyJawbone.PlayerHurt, EntityType.ENTITY_PLAYER)

function DonkeyJawbone:JawboneUpdate(jawbone)
	local player = jawbone.Parent:ToPlayer()
	local data = Helpers.GetData(player)
	local blackList = Helpers.GetData(jawbone)
	local sprite = jawbone:GetSprite()

    -- We are going to use this table as a way to make sure enemies are only hurt once in a swing.
    -- This line will either set the hit blacklist to itself, or create one if it doesn't exist.
    blackList.HitBlacklist = blackList.HitBlacklist or {}
	
    -- Handle removing the pipe when the spin is done.
	if sprite:GetFrame() >= 9 and data.ExtraSpins > 0 then
		DonkeyJawbone:ReplaySpin(player, jawbone)
	end
	if sprite:IsFinished("SpinDown") then
		jawbone:Remove()
		return
	end

    -- We're doing a for loop before because the effect is based off of Spirit Sword's anm2.
    -- Spirit Sword's anm2 has two hitboxes with the same name with a different number at the ending, so we use a for loop to avoid repeating code.
	local jawboneDamage = (player.Damage * 8) + 10
	if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_KNIFE) then
		jawboneDamage = (player.Damage * 8) + 16
	end

	if REPENTOGON then
		for i = 1, 2 do
			-- Get the "null capsule", which is the hitbox defined by the null layer in the anm2.
			local capsule = jawbone:GetNullCapsule("Hit" .. i)
			-- Search for all enemies within the capsule.
			for _, enemy in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
				-- Make sure it can be hurt.
				if enemy:IsVulnerableEnemy()
				and enemy:IsActiveEnemy()
				and not blackList.HitBlacklist[GetPtrHash(enemy)] then
					-- Now hurt it.
					enemy:TakeDamage(jawboneDamage, 0, EntityRef(player), 0)
					-- Add it to the blacklist, so it can't be hurt again.
					blackList.HitBlacklist[GetPtrHash(enemy)] = true

					-- Do some fancy effects, while we're at it.
					enemy:BloodExplode()
					enemy:MakeBloodPoof(enemy.Position, nil, 0.5)
					sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
					enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
				end
			end
			for i, entity in pairs(Isaac.FindInCapsule(capsule, EntityPartition.BULLET)) do
				local projectile = entity:ToProjectile()
				if not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
					local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
					local reflectChance = TSIL.Random.GetRandomInt(1, 100)
					
					if reflectChance <= 100 then
						projectile.Velocity = Vector.FromAngle(angle):Resized(10)
						projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
						projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
					else
						projectile:Die()
					end
				end
			end
		end
	else
		local frameDamageRadius = {
			20, 30
		}
		local frameDamageLength = {
			[1] = {29.2308, 23.4836},
			[2] = {34.1594, 35.9157},
			[3] = {37.7159, 42.2447},
			[4] = {44.9325, 46.7905},
			[5] = {44.6154, 55.5766},
			[6] = {44.9326, 53.8462},
			[7] = {37.7159, 53.8242},
			[8] = {34.1594, 46.7905},
			[9] = {29.2308, 43.5414},
			[10] = {29.2308},
			[11] = {29.2308},
			[12] = {29.2308},
		}
		local frameDamageAngle = {
			[1] = {90, 58.40},
			[2] = {144.16, 99.87},
			[3] = {-168.23, 146.89},
			[4] = {-128.08, -170.54},
			[5] = {-90, -131.63},
			[6] = {-51.95, -90},
			[7] = {-11.77, -59.04},
			[8] = {35.84, -9.46},
			[9] = {90, 32},
			[10] = {90},
			[11] = {90},
			[12] = {90},
		}
		if frameDamageAngle[sprite:GetFrame()] then
			local i = sprite:GetFrame()
			for index, _ in ipairs(frameDamageAngle[i]) do
				local position = player.Position + Vector.FromAngle(frameDamageAngle[i][index]):Resized(frameDamageLength[i][index])
				for _, enemy in ipairs(Isaac.FindInRadius(position, frameDamageRadius[index], EntityPartition.ENEMY)) do
					-- Make sure it can be hurt.
					if enemy:IsVulnerableEnemy()
					and enemy:IsActiveEnemy()
					and not blackList.HitBlacklist[GetPtrHash(enemy)] then
						-- Now hurt it.
						enemy:TakeDamage(jawboneDamage, 0, EntityRef(player), 0)
						-- Add it to the blacklist, so it can't be hurt again.
						blackList.HitBlacklist[GetPtrHash(enemy)] = true

						-- Do some fancy effects, while we're at it.
						enemy:BloodExplode()
						--enemy:MakeBloodPoof(enemy.Position, nil, 0.5)
						local eff1 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 3, enemy.Position, Vector.Zero, nil)
						local eff2 = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF04, 4, enemy.Position, Vector.Zero, eff1)
						sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
						enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
					end
				end
				for _, entity in ipairs(Isaac.FindInRadius(position, frameDamageRadius[index], EntityPartition.BULLET)) do
					local projectile = entity:ToProjectile()
					if not projectile:HasProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER) then
						local angle = ((player.Position - projectile.Position) * -1):GetAngleDegrees()
						local reflectChance = TSIL.Random.GetRandomInt(1, 100)
						if reflectChance <= 100 then
							projectile.Velocity = Vector.FromAngle(angle):Resized(10)
							projectile:AddProjectileFlags(ProjectileFlags.CANT_HIT_PLAYER)
							projectile:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES)
						else
							projectile:Die()
						end
					end
				end
			end
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, DonkeyJawbone.JawboneUpdate, RestoredItemsCollection.Enums.Entities.DONKEY_JAWBONE.Variant)

function DonkeyJawbone:SpawnJawbone(player)
	local jawbone = Isaac.Spawn(1000, RestoredItemsCollection.Enums.Entities.DONKEY_JAWBONE.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
	local data = Helpers.GetData(player)
	data.ExtraSpins = math.max(0, data.ExtraSpins - 1)
	jawbone.Parent = player
	jawbone:FollowParent(player)
	
	local sprite = jawbone:GetSprite()

	sprite:Play("SpinDown", true)
	
	sfx:Play(SoundEffect.SOUND_SWORD_SPIN)
end

function DonkeyJawbone:ReplaySpin(player, jawbone)
	local data = Helpers.GetData(player)
	local blackList = Helpers.GetData(jawbone)
	data.ExtraSpins = math.max(0, data.ExtraSpins - 1)
	blackList.HitBlacklist = {}
	local sprite = jawbone:GetSprite()
	sprite:SetFrame(2)
	
	sfx:Play(SoundEffect.SOUND_SWORD_SPIN)
end