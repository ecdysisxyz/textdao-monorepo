// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {DeployLib} from "script/deployment/DeployLib.sol";
import {TextDAOFacade, Schema} from "bundle/textDAO/interfaces/TextDAOFacade.sol";

import {Types} from "bundle/textDAO/storages/Types.sol";

import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";

contract TextDAOScenarioTest is MCTest {
    TextDAOFacade textDAO;

    function setUp() public {
        textDAO = TextDAOFacade(DeployLib.deployTextDAO(mc));
    }

    function test_scenario_withoutVrf() public {
        // 1. initialize
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = address(this); // Example initial member address

        Schema.DeliberationConfig memory pConfig = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            tallyInterval: 1 minutes,
            repsNum: 1000,
            quorumScore: 3
        });

        textDAO.initialize(initialMembers, pConfig);


        // 2. propose
        Types.ProposalArg memory _p;

        uint256 pid0 = textDAO.propose(_p);
        uint256 pid1 = textDAO.propose(_p);
        uint256 pid2 = textDAO.propose(_p);


        // 3. fork
        _p.header.metadataURI = "Qm...";
        _p.cmd.actions = new Schema.Action[](1);
        _p.cmd.actions[0] = Schema.Action({
            func: "memberJoin(uint256,(uint256,address,bytes32)[])",
            abiParams: abi.encode(pid1, new Schema.Member[](1))
        });

        Types.ProposalArg memory _p2;
        _p2.header.metadataURI = "Qm.......";
        _p2.cmd.actions = new Schema.Action[](1);
        _p2.cmd.actions[0] = Schema.Action({
            func: "saveText(uint256,uint256,bytes32[])",
            abiParams: abi.encode(1, 1, new bytes32[](1))
        });

        Types.ProposalArg memory _p3;
        _p3.header.metadataURI = "Qm.......";
        _p3.cmd.actions = new Schema.Action[](1);
        _p3.cmd.actions[0] = Schema.Action({
            func: "saveText(uint256,uint256,bytes32[])",
            abiParams: abi.encode(pid0, new Schema.Member[](1)) // TODO Oops...
        });

        textDAO.fork(pid0, _p);
        textDAO.fork(pid0, _p);
        textDAO.fork(pid1, _p2);
        textDAO.fork(pid0, _p);
        textDAO.fork(pid0, _p);
        textDAO.fork(pid1, _p);
        textDAO.fork(pid1, _p);
        textDAO.fork(pid0, _p);
        textDAO.fork(pid0, _p);
        textDAO.fork(pid2, _p3); // TODO need at least 3 forks to tally
        textDAO.fork(pid2, _p3);
        textDAO.fork(pid2, _p3);


        // 4. vote
        uint[3] memory _headerIds = [uint(2), 1, 0];
        uint[3] memory _headerIds1 = [uint(3), 1, 0];
        uint[3] memory _headerIds2 = [uint(0), 1, 0];
        textDAO.voteHeaders(pid0, _headerIds2);
        textDAO.voteHeaders(pid0, _headerIds1);
        textDAO.voteHeaders(pid0, _headerIds2);
        textDAO.voteHeaders(pid1, _headerIds2);
        textDAO.voteHeaders(pid1, _headerIds2);
        textDAO.voteHeaders(pid0, _headerIds1);
        textDAO.voteHeaders(pid0, _headerIds2);
        textDAO.voteCmds(pid0, _headerIds2);
        textDAO.voteCmds(pid0, _headerIds2);
        textDAO.voteCmds(pid0, _headerIds2);
        textDAO.voteCmds(pid1, _headerIds2);
        textDAO.voteCmds(pid1, _headerIds2);
        textDAO.voteCmds(pid1, _headerIds2);
        textDAO.voteCmds(pid2, _headerIds2);


        // 5. tally
        textDAO.tally(pid0);
        textDAO.tally(pid1);
        textDAO.tally(pid2);


        // 6. execute
        vm.warp(block.timestamp + pConfig.expiryDuration + 1);
        textDAO.execute(pid0);
        textDAO.execute(pid1);
        textDAO.execute(pid2);

    }

    function test_filler() public {
        address[] memory initialMembers = new address[](1);
        initialMembers[0] = address(this); // Example initial member address
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
            nextRepId: 0,
            createdAt: block.timestamp
        });
        proposalMeta.reps[0] = address(this);
        proposalMeta.nextRepId = 1;
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
            id: 123, // Example candidate ID
            addr: 0x1234567890123456789012345678901234567890, // Example candidate address
            metadataURI: "exampleURI" // Example metadata URI
        });

        proposalArg.cmd.actions[0] = Schema.Action({
            func: "memberJoin(uint256,address[])",
            abiParams: abi.encode(plannedProposalId, candidates)
        });
        uint proposalId = textDAO.propose(proposalArg);
        require(plannedProposalId == proposalId, "Proposal IDs do not match");


        vm.warp(block.timestamp + 20);


        uint[3] memory cmdIds = [uint(0), uint(1), uint(2)]; // Example cmdIds, replace with actual command IDs
        textDAO.voteCmds(proposalId, cmdIds);

    }

}
