// import { newMockEvent } from "matchstick-as";
// import { ethereum, BigInt, Address } from "@graphprotocol/graph-ts";
// import {
//     CommandCreated,
//     HeaderCreated,
//     Initialized,
//     ProposalExecuted,
//     ProposalSnapped,
//     ProposalTallied,
//     ProposalTalliedWithTie,
//     Proposed,
//     RepresentativesAssigned,
//     TextCreated,
//     TextDeleted,
//     TextUpdated,
//     VRFRequested,
//     Voted,
//     WARN_CommandChoiceIsDuplicate,
//     WARN_CommandChoiceIsOutOfRange,
//     WARN_HeaderChoiceIsDuplicate,
//     WARN_HeaderChoiceIsOutOfRange,
// } from "../generated/TextDAO/TextDAOEvents";

// export function createCommandCreatedEvent(
//     pid: BigInt,
//     commandId: BigInt,
//     actions: Array<ethereum.Tuple>
// ): CommandCreated {
//     let commandCreatedEvent = changetype<CommandCreated>(newMockEvent());

//     commandCreatedEvent.parameters = new Array();

//     commandCreatedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     commandCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "commandId",
//             ethereum.Value.fromUnsignedBigInt(commandId)
//         )
//     );
//     commandCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "actions",
//             ethereum.Value.fromTupleArray(actions)
//         )
//     );

//     return commandCreatedEvent;
// }

// export function createHeaderCreatedEvent(
//     pid: BigInt,
//     headerId: BigInt,
//     metadataURI: string
// ): HeaderCreated {
//     let headerCreatedEvent = changetype<HeaderCreated>(newMockEvent());

//     headerCreatedEvent.parameters = new Array();

//     headerCreatedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     headerCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "headerId",
//             ethereum.Value.fromUnsignedBigInt(headerId)
//         )
//     );
//     headerCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "metadataURI",
//             ethereum.Value.fromString(metadataURI)
//         )
//     );

//     return headerCreatedEvent;
// }

// export function createInitializedEvent(version: BigInt): Initialized {
//     let initializedEvent = changetype<Initialized>(newMockEvent());

//     initializedEvent.parameters = new Array();

//     initializedEvent.parameters.push(
//         new ethereum.EventParam(
//             "version",
//             ethereum.Value.fromUnsignedBigInt(version)
//         )
//     );

//     return initializedEvent;
// }

// export function createProposalExecutedEvent(
//     pid: BigInt,
//     approvedCommandId: BigInt
// ): ProposalExecuted {
//     let proposalExecutedEvent = changetype<ProposalExecuted>(newMockEvent());

//     proposalExecutedEvent.parameters = new Array();

//     proposalExecutedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     proposalExecutedEvent.parameters.push(
//         new ethereum.EventParam(
//             "approvedCommandId",
//             ethereum.Value.fromUnsignedBigInt(approvedCommandId)
//         )
//     );

//     return proposalExecutedEvent;
// }

// export function createProposalSnappedEvent(
//     pid: BigInt,
//     top3HeaderIds: Array<BigInt>,
//     top3CommandIds: Array<BigInt>
// ): ProposalSnapped {
//     let proposalSnappedEvent = changetype<ProposalSnapped>(newMockEvent());

//     proposalSnappedEvent.parameters = new Array();

//     proposalSnappedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     proposalSnappedEvent.parameters.push(
//         new ethereum.EventParam(
//             "top3HeaderIds",
//             ethereum.Value.fromUnsignedBigIntArray(top3HeaderIds)
//         )
//     );
//     proposalSnappedEvent.parameters.push(
//         new ethereum.EventParam(
//             "top3CommandIds",
//             ethereum.Value.fromUnsignedBigIntArray(top3CommandIds)
//         )
//     );

//     return proposalSnappedEvent;
// }

// export function createProposalTalliedEvent(
//     pid: BigInt,
//     approvedHeaderId: BigInt,
//     approvedCommandId: BigInt
// ): ProposalTallied {
//     let proposalTalliedEvent = changetype<ProposalTallied>(newMockEvent());

//     proposalTalliedEvent.parameters = new Array();

//     proposalTalliedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     proposalTalliedEvent.parameters.push(
//         new ethereum.EventParam(
//             "approvedHeaderId",
//             ethereum.Value.fromUnsignedBigInt(approvedHeaderId)
//         )
//     );
//     proposalTalliedEvent.parameters.push(
//         new ethereum.EventParam(
//             "approvedCommandId",
//             ethereum.Value.fromUnsignedBigInt(approvedCommandId)
//         )
//     );

//     return proposalTalliedEvent;
// }

// export function createProposalTalliedWithTieEvent(
//     pid: BigInt,
//     approvedHeaderIds: Array<BigInt>,
//     approvedCommandIds: Array<BigInt>
// ): ProposalTalliedWithTie {
//     let proposalTalliedWithTieEvent = changetype<ProposalTalliedWithTie>(
//         newMockEvent()
//     );

//     proposalTalliedWithTieEvent.parameters = new Array();

//     proposalTalliedWithTieEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     proposalTalliedWithTieEvent.parameters.push(
//         new ethereum.EventParam(
//             "approvedHeaderIds",
//             ethereum.Value.fromUnsignedBigIntArray(approvedHeaderIds)
//         )
//     );
//     proposalTalliedWithTieEvent.parameters.push(
//         new ethereum.EventParam(
//             "approvedCommandIds",
//             ethereum.Value.fromUnsignedBigIntArray(approvedCommandIds)
//         )
//     );

//     return proposalTalliedWithTieEvent;
// }

// export function createProposedEvent(
//     pid: BigInt,
//     proposer: Address,
//     createdAt: BigInt,
//     expirationTime: BigInt
// ): Proposed {
//     let proposedEvent = changetype<Proposed>(newMockEvent());

//     proposedEvent.parameters = new Array();

//     proposedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     proposedEvent.parameters.push(
//         new ethereum.EventParam(
//             "proposer",
//             ethereum.Value.fromAddress(proposer)
//         )
//     );
//     proposedEvent.parameters.push(
//         new ethereum.EventParam(
//             "createdAt",
//             ethereum.Value.fromUnsignedBigInt(createdAt)
//         )
//     );
//     proposedEvent.parameters.push(
//         new ethereum.EventParam(
//             "expirationTime",
//             ethereum.Value.fromUnsignedBigInt(expirationTime)
//         )
//     );

//     return proposedEvent;
// }

// export function createRepresentativesAssignedEvent(
//     pid: BigInt,
//     reps: Array<Address>
// ): RepresentativesAssigned {
//     let representativesAssignedEvent = changetype<RepresentativesAssigned>(
//         newMockEvent()
//     );

//     representativesAssignedEvent.parameters = new Array();

//     representativesAssignedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     representativesAssignedEvent.parameters.push(
//         new ethereum.EventParam("reps", ethereum.Value.fromAddressArray(reps))
//     );

//     return representativesAssignedEvent;
// }

// export function createTextCreatedEvent(
//     textId: BigInt,
//     metadataURI: string
// ): TextCreated {
//     let textCreatedEvent = changetype<TextCreated>(newMockEvent());

//     textCreatedEvent.parameters = new Array();

//     textCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "textId",
//             ethereum.Value.fromUnsignedBigInt(textId)
//         )
//     );
//     textCreatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "metadataURI",
//             ethereum.Value.fromString(metadataURI)
//         )
//     );

//     return textCreatedEvent;
// }

// export function createTextDeletedEvent(textId: BigInt): TextDeleted {
//     let textDeletedEvent = changetype<TextDeleted>(newMockEvent());

//     textDeletedEvent.parameters = new Array();

//     textDeletedEvent.parameters.push(
//         new ethereum.EventParam(
//             "textId",
//             ethereum.Value.fromUnsignedBigInt(textId)
//         )
//     );

//     return textDeletedEvent;
// }

// export function createTextUpdatedEvent(
//     textId: BigInt,
//     newMetadataURI: string
// ): TextUpdated {
//     let textUpdatedEvent = changetype<TextUpdated>(newMockEvent());

//     textUpdatedEvent.parameters = new Array();

//     textUpdatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "textId",
//             ethereum.Value.fromUnsignedBigInt(textId)
//         )
//     );
//     textUpdatedEvent.parameters.push(
//         new ethereum.EventParam(
//             "newMetadataURI",
//             ethereum.Value.fromString(newMetadataURI)
//         )
//     );

//     return textUpdatedEvent;
// }

// export function createVRFRequestedEvent(
//     pid: BigInt,
//     requestId: BigInt
// ): VRFRequested {
//     let vrfRequestedEvent = changetype<VRFRequested>(newMockEvent());

//     vrfRequestedEvent.parameters = new Array();

//     vrfRequestedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     vrfRequestedEvent.parameters.push(
//         new ethereum.EventParam(
//             "requestId",
//             ethereum.Value.fromUnsignedBigInt(requestId)
//         )
//     );

//     return vrfRequestedEvent;
// }

// export function createVotedEvent(
//     pid: BigInt,
//     rep: Address,
//     vote: ethereum.Tuple
// ): Voted {
//     let votedEvent = changetype<Voted>(newMockEvent());

//     votedEvent.parameters = new Array();

//     votedEvent.parameters.push(
//         new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid))
//     );
//     votedEvent.parameters.push(
//         new ethereum.EventParam("rep", ethereum.Value.fromAddress(rep))
//     );
//     votedEvent.parameters.push(
//         new ethereum.EventParam("vote", ethereum.Value.fromTuple(vote))
//     );

//     return votedEvent;
// }

// export function createWARN_CommandChoiceIsDuplicateEvent(
//     commandChoice: BigInt
// ): WARN_CommandChoiceIsDuplicate {
//     let warnCommandChoiceIsDuplicateEvent =
//         changetype<WARN_CommandChoiceIsDuplicate>(newMockEvent());

//     warnCommandChoiceIsDuplicateEvent.parameters = new Array();

//     warnCommandChoiceIsDuplicateEvent.parameters.push(
//         new ethereum.EventParam(
//             "commandChoice",
//             ethereum.Value.fromUnsignedBigInt(commandChoice)
//         )
//     );

//     return warnCommandChoiceIsDuplicateEvent;
// }

// export function createWARN_CommandChoiceIsOutOfRangeEvent(
//     commandChoice: BigInt
// ): WARN_CommandChoiceIsOutOfRange {
//     let warnCommandChoiceIsOutOfRangeEvent =
//         changetype<WARN_CommandChoiceIsOutOfRange>(newMockEvent());

//     warnCommandChoiceIsOutOfRangeEvent.parameters = new Array();

//     warnCommandChoiceIsOutOfRangeEvent.parameters.push(
//         new ethereum.EventParam(
//             "commandChoice",
//             ethereum.Value.fromUnsignedBigInt(commandChoice)
//         )
//     );

//     return warnCommandChoiceIsOutOfRangeEvent;
// }

// export function createWARN_HeaderChoiceIsDuplicateEvent(
//     headerChoice: BigInt
// ): WARN_HeaderChoiceIsDuplicate {
//     let warnHeaderChoiceIsDuplicateEvent =
//         changetype<WARN_HeaderChoiceIsDuplicate>(newMockEvent());

//     warnHeaderChoiceIsDuplicateEvent.parameters = new Array();

//     warnHeaderChoiceIsDuplicateEvent.parameters.push(
//         new ethereum.EventParam(
//             "headerChoice",
//             ethereum.Value.fromUnsignedBigInt(headerChoice)
//         )
//     );

//     return warnHeaderChoiceIsDuplicateEvent;
// }

// export function createWARN_HeaderChoiceIsOutOfRangeEvent(
//     headerChoice: BigInt
// ): WARN_HeaderChoiceIsOutOfRange {
//     let warnHeaderChoiceIsOutOfRangeEvent =
//         changetype<WARN_HeaderChoiceIsOutOfRange>(newMockEvent());

//     warnHeaderChoiceIsOutOfRangeEvent.parameters = new Array();

//     warnHeaderChoiceIsOutOfRangeEvent.parameters.push(
//         new ethereum.EventParam(
//             "headerChoice",
//             ethereum.Value.fromUnsignedBigInt(headerChoice)
//         )
//     );

//     return warnHeaderChoiceIsOutOfRangeEvent;
// }
