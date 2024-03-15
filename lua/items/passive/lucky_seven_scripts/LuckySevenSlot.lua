local LuckySevenSlot = {
    SPRITE = nil,
    TIMEOUT = 0,
}

function LuckySevenSlot:New(sprite, timeout)
    --Default is empty table
    local luckySevenSlot = {
        SPRITE = sprite,
        TIMEOUT = timeout,
    }

    setmetatable(luckySevenSlot, self)
    self.__index = self

    return luckySevenSlot
end


---@param player EntityPlayer
---@return boolean
function LuckySevenSlot:CanSpawn(player)
    return true
end


---@param slot Entity
function LuckySevenSlot:__Init(slot)
    slot:GetSprite():Load(self.SPRITE, true)
    slot.SizeMulti = Vector(1.5, 0.75)

    self:OnInit(slot)
end


---@param slot Entity
function LuckySevenSlot:OnInit(slot)
end


---@param slot Entity
function LuckySevenSlot:OnUpdate(slot)
end


---@param slot Entity
function LuckySevenSlot:OnDestroyedUpdate(slot)
end


---@param slot Entity
---@param player EntityPlayer
function LuckySevenSlot:OnCollision(slot, player)
end


---@param slot Entity
function LuckySevenSlot:OnDestroy(slot)
end


return LuckySevenSlot