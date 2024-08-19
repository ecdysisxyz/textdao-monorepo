import { ProposalExecuted } from "../../generated/TextDAO/TextDAOEvents";
import { loadCommand, loadProposal } from "../utils/entity-provider";

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
export function handleProposalExecuted(event: ProposalExecuted): void {
	const proposal = loadProposal(event.params.pid);

	proposal.fullyExecuted = true;

	const actions = loadCommand(
		event.params.pid,
		event.params.approvedCommandId,
	).actions.load();
	for (let i = 0; i < actions.length; i++) {
		const action = actions[i];
		action.status = "Executed";
		action.save();
	}

	proposal.save();
}
