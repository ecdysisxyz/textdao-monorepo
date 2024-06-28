import {
  HeaderProposed as HeaderProposedEvent,
  CommandProposed as CommandProposedEvent,
} from "../generated/Propose/Propose";
import {
  HeaderScored as HeaderScoredEvent,
  CommandScored as CommandScoredEvent,
} from "../generated/Vote/Vote";
import { TextSaved as TextSavedEvent } from "../generated/SaveTextProtected/SaveTextProtected";
import { ProposalTallied as ProposalTalliedEvent } from "../generated/Tally/Tally";
import {
  Header,
  Command,
  Action,
  Text,
  ProposalMeta,
  Proposal,
} from "../generated/schema";
import { store, ipfs, Bytes } from "@graphprotocol/graph-ts";

export function handleHeaderProposed(event: HeaderProposedEvent): void {
  const id = event.params.header.id.toString();
  let header = Header.load(id);
  if (header == null) {
    header = new Header(id);
  }

  header.proposal = event.params.pid.toString();
  header.currentScore = event.params.header.currentScore;
  header.metadataURI = event.params.header.metadataURI;
  header.tagIds = event.params.header.tagIds;
  header.save();
}
export function handleCommandProposed(event: CommandProposedEvent): void {
  const id = event.params.cmd.id.toString();
  let command = Command.load(id);
  if (command == null) {
    command = new Command(id);
  }

  let actions = command.actions.load();
  for (let i: i32 = 0; i < actions.length; i++) {
    let action = actions[i];
    store.remove("Action", action.id);
  }

  command.proposal = event.params.pid.toString();
  command.currentScore = event.params.cmd.currentScore;
  command.save();
  for (let i: i32 = 0; i < event.params.cmd.actions.length; i++) {
    let action = new Action(
      event.transaction.hash.toHex() + "-" + i.toString()
    );
    action.command = command.id;
    action.func = event.params.cmd.actions[i].func;
    action.abiParams = event.params.cmd.actions[i].abiParams;
    action.save();
  }
}
export function handleHeaderScored(event: HeaderScoredEvent): void {
  const id = event.params.headerId.toString();
  let header = Header.load(id);
  if (header == null) {
    header = new Header(id);
  }
  header.proposal = event.params.pid.toString();
  header.currentScore = event.params.currentScore;
  header.save();
}
export function handleCommandScored(event: CommandScoredEvent): void {
  const id = event.params.cmdId.toString();
  let command = Command.load(id);
  if (command == null) {
    command = new Command(id);
  }
  command.proposal = event.params.pid.toString();
  command.currentScore = event.params.currentScore;
  command.save();
}
export function handleTextSaved(event: TextSavedEvent): void {
  const id = event.params.id.toString();
  let text = Text.load(id);
  if (text == null) {
    text = new Text(id);
  }
  text.metadataURIs = event.params.metadataURIs;
  text.bodies = event.params.metadataURIs.map<string>((metadataURI) => {
    const metadataBytes = ipfs.cat(metadataURI);
    if (metadataBytes) {
      return metadataBytes.toString();
    }
    return "";
  });
  text.save();
}
export function handleProposalTallied(event: ProposalTalliedEvent): void {
  const pid = event.params.pid.toString();
  let proposal = Proposal.load(pid);
  if (proposal == null) {
    proposal = new Proposal(pid);
  }
  const metas = proposal.proposalMeta.load();
  for (let i: i32 = 0; i < metas.length; i++) {
    const meta = metas[i];
    store.remove("ProposalMeta", meta.id);
  }

  const id = event.transaction.hash.toHex();
  let proposalMeta = new ProposalMeta(id);
  proposalMeta.proposal = pid;
  proposalMeta.currentScore = event.params.proposalMeta.currentScore;
  proposalMeta.headerRank = event.params.proposalMeta.headerRank;
  proposalMeta.cmdRank = event.params.proposalMeta.cmdRank;
  proposalMeta.nextHeaderTallyFrom =
    event.params.proposalMeta.nextHeaderTallyFrom;
  proposalMeta.nextCmdTallyFrom = event.params.proposalMeta.nextCmdTallyFrom;
  proposalMeta.reps = changetype<Bytes[]>(event.params.proposalMeta.reps);
  proposalMeta.createdAt = event.params.proposalMeta.createdAt;
  proposalMeta.vrfRequestId = event.params.proposalMeta.vrfRequestId;
  proposalMeta.save();
}
