// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract OnlyRepsBase {

    modifier onlyReps(uint pid) {
        // TODO ProposalNotFound
        address[] storage $reps = Storage.Deliberation().proposals[pid].proposalMeta.reps;

        bool result;
        for (uint i; i < $reps.length; ++i) {
            if ($reps[i] == msg.sender) {
                result = true;
                break;
            }
        }
        if (!result) revert TextDAOErrors.YouAreNotTheRep();

        _;
    }

}
