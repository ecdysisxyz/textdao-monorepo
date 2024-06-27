import {
  assert,
  describe,
  test,
  clearStore,
  beforeEach,
  beforeAll,
  mockIpfsFile,
} from "matchstick-as/assembly/index";
import { handleTextSaved } from "../src/mapping";
import { createTextSaved } from "./utils";

describe("TextSaved", () => {
  const metadataURI1 = "0x1234";
  const metadataURI2 = "0x5678";
  const samplePath1 = "tests/texts/sample1.txt";
  const samplePath2 = "tests/texts/sample2.txt";
  beforeAll(() => {
    mockIpfsFile(metadataURI1, samplePath1);
    mockIpfsFile(metadataURI2, samplePath2);
  });

  beforeEach(() => {
    clearStore();
  });

  test("save Text", () => {
    assert.entityCount("Text", 0);
    handleTextSaved(createTextSaved(1, [metadataURI1, metadataURI2]));
    handleTextSaved(createTextSaved(2, [metadataURI1, metadataURI2]));
    assert.entityCount("Text", 2);

    assert.fieldEquals("Text", "1", "metadataURIs", "[0x1234, 0x5678]");
    assert.fieldEquals("Text", "1", "bodies", "[sample text1, sample text2]");
    assert.fieldEquals("Text", "2", "metadataURIs", "[0x1234, 0x5678]");
    assert.fieldEquals("Text", "2", "bodies", "[sample text1, sample text2]");
  });

  test("update Text", () => {
    assert.entityCount("Text", 0);
    handleTextSaved(createTextSaved(1, [metadataURI1]));
    assert.entityCount("Text", 1);
    handleTextSaved(createTextSaved(1, [metadataURI2]));
    assert.entityCount("Text", 1);

    assert.fieldEquals("Text", "1", "metadataURIs", "[0x5678]");
    assert.fieldEquals("Text", "1", "bodies", "[sample text2]");
  });
});
