
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import { StorageLib } from "../internal/StorageLib.sol";
import { PassOpBase } from "./PassOpBase.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract SetConfigsPassOp is PassOpBase {
    function setProposalsConfig(uint pid, StorageLib.ProposalsConfig memory config) public onlyPassed(pid) returns (bool) {
        StorageLib.ProposeOpStorage storage $ = StorageLib.$Proposals();
        $.config.expiryDuration = config.expiryDuration;
        $.config.repsNum = config.repsNum;
        $.config.quorumScore = config.quorumScore;
    }

    function setVRFConfig(uint pid, StorageLib.VRFConfig memory config) public onlyPassed(pid) returns (bool) {
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();
        $vrf.config.vrfCoordinator = config.vrfCoordinator;
        $vrf.config.keyHash = config.keyHash;
        $vrf.config.callbackGasLimit = config.callbackGasLimit;
        $vrf.config.requestConfirmations = config.requestConfirmations;
        $vrf.config.numWords = config.numWords;
        $vrf.config.LINKTOKEN = config.LINKTOKEN;
    }

    function createAndFundVRFSubscription(uint pid, uint96 amount) public onlyPassed(pid) returns (bool) {
        StorageLib.VRFStorage storage $vrf = StorageLib.$VRF();

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