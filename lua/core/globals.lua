local Helpers = RestoredCollection.Helpers
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PlayerData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "FamiliarData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HasMorphedKeepersRope", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
if not REPENTOGON then
    TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HiddenItemMangerSave", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
end
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "LastPillUsed", -1, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "MonsterTeleTable", {}, TSIL.Enums.VariablePersistenceMode.RESET_LEVEL)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HPUpDownEnemies", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PacifistLevels", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)

TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "DSS", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "IllusionClonesPlaceBombs", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PerfectIllusion", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "IllusionInstaDeath", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "DisabledItems", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "MaxsHead", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)

RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
    for _, bomb in ipairs(Isaac.FindByType(EntityType.ENTITY_BOMB)) do
        Helpers.GetData(bomb).BombInit = true
    end
end)