import { CommandCreated } from "../../generated/TextDAO/TextDAOEvents";
import { createNewAction, createNewCommand, loadOrCreateProposal } from "../utils/entity-provider";

/**
 * Handles the CommandCreated event by creating Command, Proposal and Action entities.
 * This function ensures that:
 * 1. A Command entity is created for each new command.
 * 2. Action entities are created for each action within the command.
 * 3. A corresponding Proposal entity is created if it doesn't exist.
 * 4. The Command entity is properly linked to its Proposal.
 * 5. The creation timestamp is recorded for the Command entity.
 *
 * @param event - The CommandCreated event containing the event data
 */
export function handleCommandCreated(event: CommandCreated): void {
  const command = createNewCommand(event.params.pid, event.params.commandId, event.block.timestamp);

  command.proposal = loadOrCreateProposal(event.params.pid).id;

  const actions = event.params.actions;
  for (let i = 0; i < actions.length; i++) {
    const action = createNewAction(event.params.pid, event.params.commandId, i);
    action.command = command.id;
    action.func = actions[i].funcSig;
    action.abiParams = actions[i].abiParams;
    action.status = "Proposed";
    action.save();
  }

  command.save();
}
