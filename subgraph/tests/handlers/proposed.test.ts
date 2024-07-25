import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleProposed } from "../../src/handlers/proposed";
import { genProposalId } from "../../src/utils/entity-id-provider";
import { createMockProposedEvent } from "../utils/mock-events";

describe("Proposed Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create new Proposal entity with correct fields", () => {
        const pid = BigInt.fromI32(100);
        const proposer = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
        );

        const proposalEntityId = genProposalId(pid);

        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "id",
            proposalEntityId
        );
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
    });

    test("Should not update existing Proposal entity", () => {
        const pid = BigInt.fromI32(100);
        const proposer = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        // Create initial proposal
        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
        );

        // Attempt to update proposal with new data
        const newProposer = Address.fromString(
            "0x0987654321098765432109876543210987654321"
        );
        const newCreatedAt = BigInt.fromI32(1625270400);
        const newExpirationTime = BigInt.fromI32(1625356800);

        handleProposed(
            createMockProposedEvent(
                pid,
                newProposer,
                newCreatedAt,
                newExpirationTime
            )
        );

        const proposalEntityId = genProposalId(pid);

        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "id",
            proposalEntityId
        );
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
    });

    test("Should handle multiple proposals", () => {
        const pid1 = BigInt.fromI32(100);
        const pid2 = BigInt.fromI32(101);
        const proposer = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        handleProposed(
            createMockProposedEvent(pid1, proposer, createdAt, expirationTime)
        );
        handleProposed(
            createMockProposedEvent(pid2, proposer, createdAt, expirationTime)
        );

        assert.entityCount("Proposal", 2);
    });

    test("Should handle proposal with zero address proposer", () => {
        const pid = BigInt.fromI32(100);
        const zeroAddress = Address.fromString(
            "0x0000000000000000000000000000000000000000"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        handleProposed(
            createMockProposedEvent(pid, zeroAddress, createdAt, expirationTime)
        );

        const proposalEntityId = genProposalId(pid);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "proposer",
            zeroAddress.toHexString()
        );
    });

    test("Should handle proposal with createdAt greater than expirationTime", () => {
        const pid = BigInt.fromI32(100);
        const proposer = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const createdAt = BigInt.fromI32(1625184000);
        const expirationTime = BigInt.fromI32(1625097600);

        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
        );

        const proposalEntityId = genProposalId(pid);
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
    });
});
