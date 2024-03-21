local VPTWF = {}
local Helpers = require("lua.helpers.Helpers")

local function FireTear(player)
    local data = Helpers.GetData(player)
    if data.PrevDelay and player.HeadFrameDelay > data.PrevDelay and player.HeadFrameDelay > 1 then 
        --Helpers.ChargeBowl(player)
        Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
    end 
    data.PrevDelay = player.HeadFrameDelay
end

local function LudoCharge(entity)
    local player = Helpers.GetPlayerFromTear(entity)
    local data = Helpers.GetData(entity)
    if player then
        if player:GetActiveWeaponEntity() and entity.FrameCount > 0 then
            if entity.TearFlags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entity) then
                if math.fmod(entity.FrameCount, player.MaxFireDelay) == 1 and not data.KnifeLudoCharge then
                    --Helpers.ChargeBowl(player)
                    Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
                    data.KnifeLudoCharge = true
                elseif math.fmod(entity.FrameCount, player.MaxFireDelay) == ((player.MaxFireDelay - 2) > 1 and (player.MaxFireDelay - 2) or 1) and data.KnifeLudoCharge then
                    data.KnifeLudoCharge = nil
                end
            end
        end
    end
end

--firing tears updates the bowl
function VPTWF:TearBowlCharge(player)
    if not player:HasWeaponType(WeaponType.WEAPON_LUDOVICO_TECHNIQUE) and not player:HasWeaponType(WeaponType.WEAPON_KNIFE)
    and not player:HasWeaponType(WeaponType.WEAPON_ROCKETS) and not player:HasWeaponType(WeaponType.WEAPON_TECH_X)
    and not player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) then
        FireTear(player)
    end
end

--updating knife charge
function VPTWF:KnifeBowlCharge(entityKnife)
    local player = Helpers.GetPlayerFromTear(entityKnife)
    local data = Helpers.GetData(entityKnife)
    if player then
        if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
        or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then return end
        local sk = entityKnife:GetSprite()
        if entityKnife.Variant == 10 and entityKnife.SubType == 0 then --spirit sword
            if sk:GetFrame() == 3 and not data.SwordSpin then
                --Helpers.ChargeBowl(player)
                Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
                data.SwordSpin = true
            elseif data.SwordSpin then
                for _,s in ipairs({"Left","Right","Down","Up"}) do
                    if (sk:IsPlaying("Attack"..s) or sk:IsPlaying("Spin"..s)) and sk:GetFrame() == 2 then
                        data.SwordSpin = nil
                        break
                    end
                end
            end
        elseif entityKnife:IsFlying() and not data.Flying then --knife flies
            data.Flying = true
            if GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
                --Helpers.ChargeBowl(player)
                Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
            end
        elseif not entityKnife:IsFlying() and data.Flying then --one charge check
            data.Flying = nil
        elseif entityKnife.Variant == 1 or entityKnife.Variant == 3 and GetPtrHash(player:GetActiveWeaponEntity()) == GetPtrHash(entityKnife) then
            if sk:GetFrame() == 1 and not data.BoneSwing then
                --Helpers.ChargeBowl(player)
                Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
                data.BoneSwing = true
            end
        else
            LudoCharge(entityKnife)
        end
    end
end

--updating ludo charge and fired from bowl tears
function VPTWF:TearUpdateBOT(entityTear)
    local player = Helpers.GetPlayerFromTear(entityTear)
    --updating charges with ludo
    if player then
        LudoCharge(entityTear)
        --updating slight height and acceleration of tears from bowl
        --[[if entityTear.FrameCount == 1 and TC_SaltLady:GetData(entityTear).FromBowl then
            --local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_BOWL_OF_TEARS)
            entityTear.Height = TC_SaltLady:GetRandomNumber(-40,-24, TC_SaltLady.Globals.rng)
            entityTear.FallingAcceleration = 1 / TC_SaltLady:GetRandomNumber(1,5,TC_SaltLady.Globals.rng)
        end]]
    end
end

--chargin lasers
function VPTWF:BrimstoneBowlCharge(entityLaser)
    if entityLaser.SpawnerType == EntityType.ENTITY_PLAYER and not Helpers.GetData(entityLaser).isSpreadLaser then
        local player = Helpers.GetPlayerFromTear(entityLaser)
        if player then
            if player:HasWeaponType(WeaponType.WEAPON_TECH_X) then
                FireTear(player)
            elseif player:HasWeaponType(WeaponType.WEAPON_BRIMSTONE) and player:GetActiveWeaponEntity() then
                local delay = player:GetActiveWeaponEntity().SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO and player.MaxFireDelay or 5
                if math.fmod(player:GetActiveWeaponEntity().FrameCount, delay) == 1 then
                    --Helpers.ChargeBowl(player)
                    Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
                end
            end
        end
    end
end

--that one scene from Dr. Strangelove 
function VPTWF:EpicBowlCharge(entityRocet)
    local player = Helpers.GetPlayerFromTear(entityRocet)
    if player then
        --Helpers.ChargeBowl(player)
        Isaac.RunCallback(RestoredItemsCollection.Enums.Callbacks.VANILLA_POST_TRIGGER_WEAPON_FIRED, player)
    end
end

RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, VPTWF.TearBowlCharge)
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, VPTWF.KnifeBowlCharge)
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, VPTWF.TearUpdateBOT)
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, VPTWF.BrimstoneBowlCharge)
RestoredItemsCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, VPTWF.EpicBowlCharge, EffectVariant.ROCKET)