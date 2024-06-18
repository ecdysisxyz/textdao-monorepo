// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

abstract contract OnlyRepsBase {
    error YouAreNotTheRep();

    modifier onlyReps(uint pid) {
        address[] storage $reps = Storage.DAOState().proposals[pid].proposalMeta.reps;

        bool result;
        for (uint i; i < $reps.length; ++i) {
            if ($reps[i] == msg.sender) {
                result = true;
                break;
            }
        }
        if (!result) revert YouAreNotTheRep();

        _;
    }

}
