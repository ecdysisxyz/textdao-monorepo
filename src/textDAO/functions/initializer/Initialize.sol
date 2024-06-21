// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {MembersLib} from "bundle/textDAO/storages/utils/MembersLib.sol";
// Interface
import {IInitialize} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";

contract Initialize is IInitialize, Initializable {
    using MembersLib for Schema.Members;

    function initialize(Schema.Member[] calldata _initialMembers, Schema.DeliberationConfig calldata _initialConfig) external initializer {
        // 1. Set Initial Members
        Storage.Members().addMembers(_initialMembers);

        // 2. Set Initial DeliberationConfig
        Storage.Deliberation().config = _initialConfig;

        /// @dev emit Initialized(1) @Initializable.initializer()
    }
}
