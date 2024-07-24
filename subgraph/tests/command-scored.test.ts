// import {
//   assert,
//   describe,
//   test,
//   clearStore,
//   beforeEach,
// } from "matchstick-as/assembly/index";
// import { Bytes } from "@graphprotocol/graph-ts";
// import { handleCommandScored, handleCommandProposed } from "../src/mapping";
// import { createCommandScored, createCommandProposed } from "./utils";

// describe("CommandScored", () => {
//   beforeEach(() => {
//     clearStore();
//     let abiParams1Hex = Bytes.fromUTF8("abi1").toHex();
//     let abiParams2Hex = Bytes.fromUTF8("abi2").toHex();
//     handleCommandProposed(
//       createCommandProposed(
//         1,
//         2,
//         "func1",
//         "func2",
//         abiParams1Hex,
//         abiParams2Hex,
//         3,
//         "0x01"
//       )
//     );
//   });

//   test("update currentScore", () => {
//     assert.fieldEquals("Command", "1", "currentScore", "3");
//     handleCommandScored(createCommandScored(1, 2, 5));
//     assert.fieldEquals("Command", "1", "currentScore", "5");
//   });
// });
