// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/storages/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textDAO/storages/utils/ProposalLib.sol";
// Interface
import {IPropose} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

import "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

contract Propose is IPropose, OnlyMemberBase {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    function propose(ProposeArgs calldata _args) external onlyMember returns (uint proposalId) {
        Schema.Deliberation storage $Deliberation = Storage.Deliberation();

        if (bytes(_args.headerMetadataURI).length == 0) revert TextDAOErrors.HeaderMetadataIsRequired();

        proposalId = $Deliberation.proposals.length;

        Schema.Proposal storage $proposal = $Deliberation.createProposal();

        $proposal.createHeader(_args.headerMetadataURI);
        emit TextDAOEvents.HeaderProposed(proposalId, _args.headerMetadataURI);

        // TODO Check ignore no action
        if (_args.actions.length != 0) {
            $proposal.createCommand(_args.actions);
            emit TextDAOEvents.CommandProposed(proposalId, _args.actions);
        }


        Schema.VRFStorage storage $vrf = Storage.$VRF();
        Schema.Member[] storage $members = Storage.Members().members;

        if ($Deliberation.config.repsNum < $members.length) { // TODO check
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
