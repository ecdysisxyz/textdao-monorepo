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
        string headerMetadataCid1;
        string headerMetadataCid2;
        string memberMetadataCid1;
        string memberMetadataCid2;
        string textMetadataCid1;
        string textMetadataCid2;
    }
    function fillSampleData(MCDevKit storage mc, address _textDAO) internal {
        Vars memory __;

        TextDAOWithCheatsFacade textDAO = TextDAOWithCheatsFacade(_textDAO);

        __.key1 = mc.loadPrivateKey("DEPLOYER_PRIV_KEY");
        __.key2 = mc.loadPrivateKey("MEMBER2_PRIV_KEY");
        __.sender = ForgeHelper.msgSender();
        __.sender2 = vm.addr(__.key2);
        __.headerMetadataCid1 = "QmS2gdi4CRx4bXeaZgchp9SNs3B5oFaxjyDEVYTcdcfgzE";
        __.headerMetadataCid2 = "Qmeo92GcxD6mamU5YbTiWAYJJRGrk8phUwcM4tMENLsBsC";
        __.memberMetadataCid1 = "QmcLfVoJ8wi95symVPZTvKizjQsV7BFcTBRLxL8przFJrS";
        __.memberMetadataCid2 = "QmXBH4kKdQTDWK5Yw677o5bENQHZaPqQsoSj1Ua39gZiAA";
        __.textMetadataCid1 = "QmQEJ3TDEwG1PShJu1P2fw5W5Ap2AmPiLma3BJJ2xkTmfW";
        __.textMetadataCid2 = "Qma9J9dqZC6ASDYahGRXsqewNMMe5o3pXne5F9d792pgpQ";

        address[] memory _newMembers = new address[](1);
        _newMembers[0] = __.sender2;
        textDAO.addMembers(_newMembers);

        // Create proposal
        uint256 _expirationTime = block.timestamp + TextDAODeployer.initialConfig().expiryDuration;
        address[] memory _reps = new address[](3);
        _reps[0] = __.sender;
        _reps[1] = __.sender2;
        // _reps[2] = MEMBER3;
        vm.expectEmit();
        emit TextDAOEvents.HeaderCreated(0, 1, __.headerMetadataCid1);
        emit TextDAOEvents.RepresentativesAssigned(0, _reps);
        emit TextDAOEvents.Proposed(0, __.sender, block.timestamp, _expirationTime, TextDAODeployer.initialConfig().snapInterval);
        uint256 _pid = textDAO.propose(__.headerMetadataCid1, new Schema.Action[](0));

        // Fork proposal
        Schema.Action[] memory _actions = new Schema.Action[](2);
        _actions[0] = Schema.Action({
            funcSig: "createText(uint256,string)",
            abiParams: abi.encode(_pid, __.textMetadataCid1)
        });
        Schema.Member[] memory _memberCandidates = new Schema.Member[](1);
        _memberCandidates[0] = Schema.Member({
            addr: address(this),
            metadataCid: __.memberMetadataCid1
        });
        _actions[1] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(_pid, _memberCandidates)
        });
        vm.expectEmit(true, true, true, true);
        emit TextDAOEvents.HeaderCreated(_pid, 2, __.headerMetadataCid2);
        emit TextDAOEvents.CommandCreated(_pid, 1, _actions);
        textDAO.fork(_pid, __.headerMetadataCid2, _actions);

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

    function upgradeAdminCheats(MCDevKit storage mc, address textDAO, address deployer) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.addAdmins.selector, newCheats);
        _dictionary.set(OnlyAdminCheats.forceAddAdmin.selector, newCheats);
        OnlyAdminCheats(textDAO).forceAddAdmin(deployer);
        OnlyAdminCheats(textDAO).forceAddAdmin(0x82911187eAA5230f6831A301bE88ef55158f4625);
        // _dictionary.set(OnlyAdminCheats.forceAddAdmin.selector, address(0));
        _dictionary.set(OnlyAdminCheats.addMembers.selector, newCheats);
        _dictionary.set(OnlyAdminCheats.updateConfig.selector, newCheats);
        _dictionary.set(OnlyAdminCheats.transferAdmin.selector, newCheats);
        _dictionary.set(OnlyAdminCheats.forceTally.selector, newCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

    function addForceApproveAdminCheat(MCDevKit storage mc, address textDAO, address deployer) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        address newCheats = address(new OnlyAdminCheats());
        _dictionary.set(OnlyAdminCheats.forceApprove.selector, newCheats);
        _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

    function upgradeTallyAndExecute(MCDevKit storage mc, address textDAO) internal {
        Dictionary memory _dictionary = mc.loadDictionary("TextDAODictionary", mc.getDictionaryAddress(textDAO));
        _dictionary.set(Tally.tally.selector, address(new Tally()));
        // _dictionary.upgradeFacade(address(new TextDAOWithCheatsFacade())); // for Etherscan proxy read/write
    }

}
