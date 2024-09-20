// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {TextDAOOps} from "script/TextDAOOps.sol";

contract UpgradeAndCloneScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_ADDR_11155111");
        address newTextDAO = TextDAOOps.upgradeAndClone(mc, textDAO, deployer);
        _saveAddrToEnv(newTextDAO, "TEXT_DAO_CHEAT_NEW_ADDR_");
    }
}
