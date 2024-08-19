import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
	assert,
	beforeEach,
	clearStore,
	dataSourceMock,
	describe,
	readFile,
	test,
} from "matchstick-as/assembly/index";
import {
	handleMemberAdded,
	handleMemberAddedByProposal,
	handleMemberRemoved,
	handleMemberRemovedByProposal,
	handleMemberUpdated,
	handleMemberUpdatedByProposal,
} from "../../src/event-handlers/member-events";
import { handleMemberInfo } from "../../src/file-data-handlers/member-info";
import {
	genMemberId,
	genMemberInfoId,
} from "../../src/utils/entity-id-provider";
import {
	createMockMemberAddedByProposalEvent,
	createMockMemberAddedEvent,
	createMockMemberRemovedByProposalEvent,
	createMockMemberRemovedEvent,
	createMockMemberUpdatedByProposalEvent,
	createMockMemberUpdatedEvent,
} from "../utils/mock-events";

describe("Member Event Handlers", () => {
	const metadataCid1 = "QmTest1";
	const metadataFilePath1 =
		"tests/utils/ipfs-file-data/sample-member-metadata1.json";
	const metadataCid2 = "QmTest2";
	const metadataFilePath2 =
		"tests/utils/ipfs-file-data/sample-member-metadata2.json";

	beforeEach(() => {
		clearStore();
		dataSourceMock.resetValues();
	});

	test("Should create new Member entity on MemberAdded event", () => {
		assert.entityCount("Member", 0);
		assert.entityCount("MemberInfo", 0);

		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const memberInfoId = genMemberInfoId(metadataCid1);

		const addr = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);

		dataSourceMock.setAddress(metadataCid1);
		handleMemberAdded(createMockMemberAddedEvent(memberId, addr, metadataCid1));

		assert.dataSourceCount("MemberInfo", 1);
		assert.dataSourceExists("MemberInfo", memberInfoId);
		handleMemberInfo(readFile(metadataFilePath1));
		// logDataSources("TextContents");

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId);
		assert.fieldEquals("MemberInfo", memberInfoId, "name", "User1");
		assert.fieldEquals("MemberInfo", memberInfoId, "image", "imageURI");
		assert.fieldEquals("MemberInfo", memberInfoId, "bio", "I'm a user.");
	});

	test("Should create new Member entity on MemberAddedByProposal event", () => {
		const memberId = BigInt.fromI32(1);
		const memberEntityId = genMemberId(memberId);
		const memberInfoId = genMemberInfoId(metadataCid1);
		const addr = Address.fromString(
			"0x2345678901234567890123456789012345678901",
		);

		dataSourceMock.setAddress(metadataCid1);
		handleMemberAddedByProposal(
			createMockMemberAddedByProposalEvent(memberId, addr, metadataCid1),
		);
		handleMemberInfo(readFile(metadataFilePath1));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId);
		assert.fieldEquals("MemberInfo", memberInfoId, "name", "User1");
		assert.fieldEquals("MemberInfo", memberInfoId, "image", "imageURI");
		assert.fieldEquals("MemberInfo", memberInfoId, "bio", "I'm a user.");
	});

	test("Should update existing Member entity on MemberUpdated event", () => {
		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const memberInfoId1 = genMemberInfoId(metadataCid1);
		const memberInfoId2 = genMemberInfoId(metadataCid2);
		const addr1 = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);
		const addr2 = Address.fromString(
			"0xaaaa567890123456789012345678901234567890",
		);

		dataSourceMock.setAddress(metadataCid1);
		handleMemberAdded(
			createMockMemberAddedEvent(memberId, addr1, metadataCid1),
		);
		handleMemberInfo(readFile(metadataFilePath1));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr1.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId1);
		assert.entityCount("MemberInfo", 1);
		assert.fieldEquals("MemberInfo", memberInfoId1, "name", "User1");
		assert.fieldEquals("MemberInfo", memberInfoId1, "image", "imageURI");
		assert.fieldEquals("MemberInfo", memberInfoId1, "bio", "I'm a user.");

		dataSourceMock.setAddress(metadataCid2);
		handleMemberUpdated(
			createMockMemberUpdatedEvent(memberId, addr2, metadataCid2),
		);
		handleMemberInfo(readFile(metadataFilePath2));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr2.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId2);
		assert.entityCount("MemberInfo", 2);
		assert.fieldEquals("MemberInfo", memberInfoId2, "name", "UpdatedUser");
		assert.fieldEquals("MemberInfo", memberInfoId2, "image", "updatedImageURI");
		assert.fieldEquals(
			"MemberInfo",
			memberInfoId2,
			"bio",
			"I'm an updated user.",
		);
	});

	test("Should update existing Member entity on MemberUpdatedByProposal event", () => {
		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const memberInfoId1 = genMemberInfoId(metadataCid1);
		const memberInfoId2 = genMemberInfoId(metadataCid2);
		const addr1 = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);
		const addr2 = Address.fromString(
			"0xaaaa567890123456789012345678901234567890",
		);

		dataSourceMock.setAddress(metadataCid1);
		handleMemberAdded(
			createMockMemberAddedEvent(memberId, addr1, metadataCid1),
		);
		handleMemberInfo(readFile(metadataFilePath1));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr1.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId1);
		assert.entityCount("MemberInfo", 1);
		assert.fieldEquals("MemberInfo", memberInfoId1, "name", "User1");
		assert.fieldEquals("MemberInfo", memberInfoId1, "image", "imageURI");
		assert.fieldEquals("MemberInfo", memberInfoId1, "bio", "I'm a user.");

		dataSourceMock.setAddress(metadataCid2);
		handleMemberUpdatedByProposal(
			createMockMemberUpdatedByProposalEvent(memberId, addr2, metadataCid2),
		);
		handleMemberInfo(readFile(metadataFilePath2));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr2.toHexString());
		assert.fieldEquals("Member", memberEntityId, "info", memberInfoId2);
		assert.entityCount("MemberInfo", 2);
		assert.fieldEquals("MemberInfo", memberInfoId2, "name", "UpdatedUser");
		assert.fieldEquals("MemberInfo", memberInfoId2, "image", "updatedImageURI");
		assert.fieldEquals(
			"MemberInfo",
			memberInfoId2,
			"bio",
			"I'm an updated user.",
		);
	});

	test("Should handle multiple Member entities", () => {
		const memberId1 = BigInt.fromI32(1);
		const memberEntityId1 = genMemberId(memberId1);
		const memberInfoId1 = genMemberInfoId(metadataCid1);
		const memberId2 = BigInt.fromI32(2);
		const memberEntityId2 = genMemberId(memberId2);
		const memberInfoId2 = genMemberInfoId(metadataCid2);
		const addr1 = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);
		const addr2 = Address.fromString(
			"0x2345678901234567890123456789012345678901",
		);

		dataSourceMock.setAddress(metadataCid1);
		handleMemberAdded(
			createMockMemberAddedEvent(memberId1, addr1, metadataCid1),
		);
		handleMemberInfo(readFile(metadataFilePath1));

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId1, "addr", addr1.toHexString());
		assert.fieldEquals("Member", memberEntityId1, "info", memberInfoId1);
		assert.entityCount("MemberInfo", 1);
		assert.fieldEquals("MemberInfo", memberInfoId1, "name", "User1");
		assert.fieldEquals("MemberInfo", memberInfoId1, "image", "imageURI");
		assert.fieldEquals("MemberInfo", memberInfoId1, "bio", "I'm a user.");

		dataSourceMock.setAddress(metadataCid2);
		handleMemberAddedByProposal(
			createMockMemberAddedByProposalEvent(memberId2, addr2, metadataCid2),
		);
		handleMemberInfo(readFile(metadataFilePath2));

		assert.entityCount("Member", 2);
		assert.fieldEquals("Member", memberEntityId2, "addr", addr2.toHexString());
		assert.fieldEquals("Member", memberEntityId2, "info", memberInfoId2);
		assert.entityCount("MemberInfo", 2);
		assert.fieldEquals("MemberInfo", memberInfoId2, "name", "UpdatedUser");
		assert.fieldEquals("MemberInfo", memberInfoId2, "image", "updatedImageURI");
		assert.fieldEquals(
			"MemberInfo",
			memberInfoId2,
			"bio",
			"I'm an updated user.",
		);
	});

	test("Should handle empty metadataCid with null metadata fields", () => {
		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const addr = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);
		const emptyMetadataCid = "";

		handleMemberAdded(
			createMockMemberAddedEvent(memberId, addr, emptyMetadataCid),
		);

		assert.entityCount("Member", 1);
		assert.fieldEquals("Member", memberEntityId, "addr", addr.toHexString());
	});

	test("Should mark Member as inactive on MemberRemoved event", () => {
		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const addr = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);

		handleMemberAdded(createMockMemberAddedEvent(memberId, addr, metadataCid1));
		handleMemberRemoved(createMockMemberRemovedEvent(memberId));

		assert.entityCount("Member", 0);
	});

	test("Should mark Member as inactive on MemberRemovedByProposal event", () => {
		const memberId = BigInt.fromI32(0);
		const memberEntityId = genMemberId(memberId);
		const addr = Address.fromString(
			"0x1234567890123456789012345678901234567890",
		);

		handleMemberAdded(createMockMemberAddedEvent(memberId, addr, metadataCid1));
		handleMemberRemovedByProposal(
			createMockMemberRemovedByProposalEvent(memberId),
		);

		assert.entityCount("Member", 0);
	});
});
