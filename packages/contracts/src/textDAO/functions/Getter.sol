// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// // Storage
// import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";

// // External getter functions
// contract Getter {
//     struct ProposalInfo {
//         Schema.ProposalMeta proposalMeta;
//         uint256 headersLength;
//         uint256 cmdsLength;
//     }
//     function getProposal(uint id) external view returns (ProposalInfo memory) {
//         Schema.Proposal storage proposal = Storage.Deliberation().proposals[id];
//         return ProposalInfo({
//             headersLength: proposal.headers.length,
//             cmdsLength: proposal.cmds.length,
//             proposalMeta: proposal.meta
//         });
//     }

//     function getProposalHeaders(uint pid) external view returns(Schema.Header[] memory) {
//         return Storage.Deliberation().proposals[pid].headers;
//     }

//     // function getProposalCommand(uint pid, uint cid) external view returns(Schema.Command memory) {
//     //     return Storage.Deliberation().proposals[pid].cmds[cid];
//     // }

//     function getProposalsConfig() external view returns (Schema.DeliberationConfig memory) {
//         return Storage.Deliberation().config;
//     }

//     function getText(uint id) external view returns (Schema.Text memory) {
//         return Storage.Texts().texts[id];
//     }

//     function getTexts() external view returns (Schema.Text[] memory) {
//         return Storage.Texts().texts;
//     }

//     function getMember(uint memberId) external view returns (Schema.Member memory) {
//         return Storage.Members().members[memberId];
//     }

//     function getMembers() external view returns (Schema.Member[] memory) {
//         return Storage.Members().members;
//     }

//     // function getVRFRequest(uint id) external view returns (Schema.Request memory) {
//     //     return Storage.$VRF().requests[id];
//     // }

//     // function getNextVRFId() external view returns (uint) {
//     //     return Storage.$VRF().nextId;
//     // }

//     function getSubscriptionId() external view returns (uint64) {
//         return Storage.$VRF().subscriptionId;
//     }

//     function getVRFConfig() external view returns (Schema.VRFConfig memory) {
//         return Storage.$VRF().config;
//     }

//     function getConfigOverride(bytes4 sig) external view returns (Schema.ConfigOverride memory) {
//         return Storage.$ConfigOverride().overrides[sig];
//     }
// }


// import {MCTest, console2} from "@devkit/Flattened.sol";

// import {Getter} from "bundle/textDAO/functions/Getter.sol";
// import {Storage} from "bundle/textDAO/storages/Storage.sol";
// import {Schema} from "bundle/textDAO/storages/Schema.sol";

// contract GetterTest is MCTest {

//     function setUp() public {
//         address getter = address(new Getter());
//         _use(Getter.getProposal.selector, getter);
//         _use(Getter.getProposalHeaders.selector, getter);
//         // _use(Getter.getProposalCommand.selector, getter);
//         _use(Getter.getProposalsConfig.selector, getter);
//         _use(Getter.getText.selector, getter);
//         _use(Getter.getTexts.selector, getter);
//         _use(Getter.getMember.selector, getter);
//         _use(Getter.getMembers.selector, getter);
//         // _use(Getter.getVRFRequest.selector, getter);
//         // _use(Getter.getNextVRFId.selector, getter);
//         _use(Getter.getSubscriptionId.selector, getter);
//         _use(Getter.getVRFConfig.selector, getter);
//         _use(Getter.getConfigOverride.selector, getter);
//     }

//     function test_Proposals_success() public {
//         Schema.Deliberation storage $ = Storage.Deliberation();
//         $.proposals.push();
//         Schema.Proposal storage $proposal = $.proposals.push();
//         $proposal.headers.push();
//         $proposal.cmds.push().actions.push();
//         $proposal.meta.currentScore = 1;
//         $.config.expiryDuration = 1;

//         Getter.ProposalInfo memory proposalInfo = Getter(address(this)).getProposal(1);
//         assertEq(proposalInfo.meta.currentScore, 1);

//         Schema.Header[] memory headers = Getter(address(this)).getProposalHeaders(1);
//         assertEq(headers.length, 1);

//         // Schema.Command memory cmd = Getter(address(this)).getProposalCommand(1, 0);
//         // assertEq(cmd.actions.length, 1);

//         Schema.DeliberationConfig memory resProposalsConfig = Getter(address(this)).getProposalsConfig();
//         assertEq(resProposalsConfig.expiryDuration, 1);
//     }

//     function test_Texts_success() public {
//         Schema.Texts storage $ = Storage.Texts();

//         string[] memory _metadataCids = new string[](2);
//         _metadataCids[0] = "pseudo metadata";
//         _metadataCids[1] = "metadata2";
//         $.texts.push().metadataCids = _metadataCids;

//         Schema.Text memory _resText = Getter(target).getText(0);
//         assertEq(
//             keccak256(abi.encode(_resText.metadataCids)),
//             keccak256(abi.encode(_metadataCids))
//         );

//         Schema.Text[] memory _resTexts = Getter(target).getTexts();
//         assertEq(_resTexts.length, 1);
//     }

//     function test_Members_success() public {
//         Schema.Members storage $ = Storage.Members();

//         string memory _metadata = "pseudo metadata";
//         $.members.push().metadataCid = _metadata;

//         Schema.Member memory resMember = Getter(address(this)).getMember(0);
//         assertEq(
//             keccak256(abi.encode(resMember.metadataCid)),
//             keccak256(abi.encode(_metadata))
//         );

//         Schema.Member[] memory _members = Getter(address(this)).getMembers();
//         assertEq(_members.length, 1);
//     }

//     function test_VRF_success() public {
//         Schema.VRFStorage storage $ = Storage.$VRF();

//         // $.requests[1].requestId = 1;
//         // $.nextId = 1;
//         $.subscriptionId = 1;
//         $.config.vrfCoordinator = address(1);

//         // Schema.Request memory resRequest = Getter(address(this)).getVRFRequest(1);
//         // assertEq(resRequest.requestId, 1);

//         // uint resNextVRFId = Getter(address(this)).getNextVRFId();
//         // assertEq(resNextVRFId, 1);

//         uint resSubscriptionIdId = Getter(address(this)).getSubscriptionId();
//         assertEq(resSubscriptionIdId, 1);

//         Schema.VRFConfig memory resVRFConfig = Getter(address(this)).getVRFConfig();
//         assertEq(resVRFConfig.vrfCoordinator, address(1));
//     }

//     function test_ConfigOverride_success() public {
//         Schema.ConfigOverrideStorage storage $ = Storage.$ConfigOverride();

//         $.overrides[bytes4(uint32(1))].quorumScore = 1;

//         Schema.ConfigOverride memory resConfigOverride = Getter(address(this)).getConfigOverride(bytes4(uint32(1)));
//         assertEq(resConfigOverride.quorumScore, 1);
//     }
// }
