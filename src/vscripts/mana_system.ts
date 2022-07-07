import { BaseAbility, registerAbility } from "./lib/dota_ts_adapter";
import "./modifier_mana_system"

@registerAbility()
export class mana_system extends BaseAbility {
  GetIntrinsicModifierName(): string {
    return "modifier_mana_system"
  }
}