local LuckySevenSlot = include("lua.items.passive.lucky_seven_scripts.LuckySevenSlot")
local Electrifier = LuckySevenSlot:New("gfx/lucky_seven_electrifier.anm2", 180)
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

---@param player EntityPlayer
---@return boolean
function Electrifier:CanSpawn(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_GAMEKID)
end


---@param slot Entity
function Electrifier:OnInit(slot)
    local data = Helpers.GetData(slot)
    ---@type EntityPlayer
    local player = data.SlotPlayer
    data.ZapCooldown = player.MaxFireDelay
    data.TearDelay = 12

    slot:GetSprite():Play("Wiggle", true)
end


---@param slot Entity
---@param rng RNG
local function ZapEnemies(slot, rng)
    local laser = EntityLaser.ShootAngle(10, slot.Position, rng:RandomInt(360), 10, Vector(0, -10), slot)
    laser:SetMaxDistance(150 + rng:RandomInt(100))
    laser.DepthOffset = 40
end


---@param slot Entity
function Electrifier:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    if REPENTOGON and slot:GetState() == 2 or data.HasBeenTouched then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end

    data.ZapCooldown = data.ZapCooldown - 1

    if data.ZapCooldown <= 0 then
        local rng = slot:GetDropRNG()
        ZapEnemies(slot, rng)
        data.ZapCooldown = data.TearDelay
    end
end


---@param slot Entity
function Electrifier:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function Electrifier:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function Electrifier:OnDestroy(slot)
    local rng = slot:GetDropRNG()

    for _ = 0, rng:RandomInt(6) + 7 do
        ZapEnemies(slot, rng)
    end

    slot:GetSprite():Play("Death", true)
end


return Electrifier