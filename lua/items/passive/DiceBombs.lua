local DiceBombsLocal = {}
local Helpers = require("lua.helpers.Helpers")

local DiceBombItemBlacklist = {
    [CollectibleType.COLLECTIBLE_POLAROID] = true,
    [CollectibleType.COLLECTIBLE_NEGATIVE] = true,
    [CollectibleType.COLLECTIBLE_DADS_NOTE] = true,
    [CollectibleType.COLLECTIBLE_NULL] = true
}

local DiceBombPickupBlacklist = {
    [PickupVariant.PICKUP_BED] = true,
    [PickupVariant.PICKUP_BIGCHEST] = true,
    [PickupVariant.PICKUP_MOMSCHEST] = true,
    [PickupVariant.PICKUP_SHOPITEM] = true,
    [PickupVariant.PICKUP_THROWABLEBOMB] = true,
    [PickupVariant.PICKUP_TROPHY] = true,
    [PickupVariant.PICKUP_COLLECTIBLE] = true
}

---@param bomb EntityBomb
function DiceBombsLocal:D1BombExplode(bomb, player, radius)
    local pickup
    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PICKUP and not DiceBombPickupBlacklist[entity.Variant] then
        pickup = entity
        end
    end
    if pickup then
        if pickup.Variant ~= PickupVariant.PICKUP_BOMB then
            Isaac.Spawn(EntityType.ENTITY_PICKUP, pickup.Variant, 0, bomb.Position, Vector.Zero, nil)
        else 
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_BOMB, BombSubType.BOMB_NORMAL, bomb.Position, Vector.Zero, nil)
        end
    end
    return true
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.D1BombExplode, CollectibleType.COLLECTIBLE_D1)

---@param bomb EntityBomb
function DiceBombsLocal:D4BombExplode(bomb, player, radius)
    local itemConf = Isaac.GetItemConfig():GetCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)
    if REPENTOGON then
        itemConf.Tags = itemConf.Tags | ItemConfig.TAG_QUEST
    end

    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PLAYER and entity.Variant == 0 then
            entity:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D4, 1)
        end
    end
    
    if REPENTOGON then
        itemConf.Tags = itemConf.Tags & ~ItemConfig.TAG_QUEST
    end

    return true
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.D4BombExplode, CollectibleType.COLLECTIBLE_D4)

---@param bomb EntityBomb
function DiceBombsLocal:D6BombExplode(bomb, player, radius)		
    local rng = bomb:GetDropRNG()
    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            if not DiceBombItemBlacklist[entity.SubType] then
                if rng:RandomInt(4) > 0 then --25% chance to break the pedestal
                    local itemPool = Game():GetItemPool()
                    local poolType = itemPool:GetPoolForRoom(Game():GetRoom():GetType(), entity.InitSeed)
                    local col = itemPool:GetCollectible(poolType, true)
                    entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, col, true)
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
                else
                    entity:Remove()
                    Game():SpawnParticles(entity.Position, EffectVariant.ROCK_PARTICLE, rng:RandomInt(2) + 3, 6, Color(1,1,1,1,15/255,15/255,15/255), _, 1)
                    SFXManager():Play(SoundEffect.SOUND_MUSHROOM_POOF_2)
                    SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
                end
            end
        end
    end
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.D6BombExplode, CollectibleType.COLLECTIBLE_D6)

---@param bomb EntityBomb
function DiceBombsLocal:D8BombExplode(bomb, player, radius)
    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PLAYER and entity.Variant == 0 then
            entity:ToPlayer():UseActiveItem(CollectibleType.COLLECTIBLE_D8, 1)
        end
    end
    return true
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.D8BombExplode, CollectibleType.COLLECTIBLE_D8)

---@param bomb EntityBomb
function DiceBombsLocal:D20BombExplode(bomb, player, radius)
    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PICKUP and not DiceBombPickupBlacklist[entity.Variant] then
            entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, 0, 0)
        end
    end
    return true
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.D20BombExplode, CollectibleType.COLLECTIBLE_D20)

---@param bomb EntityBomb
function DiceBombsLocal:SpindownBombExplode(bomb, player, radius)
    local rng = bomb:GetDropRNG()
    for i, entity in ipairs(Isaac.FindInRadius(bomb.Position, radius)) do
        if entity.Type == EntityType.ENTITY_PICKUP and entity.Variant == PickupVariant.PICKUP_COLLECTIBLE then
            if not DiceBombItemBlacklist[entity.SubType] then
                if rng:RandomInt(4) > 0 then --25% chance to break the pedestal
                    local itemshift = entity.SubType - 1
                    while true do
                        if (ItemConfig.Config.IsValidCollectible(itemshift) and Isaac.GetItemConfig():GetCollectible(itemshift):IsAvailable()) or itemshift <= 1 then
                            entity:ToPickup():Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemshift, true)
                            Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
                            break
                        end
                        itemshift = itemshift - 1
                    end
                else
                    entity:Remove()
                    Game():SpawnParticles(entity.Position, EffectVariant.ROCK_PARTICLE, rng:RandomInt(2) + 3, 6, Color(1,1,1,1,15/255,15/255,15/255), _, 1)
                    SFXManager():Play(SoundEffect.SOUND_MUSHROOM_POOF_2)
                    SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE)
                end
            end
        end
    end
end
RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, DiceBombsLocal.SpindownBombExplode, CollectibleType.COLLECTIBLE_SPINDOWN_DICE)

RestoredCollection:AddCallback(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION, function(_, bomb, player, radius)
    DiceBombsLocal:D1BombExplode(bomb, player, radius)
    DiceBombsLocal:D4BombExplode(bomb, player, radius)
    DiceBombsLocal:D6BombExplode(bomb, player, radius)
    DiceBombsLocal:D8BombExplode(bomb, player, radius)
    DiceBombsLocal:D20BombExplode(bomb, player, radius)
end, CollectibleType.COLLECTIBLE_D100)

local DiceBombSpritesheets = {
    [CollectibleType.COLLECTIBLE_D1] = {"gfx/items/pick ups/bombs/costumes/dice_d1.png", "gfx/items/pick ups/bombs/costumes/dice_d1_gold.png"},
    [CollectibleType.COLLECTIBLE_D4] = {"gfx/items/pick ups/bombs/costumes/dice_d4.png", "gfx/items/pick ups/bombs/costumes/dice_d4_gold.png"},
    [CollectibleType.COLLECTIBLE_D6] = {"gfx/items/pick ups/bombs/costumes/dice_d6.png", "gfx/items/pick ups/bombs/costumes/dice_d6_gold.png"},
    [CollectibleType.COLLECTIBLE_D8] = {"gfx/items/pick ups/bombs/costumes/dice_d8.png", "gfx/items/pick ups/bombs/costumes/dice_d8_gold.png"},
    [CollectibleType.COLLECTIBLE_D20] = {"gfx/items/pick ups/bombs/costumes/dice_d20.png", "gfx/items/pick ups/bombs/costumes/dice_d20_gold.png"},
    [CollectibleType.COLLECTIBLE_D100] = {"gfx/items/pick ups/bombs/costumes/dice_d100.png", "gfx/items/pick ups/bombs/costumes/dice_d100_gold.png"},
    [CollectibleType.COLLECTIBLE_SPINDOWN_DICE] = {"gfx/items/pick ups/bombs/costumes/dice_spindown.png", "gfx/items/pick ups/bombs/costumes/dice_spindown_gold.png"},
}

function DiceBombs.AddDice(diceID, gfxNormal, gfxGolden)
    if diceID and type(diceID) == "number" and not DiceBombSpritesheets[diceID] then
        local normalBombGFX = "gfx/items/pick ups/bombs/costumes/dice_modded.png"
        local goldenBombGFX = "gfx/items/pick ups/bombs/costumes/dice_modded_gold.png"
        if gfxNormal and type(gfxNormal) == "string" then normalBombGFX = gfxNormal end
        if gfxGolden and type(gfxGolden) == "string" then goldenBombGFX = gfxGolden end
        DiceBombSpritesheets[diceID] = {normalBombGFX, goldenBombGFX}
    end
end

local function InitDiceVariant(bomb)
    local player = Helpers.GetPlayerFromTear(bomb)
    if not player then return end
    local data = Helpers.GetData(bomb)
    if data.DiceBombVariant then return end
    data.DiceBombVariant = CollectibleType.COLLECTIBLE_D6
    for i = 0, 3 do
        if DiceBombSpritesheets[player:GetActiveItem(i)] then
            data.DiceBombVariant = player:GetActiveItem(i)
            break
        end
        if REPENTOGON and player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_D_INFINITY then
            data.DiceBombVariant = CollectibleType.COLLECTIBLE_D6
            local DiceVarData = {
                [0] = CollectibleType.COLLECTIBLE_D1,
                [0x10000] = CollectibleType.COLLECTIBLE_D4,
                [0x30000] = CollectibleType.COLLECTIBLE_D6,
                [0x50000] = CollectibleType.COLLECTIBLE_D8,
                [0x80000] = CollectibleType.COLLECTIBLE_D20,
                [0x90000] = CollectibleType.COLLECTIBLE_D100,
            }
            local activeItemDesc = player:GetActiveItemDesc(i)
            local dice = DiceVarData[activeItemDesc.VarData] or DiceVarData[activeItemDesc.VarData - player:GetActiveMinUsableCharge(i)]
            if dice then
                data.DiceBombVariant = dice
            end
        end
    end
end

function DiceBombsLocal:BombInit(bomb)
    if Helpers.GetData(bomb).BombInit then return end
    local player = Helpers.GetPlayerFromTear(bomb)
	if player then
		local data = Helpers.GetData(bomb)
        local rng = bomb:GetDropRNG()
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS) and 
        (not bomb.IsFetus or bomb.IsFetus and rng:RandomInt(100) < 20)then
			if (bomb.Variant > BombVariant.BOMB_SUPERTROLL or bomb.Variant < BombVariant.BOMB_TROLL) then
				if bomb.Variant == 0 then
					bomb.Variant = RestoredCollection.Enums.BombVariant.BOMB_DICE
				end
			end            
			BombFlagsAPI.AddCustomBombFlag(bomb, "DICE_BOMB")
            InitDiceVariant(bomb)
		end
	end
end
--RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_INIT, DiceBombsLocal.BombInit)

function DiceBombsLocal:DiceRocketInit(rocket)
    local player = Helpers.GetPlayerFromTear(rocket)
	if player then
        local rng = rocket:GetDropRNG()
		if player:HasCollectible(RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS) and rng:RandomInt(100) < 20 then
            InitDiceVariant(rocket)
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, DiceBombsLocal.DiceRocketInit, EffectVariant.ROCKET)

function DiceBombsLocal:DiceRocketExplode(rocket)
    if rocket.Type == EntityType.ENTITY_EFFECT and rocket.Variant == EffectVariant.ROCKET then
        local player = Helpers.GetPlayerFromTear(rocket)
        if not player then return end
        local data = Helpers.GetData(rocket)
        if data.DiceBombVariant then
            local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
            local d6Ran = false
            local isBomber = player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)
            local radius = Helpers.GetBombRadiusFromDamage(20, isBomber)
            for _, callback in ipairs(callbacks) do
                if callback.Param and callback.Param == data.DiceBombVariant then
                    local ret = callback.Function(callback.Mod, rocket, player, radius)
                    if ret ~= nil and type(ret) == "boolean" and ret == true and not d6Ran then
                        d6Ran = true
                        DiceBombsLocal:D6BombExplode(rocket, player, radius)
                    end
                end
            end
        end
    end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, DiceBombsLocal.DiceRocketExplode)

---@param bomb EntityBomb
function DiceBombsLocal:BombUpdate(bomb)
	local player = Helpers.GetPlayerFromTear(bomb)

	local data = Helpers.GetData(bomb)
	
    if bomb.FrameCount == 1 then
        DiceBombsLocal:BombInit(bomb)
        if bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_DICE then
            local sprite = bomb:GetSprite()
            local anim = sprite:GetAnimation()
            local file = sprite:GetFilename()
            sprite:Load("gfx/items/pick ups/bombs/dice"..file:sub(file:len()-5), true)
            sprite:Play(anim, true)
        end
    end
    
	if BombFlagsAPI.HasCustomBombFlag(bomb, "DICE_BOMB") then
        local sprite = bomb:GetSprite()
        InitDiceVariant(bomb)
        if bomb.Variant == RestoredCollection.Enums.BombVariant.BOMB_DICE
        and not bomb:HasTearFlags(TearFlags.TEAR_BRIMSTONE_BOMB) then
            local diceBombGFX = DiceBombSpritesheets[CollectibleType.COLLECTIBLE_D6]
            if DiceBombSpritesheets[data.DiceBombVariant] then
                diceBombGFX = DiceBombSpritesheets[data.DiceBombVariant]
            end
            
            if not bomb:HasTearFlags(TearFlags.TEAR_GOLDEN_BOMB) then
                sprite:ReplaceSpritesheet(0, diceBombGFX[1])
            else
                sprite:ReplaceSpritesheet(0, diceBombGFX[2])
            end
            sprite:LoadGraphics()
        end
        
		if sprite:IsPlaying("Explode") then
            local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
            local d6Ran = false
            local isBomber = player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)
            local radius = Helpers.GetBombRadiusFromDamage(bomb.ExplosionDamage, isBomber)
            for _, callback in ipairs(callbacks) do
                if callback.Param and callback.Param == data.DiceBombVariant then
                    local ret = callback.Function(callback.Mod, bomb, player, radius)
                    if ret ~= nil and type(ret) == "boolean" and ret == true and not d6Ran then
                        d6Ran = true
                        DiceBombsLocal:D6BombExplode(bomb, player, radius)
                    end
                end
            end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, DiceBombsLocal.BombUpdate)

RestoredCollection:AddCallback("ON_STOMP_EXPLOSION", function(_, player, bombDamage, radius)
    local DiceBombVariant = CollectibleType.COLLECTIBLE_D6
    for i = 0, 3 do
        if DiceBombSpritesheets[player:GetActiveItem(i)] then
            DiceBombVariant = player:GetActiveItem(i)
            break
        end
        if REPENTOGON and player:GetActiveItem(i) == CollectibleType.COLLECTIBLE_D_INFINITY then
            DiceBombVariant = CollectibleType.COLLECTIBLE_D6
            local DiceVarData = {
                [0] = CollectibleType.COLLECTIBLE_D1,
                [0x10000] = CollectibleType.COLLECTIBLE_D4,
                [0x30000] = CollectibleType.COLLECTIBLE_D6,
                [0x50000] = CollectibleType.COLLECTIBLE_D8,
                [0x80000] = CollectibleType.COLLECTIBLE_D20,
                [0x90000] = CollectibleType.COLLECTIBLE_D100,
            }
            local activeItemDesc = player:GetActiveItemDesc(i)
            local dice = DiceVarData[activeItemDesc.VarData] or DiceVarData[activeItemDesc.VarData - player:GetActiveMinUsableCharge(i)]
            if dice then
                DiceBombVariant = dice
            end
        end
    end
	local callbacks = Isaac.GetCallbacks(RestoredCollection.Enums.Callbacks.ON_DICE_BOMB_EXPLOSION)
    local d6Ran = false
    for _, callback in ipairs(callbacks) do
        if callback.Param and callback.Param == DiceBombVariant then
            local ret = callback.Function(callback.Mod, player, player, radius)
            if ret ~= nil and type(ret) == "boolean" and ret == true and not d6Ran then
                d6Ran = true
                DiceBombsLocal:D6BombExplode(player, player, radius)
            end
        end
    end
end, RestoredCollection.Enums.CollectibleType.COLLECTIBLE_DICE_BOMBS)