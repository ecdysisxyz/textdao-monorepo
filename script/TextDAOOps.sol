// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCDevKit, Dictionary_1 as Dictionary, ForgeHelper, vm} from "@devkit/Flattened.sol";
import {TextDAODeployer} from "script/TextDAODeployer.sol";
import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {OnlyAdminCheats} from "bundle/textDAO/functions/_cheat/OnlyAdminCheats.sol";
import {Tally} from "bundle/textDAO/functions/Tally.sol";
import {Initialize} from "bundle/textDAO/functions/initializer/Initialize.sol";
import {ITextDAO} from "bundle/textDAO/interfaces/ITextDAO.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

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

    function upgradeTallyEvent(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        _dictionary.set(Tally.tally.selector, address(new Tally()));
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

    function upgradeAndClone(MCDevKit storage mc, address textDAO, address admin) internal returns(address) {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address cheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.addMembers.selector, cheats);
        _dictionary.set(OnlyAdminCheats.transferAdmin.selector, cheats);
        _dictionary.set(OnlyAdminCheats.updateConfig.selector, cheats);
        _dictionary.set(Tally.tally.selector, address(new Tally()));
        _dictionary.set(Initialize.initialize.selector, address(new Initialize()));
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
        return ITextDAO(textDAO).clone(
            abi.encodeCall(Initialize.initialize,
                (TextDAODeployer.initialMember(admin), TextDAODeployer.initialConfig())
            )
        );
    }

    struct Vars {
        uint256 key1;
        uint256 key2;
        address sender;
        address sender2;
    }
    function fillSampleData(MCDevKit storage mc, address _textDAO) internal {
        Vars memory __;

        TextDAOWithCheatsFacade textDAO = TextDAOWithCheatsFacade(_textDAO);

        __.key1 = mc.loadPrivateKey("DEPLOYER_PRIV_KEY");
        __.key2 = mc.loadPrivateKey("MEMBER2_PRIV_KEY");
        __.sender = ForgeHelper.msgSender();
        __.sender2 = vm.addr(__.key2);

        address[] memory _newMembers = new address[](1);
        _newMembers[0] = __.sender2;
        textDAO.addMembers(_newMembers);

        // Create proposal
        uint256 _expirationTime = block.timestamp + TextDAODeployer.initialConfig().expiryDuration;
        address[] memory _reps = new address[](3);
        _reps[0] = __.sender;
        _reps[1] = __.sender2;
        // _reps[2] = MEMBER3;
        string memory _metadataURI = "QmStEMeSBhmakCDyKQDYuTcRCMveCMmA5C5kwmXLBbr8YD";
        vm.expectEmit();
        emit TextDAOEvents.HeaderCreated(0, 1, _metadataURI);
        emit TextDAOEvents.RepresentativesAssigned(0, _reps);
        emit TextDAOEvents.Proposed(0, __.sender, block.timestamp, _expirationTime);
        uint256 _pid = textDAO.propose(_metadataURI, new Schema.Action[](0));

        // Fork proposal
        string memory _forkURI = "forkedProposalURI";
        Schema.Action[] memory _actions = new Schema.Action[](1);
        _actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, new Schema.Member[](1))
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(_pid, 2, _forkURI);
        emit TextDAOEvents.CommandCreated(_pid, 1, _actions);
        textDAO.fork(_pid, _forkURI, _actions);

        // Two members vote differently, causing a tie
        Schema.Vote memory _vote1 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, __.sender, _vote1);
        textDAO.vote(_pid, _vote1);

        vm.stopBroadcast();
        vm.startBroadcast(__.key2);
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(2), 1, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, __.sender2, _vote2);
        textDAO.vote(_pid, _vote2);

        // Wait for initial expiry
        // vm.warp(_expirationTime + 1);
        vm.stopBroadcast();
        vm.startBroadcast(__.key1);

        // Tally votes, expect a tie
        uint256[] memory _tieHeaderIds = new uint256[](2);
        _tieHeaderIds[0] = 1;
        _tieHeaderIds[1] = 2;
        uint256[] memory _tieCommandIds = new uint256[](1);
        _tieCommandIds[0] = 1;
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTalliedWithTie(_pid, _tieHeaderIds, _tieCommandIds, _expirationTime + TextDAODeployer.initialConfig().expiryDuration);
        textDAO.forceTally(_pid);

        // Third member votes during extended period
        // vm.prank(MEMBER3);
        vm.stopBroadcast();
        vm.startBroadcast(__.key2);
        Schema.Vote memory _vote3 = Schema.Vote({
            rankedHeaderIds: [uint(1), 2, 0],
            rankedCommandIds: [uint(1), 0, 0]
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.Voted(_pid, __.sender2, _vote3);
        textDAO.vote(_pid, _vote3);

        // Wait for extended expiry
        // vm.warp(_expirationTime + TextDAODeployer.initialConfig().expiryDuration + 1);
        vm.stopBroadcast();
        vm.startBroadcast(__.key1);

        // Tally votes again, expect resolution
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.ProposalTallied(_pid, 1, 1);
        textDAO.forceTally(_pid);
    }
}
