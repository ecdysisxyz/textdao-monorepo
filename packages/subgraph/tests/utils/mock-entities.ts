import { BigInt, Bytes } from "@graphprotocol/graph-ts";
import { Action, Command, Proposal } from "../../generated/schema";
import { genActionId, genCommandId, genProposalId } from "../../src/utils/entity-id-provider";

export function createMockProposalEntity(
  pid: BigInt,
  fullyExecuted: boolean = false,
  top3Headers: string[] | null = null,
  top3Commands: string[] | null = null,
): Proposal {
  const proposal = new Proposal(genProposalId(pid));
  proposal.fullyExecuted = fullyExecuted;
  if (top3Headers !== null) {
    proposal.top3Headers = top3Headers;
  }
  if (top3Commands !== null) {
    proposal.top3Commands = top3Commands;
  }
  proposal.save();
  return proposal;
}

export function createMockCommandEntity(
  pid: BigInt,
  commandId: BigInt,
  createdAt: BigInt = BigInt.fromI32(1721900001),
): void {
  const command = new Command(genCommandId(pid, commandId));
  command.proposal = genProposalId(pid);
  command.createdAt = createdAt;
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
