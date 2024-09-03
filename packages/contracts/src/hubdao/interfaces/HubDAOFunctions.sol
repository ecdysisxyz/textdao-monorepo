// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "../storages/Schema.sol";
// TextDAO
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";

interface ICreateDAO {
    function createTextDAO(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAO);
    function createTextDAOWithCheats(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAOWithCheats);
}

interface IInitialize {
    function initialize(Schema.Currency calldata currency, Schema.Template[] calldata templates) external;
}

// Protected

interface ITemplateManagement {
}

interface IConfigManagement {
}

// Cheats
interface ICheats {
    function addAdmins(address[] memory newAdmins) external;
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external;
    function addTemplate(Schema.Template calldata newTemplate) external;
}

interface HubDAOMainFunctions is
    ICreateDAO,
    IInitialize
{}

interface HubDAOProtectedFunctions is
    ITemplateManagement,
    IConfigManagement
{}
