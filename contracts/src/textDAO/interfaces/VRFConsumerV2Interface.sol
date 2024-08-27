// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface VRFConsumerV2Interface {
    function rawFulfillRandomWords(uint256 requestId, uint256[] memory randomWords) external;
}
