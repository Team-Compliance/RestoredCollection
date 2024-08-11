local localversion = 1.0

local function TEARFLAG(x)
    return x >= 64 and BitSet128(0,1<<(x-64)) or BitSet128(1<<x,0)
end

local function load(enums)
    BombFlagsAPI = RegisterMod("Custom Bomb Flags", 1)
    BombFlagsAPI.Version = localversion
    BombFlagsAPI.Loaded = false

    local Flags = {}
    if enums then
        for k, v in pairs(enums) do
            if v.Collectible and type(v.Collectible) == "number" then
                Flags[k] = v
            end
        end
    end

    function BombFlagsAPI.AddNewCustomBombFlag(name, collectible)
        if Flags[name] then 
            print("Custom bomb flag with name "..name.." already exists.")
            Isaac.DebugString("Custom bomb flag with name "..name.." already exists.")
            return 
        end
        if type(collectible) ~= "number" or collectible < 1 or not ItemConfig.Config.IsValidCollectible(collectible) then
            print("Can't add flag "..name..". No valid collectible to bind.")
            Isaac.DebugString("Can't add flag "..name..".No valid collectible to bind.")
            return 
        end
        local i = 84
        for _, _ in pairs(Flags) do
            i = i + 1
        end
        if i == 104 then
            print("Can't add flag "..name..". Limit exceeded.")
            Isaac.DebugString("Can't add flag "..name..". Limit exceeded.")
            return
        end
        Flags[name] = {Flag = TEARFLAG(i), Collectible = collectible}
    end

    function BombFlagsAPI.GetCustomBombFlags(player)
        local flag = 0
        for _, v in pairs(Flags) do
            if player:HasCollectible(v.Collectible) then
                flag = flag | v.Flag
            end
        end
        return flag
    end

    function BombFlagsAPI.GetFlags()
        return Flags
    end

    function BombFlagsAPI.AddCustomBombFlag(bomb, flag)
        if not Flags[flag] then 
            print("Custom bomb flag "..flag.." doesn't exists.") 
            Isaac.DebugString("Custom bomb flag "..flag.." doesn't exists.")
            return 
        end
        bomb:AddTearFlags(Flags[flag].Flag)
    end

    function BombFlagsAPI.HasCustomBombFlag(bomb, flag)
        if not Flags[flag] then 
            print("Custom bomb flag "..flag.." doesn't exists.") 
            Isaac.DebugString("Custom bomb flag "..flag.." doesn't exists.")
            return 
        end
        return bomb:HasTearFlags(Flags[flag].Flag)
    end

    function BombFlagsAPI.RemoveCustomBombFlag(bomb, flag)
        if not Flags[flag] then 
            print("Custom bomb flag "..flag.." doesn't exists.") 
            Isaac.DebugString("Custom bomb flag "..flag.." doesn't exists.")
            return 
        end
        bomb:ClearTearFlags(Flags[flag].Flag)
    end

    function BombFlagsAPI:ModReset()
        BombFlagsAPI.Loaded = false
    end
    BombFlagsAPI:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, BombFlagsAPI.ModReset)

    print("[".. BombFlagsAPI.Name .."]", "is loaded. Version "..BombFlagsAPI.Version)
    BombFlagsAPI.Loaded = true
end

if BombFlagsAPI then
	if BombFlagsAPI.Version < localversion or not BombFlagsAPI.Loaded then
        if not BombFlagsAPI.Loaded then
			print("Reloading [".. BombFlagsAPI.Name .."]")
		else
		    print("[".. BombFlagsAPI.Name .."]", "found old script V" .. BombFlagsAPI.Version .. ", found new script V" .. localversion .. ". replacing...")
        end
		local enums = BombFlagsAPI.GetFlags()
        BombFlagsAPI = nil
		load(enums)
	end
elseif not BombFlagsAPI then
	load()
end
