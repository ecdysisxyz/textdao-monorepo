import { Bytes } from "@graphprotocol/graph-ts";
import {
  DaoInfo,
  DaoMetadata,
  DaoRegistry,
  DaoTemplate,
  GlobalConfig,
  User,
  UserInfo,
} from "../../../generated/schema";
import {
  genDaoInfoId,
  genDaoMetadataId,
  genDaoRegistryId,
  genDaoTemplateId,
  genGlobalConfigId,
  genUserId,
  genUserInfoId,
} from "./entity-id-provider";

//----------------
//  DaoRegistry
//----------------

/**
 * Loads an existing DaoRegistry entity or creates a new one if it doesn't exist.
 * @returns The loaded or newly created DaoRegistry entity
 */
export function loadOrCreateDaoRegistry(): DaoRegistry {
  const id = genDaoRegistryId();
  let daoRegistry = DaoRegistry.load(id);
  if (daoRegistry == null) {
    daoRegistry = new DaoRegistry(id);
  }
  return daoRegistry;
}

//----------------
//  DaoTemplate
//----------------

/**
 * Loads an existing DaoTemplate entity or creates a new one if it doesn't exist.
 * @param templateType The numeric type of the DAO template
 * @returns The loaded or newly created DaoTemplate entity
 */
export function loadOrCreateDaoTemplate(templateType: number): DaoTemplate {
  const id = genDaoTemplateId(templateType);
  let daoTemplate = DaoTemplate.load(id);
  if (daoTemplate == null) {
    daoTemplate = new DaoTemplate(id);
  }
  daoTemplate.save();
  return daoTemplate;
}

//------------
//  DaoInfo
//------------

/**
 * Loads an existing DaoInfo entity or creates a new one if it doesn't exist.
 * @param daoAddress The EVM address of the DAO
 * @returns The loaded or newly created DaoInfo entity
 */
export function loadOrCreateDaoInfo(daoAddress: Bytes): DaoInfo {
  const id = genDaoInfoId(daoAddress);
  let daoInfo = DaoInfo.load(id);
  if (daoInfo == null) {
    daoInfo = new DaoInfo(id);
  }
  daoInfo.save();
  return daoInfo;
}

//----------------
//  DaoMetadata
//----------------

/**
 * Creates a new DaoMetadata entity if it doesn't exist.
 * @param cid The Content Identifier (CID) of the DAO metadata
 * @returns The newly created DaoMetadata entity
 * @throws Error if the DaoMetadata already exists
 */
export function createNewDaoMetadata(cid: string): DaoMetadata {
  const id = genDaoMetadataId(cid);
  if (DaoMetadata.load(id) !== null) {
    throw new Error("DaoMetadata already exists");
  }
  return new DaoMetadata(id);
}

//-----------------
//  GlobalConfig
//-----------------

/**
 * Loads an existing GlobalConfig entity or creates a new one if it doesn't exist.
 * @returns The loaded or newly created GlobalConfig entity
 */
export function loadOrCreateGlobalConfig(): GlobalConfig {
  const id = genGlobalConfigId();
  let globalConfig = GlobalConfig.load(id);
  if (globalConfig == null) {
    globalConfig = new GlobalConfig(id);
  }
  return globalConfig;
}

//---------
//  User
//---------

/**
 * Loads an existing User entity or creates a new one if it doesn't exist.
 * @param userAddress The EVM address of the user
 * @returns The loaded or newly created User entity
 */
export function loadOrCreateUser(userAddress: Bytes): User {
  const id = genUserId(userAddress);
  let user = User.load(id);
  if (user == null) {
    user = new User(id);
  }
  user.save();
  return user;
}

//-------------
//  UserInfo
//-------------

/**
 * Creates a new UserInfo entity if it doesn't exist.
 * @param cid The Content Identifier (CID) of the user info
 * @returns The newly created UserInfo entity
 * @throws Error if the UserInfo already exists
 */
export function createNewUserInfo(cid: string): UserInfo {
  const id = genUserInfoId(cid);
  if (UserInfo.load(id) !== null) {
    throw new Error("UserInfo already exists");
  }
  return new UserInfo(id);
}
