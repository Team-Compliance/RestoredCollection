local HUDSparks = {}
local Helpers = require("lua.helpers.Helpers")

SevenShinySparks = {
    ---@type {Position : Vector, Sprite : Sprite}[]
    Coins = {},
    ---@type {Position : Vector, Sprite : Sprite}[]
    Keys = {},
    ---@type {Position : Vector, Sprite : Sprite}[]
    Bombs = {},
    ---@type {Position : Vector, Sprite : Sprite}[]
    Poops = {}
}

local wasGamePaused = false

function HUDSparks:OnRender()
    local isGamePaused = REPENTOGON and Game():IsPauseMenuOpen() or Game():IsPaused()
    
    if isGamePaused and not wasGamePaused then
        for _, sparks in pairs(SevenShinySparks) do
            for _, spark in ipairs(sparks) do
                local color = Color(0.5, 0.5, 0.5)
                spark.Sprite.Color = color
            end
        end
    elseif not isGamePaused and wasGamePaused then
        for _, sparks in pairs(SevenShinySparks) do
            for _, spark in ipairs(sparks) do
                local color = Color(1, 1, 1)
                spark.Sprite.Color = color
            end
        end
    end

    wasGamePaused = isGamePaused
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_RENDER, HUDSparks.OnRender)


---@return boolean
---@return boolean
local function CheckForTBlueBaby()
    local areAllMainPlayersTBlueBaby = true
    local isThereMainPlayerTBlueBaby = false

    local foundIndexes = {}
    for _, player in ipairs(Helpers.GetPlayers()) do
        local controllerIndex = player.ControllerIndex

        local alreadyFound = foundIndexes[controllerIndex]

        if not alreadyFound then
            foundIndexes[controllerIndex] = true

            if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B then
                isThereMainPlayerTBlueBaby = true
            else
                areAllMainPlayersTBlueBaby = false
            end
        end
    end

    return isThereMainPlayerTBlueBaby, areAllMainPlayersTBlueBaby
end


local function GetPickupYRenderPos(pickup)
    local yPositions = {
        35,
        48,
        59,
        67
    }

    local atLeastOneTBlueBaby, allTBlueBaby = CheckForTBlueBaby()

    if pickup == "Coins" then
        --Coins always render first
        return yPositions[1]
    end

    if atLeastOneTBlueBaby then
        if allTBlueBaby then
            --If all players are T. Blue Baby, poops render in the place of bombs
            if pickup == "Poops" then
                return yPositions[2]
            elseif pickup == "Keys" then
                return yPositions[3]
            end
        else
            --If there aren't other players that aren't T. blue baby, poops render under bombs
            if pickup == "Bombs" then
                return yPositions[2]
            elseif pickup == "Poops" then
                return yPositions[3]
            elseif pickup == "Keys" then
                return yPositions[4]
            end
        end
    else
        if pickup == "Bombs" then
            return yPositions[2]
        elseif pickup == "Keys" then
            return yPositions[3]
        elseif pickup == "Poops" then
            return -100
        end
    end
end


local function AnyTBlueBabyHasBirthright()
    for _, player in ipairs(Helpers.GetPlayers()) do
        if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B and
        player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
            return true
        end
    end

    return false
end


---@param prevPosition Vector
local function NewSpark(prevPosition, pickup)
    local newSprite = Sprite()
    newSprite:Load("gfx/lucky_seven_sparkle.anm2", true)
    newSprite:Play("Idle", true)

    local yPos = GetPickupYRenderPos(pickup)

    if not yPos then return end

    local baseRenderPos = Vector(23, yPos)
    local deepPokects = REPENTOGON and PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) or #Helpers.GetPlayersByCollectible(CollectibleType.COLLECTIBLE_DEEP_POCKETS) > 0
    if deepPokects and pickup == "Coins" then
        baseRenderPos = baseRenderPos + Vector(5, 0)
    end
    
    if pickup == "Poops" and not AnyTBlueBabyHasBirthright() then
        baseRenderPos = baseRenderPos - Vector(6, 0)
    end

    local renderPos = Vector(23, yPos)

    repeat
        renderPos = baseRenderPos + Vector(math.random(5), math.random(10))
    until renderPos:DistanceSquared(prevPosition) > 12

    return {Position = renderPos, Sprite = newSprite}
end


local function UpdateSparkSprites(sparks, pickup)
    local auxSparks = {}

    for _, spark in ipairs(sparks) do
        spark.Sprite:Update()

        if spark.Sprite:GetFrame() == 5 then
            auxSparks[#auxSparks+1] = NewSpark(spark.Position, pickup)
        end

        if not spark.Sprite:IsFinished("Idle") then
            auxSparks[#auxSparks+1] = spark
        end
    end

    sparks = auxSparks

    if #sparks == 0 then
        sparks = {NewSpark(Vector.Zero, pickup)}
    end

    return sparks
end


function HUDSparks:OnFrameUpdate()
    for pickup, sparks in pairs(SevenShinySparks) do
        SevenShinySparks[pickup] = UpdateSparkSprites(sparks, pickup)
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_POST_UPDATE, HUDSparks.OnFrameUpdate)


local function RenderSparks(sparks)
    for _, spark in ipairs(sparks) do
        local hudOffset = Options.HUDOffset * Vector(20, 12)
        local renderPos = spark.Position + hudOffset

        ---@diagnostic disable-next-line: param-type-mismatch
        spark.Sprite:Render(renderPos)
    end
end


function HUDSparks:OnHud(shaderName)
    if shaderName ~= "LostItemsPackNothingShader" then return end
    if not Game():GetHUD():IsVisible() then return end
    local anyPlayer = REPENTOGON and PlayerManager.AnyoneHasCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) 
    or #Helpers.GetPlayersByCollectible(RestoredItemsPack.Enums.CollectibleType.COLLECTIBLE_LUCKY_SEVEN) > 0
    if not anyPlayer then return end

    local player = Game():GetPlayer(0)
    if player:GetNumCoins() % 10 == 7 then
        RenderSparks(SevenShinySparks.Coins)
    end

    if player:GetNumKeys() % 10 == 7 then
        RenderSparks(SevenShinySparks.Keys)
    end

    if player:GetNumBombs() % 10 == 7 then
        RenderSparks(SevenShinySparks.Bombs)
    end

    if player:GetPoopMana() % 10 == 7 then
        RenderSparks(SevenShinySparks.Poops)
    end
end
RestoredItemsPack:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, HUDSparks.OnHud)