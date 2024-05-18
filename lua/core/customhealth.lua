local sfx = SFXManager()
local Helpers = require("lua.helpers.Helpers")

if CustomHealthAPI and CustomHealthAPI.Library and CustomHealthAPI.Library.UnregisterCallbacks then
    CustomHealthAPI.Library.UnregisterCallbacks("RestoredCollection")
end

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_IMMORTAL",
    {
        AnimationFilename = "gfx/ui/ui_remix_hearts.anm2",
        AnimationName = {"ImmortalHeartHalf", "ImmortalHeartFull"},
        SortOrder = 150,
        AddPriority = 175,
        HealFlashRO = 240/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
        MaxHP = 2,
        PrioritizeHealing = true,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = RestoredCollection.Enums.Pickups.Hearts.HEART_IMMORTAL}
        },
        SumptoriumSubType = 20,  -- immortal heart clot
        SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumCollectSoundSettings = {
            ID = SoundEffect.SOUND_MEAT_IMPACTS,
            Volume = 1.0,
            FrameDelay = 0,
            Loop = false,
            Pitch = 1.0,
            Pan = 0
        }
    }
)

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_SUN",
    {
        AnimationFilename = "gfx/ui/ui_remix_hearts.anm2",
        AnimationName = {"SunHeartFull"},
        SortOrder = 100,
        AddPriority = 125,
        HealFlashRO = 240/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
        MaxHP = 1,
        PrioritizeHealing = false,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = RestoredCollection.Enums.Pickups.Hearts.HEART_SUN}
        },
        SumptoriumSubType = 30,  -- sun heart clot
        SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumCollectSoundSettings = {
            ID = SoundEffect.SOUND_MEAT_IMPACTS,
            Volume = 1.0,
            FrameDelay = 0,
            Loop = false,
            Pitch = 1.0,
            Pan = 0
        }
    }
)

CustomHealthAPI.Library.RegisterSoulHealth(
    "HEART_ILLUSION",
    {
        AnimationFilename = "gfx/ui/ui_remix_hearts.anm2",
        AnimationName = {"IllusionHeartFull", "IllusionHeartHalf"},
        SortOrder = 100,
        AddPriority = 125,
        HealFlashRO = 240/255, 
        HealFlashGO = 240/255,
        HealFlashBO = 240/255,
        MaxHP = 2,
        PrioritizeHealing = false,
        PickupEntities = {
            {ID = EntityType.ENTITY_PICKUP, Var = PickupVariant.PICKUP_HEART, Sub = RestoredCollection.Enums.Pickups.Hearts.HEART_ILLUSION}
        },
        SumptoriumSubType = 31,  -- illusion heart clot
        SumptoriumSplatColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumTrailColor = Color(1.00, 1.00, 1.00, 1.00, 0.00, 0.00, 0.00),
        SumptoriumCollectSoundSettings = {
            ID = SoundEffect.SOUND_MEAT_IMPACTS,
            Volume = 1.0,
            FrameDelay = 0,
            Loop = false,
            Pitch = 1.0,
            Pan = 0
        }
    }
)

local function SpriteChange(_, entity)
	if entity.SubType == RestoredCollection.Enums.Pickups.Hearts.HEART_SUN
	or entity.SubType == RestoredCollection.Enums.Pickups.Hearts.HEART_ILLUSION
	or entity.SubType == RestoredCollection.Enums.Pickups.Hearts.HEART_IMMORTAL then
		local sprite = entity:GetSprite()
		local spritename = "gfx/items/pick ups/pickup_001_remix_heart"
		local style = TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "HeartStyleRender")
		if style == 2 then
			spritename = spritename.."_aladar"
		end
		if style == 3 then
			spritename = spritename.."_peas"
		end
		if style == 5 then
			spritename = spritename.."_flashy"
		end
		if style == 6 then
			spritename = spritename.."_bettericons"
		end
		if style == 8 then
			spritename = spritename.."_duxi"
		end
		if style == 9 then
			spritename = spritename.."_sussy" 
		end
		spritename = spritename..".png"
		
		sprite:ReplaceSpritesheet(0,spritename)
		sprite:LoadGraphics()
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, SpriteChange, PickupVariant.PICKUP_HEART)

CustomHealthAPI.Library.AddCallback("RestoredCollection",CustomHealthAPI.Enums.Callbacks.ON_SAVE, 0, function (savedata, isPreGameExit)
	if isPreGameExit then
    	TSIL.SaveManager.SetPersistentVariable(RestoredCollection, "CustomHealthAPISave", savedata)
	end
end)

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.ON_LOAD, 0, function()
	return TSIL.SaveManager.GetPersistentVariable(RestoredCollection, "CustomHealthAPISave")
end)

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.POST_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, wasDepleted, wasLastDamaged)
	if key == "HEART_SUN" then
		if wasDepleted then
			sfx:Play(RestoredCollection.Enums.SFX.Hearts.SUN_BREAK, 1, 0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.IMPACT, 0, player.Position + Vector(0, 0), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR:Play("Yellow",true)
			shatterSPR.Offset = Vector(0, -15)
		end
	end
    if key == "HEART_IMMORTAL" then
		if wasDepleted then
			sfx:Play(RestoredCollection.Enums.SFX.Hearts.IMMORTAL_BREAK, 1, 0)
			local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
			shatterSPR.PlaybackSpeed = 2
		else
			player:GetData().ImmortalHeartDamage = true
		end
	end
end)

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.PRE_HEALTH_DAMAGED, 0, function(player, flags, key, hpDamaged, otherKey, otherHPDamaged, amountToRemove)
	if otherKey == "HEART_IMMORTAL" then
		return 1
	end
end)

CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.PRE_ADD_HEALTH, 0, function(player, key, hp)
	local d = Helpers.GetEntityData(player)
	if key == "HEART_ILLUSION" then
		if not d or d and not d.IsIllusion then
			return "HEART_SOUL", hp
		end
	end
end)


CustomHealthAPI.Library.AddCallback("RestoredCollection", CustomHealthAPI.Enums.Callbacks.POST_SUMPTORIUM_CLOT_INIT, 0, function(familiar, key)
	if key == "HEART_IMMORTAL" then
		local player = familiar.Player
		if player then
			if  ComplianceImmortal.GetImmortalHeartsNum(player) % 2 == 0 then
				sfx:Play(RestoredCollection.Enums.SFX.Hearts.IMMORTAL_BREAK, 1, 0)
				local shatterSPR = Isaac.Spawn(EntityType.ENTITY_EFFECT, 904, 0, player.Position + Vector(0, 1), Vector.Zero, nil):ToEffect():GetSprite()
				shatterSPR.PlaybackSpeed = 2
			end
			local clot
			for _, s_clot in ipairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR, FamiliarVariant.BLOOD_BABY, 20)) do
				s_clot = s_clot:ToFamiliar()
				if GetPtrHash(s_clot.Player) == GetPtrHash(player) and GetPtrHash(familiar) ~= GetPtrHash(s_clot) then
					clot = s_clot
					break
				end
			end
			if clot ~= nil and clot.InitSeed ~= familiar.InitSeed then
				local clotData = clot:GetData()
				clotData.TC_HP = clotData.TC_HP + 1
				local ImmortalEffect = Isaac.Spawn(EntityType.ENTITY_EFFECT, 903, 0, clot.Position + Vector(0, 1), Vector.Zero, nil):ToEffect()
				ImmortalEffect:GetSprite().Offset = Vector(0, -10)
				familiar:Remove()
			end
		end
	end
end)

local function StaticClotHP(_, clot)
	if clot.SubType == 20 or clot.SubType == 30 then
		local clotData = clot:GetData()
		if (clotData.TC_HP == nil) then
			clotData.TC_HP = clot.HitPoints
		else
			local damageTaken = clotData.TC_HP - clot.HitPoints
			if (damageTaken > 0.19 and damageTaken < 0.21) then
				clot.HitPoints = clot.HitPoints + damageTaken
			elseif (damageTaken > 1.19 and damageTaken < 1.21) then
				clot.HitPoints = clot.HitPoints - 1.0
			else
				clotData.TC_HP = clot.HitPoints
			end
		end
	end
end
RestoredCollection:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, StaticClotHP, FamiliarVariant.BLOOD_BABY)