local localversion = 1.0
local name = "Sun Hearts API"

local function load()
	ComplianceSun = RegisterMod(name, 1)
	ComplianceSun.Version = localversion
    ComplianceSun.Loaded = false

    function ComplianceSun.GetSunHeartsNum(player)
        return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_SUN")
    end
    
    function ComplianceSun.AddSunHearts(player, hp)
        CustomHealthAPI.Library.AddHealth(player, "HEART_SUN", hp)
    end
    
    function ComplianceSun.CanPickSunHearts(player)
        return CustomHealthAPI.Library.CanPickKey(player, "HEART_SUN")
    end

    function ComplianceSun:ModReset()
        ComplianceSun.Loaded = false
    end
    ComplianceSun:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, ComplianceSun.ModReset)

	print("[".. ComplianceSun.Name .."]", "is loaded. Version "..ComplianceSun.Version)
	ComplianceSun.Loaded = true
end

if not CustomHealthAPI then
    print("[".. name .."]", " couldn't be loaded. Missing CustomHealthAPI.")
else
    if ComplianceSun then
        if ComplianceSun.Version < localversion or not ComplianceSun.Loaded then
            if not ComplianceSun.Loaded then
                print("Reloading [".. ComplianceSun.Name .."]")
            else
                print("[".. ComplianceSun.Name .."]", " found old script V" .. ComplianceSun.Version .. ", found new script V" .. localversion .. ". replacing...")
            end
            ComplianceSun = nil
            load()
        end
    elseif not ComplianceSun then
        load()
    end
end