import { bigNumberify } from "@cryptocert/ethereum-utils";
import { AssetLedgerAbility } from "@cryptocert/scaffold";

/**
 * Converts array of abilities into its bitfield representation.
 * @param abilities Array of abilitites.
 */
export function getBitfieldFromAbilities(
  abilities: AssetLedgerAbility[]
): string {
  let bitAbilities = bigNumberify(0);
  abilities.forEach((ability) => {
    bitAbilities = bitAbilities.add(ability);
  });
  return bitAbilities.toHexString();
}
