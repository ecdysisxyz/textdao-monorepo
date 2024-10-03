import { BigInt, Bytes, store } from "@graphprotocol/graph-ts";
import {
  Action,
  Command,
  DeliberationConfig,
  Header,
  Member,
  Proposal,
  Text,
  TopCommand,
  TopHeader,
  Vote,
} from "../../generated/schema";
import {
  genActionId,
  genCommandId,
  genDeliberationConfigId,
  genHeaderId,
  genMemberId,
  genProposalId,
  genTextId,
  genTopCommandId,
  genTopHeaderId,
  genVoteId,
} from "./entity-id-provider";

// DeliberationConfig

export function loadOrCreateDeliberationConfig(): DeliberationConfig {
  const id = genDeliberationConfigId();
  let deliberationConfig = DeliberationConfig.load(id);
  if (deliberationConfig == null) {
    deliberationConfig = new DeliberationConfig(id);
  }
  return deliberationConfig;
}

// Proposal

/**
 * Creates a new Proposal entity if it doesn't exist.
 * @param pid The proposal ID
 * @returns The newly created Proposal entity
 * @throws Error if the Proposal already exists
 */
export function createNewProposal(pid: BigInt): Proposal {
  const id = genProposalId(pid);
  if (Proposal.load(id) !== null) {
    throw new Error("Proposal already exists");
  }
  return new Proposal(id);
}

/**
 * Loads an existing Proposal entity or creates a new one if it doesn't exist.
 * @param pid The proposal ID
 * @returns The loaded or newly created Proposal entity
 */
export function loadOrCreateProposal(pid: BigInt): Proposal {
  const id = genProposalId(pid);
  let proposal = Proposal.load(id);
  if (proposal == null) {
    proposal = new Proposal(id);
  }
  proposal.save();
  return proposal;
}

/**
 * Loads an existing Proposal entity.
 * @param pid The proposal ID
 * @returns The loaded Proposal entity
 * @throws Error if the Proposal does not exist
 */
export function loadProposal(pid: BigInt): Proposal {
  const id = genProposalId(pid);
  const proposal = Proposal.load(id);
  if (proposal == null) {
    throw new Error("Proposal not found");
  }
  return proposal;
}

// Header

/**
 * Creates a new Header entity if it doesn't exist.
 * @param pid The proposal ID
 * @param headerId The header ID
 * @returns The newly created Header entity
 * @throws Error if the Header already exists
 */
export function createNewHeader(pid: BigInt, headerId: BigInt, createdAt: BigInt): Header {
  const id = genHeaderId(pid, headerId);
  if (Header.load(id) !== null) {
    throw new Error("Header already exists");
  }
  const header = new Header(id);
  header.index = headerId;
  header.createdAt = createdAt;
  return header;
}

// Command

/**
 * Creates a new Command entity if it doesn't exist.
 * @param pid The proposal ID
 * @param commandId The command ID
 * @returns The newly created Command entity
 * @throws Error if the Command already exists
 */
export function createNewCommand(pid: BigInt, commandId: BigInt, createdAt: BigInt): Command {
  const id = genCommandId(pid, commandId);
  if (Command.load(id) !== null) {
    throw new Error("Command already exists");
  }
  const command = new Command(id);
  command.index = commandId;
  command.createdAt = createdAt;
  return command;
}

/**
 * Loads an existing Command entity.
 * @param pid The proposal ID
 * @param commandId The command ID
 * @returns The loaded Command entity
 * @throws Error if the Command does not exist
 */
export function loadCommand(pid: BigInt, commandId: BigInt): Command {
  const id = genCommandId(pid, commandId);
  const command = Command.load(id);
  if (command == null) {
    throw new Error("Command not found");
  }
  return command;
}

// Action

/**
 * Creates a new Action entity if it doesn't exist.
 * @param pid The proposal ID
 * @param commandId The command ID
 * @param actionId The action ID
 * @returns The newly created Action entity
 * @throws Error if the Action already exists
 */
export function createNewAction(pid: BigInt, commandId: BigInt, actionId: number): Action {
  const id = genActionId(pid, commandId, actionId);
  if (Action.load(id) !== null) {
    throw new Error("Action already exists");
  }
  return new Action(id);
}

// function createNewTopHeader(pid: BigInt, epoch: BigInt, index: i32, headerId: string): string {
//   const id = genTopHeaderId(pid, epoch, index);
//   if (TopHeader.load(id) !== null) {
//     throw new Error("TopHeader already exists");
//   }
//   const topHeader = new TopHeader(id);
//   topHeader.snappedEpoch = epoch;
//   topHeader.index = BigInt.fromI32(index as i32);
//   topHeader.header = headerId;
//   topHeader.save();

//   return id;
// }

function loadOrCreateTopHeader(pid: BigInt, epoch: BigInt, index: i32, headerId: string): string {
  const id = genTopHeaderId(pid, epoch, index);
  let topHeader = TopHeader.load(id);
  if (topHeader == null) {
    topHeader = new TopHeader(id);
  }
  topHeader.snappedEpoch = epoch;
  topHeader.index = BigInt.fromI32(index as i32);
  topHeader.header = headerId;
  topHeader.save();

  return id;
}

export function createNewTopHeaders(pid: BigInt, epoch: BigInt, headerIdsBigInt: Array<BigInt>): Array<string> {
  const topHeaderIds: Array<string> = [];
  for (let i = 0; i < headerIdsBigInt.length; i++) {
    topHeaderIds.push(loadOrCreateTopHeader(pid, epoch, i, genHeaderId(pid, headerIdsBigInt[i])));
  }
  return topHeaderIds;
}

// function createNewTopCommand(pid: BigInt, epoch: BigInt, index: i32, commandId: string): string {
//   const id = genTopCommandId(pid, epoch, index);
//   if (TopCommand.load(id) !== null) {
//     throw new Error("TopCommand already exists");
//   }
//   const topCommand = new TopCommand(id);
//   topCommand.snappedEpoch = epoch;
//   topCommand.index = BigInt.fromI32(index as i32);
//   topCommand.command = commandId;
//   topCommand.save();

//   return id;
// }

function loadOrCreateTopCommand(pid: BigInt, epoch: BigInt, index: i32, commandId: string): string {
  const id = genTopCommandId(pid, epoch, index);
  let topCommand = TopCommand.load(id);
  if (topCommand == null) {
    topCommand = new TopCommand(id);
  }
  topCommand.snappedEpoch = epoch;
  topCommand.index = BigInt.fromI32(index as i32);
  topCommand.command = commandId;
  topCommand.save();

  return id;
}

export function createNewTopCommands(pid: BigInt, epoch: BigInt, commandIdsBigInt: Array<BigInt>): Array<string> {
  const topCommandIds: Array<string> = [];
  for (let i = 0; i < commandIdsBigInt.length; i++) {
    topCommandIds.push(loadOrCreateTopCommand(pid, epoch, i, genCommandId(pid, commandIdsBigInt[i])));
  }
  return topCommandIds;
}

// Vote

/**
 * Loads an existing Vote entity or creates a new one if it doesn't exist.
 * @param pid The proposal ID
 * @param rep The representative's address
 * @param createdAt The block timestamp
 * @returns The loaded or newly created Vote entity
 */
export function loadOrCreateVote(pid: BigInt, rep: Bytes, createdAt: BigInt): Vote {
  const id = genVoteId(pid, rep);
  let vote = Vote.load(id);
  if (vote == null) {
    vote = new Vote(id);
    vote.proposal = genProposalId(pid);
    vote.rep = rep;
    vote.createdAt = createdAt;
    vote.updatedAt = createdAt;
    vote.save();
  }
  return vote;
}

// Text

/**
 * Creates a new Text entity if it doesn't exist.
 * @param textId The text ID
 * @returns The newly created Text entity
 * @throws Error if the Text already exists
 */
export function createNewText(textId: BigInt): Text {
  const id = genTextId(textId);
  if (Text.load(id) !== null) {
    throw new Error("Text already exists");
  }
  const text = new Text(id);
  text.index = textId;
  return text;
}

/**
 * Loads an existing Text entity.
 * @param textId The text ID
 * @returns The loaded Text entity
 * @throws Error if the Text does not exist
 */
export function loadText(textId: BigInt): Text {
  const id = genTextId(textId);
  const text = Text.load(id);
  if (text == null) {
    throw new Error("Text not found");
  }
  return text;
}

/**
 * Removes a Text entity from the store.
 * @param textId The text ID
 * @throws Error if the Text does not exist
 */
export function removeTextEntity(textId: BigInt): void {
  const id = genTextId(textId);
  if (Text.load(id) == null) {
    throw new Error("Text not found");
  } else {
    store.remove("Text", id);
  }
}

// Member

export function createNewMember(memberId: BigInt): Member {
  const id = genMemberId(memberId);
  if (Member.load(id) !== null) {
    throw new Error("Member already exists");
  }
  const member = new Member(id);
  member.index = memberId;
  return member;
}

export function loadMember(memberId: BigInt): Member {
  const id = genMemberId(memberId);
  const member = Member.load(id);
  if (member == null) {
    throw new Error("Member not found");
  }
  return member;
}

/**
 * Removes a Member entity from the store.
 * @param memberId The member ID
 * @throws Error if the Member does not exist
 */
export function removeMemberEntity(memberId: BigInt): void {
  const id = genMemberId(memberId);
  if (Member.load(id) == null) {
    throw new Error("Member not found");
  } else {
    store.remove("Member", id);
  }
}
