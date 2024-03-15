local LuckySevenBoneSwing = {}
local Helpers = require("lua.helpers.Helpers")


local DIRECTION_TO_VECTOR = {
    [Direction.NO_DIRECTION] = Vector.Zero,
    [Direction.DOWN] = Vector(0, 1),
    [Direction.LEFT] = Vector(-1, 0),
    [Direction.RIGHT] = Vector(1, 0),
    [Direction.UP] = Vector(0, -1)
}

local KnifeAnimations = {}


---@param knife EntityKnife
function LuckySevenBoneSwing:OnKnifeRender(knife)
    if knife.Variant ~= 1 then return end
    if not knife.Parent or knife.Parent.Type ~= EntityType.ENTITY_PLAYER then return end

    local player = knife.Parent:ToPlayer()
    if not player:HasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) then return end
    if not Helpers.DoesPlayerHaveRightAmountOfPickups(player) then return end

    local sprite = knife:GetSprite()

    local animation = sprite:GetAnimation();
    local ptrHash = GetPtrHash(knife);

    local animationOnLastFrame = KnifeAnimations[ptrHash]
    KnifeAnimations[ptrHash] = animation

    if animationOnLastFrame ~= nil and animation ~= animationOnLastFrame and
    (animation == "Swing" or animation == "Swing2") then
        local chance = Helpers.GetLuckySevenTearChance(player)
        local rng = knife:GetDropRNG()

        if rng:RandomInt(100) < chance then
            local speed = DIRECTION_TO_VECTOR[player:GetFireDirection()] * 9
            local tear = player:FireTear(knife.Position, speed, false, true, false, player, 1)

            tear:ChangeVariant(TearVariant.BLUE)

            local tearData = Helpers.GetData(tear)
            tearData.IsLuckySevenTear = true
            local tearSprite = tear:GetSprite()
            local tearAnimation = tearSprite:GetAnimation()
            tearSprite:Load("gfx/lucky_seven_tear.anm2", true)
            tearSprite:Play(tearAnimation, true)
        end
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_KNIFE_RENDER, LuckySevenBoneSwing.OnKnifeRender)


function LuckySevenBoneSwing:OnNewRoom()
    KnifeAnimations = {}
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, LuckySevenBoneSwing.OnNewRoom)