// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {
    Initialize,
    Storage,
    Schema,
    Initializable
} from "bundle/textDAO/functions/initializer/Initialize.sol";

contract InitializeTest is MCTest {
    function setUp() public {
        _use(Initialize.initialize.selector, address(new Initialize()));
    }

    function test_initialize_success(Schema.Member[] calldata initialMembers, Schema.DeliberationConfig calldata pConfig) public {
        vm.expectEmit();
        emit Initializable.Initialized(1);
        Initialize(target).initialize(initialMembers, pConfig);

        Schema.Member[] storage $members = Storage.Members().members;
        for (uint i; i < initialMembers.length; ++i) {
            assertEq(
                keccak256(abi.encode($members[i])),
                keccak256(abi.encode(initialMembers[i]))
            );
        }

        Schema.DeliberationConfig storage $pConfig = Storage.Deliberation().config;
        assertEq(
            keccak256(abi.encode($pConfig)),
            keccak256(abi.encode(pConfig))
        );
    }

    function test_initialize_revert_InvalidInitialization() public {
        Schema.DeliberationConfig memory pConfig = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            tallyInterval: 1 minutes,
            repsNum: 1000,
            quorumScore: 3
        });
        Initialize(target).initialize(new Schema.Member[](1), pConfig);

        vm.expectRevert(Initializable.InvalidInitialization.selector);
        Initialize(target).initialize(new Schema.Member[](2), pConfig);
    }

}
