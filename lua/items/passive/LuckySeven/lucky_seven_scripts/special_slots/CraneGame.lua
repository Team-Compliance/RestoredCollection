local LuckySevenSlot = include("lua.items.passive.LuckySeven.lucky_seven_scripts.LuckySevenSlot")
local CraneGame = LuckySevenSlot:New("gfx/lucky_seven_crane_game.anm2", 180)
local Helpers = RestoredCollection.Helpers
local sfx = SFXManager()

---@param slot Entity
---@return Entity|nil
local function FindClosestTargetableEnemy(slot)
    local closestEnemy = nil
    local minDistance = math.maxinteger

    for _, entity in ipairs(Isaac.GetRoomEntities()) do
        if Helpers.IsTargetableEnemy(entity) and not Helpers.GetData(entity).IsGrappled then
            local distance = slot.Position:DistanceSquared(entity.Position)

            if distance < minDistance then
                closestEnemy = entity
                minDistance = distance
            end
        end
    end

    return closestEnemy
end


---@param slot Entity
---@param data table
local function ShootGrappleAtClosestEnemy(slot, data)
    if #data.Claws >= 5 then return end

    local closestEnemy = FindClosestTargetableEnemy(slot)

    local shootAngle = slot:GetDropRNG():RandomInt(360)
    if closestEnemy then
        shootAngle = (closestEnemy.Position - slot.Position):GetAngleDegrees()
    end

    local targetClawVelocity = Vector(9, 0):Rotated(shootAngle)

    local cordEnd = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.LUCKY_SEVEN_CORD_END.Variant, 0, slot.Position, targetClawVelocity, slot):ToEffect()
    cordEnd.Parent = slot
    cordEnd:Update()
    cordEnd.Visible = false
    Helpers.GetData(cordEnd).TargetVelocity = targetClawVelocity

    data.Claws[#data.Claws+1] = cordEnd
end


---@param player EntityPlayer
---@return boolean
function CraneGame:CanSpawn(player)
    return player:HasCollectible(CollectibleType.COLLECTIBLE_ANIMA_SOLA)
end


---@param slot Entity
function CraneGame:OnInit(slot)
    local data = Helpers.GetData(slot)
    ---@type EntityPlayer
    local player = data.SlotPlayer

    data.GrappleCooldown = player.MaxFireDelay
    data.TearDelay = 35
    data.Claws = {}

    slot:GetSprite():Play("Idle", true)
end


---@param slot Entity
function CraneGame:OnUpdate(slot)
    local data = Helpers.GetData(slot)

    if REPENTOGON and slot:GetState() == 2 or data.HasBeenTouched then
        if slot:GetSprite():IsFinished("Initiate") then
            data.SlotTimeout = 0
        end

        return true
    end

    local auxClaws = {}
    for _, claw in ipairs(data.Claws) do
        if claw:Exists() then
            auxClaws[#auxClaws+1] = claw
        end
    end
    data.Claws = auxClaws

    data.GrappleCooldown = data.GrappleCooldown - 1

    if data.GrappleCooldown <= 0 then
        ShootGrappleAtClosestEnemy(slot, data)

        data.GrappleCooldown = data.TearDelay
    end
end


---@param slot Entity
function CraneGame:OnDestroyedUpdate(slot)
    local data = Helpers.GetData(slot)

    slot:GetSprite().Color = Color(1, 1, 1, data.SlotDeathTimer / 60, 0, 0, 0)

    local spr = slot:GetSprite()
    if spr:IsFinished("Death") then
        spr:Play("Broken")
    end
end


---@param slot Entity
function CraneGame:OnCollision(slot)
    if not REPENTOGON then
        local data = Helpers.GetData(slot)
        if data.HasBeenTouched then return end
        data.HasBeenTouched = true
    end
    slot:GetSprite():Play("Initiate", true)
    sfx:Play(SoundEffect.SOUND_COIN_SLOT)
end


---@param slot Entity
function CraneGame:OnDestroy(slot)
    slot:GetSprite():Play("Death", true)

    local data = Helpers.GetData(slot)
    for _, claw in ipairs(data.Claws) do
        local clawData = Helpers.GetData(claw)
        clawData.IsGoingBack = true
        clawData.MachineDestroyed = true

        if clawData.GrappledEnemy then
            clawData.GrappledEnemy:TakeDamage(7, 0, EntityRef(slot), -1)
            clawData.GrappledEnemy:ClearEntityFlags(EntityFlag.FLAG_FREEZE)
            Helpers.GetData(clawData.GrappledEnemy).IsGrappled = false
        end

        clawData.GrappledEnemy = nil
    end
end


---@param cordEnd EntityEffect
local function SpawnCord(cordEnd)
    local head = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.LUCKY_SEVEN_CORD_HANDLER.Variant, 0, cordEnd.Position, Vector.Zero, cordEnd):ToEffect()
    head.Parent = cordEnd.Parent
    head.Visible = false
    head:Update()

    local handler = Isaac.Spawn(EntityType.ENTITY_HORF, 0, 0, cordEnd.Position, Vector.Zero, cordEnd)
    handler.Parent = cordEnd
    handler.Visible = false
    handler.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    handler.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    handler:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
    handler:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    Helpers.GetData(handler).IsCordHandler = true
    handler:Update()

    local rope = Isaac.Spawn(EntityType.ENTITY_EVIS, 10, RestoredCollection.Enums.Entities.LUCKY_SEVEN_CRANE_CORD.SubType, cordEnd.Parent.Position, Vector.Zero, cordEnd)
    cordEnd.Child = rope
    head.Child = rope

    rope.Parent = head
    rope.Target = handler

    rope:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
    rope:ClearEntityFlags(EntityFlag.FLAG_APPEAR)

    rope:GetSprite():Play("Idle", true)
    rope:Update()

    rope.SplatColor = Color(1, 1, 1, 0)

    rope:GetSprite():ReplaceSpritesheet(0, "gfx/effects/crane_game_cord.png")
    rope:GetSprite():ReplaceSpritesheet(1, "gfx/effects/crane_game_cord.png")
    rope:GetSprite():LoadGraphics()
end


---@param cordEnd EntityEffect
local function TryGrappleEnemy(cordEnd)
    local data = Helpers.GetData(cordEnd)
    local enemiesInRange = Isaac.FindInRadius(cordEnd.Position, 10, EntityPartition.ENEMY)

    for _, enemy in ipairs(enemiesInRange) do
        if Helpers.IsTargetableEnemy(enemy) and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not
        Helpers.GetData(enemy).IsGrappled then
            enemy:AddEntityFlags(EntityFlag.FLAG_FREEZE)
            data.GrappledEnemy = enemy
            data.IsGoingBack = false
            Helpers.GetData(enemy).IsGrappled = true
            break
        end
    end
end


---@param cordEnd EntityEffect
local function AttatchToEnemy(cordEnd)
    local data = Helpers.GetData(cordEnd)
    ---@type Entity
    local enemy = data.GrappledEnemy

    cordEnd.Velocity = Vector.Zero
    cordEnd.Position = enemy.Position

    if not enemy:Exists() or enemy:IsDead() then
        data.IsGoingBack = true
        data.GrappledEnemy = nil
        return
    end
end


---@param cordEnd EntityEffect
local function ReturnClawToMachine(cordEnd)
    if cordEnd.Velocity:Length() > -7 then
        cordEnd.Velocity = cordEnd.Velocity - Helpers.GetData(cordEnd).TargetVelocity:Resized(0.5)
    end

    local targetAngle = Helpers.GetData(cordEnd).TargetVelocity:GetAngleDegrees()
    local currentAngle = (cordEnd.Position - cordEnd.Parent.Position):GetAngleDegrees()

    if math.abs(targetAngle - currentAngle) > 30 then
        cordEnd:Remove()
    end
end


---@param cordEnd EntityEffect
function OnCordEndUpdate(_, cordEnd)
    local data = Helpers.GetData(cordEnd)
    cordEnd.Visible = false

    if not cordEnd.Child then
        SpawnCord(cordEnd)
    end

    if not data.GrappledEnemy and not data.MachineDestroyed then
        TryGrappleEnemy(cordEnd)
    end

    if data.IsGoingBack then
        ReturnClawToMachine(cordEnd)
    end

    if data.GrappledEnemy then
        AttatchToEnemy(cordEnd)
    else
        data.IsGoingBack = cordEnd.FrameCount > 10
    end

    if not cordEnd.Parent or not cordEnd.Parent:Exists() then
        cordEnd.Child:Remove()
        cordEnd:Remove()
        return
    end

    cordEnd.Child:Update()
    cordEnd.Child:Update()
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnCordEndUpdate, RestoredCollection.Enums.Entities.LUCKY_SEVEN_CORD_END.Variant)


local function OnCordHandlerUpdate(_, handler)
    if not handler.Parent or not handler.Parent:Exists() then
        handler:Remove()
    else
        handler.Position = handler.Parent.Position + handler.Parent.SpriteOffset + Vector(0,11)
        handler.Velocity = handler.Parent.Velocity
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, OnCordHandlerUpdate, RestoredCollection.Enums.Entities.LUCKY_SEVEN_CORD_HANDLER.Variant)



---@param npc EntityNPC
local function PreHorfHandlerUpdate(_, npc)
    if not Helpers.GetData(npc).IsCordHandler then return end

    if not npc.Parent or not npc.Parent:Exists() then
        npc:Remove()
        return
    end

    npc.Visible = false
    npc.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
    npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    npc:AddEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_STATUS_EFFECTS)
    npc.SplatColor = Color(1, 1, 1, 0)
    npc.Position = npc.Parent.Position
    npc.CanShutDoors = false

    return true
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, PreHorfHandlerUpdate, EntityType.ENTITY_HORF)


local function PreEvisCordUpdate(_, npc)
    if npc.Variant == 10 and npc.SubType == RestoredCollection.Enums.Entities.LUCKY_SEVEN_CRANE_CORD.SubType then
        if npc.Target and npc.Target.Type == EntityType.ENTITY_PLAYER then
            npc:Remove()
        end

        npc.SplatColor = Color(1, 1, 1, 0)
        return false
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_PRE_NPC_UPDATE, PreEvisCordUpdate, EntityType.ENTITY_EVIS)


return CraneGame