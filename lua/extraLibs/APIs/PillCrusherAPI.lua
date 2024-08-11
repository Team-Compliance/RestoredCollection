local localversion = 1.0
local name = "Pill Crusher API"

local function load()
	PillCrusher = RegisterMod(name, 1)
	PillCrusher.Version = localversion
    PillCrusher.Loaded = false

    --FF Helpers
    local FFPillColours = {
        --Normal
        101,102,103,104,105,106,107,108,109,110,
        111,112,113,114,115,116,117,118,119,120,
        --Horse
        2149,2150,2151,2152,2153,2154,2155,2156,2157,2158,
        2159,2160,2161,2162,2163,2164,2165,2166,2167,2168
    }
    --Just lets you pass isFFPill[101] or somethin to test it
    local isFFPill = {}
    do
        for i = 1, #FFPillColours do
            isFFPill[FFPillColours[i]] = true
        end
    end


    --API
    local CrushedPillEffects = {}
    local CrushedPillsRoom = {}

    ---@param pillEffect PillEffect
    ---@param name string
    ---@param func fun(player: EntityPlayer, rng: RNG, isGolden: boolean, isHorse: boolean, pillColor: PillColor)?
    function PillCrusher:AddPillCrusherEffect(pillEffect, name, func)
        if not func then
            func = function () end
        end
        CrushedPillEffects[pillEffect] = {name = name, func = func}
    end

    ---@param pillEffect PillEffect
    ---@return table
    function PillCrusher:GetPillCrusherEffect(pillEffect)
        return CrushedPillEffects[pillEffect]
    end

    ---@param pillEffect PillEffect
    ---@return boolean
    function PillCrusher:HasCrushedPill(pillEffect)
        return CrushedPillsRoom[pillEffect] ~= nil
    end

    ---@param pillEffect PillEffect
    ---@return integer
    function PillCrusher:GetCrushedPillNum(pillEffect)
        local num = CrushedPillsRoom[pillEffect]
        if not num then num = 0 end
        return num
    end

    ---@param pillEffect PillEffect
    ---@param isHorse boolean
    function PillCrusher:AddCrushedPillEffectForRoom(pillEffect, isHorse)
        local mult = isHorse and 2 or 1
        if CrushedPillsRoom[pillEffect] then
            CrushedPillsRoom[pillEffect] = CrushedPillsRoom[pillEffect] + 1 * mult
        else
            CrushedPillsRoom[pillEffect] = 1 * mult
        end
    end

    function PillCrusher:ResetCrushedPillPerRoom()
        CrushedPillsRoom = {}
    end
    PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PillCrusher.ResetCrushedPillPerRoom)

    function PillCrusher:ResetCrushedPillPerRoom()
        CrushedPillsRoom = {}
    end
    PillCrusher:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PillCrusher.ResetCrushedPillPerRoom)
    
    function PillCrusher:ModReset()
        PillCrusher.Loaded = false
    end
    PillCrusher:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, PillCrusher.ModReset)

    ---@param truePillColor PillColor
    function PillCrusher:IsFiendFolioPill(truePillColor)
        return isFFPill[truePillColor]
    end

    function PillCrusher:GetRandomPillCrusherEffect(rng)
        local pillEffects = {}

        for pillEffect, _ in pairs(CrushedPillEffects) do
            table.insert(pillEffects, pillEffect)
        end

        local chosenPill = pillEffects[rng:RandomInt(#pillEffects) + 1]

        return {CrushedPillEffects[chosenPill], chosenPill}
    end

	print("[".. PillCrusher.Name .."]", "is loaded. Version "..PillCrusher.Version)
	PillCrusher.Loaded = true
end

if PillCrusher then
    if PillCrusher.Version < localversion or not PillCrusher.Loaded then
        if not PillCrusher.Loaded then
            print("Reloading [".. PillCrusher.Name .."]")
        else
            print("[".. PillCrusher.Name .."]", " found old script V" .. PillCrusher.Version .. ", found new script V" .. localversion .. ". replacing...")
        end
        PillCrusher = nil
        load()
    end
elseif not PillCrusher then
    load()
end