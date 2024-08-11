local LuckySevenSlot = include("lua.items.passive.LuckySeven.lucky_seven_scripts.LuckySevenSlot")
local DonationMachine = LuckySevenSlot:New("gfx/lucky_seven_donation_machine.anm2", 180)
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

---@param player EntityPlayer
---@return boolean
function DonationMachine:CanSpawn(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_KEEPERS_BOX)
end


---@param slot Entity
function DonationMachine:OnInit(slot)
    local data = Helpers.GetData(slot)
    ---@type EntityPlayer
    local player = data.SlotPlayer
    data.CoinCooldown = player.MaxFireDelay
    data.TearDelay = 59

    slot:GetSprite():Play("Wiggle", true)
end


---@param slot Entity
function SpawnGreedCoin(slot)
    local room = Game():GetRoom()

    ---@type Vector
    local spawningPos

    repeat
        spawningPos = Isaac.GetRandomPosition()
    until room:GetGridCollisionAtPos(spawningPos) == GridCollisionClass.COLLISION_NONE

    local coin = Isaac.Spawn(EntityType.ENTITY_ULTRA_COIN, 0, 0, spawningPos, Vector.Zero, slot):ToNPC()
    coin:AddEntityFlags(EntityFlag.FLAG_CHARM)
    coin.Visible = false
    coin.CanShutDoors = false
    coin.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
    Helpers.GetData(coin).IsDonationMachineCoin = true
end


---@param slot Entity
function DonationMachine:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    if REPENTOGON and slot:GetState() == 2 or data.HasBeenTouched then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end

    data.CoinCooldown = data.CoinCooldown - 1

    if data.CoinCooldown <= 0 then
        SpawnGreedCoin(slot)
        data.CoinCooldown = data.TearDelay
    end
end


---@param slot Entity
function DonationMachine:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function DonationMachine:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function DonationMachine:OnDestroy(slot)
    local rng = slot:GetDropRNG()

    for _ = 0, rng:RandomInt(3) + 1 do
        SpawnGreedCoin(slot)
    end

    slot:GetSprite():Play("Death", true)
end


---@param coin EntityNPC
function DonationMachine:OnCoinUpdate(coin)
    if not Helpers.GetData(coin).IsDonationMachineCoin then return end

    coin.Visible = true
    coin.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ENEMIES
end
RestoredCollection:AddCallback(ModCallbacks.MC_NPC_UPDATE, DonationMachine.OnCoinUpdate, EntityType.ENTITY_ULTRA_COIN)


---@param coin EntityNPC
---@param source EntityRef
function DonationMachine:OnCoinDamage(coin, _, _, source)
    if not Helpers.GetData(coin).IsDonationMachineCoin then return end
    if not source.Entity then return end

    if Helpers.GetData(source.Entity).IsDonationMachineCoin or
    source.Type == EntityType.ENTITY_PLAYER or source.SpawnerType == EntityType.ENTITY_PLAYER then
        return false
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, DonationMachine.OnCoinDamage, EntityType.ENTITY_ULTRA_COIN)


return DonationMachine