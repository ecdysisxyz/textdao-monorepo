import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
    beforeAll,
    mockIpfsFile,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import { handleHeaderCreated } from "../../src/event-handlers/header-created";
import { genHeaderId, genProposalId } from "../../src/utils/entity-id-provider";
import { createMockHeaderCreatedEvent } from "../utils/mock-events";

function assertProposalFieldFilledWithMetadata1(headerEntityId: string): void {
    assert.fieldEquals(
        "Header",
        headerEntityId,
        "title",
        "Sample Header Title1"
    );
    assert.fieldEquals("Header", headerEntityId, "body", "wrrrrrrrrrrryyyy");
}
function assertProposalFieldFilledWithMetadata2(headerEntityId: string): void {
    assert.fieldEquals(
        "Header",
        headerEntityId,
        "title",
        "Sample Header Title2"
    );
    assert.fieldEquals("Header", headerEntityId, "body", "foooooooooooo");
}

describe("HeaderCreated Event Handler", () => {
    const metadataCid1 = "QmTest1";
    const metadataFilePath1 =
        "tests/utils/ipfs-file-data/sample-proposal-header-metadata1.json";
    const metadataCid2 = "QmTest2";
    const metadataFilePath2 =
        "tests/utils/ipfs-file-data/sample-proposal-header-metadata2.json";

    beforeAll(() => {
        mockIpfsFile(metadataCid1, metadataFilePath1);
        mockIpfsFile(metadataCid2, metadataFilePath2);
    });

    beforeEach(() => {
        clearStore();
    });

    test("Should create and store a single Header entity", () => {
        assert.entityCount("Header", 0);

        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(222);

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, metadataCid1)
        );

        assert.entityCount("Header", 1);

        const headerEntityId = genHeaderId(pid, headerId);
        const proposalEntityId = genProposalId(pid);

        assert.fieldEquals("Header", headerEntityId, "id", headerEntityId);
        assert.fieldEquals(
            "Header",
            headerEntityId,
            "proposal",
            proposalEntityId
        );
        assertProposalFieldFilledWithMetadata1(headerEntityId);
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
        const metadataCids: string[] = [
            metadataCid1,
            metadataCid2,
            metadataCid1,
        ];

        for (let i = 0; i < pids.length; i++) {
            handleHeaderCreated(
                createMockHeaderCreatedEvent(
                    pids[i],
                    headerIds[i],
                    metadataCids[i]
                )
            );

            assert.entityCount("Header", i + 1);

            const headerEntityId = genHeaderId(pids[i], headerIds[i]);
            const proposalEntityId = genProposalId(pids[i]);

            assert.fieldEquals("Header", headerEntityId, "id", headerEntityId);
            assert.fieldEquals(
                "Header",
                headerEntityId,
                "proposal",
                proposalEntityId
            );
        }
        assertProposalFieldFilledWithMetadata1(
            genHeaderId(pids[0], headerIds[0])
        );
        assertProposalFieldFilledWithMetadata2(
            genHeaderId(pids[1], headerIds[1])
        );
        assertProposalFieldFilledWithMetadata1(
            genHeaderId(pids[2], headerIds[2])
        );
    });

    test(
        "Should fail update an existing Header entity",
        () => {
            const pid = BigInt.fromI32(100);
            const headerId = BigInt.fromI32(1);

            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerId, metadataCid1)
            );
            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerId, metadataCid2)
            );
        },
        true
    );

    test("Should handle Headers with empty metadataCid", () => {
        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(1);
        const emptyMetadataCid = "";

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, emptyMetadataCid)
        );

        assert.entityCount("Header", 1);
    });

    test("Should create a Proposal entity if it doesn't exist", () => {
        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(1);

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, metadataCid1)
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
});
