// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";
// Storage
import {Storage, Schema} from "bundle/textDAO/storages/Storage.sol";
// Interface
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";

/**
 * @title SaveTextProtected
 * @dev Handles C(R)UD operations for text storage in TextDAO
 * @custom:version 0.1.0
 */
contract SaveTextProtected is ProtectionBase {
    /**
     * @notice Creates a new text entry
     * @param pid Proposal ID
     * @param metadataURI Metadata URI for the text
     * @return textId The ID of the newly created text
     */
    function createText(uint256 pid, string memory metadataURI) public protected(pid) returns (uint256 textId) {
        if (bytes(metadataURI).length == 0) revert TextDAOErrors.TextMetadataURIIsRequired();

        textId = Storage.Texts().texts.length;
        Storage.Texts().texts.push().metadataURI = metadataURI;
        emit TextDAOEvents.TextCreated(textId, metadataURI);
    }

    /**
     * @notice Updates an existing text entry
     * @param pid Proposal ID
     * @param textId ID of the text to update
     * @param newMetadataURI New metadata URI for the text
     */
    function updateText(uint256 pid, uint256 textId, string memory newMetadataURI) public protected(pid) {
        if (textId >= Storage.Texts().texts.length) revert TextDAOErrors.TextNotFound(textId);
        if (bytes(newMetadataURI).length == 0) revert TextDAOErrors.TextMetadataURIIsRequired();

        Storage.Texts().texts[textId].metadataURI = newMetadataURI;
        emit TextDAOEvents.TextUpdated(textId, newMetadataURI);
    }

    /**
     * @notice Deletes an existing text entry
     * @param pid Proposal ID
     * @param textId ID of the text to delete
     */
    function deleteText(uint256 pid, uint256 textId) public protected(pid) {
        if (textId >= Storage.Texts().texts.length) revert TextDAOErrors.TextNotFound(textId);

        delete Storage.Texts().texts[textId];
        emit TextDAOEvents.TextDeleted(textId);
    }
}


// Testing
import {MCTest} from "@devkit/Flattened.sol";
import {DeliberationLib} from "bundle/textDAO/utils/DeliberationLib.sol";
import {CommandLib} from "bundle/textDAO/utils/CommandLib.sol";

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
     * @param metadataURI The metadata URI for the text to be created
     * @return pid The proposal ID for the created environment
     */
    function _setupCreateTextProtectedEnv(string memory metadataURI) internal returns (uint pid) {
        pid = Storage.Deliberation().proposals.length;
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.cmds.push().createCreateTextAction({
            pid: pid,
            metadataURI: metadataURI
        });
        $proposal.meta.approvedCommandId = 1;
        $proposal.meta.actionStatuses[0] = (Schema.ActionStatus.Approved);
    }

    /**
     * @dev Helper function to set up the protected environment for updating a text
     * @param textId The ID of the text to be updated
     * @param metadataURI The new metadata URI for the text
     * @return pid The proposal ID for the created environment
     */
    function _setupUpdateTextProtectedEnv(uint textId, string memory metadataURI) internal returns (uint pid) {
        pid = Storage.Deliberation().proposals.length;
        Schema.Proposal storage $proposal = Storage.Deliberation().createProposal();
        $proposal.cmds.push().createUpdateTextAction({
            pid: pid,
            textId: textId,
            metadataURI: metadataURI
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
        string memory metadataURI = "ipfs://test1";
        uint256 pid = _setupCreateTextProtectedEnv(metadataURI);

        uint256 textId = SaveTextProtected(target).createText(pid, metadataURI);

        assertEq(textId, 0, "First text should have ID 0");
        assertEq(Storage.Texts().texts.length, 1, "Texts array should have one entry");
        assertEq(Storage.Texts().texts[0].metadataURI, "ipfs://test1", "MetadataURI should match");
    }

    /**
     * @dev Test text creation with empty metadata URI (should revert)
     */
    function test_createText_revert_emptyMetadataURI() public {
        uint256 pid = _setupCreateTextProtectedEnv("");

        vm.expectRevert(TextDAOErrors.TextMetadataURIIsRequired.selector);
        SaveTextProtected(target).createText(pid, "");
    }

    /**
     * @dev Test successful text update
     */
    function test_updateText_success() public {
        string memory initialMetadataURI = "ipfs://initial";
        uint256 createPid = _setupCreateTextProtectedEnv(initialMetadataURI);
        uint256 textId = SaveTextProtected(target).createText(createPid, initialMetadataURI);

        string memory updatedMetadataURI = "ipfs://updated";
        uint256 updatePid = _setupUpdateTextProtectedEnv(textId, updatedMetadataURI);
        SaveTextProtected(target).updateText(updatePid, textId, updatedMetadataURI);

        assertEq(Storage.Texts().texts[textId].metadataURI, "ipfs://updated", "MetadataURI should be updated");
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
     * @dev Test text update with empty metadata URI (should revert)
     */
    function test_updateText_revert_emptyMetadataURI() public {
        string memory initialMetadataURI = "ipfs://initial";
        uint256 createPid = _setupCreateTextProtectedEnv(initialMetadataURI);
        uint256 textId = SaveTextProtected(target).createText(createPid, initialMetadataURI);

        uint256 updatePid = _setupUpdateTextProtectedEnv(textId, "");
        vm.expectRevert(TextDAOErrors.TextMetadataURIIsRequired.selector);
        SaveTextProtected(target).updateText(updatePid, textId, "");
    }

    /**
     * @dev Test successful text deletion
     */
    function test_deleteText_success() public {
        string memory metadataURI = "ipfs://test";
        uint256 createPid = _setupCreateTextProtectedEnv(metadataURI);
        uint256 textId = SaveTextProtected(target).createText(createPid, metadataURI);

        uint256 deletePid = _setupDeleteTextProtectedEnv(textId);
        SaveTextProtected(target).deleteText(deletePid, textId);

        assertEq(Storage.Texts().texts[textId].metadataURI, "", "Text metadata should be empty after deletion");
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
