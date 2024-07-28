import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleVoted } from "../../src/event-handlers/voted";
import { genProposalId, genVoteId } from "../../src/utils/entity-id-provider";
import { createMockVotedEvent } from "../utils/mock-events";
import { Vote } from "../../src/utils/schema-types";
import { formatBigIntArray } from "../../src/utils/type-formatter";

describe("Voted Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create new Vote entity on Voted event", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const rankedHeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const rankedCommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const vote = new Vote(rankedHeaderIds, rankedCommandIds);

        handleVoted(createMockVotedEvent(pid, rep, vote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals("Vote", voteId, "proposal", genProposalId(pid));
        assert.fieldEquals("Vote", voteId, "rep", rep.toHexString());
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray(rankedHeaderIds)
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray(rankedCommandIds)
        );
    });

    test("Should update existing Vote entity on Voted event", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const initialRankedHeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const initialRankedCommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const updatedRankedHeaderIds = [
            BigInt.fromI32(3),
            BigInt.fromI32(2),
            BigInt.fromI32(1),
        ];
        const updatedRankedCommandIds = [
            BigInt.fromI32(3),
            BigInt.fromI32(2),
            BigInt.fromI32(1),
        ];

        const initialVote = new Vote(
            initialRankedHeaderIds,
            initialRankedCommandIds
        );
        const updatedVote = new Vote(
            updatedRankedHeaderIds,
            updatedRankedCommandIds
        );

        handleVoted(createMockVotedEvent(pid, rep, initialVote));
        handleVoted(createMockVotedEvent(pid, rep, updatedVote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray(updatedRankedHeaderIds)
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray(updatedRankedCommandIds)
        );
    });

    test("Should handle multiple votes for different proposals", () => {
        const pid1 = BigInt.fromI32(1);
        const pid2 = BigInt.fromI32(2);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const rankedHeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const rankedCommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const vote = new Vote(rankedHeaderIds, rankedCommandIds);

        handleVoted(createMockVotedEvent(pid1, rep, vote));
        handleVoted(createMockVotedEvent(pid2, rep, vote));

        assert.entityCount("Vote", 2);
        assert.fieldEquals(
            "Vote",
            genVoteId(pid1, rep),
            "proposal",
            genProposalId(pid1)
        );
        assert.fieldEquals(
            "Vote",
            genVoteId(pid2, rep),
            "proposal",
            genProposalId(pid2)
        );
    });

    test("Should handle votes with empty ranked arrays", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const emptyRankedIds: BigInt[] = [];
        const vote = new Vote(emptyRankedIds, emptyRankedIds);

        handleVoted(createMockVotedEvent(pid, rep, vote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals("Vote", voteId, "rankedHeaderIds", "[]");
        assert.fieldEquals("Vote", voteId, "rankedCommandIds", "[]");
    });

    test("Should handle votes with maximum array length", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const maxLengthArray: BigInt[] = [];
        for (let i = 0; i < 100; i++) {
            maxLengthArray.push(BigInt.fromI32(i));
        }
        const vote = new Vote(maxLengthArray, maxLengthArray);

        handleVoted(createMockVotedEvent(pid, rep, vote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray(maxLengthArray)
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray(maxLengthArray)
        );
    });

    test("Should handle votes with different lengths for rankedHeaderIds and rankedCommandIds", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const rankedHeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
        const rankedCommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const vote = new Vote(rankedHeaderIds, rankedCommandIds);

        handleVoted(createMockVotedEvent(pid, rep, vote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray(rankedHeaderIds)
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray(rankedCommandIds)
        );
    });

    test("Should handle multiple votes from the same representative for the same proposal", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const initialVote = new Vote(
            [BigInt.fromI32(1), BigInt.fromI32(2)],
            [BigInt.fromI32(1), BigInt.fromI32(2)]
        );
        const updatedVote = new Vote(
            [BigInt.fromI32(2), BigInt.fromI32(1)],
            [BigInt.fromI32(2), BigInt.fromI32(1)]
        );

        handleVoted(createMockVotedEvent(pid, rep, initialVote));
        handleVoted(createMockVotedEvent(pid, rep, updatedVote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray([BigInt.fromI32(2), BigInt.fromI32(1)])
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray([BigInt.fromI32(2), BigInt.fromI32(1)])
        );
    });

    test("Should handle votes with very large BigInt values", () => {
        const pid = BigInt.fromI32(1);
        const rep = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const largeValue = BigInt.fromString("1000000000000000000000000000000");
        const rankedIds = [
            largeValue,
            largeValue.plus(BigInt.fromI32(1)),
            largeValue.plus(BigInt.fromI32(2)),
        ];
        const vote = new Vote(rankedIds, rankedIds);

        handleVoted(createMockVotedEvent(pid, rep, vote));

        const voteId = genVoteId(pid, rep);
        assert.entityCount("Vote", 1);
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedHeaderIds",
            formatBigIntArray(rankedIds)
        );
        assert.fieldEquals(
            "Vote",
            voteId,
            "rankedCommandIds",
            formatBigIntArray(rankedIds)
        );
    });
});
