import { HeaderCreated } from "../../generated/TextDAO/TextDAOEvents";
import {
    createNewHeader,
    loadOrCreateProposal,
} from "../utils/entity-provider";
import { saveHeaderMetadata } from "../file-data-handlers/proposal-header-metadata";

/**
 * Handles the HeaderCreated event by creating Header and Proposal entities.
 * This function ensures that:
 * 1. A Header entity is created only if it doesn't already exist.
 * 2. A corresponding Proposal entity is created if it doesn't exist.
 * 3. The Header entity is properly linked to its Proposal.
 * 4. The metadata from IPFS is fetched and stored.
 *
 * @param event The HeaderCreated event containing the event data
 */
export function handleHeaderCreated(event: HeaderCreated): void {
    const header = createNewHeader(event.params.pid, event.params.headerId);

    header.proposal = loadOrCreateProposal(event.params.pid).id;
    header.save();
    saveHeaderMetadata(event.params.metadataCid, header);
}
