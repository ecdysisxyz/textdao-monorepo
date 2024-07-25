import {
    assert,
    describe,
    test,
    clearStore,
    beforeEach,
} from "matchstick-as/assembly/index";
import { BigInt } from "@graphprotocol/graph-ts";
import { handleHeaderCreated } from "../../src/handlers/header-created";
import { genHeaderId, genProposalId } from "../../src/utils/entity-id-provider";
import { createMockHeaderCreatedEvent } from "../utils/mock-events";

describe("HeaderCreated Event Handler", () => {
    beforeEach(() => {
        clearStore();
    });

    test("Should create and store a single Header entity", () => {
        assert.entityCount("Header", 0);

        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(222);
        const metadataURI = "Qc...abc";

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, metadataURI)
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
        assert.fieldEquals(
            "Header",
            headerEntityId,
            "metadataURI",
            metadataURI
        );
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
        const metadataURIs: string[] = ["Qm...abc", "Qm...def", "Qm...ghi"];

        for (let i = 0; i < pids.length; i++) {
            handleHeaderCreated(
                createMockHeaderCreatedEvent(
                    pids[i],
                    headerIds[i],
                    metadataURIs[i]
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
            assert.fieldEquals(
                "Header",
                headerEntityId,
                "metadataURI",
                metadataURIs[i]
            );
        }
    });

    test(
        "Should fail update an existing Header entity",
        () => {
            const pid = BigInt.fromI32(100);
            const headerId = BigInt.fromI32(1);
            const initialMetadataURI = "Qm...abc";
            const updatedMetadataURI = "Qm...xyz";

            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerId, initialMetadataURI)
            );
            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerId, updatedMetadataURI)
            );
        },
        true
    );

    test("Should handle Headers with empty metadataURI", () => {
        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(1);
        const emptyMetadataURI = "";

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, emptyMetadataURI)
        );

        assert.entityCount("Header", 1);

        const headerEntityId = genHeaderId(pid, headerId);
        assert.fieldEquals(
            "Header",
            headerEntityId,
            "metadataURI",
            emptyMetadataURI
        );
    });

    test("Should create a Proposal entity if it doesn't exist", () => {
        const pid = BigInt.fromI32(100);
        const headerId = BigInt.fromI32(1);
        const metadataURI = "Qm...abc";

        handleHeaderCreated(
            createMockHeaderCreatedEvent(pid, headerId, metadataURI)
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

    test("Should handle multiple Headers for the same Proposal", () => {
        const pid = BigInt.fromI32(100);
        const headerIds: BigInt[] = [
            BigInt.fromI32(1),
            BigInt.fromI32(2),
            BigInt.fromI32(3),
        ];
        const metadataURIs: string[] = ["Qm...abc", "Qm...def", "Qm...ghi"];

        const proposalEntityId = genProposalId(pid);

        for (let i = 0; i < headerIds.length; i++) {
            handleHeaderCreated(
                createMockHeaderCreatedEvent(pid, headerIds[i], metadataURIs[i])
            );

            assert.entityCount("Header", 1 + i);
            assert.entityCount("Proposal", 1);

            const headerEntityId = genHeaderId(pid, headerIds[i]);
            assert.fieldEquals(
                "Header",
                headerEntityId,
                "proposal",
                proposalEntityId
            );
        }
    });
});
