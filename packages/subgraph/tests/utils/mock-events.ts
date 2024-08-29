import { Address, BigInt, ethereum } from "@graphprotocol/graph-ts";
import { newMockEvent } from "matchstick-as";
import {
  CommandCreated,
  DeliberationConfigUpdated,
  DeliberationConfigUpdatedByProposal,
  HeaderCreated,
  MemberAdded,
  MemberAddedByProposal,
  MemberRemoved,
  MemberRemovedByProposal,
  MemberUpdated,
  MemberUpdatedByProposal,
  ProposalExecuted,
  ProposalSnapped,
  ProposalTallied,
  ProposalTalliedWithTie,
  Proposed,
  RepresentativesAssigned,
  TextCreated,
  TextCreatedByProposal,
  TextDeleted,
  TextDeletedByProposal,
  TextUpdated,
  TextUpdatedByProposal,
  VRFRequested,
  Voted,
} from "../../generated/TextDAO/TextDAOEvents";
import { Action, Vote } from "../../src/utils/schema-types";

/**
 * Creates a mock HeaderCreated event
 * @param pid - Proposal ID
 * @param header - Header ID
 * @param metadataCid - Metadata Cid for the header
 * @returns MockEvent of type HeaderCreated
 */
export function createMockHeaderCreatedEvent(pid: BigInt, headerId: BigInt, metadataCid: string): HeaderCreated {
  const event = changetype<HeaderCreated>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("headerId", ethereum.Value.fromUnsignedBigInt(headerId)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock CommandCreated event
 * @param pid - Proposal ID
 * @param commandId - Command ID
 * @param actions - Array of actions (each containing funcSig and abiParams)
 * @returns MockEvent of type CommandCreated
 */
export function createMockCommandCreatedEvent(pid: BigInt, commandId: BigInt, actions: Array<Action>): CommandCreated {
  const event = changetype<CommandCreated>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("commandId", ethereum.Value.fromUnsignedBigInt(commandId)));

  const actionsArray = new Array<ethereum.Tuple>();
  for (let i = 0; i < actions.length; i++) {
    const actionTuple = new ethereum.Tuple();
    actionTuple.push(ethereum.Value.fromString(actions[i].funcSig));
    actionTuple.push(ethereum.Value.fromBytes(actions[i].abiParams));
    actionsArray.push(actionTuple);
  }
  event.parameters.push(new ethereum.EventParam("actions", ethereum.Value.fromTupleArray(actionsArray)));

  return event;
}

/**
 * Creates a mock Proposed event
 * @param pid - Proposal ID
 * @param proposer - Address of the proposer
 * @param createdAt - Timestamp of proposal creation
 * @param expirationTime - Expiration timestamp of the proposal
 * @returns MockEvent of type Proposed
 */
export function createMockProposedEvent(
  pid: BigInt,
  proposer: Address,
  createdAt: BigInt,
  expirationTime: BigInt,
  snapInterval: BigInt,
): Proposed {
  const event = changetype<Proposed>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("proposer", ethereum.Value.fromAddress(proposer)));
  event.parameters.push(new ethereum.EventParam("createdAt", ethereum.Value.fromUnsignedBigInt(createdAt)));
  event.parameters.push(new ethereum.EventParam("expirationTime", ethereum.Value.fromUnsignedBigInt(expirationTime)));
  event.parameters.push(new ethereum.EventParam("snapInterval", ethereum.Value.fromUnsignedBigInt(snapInterval)));
  return event;
}

/**
 * Creates a mock RepresentativesAssigned event
 * @param pid - Proposal ID
 * @param reps - Array of representative addresses
 * @returns MockEvent of type RepresentativesAssigned
 */
export function createMockRepresentativesAssignedEvent(pid: BigInt, reps: Address[]): RepresentativesAssigned {
  const event = changetype<RepresentativesAssigned>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("reps", ethereum.Value.fromAddressArray(reps)));
  return event;
}

/**
 * Creates a mock VRFRequested event
 * @param pid - Proposal ID
 * @param requestId - VRF request ID
 * @returns MockEvent of type VRFRequested
 */
export function createMockVRFRequestedEvent(pid: BigInt, requestId: BigInt): VRFRequested {
  const event = changetype<VRFRequested>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("requestId", ethereum.Value.fromUnsignedBigInt(requestId)));
  return event;
}

/**
 * Creates a mock Voted event
 * @param pid - Proposal ID
 * @param rep - Address of the representative who voted
 * @param vote - Vote structure
 * @returns MockEvent of type Voted
 */
export function createMockVotedEvent(pid: BigInt, rep: Address, vote: Vote): Voted {
  const event = changetype<Voted>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("rep", ethereum.Value.fromAddress(rep)));

  const voteTuple = new ethereum.Tuple();
  voteTuple.push(ethereum.Value.fromUnsignedBigIntArray(vote.rankedHeaderIds));
  voteTuple.push(ethereum.Value.fromUnsignedBigIntArray(vote.rankedCommandIds));
  event.parameters.push(new ethereum.EventParam("vote", ethereum.Value.fromTuple(voteTuple)));

  return event;
}

/**
 * Creates a mock ProposalTalliedWithTie event
 * @param pid - Proposal ID
 * @param topHeaderIds - Array of top header IDs
 * @param topCommandIds - Array of top command IDs
 * @param extendedExpirationTime The unix timestamp
 * @returns MockEvent of type ProposalTalliedWithTie
 */
export function createMockProposalTalliedWithTieEvent(
  pid: BigInt,
  topHeaderIds: BigInt[],
  topCommandIds: BigInt[],
  extendedExpirationTime: BigInt,
): ProposalTalliedWithTie {
  const event = changetype<ProposalTalliedWithTie>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(
    new ethereum.EventParam("topHeaderIds", ethereum.Value.fromI32Array(topHeaderIds.map<i32>((id) => id.toI32()))),
  );
  event.parameters.push(
    new ethereum.EventParam("topCommandIds", ethereum.Value.fromI32Array(topCommandIds.map<i32>((id) => id.toI32()))),
  );
  event.parameters.push(
    new ethereum.EventParam("extendedExpirationTime", ethereum.Value.fromUnsignedBigInt(extendedExpirationTime)),
  );
  return event;
}

/**
 * Creates a mock ProposalTallied event
 * @param pid - Proposal ID
 * @param approvedHeaderId - Approved header ID
 * @param approvedCommandId - Approved command ID
 * @returns MockEvent of type ProposalTallied
 */
export function createMockProposalTalliedEvent(
  pid: BigInt,
  approvedHeaderId: BigInt,
  approvedCommandId: BigInt,
): ProposalTallied {
  const event = changetype<ProposalTallied>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(
    new ethereum.EventParam("approvedHeaderId", ethereum.Value.fromUnsignedBigInt(approvedHeaderId)),
  );
  event.parameters.push(
    new ethereum.EventParam("approvedCommandId", ethereum.Value.fromUnsignedBigInt(approvedCommandId)),
  );
  return event;
}

/**
 * Creates a mock ProposalSnapped event
 * @param pid - Proposal ID
 * @param epoch - Snapped epoch timestamp (rounded block.timestamp by interval)
 * @param top3HeaderIds - Array of top 3 header IDs
 * @param top3CommandIds - Array of top 3 command IDs
 * @returns MockEvent of type ProposalSnapped
 */
export function createMockProposalSnappedEvent(
  pid: BigInt,
  epoch: BigInt,
  top3HeaderIds: BigInt[],
  top3CommandIds: BigInt[],
): ProposalSnapped {
  const event = changetype<ProposalSnapped>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(new ethereum.EventParam("epoch", ethereum.Value.fromUnsignedBigInt(epoch)));
  event.parameters.push(
    new ethereum.EventParam("top3HeaderIds", ethereum.Value.fromI32Array(top3HeaderIds.map<i32>((id) => id.toI32()))),
  );
  event.parameters.push(
    new ethereum.EventParam("top3CommandIds", ethereum.Value.fromI32Array(top3CommandIds.map<i32>((id) => id.toI32()))),
  );
  return event;
}

/**
 * Creates a mock ProposalExecuted event
 * @param pid - Proposal ID
 * @param approvedCommandId - Approved command ID
 * @returns MockEvent of type ProposalExecuted
 */
export function createMockProposalExecutedEvent(pid: BigInt, approvedCommandId: BigInt): ProposalExecuted {
  const event = changetype<ProposalExecuted>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromUnsignedBigInt(pid)));
  event.parameters.push(
    new ethereum.EventParam("approvedCommandId", ethereum.Value.fromUnsignedBigInt(approvedCommandId)),
  );
  return event;
}

/**
 * Creates a mock TextCreated event
 * @param textId - Text ID
 * @param metadataCid - Metadata Cid for the text
 * @returns MockEvent of type TextCreated
 */
export function createMockTextCreatedEvent(textId: BigInt, metadataCid: string): TextCreated {
  const event = changetype<TextCreated>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock TextCreatedByProposal event
 * @param textId - Text ID
 * @param metadataCid - Metadata Cid for the text
 * @returns MockEvent of type TextCreatedByProposal
 */
export function createMockTextCreatedByProposalEvent(textId: BigInt, metadataCid: string): TextCreatedByProposal {
  const event = changetype<TextCreatedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock TextUpdated event
 * @param textId - Text ID
 * @param newMetadataCid - New metadata Cid for the text
 * @returns MockEvent of type TextUpdated
 */
export function createMockTextUpdatedEvent(textId: BigInt, newMetadataCid: string): TextUpdated {
  const event = changetype<TextUpdated>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  event.parameters.push(new ethereum.EventParam("newMetadataCid", ethereum.Value.fromString(newMetadataCid)));
  return event;
}

/**
 * Creates a mock TextUpdatedByProposal event
 * @param textId - Text ID
 * @param newMetadataCid - New metadata Cid for the text
 * @returns MockEvent of type TextUpdatedByProposal
 */
export function createMockTextUpdatedByProposalEvent(textId: BigInt, newMetadataCid: string): TextUpdatedByProposal {
  const event = changetype<TextUpdatedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  event.parameters.push(new ethereum.EventParam("newMetadataCid", ethereum.Value.fromString(newMetadataCid)));
  return event;
}

/**
 * Creates a mock TextDeleted event
 * @param textId - Text ID
 * @returns MockEvent of type TextDeleted
 */
export function createMockTextDeletedEvent(textId: BigInt): TextDeleted {
  const event = changetype<TextDeleted>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  return event;
}

/**
 * Creates a mock TextDeletedByProposal event
 * @param textId - Text ID
 * @returns MockEvent of type TextDeletedByProposal
 */
export function createMockTextDeletedByProposalEvent(textId: BigInt): TextDeletedByProposal {
  const event = changetype<TextDeletedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("textId", ethereum.Value.fromUnsignedBigInt(textId)));
  return event;
}

/**
 * Creates a mock MemberAdded event
 * @param memberId - Member ID
 * @param addr - Member address
 * @param metadataCid - Member profile metadata's content id
 * @returns MockEvent of type MemberAdded
 */
export function createMockMemberAddedEvent(memberId: BigInt, addr: Address, metadataCid: string): MemberAdded {
  const event = changetype<MemberAdded>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  event.parameters.push(new ethereum.EventParam("addr", ethereum.Value.fromAddress(addr)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock MemberAddedByProposal event
 * @param memberId - Member ID
 * @param addr - Member address
 * @param metadataCid - Member profile metadata's content id
 * @returns MockEvent of type MemberAddedByProposal
 */
export function createMockMemberAddedByProposalEvent(
  memberId: BigInt,
  addr: Address,
  metadataCid: string,
): MemberAddedByProposal {
  const event = changetype<MemberAddedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  event.parameters.push(new ethereum.EventParam("addr", ethereum.Value.fromAddress(addr)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock MemberUpdated event
 * @param memberId - Member ID
 * @param addr - Member address
 * @param metadataCid - Member profile metadata's content id
 * @returns MockEvent of type MemberUpdated
 */
export function createMockMemberUpdatedEvent(memberId: BigInt, addr: Address, metadataCid: string): MemberUpdated {
  const event = changetype<MemberUpdated>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  event.parameters.push(new ethereum.EventParam("addr", ethereum.Value.fromAddress(addr)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock MemberUpdatedByProposal event
 * @param memberId - Member ID
 * @param addr - Member address
 * @param metadataCid - Member profile metadata's content id
 * @returns MockEvent of type MemberUpdatedByProposal
 */
export function createMockMemberUpdatedByProposalEvent(
  memberId: BigInt,
  addr: Address,
  metadataCid: string,
): MemberUpdatedByProposal {
  const event = changetype<MemberUpdatedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  event.parameters.push(new ethereum.EventParam("addr", ethereum.Value.fromAddress(addr)));
  event.parameters.push(new ethereum.EventParam("metadataCid", ethereum.Value.fromString(metadataCid)));
  return event;
}

/**
 * Creates a mock MemberRemoved event
 * @param memberId - Member ID
 * @returns MockEvent of type MemberRemoved
 */
export function createMockMemberRemovedEvent(memberId: BigInt): MemberRemoved {
  const event = changetype<MemberRemoved>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  return event;
}

/**
 * Creates a mock MemberRemovedByProposal event
 * @param memberId - Member ID
 * @returns MockEvent of type MemberRemovedByProposal
 */
export function createMockMemberRemovedByProposalEvent(memberId: BigInt): MemberRemovedByProposal {
  const event = changetype<MemberRemovedByProposal>(newMockEvent());
  event.parameters = new Array();
  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("memberId", ethereum.Value.fromUnsignedBigInt(memberId)));
  return event;
}

/**
 * Creates a mock DeliberationConfigUpdated event
 * @param expiryDuration - Expiry duration for proposals
 * @param snapInterval - Interval for proposal snapshots
 * @param repsNum - Number of representatives
 * @param quorumScore - Quorum score required
 * @returns MockEvent of type DeliberationConfigUpdated
 */
export function createMockDeliberationConfigUpdatedEvent(
  expiryDuration: BigInt,
  snapInterval: BigInt,
  repsNum: BigInt,
  quorumScore: BigInt,
): DeliberationConfigUpdated {
  const event = changetype<DeliberationConfigUpdated>(newMockEvent());
  event.parameters = new Array();

  const configTuple = new ethereum.Tuple(4);
  configTuple[0] = ethereum.Value.fromUnsignedBigInt(expiryDuration);
  configTuple[1] = ethereum.Value.fromUnsignedBigInt(snapInterval);
  configTuple[2] = ethereum.Value.fromUnsignedBigInt(repsNum);
  configTuple[3] = ethereum.Value.fromUnsignedBigInt(quorumScore);

  event.parameters.push(new ethereum.EventParam("config", ethereum.Value.fromTuple(configTuple)));

  return event;
}

/**
 * Creates a mock DeliberationConfigUpdatedByProposal event
 * @param expiryDuration - Expiry duration for proposals
 * @param snapInterval - Interval for proposal snapshots
 * @param repsNum - Number of representatives
 * @param quorumScore - Quorum score required
 * @returns MockEvent of type DeliberationConfigUpdatedByProposal
 */
export function createMockDeliberationConfigUpdatedByProposalEvent(
  expiryDuration: BigInt,
  snapInterval: BigInt,
  repsNum: BigInt,
  quorumScore: BigInt,
): DeliberationConfigUpdatedByProposal {
  const event = changetype<DeliberationConfigUpdatedByProposal>(newMockEvent());
  event.parameters = new Array();

  const configTuple = new ethereum.Tuple(4);
  configTuple[0] = ethereum.Value.fromUnsignedBigInt(expiryDuration);
  configTuple[1] = ethereum.Value.fromUnsignedBigInt(snapInterval);
  configTuple[2] = ethereum.Value.fromUnsignedBigInt(repsNum);
  configTuple[3] = ethereum.Value.fromUnsignedBigInt(quorumScore);

  event.parameters.push(new ethereum.EventParam("pid", ethereum.Value.fromI32(0)));
  event.parameters.push(new ethereum.EventParam("config", ethereum.Value.fromTuple(configTuple)));

  return event;
}
