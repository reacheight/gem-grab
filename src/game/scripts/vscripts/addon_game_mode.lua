-- Generated from template

if GemGrab == nil then
  GemGrab = class({})
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
  GameRules._GemGrab = GemGrab()
  GameRules._GemGrab:Init()
end


function GemGrab:Init()
  GameRules:SetPreGameTime(0)
  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GemGrab, 'OnGameStateChanged'), nil)
end

function GemGrab:OnGameStateChanged()
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameRules:GetGameModeEntity():SetThink(SpawnGem, self, "GemSpawnThink", 7)
  end
end

function SpawnGem()
  print("Spawn Gem!")

  local gem = CreateItem("item_gem", nil, nil)
  local gem_spawner_position = Entities:FindByName(nil, "gem_spawner"):GetAbsOrigin()
  local spawn_position = RandomVector(RandomFloat(100, 300)) + gem_spawner_position
  CreateItemOnPositionSync(spawn_position, gem)
  return 7
end