import { BaseItem } from "./lib/dota_ts_adapter"
import { reloadable } from "./lib/tstl-utils"
import { modifier_extra_mana } from "./modifier_extra_mana"
import { modifier_mana_on_attack } from "./modifier_mana_on_attack"
import { modifier_mana_on_attacked } from "./modifier_mana_on_attacked"

declare global {
    interface CDOTAGameRules {
        GemGrab: GemGrab
    }
}

@reloadable
export class GemGrab {
    private GEM_SPAWN_PERIOD = 7
    private WIN_GEM_COUNT: number = 10
    private WIN_COUNTDOWN: number = 15
    private HERO_SELECTION_TIME = 20
    private GEM_ITEM_NAME = "item_gem"


    private Score: { [team: number]: number } = { [DotaTeam.GOODGUYS]: 0, [DotaTeam.BADGUYS]: 0 }
    private CurrentWinner: DotaTeam | undefined = undefined
    private WinTime: number = 0

    public static Precache(this: void, context: CScriptPrecacheContext) {

    }

    public static Activate(this: void) {
        GameRules.GemGrab = new GemGrab()
    }

    constructor() {
        this.configure()

        ListenToGameEvent("game_rules_state_change", () => this.OnStateChange(), undefined)
        ListenToGameEvent("dota_item_picked_up", event => this.OnItemPickedUp(event), undefined)
        ListenToGameEvent("dota_hero_inventory_item_change", event => this.OnItemDropped(event), undefined)
        ListenToGameEvent("npc_spawned", event => this.OnNPCSpawned(event), undefined)
    }

    private configure(): void {
        GameRules.SetCustomGameTeamMaxPlayers(DotaTeam.GOODGUYS, 3)
        GameRules.SetCustomGameTeamMaxPlayers(DotaTeam.BADGUYS, 3)
        GameRules.SetPreGameTime(0)
        GameRules.SetStrategyTime(0)
        GameRules.SetShowcaseTime(0)
        GameRules.SetHeroSelectionTime(this.HERO_SELECTION_TIME)
        GameRules.SetTimeOfDay(0.251)
        GameRules.SetSameHeroSelectionEnabled(true)

        let gameMode = GameRules.GetGameModeEntity()
        gameMode.SetDaynightCycleDisabled(true)
        gameMode.SetAnnouncerDisabled(true)
        gameMode.SetKillingSpreeAnnouncerDisabled(true)
    }

    public OnStateChange(): void {
        const state = GameRules.State_Get()

        if (IsInToolsMode() && state == GameState.CUSTOM_GAME_SETUP) {
            Tutorial.AddBot("npc_dota_hero_lina", "", "", false)
        }

        if (state === GameState.GAME_IN_PROGRESS) {
            Timers.CreateTimer(this.GEM_SPAWN_PERIOD, () => this.SpawnGem())
            Timers.CreateTimer(() => this.CheckWin())
        }
    }

    public OnNPCSpawned(event: NpcSpawnedEvent) {
        let hero = EntIndexToHScript(event.entindex) as CDOTA_BaseNPC_Hero
        if (!hero.IsHero()) return

        hero.AddNewModifier(hero, undefined, modifier_extra_mana.name, undefined)
        hero.AddNewModifier(hero, undefined, modifier_mana_on_attack.name, undefined)
        if (!hero.IsRangedAttacker()) {
            hero.AddNewModifier(hero, undefined, modifier_mana_on_attacked.name, undefined)
        }
        
        let baseInt = hero.GetBaseIntellect()
        Timers.CreateTimer(0.01, () => {
            hero.SetBaseIntellect(0)
            if (hero.GetPrimaryAttribute() == Attributes.INTELLECT) {
                hero.SetBaseDamageMin(hero.GetBaseDamageMin() + baseInt)
                hero.SetBaseDamageMax(hero.GetBaseDamageMax() + baseInt)
            }

            hero.SetMana(0)
            hero.SetMaxMana(300)
        })
    }

    public OnItemPickedUp(event: DotaItemPickedUpEvent): void {
        if (event.itemname == this.GEM_ITEM_NAME) {
            let item = EntIndexToHScript(event.ItemEntityIndex) as BaseItem
            let player = PlayerResource.GetPlayer(event.PlayerID)!
            let team = player.GetTeam();
            let charges = item.GetCurrentCharges()

            this.Score[team] = this.Score[team] + charges
            CustomGameEventManager.Send_ServerToAllClients("score_updated", { team: team, newScore: this.Score[team] })
        }
    }

    public OnItemDropped(event: DotaHeroInventoryItemChangeEvent): void {
        if (event.removed) {
            let item = EntIndexToHScript(event.item_entindex)! as BaseItem
            if (item.GetName() == this.GEM_ITEM_NAME) {
                let hero = EntIndexToHScript(event.hero_entindex)!
                let team = hero.GetTeam()
                let charges = item.GetCurrentCharges()

                this.Score[team] = this.Score[team] - charges
                CustomGameEventManager.Send_ServerToAllClients("score_updated", { team: team, newScore: this.Score[team] })
            }
        }
    }

    private SpawnGem(): number {
        let gem = CreateItem(this.GEM_ITEM_NAME, undefined, undefined)
        gem?.SetActivated(false)
        
        let spawnerPosition = Entities.FindByName(undefined, "gem_spawner")!.GetAbsOrigin()!
        let spawnPosition = RandomVector(RandomFloat(100, 300)).__add(spawnerPosition)

        CreateItemOnPositionSync(spawnPosition, gem)

        return this.GEM_SPAWN_PERIOD
    }

    private CalculateWinner(): DotaTeam | undefined {
        if (this.Score[DotaTeam.GOODGUYS] >= this.WIN_GEM_COUNT || this.Score[DotaTeam.BADGUYS] >= this.WIN_GEM_COUNT) {
            if (this.Score[DotaTeam.GOODGUYS] > this.Score[DotaTeam.BADGUYS])
                return DotaTeam.GOODGUYS

            if (this.Score[DotaTeam.BADGUYS] > this.Score[DotaTeam.GOODGUYS])
                return DotaTeam.BADGUYS
        }
    }

    private CheckWin(): number | undefined {
        let newWinner = this.CalculateWinner()

        if (newWinner === undefined) {
            if (this.CurrentWinner !== undefined)
                CustomGameEventManager.Send_ServerToAllClients("countdown_updated", { countdown: "" })
            
            this.CurrentWinner = undefined
            return 1
        }

        if (this.CurrentWinner !== newWinner) {
            this.CurrentWinner = newWinner
            this.WinTime = GameRules.GetGameTime() + this.WIN_COUNTDOWN
        }

        let countdown = math.floor(this.WinTime - GameRules.GetGameTime() + 0.5)
        CustomGameEventManager.Send_ServerToAllClients("countdown_updated", { countdown: countdown.toString() })

        if (GameRules.GetGameTime() >= this.WinTime) {
            GameRules.SetGameWinner(newWinner)
            return
        }

        return 1
    }

    public Reload() {
        print("Script reloaded!")
    }
}
