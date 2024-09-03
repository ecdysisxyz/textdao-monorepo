// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/hubdao/storages/Schema.sol";
import {HubDAOMainFunctions, HubDAOProtectedFunctions, ICheats} from "bundle/hubdao/interfaces/HubDAOFunctions.sol";
import {HubDAOErrors} from "bundle/hubdao/interfaces/HubDAOErrors.sol";
import {HubDAOEvents} from "bundle/hubdao/interfaces/HubDAOEvents.sol";

/**
 * @title HubDAO Interface v0.1.0
 * @custom:version schema:0.1.0
 * @custom:version functions:0.1.0
 * @custom:version errors:0.1.0
 * @custom:version events:0.1.0
 */
interface IHubDAO is Schema, HubDAOMainFunctions, HubDAOErrors, HubDAOEvents {}

interface IHubDAOWithCheats is IHubDAO, ICheats {}

interface HubDAOFullInterface is IHubDAO, HubDAOProtectedFunctions {}
