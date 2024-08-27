// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@devkit/Flattened.sol";
import {TextDAOOps} from "script/TextDAOOps.sol";

contract AddForceApproveAdminCheatScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_CHEAT_ADDR_17000");
        TextDAOOps.addForceApproveAdminCheat(mc, textDAO, deployer);
    }
}
