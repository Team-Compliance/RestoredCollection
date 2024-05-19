TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PlayerData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "FamiliarData", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HasMorphedKeepersRope", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "CustomHealthAPISave", CustomHealthAPI.Library.GetHealthBackup(), TSIL.Enums.VariablePersistenceMode.REMOVE_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HiddenItemMangerSave", RestoredCollection.HiddenItemManager:GetSaveData(), TSIL.Enums.VariablePersistenceMode.REMOVE_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PlayersCollectedLuckySeven", false, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "LastPillUsed", -1, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "MonsterTeleTable", {}, TSIL.Enums.VariablePersistenceMode.RESET_LEVEL)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HPUpDownEnemies", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "PacifistLevels", {}, TSIL.Enums.VariablePersistenceMode.RESET_RUN)

TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "DSS", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "HeartStyleRender", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "IllusionHeartSpawnChance", 20, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "IllusionClonesPlaceBombs", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "SunHeartSpawnChance", 20, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "ImmortalHeartSpawnChance", 20, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "ActOfContrictionImmortal", 1, TSIL.Enums.VariablePersistenceMode.NONE, true)
TSIL.SaveManager.AddPersistentVariable(RestoredCollection, "DisabledItems", {}, TSIL.Enums.VariablePersistenceMode.NONE, true)

DiceBombs = {}
LunchBox = {}
IllusionMod = {}
ComplianceSun = {}
ComplianceImmortal = {}
PillCrusher = {}