import { CommandCreated } from "../../generated/TextDAO/TextDAOEvents";
import { Command, Action } from "../../generated/schema";
import { genCommandId, genActionId } from "../utils/entity-id-provider";
import { createProposalIfNotExist } from "../utils/entity-provider";

/**
 * Handles the CommandCreated event by creating Command, Proposal and Action entities.
 * This function ensures that:
 * 1. A Command entity is created for each new command.
 * 2. Action entities are created for each action within the command.
 * 3. A corresponding Proposal entity is created if it doesn't exist.
 * 4. The Command entity is properly linked to its Proposal.
 *
 * @param event - The CommandCreated event containing the event data
 */
export function handleCommandCreated(event: CommandCreated): void {
    const commandEntityId = genCommandId(
        event.params.pid,
        event.params.commandId
    );

    let command = Command.load(commandEntityId);
    if (command) return; // If the Command already exists, we don't want to overwrite it, so we return early
    command = new Command(commandEntityId);

    command.proposal = createProposalIfNotExist(event.params.pid);

    let actions = event.params.actions;
    for (let i = 0; i < actions.length; i++) {
        let actionEntityId = genActionId(
            event.params.pid,
            event.params.commandId,
            i
        );
        let action = Action.load(actionEntityId);
        if (action) continue; // If the Command already exists, we don't want to overwrite it, so we skip
        action = new Action(actionEntityId);

        action.command = commandEntityId;
        action.func = actions[i].funcSig;
        action.abiParams = actions[i].abiParams;
        action.status = "Proposed";
        action.save();
    }
    command.save();
}
