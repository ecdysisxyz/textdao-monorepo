// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary, ForgeHelper, vm, console2} from "@devkit/Flattened.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {OnlyAdminCheats} from "bundle/textDAO/functions/_cheat/OnlyAdminCheats.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";
import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {ITextDAO} from "bundle/textDAO/interfaces/ITextDAO.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

import {TextDAOWithCheatsFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

library TextDAOUpgrader {

    /**
     * upgrade forceTally
     */
    function upgradeForceTally(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.forceTally.selector, newCheats);
    }

    /**
     * Rollback tally & forceTally to w/o execute version
     * and then add tallyAndExecute & forceApproveAndExecute functions
     */
    function rollbackTallyAndAddTallyWithExecute(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));

        address newTally = address(new Tally());
        address newCheats = address(new OnlyAdminCheats());

        // Rollback
        _dictionary.set(Tally.tally.selector, newTally);
        _dictionary.set(OnlyAdminCheats.forceTally.selector, newCheats);

        // Add new
        _dictionary.set(Tally.tallyAndExecute.selector, newTally);
        _dictionary.set(OnlyAdminCheats.forceApproveAndExecute.selector, newCheats);

        // Upgrade facade
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }
}
