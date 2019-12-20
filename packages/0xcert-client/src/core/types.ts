import { GenericProvider } from "@0xcert/ethereum-generic-provider";

/**
 * List of available order request priorities.
 */
export enum Priority {
  LOW = 1,
  MEDIUM = 2,
  HIGH = 3,
  CRITICAL = 4,
}

/**
 * List of available asset ledger capabilities.
 */
export enum AssetLedgerCapability {
  DESTROY_ASSET = 1,
  UPDATE_ASSET = 2,
  REVOKE_ASSET = 4,
  TOGGLE_TRANSFERS = 3,
}

/**
 * Asset ledger deployment definition.
 */
export interface AssetLedgerDeploymentData {

  /**
   * Asset ledger name.
   */
  name: string;

  /**
   * Asset ledger symbol.
   */
  symbol: string;

  /**
   * Asset ledger uriPrefix.
   */
  uriPrefix: string;

  /**
   * Asset ledger uriPostfix.
   */
  uriPostfix: string;

  /**
   * JSON schema representing asset ledger.
   */
  schemaId: any;

  /**
   * Asset ledger capabilities.
   */
  capabilities: AssetLedgerCapability[];

  /**
   * Asset ledger owner ID (address).
   */
  ownerId: string;
}

/**
 * Signer definition.
 */
export interface Signer {
  
  /**
   * Signer's account ID (address).
   */
  accountId: string,

  /**
   * Signer's claim.
   */
  claim?: string,
}

/**
 * Actions order definition.
 */
export interface ActionsOrder {

  /**
   * List of order's actions.
   */
  actions: Action[],

  /**
   * List of order's signers IDs (addresses).
   */
  signersIds: string[],

  /**
   * Order's payer ID (address).
   */
  payerId: string,

  /**
   * Wildcard signer tag.
   */
  wildcardSigner: boolean;

  /**
   * Automated perform tag.
   */
  automatedPerform: boolean;
}

/**
 * Action definition.
 */
export type Action = ActionCreateAsset | ActionTransferAsset | ActionTransferValue | ActionSetAbilities | ActionDestroyAsset;

/**
 * Available action kinds.
 */
export enum ActionKind {
  CREATE_ASSET = 1,
  TRANSFER_ASSET = 2,
  TRANSFER_VALUE = 3,
  SET_ABILITIES = 5,
  DESTROY_ASSET = 6,
}

/**
 * Destroy asset action definition.
 */
export interface ActionDestroyAsset {
  /**
   * Type od order action.
   */
  kind: ActionKind.DESTROY_ASSET,

  /**
   * Id (address) of the smart contract that represents the assetLedger.
   */
  assetLedgerId: string,

  /**
   * Address of the sender.
   */
  senderId: string,

  /**
   * Asset id.
   */
  id: string

}

/**
 * Set abilities action definition.
 */
export interface ActionSetAbilities {
  /**
   * Type od order action.
   */
  kind: ActionKind.SET_ABILITIES,

  /**
   * Id (address) of the smart contract that represents the assetLedger.
   */
  assetLedgerId: string,

  /**
   * Address of the sender.
   */
  senderId?: string,

  /**
   * Id (address) of account we are setting abilities to.
   */
  receiverId?: string,

  /**
   * Abilities we want to set.
   */
  abilities: AssetLedgerAbility[]
}

/**
 * Transfer value action definition.
 */
export interface ActionTransferValue {
  /**
   * Action kind.
   */
  kind: ActionKind.TRANSFER_VALUE,

  /**
   * Address of erc20 compliant smart contract.
   */
  valueLedgerId: string,

  /**
   * Address of the sender.
   */
  senderId?: string,

  /**
   * Address of the receiver.
   */
  receiverId?: string,

  /**
   * Amount of value to transfer.
   */
  value: number
}

/**
 * Transfer asset action definition.
 */
export interface ActionTransferAsset {
  /**
   * Action kind.
   */
  kind: ActionKind.TRANSFER_ASSET,

  /**
   * Address of erc721 compliant smart contract.
   */
  assetLedgerId: string,

  /**
   * Address of the sender.
   */
  senderId?: string,

  /**
   * Address of the receiver.
   */
  receiverId?: string,

  /**
   * Asset id.
   */
  id: string
}

/**
 * Create asset action definition.
 */
export interface ActionCreateAsset {

  /**
   * Order kind.
   */
  kind: ActionKind.CREATE_ASSET,

  /**
   * Address of erc721 compliant smart contract.
   */
  assetLedgerId: string,

  /**
   * Address of the sender.
   */
  senderId?: string,

  /**
   * Address of the receiver.
   */
  receiverId?: string,

  /**
   * Asset's imprint.
   */
  imprint?: string,

  /**
   * Asset id.
   */
  id: string
}

/**
 * Interface for client constructor options.
 */
export interface ClientOptions {

  /**
   * Instance of 0xcert framework provider that will be used for message signing. 
   */
  provider: GenericProvider,

  /**
   * Url to 0xcert api. Defaults to https://api.0xcert.org.
   */
  apiUrl?: string,
}


export type AssetLedgerAbility = SuperAssetLedgerAbility | GeneralAssetLedgerAbility;

/**
 * List of available general abilities an account can have per asset ledger. General abilities are
 * abilities that can not change other account's abilities.
 */
export enum GeneralAssetLedgerAbility {
  CREATE_ASSET = 16,
  REVOKE_ASSET = 32,
  TOGGLE_TRANSFERS = 64,
  UPDATE_ASSET = 128,
  UPDATE_URI_BASE = 256,
  ALLOW_CREATE_ASSET = 512,
  ALLOW_UPDATE_ASSET_IMPRINT = 1024,
}

/**
 * List of available super abilities an account can have per asset ledger. Super abilities are
 * abilities that can change other account's abilities.
 */
export enum SuperAssetLedgerAbility {
  MANAGE_ABILITIES = 1,
  ALLOW_MANAGE_ABILITIES = 2,
}

/**
 * Webhook event kinds.
 */
export enum WebhookEventKind {
  ORDER_REQUEST_CHANGED = 0,
  ORDER_REQUEST_ERROR = 1,
  DEPLOY_REQUEST_CHANGED = 2,
  DEPLOY_REQUEST_ERROR = 3,
}

/**
 * Default listing options.
 */
export interface DefaultListingOptions {
  skip?: number;
  limit?: number;
}

/**
 * Requests listing options.
 */
export interface GetRequestsOptions extends DefaultListingOptions {
  methods?: string[];
  sort?: RequestSort;
  status?: string;
  fromDate?: Date;
  toDate?: Date;
}

/**
 * Deployments listing options.
 */
export interface GetDeploymentsOptions extends DefaultListingOptions {
  filterIds?: string[];
  statuses?: number[];
  sort?: RequestSort;
}

/**
 * Ledgers listing options.
 */
export interface GetLedgersOptions extends DefaultListingOptions {
}

/**
 * Ledgers accounts listing options.
 */
export interface GetLedgersAccountsOptions extends DefaultListingOptions {
  filterAccountIds?: string[];
}

/**
 * Ledgers abilities listing options.
 */
export interface GetLedgersAbilitiesOptions extends DefaultListingOptions {
  filterAccountIds?: string[];
}

/**
 * Ledgers assets listing options.
 */
export interface GetLedgersAssetsOptions extends DefaultListingOptions {
  filterIds?: string[];
  ledgerRef?: string;
  sort?: AssetSort;
}


/**
 * Requests listing options.
 */
export interface GetOrdersOptions extends DefaultListingOptions {
  filterIds?: string[];
  statuses?: RequestStatus[];
  sort?: RequestSort;
}

/**
 * Stats costs listing options.
 */
export interface GetStatsCostsOptions extends DefaultListingOptions {
  fromDate?: Date;
  toDate?: Date;
}

/**
 * Stats traffic listing options.
 */
export interface GetStatsTrafficOptions extends DefaultListingOptions {
  fromDate?: Date;
  toDate?: Date;
  accountId?: string;
}

/**
 * Account's payment definition.
 */
export interface Payment {
  /**
   * Cost of minting an asset. 
   */
  assetCreateCost: number;

  /**
   * Cost of transferring an asset. 
   */
  assetTransferCost: number;

  /**
   * Cost of transferring value. 
   */
  valueTransferCost: number;

  /**
   * Cost of deployment value. 
   */
  assetDeployCost: number;

  /**
   * Cost of setting abilities. 
   */
  setAbilitiesCost: number;

  /**
   * Cost of revoking asset. 
   */
  assetRevokeCost: number;

  /**
   * Cost of updating asset. 
   */
  assetUpdateCost: number;

  /**
   * Cost of destroying asset.
   */
  assetDestroyCost: number;

  /**
   * Address of token for payment.
   */
  tokenAddress: string;

  /**
   * Address of payment receiver.
   */
  receiverAddress: string;
}

/**
 * Requests sorting options.
 */
export enum RequestSort {
  CREATED_AT_ASC = 1,
  CREATED_AT_DESC = 2,
}

/**
 * Assets sorting options.
 */
export enum AssetSort {
  CREATED_AT_ASC = 1,
  CREATED_AT_DESC = 2,
}

/**
 * List of available request statuses.
 */
export enum RequestStatus {
  INITIALIZED = 0,
  PENDING = 1,
  PROCESSING = 2,
  SUCCESS = 3,
  FAILURE = 4,
  SUSPENDED = 5,
  CANCELED = 6,
  FINALIZED = 7,
}

