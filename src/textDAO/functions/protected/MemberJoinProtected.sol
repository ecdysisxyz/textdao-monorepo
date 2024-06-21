// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

contract MemberJoinProtected is ProtectionBase {
    function memberJoin(uint pid, Schema.Member[] memory candidates) public protected(pid) returns (bool) {
        Schema.Members storage $ = Storage.Members();

        for (uint i; i < candidates.length; ++i) {
            $.members.push(candidates[i]);
        }
    }
}
