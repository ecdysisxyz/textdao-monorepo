// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary} from "@devkit/Flattened.sol";

import {OnlyAdminCheats} from "bundle/textDAO/functions/_cheat/OnlyAdminCheats.sol";

import {TextDAOWithCheatsFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

library TextDAOOps {
    function upgradeToTextDAOWithCheats(MCDevKit storage mc, address textDAO) internal {
        address onlyAdminCheats = address(new OnlyAdminCheats());
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        _dictionary.set(OnlyAdminCheats.addMembers.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.updateConfig.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.transferAdmin.selector, onlyAdminCheats);
        _dictionary.set(OnlyAdminCheats.forceTally.selector, onlyAdminCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }
}
