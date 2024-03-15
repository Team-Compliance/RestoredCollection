local PumpkinMask = {}
local Helpers = include("lua.helpers.Helpers")

---@param player EntityPlayer
---@return boolean
local function Can360Degree(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or 
    player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
end

local function GetMarkedEntity(player)
    for _, mark in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.TARGET)) do
        mark = mark:ToEffect()
        if mark.Parent and GetPtrHash(mark.Parent) == GetPtrHash(player) then
            return mark
        end
    end
    return nil
end

---@param player EntityPlayer
function PumpkinMask:FireSeeds(player)
    if player:HasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK) and not player:IsDead() then
        local data = Helpers.GetData(player)
        if not data.FireDelaySeeds then
            data.FireDelaySeeds = -1
        end
        data.FireDelaySeeds = math.max(-1, data.FireDelaySeeds - 1)
        if data.FireDelaySeeds < 0 then
            if player:GetFireDirection() ~= Direction.NO_DIRECTION then
                local shootVec = Helpers.GetVectorFromDirection(player:GetFireDirection())
                if Can360Degree(player) then
                    shootVec = player:GetAimDirection()
                end
                shootVec = shootVec:Resized(9) + player.Velocity
                if shootVec:Length() < 9 then
                    shootVec:Resize(9)
                end
                for i = 0, TSIL.Random.GetRandomInt(3,5) do
                    Helpers.scheduleForUpdate(function ()
                        if not player:IsDead() then
                            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.BLUE, 0, player.Position, shootVec:Rotated(TSIL.Random.GetRandomInt(-15, 15)) * player.ShotSpeed, player)
                            tear.CollisionDamage = player.Damage * 0.85
                        end
                    end, 2 * i)
                end
                data.FireDelaySeeds = Helpers.ToMaxFireDelay(2/3)
            end
        end
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PumpkinMask.FireSeeds, 0)