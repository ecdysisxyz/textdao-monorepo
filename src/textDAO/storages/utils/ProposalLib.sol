// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";

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

        for (uint i; i < $proposal.proposalMeta.reps.length; ++i) {
            Schema.Vote memory _repVote = $proposal.proposalMeta.votes[$proposal.proposalMeta.reps[i]];

            if (_repVote.rankedHeaderIds[0] != 0) _headerVotes[_repVote.rankedHeaderIds[0]] += 3;
            if (_repVote.rankedHeaderIds[1] != 0) _headerVotes[_repVote.rankedHeaderIds[1]] += 2;
            if (_repVote.rankedHeaderIds[2] != 0) _headerVotes[_repVote.rankedHeaderIds[2]] += 1;

            if (_repVote.rankedCommandIds[0] != 0) _commandVotes[_repVote.rankedCommandIds[0]] += 3;
            if (_repVote.rankedCommandIds[1] != 0) _commandVotes[_repVote.rankedCommandIds[1]] += 2;
            if (_repVote.rankedCommandIds[2] != 0) _commandVotes[_repVote.rankedCommandIds[2]] += 1;
        }
    }

    function isExpired(Schema.Proposal storage $proposal) internal view returns(bool) {
        return $proposal.proposalMeta.expirationTime < block.timestamp;
    }

}
