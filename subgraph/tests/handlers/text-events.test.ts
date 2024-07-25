import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import {
    handleTextCreated,
    handleTextUpdated,
    handleTextDeleted,
} from "../../src/handlers/text-events";
import { genTextId } from "../../src/utils/entity-id-provider";
import {
    createMockTextCreatedEvent,
    createMockTextUpdatedEvent,
    createMockTextDeletedEvent,
} from "../utils/mock-events";

describe("Text Event Handlers", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create new Text entity on TextCreated event", () => {
        const textId = BigInt.fromI32(1);
        const metadataURI = "ipfs://QmTest1";

        handleTextCreated(createMockTextCreatedEvent(textId, metadataURI));

        assert.entityCount("Text", 1);
        assert.fieldEquals(
            "Text",
            genTextId(textId),
            "metadataURI",
            metadataURI
        );
    });

    test(
        "Should fail if Text entity exists on TextCreated event",
        () => {
            const textId = BigInt.fromI32(1);
            const initialMetadataURI = "ipfs://QmTest1";
            const updatedMetadataURI = "ipfs://QmTest2";

            handleTextCreated(
                createMockTextCreatedEvent(textId, initialMetadataURI)
            );
            handleTextCreated(
                createMockTextCreatedEvent(textId, updatedMetadataURI)
            );
        },
        true
    );

    test("Should update existing Text entity on TextUpdated event", () => {
        const textId = BigInt.fromI32(1);
        const initialMetadataURI = "ipfs://QmTest1";
        const updatedMetadataURI = "ipfs://QmTest2";

        handleTextCreated(
            createMockTextCreatedEvent(textId, initialMetadataURI)
        );
        handleTextUpdated(
            createMockTextUpdatedEvent(textId, updatedMetadataURI)
        );

        assert.entityCount("Text", 1);
        assert.fieldEquals(
            "Text",
            genTextId(textId),
            "metadataURI",
            updatedMetadataURI
        );
    });

    test(
        "Should fail if Text entity doesn't exist on TextUpdated event",
        () => {
            const textId = BigInt.fromI32(1);
            const metadataURI = "ipfs://QmTest1";

            handleTextUpdated(createMockTextUpdatedEvent(textId, metadataURI));
        },
        true
    );

    test("Should remove Text entity on TextDeleted event", () => {
        const textId = BigInt.fromI32(1);
        const metadataURI = "ipfs://QmTest1";

        handleTextCreated(createMockTextCreatedEvent(textId, metadataURI));
        assert.entityCount("Text", 1);

        handleTextDeleted(createMockTextDeletedEvent(textId));
        assert.entityCount("Text", 0);
    });

    test(
        "Should fail if Text entity doesn't exist on TextDeleted event",
        () => {
            const textId = BigInt.fromI32(1);

            handleTextDeleted(createMockTextDeletedEvent(textId));
        },
        true
    );

    test("Should handle multiple Text entities", () => {
        const textId1 = BigInt.fromI32(1);
        const textId2 = BigInt.fromI32(2);
        const metadataURI1 = "ipfs://QmTest1";
        const metadataURI2 = "ipfs://QmTest2";

        handleTextCreated(createMockTextCreatedEvent(textId1, metadataURI1));
        handleTextCreated(createMockTextCreatedEvent(textId2, metadataURI2));

        assert.entityCount("Text", 2);
        assert.fieldEquals(
            "Text",
            genTextId(textId1),
            "metadataURI",
            metadataURI1
        );
        assert.fieldEquals(
            "Text",
            genTextId(textId2),
            "metadataURI",
            metadataURI2
        );
    });

    test("Should handle empty metadataURI", () => {
        const textId = BigInt.fromI32(1);
        const emptyMetadataURI = "";

        handleTextCreated(createMockTextCreatedEvent(textId, emptyMetadataURI));

        assert.entityCount("Text", 1);
        assert.fieldEquals(
            "Text",
            genTextId(textId),
            "metadataURI",
            emptyMetadataURI
        );
    });

    test("Should handle updating Text entity multiple times", () => {
        const textId = BigInt.fromI32(1);
        const metadataURI1 = "ipfs://QmTest1";
        const metadataURI2 = "ipfs://QmTest2";
        const metadataURI3 = "ipfs://QmTest3";

        handleTextCreated(createMockTextCreatedEvent(textId, metadataURI1));
        handleTextUpdated(createMockTextUpdatedEvent(textId, metadataURI2));
        handleTextUpdated(createMockTextUpdatedEvent(textId, metadataURI3));

        assert.entityCount("Text", 1);
        assert.fieldEquals(
            "Text",
            genTextId(textId),
            "metadataURI",
            metadataURI3
        );
    });
});
