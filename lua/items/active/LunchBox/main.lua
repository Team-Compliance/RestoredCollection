local LunchBoxLocal = {}
local game = Game()
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()
local RepentogonTargetCol = REPENTOGON and RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX or (RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - 5)
local itemConfig = Isaac.GetItemConfig()

---@param player EntityPlayer
---@return boolean
local function isNoRedHealthCharacter(player)
    local t = player:GetPlayerType()
    return REPENTOGON and player:GetHealthType() ~= HealthType.RED and player:GetHealthType() ~= HealthType.COIN or
    CustomHealthAPI and CustomHealthAPI.PersistentData.CharactersThatCantHaveRedHealth[t] or
    Helpers.IsGhost(player) or t == PlayerType.PLAYER_THESOUL
end

LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_HALF, 1, function (player, pickup)
    pickup:PlayPickupSound()
end)
LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_FULL, 2, function (player, pickup)
    pickup:PlayPickupSound()
end)
LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_SCARED, 2, function (player, pickup)
    pickup:PlayPickupSound()
end)
LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_DOUBLEPACK, 4, function (player, pickup)
    pickup:PlayPickupSound()
end)
LunchBox.AddPickup(PickupVariant.PICKUP_HEART, HeartSubType.HEART_BLENDED, 1, function (player, pickup)
    player:AddSoulHearts(1)
    pickup:PlayPickupSound()
end)
if RepentancePlusMod then
    LunchBox.AddPickup(PickupVariant.PICKUP_HEART, RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HOARDED, 8, function (player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0)
    end)
    LunchBox.AddPickup(PickupVariant.PICKUP_HEART, RepentancePlusMod.CustomPickups.TaintedHearts.HEART_CURDLED, 2, function (player)
        sfx:Play(SoundEffect.SOUND_MEAT_JUMPS)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
        local s = isNoRedHealthCharacter(player) and 1 or 0
        if player:GetPlayerType() == PlayerType.PLAYER_THELOST
        or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B
        or player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
            s = 3
        elseif player:GetPlayerType() == PlayerType.PLAYER_KEEPER
        or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            s = 4
        elseif player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
            s = 5
        end
        local trueCollider = player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B and player:GetOtherTwin() or player
        CustomHealthAPI.PersistentData.IgnoreSumptoriumHandling = true
        Isaac.Spawn(3, FamiliarVariant.BLOOD_BABY, s, trueCollider.Position, Vector.Zero, trueCollider)
        CustomHealthAPI.PersistentData.IgnoreSumptoriumHandling = false
    end)
    LunchBox.AddPickup(PickupVariant.PICKUP_HEART, RepentancePlusMod.CustomPickups.TaintedHearts.HEART_SAVAGE, 2, function (player)
        RepentancePlusMod.addTemporaryDmgBoost(player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
    end)
    LunchBox.AddPickup(PickupVariant.PICKUP_HEART, RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HARLOT, 1, function (player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES)
        player:GetEffects():AddCollectibleEffect(RepentancePlusMod.CustomCollectibles.HARLOT_FETUS_NULL, false, 1)
        player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS)
    end)
    LunchBox.AddPickup(PickupVariant.PICKUP_HEART, RepentancePlusMod.CustomPickups.TaintedHearts.HEART_HARLOT, 1, function (player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0)
        player:AddBlackHearts(1)
        sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 0)
    end)
end
if FiendFolio then
    LunchBox.AddPickup(FiendFolio.PICKUP.VARIANT.BLENDED_BLACK_HEART, 0, 1, function (player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0)
        player:AddBlackHearts(1)
        sfx:Play(SoundEffect.SOUND_UNHOLY, 1, 0)
    end)
    LunchBox.AddPickup(FiendFolio.PICKUP.VARIANT.BLENDED_IMMORAL_HEART, 0, 1, function (player)
        sfx:Play(SoundEffect.SOUND_BOSS2_BUBBLES, 1, 0)
        if CustomHealthAPI.Helper.CanPickKey(player, "IMMORAL_HEART") then
            CustomHealthAPI.Library.AddHealth(player, "IMMORAL_HEART", 1, true)
            sfx:Play(FiendFolio.Sounds.FiendHeartPickup, 1, 0, false, 1)
        end
    end)
end


---@param player EntityPlayer
---@return boolean
local function DoesLunchBoxNeedsCharge(player)
    for slot = 0,2 do
        for col = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX, RepentogonTargetCol, -1 do
            if player:GetActiveItem(slot) == col then
                local item = itemConfig:GetCollectible(player:GetActiveItem(slot))
                local charge = Helpers.GetCharge(player, slot)
                if charge < item.MaxCharges then
                    return true
                end
            end
        end
    end
    return false
end

---@param collectible CollectibleType | integer
---@param rng RNG
---@param player EntityPlayer
---@param useflag UseFlag | integer
---@param slot integer
---@param customvardata integer
function LunchBoxLocal:Use(collectible, rng, player, useflag, slot, customvardata)
    local LunchBoxPool = {}
	for i = 1, Helpers.GetMaxCollectibleID() do
        if ItemConfig.Config.IsValidCollectible(i) then
            if itemConfig:GetCollectible(i).Tags & ItemConfig.TAG_FOOD == ItemConfig.TAG_FOOD then
                table.insert(LunchBoxPool,i)
            end
        end
    end
    local food = LunchBoxPool[rng:RandomInt(#LunchBoxPool) + 1]
    local spawnpos = game:GetRoom():FindFreePickupSpawnPosition(player.Position, 20, true)
    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, food, spawnpos, Vector.Zero, nil):ToPickup()
    sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0)
    if slot ~= -1 then
        local remove = false
        local wispSP = collectible
        if REPENTOGON then
            local itemDesc = player:GetActiveItemDesc(slot)
            wispSP = wispSP - itemDesc.VarData
            if itemDesc.VarData > 4 then
                remove = true
            else
                player:SetActiveVarData(itemDesc.VarData + 1, slot)
            end
        else
            if collectible == RepentogonTargetCol then
                remove = true
            else
                player:AddCollectible(collectible - 1, 0, false, slot)
            end
        end
        player:SetActiveCharge(Helpers.GetCharge(player, slot) - itemConfig:GetCollectible(collectible).MaxCharges)
        if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
            player:AddWisp(wispSP, player.Position)
        end
        return {Discharge = false, Remove = remove, ShowAnim = true}
    end
    return true
end
RestoredCollection:AddCallback(ModCallbacks.MC_USE_ITEM, LunchBoxLocal.Use, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX)
if not REPENTOGON then
    for i = 1, 5 do
        RestoredCollection:AddCallback(ModCallbacks.MC_USE_ITEM, LunchBoxLocal.Use, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i)
    end
end

local function HPLeft(player, slot, hp, collectible)
    if player:GetActiveItem(slot) == collectible and hp > 0 then
        local item = itemConfig:GetCollectible(player:GetActiveItem(slot))
        local charge = Helpers.GetCharge(player, slot)
        if charge < item.MaxCharges then
            player:SetActiveCharge(math.min(charge + hp, item.MaxCharges), slot)
            Game():GetHUD():FlashChargeBar(player, slot)
        end
        hp = math.max(0, charge + hp - item.MaxCharges)
    end
    return hp
end

RestoredCollection:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.IMPORTANT, function (_, pickup, collider, low)
    if collider.Type == EntityType.ENTITY_PLAYER and collider.Variant == 0 then
        local player = collider:ToPlayer()
        if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
            player = player:GetOtherTwin()
        end
        if DoesLunchBoxNeedsCharge(player) and LunchBox.GetPickupData(pickup.Variant) ~= nil and LunchBox.GetPickupData(pickup.Variant, pickup.SubType) ~= nil then
            if CustomHealthAPI then
                local collect = Helpers.CollectCustomPickup(player, pickup)
                
                if collect ~= nil then
                    return collect
                end
            elseif pickup:IsShopItem() then
                return
            end
            local hp = LunchBox.GetPickupData(pickup.Variant, pickup.SubType).Charge
            
            if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGGYS_BOW) then
                hp = hp * 2
            end
            
            for slot = 0,2 do
                if REPENTOGON then
                    hp = HPLeft(player, slot, hp, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX)
                else
                    for i = 0, 5 do
                        hp = HPLeft(player, slot, hp, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i)
                    end
                end
            end
            LunchBox.GetPickupData(pickup.Variant, pickup.SubType).Function(player, pickup)
            player:AddHearts(hp)
            Game():GetLevel():SetHeartPicked()
            Game():ClearStagesWithoutHeartsPicked()
            Game():SetStateFlag(GameStateFlag.STATE_HEART_BOMB_COIN_PICKED, true)
            return true
        end
    end
end)