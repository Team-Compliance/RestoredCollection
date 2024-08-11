local LuckySevenSlot = include("lua.items.passive.LuckySeven.lucky_seven_scripts.LuckySevenSlot")
local RegularSlot = LuckySevenSlot:New("gfx/lucky_seven_regular_slot.anm2", 180)
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

---@param slot Entity
function RegularSlot:OnInit(slot)
    local data = Helpers.GetData(slot)

    data.CoinTearCooldown = 15
    data.TearDelay = 15

    slot:GetSprite():Play("Wiggle", true)
end


---@param slot Entity
---@param rng RNG
local function FireCoinTear(slot, rng)
    local tearSpeed = Vector.FromAngle(rng:RandomInt(360)):Resized(math.random(7, 10))
    local coinTear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.COIN, 0, slot.Position, tearSpeed, slot):ToTear()
    coinTear.CollisionDamage = 3.5
end


---@param slot Entity
function RegularSlot:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    if slot:GetState() == 2 then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end

    data.CoinTearCooldown = data.CoinTearCooldown - 1

    if data.CoinTearCooldown <= 0 then
        local rng = slot:GetDropRNG()
        FireCoinTear(slot, rng)
        data.CoinTearCooldown = data.TearDelay
    end
end


---@param slot Entity
function RegularSlot:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function RegularSlot:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function RegularSlot:OnDestroy(slot)
    local rng = slot:GetDropRNG()

    for _ = 0, rng:RandomInt(6) + 7 do
        FireCoinTear(slot, rng)
    end

    slot:GetSprite():Play("Death", true)
end


---@param tear EntityTear
local function OnCoinTearUpdate(_, tear)
    if tear.FrameCount ~= 1 then return end

    if tear.SpawnerType == EntityType.ENTITY_SLOT and
    tear.SpawnerVariant == RestoredCollection.Enums.Entities.LUCKY_SEVEN_SLOT.Variant then
        sfx:Stop(SoundEffect.SOUND_TEARS_FIRE)
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, OnCoinTearUpdate, TearVariant.COIN)


return RegularSlot