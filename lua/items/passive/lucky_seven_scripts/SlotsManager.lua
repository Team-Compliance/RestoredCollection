local SlotsManager = {}
local Helpers = require("lua.helpers.Helpers")


function SlotsManager:OnNewRoom()
    for _, slotMachines in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, RestoredItemsPack.Enums.Entities.LUCKY_SEVEN_SLOT.Variant)) do
        slotMachines:Remove()
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, SlotsManager.OnNewRoom)

if REPENTOGON then
    function SlotsManager:LuckySevenSlotUpdate(slot)
        local data = Helpers.GetData(slot)

        if data.SlotTimeout <= 0 then
            if not data.SlotDeathTimer then
                data.SlotDeathTimer = 60
            end

            if data.MachineSparkles then
                data.MachineSparkles:Remove()
                data.MachineSparkles = nil
            end

            data.LuckySevenSlotObject:OnDestroyedUpdate(slot)

            data.SlotDeathTimer = data.SlotDeathTimer - 1

            if data.SlotDeathTimer == 0 then
                slot:Remove()
            end
        else
            local shouldStopTimer = data.LuckySevenSlotObject:OnUpdate(slot)

            if not shouldStopTimer then
                data.SlotTimeout = data.SlotTimeout - 1
            end

            if data.SlotTimeout <= 0 then
                data.LuckySevenSlotObject:OnDestroy(slot)

                slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                slot.DepthOffset = -100
                ---@diagnostic disable-next-line: param-type-mismatch
                Isaac.Explode(slot.Position + Vector(0, -5), Isaac.GetPlayer(0), 100)

                for _, player in ipairs(Helpers.GetPlayers()) do
                    local distance = player.Position:Distance(slot.Position)

                    if player.Position:Distance(slot.Position) <= 75 then
                        local velocity = player.Position - slot.Position
                        velocity:Resize((1 - distance/75) * 8)
                        player:AddVelocity(velocity)
                    end
                end

                data.SlotDeathTimer = 60
            end
        end

    end
    RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, SlotsManager.LuckySevenSlotUpdate, RestoredItemsPack.Enums.Entities.LUCKY_SEVEN_SLOT.Variant)

    ---@param slot EntitySlot
    ---@param collider Entity
    ---@param low boolean
    function SlotsManager:OnLuckySlotCollision(slot, collider, low)
        if collider and collider:ToPlayer() and slot:GetState() == 1 then
            local player = collider:ToPlayer()
            local data = Helpers.GetData(slot)
            slot:SetState(2)
            data.LuckySevenSlotObject:OnCollision(slot, player)
        end
    end
    RestoredItemsPack:AddCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, SlotsManager.OnLuckySlotCollision, RestoredItemsPack.Enums.Entities.LUCKY_SEVEN_SLOT.Variant)
else
    ---@param player EntityPlayer
    ---@param slot Entity
    local function IsPlayerCollidingWithSlot(player, slot)
        if slot.SizeMulti then
            if (math.abs(slot.Position.X - player.Position.X) ^ 2 <= (slot.Size*slot.SizeMulti.X + (player.Size+0.1)) ^ 2) and
            (math.abs(slot.Position.Y-player.Position.Y) ^ 2 <= (slot.Size*slot.SizeMulti.Y + (player.Size+0.1)) ^ 2) then
                return true
            end
        else
            if slot.Position:DistanceSquared(player.Position) <= (slot.Size + player.Size) ^ 2 then
                return true
            end
        end

        return false
    end


    function SlotsManager:OnFrameUpdate()
        local luckySevenSlotsInRoomAux = {}

        for _, luckySevenSlot in ipairs(RestoredItemsPack.LuckySevenSlotsInRoom) do
            local keepMachine = true
            local data = Helpers.GetData(luckySevenSlot)

            if data.SlotTimeout <= 0 then
                if not data.SlotDeathTimer then
                    data.SlotDeathTimer = 60
                end

                if data.MachineSparkles then
                    data.MachineSparkles:Remove()
                    data.MachineSparkles = nil
                end

                data.LuckySevenSlotObject:OnDestroyedUpdate(luckySevenSlot)

                data.SlotDeathTimer = data.SlotDeathTimer - 1

                if data.SlotDeathTimer == 0 then
                    luckySevenSlot:Remove()
                    keepMachine = false
                end
            else
                for _, player in ipairs(Isaac.FindInRadius(luckySevenSlot.Position, 40, EntityPartition.PLAYER)) do
                    player = player:ToPlayer()
                    if IsPlayerCollidingWithSlot(player, luckySevenSlot) then
                        data.LuckySevenSlotObject:OnCollision(luckySevenSlot, player)
                    end
                end

                local shouldStopTimer = data.LuckySevenSlotObject:OnUpdate(luckySevenSlot)

                if not shouldStopTimer then
                    data.SlotTimeout = data.SlotTimeout - 1
                end

                if data.SlotTimeout <= 0 then
                    data.LuckySevenSlotObject:OnDestroy(luckySevenSlot)

                    luckySevenSlot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                    luckySevenSlot.DepthOffset = -100
                    ---@diagnostic disable-next-line: param-type-mismatch
                    Isaac.Explode(luckySevenSlot.Position + Vector(0, -5), Isaac.GetPlayer(0), 100)

                    for i = 0, Game():GetNumPlayers() - 1, 1 do
                        local player = Game():GetPlayer(i)

                        local distance = player.Position:Distance(luckySevenSlot.Position)

                        if player.Position:Distance(luckySevenSlot.Position) <= 75 then
                            local velocity = player.Position - luckySevenSlot.Position
                            velocity:Resize((1 - distance/75) * 8)
                            player:AddVelocity(velocity)
                        end
                    end

                    data.SlotDeathTimer = 60
                end
            end

            if keepMachine then
                luckySevenSlotsInRoomAux[#luckySevenSlotsInRoomAux+1] = luckySevenSlot
            end
        end

        RestoredItemsPack.LuckySevenSlotsInRoom = luckySevenSlotsInRoomAux
    end
    RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_UPDATE, SlotsManager.OnFrameUpdate)
end

---@param source EntityRef
function SlotsManager:OnPlayerDamage(_, _, _, source)
    if (source.Type == EntityType.ENTITY_SLOT and source.Variant == RestoredItemsPack.Enums.Entities.LUCKY_SEVEN_SLOT.Variant) or
    (source.SpawnerType == EntityType.ENTITY_SLOT and source.SpawnerVariant == RestoredItemsPack.Enums.Entities.LUCKY_SEVEN_SLOT.Variant) then
        return false
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, SlotsManager.OnPlayerDamage, EntityType.ENTITY_PLAYER)