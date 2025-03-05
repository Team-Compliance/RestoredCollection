local Helpers = {}

local turretList = {{831,10,-1}, {835,10,-1}, {887,-1,-1}, {951,-1,-1}, {815,-1,-1}, {306,-1,-1}, {837,-1,-1}, {42,-1,-1}, {201,-1,-1}, 
{202,-1,-1}, {203,-1,-1}, {235,-1,-1}, {236,-1,-1}, {804,-1,-1}, {809,-1,-1}, {68,-1,-1}, {864,-1,-1}, {44,-1,-1}, {218,-1,-1}, {877,-1,-1},
{893,-1,-1}, {915,-1,-1}, {291,-1,-1}, {295,-1,-1}, {404,-1,-1}, {409,-1,-1}, {903,-1,-1}, {293,-1,-1}, {964,-1,-1},}

local vectorDirection = {[Direction.NO_DIRECTION] = Vector(0, 0), [Direction.UP] = Vector(0, -1), [Direction.DOWN] = Vector(0, 1), [Direction.LEFT] = Vector(-1, 0),[Direction.RIGHT] = Vector(1, 0)}

local function RemoveStoreCreditFromPlayer(player) -- Partially from FF
	local t0 = player:GetTrinket(0)
	local t1 = player:GetTrinket(1)
	
	if t0 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	elseif t1 & TrinketType.TRINKET_ID_MASK == TrinketType.TRINKET_STORE_CREDIT then
		player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		return
	end
	if REPENTOGON then
		player:TryRemoveSmeltedTrinket(TrinketType.TRINKET_STORE_CREDIT)
	else
		local numStoreCredits = player:GetTrinketMultiplier(TrinketType.TRINKET_STORE_CREDIT)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MOMS_BOX) then
			numStoreCredits = numStoreCredits - 1
		end
		
		if numStoreCredits >= 2 then
			player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT + TrinketType.TRINKET_GOLDEN_FLAG)
		else
			player:TryRemoveTrinket(TrinketType.TRINKET_STORE_CREDIT)
		end
	end
end

local function TryRemoveStoreCredit(player)
	if Game():GetRoom():GetType() == RoomType.ROOM_SHOP then
		if player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) then
			RemoveStoreCreditFromPlayer(player)
		else
			for _,player in ipairs(Helpers.Filter(Helpers.GetPlayers(), function(_, player) return player:HasTrinket(TrinketType.TRINKET_STORE_CREDIT) end)) do
				RemoveStoreCreditFromPlayer(player)
				return
			end
		end
	end
end

function Helpers.HereticBattle(enemy)
	local room = Game():GetRoom()
	if room:GetType() == RoomType.ROOM_BOSS and room:GetBossID() == 81 and enemy.Type == EntityType.ENTITY_EXORCIST then
		return true
	end
	return false
end


function Helpers.IsTurret(enemy)
	for _,e in ipairs(turretList) do
		if e[1] == enemy.Type and (e[2] == -1 or e[2] == enemy.Variant) and (e[3] == -1 or e[3] == enemy.SubType) then
			return true
		end
	end
	return false
end

function Helpers.IsLost(player)
    if REPENTOGON then
		return player:GetHealthType() == HealthType.NO_HEALTH and player:GetPlayerType() ~= PlayerType.PLAYER_THESOUL_B
	end
	for _,pType in ipairs({PlayerType.PLAYER_THELOST, PlayerType.PLAYER_THELOST_B, PlayerType.PLAYER_JACOB2_B}) do
		if Helpers.IsPlayerType(player, pType) then
			return true
		end
	end
	return false
end

function Helpers.IsGhost(player)
    return player:GetEffects():HasNullEffect(NullItemID.ID_LOST_CURSE) or Helpers.IsLost(player)
end

function Helpers.CanCollectCustomShopPickup(player, pickup)
	if pickup:IsShopItem() and (pickup.Price > 0 and player:GetNumCoins() < pickup.Price or not player:IsExtraAnimationFinished())
	or pickup.Wait > 0 then
		return false
	end
	return true
end

function Helpers.CollectCustomPickup(player,pickup)
	if not Helpers.CanCollectCustomShopPickup(player, pickup) then
		return pickup:IsShopItem()
	end
	if not pickup:IsShopItem() then
		pickup:GetSprite():Play("Collect")
		pickup:Die()
	else
		if pickup.Price >= 0 or pickup.Price == PickupPrice.PRICE_FREE or pickup.Price == PickupPrice.PRICE_SPIKES then
			if pickup.Price == PickupPrice.PRICE_SPIKES and not Helpers.IsGhost(player) then
				local tookDamage = player:TakeDamage(2.0, 268435584, EntityRef(nil), 30)
				if not tookDamage then
					return pickup:IsShopItem()
				end
			end
			if pickup.Price >= 0 then
				player:AddCoins(-pickup.Price)
			end
			CustomHealthAPI.Library.TriggerRestock(pickup)
			TryRemoveStoreCredit(player)
			pickup:Remove()
			player:AnimatePickup(pickup:GetSprite(), true)
		end
	end
	if pickup.OptionsPickupIndex ~= 0 then
		local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
		for _, entity in ipairs(pickups) do
			if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
			(entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
			then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, Vector.Zero, nil)
				entity:Remove()
			end
		end
	end
	return nil
end

function Helpers.InBoilerMirrorWorld()
	return FFGRACE and FFGRACE:IsBoilerMirrorWorld()
end

function Helpers.InMirrorWorld()
	return Game():GetRoom():IsMirrorWorld() or Helpers.InBoilerMirrorWorld()
end

---@param enemy Entity
---@param allEnemies boolean?
---@return boolean
function Helpers.IsEnemy(enemy, allEnemies)
	allEnemies = allEnemies or false
	return enemy and (enemy:IsVulnerableEnemy() or allEnemies) and enemy:IsActiveEnemy() and enemy:IsEnemy()
	and not EntityRef(enemy).IsFriendly
end

---@param allEnemies boolean | nil
---@param noBosses boolean | nil
---@return EntityNPC[]
function Helpers.GetEnemies(allEnemies, noBosses)
	local enemies = {}
	for _,enemy in ipairs(Isaac.GetRoomEntities()) do
		enemy = enemy:ToNPC()
		if Helpers.IsEnemy(enemy, allEnemies) then
			if not enemy:IsBoss() or (enemy:IsBoss() and not noBosses) then
				if enemy.Type == EntityType.ENTITY_ETERNALFLY then
					enemy:Morph(EntityType.ENTITY_ATTACKFLY,0,0,-1)
				end
				if not Helpers.HereticBattle(enemy) and not Helpers.IsTurret(enemy) and enemy.Type ~= EntityType.ENTITY_BLOOD_PUPPY then
					table.insert(enemies,enemy)
				end
			end
		end
	end
	return enemies
end


function Helpers.Lerp(a, b, t, speed)
	speed = speed or 1
	return a + (b-a) * speed * t
end

---@param player EntityPlayer
---@return boolean
function Helpers.IsPlayingExtraAnimation(player)
    local sprite = player:GetSprite()
    local anim = sprite:GetAnimation()

    local normalAnims = {
        ["WalkUp"] = true,
        ["WalkDown"] = true,
        ["WalkLeft"] = true,
        ["WalkRight"] = true
    }

    return not normalAnims[anim]
end

function Helpers.Sign(x)
	return x >= 0 and 1 or -1
end

function Helpers.IsMenuing()
	if ModConfigMenu and ModConfigMenu.IsVisible or DeadSeaScrollsMenu and DeadSeaScrollsMenu.OpenedMenu then return true end
	return false
end

function Helpers.IsPlayerType(player, type)
	return player:GetPlayerType() == type
end

function Helpers.IsAnyPlayerType(player, ...)
	local pTypeTable = {...}
	if #pTypeTable > 0 then
		for _, pType in pairs(pTypeTable) do
			if Helpers.IsPlayerType(player, pType) then
				return true
			end
		end
		
	end
	return false
end

function Helpers.GetPlayerIndex(player)
    local id = 1
	if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS2_B then
		id = 2
	end
	return player:GetCollectibleRNG(id):GetSeed()
end

function Helpers.GetEntityData(entity)
	if entity then
		if entity:ToPlayer() then
			local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "PlayerData")
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			if not player then return nil end
			local index = tostring(Helpers.GetPlayerIndex(player))
			if not data[index] then
				data[index] = {}
			end
			if not data[index].BethsHeartIdentifier then
				data[index].BethsHeartIdentifier = tonumber(index)
			end
			return data[index]
		elseif entity:ToFamiliar() then
			local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "FamiliarData")
			local index = tostring(entity:ToFamiliar().InitSeed)
			if not data[index] then
				data[index] = {}
			end
			return data[index]
		end
	end
	return nil
end

function Helpers.RemoveEntityData(entity)
	if entity then
		local index
		if entity:ToPlayer() then
			local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "PlayerData")
			local player = entity:ToPlayer()
			if player:GetPlayerType() == PlayerType.PLAYER_THESOUL_B then
				player = player:GetOtherTwin()
			end
			if not player then return nil end
			index = tostring(Helpers.GetPlayerIndex(player))
			--local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "PlayerData")
			data[index] = nil
		elseif entity:ToFamiliar() then
			local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "FamiliarData")
			index = tostring(entity:ToFamiliar().InitSeed)
			--local data = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "FamiliarData")
			data[index] = nil
		end
	end
end

function Helpers.GetBombExplosionRadius(bomb)
	local damage = bomb.ExplosionDamage
	local radiusMult = bomb.RadiusMultiplier
	local radius

	if damage >= 175.0 then
		radius = 105.0
	else
		if damage <= 140.0 then
			radius = 75.0
		else
			radius = 90.0
		end
	end

	return radius * radiusMult
end


function Helpers.GetBombRadiusFromDamage(damage,isBomber)
	if 300 <= damage then
		return 300.0
	elseif isBomber then
		return 155.0
	elseif 175.0 <= damage then
		return 105.0
	else
		if damage <= 140.0 then
			return 75.0
		else
			return 90.0
		end
	end
end

--self explanatory
function Helpers.GetCharge(player,slot)
	return player:GetActiveCharge(slot) + player:GetBatteryCharge(slot)
end

function Helpers.BatteryChargeMult(player)
	return player:HasCollectible(CollectibleType.COLLECTIBLE_BATTERY) and 2 or 1
end

function Helpers.GetUnchargedSlot(player,slot)
	local charge = Helpers.GetCharge(player, slot)
	local battery = Helpers.BatteryChargeMult(player)
	local item = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem(slot))
	if player:GetActiveItem(slot) == CollectibleType.COLLECTIBLE_ALABASTER_BOX then
		if charge < item.MaxCharges then
			return slot
		end
	elseif player:GetActiveItem(slot) > 0 and charge < item.MaxCharges * battery and player:GetActiveItem(slot) ~= CollectibleType.COLLECTIBLE_ERASER then
		return slot
	elseif slot < ActiveSlot.SLOT_POCKET then
		slot = Helpers.GetUnchargedSlot(player,slot + 1)
		return slot
	end
	return nil
end

--hud and sfx reactions in all slots
function Helpers.ChargeBowl(player)
	for slot = 0,2 do
		if player:GetActiveItem(slot) == RestoredCollection.Enums.CollectibleType.COLLECTIBLE_BOWL_OF_TEARS then
			local charge = Helpers.GetCharge(player,slot)
			if charge < 6 * Helpers.BatteryChargeMult(player) then
				player:SetActiveCharge(charge+1,slot)
				Game():GetHUD():FlashChargeBar(player,slot)
				if charge >= 5 then
					SFXManager():Play(SoundEffect.SOUND_ITEMRECHARGE)
				else
					SFXManager():Play(SoundEffect.SOUND_BEEP)
				end
			end
		end
	end
end

function Helpers.OverCharge(player,slot,item)
	local effect = Isaac.Spawn(1000,49,1,player.Position+Vector(0,1),Vector.Zero,nil)
	effect:GetSprite().Offset = Vector(0,-22)
end

function Helpers.GetNearestEnemy(_pos)
	local distance = 9999999
	local closestPos = nil
	local enemies = Isaac.GetRoomEntities()
	for i=1, #enemies do
		local enemy = enemies[i]:ToNPC()
		if (enemy) and (enemy:IsVulnerableEnemy()) and (not enemy:HasEntityFlags(EntityFlag.FLAG_FRIENDLY | EntityFlag.FLAG_CHARM)) then
			if (_pos - enemy.Position):Length() < distance then
				closestPos = enemy
				distance = (_pos - enemy.Position):Length()
			end
		end
	end
	if distance == 9999999 then
		return Game():GetNearestPlayer(_pos)
	else
		return closestPos
	end
end

function Helpers.GetDirectionFromVector(_vec)
	local angle = _vec:GetAngleDegrees()
	if (angle < 45 and angle >= -45) then
		return Direction.RIGHT
	elseif (angle < -45 and angle >= -135) then
		return Direction.UP
	elseif (angle > 45 and angle <= 135) then
		return Direction.DOWN
	end
	return Direction.LEFT
end

---@param direction Direction | integer
---@return Vector
function Helpers.GetVectorFromDirection(direction)
	return vectorDirection[direction]
end

function Helpers.Shuffle(list)
	local size, shuffled  = #list, list
    for i = size, 2, -1 do
		local j = math.random(i)
		shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
	end
    return shuffled
end

function Helpers.GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size -1
end

function Helpers.GetMaxTrinketID()
    return Isaac.GetItemConfig():GetTrinkets().Size -1
end

function Helpers.tearsUp(firedelay, val)
    local currentTears = Helpers.ToTearsPerSecond(firedelay)
    local newTears = currentTears + val
    return math.max(Helpers.ToMaxFireDelay(newTears), -0.75)
end

function Helpers.GetTrueRange(player)
    return player.Range / 40.0
end

function Helpers.rangeUp(range, val)
    local currentRange = range / 40.0
    local newRange = currentRange + val
    return math.max(1.0,newRange) * 40.0
end

function Helpers.GridAlignPosition(pos)
	local x = pos.X
	local y = pos.Y

	x = 40 * math.floor(x/40 + 0.5)
	y = 40 * math.floor(y/40 + 0.5)

	return Vector(x, y)
end

---@param enemy Entity
---@return boolean
function Helpers.IsTargetableEnemy(enemy)
    return enemy:IsEnemy() and enemy:IsVulnerableEnemy() and enemy:IsActiveEnemy() and
    not (enemy:IsBoss() or enemy.Type == EntityType.ENTITY_FIREPLACE or
    (enemy.Type == EntityType.ENTITY_EVIS and enemy.Variant == 10))
end


---@param player EntityPlayer
function Helpers.DoesPlayerHaveRightAmountOfPickups(player)
    local has7Coins = player:GetNumCoins() % 10 == 7
    local has7Keys = player:GetNumKeys() % 10 == 7
    local has7Bombs = player:GetNumBombs() % 10 == 7
    local has7Poops = player:GetPoopMana() % 10 == 7

    return has7Bombs or has7Coins or has7Keys or has7Poops
end


---@param player EntityPlayer
function Helpers.GetLuckySevenTearChance(player)
    local has7Coins = player:GetNumCoins() % 10 == 7
    local has7Keys = player:GetNumKeys() % 10 == 7
    local has7Bombs = player:GetNumBombs() % 10 == 7
    local has7Poops = player:GetPoopMana() % 10 == 7

    local chance = 0

    if has7Coins then chance = chance + 2 end
    if has7Keys then chance = chance + 2 end
    if has7Bombs then chance = chance + 2 end
    if has7Poops then chance = chance + 2 end

    chance = math.max(0, math.min(15, chance + player.Luck))

    local mult = player:HasTrinket(TrinketType.TRINKET_TEARDROP_CHARM) and 3 or 1

    return chance * mult
end


---@param enemy Entity
---@param player EntityPlayer
---@param rng RNG
function Helpers.TurnEnemyIntoGoldenMachine(enemy, player, rng)
    Game():ShakeScreen(7)
    SFXManager():Play(SoundEffect.SOUND_CASH_REGISTER)
    enemy:Remove()

    local machinesToUse = {}

    for _, luckySevenSlot in ipairs(RestoredCollection.LuckySevenSpecialSlots) do
        if luckySevenSlot:CanSpawn(player) then
            machinesToUse[#machinesToUse+1] = luckySevenSlot
        end
    end

    local chosenMachine = machinesToUse[rng:RandomInt(#machinesToUse)+1] or RestoredCollection.LuckySevenRegularSlot

    local luckySevenSlotEntity = Isaac.Spawn(EntityType.ENTITY_SLOT, RestoredCollection.Enums.Entities.LUCKY_SEVEN_SLOT.Variant, 0, enemy.Position, Vector.Zero, nil)
    local data = Helpers.GetData(luckySevenSlotEntity)
    data.LuckySevenSlotObject = chosenMachine
    data.SlotTimeout = data.LuckySevenSlotObject.TIMEOUT
    data.SlotPlayer = player
    data.LuckySevenSlotObject:__Init(luckySevenSlotEntity)
    luckySevenSlotEntity:AddEntityFlags(EntityFlag.FLAG_NO_QUERY)

	local slots = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "LuckySevenSlotsInRoom")
	

    local sparkles = Isaac.Spawn(EntityType.ENTITY_EFFECT, RestoredCollection.Enums.Entities.LUCKY_SEVEN_MACHINE_SPARKLES.Variant, 0, luckySevenSlotEntity.Position, Vector.Zero, luckySevenSlotEntity)
    sparkles.DepthOffset = 20
    data.MachineSparkles = sparkles

    local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, luckySevenSlotEntity.Position, Vector.Zero, luckySevenSlotEntity)

    luckySevenSlotEntity:SetColor(Color(1, 1, 1, 1, 1, 1, 117 / 255), 20, 1, true, false)
    poof.Color = Color(1, 1, 1, 1, 1, 1, 117 / 255)
end


---@param v1 Vector
---@param v2 Vector
---@return number
local function ScalarProduct(v1, v2)
    return v1.X * v2.X + v1.Y * v2.Y
end


---@param laser EntityLaser
---@param entity Entity
function Helpers.DoesLaserHitEntity(laser, entity)
    local targetSamples = {
        entity.Position,
        entity.Position + Vector(entity.Size * entity.SizeMulti.X, 0),
        entity.Position + Vector(-entity.Size * entity.SizeMulti.X, 0),
        entity.Position + Vector(0, entity.Size * entity.SizeMulti.Y),
        entity.Position + Vector(0, -entity.Size * entity.SizeMulti.Y),
    }
    ---@type VectorList
    ---@diagnostic disable-next-line: assign-type-mismatch
    local samplePoints = laser:GetSamples()
    local laserSize = laser.Size

    --From https://math.stackexchange.com/questions/190111/how-to-check-if-a-point-is-inside-a-rectangle
    for i = 0, samplePoints.Size-2, 1 do
        local point1 = samplePoints:Get(i)
        local point2 = samplePoints:Get(i+1)

        local side = (point1 - point2):Rotated(90):Resized(laserSize)

        local cornerA = point1 + side
        local cornerB = point2 + side
        local cornerD = point1 - side

        for _, targetPos in ipairs(targetSamples) do
            local AM = targetPos - cornerA
            local AB = cornerB - cornerA
            local AD = cornerD - cornerA
    
            local AMpAB = ScalarProduct(AM, AB)
            local ABpAB = ScalarProduct(AB, AB)
            local AMpAD = ScalarProduct(AM, AD)
            local ADpAD = ScalarProduct(AD, AD)
    
            if 0 < AMpAB and AMpAB < ABpAB and 0 < AMpAD and AMpAD < ADpAD then
                return true
            end
        end
    end
end

-----------------------------------
--Helper Functions (thanks piber)--
-----------------------------------

---@param ignoreCoopBabies? boolean 
---@return EntityPlayer[]
function Helpers.GetPlayers(ignoreCoopBabies)
	local players
	if REPENTOGON then
		players = PlayerManager.GetPlayers()
	else
		players = {}
		for _,player in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER)) do
			table.insert(players, player:ToPlayer())
		end
	end
	
	return Helpers.Filter(players, function(_, player)
		return player.Variant == 0 or ignoreCoopBabies == false
	end)
end

local function IsBaby(variant)
	return variant == FamiliarVariant.INCUBUS or variant == FamiliarVariant.TWISTED_BABY
	or variant == FamiliarVariant.BLOOD_BABY or variant == FamiliarVariant.CAINS_OTHER_EYE
	or variant == FamiliarVariant.UMBILICAL_BABY or variant == FamiliarVariant.SPRINKLER
end

function Helpers.GetPlayerFromTear(tear)
	for i=1, 3 do
		local check = nil
		if i == 1 then
			check = tear.Parent
		elseif i == 2 then
			check = tear.SpawnerEntity
		end
		if check then
			if check.Type == EntityType.ENTITY_PLAYER then
				return Helpers.GetPtrHashEntity(check):ToPlayer(), false
			elseif check.Type == EntityType.ENTITY_FAMILIAR and IsBaby(check.Variant)
			then
				local data = Helpers.GetData(tear)
				data.IsIncubusTear = true
				return check:ToFamiliar().Player:ToPlayer(), true
			end
		end
	end
	return nil
end

function Helpers.GetPtrHashEntity(entity)
	if entity then
		if entity.Entity then
			entity = entity.Entity
		end
		for _, matchEntity in pairs(Isaac.FindByType(entity.Type, entity.Variant, entity.SubType, false, false)) do
			if GetPtrHash(entity) == GetPtrHash(matchEntity) then
				return matchEntity
			end
		end
	end
	return nil
end


---@param entity Entity
---@return table | nil?
function Helpers.GetData(entity)
	if entity and entity.GetData then
		local data = entity:GetData()
		if not data.RestoredCollection then
			data.RestoredCollection = {}
		end
		return data.RestoredCollection
	end
	return nil
end

function Helpers.Contains(list, x)
	for _, v in pairs(list) do
		if v == x then return true end
	end
	return false
end

--ripairs stuff from revel
function ripairs_it(t,i)
	i=i-1
	local v=t[i]
	if v==nil then return v end
	return i,v
end
function ripairs(t)
	return ripairs_it, t, #t+1
end

--- Executes a function for each key-value pair of a table
function Helpers.ForEach(toIterate, funct)
	for index, value in pairs(toIterate) do
		funct(index, value)
	end
end

--filters a table given a predicate
function Helpers.Filter(toFilter, predicate)
	local filtered = {}

	for index, value in pairs(toFilter) do
		if predicate(index, value) then
			filtered[#filtered+1] = value
		end
	end

	return filtered
end

--returns a list of all players that have a certain item
function Helpers.GetPlayersByCollectible(collectibleId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:HasCollectible(collectibleId)
	end)
end

--returns a list of all players that have a certain item effect (useful for actives)
function Helpers.GetPlayersWithCollectibleEffect(collectibleId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:GetEffects():HasCollectibleEffect(collectibleId)
	end)
end

--returns a list of all players that have a certain item effect (useful for actives)
function Helpers.GetPlayersByNullEffect(nullItemId)
	local players = Helpers.GetPlayers()

	return Helpers.Filter(players, function(_, player)
		return player:GetEffects():HasNullEffect(nullItemId)
	end)
end

--returns a list of all players of certain type
function Helpers.GetPlayersByType(playerType)
	local players = Helpers.GetPlayers()
	if not playerType or type(playerType) ~= "number" or playerType < 0 then return players end

	return Helpers.Filter(players, function(_, player)
		return player:GetPlayerType() == playerType
	end)
end

---@param x number
---@return number
function Helpers.EaseOutBack(x)
    local c1 = 1.70158
	local c3 = c1 + 1

	return 1 + c3 * (x - 1)^3 + c1 * (x - 1)^2
end

---@param num number
---@param dp integer
---@return number
function Helpers.Round(num, dp)
    local mult = 10^(dp or 0)
    return math.floor(num * mult + 0.5)/mult
end


---By catinsurance
---@param maxFireDelay number
---@return number
function Helpers.ToTearsPerSecond(maxFireDelay)
    return 30 / (maxFireDelay + 1)
end


---By catinsurance
---@param tearsPerSecond number
---@return number
function Helpers.ToMaxFireDelay(tearsPerSecond)
    return (30 / tearsPerSecond) - 1
end

--#region bless Fiend Folio (you read that right)
local function runUpdates(tab) --This is from Fiend Folio
    for i = #tab, 1, -1 do
        local f = tab[i]
        f.Delay = f.Delay - 1
        if f.Delay <= 0 then
            f.Func()
            table.remove(tab, i)
        end
    end
end

local delayedFuncs = {}
function Helpers.scheduleForUpdate(foo, delay, callback)
	if REPENTOGON then
		Isaac.CreateTimer(foo, delay, 1, false)
	else
		callback = callback or ModCallbacks.MC_POST_UPDATE
		if not delayedFuncs[callback] then
			delayedFuncs[callback] = {}
			RestoredCollection:AddCallback(callback, function()
				runUpdates(delayedFuncs[callback])
			end)
			local function Reset()
				delayedFuncs[callback] = {}
			end
			RestoredCollection:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Reset)
			RestoredCollection:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Reset)
		end
		table.insert(delayedFuncs[callback], { Func = foo, Delay = delay })
	end
end
--#endregion

---@param item CollectibleType | integer
---@return boolean
function Helpers.IsItemDisabled(item)
	for _, disabledItem in ipairs(TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "DisabledItems")) do
        if item == RestoredCollection.Enums.CollectibleType[disabledItem] then
            return true
        end
    end
	return false
end

---@param collectible CollectibleType | integer
---@return boolean
function Helpers.DoesAnyPlayerHasItem(collectible)
	return REPENTOGON and PlayerManager.AnyoneHasCollectible(collectible) or #Helpers.Filter(Helpers.GetPlayers(), function(_, player) return player:HasCollectible(collectible) end) > 0
end

RestoredCollection.Helpers = Helpers

return Helpers