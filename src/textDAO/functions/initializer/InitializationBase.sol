// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";

abstract contract InitializationBase {
    modifier initializer() {
        Schema.MemberJoinProtectedStorage storage $ = Storage.$Members();
        require($.nextMemberId == 0, "Initialize: already initialized");
        _;
    }
}
