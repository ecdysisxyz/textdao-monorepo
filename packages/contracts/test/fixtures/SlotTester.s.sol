// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { MCScript } from "@mc-devkit/MCScript.sol";
import { Dummy } from "test/fixtures/Dummy.sol";

contract SlotTester is MCScript {

    function run() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address addr = address(new Dummy());
        Dummy(addr).save();
    }
}
