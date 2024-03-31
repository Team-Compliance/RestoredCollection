local function InitSounds()
    if USoEI then
        for _,collectible in pairs(RestoredCollection.Enums.CollectibleType) do
            if collectible > 0 then
                local collectibleConf = Isaac.GetItemConfig():GetCollectible(collectible)
                local sound = Isaac.GetSoundIdByName(collectibleConf.Name)
                if sound > 0 then
                    USoEI.AddSoundToItem(collectible, sound)
                    if collectible == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX then
                        for i = 1, 5 do
                            USoEI.AddSoundToItem(collectible - i, sound)
                        end
                    end
                end
            end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, InitSounds)
