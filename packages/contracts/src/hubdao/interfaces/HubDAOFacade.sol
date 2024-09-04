// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// TextDAO
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
// HubDAO
import {Schema} from "bundle/hubdao/storages/Schema.sol";
import {IHubDAO, ICheats} from "bundle/hubdao/interfaces/IHubDAO.sol";

contract HubDAOFacade is IHubDAO {
    function initialize(Schema.Currency calldata currency, Schema.Template[] calldata templates) external {}
    function createTextDAO(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAO) {}
    function createTextDAOWithCheats(TextDAOSchema.Member[] calldata initialMembers, TextDAOSchema.DeliberationConfig calldata initialConfig, string calldata metadataCid) external returns(address textDAOWithCheats) {}
    function updateUserProfile(string calldata metadataCid) external {}
    function removeUserProfile() external {}
}

contract HubDAOWithCheatsFacade is HubDAOFacade, ICheats {
    function addAdmins(address[] memory newAdmins) external {}
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external {}
    function addTemplate(Schema.Template calldata newTemplate) external {}
}
