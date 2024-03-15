local function InitSounds()
    if USoEI then
        for _,collectible in pairs(RestoredItemsPack.Enums.CollectibleType) do
            local collectibleConf = Isaac.GetItemConfig():GetCollectible(collectible)
            local sound = Isaac.GetSoundIdByName(collectibleConf.Name)
            if sound > 0 then
                USoEI.AddSoundToItem(collectible, sound)
            end
        end
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, InitSounds)
