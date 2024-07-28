import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Address } from "@graphprotocol/graph-ts";
import { handleProposed } from "../../src/event-handlers/proposed";
import { handleRepresentativesAssigned } from "../../src/event-handlers/representatives-assigned";
import { genProposalId } from "../../src/utils/entity-id-provider";
import {
    createMockProposedEvent,
    createMockRepresentativesAssignedEvent,
} from "../utils/mock-events";
import { formatAddressArray } from "../../src/utils/type-formatter";
import { createMockProposalEntity } from "../utils/mock-entities";

describe("Proposed Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should update existing Proposal entity created by RepresentativesAssigned", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);
        const reps = [
            Address.fromString("0x1234567890123456789012345678901234567890"),
        ];

        // Simulate initial RepresentativesAssigned event
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, reps)
        );

        const proposer = Address.fromString(
            "0x0987654321098765432109876543210987654321"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
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

    test(
        "Should fail if Proposal entity doesn't exist",
        () => {
            const pid = BigInt.fromI32(100);
            const proposer = Address.fromString(
                "0x1234567890123456789012345678901234567890"
            );
            const createdAt = BigInt.fromI32(1625097600);
            const expirationTime = BigInt.fromI32(1625184000);

            handleProposed(
                createMockProposedEvent(
                    pid,
                    proposer,
                    createdAt,
                    expirationTime
                )
            );
        },
        true
    );

    // test("Should create new Proposal entity if it doesn't exist", () => {
    //     const pid = BigInt.fromI32(100);
    //     const proposalEntityId = genProposalId(pid);
    //     const proposer = Address.fromString(
    //         "0x1234567890123456789012345678901234567890"
    //     );
    //     const createdAt = BigInt.fromI32(1625097600);
    //     const expirationTime = BigInt.fromI32(1625184000);

    //     handleProposed(
    //         createMockProposedEvent(pid, proposer, createdAt, expirationTime)
    //     );

    //     assert.entityCount("Proposal", 1);
    //     assert.fieldEquals(
    //         "Proposal",
    //         proposalEntityId,
    //         "id",
    //         proposalEntityId
    //     );
    //     assert.fieldEquals(
    //         "Proposal",
    //         proposalEntityId,
    //         "proposer",
    //         proposer.toHexString()
    //     );
    //     assert.fieldEquals(
    //         "Proposal",
    //         proposalEntityId,
    //         "createdAt",
    //         createdAt.toString()
    //     );
    //     assert.fieldEquals(
    //         "Proposal",
    //         proposalEntityId,
    //         "expirationTime",
    //         expirationTime.toString()
    //     );
    // });

    test("Should handle multiple RepresentativesAssigned and Proposed events in correct order", () => {
        const pid = BigInt.fromI32(100);
        const proposalEntityId = genProposalId(pid);
        const initialReps = [
            Address.fromString("0x1111111111111111111111111111111111111111"),
        ];
        const proposer = Address.fromString(
            "0x2222222222222222222222222222222222222222"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);
        const finalReps = [
            Address.fromString("0x3333333333333333333333333333333333333333"),
            Address.fromString("0x4444444444444444444444444444444444444444"),
        ];

        // Simulate event sequence
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, initialReps)
        );
        handleProposed(
            createMockProposedEvent(pid, proposer, createdAt, expirationTime)
        );
        handleRepresentativesAssigned(
            createMockRepresentativesAssignedEvent(pid, finalReps)
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
            formatAddressArray(finalReps)
        );
    });

    test("Should handle proposal with zero address proposer", () => {
        const pid = BigInt.fromI32(100);
        const zeroAddress = Address.fromString(
            "0x0000000000000000000000000000000000000000"
        );
        const createdAt = BigInt.fromI32(1625097600);
        const expirationTime = BigInt.fromI32(1625184000);

        createMockProposalEntity(pid);

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

        createMockProposalEntity(pid);

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
