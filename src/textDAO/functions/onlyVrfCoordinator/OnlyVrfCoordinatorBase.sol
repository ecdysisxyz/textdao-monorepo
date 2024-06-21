// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract OnlyVrfCoordinatorBase {
    modifier onlyVrfCoordinator() {
        if (Storage.$VRF().config.vrfCoordinator != msg.sender) {
            revert TextDAOErrors.YouAreNotTheVrfCoordinator();
        }
        _;
    }
}
