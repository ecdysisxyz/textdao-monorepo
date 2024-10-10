// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textdao/storages/Schema.sol";
import {TextDAOErrors} from "bundle/textdao/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";

/**
 * @title TextDAO Interface v0.1.0
 * @custom:version schema:0.1.0
 * @custom:version errors:0.1.0
 * @custom:version events:0.1.0
 */
interface IDrinkDAO is Schema, TextDAOErrors, TextDAOEvents {}
