
RestoredCollection = RegisterMod("Restored Collection", 1)

local LOCAL_TSIL = require("lua.extraLibs.loi.TSIL")
LOCAL_TSIL.Init("lua.extraLibs.loi")
if not REPENTOGON then
    local HiddenItemManager = include("lua.extraLibs.hidden_item_manager")
    RestoredCollection.HiddenItemManager = HiddenItemManager:Init(RestoredCollection)
end


include("lua.helpers.Helpers")
include("lua.extraLibs.hellfirejuneMSHack")

--apis
--include("lua.extraLibs.APIs.customhealthapi.core")
include("lua.extraLibs.APIs.custom_shockwave_api")
include("lua.extraLibs.APIs.custom_bomb_flags")
include("lua.extraLibs.APIs.IllusionAPI")
include("lua.extraLibs.APIs.PillCrusherAPI")
include("lua.extraLibs.APIs.LunchBoxAPI")
include("lua.extraLibs.APIs.DiceBombsAPI")

--core
include("lua.core.enums")
include("lua.core.globals")
include("lua.core.save_manager")
include("lua.core.customhealth")
include("lua.core.dss.deadseascrolls")
include("lua.core.BlockDisabledItems")
include("lua.core.ReplaceItems")

include("lua.core.VanillaPostTriggerWeaponFired")
include("lua.core.achievements")

--items
--active
include("lua.items.active.LunchBox.main")
include("lua.items.active.BookOfDespair.main")
include("lua.items.active.BowlOfTears.main")
include("lua.items.active.BookOfIllusions.main")
include("lua.items.active.PillCrusher.main")
include("lua.items.active.VoodooPin.main")

--passive
include("lua.items.passive.BlankBombs.main")
include("lua.items.passive.StoneBombs.main")
include("lua.items.passive.CheckedMate.main")
include("lua.items.passive.DiceBombs.main")
include("lua.items.passive.DonkeyJawbone.main")
include("lua.items.passive.Menorah.main")

include("lua.items.passive.AncientRevelation.main")
include("lua.items.passive.BethsHeart.main")
include("lua.items.passive.KeepersRope.main")
include("lua.items.passive.LuckySeven.main")
include("lua.items.passive.Pacifist.main")
include("lua.items.passive.SafetyBombs.main")
include("lua.items.passive.OlLopper.main")
include("lua.items.passive.MaxsHead.main")
include("lua.items.passive.PumpkinMask.main")
include("lua.items.passive.MeltedCandle.main")
include("lua.items.passive.TammysTail.main")

--trinkets
include("lua.items.trinkets.GameSquid.main")

--pickups
include("lua.entities.illusions.main")

--mod compatibility
include("lua.mod_compat.eid.eid")
include("lua.mod_compat.encyclopedia.encyclopedia")
include("lua.mod_compat.MiniMapiItems.MiniMapiItems")
include("lua.mod_compat.community_remix.cr_compat")

--misc
include("lua.items.funny")
include("lua.items.Translations")