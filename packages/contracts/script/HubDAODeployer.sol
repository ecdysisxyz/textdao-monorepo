// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit} from "@mc-devkit/Flattened.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";

import {Schema} from "bundle/hubdao/storages/Schema.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
// Main core functions
import {Initialize} from "bundle/hubdao/functions/initializer/Initialize.sol";
import {CreateDAO} from "bundle/hubdao/functions/CreateDAO.sol";
import {UserManagement} from "bundle/hubdao/functions/UserManagement.sol";
// Cheats
import {OnlyAdminCheats} from "bundle/hubdao/functions/_cheat/OnlyAdminCheats.sol";

import {
    HubDAOFacade,
    HubDAOWithCheatsFacade
} from "bundle/hubdao/interfaces/HubDAOFacade.sol";

/**
 * @title HubDAODeployer
 * @dev Library for deploying and initializing HubDAO contracts
 */
library HubDAODeployer {
    /**
     * @dev Deploys the HubDAO contract
     * @param mc MCDevKit storage reference
     * @param baseCurrency The base currency for the HubDAO
     * @param templates An array of DAO templates to be used
     * @return hubDAO Address of the deployed HubDAO proxy
     */
    function deploy(
        MCDevKit storage mc,
        Schema.Currency memory baseCurrency,
        Schema.Template[] memory templates,
        TextDAOSchema.DeliberationConfig memory textDaoDefaultConfig
    ) internal returns(address hubDAO) {
        mc.init("HubDAO");
        mc.use("Initialize", Initialize.initialize.selector, address(new Initialize()));
        address _createDAO = address(new CreateDAO());
        mc.use("CreateDAO", CreateDAO.createTextDAO.selector, _createDAO);
        mc.use("CreateDAOWithParams", CreateDAO.createTextDAOWithParams.selector, _createDAO);
        address _userManagement = address(new UserManagement());
        mc.use("UpdateUserProfile", UserManagement.updateUserProfile.selector, _userManagement);
        mc.use("RemoveUserProfile", UserManagement.removeUserProfile.selector, _userManagement);

        mc.useFacade(address(new HubDAOFacade())); // for Etherscan proxy read/write

        return mc.deploy(
            abi.encodeCall(Initialize.initialize,
                (baseCurrency, templates, textDaoDefaultConfig)
            )
        ).toProxyAddress();
    }

    /**
     * @dev Deploys the TextDAO contract with cheat functions and initializes with an admin
     * @param mc MCDevKit storage reference
     * @param baseCurrency The base currency for the HubDAO
     * @param templates An array of DAO templates to be used
     * @return textDAO Address of the deployed TextDAO proxy
     */
    function deployWithCheats(
        MCDevKit storage mc,
        Schema.Currency memory baseCurrency,
        Schema.Template[] memory templates,
        TextDAOSchema.DeliberationConfig memory textDaoDefaultConfig,
        address admin
    ) internal returns(address textDAO) {
        mc.init("HubDAOWithCheats");
        mc.use("InitializeWithAdmin", Initialize.initializeWithAdmin.selector, address(new Initialize()));
        address _createDAO = address(new CreateDAO());
        mc.use("CreateDAOWithCheats", CreateDAO.createTextDAOWithCheats.selector, _createDAO);
        mc.use("CreateDAOWithCheatsWithParams", CreateDAO.createTextDAOWithCheatsWithParams.selector, _createDAO);

        address _userManagement = address(new UserManagement());
        mc.use("UpdateUserProfile", UserManagement.updateUserProfile.selector, _userManagement);
        mc.use("RemoveUserProfile", UserManagement.removeUserProfile.selector, _userManagement);

        address _cheats = address(new OnlyAdminCheats());
        mc.use("AddAdmins", OnlyAdminCheats.addAdmin.selector, _cheats);
        mc.use("UpdateBaseCurrency", OnlyAdminCheats.updateBaseCurrency.selector, _cheats);
        mc.use("AddTemplate", OnlyAdminCheats.addTemplate.selector, _cheats);

        mc.useFacade(address(new HubDAOWithCheatsFacade())); // for Etherscan proxy read/write

        return mc.deploy(
            abi.encodeCall(Initialize.initializeWithAdmin,
                (baseCurrency, templates, textDaoDefaultConfig, admin)
            )
        ).toProxyAddress();
    }
}
