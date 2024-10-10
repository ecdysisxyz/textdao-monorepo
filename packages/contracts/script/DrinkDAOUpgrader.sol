// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary, ForgeHelper, vm, console} from "@mc-devkit/Flattened.sol";
import {DrinkDAOFacade} from "bundle/textdao/interfaces/DrinkDAOFacade.sol";

library DrinkDAOUpgrader {

    /**
     * upgrade facade
     */
    function upgradeFacade(MCDevKit storage mc, address drinkDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("DrinkDAODictionary", mc.getDictionaryAddress(drinkDAO));
        _dictionary.upgradeFacade(address(new DrinkDAOFacade())); // for Etherscan proxy read/write
    }
}
