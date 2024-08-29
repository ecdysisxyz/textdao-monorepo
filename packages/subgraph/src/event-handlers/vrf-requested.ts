import { VRFRequested } from "../../generated/TextDAO/TextDAOEvents";
import { createNewProposal } from "../utils/entity-provider";

export function handleVRFRequested(event: VRFRequested): void {
  const proposal = createNewProposal(event.params.pid);
  proposal.vrfRequestId = event.params.requestId;
  proposal.save();
}
