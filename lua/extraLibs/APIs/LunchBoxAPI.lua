local localversion = 1.0
local name = "Lunchbox API"

local function load(data)
	LunchBox = RegisterMod(name, 1)
	LunchBox.Version = localversion
    LunchBox.Loaded = false

    local LunchBoxPickupData = {}
    if data then
        LunchBoxPickupData = data
    end

    function LunchBox.AddPickup(variant, subtype, charge, func)
        if type(variant) ~= "number" or type(subtype) ~= "number" or type(charge) ~= "number" or type(func) ~= "function" then
            print("Couldn't add pickup to charge Lunchbox. Variant: "..tostring(variant)..", SubType: "..tostring(subtype)..", Charge: "..tostring(charge)..".")
            print("Function type is "..type(func))
            return
        end
        if not LunchBoxPickupData[variant] then
            LunchBoxPickupData[variant] = {}
        end
        if LunchBoxPickupData[variant][subtype] then
            print("This Variant: "..tostring(variant).." and SubType: "..tostring(subtype).." already exists.")
            return
        end
        LunchBoxPickupData[variant][subtype] = {Charge = charge, Function = func}
    end

    function LunchBox.GetPickupData(variant, subtype)
        if variant then
            if subtype then
                return LunchBoxPickupData[variant][subtype]
            end
            return LunchBoxPickupData[variant]
        end
        return LunchBoxPickupData
    end

    function LunchBox:ModReset()
        LunchBox.Loaded = false
    end
    LunchBox:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, LunchBox.ModReset)

	print("[".. LunchBox.Name .."]", "is loaded. Version "..LunchBox.Version)
	LunchBox.Loaded = true
end


if LunchBox and LunchBox.Loaded then
    if LunchBox.Version < localversion or not LunchBox.Loaded then
        if not LunchBox.Loaded then
            print("Reloading [".. LunchBox.Name .."]")
        else
            print("[".. LunchBox.Name .."]", " found old script V" .. LunchBox.Version .. ", found new script V" .. localversion .. ". replacing...")
        end
        local data = LunchBox.GetPickupData()
        LunchBox = nil
        load(data)
    end
elseif not LunchBox then
    load()
end
