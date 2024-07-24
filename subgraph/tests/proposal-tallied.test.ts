// import {
//   assert,
//   describe,
//   test,
//   clearStore,
//   beforeEach,
// } from "matchstick-as/assembly/index";
// import { handleProposalTallied } from "../src/mapping";
// import { createProposalTallied } from "./utils";

// describe("ProposalTallied", () => {
//   beforeEach(() => {
//     clearStore();
//   });

//   test("save ProposalMeta", () => {
//     assert.entityCount("ProposalMeta", 0);
//     handleProposalTallied(createProposalTallied(1, 2, "0x01"));
//     assert.entityCount("ProposalMeta", 1);

//     assert.fieldEquals("ProposalMeta", "0x01", "proposal", "1");
//     assert.fieldEquals("ProposalMeta", "0x01", "currentScore", "2");
//   });

//   test("save 2 ProposalMeta", () => {
//     assert.entityCount("ProposalMeta", 0);
//     handleProposalTallied(createProposalTallied(1, 2, "0x01"));
//     handleProposalTallied(createProposalTallied(3, 4, "0x02"));
//     assert.entityCount("ProposalMeta", 2);

//     assert.fieldEquals("ProposalMeta", "0x01", "proposal", "1");
//     assert.fieldEquals("ProposalMeta", "0x01", "currentScore", "2");
//     assert.fieldEquals("ProposalMeta", "0x02", "proposal", "3");
//     assert.fieldEquals("ProposalMeta", "0x02", "currentScore", "4");
//   });

//   test("update ProposalMeta", () => {
//     assert.entityCount("ProposalMeta", 0);
//     handleProposalTallied(createProposalTallied(1, 2, "0x01"));
//     assert.entityCount("ProposalMeta", 1);
//     handleProposalTallied(createProposalTallied(1, 3, "0x01"));
//     assert.entityCount("ProposalMeta", 1);

//     assert.fieldEquals("ProposalMeta", "0x01", "proposal", "1");
//     assert.fieldEquals("ProposalMeta", "0x01", "currentScore", "3");
//   });
// });
