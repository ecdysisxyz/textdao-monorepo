// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2, StdChains} from "@devkit/Flattened.sol";

import {TestUtils} from "test/fixtures/TestUtils.sol";

import {DeployLib} from "script/deployment/DeployLib.sol";
import {ITextDAO, Schema} from "bundle/textDAO/interfaces/ITextDAO.sol";

import {IPropose} from "bundle/textDAO/functions/onlyMember/Propose.sol";
import {Types} from "bundle/textDAO/storages/Types.sol";

contract TextDAOAnvilSimulation is MCTest {
    ITextDAO textDAO;

    function setUp() public {
        StdChains.Chain memory chain = getChain("anvil");
        vm.createSelectFork(chain.rpcUrl);
        string memory envKey = string.concat("TEXT_DAO_ADDR_", vm.toString(chain.chainId));
        address textDAOAddr = vm.envAddress(envKey);
        if (textDAOAddr.code.length == 0) revert("TextDAO Not Deployed Yet");
        textDAO = ITextDAO(textDAOAddr);
    }

    function test_scenario() public {
        Schema.Member[] memory initialMembers = new Schema.Member[](1);
        initialMembers[0].addr = address(this); // Example initial member address
        try textDAO.initialize(initialMembers, Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 1,
            quorumScore: 3
        })) {} catch {
            console2.log("Initialization failed but skipped.");
        }


        vm.warp(block.timestamp + 20);


        // Schema.ProposalMeta memory proposalMeta = Schema.ProposalMeta({
        //     currentScore: 0,
        //     headerRank: new uint[](0),
        //     cmdRank: new uint[](0),
        //     nextHeaderTallyFrom: 0,
        //     nextCmdTallyFrom: 0,
        //     reps: new address[](1),
        //     createdAt: block.timestamp,
        //     expirationTime: block.timestamp + 2 minutes,
        //     vrfRequestId: 0
        // });
        // proposalMeta.reps[0] = address(this);
        IPropose.ProposeArgs memory _proposeArgs = IPropose.ProposeArgs({
            headerMetadataURI: "Implement MemberJoinProtected",
            actions: new Schema.Action[](1)
        });

        uint plannedProposalId = 0;
        Schema.Member[] memory candidates = new Schema.Member[](1); // Assuming there's one candidate for demonstration
        candidates[0] = Schema.Member({
            addr: 0x1234567890123456789012345678901234567890, // Example candidate address
            metadataURI: "exampleURI" // Example metadata URI
        });

        _proposeArgs.actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(plannedProposalId, candidates)
        });
        uint proposalId = textDAO.propose(_proposeArgs);
        require(plannedProposalId == proposalId, "Proposal IDs do not match");


        vm.warp(block.timestamp + 20);


        uint[3] memory cmdIds = [uint(0), uint(1), uint(2)]; // Example cmdIds, replace with actual command IDs
        textDAO.voteCmds(proposalId, cmdIds);

    }

}
