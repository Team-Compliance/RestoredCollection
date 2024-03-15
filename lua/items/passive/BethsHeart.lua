BethsHeart = {}
local BethsHeartLocal = {}
local Helpers = require("lua.helpers.Helpers")
local bethsheartdesc = Isaac.GetItemConfig():GetCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART)
local sfx = SFXManager()

BethsHeart.HeartCharges = {
	[HeartSubType.HEART_BLACK] = 3,
	[HeartSubType.HEART_SOUL] = 2,
	[HeartSubType.HEART_HALF_SOUL] = 1,
	[HeartSubType.HEART_ETERNAL] = 4
}
BethsHeart.HeartNotifType = {
	[HeartSubType.HEART_BLACK] = "black",
	[HeartSubType.HEART_SOUL] = "soul",
	[HeartSubType.HEART_HALF_SOUL] = "soul",
	[HeartSubType.HEART_ETERNAL] = "eternal"
}

local redRibbonTrinket
if FiendFolio then
	BethsHeart.HeartCharges[1022] = 2 --Half black hearts
	BethsHeart.HeartNotifType[1022] = "black"
	redRibbonTrinket = Isaac.GetTrinketIdByName("Red Ribbon")
end

BethsHeart.HeartCharges[902] = 6 --Immortal hearts
BethsHeart.HeartNotifType[902] = "eternal"


---@param heartSubtype HeartSubType|integer
---@param chargeAmount integer
---@param heartNotifType? "soul" | "black" | "eternal"
function BethsHeart:AddHeartCharge(heartSubtype, chargeAmount, heartNotifType)
	if not heartNotifType then heartNotifType = "soul" end
	BethsHeart.HeartCharges[heartSubtype] = chargeAmount
	BethsHeart.HeartNotifType[heartSubtype] = heartNotifType
end

local DIRECTION_VECTOR = {
	[Direction.NO_DIRECTION] = Vector(0, 1), -- when you don't shoot or move, you default to HeadDown
	[Direction.LEFT] = Vector(-1, 0),
	[Direction.UP] = Vector(0, -1),
	[Direction.RIGHT] = Vector(1, 0),
	[Direction.DOWN] = Vector(0, 1)
}


function BethsHeartLocal:HeartCollectibleUpdate(player)
	local numFamiliars = player:GetCollectibleNum(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART) +
		player:GetEffects():GetCollectibleEffectNum(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART)

	player:CheckFamiliar(RestoredItemsPack.Enums.Familiars.BETHS_HEART.Variant, numFamiliars,
		player:GetCollectibleRNG(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART), bethsheartdesc)
end

function BethsHeartLocal:BethsHeartInit(heart)
	heart:AddToFollowers()
	heart.State = 0
end

---@param heart EntityFamiliar
function BethsHeartLocal:BethsHeartUpdate(heart)
	local player = heart.Player
	local bff = player:HasCollectible(CollectibleType.COLLECTIBLE_BFFS) and 2 or 1
	if heart.Hearts > 6 * bff then
		heart.Hearts = 6 * bff
	end
	local heartspr = heart:GetSprite()
	if not heartspr:IsPlaying("Idle" .. heart.Hearts) then
		heartspr:Play("Idle" .. heart.Hearts, false)
	end
	if not heartspr:IsOverlayPlaying("Charge" .. heart.Hearts) then
		heartspr:PlayOverlay("Charge" .. heart.Hearts, false)
	end

	if heart.State ~= 1 then
		heart:FollowParent()
		heart.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
	else
		heart:RemoveFromFollowers()
		heart.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
	end

	if heart.State == 1 then
		for _, soulheart in pairs(Isaac.FindInRadius(heart.Position, 15 + 5 * (bff - 1), EntityPartition.PICKUP)) do
			if soulheart.Variant == PickupVariant.PICKUP_HEART and not soulheart:GetSprite():IsPlaying("Collect") then
				local restoreamount = BethsHeart.HeartCharges[soulheart.SubType]
				if not restoreamount then restoreamount = 0 end

				if redRibbonTrinket and soulheart.SubType == HeartSubType.HEART_ETERNAL then
					local multiplier = heart.Player:GetTrinketMultiplier(redRibbonTrinket)

					if multiplier == 1 then
						restoreamount = restoreamount * 2
					elseif multiplier > 1 then
						restoreamount = restoreamount * 4
					end
				end
				if (not soulheart:ToPickup():IsShopItem()) and restoreamount > 0 then
					if heart.Hearts < 6 * bff then
						heart.Hearts = heart.Hearts + restoreamount
						local heartNotifType = BethsHeart.HeartNotifType[soulheart.SubType]
						if heartNotifType == "soul" then
							local effect = Isaac.Spawn(1000, 49, 4, heart.Position, Vector.Zero, heart)
							effect:GetSprite().Offset = Vector(0, -11)
						elseif heartNotifType == "black" then
							local effect = Isaac.Spawn(1000, 49, 5, heart.Position, Vector.Zero, heart)
							effect:GetSprite().Offset = Vector(0, -11)
						elseif heartNotifType == "eternal" then
							local effect = Isaac.Spawn(1000, 49, 0, heart.Position, Vector.Zero, heart)
							effect:GetSprite():Load("gfx/1000.049_heart.anm2", false)
							effect:GetSprite():ReplaceSpritesheet(0, "gfx/effects/eternal_heart_notif.png")
							effect:GetSprite():LoadGraphics()

							effect:GetSprite():Play("Heart", true)
							effect:GetSprite().Offset = Vector(0, -11)
						end
						sfx:Play(171, 1)
						soulheart:GetSprite():Play("Collect")
						soulheart:Die()
						soulheart.EntityCollisionClass = 0
					end
				end
			end
		end
		if heart:CollidesWithGrid() then
			heart.Velocity = Vector.Zero
			heart.State = 2
		end
	end
	if heart.State == 2 then
		local target = player
		if player:HasCollectible(CollectibleType.COLLECTIBLE_KING_BABY) then
			for _, king in ipairs(Isaac.FindByType(3, FamiliarVariant.KING_BABY)) do
				local baby = king:ToFamiliar()
				if GetPtrHash(baby.Player) == GetPtrHash(player) then
					---@diagnostic disable-next-line: cast-local-type
					target = baby
				end
			end
		end
		if (heart.Position - target.Position):Length() <= 70 then
			heart.State = 0
			heart:AddToFollowers()
		end
	end
end

function BethsHeartLocal:BethInputUpdate(player)
	for _, heart in ipairs(Isaac.FindByType(3, RestoredItemsPack.Enums.Familiars.BETHS_HEART.Variant)) do
		if GetPtrHash(player) == GetPtrHash(heart:ToFamiliar().Player) then
			heart = heart:ToFamiliar()
			local heartData = Helpers.GetData(heart)
			local idx = player.ControllerIndex
			if Input.IsActionTriggered(ButtonAction.ACTION_DROP, idx) and heart.Hearts > 0 then
				local slot = Helpers.GetUnchargedSlot(player, ActiveSlot.SLOT_PRIMARY)
				local charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
				local item = Isaac:GetItemConfig():GetCollectible(player:GetActiveItem(slot))
				local battery = player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1
				if item and charge < item.MaxCharges * battery and item.ChargeType ~= 1 and player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_ALABASTER_BOX then
					---@diagnostic disable-next-line: param-type-mismatch
					Game():GetHUD():FlashChargeBar(player, slot)
					local charging
					if charge + heart.Hearts < item.MaxCharges * battery then
						charging = charge + heart.Hearts
						heart.Hearts = 0
					else
						charging = item.MaxCharges * battery
						heart.Hearts = heart.Hearts + charge - item.MaxCharges * battery
					end
					player:SetActiveCharge(charging, slot)
					sfx:Play(SoundEffect.SOUND_BATTERYCHARGE)
					Helpers.OverCharge(player)
				elseif item and item.ChargeType == 1 and charge < item.MaxCharges * battery then
					for i = 1, battery do
						if heart.Hearts > 0 and charge < item.MaxCharges * battery then
							player:FullCharge(slot)
							charge = player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
							heart.Hearts = heart.Hearts - 1
						else
							break
						end
					end
					Helpers.OverCharge(player)
				end
			end

			if not heartData.ShootButtonState and heart.State == 0 then
				if Input.IsActionTriggered(4, idx) then
					heartData.ShootButtonPressed = 4
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(5, idx) then
					heartData.ShootButtonPressed = 5
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(6, idx) then
					heartData.ShootButtonPressed = 6
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				elseif Input.IsActionTriggered(7, idx) then
					heartData.ShootButtonPressed = 7
					heartData.ShootButtonState = "listening for second tap"
					heartData.PressFrame = Game():GetFrameCount()
				end
			end

			if heartData.ShootButtonPressed and heartData.PressFrame and (Game():GetFrameCount() <= heartData.PressFrame + 10) and heart.State == 0 then
				if not Input.IsActionTriggered(heartData.ShootButtonPressed, idx) and heartData.ShootButtonState == "listening for second tap" then
					heartData.ShootButtonState = "button released"
				end

				if heartData.ShootButtonState == "button released" and Input.IsActionTriggered(heartData.ShootButtonPressed, idx) then
					heart.State = 1
					---@diagnostic disable-next-line: assign-type-mismatch
					heart.Velocity = DIRECTION_VECTOR[player:GetFireDirection()]:Resized(12) + heart.Velocity / 2
					heartData.ShootButtonState = nil
					heartData.ShootButtonPressed = nil
					heartData.PressFrame = nil
				end
			else
				heartData.ShootButtonState = nil
				heartData.ShootButtonPressed = nil
				heartData.PressFrame = nil
			end
		end
	end
end

RestoredItemsPack:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, BethsHeartLocal.BethsHeartInit, RestoredItemsPack.Enums.Familiars.BETHS_HEART.Variant)
RestoredItemsPack:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, BethsHeartLocal.BethsHeartUpdate, RestoredItemsPack.Enums.Familiars.BETHS_HEART.Variant)
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, BethsHeartLocal.BethInputUpdate)
RestoredItemsPack:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, BethsHeartLocal.HeartCollectibleUpdate, CacheFlag.CACHE_FAMILIARS)
