import { BigInt, Bytes } from "@graphprotocol/graph-ts";

export function genDeliberationConfigId(): string {
  return "DeliberationConfigID";
}

export function genProposalId(pid: BigInt): string {
  return pid.toString();
}

export function genHeaderId(pid: BigInt, headerId: BigInt): string {
  return "header-" + pid.toString() + "-" + headerId.toString();
}

export function genHeaderContentsId(cid: string): string {
  return cid;
}

export function genCommandId(pid: BigInt, commandId: BigInt): string {
  return "command-" + pid.toString() + "-" + commandId.toString();
}

export function genActionId(pid: BigInt, commandId: BigInt, actionId: number): string {
  return pid.toString() + "-" + commandId.toString() + "-" + actionId.toString();
}

export function genTopHeaderId(pid: BigInt, epoch: BigInt, index: i32): string {
  return "topHeader-" + pid.toString() + "-" + epoch.toString() + "-" + index.toString();
}

export function genTopCommandId(pid: BigInt, epoch: BigInt, index: i32): string {
  return "topCommand-" + pid.toString() + "-" + epoch.toString() + "-" + index.toString();
}

export function genVoteId(pid: BigInt, rep: Bytes): string {
  return pid.toString() + "-" + rep.toHexString();
}

export function genTextId(textId: BigInt): string {
  return textId.toString();
}

export function genTextContentsId(cid: string): string {
  return cid;
}

export function genMemberId(memberId: BigInt): string {
  return memberId.toString();
}

export function genMemberInfoId(cid: string): string {
  return cid;
}
