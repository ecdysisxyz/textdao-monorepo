// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";
import {ITextDAO, Schema} from "bundle/textDAO/interfaces/ITextDAO.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

/**
 * @title TextDAO Behavior-Focused Integration Test
 * @dev This contract contains scenario tests for the TextDAO from an end-user perspective
 */
contract TextDAOBehaviorTest is MCTest {
    ITextDAO public textDAO;
    address public constant MEMBER1 = address(0x1234);
    address public constant MEMBER2 = address(0x2345);
    address public constant MEMBER3 = address(0x3456);
    address public constant NON_MEMBER = address(0x4567);

    function setUp() public {
        Schema.Member[] memory _initialMembers = new Schema.Member[](3);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataCid: "member1Cid"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataCid: "member2Cid"});
        _initialMembers[2] = Schema.Member({addr: MEMBER3, metadataCid: "member3Cid"});

        textDAO = ITextDAO(TextDAODeployer.deploy(mc, _initialMembers));
    }

    /**
     * @dev Tests the full lifecycle of a proposal in TextDAO
     */
    function test_scenario_fullProposalLifecycle() public {
        // Create proposal
        uint256 _expirationTime = block.timestamp + TextDAODeployer.initialConfig().expiryDuration;
        address[] memory _reps = new address[](3);
        _reps[0] = MEMBER1;
        _reps[1] = MEMBER2;
        _reps[2] = MEMBER3;
        string memory _metadataCid = "originalProposalCid";
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(0, 1, _metadataCid);
        emit TextDAOEvents.RepresentativesAssigned(0, _reps);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, _expirationTime, TextDAODeployer.initialConfig().snapInterval);
        uint256 _pid = textDAO.propose(_metadataCid, new Schema.Action[](0));

        // Fork proposal
        vm.prank(MEMBER2);
        string memory _forkCid = "forkedProposalCid";
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({ // Action to be approved
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, new Schema.Member[](1))
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(_pid, 2, _forkCid);
        emit TextDAOEvents.CommandCreated(_pid, 1, _actions);
        textDAO.fork(_pid, _forkCid, _actions);

        // Vote on proposal
        vm.prank(MEMBER1);
        Schema.Vote memory _vote1 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, MEMBER1, _vote1);
        textDAO.vote(_pid, _vote1);

        vm.prank(MEMBER2);
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, MEMBER2, _vote2);
        textDAO.vote(_pid, _vote2);

        vm.prank(MEMBER3);
        Schema.Vote memory _vote3 = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, MEMBER3, _vote3);
        textDAO.vote(_pid, _vote3);

        // Wait for proposal to expire
        vm.warp(_expirationTime + 1);

        // Tally votes and then executed
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(_pid, 2, 1);
        emit TextDAOEvents.MemberAddedByProposal(_pid, 3, address(0), ""); // memberId: 3
        emit TextDAOEvents.ProposalExecuted(_pid, 1);
        textDAO.tallyAndExecute(_pid);
    }

    struct TestVars {
        uint pid;
        uint256 expirationTime;
        address[] reps;
        string metadataCid;
        string forkCid;
        Schema.Action[] actions;
        uint256 snapInterval;
        uint256 epoch;
        uint256 extendedExpirationTime;
        uint[] tieHeaderIds;
        uint[] tieCommandIds;
    }
    /**
     * @dev Tests a scenario with voting tie and resolution
     */
    function test_scenario_votingTieAndResolution() public {
        TestVars memory __;

        // Create proposal
        __.expirationTime = block.timestamp + TextDAODeployer.initialConfig().expiryDuration;
        __.reps = new address[](3);
        __.reps[0] = MEMBER1;
        __.reps[1] = MEMBER2;
        __.reps[2] = MEMBER3;
        __.metadataCid = "tieProposalCid";
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(0, 1, __.metadataCid);
        emit TextDAOEvents.RepresentativesAssigned(0, __.reps);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, __.expirationTime, TextDAODeployer.initialConfig().snapInterval);
        __.pid = textDAO.propose(__.metadataCid, new Schema.Action[](0));

        // Fork proposal
        vm.prank(MEMBER2);
        __.forkCid = "forkedProposalCid";
        __.actions = new Schema.Action[](1);
        __.actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(__.pid, new Schema.Member[](1))
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(__.pid, 2, __.forkCid);
        emit TextDAOEvents.CommandCreated(__.pid, 1, __.actions);
        textDAO.fork(__.pid, __.forkCid, __.actions);

        // Two members vote differently, causing a tie
        vm.prank(MEMBER1);
        Schema.Vote memory _vote1 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(__.pid, MEMBER1, _vote1);
        textDAO.vote(__.pid, _vote1);

        vm.prank(MEMBER2);
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(__.pid, MEMBER2, _vote2);
        textDAO.vote(__.pid, _vote2);

        // Wait for initial expiry
        vm.warp(__.expirationTime + 1);

        // Tally votes, expect a tie
        __.snapInterval = TextDAODeployer.initialConfig().snapInterval;
        __.epoch = block.timestamp / __.snapInterval * __.snapInterval;
        __.extendedExpirationTime = __.expirationTime + TextDAODeployer.initialConfig().expiryDuration;
        __.tieHeaderIds = new uint256[](2);
        __.tieHeaderIds[0] = 1;
        __.tieHeaderIds[1] = 2;
        __.tieCommandIds = new uint256[](1);
        __.tieCommandIds[0] = 1;
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(__.pid, __.epoch, __.tieHeaderIds, __.tieCommandIds, __.extendedExpirationTime);
        textDAO.tallyAndExecute(__.pid);

        // Third member votes during extended period
        vm.prank(MEMBER3);
        Schema.Vote memory _vote3 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(__.pid, MEMBER3, _vote3);
        textDAO.vote(__.pid, _vote3);

        // Wait for extended expiry
        vm.warp(__.expirationTime + TextDAODeployer.initialConfig().expiryDuration + 1);

        // Tally votes again, expect resolution
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(__.pid, 1, 1);
        emit TextDAOEvents.MemberAddedByProposal(__.pid, 3, address(0), "");
        emit TextDAOEvents.ProposalExecuted(__.pid, 1);
        textDAO.tallyAndExecute(__.pid);
    }

    /**
     * @dev Tests error cases from an end-user perspective
     */
    function test_scenario_errorCases() public {
        vm.warp(1724116970);

        // Test non-member proposal attempt
        uint256 _expirationTime = block.timestamp + TextDAODeployer.initialConfig().expiryDuration;
        vm.prank(NON_MEMBER);
        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        textDAO.propose("nonMemberProposalCid", new Schema.Action[](0));

        // Test premature tally attempt
        address[] memory _reps = new address[](3);
        _reps[0] = MEMBER1;
        _reps[1] = MEMBER2;
        _reps[2] = MEMBER3;
        string memory _metadataCid = "proposalCid";
        uint256 _snapInterval = TextDAODeployer.initialConfig().snapInterval;
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(0, 1, _metadataCid);
        emit TextDAOEvents.RepresentativesAssigned(0, _reps);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, _expirationTime, _snapInterval);
        uint256 proposalId = textDAO.propose(_metadataCid, new Schema.Action[](0));

        uint256 _epoch = block.timestamp / _snapInterval * _snapInterval;
        // uint256 _epoch = 1; // snapInterval == 0
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalSnapped(proposalId, _epoch, new uint[](0), new uint[](0));
        textDAO.tallyAndExecute(proposalId);

        // Test execution of non-approved proposal
        vm.expectRevert(TextDAOErrors.ProposalNotApproved.selector);
        textDAO.execute(proposalId);
    }
}
