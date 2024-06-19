// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2, StdChains} from "@devkit/Flattened.sol";

import {TestUtils} from "test/fixtures/TestUtils.sol";

import {DeployLib} from "script/deployment/DeployLib.sol";
import {TextDAOFacade, Schema} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

import {Types} from "bundle/textDAO/storages/Types.sol";

contract TextDAOAnvilSimulation is MCTest {
    TextDAOFacade textDAO;

    function setUp() public {
        StdChains.Chain memory chain = getChain("anvil");
        vm.createSelectFork(chain.rpcUrl);
        string memory envKey = string.concat("TEXT_DAO_ADDR_", vm.toString(chain.chainId));
        address textDAOAddr = vm.envAddress(envKey);
        if (textDAOAddr.code.length == 0) revert("TextDAO Not Deployed Yet");
        textDAO = TextDAOFacade(textDAOAddr);
    }

    function test_scenario() public {
        Schema.Member[] memory initialMembers = new Schema.Member[](1);
        initialMembers[0].addr = address(this); // Example initial member address
        try textDAO.initialize(initialMembers, Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            tallyInterval: 1 minutes,
            repsNum: 1,
            quorumScore: 3
        })) {} catch {
            console2.log("Initialization failed but skipped.");
        }


        vm.warp(block.timestamp + 20);


        Schema.ProposalMeta memory proposalMeta = Schema.ProposalMeta({
            currentScore: 0,
            headerRank: new uint[](0),
            cmdRank: new uint[](0),
            nextHeaderTallyFrom: 0,
            nextCmdTallyFrom: 0,
            reps: new address[](1),
            createdAt: block.timestamp,
            vrfRequestId: 0
        });
        proposalMeta.reps[0] = address(this);
        Types.ProposalArg memory proposalArg = Types.ProposalArg({
            header: Schema.Header({
                id: 0,
                currentScore: 0,
                metadataURI: bytes32("Implement MemberJoinProtected"),
                tagIds: new uint[](0)
            }),
            cmd: Schema.Command({
                id: 0,
                actions: new Schema.Action[](1),
                currentScore: 0
            }),
            proposalMeta: proposalMeta
        });

        uint plannedProposalId = 0;
        Schema.Member[] memory candidates = new Schema.Member[](1); // Assuming there's one candidate for demonstration
        candidates[0] = Schema.Member({
            addr: 0x1234567890123456789012345678901234567890, // Example candidate address
            metadataURI: "exampleURI" // Example metadata URI
        });

        proposalArg.cmd.actions[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(plannedProposalId, candidates),
            status: Schema.ActionStatus.Proposed
        });
        uint proposalId = textDAO.propose(proposalArg);
        require(plannedProposalId == proposalId, "Proposal IDs do not match");


        vm.warp(block.timestamp + 20);


        uint[3] memory cmdIds = [uint(0), uint(1), uint(2)]; // Example cmdIds, replace with actual command IDs
        textDAO.voteCmds(proposalId, cmdIds);

    }

}
