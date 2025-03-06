import { BaseCurrencyUpdated } from "../../../generated/HubDAO/HubDAOEvents";
import { loadOrCreateGlobalConfig } from "../utils/entity-provider";

/**
 * Handles the HeaderCreated event by creating Header and Proposal entities.
 * This function ensures that:
 * 1. A Header entity is created only if it doesn't already exist.
 * 2. A corresponding Proposal entity is created if it doesn't exist.
 * 3. The Header entity is properly linked to its Proposal.
 * 4. The metadata from IPFS is fetched and stored.
 * 5. The creation timestamp is recorded.
 *
 * @param event The HeaderCreated event containing the event data
 */
export function handleBaseCurrencyUpdated(event: BaseCurrencyUpdated): void {
  const globalConfig = loadOrCreateGlobalConfig();

  globalConfig.baseCurrency = event.params.newCurrency.addr;

  globalConfig.save();
}
