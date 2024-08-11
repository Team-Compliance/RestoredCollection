local localversion = 1.0
local name = "Dice Bombs API"

local function load(data)
	DiceBombs = RegisterMod(name, 1)
	DiceBombs.Version = localversion
    DiceBombs.Loaded = false

    local DiceBombSpritesheets = {
        [CollectibleType.COLLECTIBLE_D1] = {"gfx/items/pick ups/bombs/costumes/dice_d1.png", "gfx/items/pick ups/bombs/costumes/dice_d1_gold.png"},
        [CollectibleType.COLLECTIBLE_D4] = {"gfx/items/pick ups/bombs/costumes/dice_d4.png", "gfx/items/pick ups/bombs/costumes/dice_d4_gold.png"},
        [CollectibleType.COLLECTIBLE_D6] = {"gfx/items/pick ups/bombs/costumes/dice_d6.png", "gfx/items/pick ups/bombs/costumes/dice_d6_gold.png"},
        [CollectibleType.COLLECTIBLE_D8] = {"gfx/items/pick ups/bombs/costumes/dice_d8.png", "gfx/items/pick ups/bombs/costumes/dice_d8_gold.png"},
        [CollectibleType.COLLECTIBLE_D20] = {"gfx/items/pick ups/bombs/costumes/dice_d20.png", "gfx/items/pick ups/bombs/costumes/dice_d20_gold.png"},
        [CollectibleType.COLLECTIBLE_D100] = {"gfx/items/pick ups/bombs/costumes/dice_d100.png", "gfx/items/pick ups/bombs/costumes/dice_d100_gold.png"},
        [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = {"gfx/items/pick ups/bombs/costumes/dice_spindown.png", "gfx/items/pick ups/bombs/costumes/dice_spindown_gold.png"},
    }

    if data then
        DiceBombSpritesheets = data
    end
    
    function DiceBombs.AddDice(diceID, gfxNormal, gfxGolden)
        if diceID and type(diceID) == "number" and not DiceBombSpritesheets[diceID] then
            local normalBombGFX = "gfx/items/pick ups/bombs/costumes/dice_modded.png"
            local goldenBombGFX = "gfx/items/pick ups/bombs/costumes/dice_modded_gold.png"
            if gfxNormal and type(gfxNormal) == "string" then normalBombGFX = gfxNormal end
            if gfxGolden and type(gfxGolden) == "string" then goldenBombGFX = gfxGolden end
            DiceBombSpritesheets[diceID] = {normalBombGFX, goldenBombGFX}
        end
    end

    function DiceBombs.GetDiceBombsSprites(dice)
        if dice then
            return DiceBombSpritesheets[dice]
        end
        return DiceBombSpritesheets
    end

    function DiceBombs:ModReset()
        DiceBombs.Loaded = false
    end
    DiceBombs:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, DiceBombs.ModReset)

	print("[".. DiceBombs.Name .."]", "is loaded. Version "..DiceBombs.Version)
	DiceBombs.Loaded = true
end

if DiceBombs then
    if DiceBombs.Version < localversion or not DiceBombs.Loaded then
        if not DiceBombs.Loaded then
            print("Reloading [".. DiceBombs.Name .."]")
        else
            print("[".. DiceBombs.Name .."]", " found old script V" .. DiceBombs.Version .. ", found new script V" .. localversion .. ". replacing...")
        end
        local data = DiceBombs.GetDiceBombsSprites()
        DiceBombs = nil
        load(data)
    end
elseif not DiceBombs then
    load()
end