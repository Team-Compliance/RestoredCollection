local CheckedMateMod = {}
local game = Game()
local Helpers = require("lua.helpers.Helpers")

local checkedMateDesc = Isaac.GetItemConfig():GetCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE)
local sfx = SFXManager()

-- Main code
local Settings = {
	Cooldown = 15,
	Damage = 20,
	SameSpaceMultiplier = 2,
	BFFmultiplier = 2,
	BFFmoves = 7,
	MaxRange = 20, -- In tiles
}

local States = {
	Idle = 0,
	Jump = 1,
	Moving = 2,
	Land = 3
}

local SewingMachineJumpCrownOffsets = {
	0,
	-1,
	-1,
	-2,
	-2,
	-3,
	-3,
	-3,
	10,
	10,
	20,
	30,
	32,
	36,
	37,
	38,
	38
}

local SewingMachineLandCrownOffsets = {
	46,
	47,
	48,
	49,
	50,
	30,
	20,
	16,
	10,
	-6,
	-6,
	-6,
	-6,
	-6,
	-6,
	-5,
	-4,
	-3
	-3,
	-2,
	-2
	-1,
	0,
	0
}


if Sewn_API then
	Sewn_API:MakeFamiliarAvailable(RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE)
end


local function ShouldGetNewTargetPosition(entity)
	local data = entity:GetData()
	local room = game:GetRoom()

	return (
		not data.targetGridPosition or
		data.targetGridPosition:Distance(entity.Position) ~= 5 or
		room:GetGridCollisionAtPos(data.targetGridPosition) ~= GridCollisionClass.COLLISION_NONE
	)
end

function CheckedMateMod.GridPathfind(entity, targetPosition, speedLimit)
	local data = entity:GetData()

	if ShouldGetNewTargetPosition(entity) then
		local room = game:GetRoom()
		local entityPosition = Helpers.GridAlignPosition(entity.Position)
		local targetPosition = Helpers.GridAlignPosition(targetPosition)

		local loopingPositions = {targetPosition}
		local indexedGrids = {}

		local index = 0
		while #loopingPositions > 0 do
			local temporaryLoop = {}

			for _, position in pairs(loopingPositions) do
				if room:IsPositionInRoom(position, 0) then
					if room:GetGridCollisionAtPos(position) == GridCollisionClass.COLLISION_NONE or index == 0 then
						local gridIndex = room:GetGridIndex(position)
						if not indexedGrids[gridIndex] then
							indexedGrids[gridIndex] = index

							for i = 1, 8 do
								table.insert(temporaryLoop, position + Vector(40, 0):Rotated(i * 45))
							end
						end
					end
				end
			end
			
			index = index + 1
			loopingPositions = temporaryLoop
		end

		local entityIndex = room:GetGridIndex(entityPosition)
		local index = indexedGrids[entityIndex] or 99999
		local choice = entityPosition

		for i = 1, 8 do
			local position = entityPosition + Vector(40, 0):Rotated(i * 45)
			local positionIndex = room:GetGridIndex(position)
			local value = indexedGrids[positionIndex]

			if value and value <= index then
				index = value
				choice = position
			end
		end

		data.targetGridPosition = choice
	end
end


function CheckedMateMod:checkedMateInit(entity)
	local room = game:GetRoom()
	entity.Position = room:GetGridPosition(room:GetGridIndex(entity.Position))

	entity.State = States.Idle
	entity.FireCooldown = Settings.Cooldown -- Fire cooldown is the move cooldown
	entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	entity.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end
RestoredCollection:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, CheckedMateMod.checkedMateInit, RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant)


---@param entity EntityFamiliar
function CheckedMateMod:checkedMateUpdate(entity)
	local sprite = entity:GetSprite()
	local player = entity.Player
	local room = game:GetRoom()
	local bff = entity.Player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS)
	local data = entity:GetData()


	if entity:IsFrame(2, 0) then
		local suffix = ""
		if bff == true then
			suffix = "_bffs"
		end
		for i = 0, sprite:GetLayerCount() do
			sprite:ReplaceSpritesheet(i, "gfx/familiar/checked_mate" .. suffix .. ".png")
		end
		sprite:LoadGraphics()
	end

	entity.Velocity = Vector.Zero


	-- Cooldown
	if entity.State == States.Idle then
		if not sprite:IsPlaying("Idle") then
			sprite:Play("Idle", true)
		end

		if entity.FireCooldown <= 0 then
			if player and player:HasTrinket(TrinketType.TRINKET_RC_REMOTE) then
				local movementDirection = player:GetMovementDirection()
				local controllerIndex = player.ControllerIndex
				local isPressingCtrl = Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex)

				if movementDirection ~= Direction.NO_DIRECTION and not isPressingCtrl then
					entity.State = States.Jump

					if not entity.Child then
						local target = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, Vector.Zero, Vector.Zero, nil)
						target.Visible = false
						entity.Child = target
					end

					local movementInput = player:GetMovementInput()
					movementInput:Resize(40)

					entity.Child.Position = room:GetGridPosition(room:GetClampedGridIndex(entity.Position + movementInput))
				end
			else
				entity.State = States.Jump
			end
		else
			entity.FireCooldown = entity.FireCooldown - 1
		end


	-- Jump
	elseif entity.State == States.Jump then
		if not sprite:IsPlaying("Jump") then
			sprite:Play("Jump", true)
		end

		if Sewn_API then
			Sewn_API:AddCrownOffset(entity, Vector(0, SewingMachineJumpCrownOffsets[sprite:GetFrame()+1]))
		end

		if sprite:IsEventTriggered("Jump") then
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			entity.GridCollisionClass = GridCollisionClass.COLLISION_NONE
			sfx:Play(SoundEffect.SOUND_SCAMPER, 0.9)

		elseif sprite:IsEventTriggered("Move") then
			entity.State = States.Moving

			entity.Keys = 0
			-- Amount of moves it can do
			entity.Coins = 1
			if bff == true then
				entity.Coins = Settings.BFFmoves
			end

			if player and player:HasTrinket(TrinketType.TRINKET_RC_REMOTE) then
				entity.Target = entity.Child
			else
				entity:PickEnemyTarget(Settings.MaxRange * 40, 0, 1, Vector.Zero, 0)
			end

			if entity.Target == nil then
				entity.Target = entity.Player
			end
			
			if entity.Target then
				CheckedMateMod.GridPathfind(entity, entity.Target.Position, 3)
			end
			--entity.TargetPosition = room:GetGridPosition(room:GetGridIndex(entity.Position + ((entity.Target.Position - entity.Position):Normalized() * 40)))

			-- Get clamped angle to go in with BFFs extra steps
			entity.OrbitAngleOffset = (entity.Position - data.targetGridPosition):GetAngleDegrees()
			if entity.OrbitAngleOffset >= -22.5 and entity.OrbitAngleOffset <= 22.5 then
				entity.OrbitAngleOffset = 0
			elseif entity.OrbitAngleOffset > 22.5 and entity.OrbitAngleOffset < 67.5 then
				entity.OrbitAngleOffset = 45
			elseif entity.OrbitAngleOffset >= 67.5 and entity.OrbitAngleOffset <= 112.5 then
				entity.OrbitAngleOffset = 90
			elseif entity.OrbitAngleOffset > 112.5 and entity.OrbitAngleOffset < 157.5 then
				entity.OrbitAngleOffset = 135
			elseif entity.OrbitAngleOffset < -22.5 and entity.OrbitAngleOffset > -67.5 then
				entity.OrbitAngleOffset = -45
			elseif entity.OrbitAngleOffset <= -67.5 and entity.OrbitAngleOffset >= -112.5 then
				entity.OrbitAngleOffset = -90
			elseif entity.OrbitAngleOffset < -112.5 and entity.OrbitAngleOffset > -157.5 then
				entity.OrbitAngleOffset = -135
			else
				entity.OrbitAngleOffset = 180
			end
			entity.TargetPosition = room:GetGridPosition(room:GetGridIndex(entity.Position - (Vector.FromAngle(entity.OrbitAngleOffset) * 40)))
		end


	-- Move
	elseif entity.State == States.Moving then
		if not sprite:IsPlaying("Move") then
			sprite:Play("Move", true)
		end
		
		-- Check if it moved above target or if target position is above grid entities
		if entity.Target and entity.Target.Position:Distance(entity.Position) <= 80 then
			if player and player:HasTrinket(TrinketType.TRINKET_RC_REMOTE) then
				local movementDirection = player:GetMovementDirection()
				local controllerIndex = player.ControllerIndex
				local isPressingCtrl = Input.IsActionPressed(ButtonAction.ACTION_DROP, controllerIndex)

				if movementDirection ~= Direction.NO_DIRECTION and not isPressingCtrl then
					if not entity.Child then
						local target = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.TARGET, 0, Vector.Zero, Vector.Zero, nil)
						target.Visible = false
						entity.Child = target
					end

					local movementInput = player:GetMovementInput()
					movementInput:Resize(40)

					entity.Child.Position = room:GetGridPosition(room:GetClampedGridIndex(entity.Child.Position + movementInput))
				else
					entity.Keys = 1
				end
			else
				entity.Keys = 1
			end
		end
		
		if entity.Position:Distance(entity.TargetPosition) > 2 and room:GetGridCollisionAtPos(entity.TargetPosition) <= 0 then
			entity.Position = (entity.Position + (entity.TargetPosition - entity.Position) * 0.35)
		else
			entity.Coins = entity.Coins - 1
			if entity.Coins <= 0 or entity.Keys == 1 then
				entity.State = States.Land
				entity.Position = room:GetGridPosition(room:GetGridIndex(entity.Position))
			else
				entity.TargetPosition = room:GetGridPosition(room:GetGridIndex(entity.Position - (Vector.FromAngle(entity.OrbitAngleOffset) * 40)))
			end
		end


	-- Land
	elseif entity.State == States.Land then
		if not sprite:IsPlaying("Land") then
			sprite:Play("Land", true)
		end

		if Sewn_API then
			Sewn_API:AddCrownOffset(entity, Vector(0, SewingMachineLandCrownOffsets[sprite:GetFrame()+1]))
		end

		if sprite:IsEventTriggered("Land") then
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			entity.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
			sfx:Play(SoundEffect.SOUND_FETUS_FEET, 1.2, 0, false, 0.8, 0)

			-- Stomp
			local range = 80

			if Sewn_API and Sewn_API:IsUltra(entity:GetData()) then
				range = range * 1.5
			end

			for _,v in pairs(Isaac.GetRoomEntities()) do
				if v.Type > 9 and v.Type < 1000 and v.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and v:IsActiveEnemy()
				and room:GetGridPosition(room:GetGridIndex(entity.Position)):Distance(room:GetGridPosition(room:GetGridIndex(v.Position))) <= 80 then
					local multiplier = 1
					if bff == true then
						multiplier = multiplier * Settings.BFFmultiplier
					end
					if room:GetGridPosition(room:GetGridIndex(v.Position)) == room:GetGridPosition(room:GetGridIndex(entity.Position)) then
						multiplier = multiplier * Settings.SameSpaceMultiplier
					end

					local damage = Settings.Damage

					if Sewn_API then
						if Sewn_API:IsSuper(entity:GetData()) then
							damage = damage * 1.25
						elseif Sewn_API:IsUltra(entity:GetData()) then
							damage = damage * 1.5
						end
					end

					v:TakeDamage(damage * multiplier, DamageFlag.DAMAGE_CRUSH | DamageFlag.DAMAGE_IGNORE_ARMOR, EntityRef(entity), 0)
					if v:HasMortalDamage() then
						v:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
					end
				end
			end

		elseif sprite:IsEventTriggered("Move") then
			entity.State = States.Idle
			entity.FireCooldown = Settings.Cooldown
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, CheckedMateMod.checkedMateUpdate, RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant)


function CheckedMateMod:checkedMateNewRoom()
	for i, f in pairs(Isaac.GetRoomEntities()) do
		if f.Type == EntityType.ENTITY_FAMILIAR and f.Variant == RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant then
			local room = game:GetRoom()
			f.Position = room:GetGridPosition(room:GetGridIndex(f:ToFamiliar().Player.Position))

			f:ToFamiliar().State = States.Idle
			f:ToFamiliar().FireCooldown = 0
			f.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
			f.GridCollisionClass = GridCollisionClass.COLLISION_SOLID
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, CheckedMateMod.checkedMateNewRoom)



function CheckedMateMod:checkedMateCheck(player)
	local numFamiliars = player:GetCollectibleNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE) + player:GetEffects():GetCollectibleEffectNum(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE)

	player:CheckFamiliar(RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant, numFamiliars, player:GetCollectibleRNG(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE), checkedMateDesc)	
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, CheckedMateMod.checkedMateCheck, CacheFlag.CACHE_FAMILIARS)
