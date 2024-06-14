// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage} from "bundle/textDAO/storages/Storage.sol";

abstract contract OnlyVrfCoordinatorBase {
    error YouAreNotTheVrfCoordinator();

    modifier onlyVrfCoordinator() {
        if (Storage.$VRF().config.vrfCoordinator != msg.sender) revert YouAreNotTheVrfCoordinator();
        _;
    }

}
