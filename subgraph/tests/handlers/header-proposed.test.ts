// import {
//   assert,
//   describe,
//   test,
//   clearStore,
//   beforeEach,
// } from "matchstick-as/assembly/index";
// import { Bytes } from "@graphprotocol/graph-ts";
// import { handleHeaderProposed } from "../src/mapping";
// import { createHeaderProposed } from "./utils";

// describe("HeaderProposed", () => {
//   beforeEach(() => {
//     clearStore();
//   });

//   test("create and store Header", () => {
//     assert.entityCount("Header", 0);
//     const uriHex = Bytes.fromUTF8("uri").toHex();
//     handleHeaderProposed(createHeaderProposed(1, 2, 3, uriHex, 4, 5));
//     assert.entityCount("Header", 1);

//     assert.fieldEquals("Header", "1", "id", "1");
//     assert.fieldEquals("Header", "1", "proposal", "2");
//     assert.fieldEquals("Header", "1", "currentScore", "3");
//     assert.fieldEquals("Header", "1", "metadataURI", uriHex);
//     assert.fieldEquals("Header", "1", "tagIds", "[4, 5]");
//   });

//   test("create or update Header", () => {
//     assert.entityCount("Header", 0);
//     const uriHex = Bytes.fromUTF8("uri").toHex();
//     handleHeaderProposed(createHeaderProposed(1, 2, 3, uriHex, 4, 5));
//     handleHeaderProposed(createHeaderProposed(1, 12, 13, uriHex, 14, 15));
//     assert.entityCount("Header", 1);

//     assert.fieldEquals("Header", "1", "id", "1");
//     assert.fieldEquals("Header", "1", "proposal", "12");
//     assert.fieldEquals("Header", "1", "currentScore", "13");
//     assert.fieldEquals("Header", "1", "metadataURI", uriHex);
//     assert.fieldEquals("Header", "1", "tagIds", "[14, 15]");
//   });

//   test("create 2 Header", () => {
//     assert.entityCount("Header", 0);
//     const uriHex = Bytes.fromUTF8("uri").toHex();
//     handleHeaderProposed(createHeaderProposed(1, 2, 3, uriHex, 4, 5));
//     handleHeaderProposed(createHeaderProposed(2, 12, 13, uriHex, 14, 15));
//     assert.entityCount("Header", 2);

//     assert.fieldEquals("Header", "1", "id", "1");
//     assert.fieldEquals("Header", "1", "proposal", "2");
//     assert.fieldEquals("Header", "1", "currentScore", "3");
//     assert.fieldEquals("Header", "1", "metadataURI", uriHex);
//     assert.fieldEquals("Header", "1", "tagIds", "[4, 5]");
//     assert.fieldEquals("Header", "2", "id", "2");
//     assert.fieldEquals("Header", "2", "proposal", "12");
//     assert.fieldEquals("Header", "2", "currentScore", "13");
//     assert.fieldEquals("Header", "2", "metadataURI", uriHex);
//     assert.fieldEquals("Header", "2", "tagIds", "[14, 15]");
//   });
// });
