// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./erc721.sol";
import "./erc721-metadata.sol";
import "./erc721-token-receiver.sol";
import "cryptocert/ethereum-utils-contracts/src/contracts/utils/supports-interface.sol";
import "cryptocert/ethereum-utils-contracts/src/contracts/utils/address-utils.sol";

/**
 * @dev Optional metadata implementation for ERC-721 non-fungible token standard.
 */
contract NFTokenMetadata is
  ERC721,
  ERC721Metadata,
  SupportsInterface
{
  using AddressUtils for address;

  /**
   * @dev Error constants.
   */
  string constant ZERO_ADDRESS = "004001";
  string constant NOT_VALID_NFT = "004002";
  string constant NOT_OWNER_OR_OPERATOR = "004003";
  string constant NOT_OWNER_APPROWED_OR_OPERATOR = "004004";
  string constant NOT_ABLE_TO_RECEIVE_NFT = "004005";
  string constant NFT_ALREADY_EXISTS = "004006";

  /**
   * @dev Magic value of a smart contract that can recieve NFT.
   * Equal to: bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")).
   */
  bytes4 constant MAGIC_ON_ERC721_RECEIVED = 0x150b7a02;

  /**
   * @dev A descriptive name for a collection of NFTs.
   */
  string internal nftName;

  /**
   * @dev An abbreviated name for NFTs.
   */
  string internal nftSymbol;

  /**
   * @dev URI prefix for NFT metadata. NFT URI is made from prefix + NFT id + postfix.
   */
  string public uriPrefix;

  /**
   * @dev URI postfix for NFT metadata. NFT URI is made from prefix + NFT ID + postfix.
   */
  string public uriPostfix;

  /**
   * @dev A mapping from NFT ID to the address that owns it.
   */
  mapping (uint256 => address) internal idToOwner;

  /**
   * @dev Mapping from NFT ID to approved address.
   */
  mapping (uint256 => address) internal idToApproval;

   /**
   * @dev Mapping from owner address to count of their tokens.
   */
  mapping (address => uint256) internal ownerToNFTokenCount;

  /**
   * @dev Mapping from owner address to mapping of operator addresses.
   */
  mapping (address => mapping (address => bool)) internal ownerToOperators;

  /**
   * @dev Contract constructor.
   * @notice When implementing this contract, don't forget to set nftName, nftSymbol, uriPrefix and
   * uriPostfix.
   */
  constructor()
  {
    supportedInterfaces[0x80ac58cd] = true; // ERC721
    supportedInterfaces[0x5b5e139f] = true; // ERC721Metadata
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice Throws unless `msg.sender` is the current owner, an authorized operator, or the
   * approved address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is
   * the zero address. Throws if `_tokenId` is not a valid NFT. When transfer is complete, this
   * function checks if `_to` is a smart contract (code size > 0). If so, it calls
   * `onERC721Received` on `_to` and throws if the return value is not
   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes calldata _data
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, _data);
  }

  /**
   * @dev Transfers the ownership of an NFT from one address to another address.
   * @notice This works identically to the other function with an extra data parameter, except this
   * function just sets data to "".
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    _safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
   * @dev Throws unless `msg.sender` is the current owner, an authorized operator, or the approved
   * address for this NFT. Throws if `_from` is not the current owner. Throws if `_to` is the zero
   * address. Throws if `_tokenId` is not a valid NFT.
   * @notice The caller is responsible to confirm that `_to` is capable of receiving NFTs or else
   * they may be permanently lost.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    external
    override
  {
    _transferFrom(_from, _to, _tokenId);
  }

  /**
   * @dev Set or reaffirm the approved address for an NFT.
   * @notice The zero address indicates there is no approved address. Throws unless `msg.sender` is
   * the current NFT owner, or an authorized operator of the current owner.
   * @param _approved Address to be approved for the given NFT ID.
   * @param _tokenId ID of the token to be approved.
   */
  function approve(
    address _approved,
    uint256 _tokenId
  )
    external
    override
  {
    // can operate
    address tokenOwner = idToOwner[_tokenId];
    require(
      tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
      NOT_OWNER_OR_OPERATOR
    );

    idToApproval[_tokenId] = _approved;
    emit Approval(tokenOwner, _approved, _tokenId);
  }

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   */
  function setApprovalForAll(
    address _operator,
    bool _approved
  )
    external
    override
  {
    ownerToOperators[msg.sender][_operator] = _approved;
    emit ApprovalForAll(msg.sender, _operator, _approved);
  }

  /**
   * @dev Returns the number of NFTs owned by `_owner`. NFTs assigned to the zero address are
   * considered invalid, and this function throws for queries about the zero address.
   * @param _owner Address for whom to query the balance.
   * @return Balance of _owner.
   */
  function balanceOf(
    address _owner
  )
    external
    override
    view
    returns (uint256)
  {
    require(_owner != address(0), ZERO_ADDRESS);
    return ownerToNFTokenCount[_owner];
  }

  /**
   * @dev Returns the address of the owner of the NFT. NFTs assigned to zero address are considered
   * invalid, and queries about them do throw.
   * @param _tokenId The identifier for an NFT.
   * @return _owner Address of _tokenId owner.
   */
  function ownerOf(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address _owner)
  {
    _owner = idToOwner[_tokenId];
    require(_owner != address(0), NOT_VALID_NFT);
  }

  /**
   * @dev Get the approved address for a single NFT.
   * @notice Throws if `_tokenId` is not a valid NFT.
   * @param _tokenId ID of the NFT to query the approval of.
   * @return Address that _tokenId is approved for.
   */
  function getApproved(
    uint256 _tokenId
  )
    external
    override
    view
    returns (address)
  {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    return idToApproval[_tokenId];
  }

  /**
   * @dev Checks if `_operator` is an approved operator for `_owner`.
   * @param _owner The address that owns the NFTs.
   * @param _operator The address that acts on behalf of the owner.
   * @return True if approved for all, false otherwise.
   */
  function isApprovedForAll(
    address _owner,
    address _operator
  )
    external
    override
    view
    returns (bool)
  {
    return ownerToOperators[_owner][_operator];
  }

  /**
   * @dev Returns a descriptive name for a collection of NFTs.
   * @return _name Representing name.
   */
  function name()
    external
    override
    view
    returns (string memory _name)
  {
    _name = nftName;
  }

  /**
   * @dev Returns an abbreviated name for NFTs.
   * @return _symbol Representing symbol.
   */
  function symbol()
    external
    override
    view
    returns (string memory _symbol)
  {
    _symbol = nftSymbol;
  }

  /**
   * @notice A distinct Uniform Resource Identifier (URI) for a given asset.
   * @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC 3986. The URI may point
   * to a JSON file that conforms to the "ERC721 Metadata JSON Schema".
   * @param _tokenId Id for which we want URI.
   * @return URI of _tokenId.
   */
  function tokenURI(
    uint256 _tokenId
  )
    external
    override
    view
    returns (string memory)
  {
    require(idToOwner[_tokenId] != address(0), NOT_VALID_NFT);
    string memory uri = "";
    if (bytes(uriPrefix).length > 0)
    {
      uri = string(abi.encodePacked(uriPrefix, _uint2str(_tokenId)));
      if (bytes(uriPostfix).length > 0)
      {
        uri = string(abi.encodePacked(uri, uriPostfix));
      }
    }
    return uri;
  }

  /**
   * @dev Set a distinct URI (RFC 3986) base for all nfts.
   * @notice this is a internal function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _prefix String representing RFC 3986 URI prefix.
   * @param _postfix String representing RFC 3986 URI postfix.
   */
  function _setUri(
    string memory _prefix,
    string memory _postfix
  )
    internal
  {
    uriPrefix = _prefix;
    uriPostfix = _postfix;
  }

  /**
   * @dev Creates a new NFT.
   * @notice This is a private function which should be called from user-implemented external
   * function. Its purpose is to show and properly initialize data structures when using this
   * implementation.
   * @param _to The address that will own the created NFT.
   * @param _tokenId of the NFT to be created by the msg.sender.
   */
  function _create(
    address _to,
    uint256 _tokenId
  )
    internal
  {
    require(_to != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == address(0), NFT_ALREADY_EXISTS);

    // add NFT
    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;

    emit Transfer(address(0), _to, _tokenId);
  }

  /**
   * @dev Destroys an NFT.
   * @notice This is a private function which should be called from user-implemented external
   * destroy function. Its purpose is to show and properly initialize data structures when using
   * this implementation.
   * @param _tokenId ID of the NFT to be destroyed.
   */
  function _destroy(
    uint256 _tokenId
  )
    internal
  {
    // valid NFT
    address owner = idToOwner[_tokenId];
    require(owner != address(0), NOT_VALID_NFT);

    // clear approval
    delete idToApproval[_tokenId];

    // remove NFT
    assert(ownerToNFTokenCount[owner] > 0);
    ownerToNFTokenCount[owner] = ownerToNFTokenCount[owner] - 1;
    delete idToOwner[_tokenId];

    emit Transfer(owner, address(0), _tokenId);
  }

  /**
   * @dev Helper method that actually doee the transfer.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   */
  function _transferFrom(
    address _from,
    address _to,
    uint256 _tokenId
  )
    internal
    virtual
  {
    // valid NFT
    require(_from != address(0), ZERO_ADDRESS);
    require(idToOwner[_tokenId] == _from, NOT_VALID_NFT);
    require(_to != address(0), ZERO_ADDRESS);

    // can transfer
    require(
      _from == msg.sender
      || idToApproval[_tokenId] == msg.sender
      || ownerToOperators[_from][msg.sender],
      NOT_OWNER_APPROWED_OR_OPERATOR
    );

    // clear approval
    delete idToApproval[_tokenId];

    // remove NFT
    assert(ownerToNFTokenCount[_from] > 0);
    ownerToNFTokenCount[_from] = ownerToNFTokenCount[_from] - 1;

    // add NFT
    idToOwner[_tokenId] = _to;
    ownerToNFTokenCount[_to] = ownerToNFTokenCount[_to] + 1;

    emit Transfer(_from, _to, _tokenId);
  }

  /**
   * @dev Helper function that actually does the safeTransferFrom.
   * @param _from The current owner of the NFT.
   * @param _to The new owner.
   * @param _tokenId The NFT to transfer.
   * @param _data Additional data with no specified format, sent in call to `_to`.
   */
  function _safeTransferFrom(
    address _from,
    address _to,
    uint256 _tokenId,
    bytes memory _data
  )
    internal
    virtual
  {
    if (_to.isDeployedContract())
    {
      require(
        ERC721TokenReceiver(_to)
          .onERC721Received(msg.sender, _from, _tokenId, _data) == MAGIC_ON_ERC721_RECEIVED,
        NOT_ABLE_TO_RECEIVE_NFT
      );
    }

    _transferFrom(_from, _to, _tokenId);
  }

  /**
   * @dev Helper function that changes uint to string representation.
   * @return str String representation.
   */
  function _uint2str(
    uint256 _i
  )
    internal
    pure
    returns (string memory str)
  {
    if (_i == 0)
    {
      return "0";
    }
    uint256 j = _i;
    uint256 length;
    while (j != 0)
    {
      length++;
      j /= 10;
    }
    bytes memory bstr = new bytes(length);
    uint256 k = length;
    j = _i;
    while (j != 0)
    {
      bstr[--k] = bytes1(uint8(48 + j % 10));
      j /= 10;
    }
    str = string(bstr);
  }

}
