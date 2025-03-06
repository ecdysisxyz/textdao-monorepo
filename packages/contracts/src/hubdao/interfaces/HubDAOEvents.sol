// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/hubdao/storages/Schema.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";

/**
 * @title HubDAOEvents
 * @dev Event definitions for HubDAO
 * @custom:version 0.1.0
 */
interface HubDAOEvents {
    // GlobalConfig
    event BaseCurrencyUpdated(Schema.Currency newCurrency);

    // DaoRegistry
    event DaoRegistered(Schema.DaoInfo daoInfo);
    event DaoInfoUpdated(Schema.DaoInfo daoInfo);
    event DaoInfoDeleted(address daoAddress);

    // DaoTemplate
    event DaoTemplateAdded(Schema.Template newDaoTemplate);
    event DaoTemplateUpdated(Schema.Template newDaoTemplate);
    event DaoTemplateDeleted(Schema.TemplateType daoType);

    // UserManagement
    event UserProfileUpdated(address userAddress, string metadataCid);
    event UserProfileRemoved(address userAddress);

    // Admins
    event AdminAdded(address newAdmin);

    // Dependencies
    event ProxyCreated(address dictionary, address proxy); /// @dev from ProxyCreator
    event Initialized(uint64 version); /// @dev from openzeppelin/Initializable^5.0.0
    event DeliberationConfigUpdated(TextDAOSchema.DeliberationConfig config); /// @dev from textdao
}
