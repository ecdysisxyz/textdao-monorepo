// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Access Control
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
// Storage
import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {DaoTemplateLib} from "bundle/hubdao/storages/utils/DaoTemplateLib.sol";
import {GlobalConfigLib} from "bundle/hubdao/storages/utils/GlobalConfigLib.sol";
import {AdminLib} from "bundle/hubdao/storages/utils/AdminLib.sol";
import {Schema as TextDAOSchema} from "bundle/textdao/storages/Schema.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
// Interface
import {IInitialize} from "bundle/hubdao/interfaces/HubDAOFunctions.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title Initialize
 * @notice This contract handles the initialization process for HubDAO
 * @dev Inherits from Initializable to ensure one-time initialization
 */
contract Initialize is IInitialize, Initializable {
    using DaoTemplateLib for Schema.DaoTemplates;
    using GlobalConfigLib for Schema.GlobalConfigs;
    using DeliberationLib for TextDAOSchema.DeliberationConfig;
    using AdminLib for Schema.Admins;

    /**
     * @notice Initializes the HubDAO with base currency and multiple DAO templates
     * @param baseCurrency The base currency for the HubDAO
     * @param templates An array of DAO templates to be used
     * @param textDaoDefaultConfig Default configuration for TextDAO deliberation
     * @dev This function can only be called once due to the initializer modifier
     * @dev Emits a BaseCurrencyUpdated event for the set currency
     * @dev Emits a DaoTemplateUpdated event for each template added
     * @dev Emits a DeliberationConfigUpdated event for the TextDAO configuration
     */
    function initialize(
        Schema.Currency calldata baseCurrency,
        Schema.Template[] calldata templates,
        TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig
    ) public initializer {
        Storage.GlobalConfigs().setCurrency(baseCurrency);
        Storage.DaoTemplates().addTemplates(templates);
        Storage.TextDaoDefaultConfig().setConfig(textDaoDefaultConfig);
    }

    /**
     * @notice Initializes the HubDAO with base currency, multiple DAO templates, and sets the caller as admin
     * @param baseCurrency The base currency for the HubDAO
     * @param templates An array of DAO templates to be used
     * @param textDaoDefaultConfig Default configuration for TextDAO deliberation
     * @param admin The address to be set as admin
     * @dev This function can only be called once due to the initializer modifier
     * @dev Calls the initialize function and then adds the caller as an admin
     */
    function initializeWithAdmin(
        Schema.Currency calldata baseCurrency,
        Schema.Template[] calldata templates,
        TextDAOSchema.DeliberationConfig calldata textDaoDefaultConfig,
        address admin
    ) external {
        initialize(baseCurrency, templates, textDaoDefaultConfig);
        Storage.Admins().addAdmin(admin);
    }
}


// Testing
import {MCTest, console} from "@mc-devkit/Flattened.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title InitializeTest
 * @notice Test contract for the Initialize contract
 */
contract HubDaoInitializeTest is MCTest {
    function setUp() public {
        address _initialize = address(new Initialize());
        _use(Initialize.initialize.selector, _initialize);
        _use(Initialize.initializeWithAdmin.selector, _initialize);
    }

    /**
     * @notice Test successful initialization of HubDAO with multiple templates
     * @param fuzz_baseCurrency The base currency for fuzzing testing
     * @param fuzz_textDaoDefaultConfig The default TextDAO configuration for fuzzing testing
     */
    function test_initialize_success_withRandomArgs(
        Schema.Currency calldata fuzz_baseCurrency,
        TextDAOSchema.DeliberationConfig calldata fuzz_textDaoDefaultConfig
    ) public {
        Schema.Template[] memory _templates = new Schema.Template[](2);
        _templates[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x1111111111111111111111111111111111111111)
        });
        _templates[1] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: address(0x2222222222222222222222222222222222222222)
        });

        vm.expectEmit();
        emit HubDAOEvents.BaseCurrencyUpdated(fuzz_baseCurrency);
        for (uint i; i < _templates.length; ++i) {
            emit HubDAOEvents.DaoTemplateUpdated(_templates[i]);
        }
        emit HubDAOEvents.DeliberationConfigUpdated(fuzz_textDaoDefaultConfig);
        emit HubDAOEvents.Initialized(1);

        Initialize(target).initialize({
            baseCurrency: fuzz_baseCurrency,
            templates: _templates,
            textDaoDefaultConfig: fuzz_textDaoDefaultConfig
        });

        _verifyInitializedState({
            expectedCurrency: fuzz_baseCurrency,
            expectedTemplates: _templates,
            expectedConfig: fuzz_textDaoDefaultConfig
        });
    }

    /**
     * @notice Test revert on double initialization attempt
     * @param fuzz_baseCurrency1 The first base currency for testing
     * @param fuzz_baseCurrency2 The second base currency for testing
     * @param fuzz_textDaoDefaultConfig The default TextDAO configuration for testing
     * @dev Expects a revert with HubDAOErrors.InvalidInitialization if initialized twice
     */
    function test_initialize_revert_alreadyInitialized_withRandomArgs(
        Schema.Currency calldata fuzz_baseCurrency1,
        Schema.Currency calldata fuzz_baseCurrency2,
        TextDAOSchema.DeliberationConfig calldata fuzz_textDaoDefaultConfig
    ) public {
        Schema.Template[] memory _templates1 = new Schema.Template[](1);
        _templates1[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x1111111111111111111111111111111111111111)
        });

        Schema.Template[] memory _templates2 = new Schema.Template[](1);
        _templates2[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: address(0x2222222222222222222222222222222222222222)
        });

        // 1st attempt
        Initialize(target).initialize(fuzz_baseCurrency1, _templates1, fuzz_textDaoDefaultConfig);

        // 2nd attempt
        vm.expectRevert(HubDAOErrors.InvalidInitialization.selector);
        Initialize(target).initialize(fuzz_baseCurrency2, _templates2, fuzz_textDaoDefaultConfig);
    }

    /**
     * @notice Test initialization with empty currency and templates array
     */
    function test_initialize_withEmptyArgs() public {
        Schema.Currency memory _emptyCurrency;
        Schema.Template[] memory _emptyTemplates = new Schema.Template[](0);
        TextDAOSchema.DeliberationConfig memory _emptyDeliberationConfig;

        vm.expectEmit();
        emit HubDAOEvents.BaseCurrencyUpdated(_emptyCurrency);

        Initialize(target).initialize(_emptyCurrency, _emptyTemplates, _emptyDeliberationConfig);

        _verifyInitializedState(_emptyCurrency, _emptyTemplates, _emptyDeliberationConfig);
    }

    /**
     * @notice Test initialization with admin
     * @param fuzz_baseCurrency The base currency for testing
     * @param fuzz_textDaoDefaultConfig The default TextDAO configuration for testing
     * @param fuzz_admin The admin address for testing
     * @dev Emits an AdminAdded event when the admin is successfully added
     */
    function test_initializeWithAdmin_success_withRandomArgs(
        Schema.Currency calldata fuzz_baseCurrency,
        TextDAOSchema.DeliberationConfig calldata fuzz_textDaoDefaultConfig,
        address fuzz_admin
    ) public {
        Schema.Template[] memory _templates = new Schema.Template[](1);
        _templates[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: 0x1111111111111111111111111111111111111111
        });

        vm.expectEmit();
        emit HubDAOEvents.BaseCurrencyUpdated(fuzz_baseCurrency);
        emit HubDAOEvents.DaoTemplateUpdated(_templates[0]);
        emit HubDAOEvents.DeliberationConfigUpdated(fuzz_textDaoDefaultConfig);
        emit HubDAOEvents.Initialized(1);
        emit HubDAOEvents.AdminAdded(fuzz_admin);

        Initialize(target).initializeWithAdmin(fuzz_baseCurrency, _templates, fuzz_textDaoDefaultConfig, fuzz_admin);

        _verifyInitializedState(fuzz_baseCurrency, _templates, fuzz_textDaoDefaultConfig);
        _verifyAdmin(fuzz_admin);
    }

    /**
     * @notice Test revert on double initialization attempt with admin
     * @param fuzz_baseCurrency1 The first base currency for testing
     * @param fuzz_baseCurrency2 The second base currency for testing
     * @param fuzz_textDaoDefaultConfig The default TextDAO configuration for testing
     * @param fuzz_admin1 The first admin address for testing
     * @param fuzz_admin2 The second admin address for testing
     */
    function test_initializeWithAdmin_revert_alreadyInitialized(
        Schema.Currency calldata fuzz_baseCurrency1,
        Schema.Currency calldata fuzz_baseCurrency2,
        TextDAOSchema.DeliberationConfig calldata fuzz_textDaoDefaultConfig,
        address fuzz_admin1,
        address fuzz_admin2
    ) public {
        Schema.Template[] memory _templates1 = new Schema.Template[](1);
        _templates1[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: 0x1111111111111111111111111111111111111111
        });
        Schema.Template[] memory _templates2 = new Schema.Template[](1);
        _templates2[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAOWithCheats,
            dictionary: 0x2222222222222222222222222222222222222222
        });

        // 1st attempt
        Initialize(target).initializeWithAdmin(fuzz_baseCurrency1, _templates1, fuzz_textDaoDefaultConfig, fuzz_admin1);

        // 2nd attempt
        vm.expectRevert(HubDAOErrors.InvalidInitialization.selector);
        Initialize(target).initializeWithAdmin(fuzz_baseCurrency2, _templates2, fuzz_textDaoDefaultConfig, fuzz_admin2);
    }

    //---------------------
    //  Helper Functions
    //---------------------

    /**
     * @notice Verify the initialized state of the contract
     * @param expectedCurrency The expected base currency
     * @param expectedTemplates The expected DAO templates
     * @param expectedConfig The expected TextDAO default configuration
     */
    function _verifyInitializedState(
        Schema.Currency memory expectedCurrency,
        Schema.Template[] memory expectedTemplates,
        TextDAOSchema.DeliberationConfig memory expectedConfig
    ) internal view {
        assertEq(
            keccak256(abi.encode(Storage.GlobalConfigs().baseCurrency)),
            keccak256(abi.encode(expectedCurrency)),
            "Stored currency does not match expected"
        );
        for (uint i; i < expectedTemplates.length; ++i) {
            assertEq(
                keccak256(abi.encode(Storage.DaoTemplates().templates[expectedTemplates[i].daoType])),
                keccak256(abi.encode(expectedTemplates[i])),
                "Stored template does not match expected"
            );
        }
        assertEq(
            keccak256(abi.encode(Storage.TextDaoDefaultConfig())),
            keccak256(abi.encode(expectedConfig)),
            "Stored TextDAO default config does not match expected"
        );
    }

    /**
     * @notice Verify the admin is set correctly
     * @param expectedAdmin The expected admin address
     */
    function _verifyAdmin(address expectedAdmin) internal view {
        address[] storage $admins = Storage.Admins().admins;
        assertEq($admins.length, 1, "Should have one admin");
        assertEq($admins[0], expectedAdmin, "Admin should be the expected address");
    }
}
