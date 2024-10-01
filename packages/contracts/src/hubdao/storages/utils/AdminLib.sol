// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title AdminLib v0.1.0
 * @dev Library for managing admin addresses
 */
library AdminLib {
    using AdminLib for Schema.Admins;

    /**
     * @dev Adds an admin address to the list of admins
     * @param $admins The storage reference to the Admins structure
     * @param admin The address of the admin to be added
     */
    function addAdmin(Schema.Admins storage $admins, address admin) internal {
        $admins.admins.push(admin);
        emit HubDAOEvents.AdminAdded(admin);
    }

    /**
     * @dev Checks if an address is an admin
     * @param $admins The storage reference to the Admins structure
     * @param target The address to check
     * @return result True if the address is an admin, false otherwise
     */
    function isAdmin(Schema.Admins storage $admins, address target) internal view returns(bool result) {
        for (uint i; i < $admins.admins.length; ++i) {
            if (target == $admins.admins[i]) {
                result = true;
                break;
            }
        }
    }

    /**
     * @dev Requires that the caller is an admin
     * @param target The address to check
     */
    function requireAdmin(Schema.Admins storage $admins, address target) internal view {
        if (!$admins.isAdmin(target)) revert HubDAOErrors.NotAdmin(target);
    }

}

// Testing
import {Test} from "forge-std/Test.sol";

contract AdminLibTest is Test {
    using AdminLib for Schema.Admins;

    Schema.Admins private $admins;

    function setUp() public {} // No setup required for this library test

    function test_addAdmin_success() public {
        // Test adding a new admin address
        address _newAdmin = address(0x1234);
        $admins.addAdmin(_newAdmin);

        // Verify that the admin was successfully added
        assertEq($admins.admins.length, 1, "Admin count should be 1 after adding a new admin");
        assertEq($admins.admins[0], _newAdmin, "The added admin address should match the expected address");
    }

    function test_addAdmin_success_duplicateAdmin() public {
        // Test adding a duplicate admin address
        address _newAdmin = address(0x1234);
        $admins.addAdmin(_newAdmin);

        // Attempt to add the same admin address again
        $admins.addAdmin(_newAdmin);

        // Verify that the duplicate admin was added
        assertEq($admins.admins.length, 2, "Admin count should be 2 after adding a duplicate admin");
        assertEq($admins.admins[0], _newAdmin, "The first admin address should match the expected address");
        assertEq($admins.admins[1], _newAdmin, "The second admin address should also match the expected address");
    }

    function test_addAdmin_success_zeroAddress() public {
        // Verify initial admin count is zero
        assertEq($admins.admins.length, 0, "Initial admin count should be 0");

        // Test adding a zero address as an admin
        address _zeroAdmin = address(0);
        $admins.addAdmin(_zeroAdmin);

        // Verify that the zero address was added
        assertEq($admins.admins.length, 1, "Admin count should be 1 after adding a zero address");
        assertEq($admins.admins[0], _zeroAdmin, "The added admin address should be the zero address");
    }

    function test_isAdmin_success() public {
        // Test that an admin address is recognized as an admin
        address _admin = address(0x1234);
        $admins.addAdmin(_admin);

        // Verify that isAdmin returns true for the admin
        bool result = $admins.isAdmin(_admin);
        assert(result == true);
    }

    function test_isAdmin_failure() public view {
        // Test that a non-admin address is not recognized as an admin
        address _nonAdmin = address(0x5678);

        // Verify that isAdmin returns false for the non-admin
        bool result = $admins.isAdmin(_nonAdmin);
        assert(result == false);
    }

    function test_requireAdmin_success() public {
        // Test requiring an admin address
        address _newAdmin = address(0x1234);
        $admins.addAdmin(_newAdmin);

        // Verify that requiring the new admin does not revert
        $admins.requireAdmin(_newAdmin);
    }

    function test_requireAdmin_failure() public {
        // Test requiring a non-admin address
        address _nonAdmin = address(0x5678);

        // Expect revert when requiring a non-admin
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.NotAdmin.selector, _nonAdmin));
        $admins.requireAdmin(_nonAdmin);
    }
}
