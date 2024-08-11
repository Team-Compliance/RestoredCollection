if not REPENTOGON then return end
--player override, taken from the vanilla lua api
local META, META0
local function BeginClass(T)
	META = {}
	if type(T) == "function" then
		META0 = getmetatable(T())
	else
		META0 = getmetatable(T).__class
	end
end

local function EndClass()
	local oldIndex = META0.__index
	local newMeta = META
	
	rawset(META0, "__index", function(self, k)
		return newMeta[k] or oldIndex(self, k)
	end)
end

BeginClass(EntityPlayer)
local origGetMultishotParams = META0.GetMultiShotParams
function META:GetMultiShotParams(type)
    local p_data = self:GetData()
    if p_data.currentModifiedMultishotObj ~= nil then
        return p_data.currentModifiedMultishotObj
    end
    return origGetMultishotParams(self, type)
end
EndClass(EntityPlayer)

local function getMultishotParams(_, player)
    local callbacks = Isaac.GetCallbacks(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS)
    local p_data = player:GetData()
    for index, callback in ipairs(callbacks) do
        if callback.Priority ~= CallbackPriority.IMPORTANT then
            local params = callback.Function(callback.Mod, player)
            if params ~= nil then
                p_data.currentModifiedMultishotObj = params
            end
        end
    end

    local result = p_data.currentModifiedMultishotObj
    p_data.currentModifiedMultishotObj = nil
    return result
end
RestoredCollection:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_GET_MULTI_SHOT_PARAMS, CallbackPriority.IMPORTANT, getMultishotParams)