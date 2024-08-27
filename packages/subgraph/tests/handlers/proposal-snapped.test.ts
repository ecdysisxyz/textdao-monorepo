import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import { handleProposalSnapped } from "../../src/event-handlers/proposal-snapped";
import {
    genProposalId,
    genHeaderId,
    genCommandId,
} from "../../src/utils/entity-id-provider";
import { createMockProposalSnappedEvent } from "../utils/mock-events";
import { createMockProposalEntity } from "../utils/mock-entities";

describe("ProposalSnapped Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should update existing Proposal entity with top3 headers, commands, and snapped epoch", () => {
        const pid = BigInt.fromI32(100);
        const epoch = BigInt.fromI32(1721900000);
        const top3HeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const top3CommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];

        // Create a proposal first
        createMockProposalEntity(pid);

        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch,
                top3HeaderIds,
                top3CommandIds
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

        const expectedTop3Headers = `[${genHeaderId(
            pid,
            top3HeaderIds[0]
        )}, ${genHeaderId(pid, top3HeaderIds[1])}, ${genHeaderId(
            pid,
            top3HeaderIds[2]
        )}]`;
        const expectedTop3Commands = `[${genCommandId(
            pid,
            top3CommandIds[0]
        )}, ${genCommandId(pid, top3CommandIds[1])}, ${genCommandId(
            pid,
            top3CommandIds[2]
        )}]`;

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Headers",
            expectedTop3Headers
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            expectedTop3Commands
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            `[${epoch.toString()}]`
        );
    });

    test(
        "Should fail if Proposal entity doesn't exist",
        () => {
            const pid = BigInt.fromI32(100);
            const epoch = BigInt.fromI32(1721900000);
            const top3HeaderIds = [
                BigInt.fromI32(1),
                BigInt.fromI32(2),
                BigInt.fromI32(3),
            ];
            const top3CommandIds = [
                BigInt.fromI32(1),
                BigInt.fromI32(2),
                BigInt.fromI32(3),
            ];

            assert.entityCount("Proposal", 0);

            handleProposalSnapped(
                createMockProposalSnappedEvent(
                    pid,
                    epoch,
                    top3HeaderIds,
                    top3CommandIds
                )
            );
        },
        true
    );

    test("Should update existing Proposal entity with new values and append new epoch", () => {
        const pid = BigInt.fromI32(100);
        const epoch1 = BigInt.fromI32(1721900000);
        const epoch2 = BigInt.fromI32(1721900100);
        const initialTop3HeaderIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const initialTop3CommandIds = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const updatedTop3HeaderIds = [
            BigInt.fromI32(4),
            BigInt.fromI32(5),
            BigInt.fromI32(6),
        ];
        const updatedTop3CommandIds = [
            BigInt.fromI32(4),
            BigInt.fromI32(5),
            BigInt.fromI32(6),
        ];

        // Create a proposal first
        createMockProposalEntity(pid);

        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch1,
                initialTop3HeaderIds,
                initialTop3CommandIds
            )
        );
        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch2,
                updatedTop3HeaderIds,
                updatedTop3CommandIds
            )
        );

        const proposalEntityId = genProposalId(pid);

        assert.entityCount("Proposal", 1);

        const expectedUpdatedTop3Headers = `[${genHeaderId(
            pid,
            updatedTop3HeaderIds[0]
        )}, ${genHeaderId(pid, updatedTop3HeaderIds[1])}, ${genHeaderId(
            pid,
            updatedTop3HeaderIds[2]
        )}]`;
        const expectedUpdatedTop3Commands = `[${genCommandId(
            pid,
            updatedTop3CommandIds[0]
        )}, ${genCommandId(pid, updatedTop3CommandIds[1])}, ${genCommandId(
            pid,
            updatedTop3CommandIds[2]
        )}]`;

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Headers",
            expectedUpdatedTop3Headers
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            expectedUpdatedTop3Commands
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            `[${epoch1.toString()}, ${epoch2.toString()}]`
        );
    });

    test("Should handle less than 3 top headers or commands", () => {
        const pid = BigInt.fromI32(100);
        const epoch = BigInt.fromI32(1721900000);
        const top3HeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
        const top3CommandIds = [BigInt.fromI32(1)];

        // Create a proposal first
        createMockProposalEntity(pid);

        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch,
                top3HeaderIds,
                top3CommandIds
            )
        );

        const proposalEntityId = genProposalId(pid);

        const expectedTop3Headers = `[${genHeaderId(
            pid,
            top3HeaderIds[0]
        )}, ${genHeaderId(pid, top3HeaderIds[1])}]`;
        const expectedTop3Commands = `[${genCommandId(
            pid,
            top3CommandIds[0]
        )}]`;

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Headers",
            expectedTop3Headers
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            expectedTop3Commands
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            `[${epoch.toString()}]`
        );
    });

    test("Should handle empty top headers or commands", () => {
        const pid = BigInt.fromI32(100);
        const epoch = BigInt.fromI32(1721900000);
        const top3HeaderIds: BigInt[] = [];
        const top3CommandIds: BigInt[] = [];

        // Create a proposal first
        createMockProposalEntity(pid);

        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch,
                top3HeaderIds,
                top3CommandIds
            )
        );

        const proposalEntityId = genProposalId(pid);

        assert.fieldEquals("Proposal", proposalEntityId, "top3Headers", "[]");
        assert.fieldEquals("Proposal", proposalEntityId, "top3Commands", "[]");
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            `[${epoch.toString()}]`
        );
    });

    test("Should handle large proposal ID and large header/command IDs", () => {
        const pid = BigInt.fromI32(999999);
        const epoch = BigInt.fromI32(1721900000);
        const top3HeaderIds = [
            BigInt.fromI32(1000000),
            BigInt.fromI32(2000000),
            BigInt.fromI32(3000000),
        ];
        const top3CommandIds = [
            BigInt.fromI32(4000000),
            BigInt.fromI32(5000000),
            BigInt.fromI32(6000000),
        ];

        // Create a proposal first
        createMockProposalEntity(pid);

        handleProposalSnapped(
            createMockProposalSnappedEvent(
                pid,
                epoch,
                top3HeaderIds,
                top3CommandIds
            )
        );

        const proposalEntityId = genProposalId(pid);

        const expectedTop3Headers = `[${genHeaderId(
            pid,
            top3HeaderIds[0]
        )}, ${genHeaderId(pid, top3HeaderIds[1])}, ${genHeaderId(
            pid,
            top3HeaderIds[2]
        )}]`;
        const expectedTop3Commands = `[${genCommandId(
            pid,
            top3CommandIds[0]
        )}, ${genCommandId(pid, top3CommandIds[1])}, ${genCommandId(
            pid,
            top3CommandIds[2]
        )}]`;

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Headers",
            expectedTop3Headers
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "top3Commands",
            expectedTop3Commands
        );
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            `[${epoch.toString()}]`
        );
    });

    test("Should handle multiple snaps and append all epochs", () => {
        const pid = BigInt.fromI32(100);
        const epochs = [
            BigInt.fromI32(1721900000),
            BigInt.fromI32(1721900100),
            BigInt.fromI32(1721900200),
        ];
        const top3HeaderIds = [BigInt.fromI32(1), BigInt.fromI32(2)];
        const top3CommandIds = [BigInt.fromI32(1)];

        // Create a proposal first
        createMockProposalEntity(pid);

        for (let i = 0; i < epochs.length; i++) {
            handleProposalSnapped(
                createMockProposalSnappedEvent(
                    pid,
                    epochs[i],
                    top3HeaderIds,
                    top3CommandIds
                )
            );
        }

        const proposalEntityId = genProposalId(pid);

        const expectedSnappedEpochs = `[${epochs[0].toString()}, ${epochs[1].toString()}, ${epochs[2].toString()}]`;

        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "snappedEpoch",
            expectedSnappedEpochs
        );
    });
});
