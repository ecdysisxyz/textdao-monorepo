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
}
