// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textDAO/utils/ProposalLib.sol";
import {RCVLib} from "bundle/textDAO/utils/RCVLib.sol";

contract OnlyAdminCheats {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;
    using RCVLib for Schema.Proposal;
    using RCVLib for uint[];

    modifier onlyAdmin() {
        require(Storage.Members().members[0].addr == msg.sender, "You are not the admin");
        _;
    }

    function addMembers(address[] memory newMembers) external onlyAdmin {
        for (uint i; i < newMembers.length; ++i) {
            Storage.Members().members.push(Schema.Member({
                addr: newMembers[i],
                metadataURI: ""
            }));
        }
    }

    function updateConfig(Schema.DeliberationConfig calldata newConfig) external onlyAdmin {
        Storage.Deliberation().config = newConfig;
    }

    function transferAdmin(address newAdmin) external onlyAdmin {
        Storage.Members().members[0].addr = newAdmin;
    }

    function forceTally(uint pid) external onlyAdmin {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);

        (uint[] memory _headerScores, uint[] memory _commandScores) = $proposal.calcRCVScores();

        uint[] memory _topHeaderIds = _headerScores.findTopScorer();
        uint[] memory _topCommandIds = _commandScores.findTopScorer();

        // If there's a tie or no votes, extend the expiration time and emit an event
        if (_topHeaderIds.length == 0 ||    // no votes for header
            _topCommandIds.length == 0 ||   // no votes for command
            _topHeaderIds.length > 1 || // there's a tie header
            _topCommandIds.length > 1   // there's a tie command
        ) {
            $proposal.meta.expirationTime += Storage.Deliberation().config.expiryDuration;
            emit TextDAOEvents.ProposalTalliedWithTie(pid, _topHeaderIds, _topCommandIds, $proposal.meta.expirationTime);
        } else {
            // Approve the winning header and command
            $proposal.approveHeader(_topHeaderIds[0]);
            $proposal.approveCommand(_topCommandIds[0]);
            emit TextDAOEvents.ProposalTallied(pid, _topHeaderIds[0], _topCommandIds[0]);
        }
    }
}


// // Testing
// import {MCTest} from "@devkit/Flattened.sol";
// import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
// import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";
// import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

// contract MemberJoinProtectedTest is MCTest {
//     using DeliberationLib for Schema.Deliberation;
//     using CommandLib for Schema.Command;

//     function setUp() public {
//         _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
//     }

//     function test_memberJoin_success(Schema.Member[] memory candidates) public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

//         $proposal.meta.approvedCommandId = 1;
//         Schema.Command storage $cmd = $proposal.cmds.push();
//         $cmd.createMemberJoinAction(0, candidates);
//         $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

//         MemberJoinProtected(target).memberJoin({
//             pid: 0,
//             candidates: candidates
//         });

//         for (uint i; i < candidates.length; ++i) {
//             assertEq(
//                 keccak256(abi.encode(candidates[i])),
//                 keccak256(abi.encode(Storage.Members().members[i]))
//             );
//         }
//         assertEq(candidates.length, Storage.Members().members.length);
//     }

//     function test_memberJoin_revert_notApprovedYet() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
//         $proposal.meta.approvedCommandId = 1;
//         $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));

//         vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
//         MemberJoinProtected(target).memberJoin({
//             pid: 0,
//             candidates: new Schema.Member[](1)
//         });
//     }

//     function test_memberJoin_revert_notFound() public {
//         Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
//         $proposal.meta.approvedCommandId = 1;
//         $proposal.cmds.push().createMemberJoinAction(0, new Schema.Member[](1));
//         $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Executed;

//         vm.expectRevert(TextDAOErrors.ActionNotFound.selector);
//         MemberJoinProtected(target).memberJoin({
//             pid: 0,
//             candidates: new Schema.Member[](1)
//         });
//     }

// }
