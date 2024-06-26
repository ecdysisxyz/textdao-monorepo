import {
  HeaderProposed as HeaderProposedEvent,
  CommandProposed as CommandProposedEvent,
} from "../generated/Propose/Propose";
import { Header, Command, Action } from "../generated/schema";
import { store } from "@graphprotocol/graph-ts";

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
