import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import { handleProposalExecuted } from "../../src/handlers/proposal-executed";
import { createMockProposalExecutedEvent } from "../utils/mock-events";
import {
    createMockProposalEntity,
    createMockCommandEntity,
    createMockActionEntity,
} from "../utils/mock-entities";
import {
    genProposalId,
    genCommandId,
    genActionId,
} from "../../src/utils/entity-id-provider";

describe("ProposalExecuted Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should mark proposal as fully executed and update action statuses", () => {
        const pid = BigInt.fromI32(100);
        const approvedCommandId = BigInt.fromI32(1);
        const proposalId = genProposalId(pid);
        const commandId = genCommandId(pid, approvedCommandId);

        // Create mock entities
        createMockProposalEntity(pid, false);
        createMockCommandEntity(pid, approvedCommandId);
        createMockActionEntity(pid, approvedCommandId, 0, "Proposed");
        createMockActionEntity(pid, approvedCommandId, 1, "Proposed");

        // Assert proposal is not fully executed
        assert.fieldEquals("Proposal", proposalId, "fullyExecuted", "false");

        // Handle the event
        handleProposalExecuted(
            createMockProposalExecutedEvent(pid, approvedCommandId)
        );

        // Assert proposal is fully executed
        assert.fieldEquals("Proposal", proposalId, "fullyExecuted", "true");

        // Assert actions are marked as executed
        assert.fieldEquals(
            "Action",
            genActionId(pid, approvedCommandId, 0),
            "status",
            "Executed"
        );
        assert.fieldEquals(
            "Action",
            genActionId(pid, approvedCommandId, 1),
            "status",
            "Executed"
        );
    });

    test("Should handle proposal execution with no actions", () => {
        const pid = BigInt.fromI32(101);
        const approvedCommandId = BigInt.fromI32(2);
        const proposalId = genProposalId(pid);

        // Create mock entities
        createMockProposalEntity(pid, false);
        createMockCommandEntity(pid, approvedCommandId);

        // Handle the event
        handleProposalExecuted(
            createMockProposalExecutedEvent(pid, approvedCommandId)
        );

        // Assert proposal is fully executed
        assert.fieldEquals("Proposal", proposalId, "fullyExecuted", "true");
    });

    test("Should not affect other proposals or commands", () => {
        const pid1 = BigInt.fromI32(102);
        const pid2 = BigInt.fromI32(103);
        const approvedCommandId = BigInt.fromI32(1);
        const proposalId1 = genProposalId(pid1);
        const proposalId2 = genProposalId(pid2);

        // Create mock entities
        createMockProposalEntity(pid1, false);
        createMockProposalEntity(pid2, false);
        createMockCommandEntity(pid1, approvedCommandId);
        createMockCommandEntity(pid2, approvedCommandId);
        createMockActionEntity(pid1, approvedCommandId, 0, "Proposed");
        createMockActionEntity(pid2, approvedCommandId, 0, "Proposed");

        // Handle the event for pid1
        handleProposalExecuted(
            createMockProposalExecutedEvent(pid1, approvedCommandId)
        );

        // Assert pid1 proposal is fully executed
        assert.fieldEquals("Proposal", proposalId1, "fullyExecuted", "true");
        assert.fieldEquals(
            "Action",
            genActionId(pid1, approvedCommandId, 0),
            "status",
            "Executed"
        );

        // Assert pid2 proposal is not affected
        assert.fieldEquals("Proposal", proposalId2, "fullyExecuted", "false");
        assert.fieldEquals(
            "Action",
            genActionId(pid2, approvedCommandId, 0),
            "status",
            "Proposed"
        );
    });

    test(
        "Should fail if Proposal entity doesn't exist",
        () => {
            const pid = BigInt.fromI32(104);
            const approvedCommandId = BigInt.fromI32(1);

            handleProposalExecuted(
                createMockProposalExecutedEvent(pid, approvedCommandId)
            );
        },
        true
    );

    test(
        "Should fail if Command entity doesn't exist",
        () => {
            const pid = BigInt.fromI32(105);
            const approvedCommandId = BigInt.fromI32(1);
            const proposalId = genProposalId(pid);

            createMockProposalEntity(pid, false);

            handleProposalExecuted(
                createMockProposalExecutedEvent(pid, approvedCommandId)
            );
        },
        true
    );

    test("Should handle partial action execution", () => {
        const pid = BigInt.fromI32(106);
        const approvedCommandId = BigInt.fromI32(1);
        const proposalId = genProposalId(pid);

        createMockProposalEntity(pid, false);
        createMockCommandEntity(pid, approvedCommandId);
        createMockActionEntity(pid, approvedCommandId, 0, "Proposed");
        // Action with index 1 is intentionally not created

        handleProposalExecuted(
            createMockProposalExecutedEvent(pid, approvedCommandId)
        );

        assert.fieldEquals("Proposal", proposalId, "fullyExecuted", "true");
        assert.fieldEquals(
            "Action",
            genActionId(pid, approvedCommandId, 0),
            "status",
            "Executed"
        );
        // No assertion for non-existent action with index 1
    });
});
