// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Interfaces
import {IUserManagement} from "bundle/hubdao/interfaces/HubDAOFunctions.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";

/**
 * @title UserManagement
 * @notice This contract handles user profile management
 */
contract UserManagement is IUserManagement {
    /**
     * @notice Updates or inserts a user profile
     * @param metadataCid The IPFS CID of the user metadata
     */
    function updateUserProfile(string calldata metadataCid) external {
        emit HubDAOEvents.UserProfileUpdated(msg.sender, metadataCid);
    }

    /**
     * @notice Removes a user profile
     */
    function removeUserProfile() external {
        emit HubDAOEvents.UserProfileRemoved(msg.sender);
    }

}


/// Testing
import {MCTest, vm} from "@devkit/Flattened.sol";

/**
 * @title UserManagementTest
 * @notice Test contract for the UserManagement contract
 */
contract UserManagementTest is MCTest {
    function setUp() public {
        address userManagement = address(new UserManagement());
        _use(UserManagement.updateUserProfile.selector, userManagement);
        _use(UserManagement.removeUserProfile.selector, userManagement);
    }

    /**
     * @notice Test successful user profile update
     */
    function test_updateUserProfile_success() public {
        string memory metadataCid = "QmTest";

        vm.expectEmit();
        emit HubDAOEvents.UserProfileUpdated(address(this), metadataCid);

        UserManagement(target).updateUserProfile(metadataCid);
    }

    /**
     * @notice Test successful user profile removal
     */
    function test_removeUserProfile_success() public {
        // First, create a profile
        UserManagement(target).updateUserProfile("QmTest");

        vm.expectEmit();
        emit HubDAOEvents.UserProfileRemoved(address(this));

        UserManagement(target).removeUserProfile();
    }
}
