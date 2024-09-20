// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textdao/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
// Interface
import {ISaveText} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";

/**
 * @title SaveTextProtected
 * @dev Handles C(R)UD operations for text storage in TextDAO
 * @custom:version 0.1.0
 */
contract SaveTextProtected is ISaveText, ProtectionBase {
    /**
     * @notice Creates a new text entry
     * @param pid Proposal ID
     * @param metadataCid Metadata Cid for the text
     * @return textId The ID of the newly created text
     */
    function createText(uint256 pid, string memory metadataCid) external protected(pid) returns (uint256 textId) {
        if (bytes(metadataCid).length == 0) revert TextDAOErrors.TextMetadataCidIsRequired();

        textId = Storage.Texts().texts.length;
        Storage.Texts().texts.push().metadataCid = metadataCid;
        emit TextDAOEvents.TextCreatedByProposal(pid, textId, metadataCid);
    }

    /**
     * @notice Updates an existing text entry
     * @param pid Proposal ID
     * @param textId ID of the text to update
     * @param newMetadataCid New metadata Cid for the text
     */
    function updateText(uint256 pid, uint256 textId, string memory newMetadataCid) external protected(pid) {
        if (textId >= Storage.Texts().texts.length) revert TextDAOErrors.TextNotFound(textId);
        if (bytes(newMetadataCid).length == 0) revert TextDAOErrors.TextMetadataCidIsRequired();

        Storage.Texts().texts[textId].metadataCid = newMetadataCid;
        emit TextDAOEvents.TextUpdatedByProposal(pid, textId, newMetadataCid);
    }

    /**
     * @notice Deletes an existing text entry
     * @param pid Proposal ID
     * @param textId ID of the text to delete
     */
    function deleteText(uint256 pid, uint256 textId) external protected(pid) {
        if (textId >= Storage.Texts().texts.length) revert TextDAOErrors.TextNotFound(textId);

        delete Storage.Texts().texts[textId];
        emit TextDAOEvents.TextDeletedByProposal(pid, textId);
    }
}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textdao/utils/CommandLib.sol";

/**
 * @title SaveTextProtectedTest
 * @dev Test suite for the SaveTextProtected contract
 */
contract SaveTextProtectedTest is MCTest {
    using DeliberationLib for Schema.Deliberation;
    using CommandLib for Schema.Command;

    function setUp() public {
        _use(SaveTextProtected.createText.selector, address(new SaveTextProtected()));
        _use(SaveTextProtected.updateText.selector, address(new SaveTextProtected()));
        _use(SaveTextProtected.deleteText.selector, address(new SaveTextProtected()));
    }

    /**
     * @dev Helper function to set up the protected environment for creating a text
     * @param metadataCid The metadata Cid for the text to be created
     * @return pid The proposal ID for the created environment
     */
    function _setupCreateTextProtectedEnv(string memory metadataCid) internal returns (uint pid) {
        pid = Storage.Deliberation().proposals.length;
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.cmds.push().createCreateTextAction({
            pid: pid,
            metadataCid: metadataCid
        });
        $proposal.meta.approvedCommandId = 1;
        $proposal.meta.actionStatuses[0] = (Schema.ActionStatus.Approved);
    }

    /**
     * @dev Helper function to set up the protected environment for updating a text
     * @param textId The ID of the text to be updated
     * @param metadataCid The new metadata Cid for the text
     * @return pid The proposal ID for the created environment
     */
    function _setupUpdateTextProtectedEnv(uint textId, string memory metadataCid) internal returns (uint pid) {
        pid = Storage.Deliberation().proposals.length;
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.cmds.push().createUpdateTextAction({
            pid: pid,
            textId: textId,
            metadataCid: metadataCid
        });
        $proposal.meta.approvedCommandId = 1;
        $proposal.meta.actionStatuses[0] = (Schema.ActionStatus.Approved);
    }

    /**
     * @dev Helper function to set up the protected environment for deleting a text
     * @param textId The ID of the text to be deleted
     * @return pid The proposal ID for the created environment
     */
    function _setupDeleteTextProtectedEnv(uint textId) internal returns (uint pid) {
        pid = Storage.Deliberation().proposals.length;
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.cmds.push().createDeleteTextAction({
            pid: pid,
            textId: textId
        });
        $proposal.meta.approvedCommandId = 1;
        $proposal.meta.actionStatuses[0] = (Schema.ActionStatus.Approved);
    }

    /**
     * @dev Test successful text creation
     */
    function test_createText_success() public {
        string memory metadataCid = "ipfs://test1";
        uint256 pid = _setupCreateTextProtectedEnv(metadataCid);

        uint256 textId = SaveTextProtected(target).createText(pid, metadataCid);

        assertEq(textId, 0, "First text should have ID 0");
        assertEq(Storage.Texts().texts.length, 1, "Texts array should have one entry");
        assertEq(Storage.Texts().texts[0].metadataCid, "ipfs://test1", "MetadataCid should match");
    }

    /**
     * @dev Test text creation with empty metadata Cid (should revert)
     */
    function test_createText_revert_emptyMetadataCid() public {
        uint256 pid = _setupCreateTextProtectedEnv("");

        vm.expectRevert(TextDAOErrors.TextMetadataCidIsRequired.selector);
        SaveTextProtected(target).createText(pid, "");
    }

    /**
     * @dev Test successful text update
     */
    function test_updateText_success() public {
        string memory initialMetadataCid = "ipfs://initial";
        uint256 createPid = _setupCreateTextProtectedEnv(initialMetadataCid);
        uint256 textId = SaveTextProtected(target).createText(createPid, initialMetadataCid);

        string memory updatedMetadataCid = "ipfs://updated";
        uint256 updatePid = _setupUpdateTextProtectedEnv(textId, updatedMetadataCid);
        SaveTextProtected(target).updateText(updatePid, textId, updatedMetadataCid);

        assertEq(Storage.Texts().texts[textId].metadataCid, "ipfs://updated", "MetadataCid should be updated");
    }

    /**
     * @dev Test text update with non-existent text ID (should revert)
     */
    function test_updateText_revert_textNotFound() public {
        uint256 pid = _setupUpdateTextProtectedEnv(999, "ipfs://test");

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.TextNotFound.selector, 999));
        SaveTextProtected(target).updateText(pid, 999, "ipfs://test");
    }

    /**
     * @dev Test text update with empty metadata Cid (should revert)
     */
    function test_updateText_revert_emptyMetadataCid() public {
        string memory initialMetadataCid = "ipfs://initial";
        uint256 createPid = _setupCreateTextProtectedEnv(initialMetadataCid);
        uint256 textId = SaveTextProtected(target).createText(createPid, initialMetadataCid);

        uint256 updatePid = _setupUpdateTextProtectedEnv(textId, "");
        vm.expectRevert(TextDAOErrors.TextMetadataCidIsRequired.selector);
        SaveTextProtected(target).updateText(updatePid, textId, "");
    }

    /**
     * @dev Test successful text deletion
     */
    function test_deleteText_success() public {
        string memory metadataCid = "ipfs://test";
        uint256 createPid = _setupCreateTextProtectedEnv(metadataCid);
        uint256 textId = SaveTextProtected(target).createText(createPid, metadataCid);

        uint256 deletePid = _setupDeleteTextProtectedEnv(textId);
        SaveTextProtected(target).deleteText(deletePid, textId);

        assertEq(Storage.Texts().texts[textId].metadataCid, "", "Text metadata should be empty after deletion");
    }

    /**
     * @dev Test text deletion with non-existent text ID (should revert)
     */
    function test_deleteText_revert_textNotFound() public {
        uint256 pid = _setupDeleteTextProtectedEnv(999);

        vm.expectRevert(abi.encodeWithSelector(TextDAOErrors.TextNotFound.selector, 999));
        SaveTextProtected(target).deleteText(pid, 999);
    }
}
