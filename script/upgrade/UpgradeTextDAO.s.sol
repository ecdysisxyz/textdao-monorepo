// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCScript} from "@devkit/Flattened.sol";

import {TextDAOFacade} from "bundle/textDAO/interfaces/TextDAOFacade.sol";
import {Propose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Vote} from "bundle/textDAO/functions/onlyReps/Vote.sol";

contract UpgradeTextDAOScript is MCScript {
    function updateFacade() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_ADDR");
        mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO)).upgradeFacade(address(new TextDAOFacade()));
    }

    function upgradeProposeAndVote() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
        address textDAO = vm.envAddress("TEXT_DAO_ADDR");
        address propose = address(new Propose());
        address vote = address(new Vote());
        mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO))
            .set(Propose.propose.selector, propose)
            .set(Vote.voteHeaders.selector, vote)
            .set(Vote.voteCmds.selector, vote);
    }
}
