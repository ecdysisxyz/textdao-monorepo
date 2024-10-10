// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@mc-devkit/Flattened.sol";
import {DrinkDAODeployer} from "script/DrinkDAODeployer.sol";
import {Schema} from "bundle/textdao/storages/Schema.sol";

contract DeployDrinkDAOScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address drinkDAO = DrinkDAODeployer.deployWithCheats({
            mc: mc,
            admin: deployer,
            initialConfig: Schema.DeliberationConfig({
                expiryDuration: 3 days,
                snapInterval: 24 hours,
                repsNum: 3000,
                quorumScore: 1
            })
        });
        _saveAddrToEnv(drinkDAO, "DRINK_DAO_CHEAT_ADDR_");
    }
}
