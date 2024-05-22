local localversion = 1.0

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
        local i = 0
        for _, _ in pairs(Flags) do
            i = i + 1
        end
        if i == 63 then
            print("Can't add flag "..name..". Limit exceeded.")
            Isaac.DebugString("Can't add flag "..name..". Limit exceeded.")
        end
        Flags[name] = {Flag = 1 << i, Collectible = collectible}
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
        bomb.SubType = bomb.SubType | Flags[flag].Flag
    end
    
    function BombFlagsAPI.HasCustomBombFlag(bomb, flag)
        if not Flags[flag] then 
            print("Custom bomb flag "..flag.." doesn't exists.") 
            Isaac.DebugString("Custom bomb flag "..flag.." doesn't exists.")
            return 
        end
        return bomb.SubType & Flags[flag].Flag == Flags[flag].Flag
    end
    
    function BombFlagsAPI.RemoveCustomBombFlag(bomb, flag)
        if not Flags[flag] then 
            print("Custom bomb flag "..flag.." doesn't exists.") 
            Isaac.DebugString("Custom bomb flag "..flag.." doesn't exists.")
            return 
        end
        bomb.SubType = bomb.SubType & ~Flags[flag].Flag
    end
    --#endregion
    print("[".. BombFlagsAPI.Name .."]", "is loaded")
end

if BombFlagsAPI then
	if BombFlagsAPI.Version < localversion then
		print("[".. BombFlagsAPI.Name .."]", "found old script V" .. BombFlagsAPI.Version .. ", found new script V" .. localversion .. ". replacing...")
		local enums = BombFlagsAPI.GetFlags()
        BombFlagsAPI = nil
		load(enums)
		print("[".. BombFlagsAPI.Name .."]", "replaced with V" .. BombFlagsAPI.Version)
	end
elseif not BombFlagsAPI then
	load()
end
