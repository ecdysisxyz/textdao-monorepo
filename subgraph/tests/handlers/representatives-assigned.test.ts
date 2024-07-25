import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address, ethereum, Bytes } from "@graphprotocol/graph-ts";
import { handleRepresentativesAssigned } from "../../src/handlers/representatives-assigned";
import { genProposalId } from "../../src/utils/entity-id-provider";
import { Proposal } from "../../generated/schema";
import { createMockRepresentativesAssignedEvent } from "../utils/mock-events";

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

        const mockEvent = createMockRepresentativesAssignedEvent(pid, reps);

        handleRepresentativesAssigned(mockEvent);

        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "id",
            proposalEntityId
        );

        const savedProposal = Proposal.load(proposalEntityId);
        if (savedProposal == null || savedProposal.reps == null) {
            throw new Error("Saved proposal or reps should not be null");
        }
        assert.equals(
            ethereum.Value.fromAddressArray(reps),
            ethereum.Value.fromBytesArray(savedProposal.reps as Bytes[])
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

        const savedProposal = Proposal.load(proposalEntityId);
        if (savedProposal == null || savedProposal.reps == null) {
            throw new Error("Saved proposal or reps should not be null");
        }
        assert.equals(
            ethereum.Value.fromAddressArray(newReps),
            ethereum.Value.fromBytesArray(savedProposal.reps as Bytes[])
        );
    });

    test("Should handle empty representatives array", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);

        const emptyReps: Address[] = [];
        const mockEvent = createMockRepresentativesAssignedEvent(
            pid,
            emptyReps
        );

        handleRepresentativesAssigned(mockEvent);

        assert.entityCount("Proposal", 1);

        const savedProposal = Proposal.load(proposalEntityId);
        if (savedProposal == null || savedProposal.reps == null) {
            throw new Error("Saved proposal or reps should not be null");
        }
        assert.equals(
            ethereum.Value.fromAddressArray([]),
            ethereum.Value.fromBytesArray(savedProposal.reps as Bytes[])
        );
    });
});
