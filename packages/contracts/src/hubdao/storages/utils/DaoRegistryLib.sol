// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title DaoRegistryLib v0.1.0
 * @dev Library for managing DAO info registrations.
 */
library DaoRegistryLib {
    /**
     * @dev Registers a new TextDAO in the DAO registry.
     * @param $daoRegistry The DAO registry to register the DAO in.
     * @param textDAO The address of the TextDAO.
     * @param metadataCid The metadata CID associated with the DAO.
     * @notice Emits a DaoRegistered event on success.
     * @dev Reverts with HubDAOErrors.DaoAlreadyRegistered if the DAO is already registered.
     */
    function registerTextDAO(Schema.DaoRegistry storage $daoRegistry, address textDAO, string memory metadataCid) internal {
        if ($daoRegistry.daoInfos[textDAO].addr != address(0)) revert HubDAOErrors.DaoAlreadyRegistered(textDAO);
        Schema.DaoInfo memory _daoInfo = Schema.DaoInfo({
            addr: textDAO,
            daoType: Schema.TemplateType.TextDAO,
            metadataCid: metadataCid
        });
        $daoRegistry.daoInfos[textDAO] = _daoInfo;
        emit HubDAOEvents.DaoRegistered(_daoInfo);
    }

    /**
     * @dev Updates an existing TextDAO in the DAO registry.
     * @param $daoRegistry The DAO registry to update the DAO in.
     * @param daoInfo The updated DAO information.
     * @notice Emits a DaoInfoUpdated event on success.
     * @dev Reverts with HubDAOErrors.DaoNotFound if the DAO does not exist.
     */
    function updateTextDAO(Schema.DaoRegistry storage $daoRegistry, Schema.DaoInfo memory daoInfo) internal {
        if ($daoRegistry.daoInfos[daoInfo.addr].addr == address(0)) revert HubDAOErrors.DaoNotFound(daoInfo.addr);
        $daoRegistry.daoInfos[daoInfo.addr] = daoInfo;
        emit HubDAOEvents.DaoInfoUpdated(daoInfo);
    }

    /**
     * @dev Deletes an existing TextDAO from the DAO registry.
     * @param $daoRegistry The DAO registry to delete the DAO from.
     * @param daoInfo The DAO information to delete.
     * @notice Emits a DaoInfoDeleted event on success.
     * @dev Reverts with HubDAOErrors.DaoNotFound if the DAO does not exist.
     */
    function deleteTextDAO(Schema.DaoRegistry storage $daoRegistry, Schema.DaoInfo memory daoInfo) internal {
        if ($daoRegistry.daoInfos[daoInfo.addr].addr == address(0)) revert HubDAOErrors.DaoNotFound(daoInfo.addr);
        delete $daoRegistry.daoInfos[daoInfo.addr];
        emit HubDAOEvents.DaoInfoDeleted(daoInfo.addr);
    }

    /**
     * @dev Registers a new TextDAO with cheats in the DAO registry.
     * @param $daoRegistry The DAO registry to register the DAO in.
     * @param textDAOWithCheats The address of the TextDAO with cheats.
     * @param metadataCid The metadata CID associated with the DAO.
     * @notice Emits a DaoRegistered event on success.
     * @dev Reverts with HubDAOErrors.DaoAlreadyRegistered if the DAO is already registered.
     */
    function registerTextDAOWithCheats(Schema.DaoRegistry storage $daoRegistry, address textDAOWithCheats, string memory metadataCid) internal {
        if ($daoRegistry.daoInfos[textDAOWithCheats].addr != address(0)) revert HubDAOErrors.DaoAlreadyRegistered(textDAOWithCheats);
        Schema.DaoInfo memory _daoInfo = Schema.DaoInfo({
            addr: textDAOWithCheats,
            daoType: Schema.TemplateType.TextDAOWithCheats,
            metadataCid: metadataCid
        });
        $daoRegistry.daoInfos[textDAOWithCheats] = _daoInfo;
        emit HubDAOEvents.DaoRegistered(_daoInfo);
    }

    /**
     * @dev Updates an existing TextDAO with cheats in the DAO registry.
     * @param $daoRegistry The DAO registry to update the DAO in.
     * @param daoInfo The updated DAO information.
     * @notice Emits a DaoInfoUpdated event on success.
     * @dev Reverts with HubDAOErrors.DaoNotFound if the DAO does not exist.
     */
    function updateTextDAOWithCheats(Schema.DaoRegistry storage $daoRegistry, Schema.DaoInfo memory daoInfo) internal {
        if ($daoRegistry.daoInfos[daoInfo.addr].addr == address(0)) revert HubDAOErrors.DaoNotFound(daoInfo.addr);
        $daoRegistry.daoInfos[daoInfo.addr] = daoInfo;
        emit HubDAOEvents.DaoInfoUpdated(daoInfo);
    }

    /**
     * @dev Deletes an existing TextDAO with cheats from the DAO registry.
     * @param $daoRegistry The DAO registry to delete the DAO from.
     * @param daoInfo The DAO information to delete.
     * @notice Emits a DaoInfoDeleted event on success.
     * @dev Reverts with HubDAOErrors.DaoNotFound if the DAO does not exist.
     */
    function deleteTextDAOWithCheats(Schema.DaoRegistry storage $daoRegistry, Schema.DaoInfo memory daoInfo) internal {
        if ($daoRegistry.daoInfos[daoInfo.addr].addr == address(0)) revert HubDAOErrors.DaoNotFound(daoInfo.addr);
        delete $daoRegistry.daoInfos[daoInfo.addr];
        emit HubDAOEvents.DaoInfoDeleted(daoInfo.addr);
    }
}

// Testing
import {Test} from "forge-std/Test.sol";

contract DaoRegistryLibTest is Test {
    using DaoRegistryLib for Schema.DaoRegistry;

    Schema.DaoRegistry private $daoRegistry;

    function setUp() public {} // No setup required for this library test

    function test_registerTextDAO_success() public {
        address _textDAO = address(0x1234);
        string memory _metadataCid = "testCid";

        // Expect the DaoRegistered event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoRegistered(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAO,
            addr: _textDAO,
            metadataCid: _metadataCid
        }));
        // Register the TextDAO
        $daoRegistry.registerTextDAO(_textDAO, _metadataCid);

        // Assert that the DAO is registered correctly
        assertEq($daoRegistry.daoInfos[_textDAO].addr, _textDAO, "The DAO address should match.");
        assertEq($daoRegistry.daoInfos[_textDAO].metadataCid, _metadataCid, "The metadata CID should match.");
    }

    function test_registerTextDAO_success_emptyAddressAndMetadataCid() public {
        address _emptyAddress = address(0);
        string memory _emptyMetadataCid = "";

        $daoRegistry.registerTextDAO(_emptyAddress, _emptyMetadataCid);

        // Assert that the DAO is registered correctly
        assertEq($daoRegistry.daoInfos[_emptyAddress].addr, _emptyAddress, "The DAO address should match.");
        assertEq($daoRegistry.daoInfos[_emptyAddress].metadataCid, _emptyMetadataCid, "The metadata CID should match.");
    }

    function test_registerTextDAO_revert_alreadyRegistered() public {
        address textDAO = address(0x1234);
        string memory metadataCid = "testCid";

        // First registration should succeed
        $daoRegistry.registerTextDAO(textDAO, metadataCid);

        // Expect a revert when trying to register the same DAO again
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoAlreadyRegistered.selector, textDAO));
        $daoRegistry.registerTextDAO(textDAO, metadataCid);
    }

    function test_updateTextDAO_success() public {
        address _textDAO = address(0x1234);
        string memory _metadataCid = "updatedCid";

        // Register the TextDAO first
        $daoRegistry.registerTextDAO(_textDAO, "initialCid");

        // Expect the DaoInfoUpdated event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoInfoUpdated(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAO,
            addr: _textDAO,
            metadataCid: _metadataCid
        }));

        // Update the TextDAO
        $daoRegistry.updateTextDAO(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAO,
            addr: _textDAO,
            metadataCid: _metadataCid
        }));

        // Assert that the DAO is updated correctly
        assertEq($daoRegistry.daoInfos[_textDAO].metadataCid, _metadataCid, "The metadata CID should match.");
    }

    function test_updateTextDAO_revert_notFound() public {
        address _nonExistentDAO = address(0x9999);
        // Expect a revert when trying to update a non-existent DAO
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoNotFound.selector, _nonExistentDAO));
        $daoRegistry.updateTextDAO(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAO,
            addr: _nonExistentDAO,
            metadataCid: "someCid"
        }));
    }

    function test_deleteTextDAO_success() public {
        address _textDAO = address(0x1234);
        string memory _metadataCid = "testCid";

        // Register the TextDAO first
        $daoRegistry.registerTextDAO(_textDAO, _metadataCid);

        // Expect the DaoInfoDeleted event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoInfoDeleted(_textDAO);

        // Delete the TextDAO
        $daoRegistry.deleteTextDAO(Schema.DaoInfo({
            addr: _textDAO,
            daoType: Schema.TemplateType.TextDAO,
            metadataCid: _metadataCid
        }));

        // Assert that the DAO is deleted
        assertEq($daoRegistry.daoInfos[_textDAO].addr, address(0), "The DAO should be deleted.");
    }

    function test_deleteTextDAO_revert_notFound() public {
        address _nonExistentDAO = address(0x9999);
        // Expect a revert when trying to delete a non-existent DAO
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoNotFound.selector, _nonExistentDAO));
        $daoRegistry.deleteTextDAO(Schema.DaoInfo({
            addr: _nonExistentDAO,
            daoType: Schema.TemplateType.TextDAO,
            metadataCid: "someCid"
        }));
    }

    function test_registerTextDAOWithCheats_success() public {
        address _textDAOWithCheats = address(0x5678);
        string memory _metadataCid = "cheatCid";

        // Expect the DaoRegistered event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoRegistered(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            addr: _textDAOWithCheats,
            metadataCid: _metadataCid
        }));
        // Register the TextDAO with cheats
        $daoRegistry.registerTextDAOWithCheats(_textDAOWithCheats, _metadataCid);

        // Assert that the DAO with cheats is registered correctly
        assertEq($daoRegistry.daoInfos[_textDAOWithCheats].addr, _textDAOWithCheats, "The DAO address should match.");
        assertEq($daoRegistry.daoInfos[_textDAOWithCheats].metadataCid, _metadataCid, "The metadata CID should match.");
    }

    function test_registerTextDAOWithCheats_revert_alreadyRegistered() public {
        address textDAOWithCheats = address(0x5678);
        string memory metadataCid = "cheatCid";

        // First registration should succeed
        $daoRegistry.registerTextDAOWithCheats(textDAOWithCheats, metadataCid);

        // Expect a revert when trying to register the same DAO again
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoAlreadyRegistered.selector, textDAOWithCheats));
        $daoRegistry.registerTextDAOWithCheats(textDAOWithCheats, metadataCid);
    }

    function test_updateTextDAOWithCheats_success() public {
        address _textDAOWithCheats = address(0x5678);
        string memory _metadataCid = "updatedCheatCid";

        // Register the TextDAO with cheats first
        $daoRegistry.registerTextDAOWithCheats(_textDAOWithCheats, "initialCheatCid");

        // Expect the DaoInfoUpdated event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoInfoUpdated(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            addr: _textDAOWithCheats,
            metadataCid: _metadataCid
        }));

        // Update the TextDAO with cheats
        $daoRegistry.updateTextDAOWithCheats(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            addr: _textDAOWithCheats,
            metadataCid: _metadataCid
        }));

        // Assert that the DAO with cheats is updated correctly
        assertEq($daoRegistry.daoInfos[_textDAOWithCheats].metadataCid, _metadataCid, "The metadata CID should match.");
    }

    function test_updateTextDAOWithCheats_revert_notFound() public {
        address _nonExistentDAOWithCheats = address(0x9999);
        // Expect a revert when trying to update a non-existent DAO with cheats
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoNotFound.selector, _nonExistentDAOWithCheats));
        $daoRegistry.updateTextDAOWithCheats(Schema.DaoInfo({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            addr: _nonExistentDAOWithCheats,
            metadataCid: "someCid"
        }));
    }

    function test_deleteTextDAOWithCheats_success() public {
        address _textDAOWithCheats = address(0x5678);
        string memory _metadataCid = "testCheatCid";

        // Register the TextDAO with cheats first
        $daoRegistry.registerTextDAOWithCheats(_textDAOWithCheats, _metadataCid);

        // Expect the DaoInfoDeleted event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoInfoDeleted(_textDAOWithCheats);

        // Delete the TextDAO with cheats
        $daoRegistry.deleteTextDAOWithCheats(Schema.DaoInfo({
            addr: _textDAOWithCheats,
            daoType: Schema.TemplateType.TextDAOWithCheats,
            metadataCid: _metadataCid
        }));

        // Assert that the DAO with cheats is deleted
        assertEq($daoRegistry.daoInfos[_textDAOWithCheats].addr, address(0), "The DAO should be deleted.");
    }

    function test_deleteTextDAOWithCheats_revert_notFound() public {
        address _nonExistentDAOWithCheats = address(0x9999);
        // Expect a revert when trying to delete a non-existent DAO with cheats
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.DaoNotFound.selector, _nonExistentDAOWithCheats));
        $daoRegistry.deleteTextDAOWithCheats(Schema.DaoInfo({
            addr: _nonExistentDAOWithCheats,
            daoType: Schema.TemplateType.TextDAOWithCheats,
            metadataCid: "someCid"
        }));
    }
}
