// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storages/Schema.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";

interface IInitialize {
    function initialize(
        Schema.Currency calldata currency,
        Schema.Template[] calldata templates,
        TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig
    ) external;
    function initializeWithAdmin(
        Schema.Currency calldata baseCurrency,
        Schema.Template[] calldata templates,
        TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig,
        address admin
    ) external;
}

interface ICreateDAO {
    function createTextDAO(string calldata metadataCid) external returns(address textDAO);
    function createTextDAOWithParams(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAO);
    function createTextDAOWithCheats(string calldata metadataCid) external returns(address textDAOWithCheats);
    function createTextDAOWithCheatsWithParams(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAOWithCheats);
}

interface IUserManagement {
    function updateUserProfile(string calldata metadataCid) external;
    function removeUserProfile() external;
}

// Cheats
interface ICheats {
    function addAdmins(address[] memory newAdmins) external;
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external;
    function addTemplate(Schema.Template calldata newTemplate) external;
}

interface HubDAOMainFunctions is
    IInitialize,
    ICreateDAO,
    IUserManagement
{}
