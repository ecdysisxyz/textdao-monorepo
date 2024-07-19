// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {
    Initialize,
    Storage,
    Schema
} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

contract InitializeTest is MCTest {
    function setUp() public {
        _use(Initialize.initialize.selector, address(new Initialize()));
    }

    function test_initialize_success(Schema.Member[] calldata _initialMembers, Schema.DeliberationConfig calldata _initialConfig) public {
        vm.expectEmit();
        emit TextDAOEvents.Initialized(1);
        Initialize(target).initialize(_initialMembers, _initialConfig);

        Schema.Member[] storage $members = Storage.Members().members;
        for (uint i; i < _initialMembers.length; ++i) {
            assertEq(
                keccak256(abi.encode($members[i])),
                keccak256(abi.encode(_initialMembers[i]))
            );
        }

        Schema.DeliberationConfig storage $config = Storage.Deliberation().config;
        assertEq(
            keccak256(abi.encode($config)),
            keccak256(abi.encode(_initialConfig))
        );
    }

    function test_initialize_revert_InvalidInitialization() public {
        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 1000,
            quorumScore: 3
        });
        Initialize(target).initialize(new Schema.Member[](1), _config);

        vm.expectRevert(TextDAOErrors.InvalidInitialization.selector);
        Initialize(target).initialize(new Schema.Member[](2), _config);
    }

}
