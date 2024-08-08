// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Schema} from "bundle/textDAO/storages/Schema.sol";
import {TextDAOMainFunctions, TextDAOProtectedFunctions} from "bundle/textDAO/interfaces/TextDAOFunctions.sol";
import {TextDAOErrors} from "bundle/textDAO/interfaces/TextDAOErrors.sol";
import {TextDAOEvents} from "bundle/textDAO/interfaces/TextDAOEvents.sol";

/**
 * @title TextDAO Interface v0.1.0
 * @custom:version schema:0.1.0
 * @custom:version functions:0.1.0
 * @custom:version errors:0.1.0
 * @custom:version events:0.1.0
 */
interface ITextDAO is Schema, TextDAOMainFunctions, TextDAOErrors, TextDAOEvents {}

interface TextDAOFullInterface is ITextDAO, TextDAOProtectedFunctions {}
