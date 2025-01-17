// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "cryptocert/ethereum-xcert-contracts/src/contracts/ixcert-burnable.sol";
import "cryptocert/ethereum-utils-contracts/src/contracts/permission/abilitable.sol";

/**
 * @title XcertBurnProxy - burns a token on behalf of contracts that have been approved via
 * decentralized governance.
 */
contract XcertBurnProxy is
  Abilitable
{

  /**
   * @dev List of abilities:
   * 16 - Ability to execute create.
   */
  uint8 constant ABILITY_TO_EXECUTE = 16;

  /**
   * @dev Destroys an existing Xcert.
   * @param _xcert Address of the Xcert contract on which the token destroy will be performed.
   * @param _id The Xcert we will destroy.
   */
  function destroy(
    address _xcert,
    uint256 _id
  )
    external
    hasAbilities(ABILITY_TO_EXECUTE)
  {
    XcertBurnable(_xcert).destroy(_id);
  }

}
