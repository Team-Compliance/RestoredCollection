RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if communityRemix then
        communityRemix.TransformationItem[RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD] = {NullItemID.ID_MAX}
    end
end)