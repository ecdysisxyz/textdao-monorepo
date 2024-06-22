import {
  HeaderProposed as HeaderProposedEvent,
  CommandProposed as CommandProposedEvent,
} from "../generated/Propose/Propose";
import { Header, Command, Action } from "../generated/schema";

export function handleHeaderProposed(event: HeaderProposedEvent): void {
  const id = event.params.header.id.toString();
  let header = Header.load(id);
  if (header == null) {
    header = new Header(event.params.header.id.toString());
  }

  header.proposal = event.params.pid.toString();
  header.currentScore = event.params.header.currentScore;
  header.metadataURI = event.params.header.metadataURI;
  header.tagIds = event.params.header.tagIds;
  header.save();
}
export function handleCommandProposed(event: CommandProposedEvent): void {
  let command = new Command(event.params.cmd.id.toHex());
  command.proposal = event.params.pid.toHex();
  command.currentScore = event.params.cmd.currentScore;
  command.save();
  event.params.cmd.actions.forEach((params, index) => {
    let action = new Action(
      event.transaction.hash.toHex() + "-" + index.toString()
    );
    action.command = command.id;
    action.func = params.func;
    action.abiParams = params.abiParams;
    action.save();
  });
}
