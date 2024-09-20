// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";

/**
 * @title OnlyAdminCheats
 * @dev Contract for admin-only functions to manage HubDAO settings
 */
contract OnlyAdminCheats {
    /**
     * @dev Modifier to restrict function access to admin users only
     */
    modifier onlyAdmin() {
        bool _isAdmin;
        for (uint i; i < Storage.Admins().admins.length; ++i) {
            if (msg.sender == Storage.Admins().admins[i]) {
                _isAdmin = true;
                break;
            }
        }
        require(_isAdmin, "You are not the admin");
        _;
    }

    /**
     * @dev Adds new admin addresses to the admin list
     * @param newAdmins Array of addresses to be added as admins
     */
    function addAdmins(address[] memory newAdmins) external onlyAdmin {
        for (uint i; i < newAdmins.length; ++i) {
            Storage.Admins().admins.push(newAdmins[i]);
        }
    }

    /**
     * @dev Updates the base currency of the HubDAO
     * @param newCurrency New currency details to be set as base currency
     */
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external onlyAdmin {
        Storage.MetaState().baseCurrency = newCurrency;
    }

    /**
     * @dev Adds a new DAO template
     * @param newTemplate New template details to be added
     */
    function addTemplate(Schema.Template calldata newTemplate) external onlyAdmin {
        Storage.MetaState().templates[newTemplate.daoType] = newTemplate;
    }

}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";

contract OnlyAdminCheatsTest is MCTest {
    address private admin;
    address private nonAdmin;

    function setUp() public {
        address onlyAdminCheats = address(new OnlyAdminCheats());
        admin = address(0x1);
        nonAdmin = address(0x2);

        _use(OnlyAdminCheats.addAdmins.selector, onlyAdminCheats);
        _use(OnlyAdminCheats.updateBaseCurrency.selector, onlyAdminCheats);
        _use(OnlyAdminCheats.addTemplate.selector, onlyAdminCheats);

        // Add initial admin
        Storage.Admins().admins.push(admin);
    }

    function test_addAdmins_success() public {
        address[] memory newAdmins = new address[](2);
        newAdmins[0] = address(0x3);
        newAdmins[1] = address(0x4);

        vm.prank(admin);
        OnlyAdminCheats(target).addAdmins(newAdmins);

        assertEq(Storage.Admins().admins.length, 3, "New admins should be added");
        assertEq(Storage.Admins().admins[1], newAdmins[0], "First new admin should be added");
        assertEq(Storage.Admins().admins[2], newAdmins[1], "Second new admin should be added");
    }

    function test_addAdmins_fail_nonAdmin() public {
        address[] memory newAdmins = new address[](1);
        newAdmins[0] = address(0x5);

        vm.prank(nonAdmin);
        vm.expectRevert("You are not the admin");
        OnlyAdminCheats(target).addAdmins(newAdmins);
    }

    function test_updateBaseCurrency_success() public {
        address newCurrencyAddress = address(0x1234);
        Schema.Currency memory newCurrency = Schema.Currency({
            addr: newCurrencyAddress
        });

        vm.prank(admin);
        OnlyAdminCheats(target).updateBaseCurrency(newCurrency);

        Schema.Currency memory updatedCurrency = Storage.MetaState().baseCurrency;
        assertEq(updatedCurrency.addr, newCurrencyAddress, "Currency address should be updated");
    }

    function test_updateBaseCurrency_fail_nonAdmin() public {
        Schema.Currency memory newCurrency = Schema.Currency({
            addr: address(0x1234)
        });

        vm.prank(nonAdmin);
        vm.expectRevert("You are not the admin");
        OnlyAdminCheats(target).updateBaseCurrency(newCurrency);
    }

    function test_addTemplate_success() public {
        Schema.Template memory newTemplate = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x5678)
        });

        vm.prank(admin);
        OnlyAdminCheats(target).addTemplate(newTemplate);

        Schema.Template memory addedTemplate = Storage.MetaState().templates[Schema.TemplateType.TextDAO];
        assertEq(uint(addedTemplate.daoType), uint(Schema.TemplateType.TextDAO), "Template type should be added correctly");
        assertEq(addedTemplate.dictionary, address(0x5678), "Template dictionary address should be added correctly");
    }

    function test_addTemplate_fail_nonAdmin() public {
        Schema.Template memory newTemplate = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x5678)
        });

        vm.prank(nonAdmin);
        vm.expectRevert("You are not the admin");
        OnlyAdminCheats(target).addTemplate(newTemplate);
    }
}
