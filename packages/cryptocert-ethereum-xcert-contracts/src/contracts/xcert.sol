// SPDX-License-Identifier: MIT

pragma solidity 0.8.6;

import "./ierc-2477.sol";
import "./ixcert.sol";
import "./ixcert-burnable.sol";
import "./ixcert-mutable.sol";
import "./ixcert-pausable.sol";
import "./ixcert-revokable.sol";
import "cryptocert/ethereum-utils-contracts/src/contracts/permission/abilitable.sol";
import "cryptocert/ethereum-erc721-contracts/src/contracts/nf-token-metadata-enumerable.sol";
import "cryptocert/ethereum-erc20-contracts/src/contracts/erc20.sol";

/**
 * @dev Xcert implementation.
 */
contract XcertToken is
  ERC2477,
  Xcert,
  XcertBurnable,
  XcertMutable,
  XcertPausable,
  XcertRevokable,
  NFTokenMetadataEnumerable,
  Abilitable
{

  /**
   * @dev List of abilities (gathered from all extensions):
   */
  uint8 constant ABILITY_CREATE_ASSET = 16;
  uint8 constant ABILITY_REVOKE_ASSET = 32;
  uint8 constant ABILITY_TOGGLE_TRANSFERS = 64;
  uint8 constant ABILITY_UPDATE_ASSET_URI_INTEGRITY_DIGEST = 128;
  uint16 constant ABILITY_UPDATE_URI = 256;
  /// ABILITY_ALLOW_CREATE_ASSET = 512 - A specific ability that is bounded to atomic orders.
  /// When creating a new Xcert trough `ActionsGateway`, the order maker has to have this ability.
  /// ABILITY_ALLOW_UPDATE_ASSET = 1024 - A specific ability that is bounded to atomic orders.
  /// When updating tokenURIIntegrityDigest of an Xcert trough `ActionsGateway`, the order maker has to have this
  /// ability.

  /**
   * @dev List of capabilities (supportInterface bytes4 representations).
   */
  bytes4 constant MUTABLE = 0x0d04c3b8;
  bytes4 constant BURNABLE = 0x9d118770;
  bytes4 constant PAUSABLE = 0xbedb86fb;
  bytes4 constant REVOKABLE = 0x20c5429b;

  /**
   * @dev Hashing function.
   */
  string constant HASH_ALGORITHM = 'sha256';

  /**
   * @dev Error constants.
   */
  string constant CAPABILITY_NOT_SUPPORTED = "007001";
  string constant TRANSFERS_DISABLED = "007002";
  string constant NOT_VALID_XCERT = "007003";
  string constant NOT_XCERT_OWNER_OR_OPERATOR = "007004";
  string constant INVALID_SIGNATURE = "007005";
  string constant INVALID_SIGNATURE_KIND = "007006";
  string constant CLAIM_PERFORMED = "007007";
  string constant CLAIM_EXPIRED = "007008";
  string constant CLAIM_CANCELED = "007009";
  string constant NOT_OWNER = "007010";

  /**
   * @dev This emits when ability of being able to transfer Xcerts changes (paused/unpaused).
   */
  event IsPaused(bool isPaused);

  /**
   * @dev Emits when integrity digest of a token is changed.
   * @param _tokenId Id of the Xcert.
   * @param _tokenURIIntegrityDigest Cryptographic asset integrity digest.
   */
  event TokenURIIntegrityDigestUpdate(
    uint256 indexed _tokenId,
    bytes32 _tokenURIIntegrityDigest
  );

  /**
   * @dev Enum of available signature kinds.
   * @param eth_sign Signature using eth sign.
   * @param trezor Signature from Trezor hardware wallet.
   * It differs from web3.eth_sign in the encoding of message length
   * (Bitcoin varint encoding vs ascii-decimal, the latter is not
   * self-terminating which leads to ambiguities).
   * See also:
   * https://en.bitcoin.it/wiki/Protocol_documentation#Variable_length_integer
   * https://github.com/trezor/trezor-mcu/blob/master/firmware/ethereum.c#L602
   * https://github.com/trezor/trezor-mcu/blob/master/firmware/crypto.c#L36a
   * @param eip721 Signature using eip721.
   */
  enum SignatureKind
  {
    eth_sign,
    trezor,
    no_prefix
  }

  /**
   * @dev Structure representing the signature parts.
   * @param r ECDSA signature parameter r.
   * @param s ECDSA signature parameter s.
   * @param v ECDSA signature parameter v.
   * @param kind Type of signature.
   */
  struct SignatureData
  {
    bytes32 r;
    bytes32 s;
    uint8 v;
    SignatureKind kind;
  }

  /**
   * @dev Mapping of all performed claims.
   */
  mapping(bytes32 => bool) public claimPerformed;

  /**
   * @dev Mapping of all canceled claims.
   */
  mapping(bytes32 => bool) public claimCancelled;

  /**
   * @dev Unique ID which determines each Xcert smart contract type by its JSON convention.
   * Calculated as keccak256(jsonSchema).
   */
  bytes32 internal schemaURIIntegrityDigest;

  /**
   * @dev Maps NFT ID to tokenURIIntegrityDigest.
   */
  mapping (uint256 => bytes32) internal idToIntegrityDigest;

  /**
   * @dev Maps address to authorization of contract.
   */
  mapping (address => bool) internal addressToAuthorized;

  /**
   * @dev Are Xcerts transfers paused (can be performed) or not.
   */
  bool public isPaused;

  /**
   * @dev Contract constructor.
   * @notice When implementing this contract don't forget to set schemaURIIntegrityDigest, nftName, nftSymbol
   * and uriPrefix.
   */
  constructor()
  {
    supportedInterfaces[0x39541724] = true; // Xcert
  }

  /**
   * @dev Creates a new Xcert.
   * @param _to The address that will own the created Xcert.
   * @param _id The Xcert to be created by the msg.sender.
   * @param _tokenURIIntegrityDigest Cryptographic asset uri integrity digest.
   */
  function create(
    address _to,
    uint256 _id,
    bytes32 _tokenURIIntegrityDigest
  )
    external
    override
    hasAbilities(ABILITY_CREATE_ASSET)
  {
    super._create(_to, _id);
    idToIntegrityDigest[_id] = _tokenURIIntegrityDigest;
  }

  /**
   * @dev Change URI.
   * @param _uriPrefix New URI prefix.
   * @param _uriPostfix New URI postfix.
   */
  function setUri(
    string calldata _uriPrefix,
    string calldata _uriPostfix
  )
    external
    override
    hasAbilities(ABILITY_UPDATE_URI)
  {
    super._setUri(_uriPrefix, _uriPostfix);
  }

  /**
   * @dev Revokes(destroys) a specified Xcert. Reverts if not called from contract owner or
   * authorized address.
   * @param _tokenId Id of the Xcert we want to destroy.
   */
  function revoke(
    uint256 _tokenId
  )
    external
    override
    hasAbilities(ABILITY_REVOKE_ASSET)
  {
    require(supportedInterfaces[REVOKABLE], CAPABILITY_NOT_SUPPORTED);
    super._destroy(_tokenId);
    delete idToIntegrityDigest[_tokenId];
  }

  /**
   * @dev Sets if Xcerts transfers are paused (can be performed) or not.
   * @param _isPaused Pause status.
   */
  function setPause(
    bool _isPaused
  )
    external
    override
    hasAbilities(ABILITY_TOGGLE_TRANSFERS)
  {
    require(supportedInterfaces[PAUSABLE], CAPABILITY_NOT_SUPPORTED);
    isPaused = _isPaused;
    emit IsPaused(_isPaused);
  }

  /**
   * @dev Updates Xcert integrity digest.
   * @param _tokenId Id of the Xcert.
   * @param _tokenURIIntegrityDigest New tokenURIIntegrityDigest.
   */
  function updateTokenURIIntegrityDigest(
    uint256 _tokenId,
    bytes32 _tokenURIIntegrityDigest
  )
    external
    override
    hasAbilities(ABILITY_UPDATE_ASSET_URI_INTEGRITY_DIGEST)
  {
    require(supportedInterfaces[MUTABLE], CAPABILITY_NOT_SUPPORTED);
    require(idToOwner[_tokenId] != address(0), NOT_VALID_XCERT);
    idToIntegrityDigest[_tokenId] = _tokenURIIntegrityDigest;
    emit TokenURIIntegrityDigestUpdate(_tokenId, _tokenURIIntegrityDigest);
  }

  /**
   * @dev Destroys a specified Xcert. Reverts if not called from Xcert owner or operator.
   * @param _tokenId Id of the Xcert we want to destroy.
   */
  function destroy(
    uint256 _tokenId
  )
    external
    override
  {
    require(supportedInterfaces[BURNABLE], CAPABILITY_NOT_SUPPORTED);
    address tokenOwner = idToOwner[_tokenId];
    super._destroy(_tokenId);
    require(
      tokenOwner == msg.sender || ownerToOperators[tokenOwner][msg.sender],
      NOT_XCERT_OWNER_OR_OPERATOR
    );
    delete idToIntegrityDigest[_tokenId];
  }

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _owner Address to the owner who is approving.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   * @param _feeToken The token then will be tranferred to the fee recipient of this method.
   * @param _feeValue The amount of token then will be tranfered to the fee recipient of this
   * method.
   * @param _feeRecipient Address of the fee recipient. If set to zero address the msg.sender will
   * automatically become the fee recipient.
   * @param _seed Arbitrary number to facilitate uniqueness of the order's hash. Usually timestamp.
   * @param _expiration Timestamp of when the claim expires.
   * @param _signature Data from the signature.
   */
  function setApprovalForAllWithSignature(
    address _owner,
    address _operator,
    bool _approved,
    address _feeToken,
    uint256 _feeValue,
    address _feeRecipient,
    uint256 _seed,
    uint256 _expiration,
    SignatureData calldata _signature
  )
    external
  {
    bytes32 claim = generateClaim(
      _owner,
      _operator,
      _approved,
      _feeToken,
      _feeValue,
      _feeRecipient,
      _seed,
      _expiration
    );
    require(!claimCancelled[claim], CLAIM_CANCELED);
    require(
      isValidSignature(
        _owner,
        claim,
        _signature
      ),
      INVALID_SIGNATURE
    );
    require(!claimPerformed[claim], CLAIM_PERFORMED);
    require(_expiration >= block.timestamp, CLAIM_EXPIRED);
    claimPerformed[claim] = true;
    ownerToOperators[_owner][_operator] = _approved;
    if (_feeRecipient == address(0)) {
      _feeRecipient = msg.sender;
    }
    ERC20(_feeToken).transferFrom(_owner, _feeRecipient, _feeValue);
    emit ApprovalForAll(_owner, _operator, _approved);
  }

  /**
   * @dev Enables or disables approval for a third party ("operator") to manage all of
   * `msg.sender`'s assets. It also emits the ApprovalForAll event.
   * @notice This works even if sender doesn't own any tokens at the time.
   * @param _owner Address to the owner who is approving.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   * @param _feeToken The token then will be tranferred to the fee recipient of this method.
   * @param _feeValue The amount of token then will be tranfered to the fee recipient of this
   * method.
   * @param _feeRecipient Address of the fee recipient. If set to zero address the msg.sender will
   * automatically become the fee recipient.
   * @param _seed Arbitrary number to facilitate uniqueness of the order's hash. Usually timestamp.
   * @param _expiration Timestamp of when the claim expires.
   */
  function cancelSetApprovalForAllWithSignature(
    address _owner,
    address _operator,
    bool _approved,
    address _feeToken,
    uint256 _feeValue,
    address _feeRecipient,
    uint256 _seed,
    uint256 _expiration
  )
    external
  {
    require(msg.sender == _owner, NOT_OWNER);
    bytes32 claim = generateClaim(
      _owner,
      _operator,
      _approved,
      _feeToken,
      _feeValue,
      _feeRecipient,
      _seed,
      _expiration
    );
    require(!claimPerformed[claim], CLAIM_PERFORMED);
    claimCancelled[claim] = true;
  }

  /**
   * @dev Generates hash of the set approval for.
   * @param _owner Address to the owner who is approving.
   * @param _operator Address to add to the set of authorized operators.
   * @param _approved True if the operator is approved, false to revoke approval.
   * @param _feeToken The token then will be tranferred to the fee recipient of this method.
   * @param _feeValue The amount of token then will be tranfered to the fee recipient of this
   * method.
   * @param _feeRecipient Address of the fee recipient.
   * @param _seed Arbitrary number to facilitate uniqueness of the order's hash. Usually, timestamp.
   * @param _expiration Timestamp of when the claim expires.
  */
  function generateClaim(
    address _owner,
    address _operator,
    bool _approved,
    address _feeToken,
    uint256 _feeValue,
    address _feeRecipient,
    uint256 _seed,
    uint256 _expiration
  )
    public
    view
    returns(bytes32)
  {
    return keccak256(
      abi.encodePacked(
        address(this),
        _owner,
        _operator,
        _approved,
        _feeToken,
        _feeValue,
        _feeRecipient,
        _seed,
        _expiration
      )
    );
  }

  /**
   * @dev Verifies if claim signature is valid.
   * @param _signer address of signer.
   * @param _claim Signed Keccak-256 hash.
   * @param _signature Signature data.
   */
  function isValidSignature(
    address _signer,
    bytes32 _claim,
    SignatureData memory _signature
  )
    public
    pure
    returns (bool)
  {
    if (_signature.kind == SignatureKind.eth_sign)
    {
      return _signer == ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19Ethereum Signed Message:\n32",
            _claim
          )
        ),
        _signature.v,
        _signature.r,
        _signature.s
      );
    } else if (_signature.kind == SignatureKind.trezor)
    {
      return _signer == ecrecover(
        keccak256(
          abi.encodePacked(
            "\x19Ethereum Signed Message:\n\x20",
            _claim
          )
        ),
        _signature.v,
        _signature.r,
        _signature.s
      );
    } else if (_signature.kind == SignatureKind.no_prefix)
    {
      return _signer == ecrecover(
        _claim,
        _signature.v,
        _signature.r,
        _signature.s
      );
    }

    revert(INVALID_SIGNATURE_KIND);
  }

  /**
   * @dev Returns a bytes32 of sha256 of json schema representing 0xcert Protocol convention per token.
   * @param tokenId Id of the Xcert.
   * @return digest Bytes returned from the hash algorithm
   * @return hashAlgorithm The name of the cryptographic hash algorithm
   */
  function tokenURISchemaIntegrity(
    uint256 tokenId
  )
    external
    override
    view
    returns(bytes memory digest, string memory hashAlgorithm)
  {
    require(idToOwner[tokenId] != address(0), NOT_VALID_XCERT);
    digest = abi.encodePacked(schemaURIIntegrityDigest);
    hashAlgorithm = HASH_ALGORITHM;
  }

  /**
   * @dev Returns digest for Xcert.
   * @param tokenId Id of the Xcert.
   * @return digest Bytes returned from the hash algorithm or "" if there is no schema
   * @return hashAlgorithm The name of the cryptographic hash algorithm or "" if there is no schema
   */
  function tokenURIIntegrity(
    uint256 tokenId
  )
    external
    override
    view
    returns(bytes memory digest, string memory hashAlgorithm)
  {
    require(idToOwner[tokenId] != address(0), NOT_VALID_XCERT);
    digest = abi.encodePacked(idToIntegrityDigest[tokenId]);
    hashAlgorithm = HASH_ALGORITHM;
  }

  /**
   * @dev Helper method that actually does the transfer.
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
    override
  {
    /**
     * if (supportedInterfaces[0xbedb86fb])
     * {
     *   require(!isPaused, TRANSFERS_DISABLED);
     * }
     * There is no need to check for pausable capability here since by using logical deduction we
     * can say based on code above that:
     * !supportedInterfaces[0xbedb86fb] => !isPaused
     * isPaused => supportedInterfaces[0xbedb86fb]
     * (supportedInterfaces[0xbedb86fb] ∧ isPaused) <=> isPaused.
     * This saves 200 gas.
     */
    require(!isPaused, TRANSFERS_DISABLED);
    super._transferFrom(_from, _to, _tokenId);
  }
}
