--MinimapAPI and Minimap Items Compatibility
if not MinimapAPI then return end

local Pickups = Sprite()
Pickups:Load("gfx/ui/minimapitems/restoreditems_pickups_icons.anm2", true)
MinimapAPI:AddIcon("SunHeartIcon", Pickups, "CustomIcons", 0)
MinimapAPI:AddPickup(RestoredItemsPack.Enums.Pickups.Hearts.HEART_SUN, "SunHeartIcon", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, RestoredItemsPack.Enums.Pickups.Hearts.HEART_SUN, MinimapAPI.PickupNotCollected, "hearts", 13000)
MinimapAPI:AddIcon("ImmortalHeartIcon", Pickups, "CustomIcons", 1)
MinimapAPI:AddPickup(RestoredItemsPack.Enums.Pickups.Hearts.HEART_IMMORTAL, "ImmortalHeartIcon", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, RestoredItemsPack.Enums.Pickups.Hearts.HEART_IMMORTAL, MinimapAPI.PickupNotCollected, "hearts", 13000)
MinimapAPI:AddIcon("IllusionHeartIcon", Pickups, "CustomIcons", 2)
MinimapAPI:AddPickup(RestoredItemsPack.Enums.Pickups.Hearts.HEART_ILLUSION, "IllusionHeartIcon", EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, RestoredItemsPack.Enums.Pickups.Hearts.HEART_ILLUSION, MinimapAPI.PickupNotCollected, "hearts", 13000)
if not MiniMapiItemsAPI then return end

local Collectibles = Sprite()
Collectibles:Load("gfx/ui/minimapitems/restoreditems_collectibles_icons.anm2", true)
for _,item in pairs(RestoredItemsPack.Enums.CollectibleType) do
    MiniMapiItemsAPI:AddCollectible(item, Collectibles, "CustomIcons", item - RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS)
end