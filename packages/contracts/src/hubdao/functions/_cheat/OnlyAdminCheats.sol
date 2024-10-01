// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {DaoRegistryLib} from "bundle/hubdao/storages/utils/DaoRegistryLib.sol";
import {DaoTemplateLib} from "bundle/hubdao/storages/utils/DaoTemplateLib.sol";
import {GlobalConfigLib} from "bundle/hubdao/storages/utils/GlobalConfigLib.sol";
import {AdminLib} from "bundle/hubdao/storages/utils/AdminLib.sol";
// Interfaces
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";

/**
 * @title OnlyAdminCheats
 * @dev Contract for admin-only functions to manage HubDAO settings
 */
contract OnlyAdminCheats {
    using DaoTemplateLib for Schema.DaoTemplates;
    using DaoRegistryLib for Schema.DaoRegistry;
    using GlobalConfigLib for Schema.GlobalConfigs;
    using AdminLib for Schema.Admins;

    /**
     * @dev Modifier to restrict function access to admin users only
     */
    modifier onlyAdmin() {
        Storage.Admins().requireAdmin(msg.sender);
        _;
    }

    /**
     * @dev Adds new admin address to the admin list
     * @param newAdmin An address to be added as an admin
     * @notice Only callable by an admin
     */
    function addAdmin(address newAdmin) external onlyAdmin {
        Storage.Admins().addAdmin(newAdmin);
    }

    /**
     * @dev Updates the base currency of the HubDAO
     * @param newCurrency New currency details to be set as base currency
     * @notice Only callable by an admin
     */
    function updateBaseCurrency(Schema.Currency calldata newCurrency) external onlyAdmin {
        Storage.GlobalConfigs().setCurrency(newCurrency);
    }

    /**
     * @dev Adds a new DAO template
     * @param newTemplate New template details to be added
     * @notice Only callable by an admin
     */
    function addTemplate(Schema.Template calldata newTemplate) external onlyAdmin {
        Storage.DaoTemplates().addTemplate(newTemplate);
    }

}


// Testing
import {MCTest} from "@mc-devkit/Flattened.sol";

contract OnlyAdminCheatsTest is MCTest {
    using AdminLib for Schema.Admins;

    address private constant ADMIN = address(0x1);
    address private constant NON_ADMIN = address(0x2);

    function setUp() public {
        address _onlyAdminCheats = address(new OnlyAdminCheats());

        // Use the contract's functions for testing
        _use(OnlyAdminCheats.addAdmin.selector, _onlyAdminCheats);
        _use(OnlyAdminCheats.updateBaseCurrency.selector, _onlyAdminCheats);
        _use(OnlyAdminCheats.addTemplate.selector, _onlyAdminCheats);

        // Add initial admin
        Storage.Admins().addAdmin(ADMIN);
    }

    function test_addAdmin_success() public {
        address _newAdmin = address(0x3);

        vm.prank(ADMIN);
        OnlyAdminCheats(target).addAdmin(_newAdmin);

        assertEq(Storage.Admins().admins.length, 2, "New admin should be added successfully");
        assertEq(Storage.Admins().admins[1], _newAdmin, "The new admin address should match");
    }

    function test_addAdmin_revert_nonAdmin() public {
        address _newAdmin = address(0x5);

        vm.prank(NON_ADMIN);
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.NotAdmin.selector, NON_ADMIN));
        OnlyAdminCheats(target).addAdmin(_newAdmin);
    }

    function test_updateBaseCurrency_success() public {
        address _newCurrencyAddress = address(0x1234);
        Schema.Currency memory _newCurrency = Schema.Currency({
            addr: _newCurrencyAddress
        });

        vm.prank(ADMIN);
        OnlyAdminCheats(target).updateBaseCurrency(_newCurrency);

        Schema.Currency memory _updatedCurrency = Storage.GlobalConfigs().baseCurrency;
        assertEq(_updatedCurrency.addr, _newCurrencyAddress, "Currency address should be updated");
    }

    function test_updateBaseCurrency_revert_nonAdmin() public {
        Schema.Currency memory _newCurrency = Schema.Currency({
            addr: address(0x1234)
        });

        vm.prank(NON_ADMIN);
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.NotAdmin.selector, NON_ADMIN));
        OnlyAdminCheats(target).updateBaseCurrency(_newCurrency);
    }

    function test_addTemplate_success() public {
        Schema.Template memory _newTemplate = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x5678)
        });

        vm.prank(ADMIN);
        OnlyAdminCheats(target).addTemplate(_newTemplate);

        Schema.Template memory _addedTemplate = Storage.DaoTemplates().templates[Schema.TemplateType.TextDAO];
        assertEq(uint(_addedTemplate.daoType), uint(Schema.TemplateType.TextDAO), "Template type should be added correctly");
        assertEq(_addedTemplate.dictionary, address(0x5678), "Template dictionary address should be added correctly");
    }

    function test_addTemplate_revert_nonAdmin() public {
        Schema.Template memory _newTemplate = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x5678)
        });

        vm.prank(NON_ADMIN);
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.NotAdmin.selector, NON_ADMIN));
        OnlyAdminCheats(target).addTemplate(_newTemplate);
    }
}
