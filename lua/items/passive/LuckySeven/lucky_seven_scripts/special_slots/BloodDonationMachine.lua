local LuckySevenSlot = include("lua.items.passive.LuckySeven.lucky_seven_scripts.LuckySevenSlot")
local BloodDonationMachine = LuckySevenSlot:New("gfx/lucky_seven_blood_donation_machine.anm2", 180)
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

---@param player EntityPlayer
---@return boolean
function BloodDonationMachine:CanSpawn(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_IV_BAG)
end


---@param slot Entity
function BloodDonationMachine:OnInit(slot)
    local data = Helpers.GetData(slot)
    ---@type EntityPlayer
    local player = data.SlotPlayer

    local creep = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_LEMON_PARTY, 0, slot.Position, Vector.Zero, player):ToEffect()
    creep.Timeout = self.TIMEOUT
    local color = Color(1, 1, 1, 1)
    color:SetColorize(1, 0, 0, 1)
    creep.Color = color
    data.BloodDonationMachineCreep = creep
    data.BloodDonationMachineCreepScale = 0

    slot:GetSprite():Play("Wiggle", true)
end


---@param slot Entity
function BloodDonationMachine:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    data.BloodDonationMachineCreep.SpriteScale = Vector(data.BloodDonationMachineCreepScale, data.BloodDonationMachineCreepScale)
    data.BloodDonationMachineCreepScale = data.BloodDonationMachineCreepScale + 0.05
    if data.BloodDonationMachineCreepScale >= 0.6 then data.BloodDonationMachineCreepScale = 0.6 end

    if slot:GetState() == 2 then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end
end


---@param slot Entity
function BloodDonationMachine:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function BloodDonationMachine:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function BloodDonationMachine:OnDestroy(slot)
    for angle = 0, 359, 45 do
        local velocity = Vector(5, 0):Rotated(angle)

        local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BALLOON, 0, slot.Position, velocity, slot):ToTear()
        tear.FallingAcceleration = 1.5
        tear.FallingSpeed = -17
        tear.Scale = tear.Scale * 1.3
    end

    slot:GetSprite():Play("Death", true)
end


return BloodDonationMachine