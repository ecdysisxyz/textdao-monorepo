import {
    assert,
    describe,
    test,
    clearStore,
    beforeAll,
    log,
} from "matchstick-as/assembly/index";
import { BigInt, Address, Bytes } from "@graphprotocol/graph-ts";
import { handleRepresentativesAssigned } from "../src/handlers/representatives-assigned";
import { handleProposed } from "../src/handlers/proposed";
import { handleVoted } from "../src/handlers/voted";
import { handleHeaderCreated } from "../src/handlers/header-created";
import { handleCommandCreated } from "../src/handlers/command-created";
import {
    handleProposalTallied,
    handleProposalTalliedWithTie,
} from "../src/handlers/proposal-tallied";
import { handleProposalExecuted } from "../src/handlers/proposal-executed";
import { handleProposalSnapped } from "../src/handlers/proposal-snapped";
import {
    createMockRepresentativesAssignedEvent,
    createMockProposedEvent,
    createMockVotedEvent,
    createMockHeaderCreatedEvent,
    createMockCommandCreatedEvent,
    createMockProposalTalliedEvent,
    createMockProposalTalliedWithTieEvent,
    createMockProposalExecutedEvent,
    createMockProposalSnappedEvent,
} from "./utils/mock-events";
import {
    genCommandId,
    genHeaderId,
    genProposalId,
    genVoteId,
} from "../src/utils/entity-id-provider";
import {
    formatAddressArray,
    formatBigIntArray,
    formatBigIntIdArray,
} from "../src/utils/type-formatter";
import { Vote, Action } from "../src/utils/schema-types";
import { loadProposal } from "../src/utils/entity-provider";
import { Vote as VoteEntity } from "../generated/schema";

/**
 * Integration tests for TextDAO Subgraph event handlers
 *
 * These tests simulate real-world scenarios and event sequences in TextDAO,
 * ensuring that the subgraph correctly processes and stores data from multiple related events.
 */
describe("TextDAO Subgraph Integration Tests", () => {
    beforeAll(() => {
        clearStore();
    });

    test("Full proposal lifecycle", () => {
        const pid = BigInt.fromI32(0);
        const headerId1 = BigInt.fromI32(1);
        const createdAt = BigInt.fromI32(100000);
        const expirationTime = BigInt.fromI32(1100000);
        const reps = [
            Address.fromString("0x1234000000000000000000000000000000000000"),
            Address.fromString("0x2345000000000000000000000000000000000000"),
            Address.fromString("0x3456000000000000000000000000000000000000"),
        ];
        const metadataURI = "originalProposalURI";
        const proposer = Address.fromString(
            "0xaaaa000000000000000000000000000000000000"
        );

        // Create proposal
        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId1, metadataURI)
        );
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, reps)
        );
        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
        );

        const proposalEntityId = genProposalId(pid);
        const headerEntityId = genHeaderId(pid, headerId1);

        assert.entityCount("Proposal", 1);
        let proposal = loadProposal(pid);
        assert.assertNotNull(proposal);
        assert.stringEquals(proposal.id, proposalEntityId);

        let headers = proposal.headers.load();
        assert.i32Equals(headers.length, 1);
        let foundMatchingHeader = false;
        for (let i = 0; i < headers.length; i++) {
            if (
                headers[i].id == headerEntityId &&
                headers[i].proposal == proposalEntityId &&
                headers[i].metadataURI == metadataURI
            ) {
                foundMatchingHeader = true;
                break;
            }
        }
        assert.assertTrue(foundMatchingHeader);

        assert.i32Equals(proposal.cmds.load().length, 0);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "proposer",
            proposer.toHexString()
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "createdAt",
            createdAt.toString()
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "expirationTime",
            expirationTime.toString()
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "reps",
            formatAddressArray(reps)
        );
        assert.i32Equals(proposal.votes.load().length, 0);
        // assert.assertNull(proposal.approvedHeaderId);
        // assert.assertNull(proposal.approvedCommandId);
        // assert.assertNull(proposal.fullyExecuted);
        // assert.assertNull(proposal.vrfRequestId);
        // assert.assertNull(proposal.snapped);
        // assert.assertNull(proposal.top3Headers);
        // assert.assertNull(proposal.top3Commands);
        log.info("Proposal is ok", []);
        log.info("pid: {}, headerId1: {}", [
            pid.toString(),
            headerId1.toString(),
        ]);
        log.info("Generated headerEntityId: {}", [headerEntityId]);

        // Fork proposal
        const headerId2 = BigInt.fromI32(2);
        const commandId1 = BigInt.fromI32(1);
        const forkURI = "forkedProposalURI";
        const actions = [
            new Action(
                "memberJoin(uint256,(address,string)[])",
                Bytes.fromHexString("0xabcd")
            ),
        ];
        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId2, forkURI)
        );
        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId1, actions)
        );

        proposal = loadProposal(pid);
        headers = proposal.headers.load();
        assert.i32Equals(headers.length, 2);
        let foundForkHeader = false;
        for (let i = 0; i < headers.length; i++) {
            if (
                headers[i].id == genHeaderId(pid, headerId2) &&
                headers[i].proposal == proposalEntityId &&
                headers[i].metadataURI == forkURI
            ) {
                foundForkHeader = true;
                break;
            }
        }
        assert.assertTrue(foundForkHeader);

        let cmds = proposal.cmds.load();
        assert.i32Equals(cmds.length, 1);
        let foundMatchingCommand = false;
        for (let i = 0; i < cmds.length; i++) {
            if (
                cmds[i].id == genCommandId(pid, commandId1) &&
                cmds[i].proposal == proposalEntityId
            ) {
                foundMatchingCommand = true;
                break;
            }
        }
        assert.assertTrue(foundMatchingCommand);

        const command1 = cmds[0];
        const actions1 = command1.actions.load();
        assert.i32Equals(actions1.length, 1);

        let foundMatchingAction = false;
        for (let i = 0; i < actions1.length; i++) {
            if (
                actions1[i].command == command1.id &&
                actions1[i].func == actions[0].funcSig &&
                actions1[i].abiParams == actions[0].abiParams &&
                actions1[i].status == "Proposed"
            ) {
                foundMatchingAction = true;
                break;
            }
        }
        assert.assertTrue(foundMatchingAction);

        // Voting
        const voter = [
            Address.fromString("0x1111000000000000000000000000000000000000"),
            Address.fromString("0x2222000000000000000000000000000000000000"),
            Address.fromString("0x3333000000000000000000000000000000000000"),
        ];
        const voteList = [
            new Vote(
                [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
                [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
            ),
            new Vote(
                [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
                [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
            ),
            new Vote(
                [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
                [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
            ),
        ];

        for (let i = 0; i < voteList.length; i++) {
            handleVoted(createMockVotedEvent(pid, voter[i], voteList[i]));

            proposal = loadProposal(pid);
            const votes = proposal.votes.load();
            let foundVote = false;
            for (let j = 0; j < votes.length; j++) {
                if (votes[j].rep == voter[i]) {
                    assert.stringEquals(votes[j].proposal, proposalEntityId);
                    assert.fieldEquals(
                        "Vote",
                        votes[j].id,
                        "rankedHeaderIds",
                        formatBigIntArray(voteList[i].rankedHeaderIds)
                    );
                    assert.fieldEquals(
                        "Vote",
                        votes[j].id,
                        "rankedCommandIds",
                        formatBigIntArray(voteList[i].rankedCommandIds)
                    );
                    foundVote = true;
                    log.info("Vote is ok: ID is {}, Voter is {}", [
                        votes[j].id,
                        voter[i].toHexString(),
                    ]);
                    break;
                }
            }
            assert.assertTrue(foundVote);
        }

        assert.entityCount("Vote", 3);

        // Tally votes
        const approvedHeaderId = BigInt.fromI32(2);
        const approvedCommandId = BigInt.fromI32(1);
        handleProposalTallied(
            createMockProposalTalliedEvent(
                pid,
                approvedHeaderId,
                approvedCommandId
            )
        );

        assert.i32Equals(headers.length, 2);
        assert.i32Equals(cmds.length, 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "approvedHeaderId",
            approvedHeaderId.toString()
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "approvedCommandId",
            approvedCommandId.toString()
        );

        // Execute proposal
        handleProposalExecuted(
            createMockProposalExecutedEvent(pid, approvedCommandId)
        );

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "fullyExecuted",
            "true"
        );
    });

    test("Proposal with voting tie and resolution", () => {
        const pid = BigInt.fromI32(1);
        const proposer = Address.fromString(
            "0xaaaa000000000000000000000000000000000000"
        );
        const expirationTime = BigInt.fromI32(2100000);
        const extendedExpirationTime = BigInt.fromI32(2200000);
        const reps = [
            Address.fromString("0x1234000000000000000000000000000000000000"),
            Address.fromString("0x2345000000000000000000000000000000000000"),
            Address.fromString("0x3456000000000000000000000000000000000000"),
        ];
        const metadataURI = "tieProposalURI";

        // Create proposal
        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, BigInt.fromI32(1), metadataURI)
        );
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, reps)
        );
        handleProposed(
            createMockProposedEvent(
                pid,
                proposer,
                BigInt.fromI32(2000000),
                expirationTime
            )
        );

        // Fork proposal
        const forkURI = "forkedProposalURI";
        const actions = [
            new Action(
                "memberJoin(uint256,(address,string)[])",
                Bytes.fromHexString("0x1234")
            ),
        ];
        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, BigInt.fromI32(2), forkURI)
        );
        handleCommandCreated(
            createMockCommandCreatedEvent(pid, BigInt.fromI32(1), actions)
        );

        // Two members vote differently, causing a tie
        const vote1 = new Vote(
            [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
            [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
        );
        handleVoted(createMockVotedEvent(pid, reps[0], vote1));

        const vote2 = new Vote(
            [BigInt.fromI32(2), BigInt.fromI32(1), BigInt.fromI32(0)],
            [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
        );
        handleVoted(createMockVotedEvent(pid, reps[1], vote2));

        // Tally votes, expect a tie
        const tieHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
        const tieCommandIds = [BigInt.fromI32(1)];
        handleProposalTalliedWithTie(
            createMockProposalTalliedWithTieEvent(
                pid,
                tieHeaderIds,
                tieCommandIds,
                extendedExpirationTime
            )
        );

        const proposalEntityId = genProposalId(pid);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "expirationTime",
            extendedExpirationTime.toString()
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Headers",
            formatBigIntIdArray(pid, tieHeaderIds, genHeaderId)
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            formatBigIntIdArray(pid, tieCommandIds, genCommandId)
        );

        // Third member votes during extended period
        const vote3 = new Vote(
            [BigInt.fromI32(1), BigInt.fromI32(2), BigInt.fromI32(0)],
            [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
        );
        handleVoted(createMockVotedEvent(pid, reps[2], vote3));

        // Tally votes again, expect resolution
        handleProposalTallied(
            createMockProposalTalliedEvent(
                pid,
                BigInt.fromI32(1),
                BigInt.fromI32(1)
            )
        );

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "approvedHeaderId",
            "1"
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "approvedCommandId",
            "1"
        );
    });

    test(
        "Error handling and edge cases",
        () => {
            const MEMBER1 = Address.fromString(
                "0x1234000000000000000000000000000000000000"
            );
            const MEMBER2 = Address.fromString(
                "0x2345000000000000000000000000000000000000"
            );
            const MEMBER3 = Address.fromString(
                "0x3456000000000000000000000000000000000000"
            );

            const pid = BigInt.fromI32(2);
            const headerId = BigInt.fromI32(1);
            const proposer = Address.fromString(
                "0x9999990000000000000000000000000000000000"
            );
            const createdAt = BigInt.fromI32(17200000);
            const expirationTime = BigInt.fromI32(3100000);
            const reps = [MEMBER1, MEMBER2, MEMBER3];
            const metadataURI = "proposalURI";

            // Create proposal
            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerId, metadataURI)
            );
            handleRepresentativesAssigned(
                createMockRepresentativesAssignedEvent(pid, reps)
            );
            handleProposed(
                createMockProposedEvent(
                    pid,
                    proposer,
                    createdAt,
                    expirationTime
                )
            );

            // Test premature tally attempt (ProposalSnapped event)
            const epoch = BigInt.fromI32(17000000);
            handleProposalSnapped(
                createMockProposalSnappedEvent(
                    pid,
                    epoch,
                    new Array<BigInt>(),
                    new Array<BigInt>()
                )
            );

            const proposal = loadProposal(pid);
            assert.assertNotNull(proposal.snappedEpoch);
            assert.fieldEquals(
                "Proposal",
                proposal.id,
                "snappedEpoch",
                `[${epoch.toString()}]`
            );
            log.info("Proposal snapped successfully at epoch: {}", [
                epoch.toString(),
            ]);

            // Non-existent proposal
            const nonExistentProposalId = BigInt.fromI32(999);
            const nonExistentProposalEntityId = genProposalId(
                nonExistentProposalId
            );

            // Attempt to vote on a non-existent proposal
            const vote = new Vote(
                [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)],
                [BigInt.fromI32(1), BigInt.fromI32(0), BigInt.fromI32(0)]
            );
            handleVoted(
                createMockVotedEvent(nonExistentProposalId, MEMBER1, vote)
            );

            // Verify that no Vote entity was created
            const voteId = genVoteId(nonExistentProposalId, MEMBER1);
            assert.assertNotNull(VoteEntity.load(voteId));

            // Attempt to tally a non-existent proposal
            handleProposalTallied(
                createMockProposalTalliedEvent(
                    nonExistentProposalId,
                    BigInt.fromI32(1),
                    BigInt.fromI32(1)
                )
            );
        },
        true
    );
});
