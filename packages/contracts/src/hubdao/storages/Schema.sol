// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title HubDAO Schema v0.1.0
 */
interface Schema {
    /// @custom:storage-location erc7201:HubDAO.DaoTemplates
    struct DaoTemplates {
        mapping(TemplateType => Template) templates;
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
        mapping(address daoAddress => DaoInfo) daoInfos;
    }
    struct DaoInfo {
        TemplateType daoType;
        address addr;
        string metadataCid;
    }

    /// @custom:storage-location erc7201:HubDAO.GlobalConfigs
    struct GlobalConfigs {
        Currency baseCurrency;
    }
    struct Currency {
        address addr;
    }

    /// @custom:storage-location erc7201:HubDAO.Admins
    struct Admins {
        address[] admins;
    }
}
