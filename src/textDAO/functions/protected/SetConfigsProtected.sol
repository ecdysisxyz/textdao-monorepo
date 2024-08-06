
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interfaces
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract SetConfigsProtected is ProtectionBase {
    function setDebelirationConfig(uint pid, Schema.DeliberationConfig calldata config) public protected(pid) {
        Storage.Deliberation().config = config;
        emit TextDAOEvents.DeliberationConfigUpdatedByProposal(pid, config);
    }

    function setVRFConfig(uint pid, Schema.VRFConfig memory config) public protected(pid) returns (bool) {
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        $vrf.config.vrfCoordinator = config.vrfCoordinator;
        $vrf.config.keyHash = config.keyHash;
        $vrf.config.callbackGasLimit = config.callbackGasLimit;
        $vrf.config.requestConfirmations = config.requestConfirmations;
        $vrf.config.numWords = config.numWords;
        $vrf.config.LINKTOKEN = config.LINKTOKEN;
    }

    function createAndFundVRFSubscription(uint pid, uint96 amount) public protected(pid) returns (bool) {
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        // Create a new subscription
        $vrf.subscriptionId = VRFCoordinatorV2Interface($vrf.config.vrfCoordinator).createSubscription();

        // Fund the subscription with LINK tokens
        // Ensure this contract has enough LINK tokens before calling this
        IERC677($vrf.config.LINKTOKEN).transferAndCall(
            $vrf.config.vrfCoordinator,
            amount,
            abi.encode($vrf.subscriptionId));
    }

}

interface IERC677 {
    function transferAndCall(address to, uint256 value, bytes calldata data) external returns (bool success);
}
