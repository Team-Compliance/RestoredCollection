local OlLopper = {}
local Helpers = require("lua.helpers.Helpers")
OlLopper.ID = RestoredCollection.Enums.CollectibleType.COLLECTIBLE_OL_LOPPER
OlLopper.HEAD_HELPER = RestoredCollection.Enums.Entities.OL_LOPPER_HEAD_HELPER
OlLopper.NECK = RestoredCollection.Enums.Entities.OL_LOPPER_NECK

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


---@param parent EntityFamiliar
---@return EntityEffect[]?
local function GetNeckPieces(parent)
    ---@type EntityRef[]?
    local neck = Helpers.GetData(parent).OlLopperNeckPieces

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


---@param parent EntityFamiliar
local function RemoveNeckPieces(parent)
    local neckPieces = GetNeckPieces(parent)
    if neckPieces then
        for _, neckPiece in ipairs(neckPieces) do
            neckPiece:Remove()
        end

        Helpers.GetData(parent).OlLopperNeckPieces = nil
    end
end


---@param parent EntityFamiliar
---@return EntityEffect[]
local function CreateNeckPieces(parent)
    RemoveNeckPieces(parent)

    local entityRefs = {}
    local effects = {}

    for _ = 1, OlLopper.NUM_NECK_PIECES, 1 do
        local neckPiece = Isaac.Spawn(
            OlLopper.NECK.Type,
            OlLopper.NECK.Variant,
            OlLopper.NECK.SubType,
            parent.Position,
            Vector.Zero,
            parent):ToEffect()

        entityRefs[#entityRefs+1] = EntityRef(neckPiece)
        effects[#effects+1] = neckPiece
    end

    Helpers.GetData(parent).OlLopperNeckPieces = entityRefs
    return effects
end


---@param player EntityPlayer
function OlLopper:OnPlayerRender(player)
    local data = Helpers.GetData(player)

    if not player:HasCollectible(OlLopper.ID) then
        if data.UsedToHaveOlLopper then
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
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, OlLopper.OnPlayerRender)


---@param headHelper EntityFamiliar
local function HandleHeadMovement(headHelper)
    local data = Helpers.GetData(headHelper)
    local player = headHelper.Player
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

---@param headHelper EntityFamiliar
local function DealContactDamage(headHelper)
    if headHelper:IsFrame(OlLopper.CONTACT_DAMAGE_FREQUENCY, headHelper.InitSeed) then
        local enemies = Isaac.FindInRadius(
            headHelper.Position,
            OlLopper.CONTACT_DAMAGE_RANGE,
            EntityPartition.ENEMY
        )
        local player = headHelper.Player
        for _, enemy in ipairs(enemies) do
            local ref = EntityRef(enemy)
            if not ref.IsFriendly and enemy:IsActiveEnemy() and enemy:IsVulnerableEnemy() then
                local damage = player:GetTearPoisonDamage() * OlLopper.CONTACT_DAMAGE_MULT
                enemy:TakeDamage(damage, 0, EntityRef(player), 0)
            end
        end
    end
end

---@param headHelper EntityFamiliar
function OlLopper:OnHeadHelperUpdate(headHelper)
    local spawner = headHelper.SpawnerEntity
    if not spawner then
        headHelper:Remove()
        RemoveNeckPieces(headHelper)
        return
    end

    local player = spawner:ToPlayer()
    if not player then
        headHelper:Remove()
        RemoveNeckPieces(headHelper)
        return
    end
    player.TearsOffset = headHelper.Position - player.Position
    HandleHeadMovement(headHelper)
    DealContactDamage(headHelper)
end
RestoredCollection:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, OlLopper.OnHeadHelperUpdate, OlLopper.HEAD_HELPER.Variant)

---@param headHelper Entity
function OlLopper:OnHeadHelperRemove(headHelper)
    if headHelper.Variant == OlLopper.HEAD_HELPER.Variant or headHelper.Variant == FamiliarVariant.GUILLOTINE then
        RemoveNeckPieces(headHelper:ToFamiliar())
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, OlLopper.OnHeadHelperRemove, EntityType.ENTITY_FAMILIAR)

---@param player EntityPlayer
---@param headPos Vector
function RenderPlayerHead(player, headPos)
    local renderPos = Isaac.WorldToScreen(headPos)
    player:RenderGlow(renderPos)
    player:RenderHead(renderPos)
end


---@param parent EntityFamiliar
---@param headPos Vector
function RenderPlayerNeck(parent, headPos)
    local neckPieces = GetNeckPieces(parent)
    if not neckPieces then
        neckPieces = CreateNeckPieces(parent)
    end
    local player = parent.Player
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
        if parent.Variant == FamiliarVariant.GUILLOTINE then
            neckPiece.Position = targetPos
        else
            neckPiece.Velocity = (targetPos - neckPiece.Position)
        end
        neckPiece.Visible = player.Visible and not Helpers.IsPlayingExtraAnimation(player) and not player:IsDead() and not player:IsCoopGhost()
    end
end

---@param headHelper EntityFamiliar
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
    headHelper.DepthOffset = 20
    RenderPlayerHead(player, headHelper.Position)
    RenderPlayerNeck(headHelper, headHelper.Position)
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, OlLopper.OnHeadHelperRender, OlLopper.HEAD_HELPER.Variant)

---@param neck EntityEffect
function OlLopper:OnNeckPieceRender(neck)
    local spawner = neck.SpawnerEntity
    if not spawner then
        neck:Remove()
        return
    end

    local head = spawner:ToFamiliar()
    if not head then
        neck:Remove()
        return
    end
    neck.DepthOffset = head.Variant == FamiliarVariant.GUILLOTINE and 15 or 20
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, OlLopper.OnNeckPieceRender, OlLopper.NECK.Variant)

---@param player EntityPlayer
---@param cache CacheFlag | integer
function OlLopper:EvalCache(player, cache)
    local num = player:GetCollectibleNum(CollectibleType.COLLECTIBLE_GUILLOTINE) > 0 and 0 or (player:GetCollectibleNum(OlLopper.ID) > 0 and 1 or 0)
    player:CheckFamiliar(OlLopper.HEAD_HELPER.Variant, num, player:GetCollectibleRNG(OlLopper.ID), Isaac.GetItemConfig():GetCollectible(OlLopper.ID))
end
RestoredCollection:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, OlLopper.EvalCache, CacheFlag.CACHE_FAMILIARS)

---@param head EntityFamiliar
function OlLopper:OnGuillotineHeadRender(head)
    local spawner = head.SpawnerEntity
    if not spawner then
        head:Remove()
        return
    end

    local player = spawner:ToPlayer()
    if not player then
        head:Remove()
        return
    end
    if not player:HasCollectible(OlLopper.ID) then
        RemoveNeckPieces(head)
        return
    end
    RenderPlayerNeck(head, head.Position)
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, OlLopper.OnGuillotineHeadRender, FamiliarVariant.GUILLOTINE)

---@param headHelper EntityFamiliar
local function HandleGuillotineHeadMovement(headHelper)
    local data = Helpers.GetData(headHelper)
    data.OldHeadDistance = data.OldHeadDistance or headHelper.OrbitDistance
    local player = headHelper.Player
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

        headHelper.OrbitDistance = data.OldHeadDistance
    elseif fireDir == Direction.NO_DIRECTION then
        local movementProgress = data.MovementProgress or 1

        if movementProgress < 1 then
            local t = Helpers.EaseOutBack(movementProgress)
            headHelper.OrbitDistance = Helpers.Lerp(headHelper.OrbitDistance, data.OldHeadDistance, t / 4)

            data.MovementProgress = math.min(movementProgress + OlLopper.HEAD_RETURN_VELOCITY, 1)
            data.GuillotineHeadAccel = data.GuillotineHeadAccel and Helpers.Lerp(data.GuillotineHeadAccel, 0, t) or 0
        end
    else
        data.GuillotineHeadAccel = data.GuillotineHeadAccel and Helpers.Lerp(data.GuillotineHeadAccel, OlLopper.HEAD_VELOCITY / 4, OlLopper.HEAD_ACCEL) or 0
        local distanceToPlayer = headHelper.Position:Distance(player.Position)

        if distanceToPlayer > OlLopper.HEAD_FREE_RANGE then
            data.GuillotineHeadAccel = 0
        end
        headHelper.OrbitDistance = headHelper.OrbitDistance + Vector.One:Resized(data.GuillotineHeadAccel)
    end
end

---@param head EntityFamiliar
function OlLopper:OnGuillotineHeadUpdate(head)
    if head.Player then
        local player = head.Player
        if player:HasCollectible(OlLopper.ID) then
            HandleGuillotineHeadMovement(head)
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, OlLopper.OnGuillotineHeadUpdate, FamiliarVariant.GUILLOTINE)