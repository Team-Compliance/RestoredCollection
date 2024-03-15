local LuckySevenTears = {}
local Helpers = require("lua.helpers.Helpers")


---@param tear EntityTear
function LuckySevenTears:OnTearInit(tear)
    if tear.SpawnerType ~= EntityType.ENTITY_PLAYER and not tear.Parent then return end

    local player = tear.Parent:ToPlayer()

    if not player:HasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local tearData = Helpers.GetData(tear)

    local rng = RNG()
    rng:SetSeed(tear.InitSeed, 35)

    local chance = Helpers.GetLuckySevenTearChance(player)

    if rng:RandomInt(100) <= chance then
        tearData.IsLuckySevenTear = true
        local sprite = tear:GetSprite()
        local animation = sprite:GetAnimation()
        sprite:Load("gfx/lucky_seven_tear.anm2", true)
        sprite:Play(animation, true)
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, LuckySevenTears.OnTearInit)


---@param tear EntityTear
---@param collider Entity
function LuckySevenTears:OnTearCollision(tear, collider)
    local tearData = Helpers.GetData(tear)

    if not tearData.IsLuckySevenTear then return end
    if not Helpers.IsTargetableEnemy(collider) then return end

    local player = tear.Parent:ToPlayer()

    local rng = RNG()
    rng:SetSeed(tear.InitSeed, 35)

    Helpers.TurnEnemyIntoGoldenMachine(collider, player, rng)
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, LuckySevenTears.OnTearCollision)