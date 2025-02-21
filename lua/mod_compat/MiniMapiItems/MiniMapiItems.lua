--MinimapAPI and Minimap Items Compatibility
if not MinimapAPI then return end

if not MiniMapiItemsAPI then return end

local Collectibles = Sprite()
Collectibles:Load("gfx/ui/minimapitems/restoreditems_collectibles_icons.anm2", true)

MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS, Collectibles, "CustomIcons", 0)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS, Collectibles, "CustomIcons", 1)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE, Collectibles, "CustomIcons", 2)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS, Collectibles, "CustomIcons", 3)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE, Collectibles, "CustomIcons", 4)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH, Collectibles, "CustomIcons", 5)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION, Collectibles, "CustomIcons", 6)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART, Collectibles, "CustomIcons", 7)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE, Collectibles, "CustomIcons", 8)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN, Collectibles, "CustomIcons", 9)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST, Collectibles, "CustomIcons", 10)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS, Collectibles, "CustomIcons", 11)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER, Collectibles, "CustomIcons", 12)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD, Collectibles, "CustomIcons", 13)
for i = 0, 5 do
    MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i, Collectibles, "CustomIcons", 14)
end
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR, Collectibles, "CustomIcons", 15)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS, Collectibles, "CustomIcons", 16)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS, Collectibles, "CustomIcons", 17)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER, Collectibles, "CustomIcons", 18)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN, Collectibles, "CustomIcons", 19)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK, Collectibles, "CustomIcons", 20)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE, Collectibles, "CustomIcons", 21)
MiniMapiItemsAPI:AddCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC, Collectibles, "CustomIcons", 22)