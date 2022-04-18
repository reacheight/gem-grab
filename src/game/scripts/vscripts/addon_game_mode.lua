-- Generated from template

if CAddonTemplateGameMode == nil then
	CAddonTemplateGameMode = class({})
end

function Precache( context )
	--[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

-- Create the game mode when we activate
function Activate()
	GameRules.AddonTemplate = CAddonTemplateGameMode()
	GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
	print( "Template addon is loaded." )
	GameRules:SetPreGameTime(0)
	GameRules:GetGameModeEntity():SetThink( "SpawnGem", self, "OnGameInProgressThink", 1 )
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:SpawnGem()
	if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
		local gem_spawner = Entities:FindByName(nil, "gem_spawner")
		gem_spawner:SetHullRadius(0)
		
		GameRules:GetGameModeEntity():SetThink(SpawnGem, self, "GemSpawnThink", 7)
		return nil
	end

	return 1
end

function SpawnGem()
	print("Spawn Gem!")

	local gem = CreateItem("item_gem", nil, nil)
	local gem_spawner_position = Entities:FindByName(nil, "gem_spawner"):GetAbsOrigin()
	local spawn_position = RandomVector(RandomFloat(100, 300)) + gem_spawner_position
	CreateItemOnPositionSync(spawn_position, gem)
	return 7
end