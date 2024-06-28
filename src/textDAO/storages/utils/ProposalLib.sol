// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

/**
 * @title ProposalLib v0.1.0
 */
library ProposalLib {
    function createHeader(Schema.Proposal storage $proposal, string memory _metadataURI) internal {
        $proposal.headers.push(Schema.Header({
            currentScore: 0,
            metadataURI: _metadataURI,
            tagIds: new uint[](0)
        }));
    }

    function createCommand(Schema.Proposal storage $proposal, Schema.Action[] memory _actions) internal {
        Schema.Command storage $cmd = $proposal.cmds.push();
        for (uint i; i < _actions.length; ++i) {
            $cmd.actions.push(_actions[i]);
        }
        /// @dev ActionStatus defaults to 'Proposed' (0) when creating a Command, so it doesn't need to be explicitly set.
        $cmd.currentScore = 0;
    }

    function calcVotes(Schema.Proposal storage $proposal) internal view returns(uint[] memory _headerVotes, uint[] memory _commandVotes) {
        _headerVotes = new uint[]($proposal.headers.length);
        _commandVotes = new uint[]($proposal.cmds.length);

        for (uint i; i < $proposal.meta.reps.length; ++i) {
            Schema.Vote memory _repVote = $proposal.meta.votes[$proposal.meta.reps[i]];

            if (_repVote.rankedHeaderIds[0] != 0) _headerVotes[_repVote.rankedHeaderIds[0]] += 3;
            if (_repVote.rankedHeaderIds[1] != 0) _headerVotes[_repVote.rankedHeaderIds[1]] += 2;
            if (_repVote.rankedHeaderIds[2] != 0) _headerVotes[_repVote.rankedHeaderIds[2]] += 1;

            if (_repVote.rankedCommandIds[0] != 0) _commandVotes[_repVote.rankedCommandIds[0]] += 3;
            if (_repVote.rankedCommandIds[1] != 0) _commandVotes[_repVote.rankedCommandIds[1]] += 2;
            if (_repVote.rankedCommandIds[2] != 0) _commandVotes[_repVote.rankedCommandIds[2]] += 1;
        }
    }

    function isExpired(Schema.Proposal storage $proposal) internal view returns(bool) {
        return $proposal.meta.expirationTime < block.timestamp;
    }


    /**
    * @notice Approves a specific header in the proposal
    * @param $proposal The proposal to update
    * @param _headerIdForApproval The ID of the header to approve
    * @dev Reverts if the header ID is invalid
    */
    function approveHeader(Schema.Proposal storage $proposal, uint _headerIdForApproval) internal {
        if (_headerIdForApproval == 0 ||
            _headerIdForApproval >= $proposal.headers.length
        ) {
            revert TextDAOErrors.InvalidHeaderId(_headerIdForApproval);
        }
        $proposal.meta.approvedHeaderId = _headerIdForApproval;
    }

    /**
    * @notice Approves a specific command and its actions in the proposal
    * @param $proposal The proposal to update
    * @param _cmdIdForApproval The ID of the command to approve
    * @dev Reverts if the command ID is invalid
    */
    function approveCommand(Schema.Proposal storage $proposal, uint _cmdIdForApproval) internal {
        if (_cmdIdForApproval == 0 ||
            _cmdIdForApproval >= $proposal.cmds.length
        ) {
            revert TextDAOErrors.InvalidCommandId(_cmdIdForApproval);
        }
        $proposal.meta.approvedCommandId = _cmdIdForApproval;
        Schema.Action[] storage $actions = $proposal.cmds[_cmdIdForApproval].actions;
        for (uint i; i < $actions.length; ++i) {
            $proposal.meta.actionStatuses[i] = Schema.ActionStatus.Approved;
        }
    }
}
