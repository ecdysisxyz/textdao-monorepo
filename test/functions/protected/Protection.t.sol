// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";
import {TestUtils} from "test/fixtures/TestUtils.sol";

import {
    ProtectionBase,
    Storage,
    Schema
} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

contract Protected is ProtectionBase {
    function doSomething(uint pid) public protected(pid) returns(bool) {
        return true;
    }
}

contract ProtectedTest is MCTest {
    function setUp() public {
        _use(Protected.doSomething.selector, address(new Protected()));
    }

    function test_protected_success() public {
        Storage.DAOState().proposals.push().cmds.push().actions.push(Schema.Action({
            funcSig: "doSomething(uint256)",
            abiParams: abi.encode(0),
            status: Schema.ActionStatus.Approved
        }));

        assertTrue(Protected(target).doSomething(0));
    }

}
