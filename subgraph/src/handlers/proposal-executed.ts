import { ProposalExecuted as ProposalExecutedEvent } from "../../generated/TextDAO/TextDAOEvents";
import { Proposal, Command, Action } from "../../generated/schema";
import {
    genProposalId,
    genCommandId,
    genActionId,
} from "../utils/entity-id-provider";

/**
 * Handles the ProposalExecuted event by updating the Proposal and Action entities.
 * This function ensures that:
 * 1. The Proposal entity is marked as fully executed.
 * 2. All Actions associated with the approved Command are marked as executed.
 *
 * If the Proposal or Command entities don't exist, the function will exit early.
 * Non-existent Actions are skipped without affecting the overall execution.
 *
 * @param event - The ProposalExecuted event containing the event data
 */
export function handleProposalExecuted(event: ProposalExecutedEvent): void {
    let proposalEntityId = genProposalId(event.params.pid);
    let proposal = Proposal.load(proposalEntityId);
    if (!proposal) return;

    let commandEntityId = genCommandId(
        event.params.pid,
        event.params.approvedCommandId
    );
    let command = Command.load(commandEntityId);
    if (command) {
        let actions = command.actions.load();
        for (let i = 0; i < actions.length; i++) {
            let actionEntityId = actions[i].id;
            let action = Action.load(actionEntityId);
            if (!action) continue;
            action.status = "Executed";
            action.save();
        }
    }

    // Save the proposal even if the command is not found
    proposal.fullyExecuted = true;
    proposal.save();
}
