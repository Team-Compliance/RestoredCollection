if not Encyclopedia then
	return
end

local Wiki = include("lua.mod_compat.encyclopedia.wiki")

-- Items
--Stone bombs
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_STONE_BOMBS,
	WikiDesc = Wiki.StoneBombs,
	Pools = {
		Encyclopedia.ItemPools.POOL_BOMB_BUM,
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	},
})

--Blank bombs
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BLANK_BOMBS,
	WikiDesc = Wiki.BlankBombs,
	Pools = {
	  Encyclopedia.ItemPools.POOL_TREASURE,
	  Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	  Encyclopedia.ItemPools.POOL_BOMB_BUM,
	},
  })

--Checked mate
Encyclopedia.AddItem({
	ID =RestoredCollection.Enums.CollectibleType.COLLECTIBLE_CHECKED_MATE,
	WikiDesc = Wiki.CheckedMate,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_WOODEN_CHEST,
		Encyclopedia.ItemPools.POOL_BABY_SHOP,
	},
	Class = "Compliance",
	ModName = "Compliance"
})
if Sewn_API then
	Sewn_API:AddEncyclopediaUpgrade(
		RestoredCollection.Enums.Familiars.CHECKED_MATE.Variant,
		"Increases damage",
		"Increases damage further and range"
	)
end

--Book of despair
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_DESPAIR,
	WikiDesc = Wiki.BookOfDespair,
	Pools = {
	  	Encyclopedia.ItemPools.POOL_LIBRARY,
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
	},
})

--Bowl of tears
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS,
	WikiDesc = Wiki.BowlOfTears,
	Pools = {
		Encyclopedia.ItemPools.POOL_ANGEL,
		Encyclopedia.ItemPools.POOL_GREED_ANGEL,
	},
})

--Donkey jawbone
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DONKEY_JAWBONE,
	WikiDesc = Wiki.DonkeyJawbone,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
	},
})

--Menorah
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MENORAH,
	WikiDesc = Wiki.Menorah,
	Pools = {
		Encyclopedia.ItemPools.POOL_ANGEL,
		Encyclopedia.ItemPools.POOL_GREED_ANGEL,
	},
})

if Sewn_API then
	Sewn_API:AddEncyclopediaUpgrade(
		FamiliarVariant.MENORAH,
		"Higher fire rate per flame",
		"Higher fire rate per flame. You can keep firing even with no flames"
	)
end

--Dice Bombs
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS,
    WikiDesc = Wiki.DiceBombs,
    Pools = {
        Encyclopedia.ItemPools.POOL_SECRET,
        Encyclopedia.ItemPools.POOL_BOMB_BUM,
    },
})

--Ancient Revelation
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_ANCIENT_REVELATION,
    WikiDesc = Wiki.AncientRevelation,
    Pools = {
        Encyclopedia.ItemPools.POOL_ANGEL,
        Encyclopedia.ItemPools.POOL_GREED_ANGEL,
        Encyclopedia.ItemPools.POOL_ULTRA_SECRET,
    },
})

--Beth's Heart
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BETHS_HEART,
    WikiDesc = Wiki.BethsHeart,
    Pools = {
        Encyclopedia.ItemPools.POOL_TREASURE,
        Encyclopedia.ItemPools.POOL_GREED_SHOP,
        Encyclopedia.ItemPools.POOL_BABY_SHOP,
    },
})

--Book Of Illusions
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOOK_OF_ILLUSIONS,
    WikiDesc = Wiki.BookOfIllusions,
    Pools = {
        Encyclopedia.ItemPools.POOL_DEVIL,
        Encyclopedia.ItemPools.POOL_LIBRARY,
        Encyclopedia.ItemPools.POOL_GREED_DEVIL,
    },
})

--Keeper's Rope
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_KEEPERS_ROPE,
    WikiDesc = Wiki.KeepersRope,
    Pools = {
        Encyclopedia.ItemPools.POOL_SECRET,
        Encyclopedia.ItemPools.POOL_GREED_SECRET,
    },
})

---Lucky seven
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN,
    WikiDesc = Wiki.LuckySeven,
    Pools = {
        Encyclopedia.ItemPools.POOL_TREASURE,
        Encyclopedia.ItemPools.POOL_CRANE_GAME,
        Encyclopedia.ItemPools.POOL_GREED_SHOP,
    },
})

--Pacifist
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PACIFIST,
    WikiDesc = Wiki.Pacifist,
    Pools = {
        Encyclopedia.ItemPools.POOL_ANGEL
    },
})

--Pill crusher
Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PILL_CRUSHER,
    WikiDesc = Wiki.PillCrusher,
    Pools = {
        Encyclopedia.ItemPools.POOL_SHOP,
        Encyclopedia.ItemPools.POOL_GREED_SHOP,
    },
})

--Safety bombs
Encyclopedia.AddItem({
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_SAFETY_BOMBS,
    WikiDesc = Wiki.SafetyBombs,
    Pools = {
        Encyclopedia.ItemPools.POOL_TREASURE,
        Encyclopedia.ItemPools.POOL_GREED_TREASURE,
        Encyclopedia.ItemPools.POOL_BOMB_BUM,
    },
	ModName = "Compliance",
	Class = "Compliance",
})

--Voodoo Pin
Encyclopedia.AddItem({
    ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_VOODOO_PIN,
    WikiDesc = Wiki.VoodooPin,
    Pools = {
        Encyclopedia.ItemPools.POOL_SHOP,
        Encyclopedia.ItemPools.POOL_GREED_SHOP,
    },
	ModName = "Compliance",
	Class = "Compliance",
})

Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MAXS_HEAD,
	WikiDesc = Wiki.MaxsHead,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_GOLDEN_CHEST,
	},
})

Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER,
	WikiDesc = Wiki.OlLopper,
	Pools = {
		Encyclopedia.ItemPools.POOL_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_TREASURE,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
	}
})

Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK,
	WikiDesc = Wiki.PumpkinMask,
	Pools = {
		Encyclopedia.ItemPools.POOL_DEVIL,
		Encyclopedia.ItemPools.POOL_GREED_DEVIL,
		Encyclopedia.ItemPools.POOL_ROTTEN_BEGGAR,
	}
})

Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_MELTED_CANDLE,
	WikiDesc = Wiki.MeltedCandle,
	Pools = {
		Encyclopedia.ItemPools.POOL_SHOP,
		Encyclopedia.ItemPools.POOL_GREED_SHOP,
	}
})

Encyclopedia.AddItem({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_TAMMYS_TAIL_TC,
	WikiDesc = Wiki.TammysTail,
	Pools = {
		Encyclopedia.ItemPools.POOL_ANGEL,
	}
})

Encyclopedia.AddTrinket({
	ModName = "Compliance",
	Class = "Compliance",
	ID = RestoredCollection.Enums.TrinketType.TRINKET_GAME_SQUID_TC,
	WikiDesc = Wiki.GameSquid,
})


--Hide
for i = 0, 5 do
	Encyclopedia.AddItem({
		ModName = "Compliance",
		Class = "Compliance",
		ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUNCH_BOX - i,
		WikiDesc = Wiki.LunchBox,
		Pools = {
		Encyclopedia.ItemPools.POOL_SHOP,
		},
		Hide = i > 0 and true or false,
	})
end

local TransformationItems = {
	Isaac.GetItemIdByName("Spun transform"),
	Isaac.GetItemIdByName("Mom transform"),
	Isaac.GetItemIdByName("Guppy transform"),
	Isaac.GetItemIdByName("Fly transform"),
	Isaac.GetItemIdByName("Bob transform"),
	Isaac.GetItemIdByName("Mushroom transform"),
	Isaac.GetItemIdByName("Baby transform"),
	Isaac.GetItemIdByName("Angel transform"),
	Isaac.GetItemIdByName("Devil transform"),
	Isaac.GetItemIdByName("Poop transform"),
	Isaac.GetItemIdByName("Book transform"),
	Isaac.GetItemIdByName("Spider transform"),
}

for _, item in ipairs(TransformationItems) do
	Encyclopedia.AddItem({
		ModName = "Compliance",
		Class = "Compliance",
		ID = item,
		Hide = true,
	})
end

RestoredCollection.Enums.Wiki = Wiki