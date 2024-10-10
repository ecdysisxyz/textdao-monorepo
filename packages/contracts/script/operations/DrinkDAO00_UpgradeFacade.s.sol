// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {DrinkDAOUpgrader} from "script/DrinkDAOUpgrader.sol";

contract DrinkDAO_UpgradeFacadeScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address drinkDAO = vm.envAddress("DRINK_DAO_CHEAT_ADDR_8453");
        DrinkDAOUpgrader.upgradeFacade(mc, drinkDAO);
    }
}
