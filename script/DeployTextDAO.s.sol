// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript, VmSafe} from "@devkit/Flattened.sol";
import {DeployLib} from "script/DeployLib.sol";

contract DeployTextDAOScript is MCScript {
    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = DeployLib.deployTextDAO(mc);

        if (!vm.isContext(VmSafe.ForgeContext.ScriptBroadcast)) return;

        uint256 chainId;
        assembly {
            chainId := chainid()
        }
        string memory chainIdString = vm.toString(chainId);

        vm.writeLine(
            string.concat(vm.projectRoot(), "/.env"),
            string.concat(
                "TEXT_DAO_ADDR_",
                chainIdString,
                "=",
                vm.toString(address(textDAO))
            )
        );
    }
}
