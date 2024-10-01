// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Storage, Schema} from "bundle/hubdao/storages/Storage.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title DaoTemplateLib v0.1.0
 * @dev Library for managing DAO templates.
 */
library DaoTemplateLib {
    using DaoTemplateLib for Schema.DaoTemplates;

    //-----------------------
    //  Storage Operations
    //-----------------------

    /**
     * @dev Adds a DAO template to the HubDAO.
     * @param $daoTemplates The DAO registry to add the template to.
     * @param template The template to add.
     * @notice Emits a DaoTemplateAdded event on success.
     * @dev Reverts with HubDAOErrors.TemplateAlreadyExist if the template already exists.
     */
    function addTemplate(Schema.DaoTemplates storage $daoTemplates, Schema.Template memory template) internal {
        if ($daoTemplates.getDictionary(template.daoType) != address(0)) revert HubDAOErrors.TemplateAlreadyExist(template.daoType);
        $daoTemplates.templates[template.daoType] = template;
        emit HubDAOEvents.DaoTemplateAdded(template);
    }

    /**
     * @dev Updates an existing DAO template in the HubDAO.
     * @param $daoTemplates The DAO registry to update the template in.
     * @param template The template to update.
     * @notice Emits a DaoTemplateUpdated event on success.
     * @dev Reverts with HubDAOErrors.TemplateNotFound if the template does not exist.
     */
    function updateTemplate(Schema.DaoTemplates storage $daoTemplates, Schema.Template memory template) internal {
        if ($daoTemplates.getDictionary(template.daoType) == address(0)) revert HubDAOErrors.TemplateNotFound(template.daoType);
        $daoTemplates.templates[template.daoType] = template;
        emit HubDAOEvents.DaoTemplateUpdated(template);
    }

    /**
     * @dev Deletes a DAO template from the HubDAO.
     * @param $daoTemplates The DAO registry to delete the template from.
     * @param templateType The type of the template to delete.
     * @notice Emits a DaoTemplateDeleted event on success.
     * @dev Reverts with HubDAOErrors.TemplateNotFound if the template does not exist.
     */
    function deleteTemplate(Schema.DaoTemplates storage $daoTemplates, Schema.TemplateType templateType) internal {
        if ($daoTemplates.getDictionary(templateType) == address(0)) revert HubDAOErrors.TemplateNotFound(templateType);
        delete $daoTemplates.templates[templateType];
        emit HubDAOEvents.DaoTemplateDeleted(templateType);
    }

    /**
     * @dev Retrieves the dictionary address for a given template type.
     * @param $daoTemplates The DAO registry to query.
     * @param templateType The template type to look up.
     * @return The dictionary address associated with the template type.
     */
    function getDictionary(Schema.DaoTemplates storage $daoTemplates, Schema.TemplateType templateType) internal view returns(address) {
        return $daoTemplates.templates[templateType].dictionary;
    }

    /**
     * @dev Adds multiple templates to the DAO templates.
     * @param $daoTemplates The DAO registry to add the templates to.
     * @param templates The array of templates to add.
     * @notice Emits DaoTemplateAdded events for each added template.
     */
    function addTemplates(Schema.DaoTemplates storage $daoTemplates, Schema.Template[] memory templates) internal {
        for (uint i; i < templates.length; ++i) {
            $daoTemplates.addTemplate(templates[i]);
        }
    }

    //----------------------
    //  Memory Operations
    //----------------------

    /**
     * @dev Creates a new template in memory.
     * @param templateType The type of the template.
     * @param dictionaryAddr The address of the dictionary.
     * @return templates An array containing the new template.
     */
    function newTemplate(Schema.TemplateType templateType, address dictionaryAddr) internal pure returns(Schema.Template[] memory templates) {
        templates = new Schema.Template[](1);
        templates[0] = Schema.Template({
            daoType: templateType,
            dictionary: dictionaryAddr
        });
    }

    /**
     * @dev Adds a new template to an existing array of templates.
     * @param originTemplates The existing array of templates.
     * @param templateType The type of the new template.
     * @param dictionaryAddr The address of the dictionary for the new template.
     * @return templates An array containing the updated templates.
     */
    function addTemplateToMemory(Schema.Template[] memory originTemplates, Schema.TemplateType templateType, address dictionaryAddr) internal pure returns(Schema.Template[] memory templates) {
        templates = new Schema.Template[](originTemplates.length + 1);
        for (uint i; i < originTemplates.length; ++i) {
            templates[i] = originTemplates[i];
        }
        templates[originTemplates.length] = Schema.Template({
            daoType: templateType,
            dictionary: dictionaryAddr
        });
    }
}

// Testing
import {Test} from "forge-std/Test.sol";

contract DaoTemplateLibTest is Test {
    using DaoTemplateLib for Schema.DaoTemplates;

    Schema.DaoTemplates private $daoTemplates;

    function setUp() public {} // No setup required for this library test

    function test_addTemplate_success() public {
        Schema.Template memory _template = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x9999)
        });

        // Expect the DaoTemplateAdded event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoTemplateAdded(_template);

        // Add the template to the DAO registry
        $daoTemplates.addTemplate(_template);

        // Assert that the template is added correctly
        assertEq($daoTemplates.templates[_template.daoType].dictionary, address(0x9999), "The dictionary address should match.");
    }

    function test_addTemplate_revert_duplicate() public {
        Schema.Template memory _template = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x9999)
        });

        // Add the template for the first time
        $daoTemplates.addTemplate(_template);

        // Expect a revert when trying to add the same template again
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.TemplateAlreadyExist.selector, _template.daoType));
        $daoTemplates.addTemplate(_template);
    }

    function test_updateTemplate_success() public {
        Schema.Template memory _template = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x9999)
        });

        // Add the initial template
        $daoTemplates.addTemplate(_template);

        Schema.Template memory _updatedTemplate = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x8888)
        });

        // Expect the DaoTemplateUpdated event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoTemplateUpdated(_updatedTemplate);

        // Update the template in the DAO registry
        $daoTemplates.updateTemplate(_updatedTemplate);

        // Assert that the template is updated correctly
        assertEq($daoTemplates.templates[_updatedTemplate.daoType].dictionary, address(0x8888), "The updated dictionary address should match.");
    }

    function test_updateTemplate_revert_notFound() public {
        Schema.Template memory _template = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x9999)
        });

        // Expect a revert when trying to update a non-existent template
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.TemplateNotFound.selector, _template.daoType));
        $daoTemplates.updateTemplate(_template);
    }

    function test_deleteTemplate_success() public {
        Schema.Template memory _template = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x9999)
        });

        // Add the template to the DAO registry
        $daoTemplates.addTemplate(_template);

        // Expect the DaoTemplateDeleted event to be emitted
        vm.expectEmit();
        emit HubDAOEvents.DaoTemplateDeleted(_template.daoType);

        // Delete the template from the DAO registry
        $daoTemplates.deleteTemplate(_template.daoType);

        // Assert that the template is deleted
        assertEq($daoTemplates.getDictionary(_template.daoType), address(0), "The dictionary address should be zero after deletion.");
    }

    function test_deleteTemplate_revert_notFound() public {
        Schema.TemplateType _templateTypeTextDAO = Schema.TemplateType.TextDAO;

        // Expect a revert when trying to delete a non-existent template
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.TemplateNotFound.selector, _templateTypeTextDAO));
        $daoTemplates.deleteTemplate(_templateTypeTextDAO);

        Schema.TemplateType _templateTypeTextDAOWithCheats = Schema.TemplateType.TextDAOWithCheats;

        // Expect a revert when trying to delete another non-existent template
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.TemplateNotFound.selector, _templateTypeTextDAOWithCheats));
        $daoTemplates.deleteTemplate(_templateTypeTextDAOWithCheats);
    }

    function test_addTemplates_success() public {
        Schema.Template[] memory _templates = new Schema.Template[](1);
        _templates[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x8888)
        });

        // Add multiple templates to the DAO registry
        $daoTemplates.addTemplates(_templates);

        // Assert that the templates are added correctly
        assertEq($daoTemplates.templates[Schema.TemplateType.TextDAO].dictionary, address(0x8888), "The dictionary address should match.");
    }

    function test_addTemplates_revert_duplicate() public {
        Schema.Template[] memory _templates = new Schema.Template[](2);
        _templates[0] = Schema.Template({
            daoType: Schema.TemplateType.TextDAO,
            dictionary: address(0x8888)
        });
        _templates[1] = _templates[0];

        // Expect a revert when trying to add duplicate templates
        vm.expectRevert(abi.encodeWithSelector(HubDAOErrors.TemplateAlreadyExist.selector, _templates[0].daoType));
        $daoTemplates.addTemplates(_templates); // Attempt to add the same template included
    }

    function test_getDictionary_success() public {
        Schema.TemplateType _templateType = Schema.TemplateType.TextDAO;
        address expectedDictionary = address(0x7777);

        // Add a template to the DAO registry
        $daoTemplates.addTemplate(Schema.Template({
            daoType: _templateType,
            dictionary: expectedDictionary
        }));

        address dictionary = $daoTemplates.getDictionary(_templateType);

        // Assert that the correct dictionary address is returned
        assertEq(dictionary, expectedDictionary, "The dictionary address should match.");
    }

    function test_getDictionary_notFound() public view {
        Schema.TemplateType _templateType = Schema.TemplateType.TextDAO;
        address dictionary = $daoTemplates.getDictionary(_templateType);

        // Assert that the dictionary address is zero for a non-existent template
        assertEq(dictionary, address(0), "The dictionary address should be zero for a non-existent template.");
    }
}
