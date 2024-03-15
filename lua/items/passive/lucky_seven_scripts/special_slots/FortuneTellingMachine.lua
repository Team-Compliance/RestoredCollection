local LuckySevenSlot = include("lua.items.passive.lucky_seven_scripts.LuckySevenSlot")
local FortuneTellingMachine = LuckySevenSlot:New("gfx/lucky_seven_fortune_machine.anm2", 180)
local Helpers = require("lua.helpers.Helpers")
local sfx = SFXManager()

---@param player EntityPlayer
---@return boolean
function FortuneTellingMachine:CanSpawn(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_CRYSTAL_BALL)
end


---@param slot Entity
function FortuneTellingMachine:OnInit(slot)
    local data = Helpers.GetData(slot)

    data.LightRayCooldown = 21
    data.TearDelay = 21

    slot:GetSprite():Play("Wiggle", true)
end


---@param slot Entity
local function SpawnRandomLightRay(slot)
    local rng = slot:GetDropRNG()
    local room = Game():GetRoom()
    local randomGridIndex = room:GetRandomTileIndex(rng:Next())
    local spawningPos = room:GetGridPosition(randomGridIndex)

    local lightRay = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.CRACK_THE_SKY, 0, spawningPos, Vector.Zero, slot)
    lightRay = lightRay:ToEffect()
end


---@param slot Entity
function FortuneTellingMachine:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    if REPENTOGON and slot:GetState() == 2 or data.HasBeenTouched then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end

    data.LightRayCooldown = data.LightRayCooldown - 1

    if data.LightRayCooldown <= 0 then
        SpawnRandomLightRay(slot)
        data.LightRayCooldown = data.TearDelay
    end
end


---@param slot Entity
function FortuneTellingMachine:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function FortuneTellingMachine:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function FortuneTellingMachine:OnDestroy(slot)
    local data = Helpers.GetData(slot)
    ---@type EntityPlayer
    local player = data.SlotPlayer

    player:UseActiveItem(CollectibleType.COLLECTIBLE_CRACK_THE_SKY, UseFlag.USE_NOANIM)

    slot:GetSprite():Play("Death", true)
end


return FortuneTellingMachine