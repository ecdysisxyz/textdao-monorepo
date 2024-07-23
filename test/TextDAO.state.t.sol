// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {ITextDAO, Schema} from "bundle/textDAO/interfaces/ITextDAO.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {Storage} from "bundle/textDAO/storages/Storage.sol";

import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Fork} from "bundle/textDAO/functions/onlyReps/Fork.sol";
import {Vote} from "bundle/textDAO/functions/onlyReps/Vote.sol";
import {Execute} from "bundle/textDAO/functions/Execute.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";
import {SaveTextProtected} from "bundle/textDAO/functions/protected/SaveTextProtected.sol";
import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";
import {RawFulfillRandomWords} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title TextDAO State-Focused Integration Test
 * @dev This contract contains state tests for the TextDAO using MC State-Fuzzing Test
 */
contract TextDAOStateTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;
    using CommandLib for Schema.Action;

    ITextDAO public textDAO = ITextDAO(target);
    address saveText;
    address memberJoin;
    address public constant MEMBER1 = address(0x1234);
    address public constant MEMBER2 = address(0x2345);
    address public constant MEMBER3 = address(0x3456);
    address public constant NON_MEMBER = address(0x4567);
    address public constant VRF_COORDINATOR = address(0x5678);

    /**
     * @dev Sets up the test environment by initializing necessary contracts and functions
     */
    function setUp() public {
        _use(Initialize.initialize.selector, address(new Initialize()));
        _use(Propose.propose.selector, address(new Propose()));
        _use(Fork.fork.selector, address(new Fork()));
        _use(Vote.vote.selector, address(new Vote()));
        _use(Execute.execute.selector, address(new Execute()));
        _use(Tally.tally.selector, address(new Tally()));
        saveText = address(new SaveTextProtected());
        _use(SaveTextProtected.createText.selector, saveText);
        _use(SaveTextProtected.updateText.selector, saveText);
        _use(SaveTextProtected.deleteText.selector, saveText);
        memberJoin = address(new MemberJoinProtected());
        _use(MemberJoinProtected.memberJoin.selector, memberJoin);
        _use(RawFulfillRandomWords.rawFulfillRandomWords.selector, address(new RawFulfillRandomWords()));
    }

    /**
     * @dev Tests the full lifecycle of a proposal in TextDAO
     */
    function test_scenario_fullLifecycle() public {
        // 1. Initialize TextDAO
        Schema.Member[] memory _initialMembers = new Schema.Member[](2);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 2,
            quorumScore: 2
        });

        textDAO.initialize(_initialMembers, _config);

        // 2. Create proposals
        vm.startPrank(MEMBER1);
        uint256 _pid0 = textDAO.propose("proposal1URI", new Schema.Action[](0));
        uint256 _pid1 = textDAO.propose("proposal2URI", new Schema.Action[](0));
        vm.stopPrank();

        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(_pid0);

        // 3. Fork proposals
        vm.startPrank(MEMBER2);
        Schema.Action[] memory _actions1 = new Schema.Action[](1);
        _actions1[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid0, new Schema.Member[](1))
        });
        textDAO.fork(_pid0, "proposal0 - fork1URI", _actions1);
        textDAO.fork(_pid0, "proposal0 - fork2URI", _actions1);

        Schema.Action[] memory _actions2 = new Schema.Action[](1);
        _actions2[0] = Schema.Action({
            funcSig: "saveText(uint256,uint256,string[])",
            abiParams: abi.encode(_pid1, 0, new string[](1))
        });
        textDAO.fork(_pid1, "fork2URI", _actions2);
        vm.stopPrank();

        // 4. Vote on proposals
        vm.prank(MEMBER1);
        Schema.Vote memory _vote1 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 3],
            rankedCommandIds: [uint(1), 0, 0]
        });
        textDAO.vote(_pid0, _vote1);

        vm.prank(MEMBER2);
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(2), 0, 3],
            rankedCommandIds: [uint(1), 0, 0]
        });
        textDAO.vote(_pid0, _vote2);

        // 5. Tally votes
        vm.warp($proposal.meta.expirationTime + 1);
        vm.expectEmit();
        emit TextDAOEvents.ProposalTallied(_pid0, 2, 1);
        textDAO.tally(_pid0);
        assertEq($proposal.meta.approvedHeaderId, 2, "Incorrect approved header ID");
        assertEq($proposal.meta.approvedCommandId, 1, "Incorrect approved command ID");

        // 6. Execute proposal
        vm.expectCall(memberJoin, _actions1[0].calcCallData());
        textDAO.execute(_pid0);

        // Verify execution results
        assertEq($proposal.headers.length, 4, "Incorrect number of headers after execution");
        assertEq($proposal.cmds.length, 3, "Incorrect number of commands after execution");
        assertTrue($proposal.meta.fullyExecuted, "Proposal should be fully executed");
    }

    /**
     * @dev Tests the VRF request and fulfillment process in TextDAO
     */
    function test_scenario_vrfRequestAndFulfillment() public {
        // Initialize TextDAO
        Schema.Member[] memory _initialMembers = new Schema.Member[](3);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
        _initialMembers[2] = Schema.Member({addr: MEMBER3, metadataURI: "member3URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 2,
            quorumScore: 2
        });

        textDAO.initialize(_initialMembers, _config);

        // Setup VRF configuration
        Schema.VRFConfig memory _vrfConfig = Schema.VRFConfig({
            vrfCoordinator: VRF_COORDINATOR,
            keyHash: bytes32(uint256(1)),
            callbackGasLimit: 100000,
            requestConfirmations: 3,
            numWords: 1,
            LINKTOKEN: address(0x1234) // Dummy LINK token address
        });
        Storage.$VRF().config = _vrfConfig;
        Storage.$VRF().subscriptionId = 1; // Set a dummy subscription ID
        uint256 _requestId = 100;
        vm.mockCall(
            VRF_COORDINATOR,
            abi.encodeCall(
                VRFCoordinatorV2Interface.requestRandomWords,
                (
                    _vrfConfig.keyHash,
                    1,
                    _vrfConfig.requestConfirmations,
                    _vrfConfig.callbackGasLimit,
                    _vrfConfig.numWords
                )
            ),
            abi.encode(_requestId)
        );

        // Create a proposal
        vm.prank(MEMBER1);
        uint256 _pid = textDAO.propose("proposalURI", new Schema.Action[](0));

        // Check that VRF request was made
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(_pid);
        assertEq($proposal.meta.vrfRequestId, _requestId, "VRF request should have been made");

        // Simulate VRF fulfillment
        uint256[] memory _randomWords = new uint256[](1);
        _randomWords[0] = 12345; // Example random number
        vm.prank(VRF_COORDINATOR);
        RawFulfillRandomWords(target).rawFulfillRandomWords($proposal.meta.vrfRequestId, _randomWords);

        // Check that representatives were assigned
        assertTrue($proposal.meta.reps.length > 0, "Representatives should have been assigned");

        // Verify that the assigned representatives are valid members
        for (uint i = 0; i < $proposal.meta.reps.length; i++) {
            bool _isValidMember = false;
            for (uint j = 0; j < _initialMembers.length; j++) {
                if ($proposal.meta.reps[i] == _initialMembers[j].addr) {
                    _isValidMember = true;
                    break;
                }
            }
            assertTrue(_isValidMember, "Assigned representative is not a valid member");
        }
    }

    /**
     * @dev Tests a scenario where there's a tie in voting, followed by resolution during an extended period
     */
    function test_scenario_votingTieWithResolution() public {
        // Initialize TextDAO
        Schema.Member[] memory _initialMembers = new Schema.Member[](3);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
        _initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
        _initialMembers[2] = Schema.Member({addr: address(0x3), metadataURI: "member3URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 3,
            quorumScore: 2
        });

        textDAO.initialize(_initialMembers, _config);

        // Create a proposal
        vm.prank(MEMBER1);
        uint256 _pid = textDAO.propose("tieProposalURI", new Schema.Action[](0));

        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(_pid);

        // Fork proposal
        vm.startPrank(MEMBER2);
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, new Schema.Member[](1))
        });
        textDAO.fork(_pid, "proposal0 - fork1URI", _actions);
        vm.stopPrank();

        // Two members vote differently, causing a tie
        vm.prank(MEMBER1);
        Schema.Vote memory _vote1 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        textDAO.vote(_pid, _vote1);

        vm.prank(MEMBER2);
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        textDAO.vote(_pid, _vote2);

        // Fast forward to after the initial expiry time
        vm.warp($proposal.meta.expirationTime + 1);

        // Tally the votes, expect a tie
        uint256[] memory _tieHeaderIds = new uint256[](2);
        _tieHeaderIds[0] = 1;
        _tieHeaderIds[1] = 2;
        uint256[] memory _tieCommandIds = new uint256[](1);
        _tieCommandIds[0] = 1;
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(_pid, _tieHeaderIds, _tieCommandIds);
        textDAO.tally(_pid);

        // Verify that the expiration time has been extended
        uint256 _extendedExpirationTime = $proposal.meta.createdAt + _config.expiryDuration * 2;
        assertEq(
            $proposal.meta.expirationTime,
            _extendedExpirationTime,
            "Expiration time should be extended after a tie"
        );

        // Third member votes during extended period
        vm.prank(address(0x3));
        Schema.Vote memory vote3 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        textDAO.vote(_pid, vote3);

        // Fast forward to after the extended expiry time
        vm.warp(_extendedExpirationTime + 1);

        // Tally the votes again, expect a winner this time
        uint256[] memory _winningHeaderIds = new uint256[](1);
        _winningHeaderIds[0] = 1;
        uint256[] memory _winningCommandIds = new uint256[](1);
        _winningCommandIds[0] = 1;
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(_pid, _winningHeaderIds[0], _winningCommandIds[0]);
        textDAO.tally(_pid);

        // Verify that the proposal is now approved
        assertEq($proposal.meta.approvedHeaderId, 1, "Header 1 should be approved after tie resolution");
        assertEq($proposal.meta.approvedCommandId, 1, "Command 1 should be approved after tie resolution");

        // Try to execute the proposal
        textDAO.execute(_pid);

        // Verify that the proposal is fully executed
        assertTrue($proposal.meta.fullyExecuted, "Proposal should be fully executed after tie resolution");
    }

    /**
     * @dev Tests successful execution of a proposal with text creation actions
     */
    function test_execute_successWithText() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        uint _pid = 0;
        uint _textId = 0;

        string memory _metadataURI1 = "text1URI";
        string memory _metadataURI2 = "text2URI";

        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createCreateTextAction(_pid, _metadataURI1);
        $cmd.createCreateTextAction(_pid, _metadataURI2);

        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.meta.actionStatuses[1] = Schema.ActionStatus.Approved;
        $proposal.meta.approvedCommandId = 1;

        Schema.Text[] storage $texts = Storage.Texts().texts;

        assertEq($texts.length, 0, "Texts should be empty before execution");

        textDAO.execute(_pid);

        assertEq($texts.length, 2, "Two texts should be added after execution");
        assertEq($texts[0].metadataURI, _metadataURI1, "First metadata URI mismatch");
        assertEq($texts[1].metadataURI, _metadataURI2, "Second metadata URI mismatch");
    }

    /**
     * @dev Tests successful execution of a proposal with member join actions
     */
    function test_execute_successWithMemberJoin() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        uint _pid = 0;

        Schema.Member[] memory _candidates = new Schema.Member[](2);
        _candidates[0] = Schema.Member({addr: address(0x1234), metadataURI: "member1URI"});
        _candidates[1] = Schema.Member({addr: address(0x5678), metadataURI: "member2URI"});

        $proposal.cmds.push().createMemberJoinAction(_pid, _candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;
        $proposal.meta.approvedCommandId = 1;

        Schema.Members storage $members = Storage.Members();

        assertEq($members.members.length, 0, "Members should be empty before execution");

        textDAO.execute(_pid);

        assertEq($members.members.length, 2, "Two members should be added after execution");
        assertEq($members.members[0].addr, address(0x1234), "First member address mismatch");
        assertEq($members.members[1].addr, address(0x5678), "Second member address mismatch");
        assertEq($members.members[0].metadataURI, "member1URI", "First member metadata URI mismatch");
        assertEq($members.members[1].metadataURI, "member2URI", "Second member metadata URI mismatch");
    }

    /**
     * @dev Tests that a second initialization attempt fails
     */
    function test_failedInitializationAttempt() public {
        Schema.Member[] memory _initialMembers = new Schema.Member[](1);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 1 days,
            snapInterval: 1 hours,
            repsNum: 1,
            quorumScore: 1
        });

        textDAO.initialize(_initialMembers, _config);

        vm.expectRevert(TextDAOErrors.InvalidInitialization.selector);
        textDAO.initialize(_initialMembers, _config);
    }

    /**
     * @dev Tests that a non-member cannot create a proposal
     */
    function test_nonMemberProposalAttempt() public {
        Schema.Member[] memory _initialMembers = new Schema.Member[](1);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 1 days,
            snapInterval: 1 hours,
            repsNum: 1,
            quorumScore: 1
        });

        textDAO.initialize(_initialMembers, _config);

        vm.prank(NON_MEMBER);
        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        textDAO.propose("nonMemberProposalURI", new Schema.Action[](0));
    }

    /**
     * @dev Tests that a tally attempt before proposal expiry results in a snap event
     */
    function test_prematureTallyAttempt() public {
        Schema.Member[] memory _initialMembers = new Schema.Member[](1);
        _initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 1 days,
            snapInterval: 1 hours,
            repsNum: 1,
            quorumScore: 1
        });

        textDAO.initialize(_initialMembers, _config);

        vm.prank(MEMBER1);
        uint256 pid = textDAO.propose("proposalURI", new Schema.Action[](0));

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalSnapped(pid, new uint[](0), new uint[](0));
        textDAO.tally(pid);
    }
}
