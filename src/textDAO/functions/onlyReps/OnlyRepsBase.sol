// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";

abstract contract OnlyRepsBase {
    modifier onlyReps(uint pid) {
        Schema.ProposeStorage storage $ = Storage.$Proposals();
        Schema.Proposal storage $p = $.proposals[pid];

        bool result;
        for (uint i; i <  $p.proposalMeta.reps.length; i++) {
            result = $p.proposalMeta.reps[i] == msg.sender || result;
        }
        require(result, "You are not the rep.");
        _;
    }
}
