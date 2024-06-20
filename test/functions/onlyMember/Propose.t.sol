// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {
    Propose,
    Storage,
    Schema,
    Types
} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

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

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";

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
        uint256 pid = Propose(address(this)).propose(p);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        assertEq(writes.length, 12);

        assertEq($vrf.requests[_requestId].proposalId, pid);

        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.currentScore, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.proposalMeta.nextHeaderTallyFrom, 0);
        assertEq($p.proposalMeta.nextCmdTallyFrom, 0);
        assertEq($p.proposalMeta.reps.length, 0);
        assertEq($p.proposalMeta.createdAt, _proposedTime);
        assertEq($p.headers[1].metadataURI, p.header.metadataURI);
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

        Types.ProposalArg memory p;
        p.header.metadataURI = "Qc.....xh";

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
        uint pid = Propose(address(this)).propose(p);
        (, bytes32[] memory writes) = vm.accesses(address(this));

        assertEq(writes.length, 12);

        assertEq($vrf.requests[_requestId].proposalId, pid);
        // assertEq(_preState.vrfNextId + 1, $vrf.nextId);

        Schema.Proposal storage $p = Storage.Deliberation().proposals[pid];

        assertEq(pid, 0);
        assertEq($p.proposalMeta.headerRank.length, 0);
        assertEq($p.proposalMeta.cmdRank.length, 0);
        assertEq($p.headers[1].metadataURI, p.header.metadataURI);

        uint pid2 = Propose(address(this)).propose(p);
        Schema.Proposal storage $p2 = Storage.Deliberation().proposals[pid2];

        assertEq(pid, 0);
        assertEq($p2.proposalMeta.headerRank.length, 0);
        assertEq($p2.proposalMeta.cmdRank.length, 0);
        assertEq($p2.headers[1].metadataURI, p.header.metadataURI);

    }

    function test_propose_RevertIf_NotMember() public {
        // Schema.Members storage $m = Storage.Members();
        // assertEq($m.members.length, 0);

        Types.ProposalArg memory p;

        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        Propose(address(this)).propose(p);
    }

}
