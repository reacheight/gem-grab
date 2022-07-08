import { BaseModifier, registerModifier } from "./lib/dota_ts_adapter";

@registerModifier()
export class modifier_mana_on_attacked extends BaseModifier {
  IsHidden() {
    return true;
  }

  DeclareFunctions() {
    return [ModifierFunction.ON_ATTACK_LANDED]
  }

  OnAttackLanded(event: ModifierAttackEvent) {
    if (!IsServer()) return
    if (this.GetParent() != event.target) return

    let currentMana = event.target.GetMana()
    let mana = event.damage / 3
    event.target.SetMana(currentMana + mana)
  }
}