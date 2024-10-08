local PumpkinMask = {}
local Helpers = include("lua.helpers.Helpers")

---@param player EntityPlayer
---@return boolean
local function Can360Degree(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_ANALOG_STICK) or 
    player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED) or player:HasCollectible(CollectibleType.COLLECTIBLE_EYE_OF_THE_OCCULT)
end

---@param player EntityPlayer
function PumpkinMask:FireSeeds(player)
    if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_PUMPKIN_MASK) and not player:IsDead() then
        local data = Helpers.GetData(player)
        if not data.FireDelaySeeds then
            data.FireDelaySeeds = -1
        end
        data.FireDelaySeeds = math.max(-1, data.FireDelaySeeds - 1)
        if data.FireDelaySeeds < 0 and player:GetItemState() == 0 then
            if player:GetFireDirection() ~= Direction.NO_DIRECTION then
                for i = 0, TSIL.Random.GetRandomInt(3,5) do
                    Helpers.scheduleForUpdate(function ()
                        local shootVec = Helpers.GetVectorFromDirection(player:GetHeadDirection())
                        if Can360Degree(player) then
                            shootVec = player:GetAimDirection()
                        end
                        shootVec = shootVec:Resized(9) + player.Velocity
                        if shootVec:Length() < 9 then
                            shootVec:Resize(9)
                        end

                        if not player:IsDead() then
                            local tear = Isaac.Spawn(EntityType.ENTITY_TEAR, RestoredCollection.Enums.TearVariant.PUMPKIN_SEED, 0, player.Position + player.TearsOffset, shootVec:Rotated(TSIL.Random.GetRandomInt(-15, 15)) * player.ShotSpeed, player):ToTear()
                            tear.CollisionDamage = player.Damage * 0.4
                            local sprite = tear:GetSprite()
                            sprite:Play(sprite:GetDefaultAnimation(), true)
                        end
                    end, 2 * i)
                end
                data.FireDelaySeeds = Helpers.ToMaxFireDelay(2/3)
            end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, PumpkinMask.FireSeeds, 0)

---@param tear EntityTear
function PumpkinMask:SeedUpdate(tear)
    tear.SpriteRotation = tear.Velocity:GetAngleDegrees() + 90
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, PumpkinMask.SeedUpdate, RestoredCollection.Enums.TearVariant.PUMPKIN_SEED)

---From FiendFolio
---@param tear Entity
function PumpkinMask:PostSeedRemove(tear)
    if tear.Variant == RestoredCollection.Enums.TearVariant.PUMPKIN_SEED then
        local splat = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.PUMPKIN_SEED_SHATTER.Variant, 0, tear.Position, Vector.Zero, tear):ToEffect()
        splat:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        splat.PositionOffset = tear.PositionOffset
        splat.SpriteOffset = tear.SpriteOffset
        tear = tear:ToTear()
        splat.SpriteScale = Vector(tear.Scale, tear.Scale) / 2
        splat:Update()
        SFXManager():Play(SoundEffect.SOUND_TEARIMPACTS, 1, 0, false, 1)
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, PumpkinMask.PostSeedRemove, EntityType.ENTITY_TEAR)

---@param effect EntityEffect
function PumpkinMask:SeedPoofRemoval(effect)
    if effect:GetSprite():IsFinished() then
        effect:Remove()
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PumpkinMask.SeedPoofRemoval, RestoredCollection.Enums.Entities.PUMPKIN_SEED_SHATTER.Variant)