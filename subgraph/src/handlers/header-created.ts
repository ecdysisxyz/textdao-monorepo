import { HeaderCreated } from "../../generated/TextDAO/TextDAOEvents";
import { Header } from "../../generated/schema";
import { genHeaderId } from "../utils/entity-id-provider";
import { createProposalIfNotExist } from "../utils/entity-provider";

/**
 * Handles the HeaderCreated event by creating Header and Proposal entities.
 * This function ensures that:
 * 1. A Header entity is created only if it doesn't already exist.
 * 2. A corresponding Proposal entity is created if it doesn't exist.
 * 3. The Header entity is properly linked to its Proposal.
 *
 * @param event The HeaderCreated event containing the event data
 */
export function handleHeaderCreated(event: HeaderCreated): void {
    const headerEntityId = genHeaderId(event.params.pid, event.params.headerId);

    let header = Header.load(headerEntityId);
    if (header) return; // Header already exists, no need to create it again
    header = new Header(headerEntityId);

    header.proposal = createProposalIfNotExist(event.params.pid);
    header.metadataURI = event.params.metadataURI;

    header.save();
}
