import { BigInt } from "@graphprotocol/graph-ts";
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
import {
  handleTextCreated,
  handleTextCreatedByProposal,
  handleTextDeleted,
  handleTextDeletedByProposal,
  handleTextUpdated,
  handleTextUpdatedByProposal,
} from "../../src/event-handlers/text-events";
import { handleTextContents } from "../../src/file-data-handlers/text-contents";
import { genTextContentsId, genTextId } from "../../src/utils/entity-id-provider";
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
  const metadataFilePath1 = "tests/utils/ipfs-file-data/sample-text-metadata1.json";
  const metadataCid2 = "QmTest2";
  const metadataFilePath2 = "tests/utils/ipfs-file-data/sample-text-metadata2.json";

  beforeEach(() => {
    clearStore();
    dataSourceMock.resetValues();
  });

  test("Should create new Text entity on TextCreated event", () => {
    assert.entityCount("Text", 0);

    const textIdNum = BigInt.fromI32(1);
    const textEntityId = genTextId(textIdNum);
    const textContentsId = genTextContentsId(metadataCid1);

    dataSourceMock.setAddress(metadataCid1);
    handleTextCreated(createMockTextCreatedEvent(textIdNum, metadataCid1));
    // logDataSources("TextContents");

    assert.dataSourceCount("TextContents", 1);
    assert.dataSourceExists("TextContents", textContentsId);
    handleTextContents(readFile(metadataFilePath1));
    // logDataSources("TextContents");

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "id", textEntityId);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId);
    assert.fieldEquals("TextContents", textContentsId, "title", "Text Title1");
    assert.fieldEquals("TextContents", textContentsId, "body", "Text body ~~~\naaa");
  });

  test("Should create new Text entity on TextCreatedByProposal event", () => {
    const textIdNum = BigInt.fromI32(1);
    const textEntityId = genTextId(textIdNum);
    const textContentsId = genTextContentsId(metadataCid1);

    dataSourceMock.setAddress(metadataCid1);
    handleTextCreatedByProposal(createMockTextCreatedByProposalEvent(textIdNum, metadataCid1));
    handleTextContents(readFile(metadataFilePath1));

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId);
    assert.fieldEquals("TextContents", textContentsId, "title", "Text Title1");
    assert.fieldEquals("TextContents", textContentsId, "body", "Text body ~~~\naaa");
  });

  test(
    "Should fail if Text entity exists on TextCreated event",
    () => {
      const textEntityId = BigInt.fromI32(1);

      handleTextCreated(createMockTextCreatedEvent(textEntityId, metadataCid1));
      handleTextCreated(createMockTextCreatedEvent(textEntityId, metadataCid2));
    },
    true,
  );

  test("Should update existing Text entity on TextUpdated event", () => {
    const textIdNum = BigInt.fromI32(1);
    const textEntityId = genTextId(textIdNum);
    const textContentsId1 = genTextContentsId(metadataCid1);
    const textContentsId2 = genTextContentsId(metadataCid2);

    dataSourceMock.setAddress(metadataCid1);
    handleTextCreated(createMockTextCreatedEvent(textIdNum, metadataCid1));
    handleTextContents(readFile(metadataFilePath1));

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId1);
    assert.fieldEquals("TextContents", textContentsId1, "title", "Text Title1");
    assert.fieldEquals("TextContents", textContentsId1, "body", "Text body ~~~\naaa");

    dataSourceMock.setAddress(metadataCid2);
    handleTextUpdated(createMockTextUpdatedEvent(textIdNum, metadataCid2));
    handleTextContents(readFile(metadataFilePath2));

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId2);
    assert.fieldEquals("TextContents", textContentsId2, "title", "Text Title2");
    assert.fieldEquals("TextContents", textContentsId2, "body", "Text body2 ~~~\naaa");
  });

  test("Should update existing Text entity on TextUpdatedByProposal event", () => {
    const textIdNum = BigInt.fromI32(1);
    const textEntityId = genTextId(textIdNum);
    const textContentsId1 = genTextContentsId(metadataCid1);
    const textContentsId2 = genTextContentsId(metadataCid2);

    dataSourceMock.setAddress(metadataCid1);
    handleTextCreated(createMockTextCreatedEvent(textIdNum, metadataCid1));
    handleTextContents(readFile(metadataFilePath1));

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId1);
    assert.fieldEquals("TextContents", textContentsId1, "title", "Text Title1");
    assert.fieldEquals("TextContents", textContentsId1, "body", "Text body ~~~\naaa");

    dataSourceMock.setAddress(metadataCid2);
    handleTextUpdatedByProposal(createMockTextUpdatedByProposalEvent(textIdNum, metadataCid2));
    handleTextContents(readFile(metadataFilePath2));

    assert.entityCount("Text", 1);
    assert.fieldEquals("Text", textEntityId, "contents", textContentsId2);
    assert.fieldEquals("TextContents", textContentsId2, "title", "Text Title2");
    assert.fieldEquals("TextContents", textContentsId2, "body", "Text body2 ~~~\naaa");
  });

  test(
    "Should fail if Text entity doesn't exist on TextUpdated event",
    () => {
      const textEntityId = BigInt.fromI32(1);
      const metadataCid = "ipfs://QmTest1";

      handleTextUpdated(createMockTextUpdatedEvent(textEntityId, metadataCid));
    },
    true,
  );

  test("Should remove Text entity on TextDeleted event", () => {
    const textEntityId = BigInt.fromI32(1);

    handleTextCreated(createMockTextCreatedEvent(textEntityId, metadataCid1));
    assert.entityCount("Text", 1);

    handleTextDeleted(createMockTextDeletedEvent(textEntityId));
    assert.entityCount("Text", 0);
  });

  test("Should remove Text entity on TextDeletedByProposal event", () => {
    const textEntityId = BigInt.fromI32(1);

    handleTextCreated(createMockTextCreatedEvent(textEntityId, metadataCid1));
    assert.entityCount("Text", 1);

    handleTextDeletedByProposal(createMockTextDeletedByProposalEvent(textEntityId));
    assert.entityCount("Text", 0);
  });

  test(
    "Should fail if Text entity doesn't exist on TextDeleted event",
    () => {
      const textEntityId = BigInt.fromI32(1);

      handleTextDeleted(createMockTextDeletedEvent(textEntityId));
    },
    true,
  );

  test("Should handle multiple Text entities", () => {
    const textIdNum1 = BigInt.fromI32(1);
    const textId1 = genTextId(textIdNum1);
    const textContentsId1 = genTextContentsId(metadataCid1);

    const textIdNum2 = BigInt.fromI32(2);
    const textId2 = genTextId(textIdNum2);
    const textContentsId2 = genTextContentsId(metadataCid2);

    dataSourceMock.setAddress(metadataCid1);
    handleTextCreated(createMockTextCreatedEvent(textIdNum1, metadataCid1));
    handleTextContents(readFile(metadataFilePath1));

    dataSourceMock.setAddress(metadataCid2);
    handleTextCreatedByProposal(createMockTextCreatedByProposalEvent(textIdNum2, metadataCid2));
    handleTextContents(readFile(metadataFilePath2));

    assert.entityCount("Text", 2);
    assert.fieldEquals("Text", textId1, "contents", textContentsId1);
    assert.fieldEquals("Text", textId2, "contents", textContentsId2);
    assert.fieldEquals("TextContents", textContentsId1, "title", "Text Title1");
    assert.fieldEquals("TextContents", textContentsId1, "body", "Text body ~~~\naaa");
    assert.fieldEquals("TextContents", textContentsId2, "title", "Text Title2");
    assert.fieldEquals("TextContents", textContentsId2, "body", "Text body2 ~~~\naaa");
  });

  test("Should handle empty metadataCid with null", () => {
    const textEntityId = BigInt.fromI32(1);
    const emptyMetadataCid = "";

    handleTextCreated(createMockTextCreatedEvent(textEntityId, emptyMetadataCid));

    assert.entityCount("Text", 1);
  });
});
