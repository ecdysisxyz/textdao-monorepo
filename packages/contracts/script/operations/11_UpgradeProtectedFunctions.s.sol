// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {TextDAOUpgrader} from "script/TextDAOUpgrader.sol";

contract UpgradeProtectedFunctionsScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_CHEAT_ADDR_17000");
        TextDAOUpgrader.upgradeProtectedFunctions(mc, textDAO);
    }
}
