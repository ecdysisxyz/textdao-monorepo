// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {OnlyMemberBase} from "bundle/textDAO/functions/onlyMember/OnlyMemberBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";
// Interface
import {IPropose} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

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

            $proposal.meta.vrfRequestId = requestId;
            $vrf.requests[requestId].proposalId = proposalId;
            // $vrf.requests[$vrf.nextId].requestId = requestId;
            // $vrf.requests[$vrf.nextId].proposalId = proposalId;
            // $vrf.nextId++;
        } else {
            for (uint i; i < $members.length; ++i) {
                $proposal.meta.reps.push($members[i].addr);
            }
        }

        // Note: Shadow(sender, timestamp)
    }

}


// Testing
import {MCTest, console2} from "@devkit/Flattened.sol";

/**
 *  Validation:
 *      - onlyMember
 *      - VRF Available
 *  State Diff:
 *      - $vrf.requests[$vrf.nextId]
 *          - requestId
 *          - proposalId
 *      - $vrf.nextId
 *      - $proposals[$---]
 *          - headers.push()
 *          - cmds.push()
 *      - nextProposalId
 */
contract ProposeTest is MCTest {

    function setUp() public {
        _use(Propose.propose.selector, address(new Propose()));
    }

    // TODO
    // function test_propose_success_withoutVrfRequest() public {}

    function test_propose_success_withVrfRequest() public {
        Schema.Members storage $m = Storage.Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.members.push().addr = address(this);

        uint256 _requestId = 1;

        // TODO: use fixtures
        $vrf.subscriptionId = uint64(1);
        $vrf.config.vrfCoordinator = address(0xff);
        $vrf.config.keyHash = bytes32(uint256(1));
        $vrf.config.callbackGasLimit = uint32(1);
        $vrf.config.requestConfirmations = uint16(1);
        $vrf.config.numWords = uint32(1);
        $vrf.config.LINKTOKEN = address(1);
        vm.mockCall(
            $vrf.config.vrfCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(_requestId)
        );

        Propose.ProposeArgs memory _args;
        _args.headerMetadataURI = "Qc.....xh";

        vm.expectCall(
            $vrf.config.vrfCoordinator,
            abi.encodeCall(VRFCoordinatorV2Interface.requestRandomWords, (
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
            )));

        // Assert pre-state
        assertEq($vrf.requests[_requestId].proposalId, 0);

        // Act & Record
        uint256 _proposedTime = block.timestamp;
        vm.record();
        uint256 pid = Propose(address(this)).propose(_args);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        // assertEq(writes.length, 12);

        assertEq($vrf.requests[_requestId].proposalId, pid);

        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.meta.currentScore, 0);
        assertEq($p.meta.headerRank.length, 0);
        assertEq($p.meta.cmdRank.length, 0);
        assertEq($p.meta.nextHeaderTallyFrom, 0);
        assertEq($p.meta.nextCmdTallyFrom, 0);
        assertEq($p.meta.reps.length, 0);
        assertEq($p.meta.createdAt, _proposedTime);
        assertEq($p.headers[1].metadataURI, _args.headerMetadataURI);
    }

    function test_propose_success_2nd() public {
        Schema.Members storage $m = Storage.Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.members.push().addr = address(this);

        uint256 _requestId = 1;

        // TODO: use fixtures
        $vrf.subscriptionId = uint64(1);
        $vrf.config.vrfCoordinator = address(0xff);
        $vrf.config.keyHash = bytes32(uint256(1));
        $vrf.config.callbackGasLimit = uint32(1);
        $vrf.config.requestConfirmations = uint16(1);
        $vrf.config.numWords = uint32(1);
        $vrf.config.LINKTOKEN = address(1);
        vm.mockCall(
            $vrf.config.vrfCoordinator,
            abi.encodeWithSelector(VRFCoordinatorV2Interface.requestRandomWords.selector),
            abi.encode(_requestId)
        );

        Propose.ProposeArgs memory _args;
        _args.headerMetadataURI = "Qc.....xh";

        vm.expectCall(
            $vrf.config.vrfCoordinator,
            abi.encodeCall(VRFCoordinatorV2Interface.requestRandomWords, (
                $vrf.config.keyHash,
                $vrf.subscriptionId,
                $vrf.config.requestConfirmations,
                $vrf.config.callbackGasLimit,
                $vrf.config.numWords
            ))
        );

        // Assert pre-state
        assertEq($vrf.requests[_requestId].proposalId, 0);

        // Act & Record
        vm.record();
        uint pid = Propose(address(this)).propose(_args);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        // assertEq(writes.length, 12);

        assertEq($vrf.requests[_requestId].proposalId, pid);
        // assertEq(_preState.vrfNextId + 1, $vrf.nextId);

        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.meta.headerRank.length, 0);
        assertEq($p.meta.cmdRank.length, 0);
        assertEq($p.headers[1].metadataURI, _args.headerMetadataURI);

        uint pid2 = Propose(address(this)).propose(_args);
        Schema.Proposal storage $p2 = Storage.Deliberation().proposals[pid2];

        assertEq(pid, 0);
        assertEq($p2.meta.headerRank.length, 0);
        assertEq($p2.meta.cmdRank.length, 0);
        assertEq($p2.headers[1].metadataURI, _args.headerMetadataURI);

    }

    function test_propose_RevertIf_NotMember() public {
        // Schema.Members storage $m = Storage.Members();
        // assertEq($m.members.length, 0);

        Propose.ProposeArgs memory _args;

        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        Propose(address(this)).propose(_args);
    }

}
