// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@devkit/Flattened.sol";
import {DeployLib} from "script/DeployLib.sol";

contract DeployTextDAOScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = DeployLib.deployTextDAO(mc);

        bytes memory encodedData = abi.encodePacked("TEXT_DAO_ADDR=", vm.toString(address(textDAO)));
        vm.writeLine(
            string(
                abi.encodePacked(vm.projectRoot(), "/.env")
            ),
            string(encodedData)
        );
    }
}
