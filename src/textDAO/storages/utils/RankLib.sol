// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title RankLib v0.1.0
 */
library RankLib {
    function findTop1(uint[] memory _votes) internal pure returns(uint[] memory topIndices) {
        uint maxVote = _votes[0];
        topIndices = new uint[](1);
        topIndices[0] = 0;

        for (uint i = 1; i < _votes.length; ++i) {
            if (_votes[i] > maxVote) {
                maxVote = _votes[i];
                topIndices[0] = i;
            } else if (_votes[i] == maxVote) {
                uint[] memory newTopIndices = new uint[](topIndices.length + 1);
                for (uint j = 0; j < topIndices.length; j++) {
                    newTopIndices[j] = topIndices[j];
                }
                newTopIndices[topIndices.length] = i;
                topIndices = newTopIndices;
            }
        }

        return topIndices;
    }
}
