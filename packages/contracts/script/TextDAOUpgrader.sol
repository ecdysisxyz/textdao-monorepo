// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary, ForgeHelper, vm, console} from "@mc-devkit/Flattened.sol";
import {OnlyAdminCheats} from "bundle/textdao/functions/_cheat/OnlyAdminCheats.sol";
import {Tally} from "bundle/textdao/functions/Tally.sol";
import {Fork} from "bundle/textdao/functions/onlyReps/Fork.sol";
import {Propose} from "bundle/textdao/functions/onlyMember/Propose.sol";
// protected functions
import {SaveTextProtected} from "bundle/textdao/functions/protected/SaveTextProtected.sol";
import {MemberJoinProtected} from "bundle/textdao/functions/protected/MemberJoinProtected.sol";
import {SetConfigsProtected} from "bundle/textdao/functions/protected/SetConfigsProtected.sol";

import {MembershipManagementProtected} from "bundle/textdao/functions/protected/MembershipManagementProtected.sol";

import {TextDAOWithCheatsFacade} from "bundle/textdao/interfaces/TextDAOFacade.sol";

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

    function upgradeProtectedFunctions(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));

        address newSaveText = address(new SaveTextProtected());
        _dictionary.set(SaveTextProtected.createText.selector, newSaveText);
        _dictionary.set(SaveTextProtected.updateText.selector, newSaveText);
        _dictionary.set(SaveTextProtected.deleteText.selector, newSaveText);

        address newMemberJoin = address(new MemberJoinProtected());
        _dictionary.set(MemberJoinProtected.memberJoin.selector, newMemberJoin);

        address newSetConfig = address(new SetConfigsProtected());
        _dictionary.set(SetConfigsProtected.setDebelirationConfig.selector, newSetConfig);

        // Upgrade facade
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    function addMembershipManagement(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));

        address _membershipManagement = address(new MembershipManagementProtected());
        _dictionary.set(MembershipManagementProtected.addMembers.selector, _membershipManagement);
        _dictionary.set(MembershipManagementProtected.updateMember.selector, _membershipManagement);
        _dictionary.set(MembershipManagementProtected.removeMember.selector, _membershipManagement);
        _dictionary.set(MembershipManagementProtected.leaveDAO.selector, _membershipManagement);

        // Upgrade facade
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    /**
     * upgrade propose
     */
    function upgradePropose(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newPropose = address(new Propose());
        _dictionary.set(Propose.propose.selector, newPropose);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    function upgradeCheatsForceApprove(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.forceApprove.selector, newCheats);
        _dictionary.set(OnlyAdminCheats.forceApproveAndExecute.selector, newCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    function upgradeFork(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newFork = address(new Fork());
        _dictionary.set(Fork.forkHeader.selector, newFork);
        _dictionary.set(Fork.forkCommand.selector, newFork);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    function upgradeTallyAndCheats(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newTally = address(new Tally());
        _dictionary.set(Tally.tally.selector, newTally);
        _dictionary.set(Tally.tallyAndExecute.selector, newTally);
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.forceTally.selector, newCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

    function addextendExpirationTimeCheat(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.extendExpirationTime.selector, newCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade()));
    }

}
