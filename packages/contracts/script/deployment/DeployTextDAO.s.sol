// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDeployScript} from "script/deployment/MCDeployScript.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";

contract DeployTextDAOScript is MCDeployScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address _textDAO = TextDAODeployer.deploy(mc, TextDAODeployer.initialMember(deployer));
        _saveAddrToEnv(_textDAO, "TEXT_DAO_ADDR_");
    }
}

contract DeployTextDAOWithCheatScript is MCDeployScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address _textDAO = TextDAODeployer.deployWithCheats(mc, deployer);
        _saveAddrToEnv(_textDAO, "TEXT_DAO_CHEAT_ADDR_");
    }
}
