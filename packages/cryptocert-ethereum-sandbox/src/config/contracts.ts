const {
  TokenMock,
} = require("@cryptocert/ethereum-erc20-contracts/build/token-mock");
const {
  DappTokenMock,
} = require("@cryptocert/ethereum-erc20-contracts/build/dapp-token-mock");
const {
  NFTokenEnumerableMock,
} = require("@cryptocert/ethereum-erc721-contracts/build/nf-token-enumerable-mock");
const {
  NFTokenMetadataMock,
} = require("@cryptocert/ethereum-erc721-contracts/build/nf-token-metadata-mock");
const {
  NFTokenMock,
} = require("@cryptocert/ethereum-erc721-contracts/build/nf-token-mock");
const {
  XcertMock,
} = require("@cryptocert/ethereum-xcert-contracts/build/xcert-mock");
const {
  XcertCreateProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/xcert-create-proxy");
const {
  XcertUpdateProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/xcert-update-proxy");
const {
  XcertBurnProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/xcert-burn-proxy");
const {
  TokenTransferProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/token-transfer-proxy");
const {
  NFTokenTransferProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/nftoken-transfer-proxy");
const {
  NFTokenSafeTransferProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/nftoken-safe-transfer-proxy");
const {
  AbilitableManageProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/abilitable-manage-proxy");
const {
  NFTokenReceiverTestMock,
} = require("@cryptocert/ethereum-erc721-contracts/build/nf-token-receiver-test-mock");
const {
  ActionsGateway,
} = require("@cryptocert/ethereum-gateway-contracts/build/actions-gateway");
const {
  XcertDeployGateway,
} = require("@cryptocert/ethereum-gateway-contracts/build/xcert-deploy-gateway");
const {
  TokenDeployGateway,
} = require("@cryptocert/ethereum-gateway-contracts/build/token-deploy-gateway");
const {
  XcertDeployProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/xcert-deploy-proxy");
const {
  TokenDeployProxy,
} = require("@cryptocert/ethereum-proxy-contracts/build/token-deploy-proxy");

/**
 * ERC20 contract data.
 */
export const erc20 = {
  abi: TokenMock.abi,
  bytecode: TokenMock.evm.bytecode.object,
};

/**
 * Dapp token contract data.
 */
export const dappToken = {
  abi: DappTokenMock.abi,
  bytecode: DappTokenMock.evm.bytecode.object,
};

/**
 * Enumerable ERC721 contract data.
 */
export const erc721Enumerable = {
  abi: NFTokenEnumerableMock.abi,
  bytecode: NFTokenEnumerableMock.evm.bytecode.object,
};

/**
 * ERC721 metadata contract data.
 */
export const erc721Metadata = {
  abi: NFTokenMetadataMock.abi,
  bytecode: NFTokenMetadataMock.evm.bytecode.object,
};

/**
 * ERC721 contract data.
 */
export const erc721 = {
  abi: NFTokenMock.abi,
  bytecode: NFTokenMock.evm.bytecode.object,
};

/**
 * ERC721 receiver.
 */
export const erc721receiver = {
  abi: NFTokenReceiverTestMock.abi,
  bytecode: NFTokenReceiverTestMock.evm.bytecode.object,
};

/**
 * Xcert contract data.
 */
export const xcert = {
  abi: XcertMock.abi,
  bytecode: XcertMock.evm.bytecode.object,
};

/**
 * Xcert create proxy contract data.
 */
export const xcertCreateProxy = {
  abi: XcertCreateProxy.abi,
  bytecode: XcertCreateProxy.evm.bytecode.object,
};

/**
 * Token transfer proxy data.
 */
export const tokenTransferProxy = {
  abi: TokenTransferProxy.abi,
  bytecode: TokenTransferProxy.evm.bytecode.object,
};

/**
 * Non-fungible token transfer proxy data.
 */
export const nftokenTransferProxy = {
  abi: NFTokenTransferProxy.abi,
  bytecode: NFTokenTransferProxy.evm.bytecode.object,
};

/**
 * Non-fungible token safe transfer proxy data.
 */
export const nftokenSafeTransferProxy = {
  abi: NFTokenSafeTransferProxy.abi,
  bytecode: NFTokenSafeTransferProxy.evm.bytecode.object,
};

/**
 * Non-fungible token safe transfer proxy data.
 */
export const xcertUpdateProxy = {
  abi: XcertUpdateProxy.abi,
  bytecode: XcertUpdateProxy.evm.bytecode.object,
};

/**
 * Xcert burn proxy data.
 */
export const xcertBurnProxy = {
  abi: XcertBurnProxy.abi,
  bytecode: XcertBurnProxy.evm.bytecode.object,
};

/**
 * Decentralized actionsGateway contract data.
 */
export const actionsGateway = {
  abi: ActionsGateway.abi,
  bytecode: ActionsGateway.evm.bytecode.object,
};

/**
 * Decentralized xcertDeployGateway contract data.
 */
export const xcertDeployGateway = {
  abi: XcertDeployGateway.abi,
  bytecode: XcertDeployGateway.evm.bytecode.object,
};

/**
 * Decentralized tokenDeployGateway contract data.
 */
export const tokenDeployGateway = {
  abi: TokenDeployGateway.abi,
  bytecode: TokenDeployGateway.evm.bytecode.object,
};

/**
 * Decentralized tokenDeployGateway contract data.
 */
export const abilitableManageProxy = {
  abi: AbilitableManageProxy.abi,
  bytecode: AbilitableManageProxy.evm.bytecode.object,
};

/**
 * Xcert deploy proxy contract data.
 */
export const xcertDeployProxy = {
  abi: XcertDeployProxy.abi,
  bytecode: XcertDeployProxy.evm.bytecode.object,
};

/**
 * Token deploy proxy contract data.
 */
export const tokenDeployProxy = {
  abi: TokenDeployProxy.abi,
  bytecode: TokenDeployProxy.evm.bytecode.object,
};
