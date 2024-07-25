// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDeployScript} from "script/deployment/MCDeployScript.sol";
import {TextDAOOps} from "script/TextDAOOps.sol";

contract UpgradeAndCloneScript is MCDeployScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_ADDR_11155111");
        TextDAOOps.upgradeAndClone(mc, textDAO, deployer);
        _saveAddrToEnv(textDAO, "TEXT_DAO_CHEAT_NEW_ADDR_");
    }
}
