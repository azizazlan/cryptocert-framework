// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "../nf-token.sol";
import "cryptocert/ethereum-utils-contracts/src/contracts/permission/claimable.sol";

/**
 * @dev This is an example contract implementation of NFToken.
 */
contract NFTokenMock is
  NFToken,
  Claimable
{

  /**
   * @dev Creates a new NFT.
   * @param _to The address that will own the created NFT.
   * @param _tokenId of the NFT to be created by the msg.sender.
   */
  function create(
    address _to,
    uint256 _tokenId
  )
    external
    onlyOwner
  {
    super._create(_to, _tokenId);
  }
  
}
