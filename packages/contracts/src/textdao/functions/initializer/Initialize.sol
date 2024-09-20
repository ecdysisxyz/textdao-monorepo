// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {MemberLib} from "bundle/textdao/utils/MemberLib.sol";
// Interface
import {IInitialize} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

contract Initialize is IInitialize, Initializable {
    using MemberLib for Schema.Members;

    function initialize(Schema.Member[] calldata _initialMembers, Schema.DeliberationConfig calldata _initialConfig) external initializer {
        // 1. Set Initial Members
        Storage.Members().addMembers(_initialMembers);

        // 2. Set Initial DeliberationConfig
        Storage.Deliberation().config = _initialConfig;
        emit TextDAOEvents.DeliberationConfigUpdated(_initialConfig);

        /// @dev emit Initialized(1) @Initializable.initializer()
    }
}


// Testing
import {MCTest, console} from "@mc-devkit/Flattened.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

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
