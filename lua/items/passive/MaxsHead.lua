local MaxsHead = {}
local Helpers = require("lua.helpers.Helpers")
MaxsHead.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD
MaxsHead.FIRE_DELAY = 1.5
MaxsHead.FIRE_RATE_MULT = 0.5
--The effect will proc every x tears
MaxsHead.NUM_TEARS_PROC = 4
local MaxHeadAnims = {
    "normal",
    "sad",
    "silly",
    "wink",
    "dead",
    "holy",
    "666",
}

---@param player EntityPlayer
function MaxsHead:OnFireDelayCache(player)
    local num = player:GetCollectibleNum(MaxsHead.ID)

    local tps = Helpers.ToTearsPerSecond(player.MaxFireDelay)
    if tps > 5 then
        tps = tps + MaxsHead.FIRE_DELAY * num
    else
        tps = math.min(5, tps + MaxsHead.FIRE_DELAY * num)
    end
    player.MaxFireDelay = Helpers.ToMaxFireDelay(tps)
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_EVALUATE_CACHE,
    MaxsHead.OnFireDelayCache,
    CacheFlag.CACHE_FIREDELAY
)

---@param effect EntityEffect
function MaxsHead:InitHeadEffect(effect)
    local data = Helpers.GetData(effect)
    local sprite = effect:GetSprite()
    sprite:Play("HeadAppear", true)
    sprite:ReplaceSpritesheet(0, "gfx/effects/max_"..MaxHeadAnims[TSIL.Random.GetRandomInt(1, #MaxHeadAnims)]..".png")
    sprite:LoadGraphics()
    data.TimeToLive = 90
end
RestoredCollection:AddCallback(
    ModCallbacks.MC_POST_EFFECT_INIT,
    MaxsHead.InitHeadEffect,
    RestoredCollection.Enums.Entities.MAXS_HEAD.Variant
)

---@param effect EntityEffect
function MaxsHead:UpdateHeadEffect(effect)
    local data = Helpers.GetData(effect)
    local sprite = effect:GetSprite()
    if sprite:IsFinished("HeadAppear") then
        sprite:Play("HeadLoop", true)
    end
    local timer = data.TimeToLive or 90
    if sprite:GetAnimation() == "HeadLoop" then
        if timer <= 0 then
            sprite:Play("HeadEnd", true)
        else
            data.TimeToLive = timer - 1
        end
    end
    if sprite:IsFinished("HeadEnd") then
        effect:Remove()
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, MaxsHead.UpdateHeadEffect, RestoredCollection.Enums.Entities.MAXS_HEAD.Variant)

---@param player EntityPlayer
local function SpanwMaxHead(player)
    if TSIL.Random.GetRandomInt(0, 100) <= 15 then
        local eff = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.MAXS_HEAD.Variant, 0, player.Position, Vector.Zero, player):ToEffect()
        ---@cast eff EntityEffect
        eff:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
        eff:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        eff:FollowParent(player)
        local spritePos = Vector.FromAngle(TSIL.Random.GetRandomInt(0, 180)):Resized(10)
        eff.SpriteOffset = Vector(0, -20 * player.SpriteScale.Y) + Vector(spritePos.X * player.SpriteScale.X, -spritePos.Y * player.SpriteScale.Y * TSIL.Random.GetRandomFloat(0.6, 1.4))
        eff.DepthOffset = 5
    end
end

if REPENTOGON then
    function MaxsHead:ChargeOnFire(dir, amount, owner)
		if owner then
			local player = owner:ToPlayer()
			if not player or amount < 1 then return end
            if not player:HasCollectible(MaxsHead.ID) then return end
            local data = Helpers.GetData(player)
			local numTears = data.NumTears or 1

            if numTears >= MaxsHead.NUM_TEARS_PROC then
                data.NumTears = 1
                player.FireDelay = Helpers.Round(player.FireDelay * MaxsHead.FIRE_RATE_MULT, 2)
                SpanwMaxHead(player)
            else
                data.NumTears = numTears + 1
            end
		end
	end
	RestoredCollection:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, MaxsHead.ChargeOnFire)
else
    ---@param player EntityPlayer
    function MaxsHead:OnPlayerUpdate(player)
        if not player:HasCollectible(MaxsHead.ID) then return end

        local data = Helpers.GetData(player)
        local prevFireDelay = data.PreviousFireDelay or 10
        local currentFireDelay = player.FireDelay
        data.PreviousFireDelay = currentFireDelay

        if prevFireDelay < currentFireDelay then
            local numTears = data.NumTears or 1

            if numTears >= MaxsHead.NUM_TEARS_PROC then
                data.NumTears = 1
                player.FireDelay = Helpers.Round(currentFireDelay * MaxsHead.FIRE_RATE_MULT, 2)
                SpanwMaxHead(player)
            else
                data.NumTears = numTears + 1
            end
        end
    end
    RestoredCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, MaxsHead.OnPlayerUpdate)
end