local Enums = {}

Enums.MouseClick = {LEFT = 0, RIGHT = 1, WHEEL = 2, BACK = 3, FORWARD = 4}

Enums.Entities = {
					BLANK_EXPLOSION_EFFECT =
					{
						Type = Isaac.GetEntityTypeByName("Blank Explosion"),
						Variant = Isaac.GetEntityVariantByName("Blank Explosion"),
						SubType = 0
					},
					DONKEY_JAWBONE = {
						Type = Isaac.GetEntityTypeByName("Antibirth Donkey Jawbone"),
						Variant = Isaac.GetEntityVariantByName("Antibirth Donkey Jawbone"),
					},
					KEEPERS_ROPE = {
						Type = Isaac.GetEntityTypeByName("Hanging rope"),
						Variant = Isaac.GetEntityVariantByName("Hanging rope"),
						SubType = 0
					},
					LUCKY_SEVEN_SLOT = {
						Type = Isaac.GetEntityTypeByName("Lucky Seven Slot"),
						Variant = Isaac.GetEntityVariantByName("Lucky Seven Slot"),
						SubType = 0
					},
					LUCKY_SEVEN_MACHINE_SPARKLES = {
						Type = Isaac.GetEntityTypeByName("Machine Sparkles"),
						Variant = Isaac.GetEntityVariantByName("Machine Sparkles"),
						SubType = 0
					},
					LUCKY_SEVEN_TEAR_SPARKLES = {
						Type = Isaac.GetEntityTypeByName("Tear Sparkles"),
						Variant = Isaac.GetEntityVariantByName("Tear Sparkles"),
						SubType = 0
					},
					LUCKY_SEVEN_CORD_END = {
						Type = Isaac.GetEntityTypeByName("Crane Cord End"),
						Variant = Isaac.GetEntityVariantByName("Crane Cord End"),
						SubType = 0
					},
					LUCKY_SEVEN_CORD_HANDLER = {
						Type = Isaac.GetEntityVariantByName("Crane Cord Handler"),
						Variant = Isaac.GetEntityVariantByName("Crane Cord Handler"),
						SubType = 0
					},
					LUCKY_SEVEN_CRANE_CORD = {
						Type = EntityType.ENTITY_EVIS,
						Variant = 10,
						SubType = 231
					},
					VOODOO_PIN_TEAR = {
						Type = Isaac.GetEntityTypeByName("Voodoo Pin Tear"),
						Variant = Isaac.GetEntityVariantByName("Voodoo Pin Tear"),
						SubType = 0
					},
					VOODOO_PIN_SHATTER = {
						Type = Isaac.GetEntityTypeByName("Voodoo Pin Shatter"),
						Variant = Isaac.GetEntityVariantByName("Voodoo Pin Shatter"),
						SubType = 0
					},
					OL_LOPPER_HEAD_HELPER = {
						Type = Isaac.GetEntityTypeByName("Ol Lopper Head"),
						Variant = Isaac.GetEntityVariantByName("Ol Lopper Head"),
						SubType = 0
					},
					OL_LOPPER_NECK = {
						Type = Isaac.GetEntityTypeByName("Ol Lopper Neck"),
						Variant = Isaac.GetEntityVariantByName("Ol Lopper Neck"),
						SubType = 0
					},
					MAXS_HEAD = {
						Type = Isaac.GetEntityTypeByName("Max's Face"),
						Variant = Isaac.GetEntityVariantByName("Max's Face"),
						SubType = 0,
					},
					WAX_TEAR_EFFECT = {
						Type = Isaac.GetEntityTypeByName("Wax Tear Effect"),
						Variant = Isaac.GetEntityVariantByName("Wax Tear Effect"),
						SubType = 0,
					}
				}

Enums.Familiars = 
				{
					CHECKED_MATE = {
									Type = Isaac.GetEntityTypeByName("Checked Mate"),
									Variant = Isaac.GetEntityVariantByName("Checked Mate"),
									SubType = 0
								},
					IMMORTAL_CLOT =
								{
									Type = Isaac.GetEntityTypeByName("Immortal Baby"),
									Variant = Isaac.GetEntityVariantByName("Immortal Baby"),
									SubType = 0
								},
					SUN_CLOT =
								{
									Type = Isaac.GetEntityTypeByName("Sun Baby"),
									Variant = Isaac.GetEntityVariantByName("Sun Baby"),
									SubType = 0
								},
					BETHS_HEART = 
								{
									Type = Isaac.GetEntityTypeByName("Beth's Heart"),
									Variant = Isaac.GetEntityVariantByName("Beth's Heart"),
									SubType = 0
								},
					MENORAH =   {
						Type = Isaac.GetEntityTypeByName("TC Menorah"),
						Variant = Isaac.GetEntityVariantByName("TC Menorah"),
						SubType = 0
					},
				}

Enums.BombVariant = {
	BOMB_STONE = Isaac.GetEntityVariantByName("Stone Bomb"),
	BOMB_SAFETY = Isaac.GetEntityVariantByName("Safety Bomb"),
	BOMB_DICE = Isaac.GetEntityVariantByName("Dice Bomb"),
	BOMB_BLANK = Isaac.GetEntityVariantByName("Blank Bomb"),
	BOMB_THUNDER = Isaac.GetEntityVariantByName("Thunder Bomb"),
}

Enums.CollectibleType = 
					{
						COLLECTIBLE_STONE_BOMBS = Isaac.GetItemIdByName("Stone Bombs"),
						COLLECTIBLE_BLANK_BOMBS = Isaac.GetItemIdByName("Blank Bombs"),
						COLLECTIBLE_CHECKED_MATE = Isaac.GetItemIdByName("Checked Mate"),
						COLLECTIBLE_DICE_BOMBS = Isaac.GetItemIdByName("Dice Bombs"),
						COLLECTIBLE_DONKEY_JAWBONE = Isaac.GetItemIdByName("​Donkey Jawbone"),
						COLLECTIBLE_MENORAH = Isaac.GetItemIdByName("​Menorah"),
						COLLECTIBLE_ANCIENT_REVELATION = Isaac.GetItemIdByName("Ancient Revelation"),
						COLLECTIBLE_BETHS_HEART = Isaac.GetItemIdByName("Beth's Heart"),
						COLLECTIBLE_KEEPERS_ROPE = Isaac.GetItemIdByName("Keeper's Rope"),
						COLLECTIBLE_LUCKY_SEVEN = Isaac.GetItemIdByName("Lucky Seven"),
						COLLECTIBLE_PACIFIST = Isaac.GetItemIdByName("Pacifist"),
						COLLECTIBLE_SAFETY_BOMBS = Isaac.GetItemIdByName("Safety Bombs"),
						COLLECTIBLE_OL_LOPPER = Isaac.GetItemIdByName("Ol' Lopper"),
						COLLECTIBLE_MAXS_HEAD = Isaac.GetItemIdByName("​Max's Head"),
						COLLECTIBLE_LUNCH_BOX = Isaac.GetItemIdByName("Lunch Box"),
						COLLECTIBLE_BOOK_OF_DESPAIR = Isaac.GetItemIdByName("Book of Despair"),
						COLLECTIBLE_BOWL_OF_TEARS = Isaac.GetItemIdByName("Bowl of Tears"),
						COLLECTIBLE_BOOK_OF_ILLUSIONS = Isaac.GetItemIdByName("Book of Illusions"),
						COLLECTIBLE_PILL_CRUSHER = Isaac.GetItemIdByName("Pill Crusher"),
						COLLECTIBLE_VOODOO_PIN = Isaac.GetItemIdByName("​Voodoo Pin"),
						COLLECTIBLE_PUMPKIN_MASK = Isaac.GetItemIdByName("​Pumpkin Mask"),
						COLLECTIBLE_MELTED_CANDLE = Isaac.GetItemIdByName("Melted Candle"),
					}

Enums.TrinketType = {
						TRINKET_GAME_SQUID_TC = Isaac.GetTrinketIdByName("​Game Squid"),
					}

Enums.Pickups = 
				{
					Hearts = 
							{
								HEART_IMMORTAL = REPENTOGON and Isaac.GetEntitySubTypeByName("Immortal Heart") or 902,
								HEART_SUN = REPENTOGON and Isaac.GetEntitySubTypeByName("Sun Heart") or 910,
								HEART_ILLUSION = REPENTOGON and Isaac.GetEntitySubTypeByName("Illusion Heart") or 9000,
							},
				}

Enums.SFX =
				{
					Hearts =
							{
								IMMORTAL_PICKUP = Isaac.GetSoundIdByName("immortal"),
								IMMORTAL_BREAK = Isaac.GetSoundIdByName("ImmortalHeartBreak"),
								SUN_PICKUP = Isaac.GetSoundIdByName("PickupSun"),
								SUN_BREAK = Isaac.GetSoundIdByName("SunBreak"),
								ILLUSION_PICKUP = Isaac.GetSoundIdByName("PickupIllusion"),
							},
				}

Enums.CustomBombFlags = {
	STONE_BOMB = 1 << 0,
	BLANK_BOMB = 1 << 1,
	DICE_BOMB = 1 << 2,
	SAFETY_BOMB = 1 << 3
}

if REPENTOGON then
	Enums.GiantBook = {
		BOOK_OF_DESPAIR = Isaac.GetGiantBookIdByName("Book of Despair"),
		BOOK_OF_ILLUSIONS = Isaac.GetGiantBookIdByName("Book of Illusions"),
	}
end

Enums.Callbacks = {
	ON_DICE_BOMB_EXPLOSION = "ON_DICE_BOMB_EXPLOSION",
	VANILLA_POST_TRIGGER_WEAPON_FIRED = "VANILLA_POST_TRIGGER_WEAPON_FIRED",
}

RestoredCollection.Enums = Enums