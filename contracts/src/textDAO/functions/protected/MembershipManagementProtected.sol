// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {IMembershipManagement} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

/// @title MembershipManagementProtected
/// @notice Handles member addition, removal, and information updates in TextDAO
/// @dev Inherits from ProtectionBase for access control
contract MembershipManagementProtected is IMembershipManagement, ProtectionBase {
    /// @notice Ensures that the caller is the member being updated
    /// @param memberId ID of the member
    modifier onlyMeInOrg(uint memberId) {
        if (msg.sender != Storage.Members().members[memberId].addr) {
            revert TextDAOErrors.YouAreNotTheMemberSelf();
        }
        _;
    }

    /// @notice Adds new members to the DAO
    /// @param pid Proposal ID
    /// @param candidates Array of new members to be added
    /// @dev This function is protected and can only be called through an approved proposal
    function addMembers(uint pid, Schema.Member[] memory candidates) external protected(pid) {
        Schema.Member[] storage $members = Storage.Members().members;

        for (uint i; i < candidates.length; ++i) {
            uint _memberId = $members.length;
            Schema.Member memory _candidate = candidates[i];
            $members.push(_candidate);
            emit TextDAOEvents.MemberAddedByProposal(pid, _memberId, _candidate.addr, _candidate.metadataCid);
        }
    }

    /// @notice Updates information for an existing member
    /// @param memberId ID of the member to update
    /// @param newMetadataCid New metadata CID for the member
    /// @dev This function can only be called by the member themselves
    function updateMember(uint memberId, string memory newMetadataCid) external onlyMeInOrg(memberId) {
        Schema.Member storage $member = Storage.Members().members[memberId];
        $member.metadataCid = newMetadataCid;
        emit TextDAOEvents.MemberUpdated(memberId, $member.addr, newMetadataCid);
    }

    /// @notice Removes a member from the DAO
    /// @param pid Proposal ID
    /// @param memberId ID of the member to remove
    /// @dev This function is protected and can only be called through an approved proposal
    function removeMember(uint pid, uint memberId) external protected(pid) {
        Schema.Member[] storage $members = Storage.Members().members;

        address _memberAddr = $members[memberId].addr;
        if (_memberAddr == address(0)) revert TextDAOErrors.MemberNotFound(memberId);

        delete $members[memberId];

        emit TextDAOEvents.MemberRemovedByProposal(pid, memberId, _memberAddr);
    }

    /// @notice Allows a member to voluntarily leave the DAO
    /// @param memberId ID of the member who wants to leave
    /// @dev This function can only be called by the member themselves
    function leaveDAO(uint memberId) external onlyMeInOrg(memberId) {
        delete Storage.Members().members[memberId];
        emit TextDAOEvents.MemberRemoved(memberId, msg.sender);
    }
}


// Testing
import {MCTest, console2} from "@devkit/Flattened.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";

contract MembershipManagementProtectedTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        address _membershipManagement = address(new MembershipManagementProtected());
        _use(MembershipManagementProtected.addMembers.selector, _membershipManagement);
        _use(MembershipManagementProtected.updateMember.selector, _membershipManagement);
        _use(MembershipManagementProtected.removeMember.selector, _membershipManagement);
        _use(MembershipManagementProtected.leaveDAO.selector, _membershipManagement);
    }

    function test_addMembers_success(Schema.Member[] memory candidates) public {
        vm.assume(candidates.length > 0 && candidates.length <= 10);
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();

        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        vm.expectEmit(true, true, true, true);
        for (uint i; i < candidates.length; ++i) {
            emit TextDAOEvents.MemberAddedByProposal(0, i, candidates[i].addr, candidates[i].metadataCid);
        }

        MembershipManagementProtected(target).addMembers(0, candidates);

        for (uint i; i < candidates.length; ++i) {
            assertEq(
                keccak256(abi.encode(candidates[i])),
                keccak256(abi.encode(Storage.Members().members[i]))
            );
        }
        assertEq(candidates.length, Storage.Members().members.length);
    }

    function test_addMembers_revert_notApprovedYet() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        $proposal.cmds.push().createAddMembersAction(0, new Schema.Member[](1));

        vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
        MembershipManagementProtected(target).addMembers(0, new Schema.Member[](1));
    }

    function test_updateMember_success() public {
        // Setup: Add a member first
        Schema.Member memory newMember = Schema.Member({
            addr: address(0x1234),
            metadataCid: "oldURI"
        });
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = newMember;

        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        MembershipManagementProtected(target).addMembers(0, candidates);

        // Test: Update member
        string memory newMetadataCid = "newURI";
        vm.prank(address(0x1234));
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.MemberUpdated(0, address(0x1234), newMetadataCid);

        MembershipManagementProtected(target).updateMember(0, newMetadataCid);

        assertEq(Storage.Members().members[0].metadataCid, newMetadataCid);
    }

    function test_updateMember_revert_notMemberSelf() public {
        // Setup: Add a member first
        Schema.Member memory newMember = Schema.Member({
            addr: address(0x1234),
            metadataCid: "oldURI"
        });
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = newMember;

        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        MembershipManagementProtected(target).addMembers(0, candidates);

        // Test: Try to update member with wrong address
        vm.prank(address(0x5678));
        vm.expectRevert(TextDAOErrors.YouAreNotTheMemberSelf.selector);
        MembershipManagementProtected(target).updateMember(0, "newURI");
    }

    function test_removeMember_success() public {
        // Setup: Add two members
        Schema.Member[] memory candidates = new Schema.Member[](2);
        candidates[0] = Schema.Member({addr: address(0x1234), metadataCid: "URI1"});
        candidates[1] = Schema.Member({addr: address(0x5678), metadataCid: "URI2"});

        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        MembershipManagementProtected(target).addMembers(0, candidates);

        // Remove the first member
        uint _removePid = 1;
        Schema.Proposal storage $removeProposal = Storage.Deliberation().createProposal();
        $removeProposal.meta.approvedCommandId = _removePid;
        Schema.Command storage $removeCmd = $removeProposal.cmds.push();
        $removeCmd.createRemoveMemberAction(_removePid, 0);
        $removeProposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.MemberRemovedByProposal(1, 0, address(0x1234));

        MembershipManagementProtected(target).removeMember(1, 0);

        // Check that the member was removed (address set to address(0))
        Schema.Member[] storage $members = Storage.Members().members;
        assertEq($members[0].addr, address(0));
        assertEq($members[1].addr, address(0x5678));
        assertEq($members[1].metadataCid, "URI2");
    }

    function test_removeMember_revert_memberNotFound() public {
        Storage.Members().members.push();
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createRemoveMemberAction(0, 0);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.MemberNotFound.selector, 0));
        MembershipManagementProtected(target).removeMember(0, 0);
    }

    function test_removeMember_revert_notApprovedYet() public {
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        $proposal.cmds.push().createRemoveMemberAction(0, 0);

        vm.expectRevert(TextDAOErrors.ActionNotApprovedYet.selector);
        MembershipManagementProtected(target).removeMember(0, 0);
    }

    function test_leaveDAO_success() public {
        // Setup: Add a member
        Schema.Member memory newMember = Schema.Member({
            addr: address(0x1234),
            metadataCid: "testURI"
        });
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = newMember;

        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        MembershipManagementProtected(target).addMembers(0, candidates);

        // Test: Member leaves DAO
        vm.prank(address(0x1234));
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.MemberRemoved(0, address(0x1234));

        MembershipManagementProtected(target).leaveDAO(0);

        // Check that the member was removed
        Schema.Member[] storage $members = Storage.Members().members;
        assertEq($members[0].addr, address(0));
        assertEq($members[0].metadataCid, "");
    }

    function test_leaveDAO_revert_notMemberSelf() public {
        // Setup: Add a member
        Schema.Member memory newMember = Schema.Member({
            addr: address(0x1234),
            metadataCid: "testURI"
        });
        Schema.Member[] memory candidates = new Schema.Member[](1);
        candidates[0] = newMember;

        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.meta.approvedCommandId = 1;
        Schema.Command storage $cmd = $proposal.cmds.push();
        $cmd.createAddMembersAction(0, candidates);
        $proposal.meta.actionStatuses[0] = Schema.ActionStatus.Approved;

        MembershipManagementProtected(target).addMembers(0, candidates);

        // Test: Try to leave DAO as a different address
        vm.prank(address(0x5678));
        vm.expectRevert(TextDAOErrors.YouAreNotTheMemberSelf.selector);
        MembershipManagementProtected(target).leaveDAO(0);
    }
}
