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
  GemGrab.RadiantScore = 0
  GemGrab.DireScore = 0

  GameRules:SetCustomGameTeamMaxPlayers(2, 3)
  GameRules:SetCustomGameTeamMaxPlayers(3, 3)
  GameRules:SetPreGameTime(0)
  GameRules:SetStrategyTime(0)
  GameRules:SetShowcaseTime(0)
  GameRules:SetHeroSelectionTime(10)
  GameRules:SetTimeOfDay(0.251)

  local GameMode = GameRules:GetGameModeEntity()
  GameMode:SetDaynightCycleDisabled(true)
  GameMode:SetAnnouncerDisabled(true)
  GameMode:SetKillingSpreeAnnouncerDisabled(true)
  
  GameRules:SetSameHeroSelectionEnabled(true)

  ListenToGameEvent('game_rules_state_change', Dynamic_Wrap(GemGrab, 'OnGameStateChanged'), nil)
  ListenToGameEvent('dota_item_picked_up', Dynamic_Wrap(GemGrab, 'OnItemPickedUp'), self)
  ListenToGameEvent('dota_hero_inventory_item_change', Dynamic_Wrap(GemGrab, 'OnItemDropped'), self)
end

function GemGrab:OnGameStateChanged()
  if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
    GameRules:GetGameModeEntity():SetThink(SpawnGem, self, "GemSpawnThink", 10)
  end
end

function GemGrab:OnItemPickedUp(event)
  local item = EntIndexToHScript(event.ItemEntityIndex)
  local hero = item:GetParent()
  local team = hero:GetTeam()

  if event.itemname == "item_gem" then
    if (team == 2) then
      GemGrab.RadiantScore = GemGrab.RadiantScore + 1

      if GemGrab.RadiantScore == 10 then
        GameRules:SetGameWinner(2)
      end
    end

    if (team == 3) then
      GemGrab.DireScore = GemGrab.DireScore + 1

      if GemGrab.DireScore == 10 then
        GameRules:SetGameWinner(3)
      end
    end
  end
end

function GemGrab:OnItemDropped(event)
  if event.removed then
    local item = EntIndexToHScript(event.item_entindex)
    if item:GetName() == "item_gem" then
      local hero = EntIndexToHScript(event.hero_entindex)
      local team = hero:GetTeam()

      if (team == 2) then
        GemGrab.RadiantScore = GemGrab.RadiantScore - 1
      end

      if (team == 3) then
        GemGrab.DireScore = GemGrab.DireScore - 1
      end
    end
  end
end

function SpawnGem()
  local gem = CreateItem("item_gem", nil, nil)
  local gem_spawner_position = Entities:FindByName(nil, "gem_spawner"):GetAbsOrigin()
  local spawn_position = RandomVector(RandomFloat(100, 300)) + gem_spawner_position
  CreateItemOnPositionSync(spawn_position, gem)
  return 7
end