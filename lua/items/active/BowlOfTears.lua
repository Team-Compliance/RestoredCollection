local BowlOfTears = {}
local Helpers = require("lua.helpers.Helpers")

if REPENTOGON then
	function BowlOfTears:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player or amount < 1 then return end
			for i = 0,2 do
				if player:GetActiveItem(i) == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
					player:AddActiveCharge(1, i, true, false, true)
				end
			end
		end
	end
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, BowlOfTears.ChargeOnFire)
else
	function BowlOfTears:ChargeOnFire(player)
		Helpers.ChargeBowl(player)
	end
	RestoredItemsCollection:AddCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, BowlOfTears.ChargeOnFire)
end

function BowlOfTears:DisableSwitching(entity, hook, button)
	if entity and entity:ToPlayer() then
		local data = Helpers.GetData(entity)
		if (button == ButtonAction.ACTION_DROP) and data.HoldingBowl then
			return false
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_INPUT_ACTION, BowlOfTears.DisableSwitching, InputHook.IS_ACTION_TRIGGERED)

--lifting and hiding bowl
function BowlOfTears:UseBowl(collectibleType, rng, player, useFlags, slot, customdata)
	local data = Helpers.GetData(player)
	if collectibleType == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
		if REPENTOGON then
			if player:GetItemState() == collectibleType then
				player:SetItemState(collectibleType)
				data.BowlWaitFrames = 0
			elseif player:GetItemState() == 0 then
				data.BowlWaitFrames = 20
				player:SetItemState(collectibleType)
				player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
			end
			return {Discharge = false, Remove = false, ShowAnim = false}
		else
			if data.HoldingBowl ~= slot then
				data.HoldingBowl = slot
				player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "LiftItem", "PlayerPickup")
				data.BowlWaitFrames = 20
			else
				data.HoldingBowl = nil
				data.BowlWaitFrames = 0
				player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			end
			local returntable = {Discharge = false, Remove = false, ShowAnim = false} --don't discharge, don't remove item, don't show animation
			return returntable
		end
	elseif not REPENTOGON then
		data.HoldingBowl = nil
		data.BowlWaitFrames = 0
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_USE_ITEM, BowlOfTears.UseBowl)

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
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BowlOfTears.BowlRoomUpdate)
	RestoredItemsCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, BowlOfTears.DamagedWithBowl, EntityType.ENTITY_PLAYER)
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
		if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS and data.HoldingBowl ~= 2 then
			data.HoldingBowl = nil
			player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			data.BowlWaitFrames = 0
		end
	end
	local state = REPENTOGON and player:GetItemState() == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS or data.HoldingBowl ~= nil
	if state and data.BowlWaitFrames <= 0 then
		local idx = player.ControllerIndex
		local left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT,idx)
		local right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT,idx)
		local up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP,idx)
		local down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN,idx)
		local mouseclick = Input.IsMouseBtnPressed(RestoredItemsCollection.Enums.MouseClick.LEFT)
		local sprite = player:GetSprite()
		if (left > 0 or right > 0 or down > 0 or up > 0 or mouseclick) then
			local angle
			if mouseclick then
				angle = (Input.GetMousePosition(true) - player.Position):Normalized():GetAngleDegrees()
			else
				angle = Vector(right-left,down-up):Normalized():GetAngleDegrees()
			end
			local shootVector = Vector.FromAngle(angle)
			local charge = Isaac.GetItemConfig():GetCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS).MaxCharges
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
				if player:GetActiveItem(i) == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
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
			player:AnimateCollectible(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, "HideItem", "PlayerPickup")
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
				for i = 1, 3 do
					player:AddWisp(RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, player.Position)
				end
			end
		end
	end
end
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BowlOfTears.BowlShoot)

function BowlOfTears:WispUpdateBOT(wisp)
	local data = Helpers.GetData(wisp)
	if wisp.SubType == RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
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
RestoredItemsCollection:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BowlOfTears.WispUpdateBOT, FamiliarVariant.WISP)