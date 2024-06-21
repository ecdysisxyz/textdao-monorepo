// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

// External getter functions
contract Getter {
    struct ProposalInfo {
        Schema.ProposalMeta proposalMeta;
        uint256 headersLength;
        uint256 cmdsLength;
    }
    function getProposal(uint id) external view returns (ProposalInfo memory) {
        Schema.Proposal storage proposal = Storage.Deliberation().proposals[id];
        return ProposalInfo({
            headersLength: proposal.headers.length,
            cmdsLength: proposal.cmds.length,
            proposalMeta: proposal.proposalMeta
        });
    }

    function getProposalHeaders(uint pid) external view returns(Schema.Header[] memory) {
        return Storage.Deliberation().proposals[pid].headers;
    }

    // function getProposalCommand(uint pid, uint cid) external view returns(Schema.Command memory) {
    //     return Storage.Deliberation().proposals[pid].cmds[cid];
    // }

    function getProposalsConfig() external view returns (Schema.DeliberationConfig memory) {
        return Storage.Deliberation().config;
    }

    function getText(uint id) external view returns (Schema.Text memory) {
        return Storage.Texts().texts[id];
    }

    function getTexts() external view returns (Schema.Text[] memory) {
        return Storage.Texts().texts;
    }

    function getMember(uint memberId) external view returns (Schema.Member memory) {
        return Storage.Members().members[memberId];
    }

    function getMembers() external view returns (Schema.Member[] memory) {
        return Storage.Members().members;
    }

    // function getVRFRequest(uint id) external view returns (Schema.Request memory) {
    //     return Storage.$VRF().requests[id];
    // }

    // function getNextVRFId() external view returns (uint) {
    //     return Storage.$VRF().nextId;
    // }

    function getSubscriptionId() external view returns (uint64) {
        return Storage.$VRF().subscriptionId;
    }

    function getVRFConfig() external view returns (Schema.VRFConfig memory) {
        return Storage.$VRF().config;
    }

    function getConfigOverride(bytes4 sig) external view returns (Schema.ConfigOverride memory) {
        return Storage.$ConfigOverride().overrides[sig];
    }
}
