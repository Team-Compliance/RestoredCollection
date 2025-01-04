local localversion = 1.3

local function load()
    CustomShockwaveAPI = RegisterMod("Custom Shockwave", 1)
    CustomShockwaveAPI.Version = localversion
    CustomShockwaveAPI.Loaded = false
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
    local function scheduleForUpdate(foo, delay, callback)
        if REPENTOGON then
            Isaac.CreateTimer(foo, delay, 1, false)
        else
            callback = callback or ModCallbacks.MC_POST_UPDATE
            if not delayedFuncs[callback] then
                delayedFuncs[callback] = {}
                local function Reset()
                    delayedFuncs[callback] = {}
                end
                CustomShockwaveAPI:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, Reset)
                CustomShockwaveAPI:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Reset)
                CustomShockwaveAPI:AddCallback(callback, function()
                    runUpdates(delayedFuncs[callback])
                end)
            end

            table.insert(delayedFuncs[callback], { Func = foo, Delay = delay })
        end
    end
    --#endregion

    ---@param position Vector
    ---@param spawner Entity
    ---@param step number?
    ---@param angle integer?
    ---@param delay integer?
    ---@param limit integer?
    ---@param damage number?
    ---@param damageIncrement number?
    ---@param tearFlags TearFlags | number?
    ---@param minradius number?
    ---@param maxradius number?
    ---@param rng RNG?
    function CustomShockwaveAPI:SpawnCustomCrackwave(position, spawner, step, angle, delay, limit, damage, damageIncrement, tearFlags, minradius, maxradius, rng)
        limit = limit or -1
        if limit == 0 then return end
        angle = angle or 0
        delay = delay or 0
        step = step or 30
        tearFlags = tearFlags or 0
        damage = damage or 10
        damageIncrement = damageIncrement or 0
        minradius = minradius or 0
        maxradius = maxradius or 0
        limit = limit > 0 and (limit - 1) or limit
        rng = rng or spawner:GetDropRNG()
        scheduleForUpdate(function()
            local room = Game():GetRoom()
            local radiusChange = rng:RandomInt(maxradius - minradius) + minradius
            while radiusChange < 0 do
                radiusChange = radiusChange + 360 
            end
            local nextPos = position + Vector.FromAngle(angle + radiusChange):Resized(step)
            local gridCol = room:GetGridCollisionAtPos(nextPos)
            local grid = room:GetGridEntityFromPos(nextPos)
            local player = spawner:ToPlayer() or spawner.Parent:ToPlayer()
            local door
            if grid then
                if grid:ToDoor() then
                    door = grid:ToDoor()
                    door:Destroy()
                    if (door:GetVariant() == DoorVariant.DOOR_LOCKED or door:GetVariant() == DoorVariant.DOOR_LOCKED_DOUBLE) then
                        if player then
                            if player:HasTrinket(TrinketType.TRINKET_BROKEN_PADLOCK) then
                                door:Open()
                            end
                        end
                    end
                end
            end
            if gridCol ~= GridCollisionClass.COLLISION_WALL and not door and (not grid or grid:GetType() ~= GridEntityType.GRID_ROCKB) then
                local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_EXPLOSION, 0, nextPos, Vector.Zero, spawner):ToEffect()
                effect.Parent = player
                effect:GetData().CustomRockExplosion = true
                effect:GetData().CustomRockExplosionTearFlags = tearFlags
                effect:GetData().CustomRockExplosionDamage = damage
                for i = 0, 359, 10 do
                    local pit = room:GetGridEntityFromPos(nextPos + Vector.FromAngle(i):Resized(5))
                    if pit and pit:ToPit() then
                        pit:ToPit():MakeBridge(nil)
                    end
                end
                CustomShockwaveAPI:SpawnCustomCrackwave(nextPos, spawner, step, angle, delay, limit, damage + damageIncrement, damageIncrement, tearFlags, minradius, maxradius, rng)
            end
        end, delay)
    end

    ---@param effect EntityEffect
    function CustomShockwaveAPI:UpdateCustomRockExplosion(effect)
        local data = effect:GetData()
        if data.CustomRockExplosion then
            local sprite = effect:GetSprite()
            if effect.FrameCount == 2 then
                SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.4, 0)
                Game():BombDamage(effect.Position, data.CustomRockExplosionDamage, 20 * sprite.Scale.X, false, effect.SpawnerEntity, data.CustomRockExplosionTearFlags, DamageFlag.DAMAGE_CRUSH, false)
                for _,ent in ipairs(Isaac.FindInRadius(effect.Position, 20 * sprite.Scale.X, EntityPartition.ENEMY)) do
                    if ent.Type == EntityType.ENTITY_FIREPLACE and ent.Variant ~= 4 then
                        ent:Die()
                    end
                end
            end
        end
    end
    CustomShockwaveAPI:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, CustomShockwaveAPI.UpdateCustomRockExplosion, EffectVariant.ROCK_EXPLOSION)

    function CustomShockwaveAPI:ModReset()
        CustomShockwaveAPI.Loaded = false
    end
    CustomShockwaveAPI:AddCallback(ModCallbacks.MC_PRE_MOD_UNLOAD, CustomShockwaveAPI.ModReset)

    print("[".. CustomShockwaveAPI.Name .."]", "is loaded. Version "..CustomShockwaveAPI.Version)
    CustomShockwaveAPI.Loaded = true
end

if CustomShockwaveAPI then
	if CustomShockwaveAPI.Version < localversion or not CustomShockwaveAPI.Loaded then
		if not CustomShockwaveAPI.Loaded then
			print("Reloading [".. CustomShockwaveAPI.Name .."]")
		else
		    print("[".. CustomShockwaveAPI.Name .."]", "found old script V" .. CustomShockwaveAPI.Version .. ", found new script V" .. localversion .. ". replacing...")
        end
		CustomShockwaveAPI = nil
		load()
	end
elseif not CustomShockwaveAPI then
	load()
end
