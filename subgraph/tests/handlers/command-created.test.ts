import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import { handleCommandCreated } from "../../src/handlers/command-created";
import {
    genCommandId,
    genActionId,
    genProposalId,
} from "../../src/utils/entity-id-provider";
import { createMockCommandCreatedEvent } from "../utils/mock-events";
import { Action } from "../../src/types/schema";

describe("CommandCreated Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create and store a single Command entity with its Actions", () => {
        assert.entityCount("Command", 0);
        assert.entityCount("Action", 0);

        const pid = BigInt.fromI32(100);
        const commandId = BigInt.fromI32(1);
        const actions: Action[] = [
            new Action("function1()", Bytes.fromHexString("0x1234")),
            new Action("function2()", Bytes.fromHexString("0x5678")),
        ];

        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId, actions)
        );

        assert.entityCount("Command", 1);
        assert.entityCount("Action", 2);

        const commandEntityId = genCommandId(pid, commandId);
        const proposalEntityId = genProposalId(pid);

        assert.fieldEquals("Command", commandEntityId, "id", commandEntityId);
        assert.fieldEquals(
            "Command",
            commandEntityId,
            "proposal",
            proposalEntityId
        );

        for (let i = 0; i < actions.length; i++) {
            const actionEntityId = genActionId(pid, commandId, i);
            assert.fieldEquals("Action", actionEntityId, "id", actionEntityId);
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "command",
                commandEntityId
            );
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "func",
                actions[i].funcSig
            );
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "abiParams",
                actions[i].abiParams.toHexString()
            );
            assert.fieldEquals("Action", actionEntityId, "status", "Proposed");
        }
    });

    test("Should create multiple Command entities for different proposals", () => {
        const pids = [BigInt.fromI32(100), BigInt.fromI32(101)];
        const commandIds = [BigInt.fromI32(1), BigInt.fromI32(1)];
        const actions: Action[][] = [
            [
                new Action("function1()", Bytes.fromHexString("0x1234")),
                new Action("function2()", Bytes.fromHexString("0x5678")),
            ],
            [
                new Action("function3()", Bytes.fromHexString("0x9abc")),
                new Action("function4()", Bytes.fromHexString("0xdef0")),
            ],
        ];

        for (let i = 0; i < pids.length; i++) {
            handleCommandCreated(
                createMockCommandCreatedEvent(
                    pids[i],
                    commandIds[i],
                    actions[i]
                )
            );

            assert.entityCount("Command", i + 1);
            assert.entityCount("Action", (i + 1) * actions[i].length);

            const commandEntityId = genCommandId(pids[i], commandIds[i]);
            const proposalEntityId = genProposalId(pids[i]);

            assert.fieldEquals(
                "Command",
                commandEntityId,
                "id",
                commandEntityId
            );
            assert.fieldEquals(
                "Command",
                commandEntityId,
                "proposal",
                proposalEntityId
            );

            for (let j = 0; j < actions[i].length; j++) {
                const actionEntityId = genActionId(pids[i], commandIds[i], j);
                assert.fieldEquals(
                    "Action",
                    actionEntityId,
                    "id",
                    actionEntityId
                );
                assert.fieldEquals(
                    "Action",
                    actionEntityId,
                    "command",
                    commandEntityId
                );
                assert.fieldEquals(
                    "Action",
                    actionEntityId,
                    "func",
                    actions[i][j].funcSig
                );
                assert.fieldEquals(
                    "Action",
                    actionEntityId,
                    "abiParams",
                    actions[i][j].abiParams.toHexString()
                );
                assert.fieldEquals(
                    "Action",
                    actionEntityId,
                    "status",
                    "Proposed"
                );
            }
        }
    });

    test("Should create a Proposal entity if it doesn't exist", () => {
        const pid = BigInt.fromI32(100);
        const commandId = BigInt.fromI32(1);
        const actions: Action[] = [
            new Action("function1()", Bytes.fromHexString("0x1234")),
        ];

        assert.entityCount("Proposal", 0);

        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId, actions)
        );

        const proposalEntityId = genProposalId(pid);
        assert.entityCount("Proposal", 1);
        assert.fieldEquals(
            "Proposal",
            proposalEntityId,
            "id",
            proposalEntityId
        );
    });

    test("Should not update an existing Command entity if it already exists", () => {
        const pid = BigInt.fromI32(100);
        const commandId = BigInt.fromI32(1);
        const initialActions: Action[] = [
            new Action("function1()", Bytes.fromHexString("0x1234")),
        ];
        const updatedActions: Action[] = [
            new Action("function2()", Bytes.fromHexString("0x5678")),
        ];

        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId, initialActions)
        );
        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId, updatedActions)
        );

        assert.entityCount("Command", 1);
        assert.entityCount("Action", 1);

        const actionEntityId = genActionId(pid, commandId, 0);

        assert.fieldEquals(
            "Action",
            actionEntityId,
            "func",
            initialActions[0].funcSig
        );
        assert.fieldEquals(
            "Action",
            actionEntityId,
            "abiParams",
            initialActions[0].abiParams.toHexString()
        );
    });

    test("Should handle Commands with empty actions", () => {
        const pid = BigInt.fromI32(100);
        const commandId = BigInt.fromI32(1);
        const emptyActions: Action[] = [];

        handleCommandCreated(
            createMockCommandCreatedEvent(pid, commandId, emptyActions)
        );

        assert.entityCount("Command", 1);
        assert.entityCount("Action", 0);

        const commandEntityId = genCommandId(pid, commandId);
        assert.fieldEquals("Command", commandEntityId, "id", commandEntityId);
    });

    test("Should handle multiple Commands for the same Proposal", () => {
        const pid = BigInt.fromI32(100);
        const commandIds: BigInt[] = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const actions: Action[][] = [
            [new Action("function1()", Bytes.fromHexString("0x1234"))],
            [new Action("function2()", Bytes.fromHexString("0x5678"))],
            [new Action("function3()", Bytes.fromHexString("0x9abc"))],
        ];

        const proposalEntityId = genProposalId(pid);

        for (let i = 0; i < commandIds.length; i++) {
            handleCommandCreated(
                createMockCommandCreatedEvent(pid, commandIds[i], actions[i])
            );

            assert.entityCount("Command", i + 1);
            assert.entityCount("Action", i + 1);

            const commandEntityId = genCommandId(pid, commandIds[i]);
            assert.fieldEquals(
                "Command",
                commandEntityId,
                "proposal",
                proposalEntityId
            );

            const actionEntityId = genActionId(pid, commandIds[i], 0);
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "command",
                commandEntityId
            );
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "func",
                actions[i][0].funcSig
            );
            assert.fieldEquals(
                "Action",
                actionEntityId,
                "abiParams",
                actions[i][0].abiParams.toHexString()
            );
        }
    });
});
