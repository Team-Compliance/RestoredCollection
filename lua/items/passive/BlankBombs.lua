local BlankBombsMod = {}

local BombsInRoom = {}
local RocketsAboutToExplode = {}

local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

---@param bomb Entity
---@return boolean
local function IsBlankBomb(bomb)
	if not bomb then return false end
	if bomb.Type ~= EntityType.ENTITY_BOMB then return false end
	bomb = bomb:ToBomb()
	local data = Helpers.GetData(bomb)
	if not data.isBlankBomb then return false end

	local player = Helpers.GetPlayerFromTear(bomb)
	if not player then return false end

	return true
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
	bomb.Variant == BombVariant.BOMB_GIGA or bomb.Variant == BombVariant.BOMB_ROCKET_GIGA)
end


---@param center Vector
---@param radius number
local function DoBlankEffect(center, radius)
	--Spawn cool explosion effect
	local blankExplosion = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredItemsCollection.Enums.Entities.BLANK_EXPLOSION_EFFECT.Variant, 0, center, Vector.Zero, nil)
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

function BlankBombsMod:BombInit(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local data = Helpers.GetData(bomb)
		if player:HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS) then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredItemsCollection.Enums.BombVariant.BOMB_BLANK
				end
			end
			data.isBlankBomb = true
		elseif player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS) and
		player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_NANCY_BOMBS):RandomInt(100) < 10 then
			data.isBlankBomb = true
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, BlankBombsMod.BombInit)

function BlankBombsMod:OnNewRoom()
	BombsInRoom = {}
	for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
		bomb = bomb:ToBomb()

		if IsBlankBomb(bomb) then
			table.insert(BombsInRoom, GetPtrHash(bomb))
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BlankBombsMod.OnNewRoom)


---@param bomb EntityBomb
function BlankBombsMod:OnBombInitLate(bomb)
	if bomb.Variant == BombVariant.BOMB_GIGA then return end
	if Helpers.GetData(bomb).IsBlankBombInstaDetonating then return end


	local sprite = bomb:GetSprite()
	if bomb.Variant == BombVariant.BOMB_ROCKET then
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

	--Instantly explode if player isn't pressing ctrl
	if not CanBombInstaDetonate(bomb) then return end

	local player = Helpers.GetPlayerFromTear(bomb)
    if not player then return end
	local controller = player.ControllerIndex

	if not Input.IsActionPressed(ButtonAction.ACTION_DROP, controller) then
		if not player:HasEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK) then
			player:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
			player:GetData().AddNoKnockBackFlag = 2

			local holyMantleNum = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
			player:GetData().AddHolyMantles = holyMantleNum
			player:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, holyMantleNum)
		end

		if player.Parent and player.Parent.Type == EntityType.ENTITY_PLAYER then
			local playerParent = player.Parent:ToPlayer()
			playerParent:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
			playerParent:GetData().AddNoKnockBackFlag = 2

			local holyMantleNum = playerParent:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
			playerParent:GetData().AddHolyMantles = holyMantleNum
			playerParent:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, holyMantleNum)
		end

		local playerIndex = Helpers.GetPlayerIndex(player)
		for i = 0, Game():GetNumPlayers() - 1, 1 do
			local otherPlayer = Game():GetPlayer(i)

			if otherPlayer.Parent and otherPlayer.Parent.Type == EntityType.ENTITY_PLAYER then
				local otherPlayerParentIndex = Helpers.GetPlayerIndex(otherPlayer.Parent:ToPlayer())

				if playerIndex == otherPlayerParentIndex then
					otherPlayer:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)
					otherPlayer:GetData().AddNoKnockBackFlag = 2

					local holyMantleNum = otherPlayer:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE)
					otherPlayer:GetData().AddHolyMantles = holyMantleNum
					otherPlayer:GetEffects():RemoveCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, holyMantleNum)
				end
			end
		end

		bomb.ExplosionDamage = bomb.ExplosionDamage / 2
		if player:HasGoldenBomb() then bomb.ExplosionDamage = bomb.ExplosionDamage / 2 end
		bomb:SetExplosionCountdown(0)

		Helpers.GetData(bomb).IsBlankBombInstaDetonating = true

		bomb:Update()
	end
end


---@param bomb EntityBomb
function BlankBombsMod:BombUpdate(bomb)
	if not IsBlankBomb(bomb) then return end

	if bomb.FrameCount == 1 then
		BlankBombsMod:OnBombInitLate(bomb)
	end

	local sprite = bomb:GetSprite()
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
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, BlankBombsMod.BombUpdate)


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
RestoredItemsCollection:AddCallback(ModCallbacks.MC_NPC_UPDATE, BlankBombsMod.OnMonstroUpdate, EntityType.ENTITY_MONSTRO)


---@param rocket EntityEffect
function BlankBombsMod:OnEpicFetusRocketUpdate(rocket)
	local player = rocket.SpawnerEntity
	if not player then return end
	if not player:ToPlayer() then return end
	if not player:ToPlayer():HasCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS) then return end

	if rocket.Timeout ~= 0 then return end

	local ptrHash = GetPtrHash(rocket)

	local isGonnaExplode = false

	for i, otherPtr in ipairs(RocketsAboutToExplode) do
		if ptrHash == otherPtr then
			table.remove(RocketsAboutToExplode, i)
			isGonnaExplode = true
		end
	end

	if isGonnaExplode then
		DoBlankEffect(rocket.Position, 90)
	else
		table.insert(RocketsAboutToExplode, ptrHash)
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BlankBombsMod.OnEpicFetusRocketUpdate, EffectVariant.ROCKET)


---@param entity Entity
---@param source EntityRef
function BlankBombsMod:OnPlayerDamage(entity, _, _, source)
	local bomb = source.Entity
	if not IsBlankBomb(bomb) then return end

	local bombPlayer = Helpers.GetPlayerFromTear(bomb)
	local player = entity:ToPlayer()

    if not bombPlayer then return end

	local playerIndex = Helpers.GetPlayerIndex(player)
	local bombPlayerIndex = Helpers.GetPlayerIndex(bombPlayer)
	local parentIndex
	local bombParentIndex

	if player.Parent and player.Parent.Type == EntityType.ENTITY_PLAYER then
		parentIndex = Helpers.GetPlayerIndex(player.Parent:ToPlayer())
	end

	if bombPlayer.Parent and bombPlayer.Parent.Type == EntityType.ENTITY_PLAYER then
		bombParentIndex = Helpers.GetPlayerIndex(bombPlayer.Parent:ToPlayer())
	end

	if playerIndex == bombPlayerIndex or
	(parentIndex and parentIndex == bombPlayerIndex) or
	(bombParentIndex and playerIndex == bombParentIndex) then
		return false
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BlankBombsMod.OnPlayerDamage, EntityType.ENTITY_PLAYER)


---@param player EntityPlayer
function BlankBombsMod:OnPlayerUpdate(player)
	if player:GetData().AddHolyMantles then
		local holyMantleNum = player:GetData().AddHolyMantles
		player:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, holyMantleNum)
		player:GetData().AddHolyMantles = nil
	end

	if not player:GetData().AddNoKnockBackFlag then return end

	player:AddEntityFlags(EntityFlag.FLAG_NO_KNOCKBACK)

	player:GetData().AddNoKnockBackFlag = player:GetData().AddNoKnockBackFlag - 1

	if player:GetData().AddNoKnockBackFlag == 0 then
		player:GetData().AddNoKnockBackFlag = nil
		if player:GetData().RemoveHostHat then
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_HOST_HAT)
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BlankBombsMod.OnPlayerUpdate)


---@param effect EntityEffect
function BlankBombsMod:OnBlankExplosionUpdate(effect)
	local spr = effect:GetSprite()

	if spr:IsFinished("Explode") then
		effect:Remove()
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, BlankBombsMod.OnBlankExplosionUpdate, RestoredItemsCollection.Enums.Entities.BLANK_EXPLOSION_EFFECT.Variant)


---@param locust EntityFamiliar
---@param collider Entity
function BlankBombsMod:OnLocustCollision(locust, collider)
	if locust.SubType ~= RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS then return end
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
RestoredItemsCollection:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, BlankBombsMod.OnLocustCollision, FamiliarVariant.ABYSS_LOCUST)