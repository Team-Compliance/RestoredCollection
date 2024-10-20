local BlankBombsMod = {}

local BombsInRoom = {}
local RocketsAboutToExplode = {}

local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

---@param bomb Entity
---@return boolean
local function IsBlankBomb(bomb)
	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	if not BombFlagsAPI.HasCustomBombFlag(bomb, "BLANK_BOMB") then return false end

	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then return false end

	return true
end

---@param rocket Entity
---@return boolean
local function IsBlankEpicFetus(rocket)
	if not rocket then return false end
	if rocket.Type ~= EntityType.ENTITY_EFFECT and rocket.Variant ~= EffectVariant.ROCKET then return false end
	rocket = rocket:ToEffect()

	local player = Helpers.GetPlayerFromTear(rocket)
	if not player then return false end
	return Helpers.GetData(rocket).IsBlankRocket or false
end

local function DoBlankDamage(player, player2)
	if player:GetOtherTwin() and GetPtrHash(player:GetOtherTwin()) == GetPtrHash(player2) then
		return false
	end
	return GetPtrHash(player) ~= GetPtrHash(player2)
end

---@param player EntityPlayer
---@param bomb EntityBomb
---@param radius integer
local function DamageFriendlyNonParents(player, bomb, radius)
	for _, player2 in ipairs(Isaac.FindInRadius(bomb.Position, radius, EntityPartition.PLAYER)) do
		player2 = player2:ToPlayer()
		---@cast player2 EntityPlayer
		
		if DoBlankDamage(player, player2) then
			bomb:ClearEntityFlags(EntityFlag.FLAG_FRIENDLY)
			player2:TakeDamage(bomb.ExplosionDamage, DamageFlag.DAMAGE_EXPLOSION, EntityRef(bomb), 30)
			bomb:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
			if not player2:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) then
				local pushDirection = (player2.Position - bomb.Position):Normalized()
				player2:AddVelocity(pushDirection * 10)
			end
		end
	end
end

---@param bomb EntityBomb
local function CanBombInstaDetonate(bomb)
	local wasInRoom = false
	local bombPtr = GetPtrHash(bomb)
	for _, bombInRoom in ipairs(BombsInRoom) do
		if bombPtr == bombInRoom then
			wasInRoom = true
		end
	end

	return not (wasInRoom or bomb.IsFetus or bomb.Variant == BombVariant.BOMB_ROCKET or
	bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA or 
	bomb.Variant == BombVariant.BOMB_THROWABLE or not BombFlagsAPI.HasCustomBombFlag(bomb, "BLANK_BOMB") 
	or Helpers.GetData(bomb).NancyBlank)
end

---@param center Vector
---@param radius number
local function DoBlankEffect(center, radius)
	--Spawn cool explosion effect
	local blankExplosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.BLANK_EXPLOSION_EFFECT.Variant, 0, center, Vector.Zero, nil)
	blankExplosion:GetSprite():Play("Explode", true)
	blankExplosion.DepthOffset = 9999
	blankExplosion.SpriteScale = blankExplosion.SpriteScale * (radius/90)
	blankExplosion.Color = Color(1, 1, 1, math.min(1, radius/90))

	--Do screen wobble
	Game():MakeShockwave(center, .035, .025, 10)

	--Remove projectiles in radius
	for _, projectile in ipairs(Isaac.FindByType(EntityType.ENTITY_PROJECTILE)) do
		projectile = projectile:ToProjectile()

		local realPosition = projectile.Position - Vector(0, projectile.Height)

		if realPosition:DistanceSquared(center) <= (radius * 3) ^ 2 then
			if projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) or
			projectile:HasProjectileFlags(ProjectileFlags.ACID_RED) or
			projectile:HasProjectileFlags(ProjectileFlags.CREEP_BROWN) or
			projectile:HasProjectileFlags(ProjectileFlags.EXPLODE) or
			projectile:HasProjectileFlags(ProjectileFlags.BURST) or
			projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) then
				--If the projectile has any flag that triggers on hit, we need to remove the projectile
				projectile:Remove()
			else
				projectile:Die()
			end
		end
	end

	--Push enemies back
	for _, entity in ipairs(Isaac.FindInRadius(center, radius * 3, EntityPartition.ENEMY)) do
		if entity:IsActiveEnemy(false) and entity:IsVulnerableEnemy() then
			local pushDirection = (entity.Position - center):Normalized()
			entity:AddVelocity(pushDirection * 30)
		end
	end
end

function BlankBombsMod:OnNewRoom()
	BombsInRoom = {}
	for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
		bomb = bomb:ToBomb()

		if IsBlankBomb(bomb) then
			table.insert(BombsInRoom, GetPtrHash(bomb))
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BlankBombsMod.OnNewRoom)


---@param bomb EntityBomb
function BlankBombsMod:OnBombInitLate(bomb)
	if bomb.Variant == BombVariant.BOMB_GIGA then return end
	if Helpers.GetData(bomb).IsBlankBombInstaDetonating then return end

	local player = Helpers.GetPlayerFromTear(bomb)
	local data = Helpers.GetData(bomb)
	if player and not Helpers.GetData(bomb).BombInit then
		local rng = bomb:GetDropRNG()
		local blankChance = player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS) and 
        (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20)

		local nancyChance = player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
		player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10
		and not Helpers.IsItemDisabled(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS)

		if blankChance or nancyChance then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredCollection.Enums.BombVariant.BOMB_BLANK
				end
			end
			BombFlagsAPI.AddCustomBombFlag(bomb, "BLANK_BOMB")
			data.NancyBlank = not blankChance and nancyChance
		end
	end

	--Instantly explode if player isn't pressing ctrl
	if not CanBombInstaDetonate(bomb) then return end

    if not player then return end
	local controller = player.ControllerIndex

	if not Input.IsActionPressed(ButtonAction.ACTION_DROP, controller) then

		bomb.ExplosionDamage = bomb.ExplosionDamage / 2
		if player:HasGoldenBomb() then bomb.ExplosionDamage = bomb.ExplosionDamage / 2 end
		bomb:AddEntityFlags(EntityFlag.FLAG_FRIENDLY)
		DamageFriendlyNonParents(player, bomb, Helpers.GetBombExplosionRadius(bomb) * 3)
		bomb:SetExplosionCountdown(0)

		Helpers.GetData(bomb).IsBlankBombInstaDetonating = true

		bomb:Update()
	end
end

---@param bomb EntityBomb
function BlankBombsMod:BombUpdate(bomb)

	if bomb.FrameCount == 1 then
		BlankBombsMod:OnBombInitLate(bomb)
		if bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_BLANK then
            local sprite = bomb:GetSprite()
            local anim = sprite:GetAnimation()
            local file = sprite:GetFilename()
            sprite:Load("gfx/items/pick ups/bombs/blank"..file:sub(file:len()-5), true)
            sprite:Play(anim, true)
        end
	end

	if not IsBlankBomb(bomb) then return end

	local sprite = bomb:GetSprite()
	if bomb.Variant == BombVariant.BOMB_ROCKET and BombFlagsAPI.HasCustomBombFlag(bomb, "BLANK_BOMB") then
		local spritesheetPreffix = ""
		local spritesheetSuffix = ""
		spritesheetPreffix = "rocket_"
		
		---@diagnostic disable-next-line: param-type-mismatch
		if bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
			spritesheetSuffix = "_gold"
		end
	
		sprite:ReplaceSpritesheet(0, "gfx/items/pick ups/bombs/costumes/" .. spritesheetPreffix .. "blank_bombs" .. spritesheetSuffix .. ".png")
		sprite:LoadGraphics()
	end
	if sprite:IsPlaying("Explode") or Helpers.GetData(bomb).IsBlankBombInstaDetonating then
        ---@diagnostic disable-next-line: param-type-mismatch
		if bomb:HasTearFlags(TearFlags.TEAR_SCATTER_BOMB) then
			for _, scatterBomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
				if scatterBomb.FrameCount == 0 then
					table.insert(BombsInRoom, GetPtrHash(scatterBomb))
				end
			end
		end

		local explosionRadius = Helpers.GetBombExplosionRadius(bomb)
		
        ---@diagnostic disable-next-line: param-type-mismatch
		if bomb:HasTearFlags(TearFlags.TEAR_GIGA_BOMB) then
			explosionRadius = 99999
		end
		DoBlankEffect(bomb.Position, explosionRadius)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, BlankBombsMod.BombUpdate)


function BlankBombsMod:OnMonstroUpdate(monstro)
	if monstro:GetData().IsAbusedMonstro then

		sfx:Stop(SoundEffect.SOUND_FORESTBOSS_STOMPS)

		for _, effect in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.POOF02)) do
			if effect.FrameCount == 0 then
				effect:Remove()
			end
		end

		monstro:Remove()
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_NPC_UPDATE, BlankBombsMod.OnMonstroUpdate, EntityType.ENTITY_MONSTRO)


---@param rocket EntityEffect
function BlankBombsMod:BlankRocketInit(rocket)
	local player = rocket.SpawnerEntity
	if not player then return end
	if not player:ToPlayer() then return end
	local proc = false
	player = player:ToPlayer()
	if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS) and
	rocket:GetDropRNG():RandomInt(100) < 120
	or player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
	player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 5
	and not Helpers.IsItemDisabled(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS) then
		Helpers.GetData(rocket).IsBlankRocket = true
	end

end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BlankBombsMod.BlankRocketInit, EffectVariant.ROCKET)

function BlankBombsMod:BlankRocketExplode(rocket)
    if rocket.Type == EntityType.ENTITY_EFFECT and rocket.Variant == EffectVariant.ROCKET then
        local player = Helpers.GetPlayerFromTear(rocket)
        if not player then return end
        local data = Helpers.GetData(rocket)
        if data.IsBlankRocket then
			DoBlankEffect(rocket.Position, 90)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, BlankBombsMod.BlankRocketExplode)

---@param effect EntityEffect
function BlankBombsMod:OnBlankExplosionUpdate(effect)
	local spr = effect:GetSprite()

	if spr:IsFinished("Explode") then
		effect:Remove()
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BlankBombsMod.OnBlankExplosionUpdate, RestoredCollection.Enums.Entities.BLANK_EXPLOSION_EFFECT.Variant)

---@param entity Entity
---@param source EntityRef
function BlankBombsMod:OnPlayerDamage(entity, _, _, source)
	local bomb = source.Entity
	if not bomb then return end
	if bomb:ToBomb() and not IsBlankBomb(bomb) then return end
	if bomb:ToEffect() and not IsBlankEpicFetus(bomb) then return end
	local bombPlayer = Helpers.GetPlayerFromTear(bomb)
	local player = entity:ToPlayer()

    if not bombPlayer then return end

	if GetPtrHash(player) == GetPtrHash(bombPlayer) then
		return false
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlankBombsMod.OnPlayerDamage, EntityType.ENTITY_PLAYER)

---@param locust EntityFamiliar
---@param collider Entity
function BlankBombsMod:OnLocustCollision(locust, collider)
	if locust.SubType ~= RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS then return end
	if collider.Type ~= EntityType.ENTITY_PROJECTILE then return end

	local projectile = collider:ToProjectile()

	if projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) or
	projectile:HasProjectileFlags(ProjectileFlags.ACID_RED) or
	projectile:HasProjectileFlags(ProjectileFlags.CREEP_BROWN) or
	projectile:HasProjectileFlags(ProjectileFlags.EXPLODE) or
	projectile:HasProjectileFlags(ProjectileFlags.BURST) or
	projectile:HasProjectileFlags(ProjectileFlags.ACID_GREEN) then
		--If the projectile has any flag that triggers on hit, we need to remove the projectile
		projectile:Remove()
	else
		projectile:Die()
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, BlankBombsMod.OnLocustCollision, FamiliarVariant.ABYSS_LOCUST)

RestoredCollection:AddCallback("ON_EDITH_STOMP_EXPLOSION", function(_, player, bombDamage, radius)
	DoBlankEffect(player.Position, radius)
end, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS)