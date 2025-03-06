// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TextDAO
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
// HubDAO
import {Schema} from "bundle/hubdao/storages/Schema.sol";
import {IHubDAO, ICheats} from "bundle/hubdao/interfaces/IHubDAO.sol";

contract HubDAOFacade is IHubDAO {
    function initialize(Schema.Currency calldata baseCurrency, Schema.Template[] calldata templates, TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig) external {}
    function createTextDAO(string calldata metadataCid) external returns(address textDAO) {}
    function createTextDAOWithParams(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAO) {}
    function createTextDAOWithCheats(string calldata metadataCid) external returns(address textDAOWithCheats) {}
    function createTextDAOWithCheatsWithParams(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAOWithCheats) {}
    function updateUserProfile(string calldata metadataCid) external {}
    function removeUserProfile() external {}
}

contract HubDAOWithCheatsFacade is HubDAOFacade, ICheats {
    function initializeWithAdmin(
        Schema.Currency calldata baseCurrency,
        Schema.Template[] calldata templates,
        TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig,
        address admin
    ) external {}
    function addAdmins(address[] memory newAdmins) external {}
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external {}
    function addTemplate(Schema.Template calldata newTemplate) external {}
}
