// import {
//     assert,
//     describe,
//     test,
//     clearStore,
//     beforeAll,
//     afterAll,
// } from "matchstick-as/assembly/index";
// import { BigInt, Address } from "@graphprotocol/graph-ts";
// import { CommandCreated } from "../generated/schema";
// import { CommandCreated as CommandCreatedEvent } from "../generated/TextDAO/TextDAOEvents";
// import { handleCommandCreated } from "../src/text-dao-events";
// import { createCommandCreatedEvent } from "./text-dao-events-utils";

// // Tests structure (matchstick-as >=0.5.0)
// // https://thegraph.com/docs/en/developer/matchstick/#tests-structure-0-5-0

// describe("Describe entity assertions", () => {
//     beforeAll(() => {
//         let pid = BigInt.fromI32(234);
//         let commandId = BigInt.fromI32(234);
//         let actions = ["ethereum.Tuple Not implemented"];
//         let newCommandCreatedEvent = createCommandCreatedEvent(
//             pid,
//             commandId,
//             actions
//         );
//         handleCommandCreated(newCommandCreatedEvent);
//     });

//     afterAll(() => {
//         clearStore();
//     });

//     // For more test scenarios, see:
//     // https://thegraph.com/docs/en/developer/matchstick/#write-a-unit-test

//     test("CommandCreated created and stored", () => {
//         assert.entityCount("CommandCreated", 1);

//         // 0xa16081f360e3847006db660bae1c6d1b2e17ec2a is the default address used in newMockEvent() function
//         assert.fieldEquals(
//             "CommandCreated",
//             "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
//             "pid",
//             "234"
//         );
//         assert.fieldEquals(
//             "CommandCreated",
//             "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
//             "commandId",
//             "234"
//         );
//         assert.fieldEquals(
//             "CommandCreated",
//             "0xa16081f360e3847006db660bae1c6d1b2e17ec2a-1",
//             "actions",
//             "[ethereum.Tuple Not implemented]"
//         );

//         // More assert options:
//         // https://thegraph.com/docs/en/developer/matchstick/#asserts
//     });
// });
