import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import {
    handleProposalTallied,
    handleProposalTalliedWithTie,
} from "../../src/handlers/proposal-tallied";
import {
    genProposalId,
    genHeaderId,
    genCommandId,
} from "../../src/utils/entity-id-provider";
import {
    createMockProposalTalliedEvent,
    createMockProposalTalliedWithTieEvent,
} from "../utils/mock-events";
import { createMockProposalEntity } from "../utils/mock-entities";
import { formatBigIntArray } from "../utils/type-formatter";

describe("ProposalTallied Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should update Proposal entity with approvedHeaderId and approvedCommandId", () => {
        const pid = BigInt.fromI32(100);
        const approvedHeaderId = BigInt.fromI32(1);
        const approvedCommandId = BigInt.fromI32(2);

        createMockProposalEntity(pid);

        handleProposalTallied(
            createMockProposalTalliedEvent(
                pid,
                approvedHeaderId,
                approvedCommandId
            )
        );

        const proposalEntityId = genProposalId(pid);

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "id",
            proposalEntityId
        );
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
    });

    test("Should log warning if Proposal entity does not exist", () => {
        const pid = BigInt.fromI32(100);
        const approvedHeaderId = BigInt.fromI32(1);
        const approvedCommandId = BigInt.fromI32(2);

        handleProposalTallied(
            createMockProposalTalliedEvent(
                pid,
                approvedHeaderId,
                approvedCommandId
            )
        );

        assert.entityCount("Proposal", 0);
    });
});

describe("ProposalTalliedWithTie Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should update Proposal entity with expirationTime, top3Headers, and top3Commands", () => {
        const pid = BigInt.fromI32(100);
        const extendedExpirationTime = BigInt.fromI32(123456);
        const approvedHeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const approvedCommandIds = [
            BigInt.fromI32(4),
            BigInt.fromI32(5),
            BigInt.fromI32(6),
        ];

        let proposal = createMockProposalEntity(pid);

        handleProposalTalliedWithTie(
            createMockProposalTalliedWithTieEvent(
                pid,
                approvedHeaderIds,
                approvedCommandIds,
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
            formatBigIntArray(pid, approvedHeaderIds, genHeaderId)
        );

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            formatBigIntArray(pid, approvedCommandIds, genCommandId)
        );
    });

    test("Should log warning if Proposal entity does not exist", () => {
        const pid = BigInt.fromI32(100);
        const extendedExpirationTime = BigInt.fromI32(123456);
        const approvedHeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const approvedCommandIds = [
            BigInt.fromI32(4),
            BigInt.fromI32(5),
            BigInt.fromI32(6),
        ];

        handleProposalTalliedWithTie(
            createMockProposalTalliedWithTieEvent(
                pid,
                approvedHeaderIds,
                approvedCommandIds,
                extendedExpirationTime
            )
        );

        assert.entityCount("Proposal", 0);
    });
});
