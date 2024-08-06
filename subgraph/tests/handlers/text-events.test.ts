import { BigInt } from "@graphprotocol/graph-ts";
import {
	assert,
	beforeAll,
	beforeEach,
	clearStore,
	describe,
	mockIpfsFile,
	test,
} from "matchstick-as/assembly/index";
import {
	handleTextCreated,
	handleTextCreatedByProposal,
	handleTextDeleted,
	handleTextDeletedByProposal,
	handleTextUpdated,
	handleTextUpdatedByProposal,
} from "../../src/event-handlers/text-events";
import { genTextId } from "../../src/utils/entity-id-provider";
import {
	createMockTextCreatedByProposalEvent,
	createMockTextCreatedEvent,
	createMockTextDeletedByProposalEvent,
	createMockTextDeletedEvent,
	createMockTextUpdatedByProposalEvent,
	createMockTextUpdatedEvent,
} from "../utils/mock-events";

describe("Text Event Handlers", () => {
	const metadataCid1 = "QmTest1";
	const metadataFilePath1 =
		"tests/utils/ipfs-file-data/sample-text-metadata1.json";
	const metadataCid2 = "QmTest2";
	const metadataFilePath2 =
		"tests/utils/ipfs-file-data/sample-text-metadata2.json";

	beforeAll(() => {
		mockIpfsFile(metadataCid1, metadataFilePath1);
		mockIpfsFile(metadataCid2, metadataFilePath2);
	});

	beforeEach(() => {
		clearStore();
	});

	test("Should create new Text entity on TextCreated event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));

		assert.entityCount("Text", 1);
		assert.fieldEquals("Text", genTextId(textId), "title", "Text Title1");
		assert.fieldEquals("Text", genTextId(textId), "body", "Text body ~~~\naaa");
	});

	test("Should create new Text entity on TextCreatedByProposal event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreatedByProposal(
			createMockTextCreatedByProposalEvent(textId, metadataCid1),
		);

		assert.entityCount("Text", 1);
		assert.fieldEquals("Text", genTextId(textId), "title", "Text Title1");
		assert.fieldEquals("Text", genTextId(textId), "body", "Text body ~~~\naaa");
	});

	test(
		"Should fail if Text entity exists on TextCreated event",
		() => {
			const textId = BigInt.fromI32(1);

			handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));
			handleTextCreated(createMockTextCreatedEvent(textId, metadataCid2));
		},
		true,
	);

	test("Should update existing Text entity on TextUpdated event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));
		handleTextUpdated(createMockTextUpdatedEvent(textId, metadataCid2));

		assert.entityCount("Text", 1);
		assert.fieldEquals("Text", genTextId(textId), "title", "Text Title2");
		assert.fieldEquals(
			"Text",
			genTextId(textId),
			"body",
			"Text body2 ~~~\naaa",
		);
	});

	test("Should update existing Text entity on TextUpdatedByProposal event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));
		handleTextUpdatedByProposal(
			createMockTextUpdatedByProposalEvent(textId, metadataCid2),
		);

		assert.entityCount("Text", 1);
		assert.fieldEquals("Text", genTextId(textId), "title", "Text Title2");
		assert.fieldEquals(
			"Text",
			genTextId(textId),
			"body",
			"Text body2 ~~~\naaa",
		);
	});

	test(
		"Should fail if Text entity doesn't exist on TextUpdated event",
		() => {
			const textId = BigInt.fromI32(1);
			const metadataCid = "ipfs://QmTest1";

			handleTextUpdated(createMockTextUpdatedEvent(textId, metadataCid));
		},
		true,
	);

	test("Should remove Text entity on TextDeleted event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));
		assert.entityCount("Text", 1);

		handleTextDeleted(createMockTextDeletedEvent(textId));
		assert.entityCount("Text", 0);
	});

	test("Should remove Text entity on TextDeletedByProposal event", () => {
		const textId = BigInt.fromI32(1);

		handleTextCreated(createMockTextCreatedEvent(textId, metadataCid1));
		assert.entityCount("Text", 1);

		handleTextDeletedByProposal(createMockTextDeletedByProposalEvent(textId));
		assert.entityCount("Text", 0);
	});

	test(
		"Should fail if Text entity doesn't exist on TextDeleted event",
		() => {
			const textId = BigInt.fromI32(1);

			handleTextDeleted(createMockTextDeletedEvent(textId));
		},
		true,
	);

	test("Should handle multiple Text entities", () => {
		const textId1 = BigInt.fromI32(1);
		const textId2 = BigInt.fromI32(2);

		handleTextCreated(createMockTextCreatedEvent(textId1, metadataCid1));
		handleTextCreatedByProposal(
			createMockTextCreatedByProposalEvent(textId2, metadataCid2),
		);

		assert.entityCount("Text", 2);
		assert.fieldEquals("Text", genTextId(textId1), "title", "Text Title1");
		assert.fieldEquals(
			"Text",
			genTextId(textId1),
			"body",
			"Text body ~~~\naaa",
		);
		assert.fieldEquals("Text", genTextId(textId2), "title", "Text Title2");
		assert.fieldEquals(
			"Text",
			genTextId(textId2),
			"body",
			"Text body2 ~~~\naaa",
		);
	});

	test("Should handle empty metadataCid with null", () => {
		const textId = BigInt.fromI32(1);
		const emptyMetadataCid = "";

		handleTextCreated(createMockTextCreatedEvent(textId, emptyMetadataCid));

		assert.entityCount("Text", 1);
	});
});
