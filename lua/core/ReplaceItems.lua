local ReplaceTable = {}
local Helpers = RestoredCollection.Helpers

local function AddReplacableItems(old, new)
    if old and old > 0 and new and new > 0 then
        ReplaceTable[old] = new
    end
end

RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    ReplaceTable = {}
    if AntibirthItemPack then
        AddReplacableItems(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR)
        AddReplacableItems(AntibirthItemPack.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
        AddReplacableItems(AntibirthItemPack.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE)
        AddReplacableItems(AntibirthItemPack.CollectibleType.COLLECTIBLE_MENORAH, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH)
        AddReplacableItems(AntibirthItemPack.CollectibleType.COLLECTIBLE_STONE_BOMBS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS)
    end
    if LostItemsPack then
        AddReplacableItems(LostItemsPack.CollectibleType.ANCIENT_REVELATION, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION)
        AddReplacableItems(LostItemsPack.CollectibleType.BETHS_HEART, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART)
        AddReplacableItems(LostItemsPack.CollectibleType.BLANK_BOMBS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS)
        AddReplacableItems(LostItemsPack.CollectibleType.BOOK_OF_ILLUSIONS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS)
        AddReplacableItems(LostItemsPack.CollectibleType.CHECKED_MATE, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE)
        AddReplacableItems(LostItemsPack.CollectibleType.DICE_BOMBS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
        AddReplacableItems(LostItemsPack.CollectibleType.KEEPERS_ROPE, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE)
        AddReplacableItems(LostItemsPack.CollectibleType.LUCKY_SEVEN, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN)
        AddReplacableItems(LostItemsPack.CollectibleType.MAXS_HEAD, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD)
        AddReplacableItems(LostItemsPack.CollectibleType.OL_LOPPER, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER)
        AddReplacableItems(LostItemsPack.CollectibleType.PACIFIST, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST)
        AddReplacableItems(LostItemsPack.CollectibleType.PILL_CRUSHER, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER)
        AddReplacableItems(LostItemsPack.CollectibleType.SAFETY_BOMBS, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS)
        AddReplacableItems(LostItemsPack.CollectibleType.VOODOO_PIN, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN)
    end
    if communityRemix then
        AddReplacableItems(CollectibleType.COLLECTIBLE_MENORAH, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH)
    end

    if REPENTOGON then
        local itemConf = Isaac.GetItemConfig()
        for oldItem, newItem in pairs(ReplaceTable) do
            if ItemConfig.Config.IsValidCollectible(oldItem) then
                itemConf:GetCollectible(oldItem).Hidden = true
            end
        end
    end
end)

---@param player EntityPlayer
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, player)
    local itemConf = Isaac.GetItemConfig()
    for oldItem, newItem in pairs(ReplaceTable) do
        if ItemConfig.Config.IsValidCollectible(oldItem) then
            if player:HasCollectible(oldItem, true) then
                if itemConf:GetCollectible(oldItem).Type == ItemType.ITEM_ACTIVE then
                    for i = 0, 2 do
                        if player:GetActiveItem(i) == oldItem then
                            local charge = Helpers.GetCharge(player, i)
                            player:RemoveCollectible(oldItem, false, i, false)
                            local varData = 0
                            if REPENTOGON then
                                varData = player:GetActiveItemDesc(i).VarData
                            end
                            player:AddCollectible(newItem, charge, false, i, varData)
                        end
                    end
                end
                if itemConf:GetCollectible(oldItem).Type == ItemType.ITEM_PASSIVE then
                    player:RemoveCollectible(oldItem, false, ActiveSlot.SLOT_PRIMARY, false)
                    player:AddCollectible(newItem, 0, false)
                end
            end
        end
    end
end)

RestoredCollection:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, function(_, collectible)
    for oldItem, newItem in pairs(ReplaceTable) do
        if ItemConfig.Config.IsValidCollectible(oldItem) then
            if collectible == oldItem then
                return newItem
            end
        end
    end
end)

---@param pickup EntityPickup
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, pickup)
    for oldItem, newItem in pairs(ReplaceTable) do
        if ItemConfig.Config.IsValidCollectible(oldItem) then
            if pickup.SubType == oldItem then
                pickup:Morph(pickup.Type, pickup.Variant, newItem, true, true)
            end
        end
    end
end, PickupVariant.PICKUP_COLLECTIBLE)