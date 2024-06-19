// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


import { console2 } from "forge-std/console2.sol";
import { Script } from "forge-std/Script.sol";

import { TextDAOFacade } from "bundle/textDAO/interfaces/TextDAOFacade.sol";
import { Schema } from "bundle/textDAO/storages/Schema.sol";
import { Types } from "bundle/textDAO/storages/Types.sol";
import { MemberJoinProtected } from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";

contract Filler is Script {

    function run() public {
        address textdaoAddr = vm.envOr("TEXT_DAO_ADDR", address(0));
        TextDAOFacade textdao = TextDAOFacade(textdaoAddr);


        Schema.Member[] memory initialMembers = new Schema.Member[](1);
        initialMembers[0].addr = address(this); // Example initial member address
        try textdao.initialize(initialMembers, Schema.DeliberationConfig({
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
        uint proposalId = textdao.propose(proposalArg);
        require(plannedProposalId == proposalId, "Proposal IDs do not match");


        vm.warp(block.timestamp + 20);


        uint[3] memory cmdIds = [uint(0), uint(1), uint(2)]; // Example cmdIds, replace with actual command IDs
        textdao.voteCmds(proposalId, cmdIds);

    }
}
