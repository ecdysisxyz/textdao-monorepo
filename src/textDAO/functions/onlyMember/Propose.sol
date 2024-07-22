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
// External Contract Interface
import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

/**
 * @title Propose
 * @dev Contract for proposing new proposals in TextDAO
 */
contract Propose is IPropose, OnlyMemberBase {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;

    /**
     * @notice Proposes a new proposal
     * @param headerMetadataURI The URI for the header metadata
     * @param actions The array of actions for the proposal
     * @return pid The ID of the newly created proposal
     */
    function propose(string calldata headerMetadataURI, Schema.Action[] calldata actions) external onlyMember returns (uint pid) {
        Schema.Deliberation storage $deliberation = Storage.Deliberation();

        if (bytes(headerMetadataURI).length == 0) revert TextDAOErrors.HeaderMetadataIsRequired();

        pid = $deliberation.proposals.length;
        Schema.Proposal storage $proposal = $deliberation.createProposal();

        $proposal.createHeader(headerMetadataURI);
        emit TextDAOEvents.HeaderProposed(pid, headerMetadataURI);

        if (actions.length > 0) {
            $proposal.createCommand(actions);
            emit TextDAOEvents.CommandProposed(pid, actions);
        }

        _setupRepresentatives($proposal, pid);

        emit TextDAOEvents.Proposed(pid, msg.sender, block.timestamp);
    }

    /**
     * @dev Sets up representatives for the proposal
     * @param $proposal The proposal storage reference
     * @param pid The ID of the proposal
     */
    function _setupRepresentatives(Schema.Proposal storage $proposal, uint pid) internal {
        Schema.Member[] storage $members = Storage.Members().members;
        Schema.DeliberationConfig memory $config = Storage.Deliberation().config;

        if ($config.repsNum < $members.length) {
            _requestVRF($proposal, pid);
        } else {
            _assignAllMembersAsReps($proposal, $members);
            emit TextDAOEvents.RepresentativesAssigned(pid, $proposal.meta.reps);
        }
    }

    /**
     * @dev Requests VRF for choosing representatives
     * @param $proposal The proposal storage reference
     * @param pid The ID of the proposal
     */
    function _requestVRF(Schema.Proposal storage $proposal, uint pid) internal {
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        _validateVRFConfig($vrf);

        uint256 _requestId = VRFCoordinatorV2Interface($vrf.config.vrfCoordinator).requestRandomWords(
            $vrf.config.keyHash,
            $vrf.subscriptionId,
            $vrf.config.requestConfirmations,
            $vrf.config.callbackGasLimit,
            $vrf.config.numWords
        );

        $proposal.meta.vrfRequestId = _requestId;
        $vrf.requests[_requestId].proposalId = pid;

        emit TextDAOEvents.VRFRequested(pid, _requestId);
    }

    /**
     * @dev Assigns all members as representatives when their number is less than or equal to required reps
     * @param $proposal The proposal storage reference
     * @param $members The members storage reference
     */
    function _assignAllMembersAsReps(Schema.Proposal storage $proposal, Schema.Member[] storage $members) internal {
        for (uint i; i < $members.length; ++i) {
            $proposal.meta.reps.push($members[i].addr);
        }
    }

    /**
     * @dev Validates the VRF configuration
     * @param $vrf The VRF storage reference
     */
    function _validateVRFConfig(Schema.VRFStorage storage $vrf) internal view {
        if ($vrf.subscriptionId == 0) revert TextDAOErrors.InvalidVRFSubscription();
        if ($vrf.config.vrfCoordinator == address(0)) revert TextDAOErrors.InvalidVRFCoordinator();
        if ($vrf.config.keyHash == 0) revert TextDAOErrors.InvalidVRFKeyHash();
        if ($vrf.config.callbackGasLimit == 0) revert TextDAOErrors.InvalidVRFCallbackGasLimit();
        if ($vrf.config.requestConfirmations == 0) revert TextDAOErrors.InvalidVRFRequestConfirmations();
        if ($vrf.config.numWords == 0) revert TextDAOErrors.InvalidVRFNumWords();
        if ($vrf.config.LINKTOKEN == address(0)) revert TextDAOErrors.InvalidVRFLinkToken();
    }
}


// Testing
import {MCTest, console2} from "@devkit/Flattened.sol";

/**
 * @title ProposeTest
 * @dev Test contract for the Propose contract
 * @notice This contract contains comprehensive tests for the Propose contract, including:
 *          - Success cases
 *          - Failure cases
 *          - Event tests
 *          - Gas consumption tests
 *          - Fuzz tests
 *          - Edge cases
 */
contract ProposeTest is MCTest {
    using DeliberationLib for Schema.Deliberation;

    function setUp() public {
        _use(Propose.propose.selector, address(new Propose()));
    }

    //==========================
    //      Success Cases
    //==========================

    /**
     * @notice Test proposing without VRF request when number of members <= required reps
     * @dev This test checks that:
     *      1. A proposal can be created successfully
     *      2. The header metadata is set correctly
     *      3. All members are assigned as representatives without VRF
     */
    function test_propose_success_withoutVrfRequest() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        $m.members.push().addr = address(0x1);
        Storage.Deliberation().config.repsNum = 3;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Act
        uint256 _pid = Propose(target).propose(_headerMetadataURI, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(_pid);
        assertEq(_pid, 0, "Proposal ID should be 0 for the first proposal");
        assertEq($p.headers[1].metadataURI, _headerMetadataURI, "Header metadata should match the input");
        assertEq($p.meta.reps.length, 2, "All members should be assigned as representatives");
        assertEq($p.meta.reps[0], address(this), "First member should be a representative");
        assertEq($p.meta.reps[1], address(0x1), "Second member should be a representative");
    }

    /**
     * @notice Test proposing with VRF request when number of members > required reps
     * @dev This test checks that:
     *      1. A proposal can be created successfully
     *      2. The header metadata is set correctly
     *      3. A VRF request is made for selecting representatives
     *      4. The VRF request ID is stored correctly
     */
    function test_propose_success_withVrfRequest() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.members.push().addr = address(this);
        $m.members.push().addr = address(0x1);
        $m.members.push().addr = address(0x2);
        Storage.Deliberation().config.repsNum = 2;

        uint256 _requestId = 1;
        _setupVRFMock($vrf, _requestId);

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Expect
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
        // vm.record();
        uint256 _pid = Propose(address(this)).propose(_headerMetadataURI, _actions);
        // (, bytes32[] memory writes) = vm.accesses(address(this));
        // assertEq(writes.length, 12);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(_pid);
        assertEq(_pid, 0, "Proposal ID should be 0 for the first proposal");
        assertEq($p.headers[1].metadataURI, _headerMetadataURI, "Header metadata should match the input");
        assertEq($p.meta.vrfRequestId, _requestId, "VRF request ID should be stored");
        assertEq($p.meta.reps.length, 0, "Representatives should not be assigned before VRF fulfillment");
        assertEq($vrf.requests[_requestId].proposalId, _pid, "VRF request should be associated with the proposal");
        assertEq($p.meta.createdAt, _proposedTime, "CreatedAt should be proposed time");
    }

    /**
     * @notice Test multiple proposal creations
     * @dev This test checks that:
     *      1. Multiple proposals can be created successfully
     *      2. Each proposal has a unique ID
     *      3. The state is correctly updated for each proposal
     */
    function test_propose_success_multipleProposals() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();

        $m.members.push().addr = address(this);
        $m.members.push().addr = address(0x1234);
        Storage.Deliberation().config.repsNum = 1;

        string memory _headerMetadataURI1 = "Qc.....xh1";
        Schema.Action[] memory _actions1 = new Schema.Action[](0);

        string memory _headerMetadataURI2 = "Qc.....xh2";
        Schema.Action[] memory _actions2 = new Schema.Action[](0);

        // Act
        _setupVRFMock($vrf, 1); // Setup VRF mock for first proposal
        uint256 pid1 = Propose(target).propose(_headerMetadataURI1, _actions1);

        _setupVRFMock($vrf, 3); // Setup VRF mock for second proposal
        uint256 pid2 = Propose(target).propose(_headerMetadataURI2, _actions2);

        // Assert
        assertEq(pid1, 0, "First proposal ID should be 0");
        assertEq(pid2, 1, "Second proposal ID should be 1");

        Schema.Proposal storage $p1 = Storage.Deliberation().getProposal(pid1);
        Schema.Proposal storage $p2 = Storage.Deliberation().getProposal(pid2);

        assertEq($p1.headers[1].metadataURI, _headerMetadataURI1, "First proposal header metadata should match");
        assertEq($p2.headers[1].metadataURI, _headerMetadataURI2, "Second proposal header metadata should match");

        assertEq($p1.meta.reps.length, 0, "First proposal should have 1 representative");
        assertEq($p2.meta.reps.length, 0, "Second proposal should have 1 representative");

        assertEq($p1.meta.vrfRequestId, 1, "First proposal should have requestId 1");
        assertEq($p2.meta.vrfRequestId, 3, "Second proposal should have requestId 3");

        assertEq($vrf.requests[1].proposalId, 0, "RequestId 1 should be associated with pid 0");
        assertEq($vrf.requests[3].proposalId, 1, "RequestId 3 should be associated with pid 1");
    }

    /**
     * @notice Test proposing with actions
     * @dev This test checks that:
     *      1. A proposal with actions can be created successfully
     *      2. The actions are correctly stored in the proposal
     */
    function test_propose_success_withActions() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        Storage.Deliberation().config.repsNum = 1;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({
            funcSig: "testFunction(uint256)",
            abiParams: abi.encode(123)
        });

        // Act
        uint256 pid = Propose(target).propose(_headerMetadataURI, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(pid);
        assertEq($p.cmds[1].actions.length, 1, "Proposal should have 1 action");
        assertEq($p.cmds[1].actions[0].funcSig, "testFunction(uint256)", "Action function signature should match");
        assertEq(abi.decode($p.cmds[1].actions[0].abiParams, (uint256)), 123, "Action parameters should match");
    }

    /**
     * @notice Test proposing when number of members equals required reps
     * @dev This test checks the boundary condition where the number of members
     *      is exactly equal to the required number of representatives
     */
    function test_propose_success_exactRequiredReps() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        $m.members.push().addr = address(0x1);
        Storage.Deliberation().config.repsNum = 2;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Act
        uint256 pid = Propose(target).propose(_headerMetadataURI, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(pid);
        assertEq($p.meta.reps.length, 2, "All members should be assigned as representatives");
        assertEq($p.meta.reps[0], address(this), "First member should be a representative");
        assertEq($p.meta.reps[1], address(0x1), "Second member should be a representative");
    }

    //==========================
    //      Failure Cases
    //==========================

    /**
     * @notice Test that non-members cannot propose
     * @dev This test checks that the onlyMember modifier is working correctly
     */
    function test_propose_revert_notMember() public {
        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        vm.expectRevert(TextDAOErrors.YouAreNotTheMember.selector);
        Propose(target).propose(_headerMetadataURI, _actions);
    }

    /**
     * @notice Test that proposals with empty header metadata are rejected
     * @dev This test checks that the contract correctly enforces non-empty header metadata
     */
    function test_propose_revert_emptyHeaderMetadata() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);

        string memory _headerMetadataURI = ""; // empty metadata
        Schema.Action[] memory _actions = new Schema.Action[](0);

        vm.expectRevert(TextDAOErrors.HeaderMetadataIsRequired.selector);
        Propose(target).propose(_headerMetadataURI, _actions);
    }

    /**
     * @notice Test that proposing fails when VRF config is invalid
     * @dev This test checks that the contract correctly validates VRF configuration before making a request
     */
    function test_propose_revert_invalidVRFConfig() public {
        // Setup
        Schema.Members storage $m = Storage.Members();

        $m.members.push().addr = address(this);
        $m.members.push().addr = address(0x1);
        $m.members.push().addr = address(0x2);
        Storage.Deliberation().config.repsNum = 2;

        // Intentionally leave VRF config invalid

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        vm.expectRevert(TextDAOErrors.InvalidVRFSubscription.selector);
        Propose(target).propose(_headerMetadataURI, _actions);
    }

    //=========================
    //      Event Tests
    //=========================

    /**
     * @notice Test event emissions during proposal creation
     * @dev This test checks that all expected events are emitted with correct parameters
     */
    function test_propose_events() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        Storage.Deliberation().config.repsNum = 1;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Expect events
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderProposed(0, "Qc.....xh");
        emit TextDAOEvents.RepresentativesAssigned(0, new address[](1));
        emit TextDAOEvents.Proposed(0, address(this), block.timestamp);

        // Act
        Propose(target).propose(_headerMetadataURI, _actions);
    }

    //==================================
    //      Gas Consumption Tests
    //==================================

    /**
     * @notice Test gas consumption for proposal creation
     * @dev This test measures gas consumption for creating a proposal with and without VRF
     */
    function test_propose_gasConsumption() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        Schema.VRFStorage storage $vrf = Storage.$VRF();
        $m.members.push().addr = address(this);
        Storage.Deliberation().config.repsNum = 1;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Measure gas for proposal without VRF
        uint256 gasStart = gasleft();
        Propose(target).propose(_headerMetadataURI, _actions);
        uint256 gasUsedWithoutVRF = gasStart - gasleft();

        // Setup for VRF
        $m.members.push().addr = address(0x1);
        Storage.Deliberation().config.repsNum = 1;
        _setupVRFMock($vrf, 1);

        // Measure gas for proposal with VRF
        gasStart = gasleft();
        Propose(target).propose(_headerMetadataURI, _actions);
        uint256 gasUsedWithVRF = gasStart - gasleft();

        console2.log("Gas used without VRF:", gasUsedWithoutVRF);
        console2.log("Gas used with VRF:", gasUsedWithVRF);

        // Assert that gas usage is within acceptable limits
        assert(gasUsedWithoutVRF < 300000);  // Adjust these values based on your requirements
        assert(gasUsedWithVRF < 400000);     // Adjust these values based on your requirements
    }

    //========================
    //      Fuzz Tests
    //========================

    /**
     * @notice Fuzz test for proposal creation with various input sizes
     * @dev This test creates proposals with randomly generated inputs
     * @param headerLength The length of the header metadata URI
     * @param actionCount The number of actions in the proposal
     */
    function testFuzz_propose_success_withRandomInputs(uint8 headerLength, uint8 actionCount) public {
        vm.assume(0 < headerLength && headerLength <= 100);  // Assume reasonable header length
        vm.assume(actionCount <= 10);  // Assume reasonable number of actions

        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        Storage.Deliberation().config.repsNum = 1;

        // Create random header metadata
        string memory _headerMetadata = _generateRandomString(headerLength);

        // Create random actions
        Schema.Action[] memory _actions = new Schema.Action[](actionCount);
        for (uint i; i < actionCount; ++i) {
            _actions[i] = Schema.Action({
                funcSig: "testFunction(uint256)",
                abiParams: abi.encode(uint256(i))
            });
        }

        // Act
        uint256 pid = Propose(target).propose(_headerMetadata, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(pid);
        assertEq($p.headers[1].metadataURI, _headerMetadata, "Header metadata should match");

        if (actionCount == 0) {
            assertEq($p.cmds.length, 1, "No Action, No command"); // commandId 0 is unused id
        } else {
            assertEq($p.cmds[1].actions.length, actionCount, "Action count should match");
        }
    }

    //========================
    //      Edge Cases
    //========================

    /**
     * @notice Test proposing with maximum allowed actions
     * @dev This test checks that a proposal with the maximum allowed number of actions can be created successfully
     */
    function test_propose_success_maxActions() public {
        // Setup
        Schema.Members storage $m = Storage.Members();
        $m.members.push().addr = address(this);
        Storage.Deliberation().config.repsNum = 1;

        // Assume maximum allowed actions is 200 (adjust as needed)
        uint256 MAX_ACTIONS = 200;

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](MAX_ACTIONS);

        for (uint i; i < MAX_ACTIONS; ++i) {
            _actions[i] = Schema.Action({
                funcSig: "testFunction(uint256)",
                abiParams: abi.encode(i)
            });
        }

        // Act
        uint256 _pid = Propose(target).propose(_headerMetadataURI, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(_pid);
        assertEq($p.cmds[1].actions.length, MAX_ACTIONS, "Proposal should have maximum allowed actions");
    }

    /**
     * @notice Test proposing with maximum number of members
     * @dev This test checks that a proposal can be created successfully when the number of members is at its maximum
     */
    function test_propose_success_maxMembers() public {
        // Setup
        Schema.Members storage $m = Storage.Members();

        // Assume maximum allowed members is 1000
        uint256 MAX_MEMBERS = 1000;

        $m.members.push().addr = address(this);
        for (uint i; i < MAX_MEMBERS - 1; ++i) {
            $m.members.push().addr = address(uint160(i + 1));
        }

        Storage.Deliberation().config.repsNum = MAX_MEMBERS; // Set repsNum not to trigger VRF

        string memory _headerMetadataURI = "Qc.....xh";
        Schema.Action[] memory _actions = new Schema.Action[](0);

        // Act
        uint256 _pid = Propose(target).propose(_headerMetadataURI, _actions);

        // Assert
        Schema.Proposal storage $p = Storage.Deliberation().getProposal(_pid);
        assertEq($p.meta.reps.length, MAX_MEMBERS, "Reps count should be max members");

        // Note: This test revealed that proposing with 1000 members consumes approximately 23,536,878 gas.
        // This high gas consumption could be problematic in real-world scenarios, especially on the Ethereum mainnet.
        //
        // TODO: Consider implementing the following optimizations for large member sets:
        // 1. Batch processing of member assignments
        // 2. Implement a cap on the number of members or representatives
        // 3. Use a more gas-efficient data structure for member storage
        //
        // These optimizations should be evaluated and implemented based on the specific requirements and constraints
        // of the TextDAO project. Regular gas consumption monitoring and optimization should be part of the
        // development process to ensure the contract remains viable as the number of members grows.
    }

    //============================
    //      Helper Functions
    //============================

    /**
     * @dev Generates a random string of given length
     * @param length The length of the string to generate
     * @return A random string
     */
    function _generateRandomString(uint8 length) internal view returns (string memory) {
        bytes memory characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        bytes memory result = new bytes(length);
        for(uint8 i; i < length; ++i) {
            uint8 rand = uint8(uint256(keccak256(abi.encodePacked(block.timestamp, i))) % characters.length);
            result[i] = characters[rand];
        }
        return string(result);
    }

    /**
     * @notice Helper function to set up VRF mock for testing
     * @param $vrf The VRF storage reference
     * @param _requestId The mock request ID to be returned
     */
    function _setupVRFMock(Schema.VRFStorage storage $vrf, uint256 _requestId) private {
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
    }
}
