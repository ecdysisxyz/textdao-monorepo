// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title HubDAO Schema v0.1.0
 */
interface Schema {
    /// @custom:storage-location erc7201:HubDAO.MetaState
    struct MetaState {
        Currency baseCurrency;
        mapping(TemplateType => Template) templates;
    }
    struct Currency {
        address addr;
    }
    enum TemplateType {
        undefined,
        TextDAO,
        TextDAOWithCheats
    }
    struct Template {
        TemplateType daoType;
        address dictionary;
    }

    /// @custom:storage-location erc7201:HubDAO.DaoRegistry
    struct DaoRegistry {
        mapping(address => Dao) daos;
    }
    struct Dao {
        address addr;
        TemplateType daoType;
        string metadataCid;
    }

    /// @custom:storage-location erc7201:HubDAO.Admins
    struct Admins {
        address[] admins;
    }
}
