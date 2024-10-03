import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import { Action, Command, Proposal } from "../../generated/schema";
import { genActionId, genCommandId, genProposalId } from "../../src/utils/entity-id-provider";
import { createNewCommand } from "../../src/utils/entity-provider";

export function createMockProposalEntity(
  pid: BigInt,
  fullyExecuted: boolean = false,
  topHeaders: string[] | null = null,
  topCommands: string[] | null = null,
): Proposal {
  const proposal = new Proposal(genProposalId(pid));
  proposal.fullyExecuted = fullyExecuted;
  if (topHeaders !== null) {
    proposal.topHeaders = topHeaders;
  }
  if (topCommands !== null) {
    proposal.topCommands = topCommands;
  }
  proposal.save();
  return proposal;
}

export function createMockCommandEntity(
  pid: BigInt,
  commandId: BigInt,
  createdAt: BigInt = BigInt.fromI32(1721900001),
): void {
  const command = createNewCommand(pid, commandId, createdAt);
  command.proposal = genProposalId(pid);
  command.save();
}

export function createMockActionEntity(
  pid: BigInt,
  commandId: BigInt,
  actionId: i32,
  status: string = "Proposed",
  func: string = "mockFunction()",
  abiParams: Bytes = Bytes.fromHexString("0x"),
): void {
  const action = new Action(genActionId(pid, commandId, actionId));
  action.command = genCommandId(pid, commandId);
  action.status = status;
  action.func = func;
  action.abiParams = abiParams;
  action.save();
}
