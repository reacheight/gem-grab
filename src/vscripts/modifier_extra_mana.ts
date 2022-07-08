import { BaseModifier, registerModifier } from "./lib/dota_ts_adapter";

@registerModifier()
export class modifier_extra_mana extends BaseModifier {
  IsHidden() {
    return false
  }

  DeclareFunctions() {
    return [ModifierFunction.EXTRA_MANA_BONUS]
  }

  GetModifierExtraManaBonus() {
    return 225
  }
}