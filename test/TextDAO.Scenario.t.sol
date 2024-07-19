// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console2} from "@devkit/Flattened.sol";

import {DeployLib} from "script/deployment/DeployLib.sol";
import {ITextDAO, Schema} from "bundle/textDAO/interfaces/ITextDAO.sol";
import {IPropose, IFork} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";

import {Types} from "bundle/textDAO/storages/Types.sol";

import {MemberJoinProtected} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";

contract TextDAOScenarioTest is MCTest {
    ITextDAO textDAO;

    function setUp() public {
        textDAO = ITextDAO(DeployLib.deployTextDAO(mc));
    }

    function test_scenario_withoutVrf() public {
        // 1. initialize
        Schema.Member[] memory initialMembers = new Schema.Member[](1);
        initialMembers[0].addr = address(this); // Example initial member address

        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 2 minutes,
            snapInterval: 1 minutes,
            repsNum: 1000,
            quorumScore: 3
        });

        textDAO.initialize(initialMembers, _config);


        // 2. propose
        IPropose.ProposeArgs memory _pArgs;
        _pArgs.headerMetadataURI = "cid:XXX";

        uint256 pid0 = textDAO.propose(_pArgs);
        uint256 pid1 = textDAO.propose(_pArgs);
        uint256 pid2 = textDAO.propose(_pArgs);


        // 3. fork
        string memory headerMetadataURI1 = "Qm...";
        string memory headerMetadataURI2 = "Qm.......";
        string memory headerMetadataURI3 = "Qm.......aaa";
        Schema.Action[] memory actions1 = new Schema.Action[](1);
        actions1[0] = Schema.Action({
            funcSig: "memberJoin(uint256,(address,string)[])",
            abiParams: abi.encode(pid1, new Schema.Member[](1))
        });
        Schema.Action[] memory actions2 = new Schema.Action[](1);
        actions2[0] = Schema.Action({
            funcSig: "saveText(uint256,uint256,string[])",
            abiParams: abi.encode(1, 1, new string[](1))
        });
        Schema.Action[] memory actions3 = new Schema.Action[](1);
        actions3[0] = Schema.Action({
            funcSig: "saveText(uint256,uint256,string[])",
            abiParams: abi.encode(1, 1, new string[](2))
        });

        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid1, headerMetadataURI2, actions2);
        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid1, headerMetadataURI1, actions1);
        textDAO.fork(pid1, headerMetadataURI1, actions1);
        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid0, headerMetadataURI1, actions1);
        textDAO.fork(pid2, headerMetadataURI3, actions3); // TODO need at least 3 forks to tally
        textDAO.fork(pid2, headerMetadataURI3, actions3);
        textDAO.fork(pid2, headerMetadataURI3, actions3);


        // 4. vote
        // Schema.Vote memory _vote0 = Schema.Vote({
        //     rankedHeaderIds: [uint(2), 1, 0],
        //     rankedCommandIds: [uint(2), 1, 0]
        // });
        // Schema.Vote memory _vote1 = Schema.Vote({
        //     rankedHeaderIds: [uint(3), 1, 0],
        //     rankedCommandIds: [uint(3), 1, 0]
        // });
        Schema.Vote memory _vote2 = Schema.Vote({
            rankedHeaderIds: [uint(0), 1, 0],
            rankedCommandIds: [uint(0), 1, 0]
        });
        Schema.Vote memory _vote3 = Schema.Vote({
            rankedHeaderIds: [uint(3), 1, 0],
            rankedCommandIds: [uint(3), 0, 0]
        });
        Schema.Vote memory _vote4 = Schema.Vote({
            rankedHeaderIds: [uint(0), 0, 1],
            rankedCommandIds: [uint(0), 1, 0]
        });
        textDAO.vote(pid0, _vote2);
        textDAO.vote(pid0, _vote2);
        textDAO.vote(pid1, _vote2);
        textDAO.vote(pid1, _vote2);
        textDAO.vote(pid0, _vote2);
        textDAO.vote(pid0, _vote3);
        textDAO.vote(pid0, _vote3);
        textDAO.vote(pid1, _vote4);
        textDAO.vote(pid2, _vote4);


        // 5. tally
        vm.warp(block.timestamp + _config.expiryDuration + 1);
        // textDAO.tally(pid0);
        textDAO.tally(pid1);
        // textDAO.tally(pid2);


        // 6. execute
        // textDAO.execute(pid0);
        textDAO.execute(pid1);
        // textDAO.execute(pid2);

    }

    function test_filler() public {
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
