import { Bytes } from "@graphprotocol/graph-ts";

/**
 * Generates a constant ID for the DaoRegistry entity.
 * @returns A string constant "DaoRegistryID"
 */
export function genDaoRegistryId(): string {
  return "DaoRegistryID";
}

/**
 * Generates an ID for a DaoTemplate entity based on its numeric type.
 * @param templateType The numeric type of the DAO template (0, 1, 2, or any other number)
 * @returns A string identifier corresponding to the template type:
 *          - "UndefinedDaoTemplate" for type 0
 *          - "TextDAO" for type 1
 *          - "TextDAOWithCheats" for type 2
 *          - "UnknownDaoTemplate" for any other value
 */
export function genDaoTemplateId(templateType: number): string {
  if (templateType == 0) return "UndefinedDaoTemplate";
  if (templateType == 1) return "TextDAO";
  if (templateType == 2) return "TextDAOWithCheats";
  return "UnknownDaoTemplate";
}

/**
 * Generates an ID for a DaoInfo entity based on its address.
 * @param daoAddress The Ethereum address of the DAO
 * @returns The hexadecimal string representation of the DAO address
 */
export function genDaoInfoId(daoAddress: Bytes): string {
  return daoAddress.toHexString();
}

/**
 * Generates an ID for DaoMetadata entity based on its CID.
 * @param cid The Content Identifier (CID) of the metadata
 * @returns The CID as the ID
 */
export function genDaoMetadataId(cid: string): string {
  return cid;
}

/**
 * Generates a constant ID for the GlobalConfig entity.
 * @returns A string constant "GlobalConfigID"
 */
export function genGlobalConfigId(): string {
  return "GlobalConfigID";
}

/**
 * Generates an ID for a User entity based on their address.
 * @param userAddress The Ethereum address of the user
 * @returns The hexadecimal string representation of the user's address
 */
export function genUserId(userAddress: Bytes): string {
  return userAddress.toHexString();
}

/**
 * Generates an ID for UserInfo entity based on its CID.
 * @param cid The Content Identifier (CID) of the user info
 * @returns The CID as the ID
 */
export function genUserInfoId(cid: string): string {
  return cid;
}
