// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

contract Initialize is Initializable {
    function initialize(Schema.Member[] calldata _initialMembers, Schema.DeliberationConfig calldata _initialConfig) external initializer {
        // 1. Set Initial Members
        Schema.Member[] storage $members = Storage.Members().members;
        for (uint i; i < _initialMembers.length; ++i) {
            $members.push(_initialMembers[i]);
        }

        // 2. Set Initial DeliberationConfig
        Schema.DeliberationConfig storage $config = Storage.DAOState().config = _initialConfig;
        // $config.expiryDuration = _initialConfig.expiryDuration;
        // $config.tallyInterval = _initialConfig.tallyInterval;
        // $config.repsNum = _initialConfig.repsNum;
        // $config.quorumScore = _initialConfig.quorumScore;

        /// @dev emit Initialized(1) @Initializable.initializer()

    }
}
