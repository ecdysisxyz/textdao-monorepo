// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/hubdao/storages/Schema.sol";

interface HubDAOEvents {
    // MetaState
    event BaseCurrencyUpdated(Schema.Currency newCurrency);
    event DaoTemplateUpdated(Schema.Template newDaoTemplate);

    // Create
    event ProxyCreated(address dictionary, address proxy); /// @dev from ProxyCreator
    event DaoCreated(address daoAddress);
    event DaoRegistered(Schema.Dao daoInfo);
}
