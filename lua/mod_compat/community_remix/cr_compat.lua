RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, function()
    if communityRemix then
        communityRemix.TransformationItem[RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD] = {NullItemID.ID_MAX}
        communityRemix.TransformationItem[RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC] = {NullItemID.ID_TAMMY}

        if EID then
            EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD, "Max")
            EID:assignTransformation("collectible", RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC, "Tammy")
        end
    end
end)