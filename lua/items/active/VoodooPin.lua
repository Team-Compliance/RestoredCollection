local VoodooPin = {}
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

function VoodooPin:DisableSwitching(entity, hook, button)
	if entity and entity:ToPlayer() then
		local data = Helpers.GetData(entity)
		if (button == ButtonAction.ACTION_DROP) and data.HoldingVoodoo then
			return false
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_INPUT_ACTION, VoodooPin.DisableSwitching, InputHook.IS_ACTION_TRIGGERED)

function VoodooPin:UseVoodooPin(collectible, _, player, _, slot)
	local data = Helpers.GetData(player)
	if collectible == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN then
		if REPENTOGON then
			if player:GetItemState() == collectible then
				player:SetItemState(collectible)
				data.VoodooWaitFrames = 0
			elseif player:GetItemState() == 0 then
				data.VoodooWaitFrames = 20
				player:SetItemState(collectible)
				player:AnimateCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "LiftItem", "PlayerPickup")
			end
			return {Discharge = false, Remove = false, ShowAnim = false}
		else
			if data.HoldingVoodoo ~= slot then
				data.HoldingVoodoo = slot
				player:AnimateCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "LiftItem", "PlayerPickup")
				data.BowlWaitFrames = 20
			else
				data.HoldingVoodoo = nil
				data.BowlWaitFrames = 0
				player:AnimateCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "HideItem", "PlayerPickup")
			end
			return {Discharge = false, Remove = false, ShowAnim = false}
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_USE_ITEM, VoodooPin.UseVoodooPin)

--reseting state/slot number on new room
function VoodooPin:VoodooRoomUpdate()
	for _,player in pairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
		Helpers.GetData(player).HoldVooodooPin = nil
		Helpers.GetData(player).VoodooWaitFrames = 0
	end
end

--taiking damage to reset state/slot number
function VoodooPin:DamagedWithVoodoo(player,dmg,dmgFlags,dmgSource,dmgCountDownFrames)
	local data = Helpers.GetData(player:ToPlayer())
	if data.SwapedEnemy then
		local entity = dmgSource.Entity
		if entity and GetPtrHash(data.SwapedEnemy) ~= GetPtrHash(entity) then
			data.SwapedEnemy:TakeDamage(dmg, dmgFlags, dmgSource, dmgCountDownFrames * 2)
			return false
		end
	end
	if not REPENTOGON then
		Helpers.GetData(player).HoldVooodooPin = nil
		Helpers.GetData(player).VoodooWaitFrames = 0
	end
	return nil
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, VoodooPin.DamagedWithVoodoo, EntityType.ENTITY_PLAYER)

if not REPENTOGON then
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, VoodooPin.VoodooRoomUpdate)
end

--shooting tears from bowl
function VoodooPin:VoodooThrow(player)
	local data = Helpers.GetData(player)
	if data.VoodooWaitFrames then
		data.VoodooWaitFrames = data.VoodooWaitFrames - 1
	else
		data.VoodooWaitFrames = 0
	end
	local slot = data.HoldingVoodoo
	if slot and slot ~= -1 then
		if player:GetActiveItem(ActiveSlot.SLOT_SECONDARY) == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN and data.HoldingVoodoo ~= 2 then
			data.HoldingVoodoo = nil
			player:AnimateCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "HideItem", "PlayerPickup")
			data.VoodooWaitFrames = 0
		end
	end
	local state = REPENTOGON and player:GetItemState() == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN or data.HoldingVoodoo ~= nil
	if state and data.VoodooWaitFrames <= 0 then
		local idx = player.ControllerIndex
		local left = Input.GetActionValue(ButtonAction.ACTION_SHOOTLEFT,idx)
		local right = Input.GetActionValue(ButtonAction.ACTION_SHOOTRIGHT,idx)
		local up = Input.GetActionValue(ButtonAction.ACTION_SHOOTUP,idx)
		local down = Input.GetActionValue(ButtonAction.ACTION_SHOOTDOWN,idx)
		local mouseclick = Input.IsMouseBtnPressed(RestoredCollection.Enums.MouseClick.LEFT)
		if (left > 0 or right > 0 or down > 0 or up > 0 or mouseclick) and data.VoodooWaitFrames <= 0 then
			local shootVector
			if mouseclick then
				shootVector = (Input.GetMousePosition(true) - player.Position):Resized(10)
			else
				shootVector = Vector(right-left,down-up):Resized(10)
			end
			local vecShoot = shootVector + player.Velocity
			Isaac.Spawn(EntityType.ENTITY_TEAR, RestoredCollection.Enums.Entities.VOODOO_PIN_TEAR.Variant, 0, player.Position, vecShoot, player):ToTear()
			
			local charge = Isaac.GetItemConfig():GetCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN).MaxCharges
			for i = 0, 2 do
				if player:GetActiveItem(i) == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN then
					if REPENTOGON then
						player:AddActiveCharge(-charge, i, true, false, true)
					else
						player:SetActiveCharge(Helpers.GetCharge(player, i) - charge, i)
					end
					break
				end
			end
			data.VoodooWaitFrames = 0
			if REPENTOGON then
				player:ResetItemState()
			else
				data.HoldingVoodoo = nil
			end
			player:AnimateCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, "HideItem", "PlayerPickup")
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
				player:AddWisp(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, player.Position)
			end
		end
	end
	if data.SwapedEnemy then
		if data.SwapedEnemy:IsDead() or not data.SwapedEnemy:Exists() then
			data.SwapedEnemy = nil
			data.VoodooTimer = 0
			player:SetMinDamageCooldown(60)
		elseif data.SwapedEnemy:IsBoss() then
			if data.VoodooTimer > 0 then
				data.VoodooTimer = data.VoodooTimer - 1
			elseif data.VoodooTimer <= 0 then
				data.SwapedEnemy = nil
				player:SetMinDamageCooldown(60)
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, VoodooPin.VoodooThrow)


--taiking damage to reset state/slot number
---@param tear EntityTear
---@param collider Entity
function VoodooPin:VoodooHit(tear,collider)
	local player = Helpers.GetPlayerFromTear(tear)
    if not player then return end

	local data = Helpers.GetData(player)
	if collider:IsVulnerableEnemy() then
		data.SwapedEnemy = collider:ToNPC()
		if collider:IsBoss() then
			data.VoodooTimer = 150
		end

		Game():ShakeScreen(7)
		sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 0.5)

		for _ = 1, 2 + math.random(3), 1 do
			local spawningPos = tear.Position + Vector(0, tear.Height)
			local speed = Vector.One
			speed:Resize(math.random() * 3 + 2)
			speed = speed:Rotated(math.random(360))
			local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_PARTICLE, 0, spawningPos, speed, nil)
			particle:GetSprite().Color = Color(0.1, 0.1, 0.1)
			particle.SpriteScale = Vector(0.7, 0.7)
		end
	end
	sfx:Play(SoundEffect.SOUND_SPLATTER,1,0,false)
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, VoodooPin.VoodooHit, RestoredCollection.Enums.Entities.VOODOO_PIN_TEAR.Variant)


local voodoo = Sprite()
voodoo:Load("gfx/effects/voodoo_status.anm2", true)
voodoo:LoadGraphics()


function VoodooPin:RenderVoodooCurse(player)
	local data = Helpers.GetData(player)
	if not data.SwapedEnemy then return end

	data.SwapedEnemy:SetColor(Color(0.518, 0.15, 0.8), 2, 1, false, false)

	if Game():GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end

	if not voodoo:IsPlaying("Curse") then
		voodoo:Play("Curse")
		voodoo.PlaybackSpeed = 0.4
	elseif not Game():IsPaused() then
		voodoo:Update()
	end

	local size = data.SwapedEnemy.Size < 20 and data.SwapedEnemy.Size or 20
	voodoo.Scale = Vector(1.3, 1.3)
	---@diagnostic disable-next-line: assign-type-mismatch
	voodoo.Offset = data.SwapedEnemy:GetSprite().Offset - Vector(0.8, size * (data.SwapedEnemy.SizeMulti.Y * 2.8))
	voodoo.Color = Color(1,1,1,0.8)
	voodoo:Render(Game():GetRoom():WorldToScreenPosition(data.SwapedEnemy.Position),Vector.Zero,Vector.Zero)
end


function VoodooPin:OnRender()
	for _,player in ipairs(Helpers.Filter(Helpers.GetPlayers(), function(_, player) return Helpers.GetData(player).SwapedEnemy ~= nil end)) do
		VoodooPin:RenderVoodooCurse(player)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_RENDER, VoodooPin.OnRender)


function VoodooPin:VoodooPinThrown(pin)
	pin.CollisionDamage = 1
	local sprite = pin:GetSprite()
	sprite.Rotation = pin.Velocity:Normalized():GetAngleDegrees()
	if pin.FrameCount == 1 then
		if sfx:IsPlaying(SoundEffect.SOUND_TEARS_FIRE) then
			sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
			sfx:Play(SoundEffect.SOUND_SHELLGAME,1,0,false)
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, VoodooPin.VoodooPinThrown, RestoredCollection.Enums.Entities.VOODOO_PIN_TEAR.Variant)


function VoodooPin:VoodooShatter(pin)
	if pin.Variant == RestoredCollection.Enums.Entities.VOODOO_PIN_TEAR.Variant then
		local shatters = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.VOODOO_PIN_SHATTER.Variant, 0, pin.Position, Vector.Zero, pin):GetSprite()
		shatters.Rotation = pin:GetSprite().Rotation
		shatters.Offset = Vector(0,pin:ToTear().Height)
		shatters:Play("Shatter",true)
		sfx:Play(SoundEffect.SOUND_STONE_IMPACT,1,0,false)
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, VoodooPin.VoodooShatter, EntityType.ENTITY_TEAR)


function VoodooPin:VoodooShattered(pin)
	local sprite = pin:GetSprite()
	if sprite:IsFinished("Shatter") then
		pin:Remove()
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, VoodooPin.VoodooShattered, RestoredCollection.Enums.Entities.VOODOO_PIN_SHATTER.Variant)