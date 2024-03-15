local BowlOfTears = {}
local Helpers = require("lua.helpers.Helpers")

if REPENTOGON then
	function BowlOfTears:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player or amount < 1 then return end
			for i = 0,2 do
				if player:GetActiveItem(i) == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
					player:AddActiveCharge(1, i, true, false, true)
				end
			end
		end
	end
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, BowlOfTears.ChargeOnFire)
else
	local function FireTear(player)
		local data = Helpers.GetData(player)
		if data.PrevDelay and player.HeadFrameDelay > data.PrevDelay and player.HeadFrameDelay > 1 then 
			Helpers.ChargeBowl(player)
		end 
		data.PrevDelay = player.HeadFrameDelay
	end

	local function LudoCharge(entity)
		local player = Helpers.GetPlayerFromTear(entity)
		local data = Helpers.GetData(entity)
		if player then
			if player:GetActiveWeaponEntity() and entity.FrameCount > 0 then
				if entity.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entity) then
					if math.fmod(entity.FrameCount, player.MaxFireDelay) == 1 and not data.KnifeLudoCharge then
						Helpers.ChargeBowl(player)
						data.KnifeLudoCharge = true
					elseif math.fmod(entity.FrameCount, player.MaxFireDelay) == ((player.MaxFireDelay - 2) > 1 and (player.MaxFireDelay - 2) or 1) and data.KnifeLudoCharge then
						data.KnifeLudoCharge = nil
					end
				end
			end
		end
	end

	--firing tears updates the bowl
	function BowlOfTears:TearBowlCharge(player)
		if not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) and not player:HasWeaponType(WeaponType.WEAPON_KNIFE)
		and not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) and not player:HasWeaponType(WeaponType.WEAPON_TECH_X)
		and not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
			FireTear(player)
		end
	end

	--updating knife charge
	function BowlOfTears:KnifeBowlCharge(entityKnife)
		local player = Helpers.GetPlayerFromTear(entityKnife)
		local data = Helpers.GetData(entityKnife)
		if player then
			if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
			or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then return end
			local sk = entityKnife:GetSprite()
			if entityKnife.Variant == 10 and entityKnife.SubType == 0 then --spirit sword
				if sk:GetFrame() == 3 and not data.SwordSpin then
					Helpers.ChargeBowl(player)
					data.SwordSpin = true
				elseif data.SwordSpin then
					for _,s in ipairs({"Left","Right","Down","Up"}) do
						if (sk:IsPlaying("Attack"..s) or sk:IsPlaying("Spin"..s)) and sk:GetFrame() == 2 then
							data.SwordSpin = nil
							break
						end
					end
				end
			elseif entityKnife:IsFlying() and not data.Flying then --knife flies
				data.Flying = true
				if GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
					Helpers.ChargeBowl(player)
				end
			elseif not entityKnife:IsFlying() and data.Flying then --one charge check
				data.Flying = nil
			elseif entityKnife.Variant == 1 or entityKnife.Variant == 3 and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
				if sk:GetFrame() == 1 and not data.BoneSwing then
					Helpers.ChargeBowl(player)
					data.BoneSwing = true
				end
			else
				LudoCharge(entityKnife)
			end
		end
	end

	--updating ludo charge and fired from bowl tears
	function BowlOfTears:TearUpdateBOT(entityTear)
		local player = Helpers.GetPlayerFromTear(entityTear)
		--updating charges with ludo
		if player then
			LudoCharge(entityTear)
			--updating slight height and acceleration of tears from bowl
			--[[if entityTear.FrameCount == 1 and TC_SaltLady:GetData(entityTear).FromBowl then
				--local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
				entityTear.Height = TC_SaltLady:GetRandomNumber(-40,-24, TC_SaltLady.Globals.rng)
				entityTear.FallingAcceleration = 1 / TC_SaltLady:GetRandomNumber(1,5,TC_SaltLady.Globals.rng)
			end]]
		end
	end

	--chargin lasers
	function BowlOfTears:BrimstoneBowlCharge(entityLaser)
		if entityLaser.SpawnerType == EntityType.ENTITY_PLAYER and not Helpers.GetData(entityLaser).isSpreadLaser then
			local player = Helpers.GetPlayerFromTear(entityLaser)
			if player then
				if player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
					FireTear(player)
				elseif player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) and player:GetActiveWeaponEntity() then
					local delay = player:GetActiveWeaponEntity().SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO and player.MaxFireDelay or 5
					if math.fmod(player:GetActiveWeaponEntity().FrameCount, delay) == 1 then
						Helpers.ChargeBowl(player)
					end
				end
			end
		end
	end

	--that one scene from Dr. Strangelove 
	function BowlOfTears:EpicBowlCharge(entityRocet)
		local player = Helpers.GetPlayerFromTear(entityRocet)
		if player then
			Helpers.ChargeBowl(player)
		end
	end

	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, BowlOfTears.TearBowlCharge)
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, BowlOfTears.KnifeBowlCharge)
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, BowlOfTears.TearUpdateBOT)
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, BowlOfTears.BrimstoneBowlCharge)
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, BowlOfTears.EpicBowlCharge, EffectVariant.ROCKET)
end

function BowlOfTears:DisableSwitching(entity, hook, button)
	if entity and entity:ToPlayer() then
		local data = Helpers.GetData(entity)
		if (button == ButtonAction.ACTION_DROP) and data.HoldingBowl then
			return false
		end
	end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_INPUT_ACTION, BowlOfTears.DisableSwitching, InputHook.IS_ACTION_TRIGGERED)

--lifting and hiding bowl
function BowlOfTears:UseBowl(collectibleType, rng, player, useFlags, slot, customdata)
	local data = Helpers.GetData(player)
	if collectibleType == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
		if REPENTOGON then
			if player:GetItemState() == collectibleType then
				player:SetItemState(collectibleType)
				data.BowlWaitFrames = 0
			elseif player:GetItemState() == 0 then
				data.BowlWaitFrames = 20
				player:SetItemState(collectibleType)
				player:AnimateCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
			end
			return {Discharge = false, Remove = false, ShowAnim = false}
		else
			if data.HoldingBowl ~= slot then
				data.HoldingBowl = slot
				player:AnimateCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
				data.BowlWaitFrames = 20
			else
				data.HoldingBowl = nil
				data.BowlWaitFrames = 0
				player:AnimateCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			end
			local returntable = {Discharge = false, Remove = false, ShowAnim = false} --don't discharge, don't remove item, don't show animation
			return returntable
		end
	elseif not REPENTOGON then
		data.HoldingBowl = nil
		data.BowlWaitFrames = 0
	end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_USE_ITEM, BowlOfTears.UseBowl)

--reseting state/slot number on new room
function BowlOfTears:BowlRoomUpdate()
	for _,player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
		BowlOfTears:DamagedWithBowl(player)
	end
end

--taiking damage to reset state/slot number
function BowlOfTears:DamagedWithBowl(player)
	Helpers.GetData(player).HoldingBowl = nil
	Helpers.GetData(player).BowlWaitFrames = 0
end
if not REPENTOGON then
	RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BowlOfTears.BowlRoomUpdate)
	RestoredItemsPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BowlOfTears.DamagedWithBowl, EntityType.ENTITY_PLAYER)
end

--shooting tears from bowl
function BowlOfTears:BowlShoot(player)
	local data = Helpers.GetData(player)
	if data.BowlWaitFrames then
		data.BowlWaitFrames = data.BowlWaitFrames - 1
	else
		data.BowlWaitFrames = 0
	end
	local slot = data.HoldingBowl
	if slot and slot ~= -1 then
		if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS and data.HoldingBowl ~= 2 then
			data.HoldingBowl = nil
			player:AnimateCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			data.BowlWaitFrames = 0
		end
	end
	local state = REPENTOGON and player:GetItemState() == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS or data.HoldingBowl ~= nil
	if state and data.BowlWaitFrames <= 0 then
		local idx = player.ControllerIndex
		local left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT,idx)
		local right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT,idx)
		local up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP,idx)
		local down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN,idx)
		local mouseclick = Input.IsMouseBtnPressed(RestoredItemsPack.Enums.MouseClick.LEFT)
		local sprite = player:GetSprite()
		if (left > 0 or right > 0 or down > 0 or up > 0 or mouseclick) then
			local angle
			if mouseclick then
				angle = (Input.GetMousePosition(true) - player.Position):Normalized():GetAngleDegrees()
			else
				angle = Vector(right-left,down-up):Normalized():GetAngleDegrees()
			end
			local shootVector = Vector.FromAngle(angle)
			local charge = Isaac.GetItemConfig():GetCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS).MaxCharges
			for _ = 1, TSIL.Random.GetRandomInt(10, 16) do
				local tear = player:FireTear(player.Position, (shootVector * player.ShotSpeed):Rotated(TSIL.Random.GetRandomInt(-10, 10)) * TSIL.Random.GetRandomInt(10, 16) + player.Velocity, false, true, false, player)
				tear.FallingSpeed = TSIL.Random.GetRandomInt(-15, -3)
                tear.Height = TSIL.Random.GetRandomInt(-60, -40)
                tear.FallingAcceleration = TSIL.Random.GetRandomFloat(0.5, 0.6)
				if player:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) and REPENTOGON then
					tear.CollisionDamage = math.max(player.Damage, player.Damage * player:GetWeapon(1):GetCharge() / player.MaxFireDelay)
				else
					tear.CollisionDamage = player.Damage
				end
			end
			for i = 0, 2 do
				if player:GetActiveItem(i) == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
					if REPENTOGON then
						player:AddActiveCharge(-charge, i, true, false, true)
					else
						player:SetActiveCharge(Helpers.GetCharge(player, i) - charge, i)
					end
					break
				end
			end
			data.BowlWaitFrames = 0
			if REPENTOGON then
				player:ResetItemState()
			else
				data.HoldingBowl = nil
			end
			player:AnimateCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
				for i = 1, 3 do
					player:AddWisp(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, player.Position)
				end
			end
		end
	end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BowlOfTears.BowlShoot)

function BowlOfTears:WispUpdateBOT(wisp)
	local data = Helpers.GetData(wisp)
	if wisp.SubType == RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
		if not data.Timeout then
			data.Timeout = 90
		end
		if data.Timeout > 0 then
			data.Timeout = data.Timeout - 1
		else
			wisp:Kill()
		end
	end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BowlOfTears.WispUpdateBOT, FamiliarVariant.WISP)