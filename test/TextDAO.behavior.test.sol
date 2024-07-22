// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";
import {DeployLib} from "script/deployment/DeployLib.sol";
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
        textDAO = ITextDAO(DeployLib.deployTextDAO(mc));
    }

    /**
     * @dev Tests the full lifecycle of a proposal in TextDAO
     */
    function test_scenario_fullProposalLifecycle() public {
        // Initialize TextDAO
        Schema.Member[] memory _initialMembers = new Schema.Member[](3);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
        _initialMembers[2] = Schema.Member({addr: MEMBER3, metadataURI: "member3URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 3,
            quorumScore: 2
        });

        textDAO.initialize(_initialMembers, _config);

        // Create proposal
        uint256 _expirationTime = block.timestamp + _config.expiryDuration;
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, _expirationTime);
        uint256 _pid = textDAO.propose("originalProposalURI", new Schema.Action[](0));

        // Fork proposal
        vm.prank(MEMBER2);
        string memory _forkURI = "forkedProposalURI";
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, new Schema.Member[](1))
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(_pid, 2, _forkURI);
        emit TextDAOEvents.CommandCreated(_pid, 1, _actions);
        textDAO.fork(_pid, _forkURI, _actions);

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

        // Tally votes
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(_pid, 2, 1);
        textDAO.tally(_pid);

        // Execute proposal
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalExecuted(_pid, 1);
        textDAO.execute(_pid);
    }

    /**
     * @dev Tests a scenario with voting tie and resolution
     */
    function test_scenario_votingTieAndResolution() public {
        // Initialize TextDAO (similar to previous test)
        Schema.Member[] memory _initialMembers = new Schema.Member[](3);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
        _initialMembers[2] = Schema.Member({addr: MEMBER3, metadataURI: "member3URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 3,
            quorumScore: 2
        });

        textDAO.initialize(_initialMembers, _config);

        // Create proposal
        uint256 _expirationTime = block.timestamp + _config.expiryDuration;
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, _expirationTime);
        uint256 _pid = textDAO.propose("tieProposalURI", new Schema.Action[](0));

        // Fork proposal
        vm.prank(MEMBER2);
        string memory _forkURI = "forkedProposalURI";
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, new Schema.Member[](1))
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(_pid, 2, _forkURI);
        emit TextDAOEvents.CommandCreated(_pid, 1, _actions);
        textDAO.fork(_pid, _forkURI, _actions);

        // Two members vote differently, causing a tie
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

        // Wait for initial expiry
        vm.warp(_expirationTime + 1);

        // Tally votes, expect a tie
        uint256[] memory _tieHeaderIds = new uint256[](2);
        _tieHeaderIds[0] = 1;
        _tieHeaderIds[1] = 2;
        uint256[] memory _tieCommandIds = new uint256[](1);
        _tieCommandIds[0] = 1;
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(_pid, _tieHeaderIds, _tieCommandIds);
        textDAO.tally(_pid);

        // Third member votes during extended period
        vm.prank(MEMBER3);
        Schema.Vote memory _vote3 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, MEMBER3, _vote3);
        textDAO.vote(_pid, _vote3);

        // Wait for extended expiry
        vm.warp(_expirationTime + _config.expiryDuration + 1);

        // Tally votes again, expect resolution
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(_pid, 1, 1);
        textDAO.tally(_pid);
    }

    /**
     * @dev Tests error cases from an end-user perspective
     */
    function test_scenario_errorCases() public {
        // Initialize TextDAO (similar to previous tests)
        Schema.Member[] memory initialMembers = new Schema.Member[](3);
        initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
        initialMembers[2] = Schema.Member({addr: MEMBER3, metadataURI: "member3URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 3,
            quorumScore: 2
        });

        textDAO.initialize(initialMembers, _config);

        // Test non-member proposal attempt
        uint256 _expirationTime = block.timestamp + _config.expiryDuration;
        vm.prank(NON_MEMBER);
        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        textDAO.propose("nonMemberProposalURI", new Schema.Action[](0));

        // Test premature tally attempt
        vm.prank(MEMBER1);
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, _expirationTime);
        uint256 proposalId = textDAO.propose("proposalURI", new Schema.Action[](0));

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalSnapped(proposalId, new uint[](0), new uint[](0));
        textDAO.tally(proposalId);

        // Test execution of non-approved proposal
        vm.expectRevert(TextDAOErrors.ProposalNotApproved.selector);
        textDAO.execute(proposalId);
    }
}
