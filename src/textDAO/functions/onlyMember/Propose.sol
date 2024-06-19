// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
import { console2 } from "forge-std/console2.sol";
import { Storage } from "bundle/textDAO/storages/Storage.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Propose is OnlyMemberBase {
    event HeaderProposed(uint pid, Schema.Header header);
    event CommandProposed(uint pid, Schema.Command cmd);

    function propose(Types.ProposalArg calldata _p) external onlyMember returns (uint proposalId) {
        Schema.DAOState storage $DAOState = Storage.DAOState();

        proposalId = $DAOState.proposals.length;

        Schema.Proposal storage $proposal = $DAOState.proposals.push();
        if (_p.header.metadataURI.length > 0) {
            $proposal.headers.push(_p.header);
            emit HeaderProposed(proposalId, _p.header);
        }
        if (_p.cmd.actions.length > 0) {
            $proposal.cmds.push(_p.cmd);
            emit CommandProposed(proposalId, _p.cmd);
        }
        $proposal.proposalMeta.createdAt = block.timestamp;


        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.Member[] storage $members = Storage.Members().members;

        if ($DAOState.config.repsNum < $members.length) { // TODO check
            /*
                VRF Request to choose reps
            */

            require($vrf.subscriptionId > 0, "No Chainlink VRF subscription. Try SetConfigsProtected::createAndFundSubscription first.");
            require($vrf.config.vrfCoordinator != address(0), "No Chainlink VRF vrfCoordinator. Try SetVRFProtected::setVRFConfig first.");
            require($vrf.config.keyHash != 0, "No Chainlink VRF keyHash. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.callbackGasLimit != 0, "No Chainlink VRF callbackGasLimit. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.requestConfirmations != 0, "No Chainlink VRF requestConfirmations. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.numWords != 0, "No Chainlink VRF numWords. Try SetConfigsProtected::setVRFConfig first.");
            require($vrf.config.LINKTOKEN != address(0), "No Chainlink VRF LINKTOKEN. Try SetConfigs::setVRFConfig first.");


            // Assumes the subscription is funded sufficiently.
            uint256 requestId = VRFCoordinatorV2Interface($vrf.config.vrfCoordinator).requestRandomWords(
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
            );

            $proposal.proposalMeta.vrfRequestId = requestId;
            $vrf.requests[requestId].proposalId = proposalId;
            // $vrf.requests[$vrf.nextId].requestId = requestId;
            // $vrf.requests[$vrf.nextId].proposalId = proposalId;
            // $vrf.nextId++;
        } else {
            for (uint i; i < $members.length; ++i) {
                $proposal.proposalMeta.reps.push($members[i].addr);
            }
        }

        // Note: Shadow(sender, timestamp)
    }

}
