local OlLopper = {}
local Helpers = require("lua.helpers.Helpers")
OlLopper.ID = RestoredItemsCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER
OlLopper.HEAD_HELPER = RestoredItemsCollection.Enums.Entities.OL_LOPPER_HEAD_HELPER
OlLopper.NECK = RestoredItemsCollection.Enums.Entities.OL_LOPPER_NECK

--The head can move without speed limitation within the free range.
--When it exits the free range it will be slowed (like forgotten's soul)
--until it reaches the allowed range.
OlLopper.HEAD_FREE_RANGE = 120
OlLopper.HEAD_ALLOWED_RANGE = 250
OlLopper.HEAD_VELOCITY = 8
OlLopper.HEAD_ACCEL = 0.3
OlLopper.HEAD_RETURN_VELOCITY = 0.07

OlLopper.NUM_NECK_PIECES = 10

OlLopper.CONTACT_DAMAGE_RANGE = 20
--Directly multiplies player's damage
OlLopper.CONTACT_DAMAGE_MULT = 1.5
--Deal damage every x frames
OlLopper.CONTACT_DAMAGE_FREQUENCY = 4


---@param player EntityPlayer
---@return Entity?
local function GetHeadHelper(player)
    ---@type EntityRef?
    local headHelper = Helpers.GetData(player).OlLopperHeadHelper

    if not headHelper then
        return
    end

    if not headHelper.Entity:Exists() then
        return
    end

    return headHelper.Entity
end


---@param player EntityPlayer
---@return Entity
local function CreateHeadHelper(player)
    local headHelper = Isaac.Spawn(
        OlLopper.HEAD_HELPER.Type,
        OlLopper.HEAD_HELPER.Variant,
        OlLopper.HEAD_HELPER.SubType,
        player.Position,
        Vector.Zero,
        player
    )
    headHelper:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    headHelper.DepthOffset = 10

    Helpers.GetData(player).OlLopperHeadHelper = EntityRef(headHelper)
    return headHelper
end


---@param player EntityPlayer
local function RemoveHeadHelper(player)
    local headHelper = GetHeadHelper(player)

    if headHelper then
        Helpers.GetData(player).OlLopperHeadHelper = nil
        headHelper:Remove()
    end
end


---@param player EntityPlayer
local function TrySpawnLight(player)
    local data = Helpers.GetData(player)
    ---@type EntityRef
    local lightRef = data.OlLopperLight

    if not lightRef or not lightRef.Entity or not lightRef.Entity:Exists() then
        local light = Isaac.Spawn(
            EntityType.ENTITY_EFFECT,
            EffectVariant.LIGHT,
            0,
            player.Position - player.PositionOffset,
            Vector.Zero,
            player
        ):ToEffect()
        light.Parent = player

        light.ParentOffset = -player.PositionOffset
        light:FollowParent(player)

        light:Update()
        light.Color = Color(1, 1, 1, 1, 1, 1, 1)
        light.SpriteScale = Vector(3, 3)

        data.OlLopperLight = EntityRef(light)
        lightRef = data.OlLopperLight
    end

    local light = lightRef.Entity:ToEffect()
    light.ParentOffset = -player.PositionOffset
end


---@param player EntityPlayer
---@return EntityEffect[]?
local function GetNeckPieces(player)
    ---@type EntityRef[]?
    local neck = Helpers.GetData(player).OlLopperNeckPieces

    if not neck then
        return
    end

    if #neck == 0 then
        return
    end

    if not neck[1].Entity:Exists() then
        return
    end

    local effects = {}
    for _, neckPiece in ipairs(neck) do
        effects[#effects+1] = neckPiece.Entity:ToEffect()
    end
    return effects
end


---@param player EntityPlayer
local function RemoveNeckPieces(player)
    local neckPieces = GetNeckPieces(player)
    if neckPieces then
        for _, neckPiece in ipairs(neckPieces) do
            neckPiece:Remove()
        end

        Helpers.GetData(player).OlLopperNeckPieces = nil
    end
end


---@param player EntityPlayer
---@return EntityEffect[]
local function CreateNeckPieces(player)
    RemoveNeckPieces(player)

    local entityRefs = {}
    local effects = {}

    for _ = 1, OlLopper.NUM_NECK_PIECES, 1 do
        local neckPiece = Isaac.Spawn(
            OlLopper.NECK.Type,
            OlLopper.NECK.Variant,
            OlLopper.NECK.SubType,
            player.Position,
            Vector.Zero,
            player
        ):ToEffect()

        neckPiece.DepthOffset = 20

        entityRefs[#entityRefs+1] = EntityRef(neckPiece)
        effects[#effects+1] = neckPiece
    end

    Helpers.GetData(player).OlLopperNeckPieces = entityRefs
    return effects
end


---@param player EntityPlayer
function OlLopper:OnPlayerRender(player)
    local data = Helpers.GetData(player)

    if not player:HasCollectible(OlLopper.ID) then
        if data.UsedToHaveOlLopper then
            RemoveHeadHelper(player)
            RemoveNeckPieces(player)
            player.TearsOffset = Vector(0, 0)
            player.PositionOffset = Vector(0, 0)
            data.UsedToHaveOlLopper = nil
        end

        return
    end

    data.UsedToHaveOlLopper = true

    TrySpawnLight(player)

    if Helpers.IsPlayingExtraAnimation(player) then
        player.PositionOffset = Vector(0, 0)
        return
    end

    player.PositionOffset = Vector(100000, 100000)

    local renderPosition = Isaac.WorldToScreen(player.Position)

    player:RenderBody(renderPosition)
    player:RenderTop(renderPosition)
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_POST_PLAYER_RENDER,
    OlLopper.OnPlayerRender
)


---@param player EntityPlayer
function OlLopper:OnPeffectUpdate(player)
    if player:HasCollectible(OlLopper.ID) then
        local headHelper = GetHeadHelper(player)
        if not headHelper then
            headHelper = CreateHeadHelper(player)
        end

        local posOffset = headHelper.Position - player.Position
        player.TearsOffset = posOffset
    else
        RemoveHeadHelper(player)
    end
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_POST_PEFFECT_UPDATE,
    OlLopper.OnPeffectUpdate
)


---@param headHelper Entity
---@param player EntityPlayer
local function HandleHeadMovement(headHelper, player)
    local data = Helpers.GetData(headHelper)

    local fireDir = player:GetFireDirection()

    local prevFireDir = data.PrevDirection or Direction.NO_DIRECTION
    data.PrevDirection = fireDir

    if fireDir == Direction.NO_DIRECTION and prevFireDir ~= Direction.NO_DIRECTION then
        data.MovementProgress = 0
        data.StartMovementPos = headHelper.Position
    end

    if Helpers.IsPlayingExtraAnimation(player) then
        data.MovementProgress = 1
        data.PrevDirection = fireDir

        headHelper.Position = player.Position
        headHelper.Velocity = player.Velocity
    elseif fireDir == Direction.NO_DIRECTION then
        local newPos = player.Position

        local movementProgress = data.MovementProgress or 1

        if movementProgress < 1 then
            local t = Helpers.EaseOutBack(movementProgress)
            newPos = Helpers.Lerp(data.StartMovementPos, player.Position, t)

            data.MovementProgress = math.min(movementProgress + OlLopper.HEAD_RETURN_VELOCITY, 1)
        end

        headHelper.Velocity = newPos - headHelper.Position
    else
        local shootingInput = player:GetShootingInput()
        local targetVelocity = shootingInput:Resized(OlLopper.HEAD_VELOCITY)
        local newVelocity = Helpers.Lerp(headHelper.Velocity, targetVelocity, OlLopper.HEAD_ACCEL)

        local distanceToPlayer = headHelper.Position:Distance(player.Position)

        if distanceToPlayer > OlLopper.HEAD_FREE_RANGE then
            local max = OlLopper.HEAD_ALLOWED_RANGE - OlLopper.HEAD_FREE_RANGE
            local current = distanceToPlayer - OlLopper.HEAD_FREE_RANGE
            local ratio = current / max

            local resistance = (headHelper.Position - player.Position):Resized(OlLopper.HEAD_VELOCITY * ratio)
            newVelocity = newVelocity - resistance
        end

        headHelper.Velocity = newVelocity
    end
end


---@param headHelper Entity
---@param player EntityPlayer
local function DealContactDamage(headHelper, player)
    if headHelper:IsFrame(OlLopper.CONTACT_DAMAGE_FREQUENCY, headHelper.InitSeed) then
        local enemies = Isaac.FindInRadius(
            headHelper.Position,
            OlLopper.CONTACT_DAMAGE_RANGE,
            EntityPartition.ENEMY
        )
        for _, enemy in ipairs(enemies) do
            local ref = EntityRef(enemy)
            if not ref.IsFriendly and enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() then
                local damage = player:GetTearPoisonDamage() * OlLopper.CONTACT_DAMAGE_MULT
                enemy:TakeDamage(damage, 0, EntityRef(player), 0)
            end
        end
    end
end


---@param headHelper Entity
function OlLopper:OnHeadHelperUpdate(headHelper)
    local spawner = headHelper.SpawnerEntity
    if not spawner then
        headHelper:Remove()
        return
    end

    local player = spawner:ToPlayer()
    if not player then
        headHelper:Remove()
        return
    end

    HandleHeadMovement(headHelper, player)
    DealContactDamage(headHelper, player)
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_FAMILIAR_UPDATE,
    OlLopper.OnHeadHelperUpdate,
    OlLopper.HEAD_HELPER.Variant
)


---@param player EntityPlayer
---@param headPos Vector
function RenderPlayerHead(player, headPos)
    local renderPos = Isaac.WorldToScreen(headPos)
    player:RenderGlow(renderPos)
    player:RenderHead(renderPos)
end


---@param player EntityPlayer
---@param headPos Vector
function RenderPlayerNeck(player, headPos)
    local neckPieces = GetNeckPieces(player)
    if not neckPieces then
        neckPieces = CreateNeckPieces(player)
    end

    local playerPos = player.Position + Vector(0, -17)
    local neckPos = headPos + Vector(0, -17)

    local numPieces = #neckPieces
    local segments = numPieces + 1
    local direction = neckPos - playerPos
    local distance = playerPos:Distance(neckPos)
    local distanceStep = distance/segments

    for i = 1, segments-1, 1 do
        local neckPiece = neckPieces[i]
        local targetPos = playerPos + direction:Resized(i * distanceStep)
        neckPiece.Velocity = targetPos - neckPiece.Position
    end
end


---@param headHelper Entity
function OlLopper:OnHeadHelperRender(headHelper)
    local spawner = headHelper.SpawnerEntity
    if not spawner then
        headHelper:Remove()
        return
    end

    local player = spawner:ToPlayer()
    if not player then
        headHelper:Remove()
        return
    end

    RenderPlayerHead(player, headHelper.Position)
    RenderPlayerNeck(player, headHelper.Position)
end
RestoredItemsCollection:AddCallback(
    ModCallbacks.MC_POST_FAMILIAR_RENDER,
    OlLopper.OnHeadHelperRender,
    OlLopper.HEAD_HELPER.Variant
)