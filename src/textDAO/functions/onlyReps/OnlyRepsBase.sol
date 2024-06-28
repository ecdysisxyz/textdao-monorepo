// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
// Interface
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

abstract contract OnlyRepsBase {
    using DeliberationLib for Schema.Deliberation;

    modifier onlyReps(uint pid) {
        // TODO ProposalNotFound
        address[] storage $reps = Storage.Deliberation().getProposal(pid).meta.reps;

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
