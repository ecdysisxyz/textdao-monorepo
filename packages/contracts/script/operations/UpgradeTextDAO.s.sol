// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.24;

// import {MCScript} from "@devkit/Flattened.sol";

// import {TextDAOFacade} from "bundle/textdao/interfaces/TextDAOFacade.sol";
// import {Propose} from "bundle/textdao/functions/onlyMember/Propose.sol";
// import {Vote} from "bundle/textdao/functions/onlyReps/Vote.sol";

// contract UpgradeTextDAOScript is MCScript {
//     function updateFacade() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
//         address textDAO = vm.envAddress("TEXT_DAO_ADDR");
//         mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO)).upgradeFacade(address(new TextDAOFacade()));
//     }

//     function upgradeProposeAndVote() public startBroadcastWith("DEPLOYER_PRIV_KEY") {
//         address textDAO = vm.envAddress("TEXT_DAO_ADDR");
//         address propose = address(new Propose());
//         address vote = address(new Vote());
//         mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO))
//             .set(Propose.propose.selector, propose);
//     }

//     function upgradeToWithCheat() public startBroadcastWith("DEPLOYER_PRIV_KEY") {

//     }
// }
