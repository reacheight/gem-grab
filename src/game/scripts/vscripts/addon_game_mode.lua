-- Generated from template

RadiantTeam = 2
DireTeam = 3
WIN_GEM_COUNT = 10
WIN_COUNTDOWN = 15

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
  GemGrab.Score = {}
  GemGrab.Score[RadiantTeam] = 0
  GemGrab.Score[DireTeam] = 0

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
    GameRules:GetGameModeEntity():SetThink(CheckWin, self, "CheckWinThink", 1)
  end
end

function GemGrab:OnItemPickedUp(event)
  if event.itemname == "item_gem" then
    local item = EntIndexToHScript(event.ItemEntityIndex)
    local player = PlayerResource:GetPlayer(event.PlayerID)
    local team = player:GetTeam()
    local charges = item:GetCurrentCharges()

    GemGrab.Score[team] = GemGrab.Score[team] + charges
    CustomGameEventManager:Send_ServerToAllClients("score_updated", { teamNum = team, newScore = GemGrab.Score[team] })
  end
end

function GemGrab:OnItemDropped(event)
  if event.removed then
    local item = EntIndexToHScript(event.item_entindex)
    if item:GetName() == "item_gem" then
      local hero = EntIndexToHScript(event.hero_entindex)
      local team = hero:GetTeam()
      local charges = item:GetCurrentCharges()

      GemGrab.Score[team] = GemGrab.Score[team] - charges
      CustomGameEventManager:Send_ServerToAllClients("score_updated", { teamNum = team, newScore = GemGrab.Score[team] })
    end
  end
end

function GemGrab:CalculateWinner()
  if GemGrab.Score[RadiantTeam] >= WIN_GEM_COUNT or GemGrab.Score[DireTeam] >= WIN_GEM_COUNT then
    if GemGrab.Score[RadiantTeam] > GemGrab.Score[DireTeam] then
      return RadiantTeam
    elseif GemGrab.Score[DireTeam] > GemGrab.Score[RadiantTeam] then
      return DireTeam
    else
      return nil
    end
  end
end

function CheckWin()
  local newWinner = GemGrab:CalculateWinner()
  
  if newWinner == nil then
    if GemGrab.CurrentWinner ~= nil then
      CustomGameEventManager:Send_ServerToAllClients("countdown_updated", { countdown = "" })
    end

    GemGrab.CurrentWinner = nil
    return 1
  end

  if GemGrab.CurrentWinner ~= newWinner then
    GemGrab.CurrentWinner = newWinner
    GemGrab.WinTime = GameRules:GetGameTime() + WIN_COUNTDOWN
    CustomGameEventManager:Send_ServerToAllClients("countdown_updated", { countdown = 15 })
    return 1
  end

  local countdown = math.floor(GemGrab.WinTime - GameRules:GetGameTime() + 0.5)
  CustomGameEventManager:Send_ServerToAllClients("countdown_updated", { countdown = countdown })
  if GameRules:GetGameTime() >= GemGrab.WinTime then
    GameRules:SetGameWinner(newWinner)
    return nil
  end

  return 1
end

function SpawnGem()
  local gem = CreateItem("item_gem", nil, nil)
  gem:SetActivated(false)
  local gem_spawner_position = Entities:FindByName(nil, "gem_spawner"):GetAbsOrigin()
  local spawn_position = RandomVector(RandomFloat(100, 300)) + gem_spawner_position
  CreateItemOnPositionSync(spawn_position, gem)
  return 7
end