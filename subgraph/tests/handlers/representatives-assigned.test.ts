import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleRepresentativesAssigned } from "../../src/handlers/representatives-assigned";
import { genProposalId } from "../../src/utils/entity-id-provider";
import { createMockRepresentativesAssignedEvent } from "../utils/mock-events";
import { formatAddressArray } from "../utils/type-formatter";

describe("RepresentativesAssigned Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create new Proposal entity with assigned representatives", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);

        const reps = [
            Address.fromString("0x1234567890123456789012345678901234567890"),
            Address.fromString("0x0987654321098765432109876543210987654321"),
        ];

        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, reps)
        );

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
            "reps",
            formatAddressArray(reps)
        );
    });

    test("Should update existing Proposal entity with new representatives", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);

        // Create initial proposal with representatives
        const initialReps = [
            Address.fromString("0x1111111111111111111111111111111111111111"),
        ];
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, initialReps)
        );

        // Update with new representatives
        const newReps = [
            Address.fromString("0x2222222222222222222222222222222222222222"),
            Address.fromString("0x3333333333333333333333333333333333333333"),
        ];
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, newReps)
        );

        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "reps",
            formatAddressArray(newReps)
        );
    });

    test("Should handle empty representatives array", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);

        const emptyReps: Address[] = [];

        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, emptyReps)
        );

        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "reps",
            formatAddressArray(emptyReps)
        );
    });
});
