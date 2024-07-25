import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { Address, BigInt } from "@graphprotocol/graph-ts";
import {
    handleMemberAdded,
    handleMemberUpdated,
} from "../../src/handlers/member-events";
import {
    createMockMemberAddedEvent,
    createMockMemberUpdatedEvent,
} from "../utils/mock-events";
import { genMemberId } from "../../src/utils/entity-id-provider";

describe("Member Event Handlers", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create new Member entity on MemberAdded event", () => {
        const memberId = BigInt.fromI32(0);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const metadataURI = "ipfs://QmTest1";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, metadataURI)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            genMemberId(memberId),
            "metadataURI",
            metadataURI
        );
    });

    test("Should update existing Member entity on MemberUpdated event", () => {
        const memberId = BigInt.fromI32(0);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const initialMetadataURI = "ipfs://QmTest1";
        const updatedMetadataURI = "ipfs://QmTest2";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, initialMetadataURI)
        );
        handleMemberUpdated(
            createMockMemberUpdatedEvent(memberId, addr, updatedMetadataURI)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            genMemberId(memberId),
            "metadataURI",
            updatedMetadataURI
        );
    });

    test("Should handle multiple Member entities", () => {
        const memberId1 = BigInt.fromI32(1);
        const memberId2 = BigInt.fromI32(2);
        const addr1 = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const addr2 = Address.fromString(
            "0x2345678901234567890123456789012345678901"
        );
        const metadataURI1 = "ipfs://QmTest1";
        const metadataURI2 = "ipfs://QmTest2";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId1, addr1, metadataURI1)
        );
        handleMemberAdded(
            createMockMemberAddedEvent(memberId2, addr2, metadataURI2)
        );

        assert.entityCount("Member", 2);
        assert.fieldEquals(
            "Member",
            genMemberId(memberId1),
            "metadataURI",
            metadataURI1
        );
        assert.fieldEquals(
            "Member",
            genMemberId(memberId2),
            "metadataURI",
            metadataURI2
        );
    });

    test("Should handle empty metadataURI", () => {
        const memberId = BigInt.fromI32(0);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const emptyMetadataURI = "";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, emptyMetadataURI)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            genMemberId(memberId),
            "metadataURI",
            emptyMetadataURI
        );
    });

    test("Should handle updating Member entity multiple times", () => {
        const memberId = BigInt.fromI32(0);
        const addr = Address.fromString(
            "0x1234567890123456789012345678901234567890"
        );
        const metadataURI1 = "ipfs://QmTest1";
        const metadataURI2 = "ipfs://QmTest2";
        const metadataURI3 = "ipfs://QmTest3";

        handleMemberAdded(
            createMockMemberAddedEvent(memberId, addr, metadataURI1)
        );
        handleMemberUpdated(
            createMockMemberUpdatedEvent(memberId, addr, metadataURI2)
        );
        handleMemberUpdated(
            createMockMemberUpdatedEvent(memberId, addr, metadataURI3)
        );

        assert.entityCount("Member", 1);
        assert.fieldEquals(
            "Member",
            genMemberId(memberId),
            "metadataURI",
            metadataURI3
        );
    });
});
