import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
    mockIpfsFile,
    beforeAll,
} from "matchstick-as/assembly/index";
import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
    handleMemberAdded,
    handleMemberUpdated,
} from "../../src/event-handlers/member-events";
import {
    createMockMemberAddedEvent,
    createMockMemberUpdatedEvent,
} from "../utils/mock-events";
import { genMemberId } from "../../src/utils/entity-id-provider";

describe("Member Event Handlers", () => {
    const metadataCid1 = "QmTest1";
    const metadataFilePath1 =
        "tests/utils/ipfs-file-data/sample-member-metadata1.json";
    const metadataCid2 = "QmTest2";
    const metadataFilePath2 =
        "tests/utils/ipfs-file-data/sample-member-metadata2.json";

    beforeAll(() => {
        mockIpfsFile(metadataCid1, metadataFilePath1);
        mockIpfsFile(metadataCid2, metadataFilePath2);
    });

    beforeEach(() => {
        clearStore();
    });

    test("Should create new Member entity on MemberAdded event", () => {
        const memberId = BigInt.fromI32(0);
        const memberEntityId = genMemberId(memberId);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, metadataCid1)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            memberEntityId,
            "addr",
            addr.toHexString()
        );
        assert.fieldEquals("Member", memberEntityId, "name", "User1");
        assert.fieldEquals("Member", memberEntityId, "image", "imageURI");
        assert.fieldEquals("Member", memberEntityId, "bio", "I'm a user.");
    });

    test("Should update existing Member entity on MemberUpdated event", () => {
        const memberId = BigInt.fromI32(0);
        const memberEntityId = genMemberId(memberId);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, metadataCid1)
        );
        handleMemberUpdated(
            createMockMemberUpdatedEvent(memberId, addr, metadataCid2)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            memberEntityId,
            "addr",
            addr.toHexString()
        );
        assert.fieldEquals("Member", memberEntityId, "name", "UpdatedUser");
        assert.fieldEquals(
            "Member",
            memberEntityId,
            "image",
            "updatedImageURI"
        );
        assert.fieldEquals(
            "Member",
            memberEntityId,
            "bio",
            "I'm an updated user."
        );
    });

    test("Should handle multiple Member entities", () => {
        const memberId1 = BigInt.fromI32(1);
        const memberEntityId1 = genMemberId(memberId1);
        const memberId2 = BigInt.fromI32(2);
        const memberEntityId2 = genMemberId(memberId2);
        const addr1 = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const addr2 = Address.fromString(
            "0x2345678901234567890123456789012345678901"
        );

        handleMemberAdded(
            createMockMemberAddedEvent(memberId1, addr1, metadataCid1)
        );
        handleMemberAdded(
            createMockMemberAddedEvent(memberId2, addr2, metadataCid2)
        );

        assert.entityCount("Member", 2);
        assert.fieldEquals(
            "Member",
            memberEntityId1,
            "addr",
            addr1.toHexString()
        );
        assert.fieldEquals("Member", memberEntityId1, "name", "User1");
        assert.fieldEquals("Member", memberEntityId1, "image", "imageURI");
        assert.fieldEquals("Member", memberEntityId1, "bio", "I'm a user.");
        assert.fieldEquals(
            "Member",
            memberEntityId2,
            "addr",
            addr2.toHexString()
        );
        assert.fieldEquals("Member", memberEntityId2, "name", "UpdatedUser");
        assert.fieldEquals(
            "Member",
            memberEntityId2,
            "image",
            "updatedImageURI"
        );
        assert.fieldEquals(
            "Member",
            memberEntityId2,
            "bio",
            "I'm an updated user."
        );
    });

    test("Should handle empty metadataCid with null metadata fields", () => {
        const memberId = BigInt.fromI32(0);
        const memberEntityId = genMemberId(memberId);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const emptyMetadataCid = "";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, emptyMetadataCid)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            memberEntityId,
            "addr",
            addr.toHexString()
        );
    });
});
