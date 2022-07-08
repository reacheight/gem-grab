import { BaseAbility, registerAbility } from "./lib/dota_ts_adapter";
import "./modifier_mana_on_attack"
import { modifier_mana_on_attack } from "./modifier_mana_on_attack";

@registerAbility()
export class mana_on_attack extends BaseAbility {
  GetIntrinsicModifierName(): string {
    return modifier_mana_on_attack.name
  }
}