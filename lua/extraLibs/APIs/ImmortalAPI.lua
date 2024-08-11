local localversion = 1.0
local name = "Immortal Hearts API"

local function load()
	ComplianceImmortal = RegisterMod(name, 1)
	ComplianceImmortal.Version = localversion
    ComplianceImmortal.Loaded = false

    function ComplianceImmortal.GetImmortalHeartsNum(player)
        if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN then
            player = player:GetSubPlayer()
        end
        return CustomHealthAPI.Library.GetHPOfKey(player, "HEART_IMMORTAL")
    end
    
    function ComplianceImmortal.GetImmortalHearts(player)
        return ComplianceImmortal.GetImmortalHeartsNum(player)
    end
    
    function ComplianceImmortal.AddImmortalHearts(player, hp)
        CustomHealthAPI.Library.AddHealth(player, "HEART_IMMORTAL", hp)
    end
    
    function ComplianceImmortal.CanPickImmortalHearts(player)
        return CustomHealthAPI.Library.CanPickKey(player, "HEART_IMMORTAL")
    end
    
    function ComplianceImmortal.HealImmortalHeart(player) -- returns true if successful
        if ComplianceImmortal.GetImmortalHeartsNum(player) > 0 and ComplianceImmortal.GetImmortalHeartsNum(player) % 2 ~= 0 then
            local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.IMMORTAL_HEART_CHARGE.Variant, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
            ImmortalEffect:GetSprite().Offset = Vector(0, -22)
            SFXManager():Play(RestoredCollection.Enums.SFX.Hearts.IMMORTAL_PICKUP, 1, 0)
            ComplianceImmortal.AddImmortalHearts(player, 1)
            return true
        end
        return false
    end

    function ComplianceImmortal:ModReset()
        ComplianceImmortal.Loaded = false
    end
    ComplianceImmortal:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, ComplianceImmortal.ModReset)

	print("[".. ComplianceImmortal.Name .."]", "is loaded. Version "..ComplianceImmortal.Version)
	ComplianceImmortal.Loaded = true
end

if not CustomHealthAPI then
    print("[".. name .."]", " couldn't be loaded. Missing CustomHealthAPI.")
else
    if ComplianceImmortal then
        if ComplianceImmortal.Version < localversion or not ComplianceImmortal.Loaded then
            if not ComplianceImmortal.Loaded then
                print("Reloading [".. ComplianceImmortal.Name .."]")
            else
                print("[".. ComplianceImmortal.Name .."]", " found old script V" .. ComplianceImmortal.Version .. ", found new script V" .. localversion .. ". replacing...")
            end
            ComplianceImmortal = nil
            load()
        end
    elseif not ComplianceImmortal then
        load()
    end
end