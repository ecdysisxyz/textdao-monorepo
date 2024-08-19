import { BigInt, log } from "@graphprotocol/graph-ts";
import {
	assert,
	beforeEach,
	clearStore,
	dataSourceMock,
	describe,
	logDataSources,
	readFile,
	test,
} from "matchstick-as/assembly/index";
import { HeaderContents } from "../../generated/schema";
import { handleHeaderCreated } from "../../src/event-handlers/header-created";
import { handleHeaderContents } from "../../src/file-data-handlers/header-contents";
import {
	genHeaderContentsId,
	genHeaderId,
	genProposalId,
} from "../../src/utils/entity-id-provider";
import { createMockHeaderCreatedEvent } from "../utils/mock-events";

function assertProposalFieldFilledWithMetadata1(
	headerContentsEntityId: string,
): void {
	assert.fieldEquals(
		"HeaderContents",
		headerContentsEntityId,
		"title",
		"Sample Header Title1",
	);
	assert.fieldEquals(
		"HeaderContents",
		headerContentsEntityId,
		"body",
		"wrrrrrrrrrrryyyy",
	);
}
function assertProposalFieldFilledWithMetadata2(
	headerContentsEntityId: string,
): void {
	assert.fieldEquals(
		"HeaderContents",
		headerContentsEntityId,
		"title",
		"Sample Header Title2",
	);
	assert.fieldEquals(
		"HeaderContents",
		headerContentsEntityId,
		"body",
		"foooooooooooo",
	);
}

describe("HeaderCreated Event Handler", () => {
	const metadataCid1 = "QmTest1";
	const metadataFilePath1 =
		"tests/utils/ipfs-file-data/sample-proposal-header-metadata1.json";
	const metadataCid2 = "QmTest2";
	const metadataFilePath2 =
		"tests/utils/ipfs-file-data/sample-proposal-header-metadata2.json";

	beforeEach(() => {
		clearStore();
		dataSourceMock.resetValues();
	});

	test("Should create and store a single Header entity with HeaderContents", () => {
		assert.entityCount("Header", 0);
		dataSourceMock.setAddress(metadataCid1);

		const pid = BigInt.fromI32(100);
		const headerId = BigInt.fromI32(222);
		logDataSources("HeaderContents");

		handleHeaderCreated(
			createMockHeaderCreatedEvent(pid, headerId, metadataCid1),
		);

		const headerEntityId = genHeaderId(pid, headerId);
		const proposalEntityId = genProposalId(pid);
		const headerContentsEntityId = genHeaderContentsId(metadataCid1);

		assert.entityCount("Header", 1);
		assert.fieldEquals("Header", headerEntityId, "id", headerEntityId);
		assert.fieldEquals("Header", headerEntityId, "proposal", proposalEntityId);
		assert.fieldEquals(
			"Header",
			headerEntityId,
			"contents",
			headerContentsEntityId,
		);

		assert.dataSourceCount("HeaderContents", 1);

		assert.assertNull(HeaderContents.load(headerContentsEntityId));
		handleHeaderContents(readFile(metadataFilePath1));
		assert.assertNotNull(HeaderContents.load(headerContentsEntityId));

		assert.dataSourceCount("HeaderContents", 1);
		assert.dataSourceExists("HeaderContents", metadataCid1);
		logDataSources("HeaderContents");

		assertProposalFieldFilledWithMetadata1(headerContentsEntityId);
	});

	test("Should create multiple Header entities for different proposals", () => {
		const pids: BigInt[] = [
			BigInt.fromI32(100),
			BigInt.fromI32(101),
			BigInt.fromI32(100),
		];
		const headerIds: BigInt[] = [
			BigInt.fromI32(1),
			BigInt.fromI32(1),
			BigInt.fromI32(2),
		];
		const metadataCids: string[] = [metadataCid1, metadataCid2, metadataCid1];

		for (let i = 0; i < pids.length; i++) {
			// logDataSources("HeaderContents");

			handleHeaderCreated(
				createMockHeaderCreatedEvent(pids[i], headerIds[i], metadataCids[i]),
			);

			assert.entityCount("Header", i + 1);

			const headerEntityId = genHeaderId(pids[i], headerIds[i]);
			const proposalEntityId = genProposalId(pids[i]);
			const headerContentsEntityId = genHeaderContentsId(metadataCids[i]);

			assert.fieldEquals("Header", headerEntityId, "id", headerEntityId);
			assert.fieldEquals(
				"Header",
				headerEntityId,
				"proposal",
				proposalEntityId,
			);
			assert.fieldEquals(
				"Header",
				headerEntityId,
				"contents",
				headerContentsEntityId,
			);
			assert.assertNull(HeaderContents.load(headerContentsEntityId));

			if (i === 0) {
				assert.dataSourceCount("HeaderContents", 1);
				assert.dataSourceExists("HeaderContents", metadataCid1);
			} else {
				assert.dataSourceCount("HeaderContents", 2);
				assert.dataSourceExists("HeaderContents", metadataCid1);
				assert.dataSourceExists("HeaderContents", metadataCid2);
			}
		}

		const headerContentsEntityId1 = genHeaderContentsId(metadataCids[0]);
		const headerContentsEntityId2 = genHeaderContentsId(metadataCids[1]);
		const headerContentsEntityId3 = genHeaderContentsId(metadataCids[2]);

		assert.assertNull(HeaderContents.load(headerContentsEntityId1));
		dataSourceMock.setAddress(metadataCid1);
		handleHeaderContents(readFile(metadataFilePath1));
		assert.assertNotNull(HeaderContents.load(headerContentsEntityId1));

		assert.assertNull(HeaderContents.load(headerContentsEntityId2));
		dataSourceMock.setAddress(metadataCid2);
		handleHeaderContents(readFile(metadataFilePath2));
		assert.assertNotNull(HeaderContents.load(headerContentsEntityId2));

		assert.assertNotNull(HeaderContents.load(headerContentsEntityId3));
		dataSourceMock.setAddress(metadataCid1);
		handleHeaderContents(readFile(metadataFilePath1));
		assert.dataSourceCount("HeaderContents", 2);

		assertProposalFieldFilledWithMetadata1(headerContentsEntityId1);
		assertProposalFieldFilledWithMetadata2(headerContentsEntityId2);
		assertProposalFieldFilledWithMetadata1(headerContentsEntityId3);
	});

	test(
		"Should fail update an existing Header entity",
		() => {
			const pid = BigInt.fromI32(100);
			const headerId = BigInt.fromI32(1);

			handleHeaderCreated(
				createMockHeaderCreatedEvent(pid, headerId, metadataCid1),
			);
			handleHeaderCreated(
				createMockHeaderCreatedEvent(pid, headerId, metadataCid2),
			);
		},
		true,
	);

	test("Should handle Headers with empty metadataCid", () => {
		const pid = BigInt.fromI32(100);
		const headerId = BigInt.fromI32(1);
		const emptyMetadataCid = "";

		handleHeaderCreated(
			createMockHeaderCreatedEvent(pid, headerId, emptyMetadataCid),
		);

		assert.entityCount("Header", 1);
	});

	test("Should create a Proposal entity if it doesn't exist", () => {
		const pid = BigInt.fromI32(100);
		const headerId = BigInt.fromI32(1);

		handleHeaderCreated(
			createMockHeaderCreatedEvent(pid, headerId, metadataCid1),
		);

		const proposalEntityId = genProposalId(pid);
		assert.entityCount("Proposal", 1);
		assert.fieldEquals("Proposal", proposalEntityId, "id", proposalEntityId);
	});
});
