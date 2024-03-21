
RestoredItemsCollection = RegisterMod("Restored Items Collection", 1)

--Functions that will be called when starting run
RestoredItemsCollection.CallOnStart = {}

local LOCAL_TSIL = require("lua.extraLibs.loi.TSIL")
LOCAL_TSIL.Init("lua.extraLibs.loi")
local HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
RestoredItemsCollection.HiddenItemManager = HiddenItemManager:Init(RestoredItemsCollection)

include("lua.extraLibs.customhealthapi.core")
include("lua.extraLibs.custom_shockwave_api")
--core
include("lua.core.enums")
include("lua.core.globals")
include("lua.core.save_manager")
include("lua.core.customhealth")
include("lua.core.dss.deadseascrolls")
include("lua.core.BlockDisabledItems")
include("lua.core.ReplaceItems")

--entities
include("lua.entities.clots.ImmortalClot")
include("lua.entities.clots.SunClot")

--items
--active
include("lua.items.active.LunchBox")
include("lua.items.active.BookOfDespair")
include("lua.items.active.BowlOfTears")

include("lua.items.active.BookOfIllusions")
include("lua.items.active.PillCrusher")
include("lua.items.active.VoodooPin")

--passive
include("lua.items.passive.BlankBombs")
include("lua.items.passive.StoneBombs")
include("lua.items.passive.CheckedMate")
include("lua.items.passive.DiceBombs")
include("lua.items.passive.DonkeyJawbone")
include("lua.items.passive.Menorah")

include("lua.items.passive.AncientRevelation")
include("lua.items.passive.BethsHeart")
include("lua.items.passive.KeepersRope")
include("lua.items.passive.LuckySeven")
include("lua.items.passive.Pacifist")
include("lua.items.passive.SafetyBombs")
include("lua.items.passive.OlLopper")
include("lua.items.passive.MaxsHead")
include("lua.items.passive.PumpkinMask")
include("lua.items.passive.MeltedCandle")

--trinkets
include("lua.items.trinkets.GameSquid")

-- pickups
include("lua.items.pickups.ImmortalHeart")
include("lua.items.pickups.SunHeart")
include("lua.items.pickups.IllusionHearts")

--mod compatibility
include("lua.mod_compat.eid.eid")
include("lua.mod_compat.encyclopedia.encyclopedia")
include("lua.mod_compat.MiniMapiItems.MiniMapiItems")

--misc
include("lua.items.funny")
include("lua.items.Translations")
