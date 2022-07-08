import { BaseModifier, registerModifier } from "./lib/dota_ts_adapter"

@registerModifier()
export class modifier_mana_on_attack extends BaseModifier {
  IsHidden() {
    return true;
  }

  DeclareFunctions() {
    return [ModifierFunction.ON_ATTACK_LANDED]
  }

  OnAttackLanded(event: ModifierAttackEvent) {
    if (!IsServer()) return
    if (this.GetParent() != event.attacker) return

    let currentMana = event.attacker.GetMana()
    let mana = event.damage
    event.attacker.SetMana(currentMana + mana)
  }
}