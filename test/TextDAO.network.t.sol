// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {MCTest, console2, StdChains} from "@devkit/Flattened.sol";

// import {TestUtils} from "test/fixtures/TestUtils.sol";

// import {DeployLib} from "script/deployment/DeployLib.sol";
// import {ITextDAO, Schema} from "bundle/textDAO/interfaces/ITextDAO.sol";
// import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
// import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
// import {RawFulfillRandomWords} from "bundle/textDAO/functions/onlyVrfCoordinator/RawFulfillRandomWords.sol";

// import {IPropose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
// import {Types} from "bundle/textDAO/storages/Types.sol";
// import {VRFCoordinatorV2Interface} from "@chainlink/vrf/interfaces/VRFCoordinatorV2Interface.sol";

// /**
//  * @title TextDAO Multi-Network Simulation
//  * @dev This contract provides comprehensive tests for TextDAO across multiple networks.
//  * It includes scenarios for full lifecycle testing and VRF integration.
//  */
// contract TextDAOMultiNetworkSimulation is MCTest {
//     ITextDAO public textDAO;
//     address public constant MEMBER1 = address(0x1234);
//     address public constant MEMBER2 = address(0x2345);
//     address public constant MEMBER3 = address(0x3456);
//     address public constant NON_MEMBER = address(0x4567);
//     address public constant VRF_COORDINATOR = address(0x5678);

//     /**
//      * @dev Struct to hold network configuration details
//      * @param name Name of the network
//      * @param chainId Chain ID of the network
//      * @param rpcUrl RPC URL for the network
//      * @param forkBlock Block number to fork from (for non-Anvil networks)
//      */
//     struct NetworkConfig {
//         string name;
//         uint256 chainId;
//         string rpcUrl;
//         uint256 forkBlock;
//     }

//     NetworkConfig[] public networks;

//     function _addNetwork(string memory name, uint256 forkBlock) internal {
//         StdChains.Chain memory chain = getChain(name);
//         networks.push(NetworkConfig(chain.name, chain.chainId, chain.rpcUrl, forkBlock));
//     }

//     /**
//      * @dev Constructor to initialize network configurations
//      */
//     constructor() {
//         _addNetwork("mainnet", 15_000_000);
//         _addNetwork("anvil", 0);
//     }

//     /**
//      * @dev Test the full lifecycle of a proposal in TextDAO
//      */
//     function testFullLifecycleScenario() public {
//         for (uint i; i < networks.length; ++i) {
//             NetworkConfig memory _config = networks[i];

//             _setupNetwork(_config);
//             console2.log("Testing on", _config.name, "at block", block.number);

//             _getOrDeployTextDAO(_config.chainId);

//             _initializeTextDAO();
//             uint256 _pid = _createProposal();
//             _forkProposal(_pid);
//             _voteOnProposal(_pid);
//             _tallyAndExecuteProposal(_pid);

//             // Additional assertions can be added here to verify the final state
//         }
//     }

//     /**
//      * @dev Test the VRF integration in TextDAO
//      * @param networkIndex Index of the network configuration to use
//      */
//     function testVRFIntegration(uint256 networkIndex) public {
//         vm.assume(networkIndex < networks.length);
//         NetworkConfig memory _config = networks[networkIndex];

//         _setupNetwork(_config);
//         console2.log("Testing VRF integration on", _config.name, "at block", block.number);

//         _getOrDeployTextDAO(_config.chainId);

//         _initializeTextDAO();
//         _setupVRFConfig();

//         uint256 _pid = _createVRFProposal();
//         _simulateVRFResponse(_pid);

//         // Add assertions here to verify VRF integration results
//     }

//     /**
//      * @dev Setup the network for testing
//      * @param config Network configuration to use
//      */
//     function _setupNetwork(NetworkConfig memory config) internal {
//         if (config.forkBlock == 0) {
//             vm.createSelectFork(config.rpcUrl);
//         } else {
//             vm.createSelectFork(config.rpcUrl, config.forkBlock);
//         }
//     }

//     /**
//      * @dev Get or deploy TextDAO contract
//      * @param chainId Chain ID of the network
//      */
//     function _getOrDeployTextDAO(uint256 chainId) internal {
//         string memory _envKey = string.concat("TEXT_DAO_ADDR_", vm.toString(chainId));
//         address _textDAOAddr = vm.envOr(_envKey, address(0));
//         if (_textDAOAddr.code.length > 0) {
//             textDAO = ITextDAO(_textDAOAddr);
//         } else {
//             textDAO = ITextDAO(DeployLib.deployTextDAO(mc));
//         }
//     }

//     /**
//      * @dev Initialize TextDAO with initial members and configuration
//      */
//     function _initializeTextDAO() internal {
//         Schema.Member[] memory initialMembers = new Schema.Member[](3);
//         initialMembers[0] = Schema.Member({addr: MEMBER1, metadataURI: "member1URI"});
//         initialMembers[1] = Schema.Member({addr: MEMBER2, metadataURI: "member2URI"});
//         initialMembers[2] = Schema.Member({addr: MEMBER3, metadataURI: "member3URI"});

//         Schema.DeliberationConfig memory deliberationConfig = Schema.DeliberationConfig({
//             expiryDuration: 7 days,
//             snapInterval: 2 hours,
//             repsNum: 5,
//             quorumScore: 2
//         });

//         try textDAO.initialize(initialMembers, deliberationConfig) {
//             console2.log("TextDAO initialized successfully");
//         } catch {
//             console2.log("Initialization failed but skipped (TextDAO might be already initialized)");
//         }
//     }

//     /**
//      * @dev Create a new proposal in TextDAO
//      * @return _pid ID of the created proposal
//      */
//     function _createProposal() internal returns (uint256 _pid) {
//         vm.prank(MEMBER1); // TODO get from storage to impersonate
//         string memory _headerMetadataURI = "Proposal for new feature";
//         Schema.Action[] memory _actions = new Schema.Action[](1);
//         _actions[0] = Schema.Action({
//             funcSig: "memberJoin(uint256,(address,string)[])",
//             abiParams: abi.encode(0, new Schema.Member[](1))
//         });
//         _pid = textDAO.propose(_headerMetadataURI, _actions);
//         console2.log("Proposal created with ID:", _pid);
//     }

//     /**
//      * @dev Fork an existing proposal
//      * @param _pid ID of the proposal to fork
//      */
//     function _forkProposal(uint256 _pid) internal {
//         vm.prank(MEMBER2);
//         string memory _headerMetadataURI = "Forked proposal";
//         Schema.Action[] memory _actions = new Schema.Action[](1);
//         _actions[0] = Schema.Action({
//             funcSig: "memberJoin(uint256,(address,string)[])",
//             abiParams: abi.encode(0, new Schema.Member[](1))
//         });
//         textDAO.fork(_pid, _headerMetadataURI, _actions);
//         console2.log("Proposal forked");
//     }

//     /**
//      * @dev Cast votes on a proposal
//      * @param _pid ID of the proposal to vote on
//      */
//     function _voteOnProposal(uint256 _pid) internal {
//         vm.prank(MEMBER1);
//         Schema.Vote memory _vote1 = Schema.Vote({
//             rankedHeaderIds: [uint(1), 2, 0],
//             rankedCommandIds: [uint(1), 0, 0]
//         });
//         textDAO.vote(_pid, _vote1);
//         console2.log("MEMBER1 voted");

//         vm.prank(MEMBER2);
//         Schema.Vote memory _vote2 = Schema.Vote({
//             rankedHeaderIds: [uint(2), 1, 0],
//             rankedCommandIds: [uint(1), 0, 0]
//         });
//         textDAO.vote(_pid, _vote2);
//         console2.log("MEMBER2 voted");
//     }

//     /**
//      * @dev Tally votes and execute the proposal
//      * @param _pid ID of the proposal to tally and execute
//      */
//     function _tallyAndExecuteProposal(uint256 _pid) internal {
//         vm.warp(block.timestamp + 8 days); // Advance time past the expiry duration

//         textDAO.tally(_pid);
//         console2.log("Votes tallied");

//         textDAO.execute(_pid);
//         console2.log("Proposal executed");
//     }

//     /**
//      * @dev Setup VRF configuration for testing
//      */
//     function _setupVRFConfig() internal {
//         Schema.VRFConfig memory vrfConfig = Schema.VRFConfig({
//             vrfCoordinator: VRF_COORDINATOR,
//             keyHash: bytes32(uint256(1)),
//             callbackGasLimit: 100000,
//             requestConfirmations: 3,
//             numWords: 1,
//             LINKTOKEN: address(0x1234)
//         });
//         // Apply VRF configuration (implementation depends on TextDAO structure)
//     }

//     /**
//      * @dev Create a proposal that triggers a VRF request
//      * @return _pid ID of the created proposal
//      */
//     function _createVRFProposal() internal returns (uint256 _pid) {
//         vm.prank(MEMBER1);
//         string memory _headerMetadataURI = "VRF Test Proposal";
//         Schema.Action[] memory _actions = new Schema.Action[](0);
//         _pid = textDAO.propose(_headerMetadataURI, _actions);
//         console2.log("VRF test proposal created with ID:", _pid);
//     }

//     /**
//      * @dev Simulate VRF response
//      * @param _pid ID of the proposal associated with the VRF request
//      */
//     function _simulateVRFResponse(uint256 _pid) internal {
//         uint256 _requestId = 100;
//         vm.mockCall(
//             VRF_COORDINATOR,
//             abi.encodeCall(
//                 VRFCoordinatorV2Interface.requestRandomWords,
//                 (
//                     bytes32(uint256(1)), // keyHash
//                     1, // subId
//                     3, // requestConfirmations
//                     100000, // callbackGasLimit
//                     1 // numWords
//                 )
//             ),
//             abi.encode(_requestId)
//         );

//         uint256[] memory _randomWords = new uint256[](1);
//         _randomWords[0] = 12345;
//         vm.prank(VRF_COORDINATOR);
//         RawFulfillRandomWords(target).rawFulfillRandomWords(_requestId, _randomWords);

//         console2.log("VRF response simulated");
//     }

//     // function test_scenario() public {
//     //     Schema.Member[] memory initialMembers = new Schema.Member[](1);
//     //     initialMembers[0].addr = address(this); // Example initial member address
//     //     try textDAO.initialize(initialMembers, Schema.DeliberationConfig({
//     //         expiryDuration: 2 minutes,
//     //         snapInterval: 1 minutes,
//     //         repsNum: 1,
//     //         quorumScore: 3
//     //     })) {} catch {
//     //         console2.log("Initialization failed but skipped.");
//     //     }


//     //     vm.warp(block.timestamp + 20);


//     //     // Schema.ProposalMeta memory proposalMeta = Schema.ProposalMeta({
//     //     //     currentScore: 0,
//     //     //     headerRank: new uint[](0),
//     //     //     cmdRank: new uint[](0),
//     //     //     nextHeaderTallyFrom: 0,
//     //     //     nextCmdTallyFrom: 0,
//     //     //     reps: new address[](1),
//     //     //     createdAt: block.timestamp,
//     //     //     expirationTime: block.timestamp + 2 minutes,
//     //     //     vrfRequestId: 0
//     //     // });
//     //     // proposalMeta.reps[0] = address(this);
//     //     IPropose.ProposeArgs memory _proposeArgs = IPropose.ProposeArgs({
//     //         headerMetadataURI: "Implement MemberJoinProtected",
//     //         actions: new Schema.Action[](1)
//     //     });

//     //     uint plannedProposalId = 0;
//     //     Schema.Member[] memory candidates = new Schema.Member[](1); // Assuming there's one candidate for demonstration
//     //     candidates[0] = Schema.Member({
//     //         addr: 0x1234567890123456789012345678901234567890, // Example candidate address
//     //         metadataURI: "exampleURI" // Example metadata URI
//     //     });

//     //     _proposeArgs.actions[0] = Schema.Action({
//     //         funcSig: "memberJoin(uint256,(address,string)[])",
//     //         abiParams: abi.encode(plannedProposalId, candidates)
//     //     });
//     //     uint _pid = textDAO.propose(_proposeArgs);
//     //     require(plannedProposalId == _pid, "Proposal IDs do not match");


//     //     vm.warp(block.timestamp + 20);


//     //     uint[3] memory cmdIds = [uint(0), uint(1), uint(2)]; // Example cmdIds, replace with actual command IDs
//     //     // textDAO.voteCmds(_pid, cmdIds);

//     // }

// }
