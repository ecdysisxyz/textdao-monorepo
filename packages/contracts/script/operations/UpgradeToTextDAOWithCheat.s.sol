// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {TextDAOOps} from "script/TextDAOOps.sol";

contract UpgradeToTextDAOWithCheatsScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_ADDR_11155111");
        TextDAOOps.upgradeToTextDAOWithCheats(mc, textDAO);
    }
}
