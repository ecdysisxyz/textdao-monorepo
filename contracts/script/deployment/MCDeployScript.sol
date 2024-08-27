// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript, VmSafe} from "@devkit/Flattened.sol";

// TODO move to mc repo
abstract contract MCDeployScript is MCScript {
    function _saveAddrToEnv(address addr, string memory envKeyBase) internal {
        if (!vm.isContext(VmSafe.ForgeContext.ScriptBroadcast)) return;

        uint256 _chainId;
        assembly {
            _chainId := chainid()
        }
        string memory _chainIdString = vm.toString(_chainId);

        vm.writeLine(
            string.concat(vm.projectRoot(), "/.env"),
            string.concat(
                envKeyBase,
                _chainIdString,
                "=",
                vm.toString(address(addr))
            )
        );
    }
}
