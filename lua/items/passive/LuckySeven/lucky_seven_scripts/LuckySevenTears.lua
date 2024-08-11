local LuckySevenTears = {}
local Helpers = RestoredCollection.Helpers


---@param tear EntityTear
function LuckySevenTears:OnTearInit(tear)
    if tear.SpawnerType ~= EntityType.ENTITY_PLAYER and not tear.Parent then return end

    local player = tear.Parent:ToPlayer()

    if not player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local tearData = Helpers.GetData(tear)

    local rng = RNG()
    rng:SetSeed(tear.InitSeed, 35)

    local chance = Helpers.GetLuckySevenTearChance(player)

    if rng:RandomInt(100) <= chance then
        tearData.IsLuckySevenTear = true
        local sparkle = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.LUCKY_SEVEN_TEAR_SPARKLES.Variant, 0, tear.Position, Vector.Zero, tear):ToEffect()
        sparkle.Parent = tear
        sparkle:FollowParent(tear)
        sparkle.DepthOffset = 15
        sparkle.SpriteScale = Vector(1, 1) * player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 1, nil).TearScale
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, LuckySevenTears.OnTearInit)

---@param tear EntityTear
---@param offset Vector
function LuckySevenTears:LuckyTearRender(tear, offset)
    local tearData = Helpers.GetData(tear)
    if tearData.IsLuckySevenTear then
        local tearColor = tear.Color
        tearColor:SetColorize(5, 5, 0, 0.5)
        tear.Color = tearColor
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, LuckySevenTears.LuckyTearRender)

---@param effect EntityEffect
function LuckySevenTears:LuckyTearSparkle(effect)
    if not effect.Parent or effect.Parent:IsDead() then
        effect:Remove()
    end
    effect.m_Height = effect.Parent:ToTear().Height
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, LuckySevenTears.LuckyTearSparkle, RestoredCollection.Enums.Entities.LUCKY_SEVEN_TEAR_SPARKLES.Variant)

---@param tear EntityTear
---@param collider Entity
function LuckySevenTears:OnTearCollision(tear, collider)
    local tearData = Helpers.GetData(tear)

    if not tearData.IsLuckySevenTear then return end
    if not Helpers.IsTargetableEnemy(collider) then return end

    local player = Helpers.GetPlayerFromTear(tear)

    local rng = RNG()
    rng:SetSeed(tear.InitSeed, 35)

    Helpers.TurnEnemyIntoGoldenMachine(collider, player, rng)
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, LuckySevenTears.OnTearCollision)