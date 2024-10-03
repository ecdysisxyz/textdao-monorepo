import { Voted } from "../../generated/TextDAO/TextDAOEvents";
import { loadOrCreateVote } from "../utils/entity-provider";

/**
 * Handles the Voted event by creating or updating a Vote entity.
 * @param event The Voted event containing the event data
 */
export function handleVoted(event: Voted): void {
  const vote = loadOrCreateVote(event.params.pid, event.params.rep, event.block.timestamp);

  vote.rankedHeaderIds = event.params.vote.rankedHeaderIds;
  vote.rankedCommandIds = event.params.vote.rankedCommandIds;
  vote.updatedAt = event.block.timestamp;

  vote.save();
}
