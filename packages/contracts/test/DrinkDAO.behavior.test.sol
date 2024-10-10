// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest, console} from "@mc-devkit/Flattened.sol";
import {DrinkDAODeployer} from "script/DrinkDAODeployer.sol";
import {IDrinkDAO, Schema, TextDAOEvents, TextDAOErrors} from "bundle/textdao/interfaces/IDrinkDAO.sol";
import {DrinkDAOFacade} from "bundle/textdao/interfaces/DrinkDAOFacade.sol";

/**
 * @title DrinkDAO Behavior-Focused Integration Test
 * @dev This contract contains scenario tests for the DrinkDAO from an end-user perspective
 */
contract DrinkDAOBehaviorTest is MCTest {
    address internal constant ADMIN1 = address(0x1234);
    address internal constant ADMIN2 = address(0x2345);
    address internal constant MEMBER1 = address(0x3456);
    address internal constant MEMBER2 = address(0x4567);
    address internal constant MEMBER3 = address(0x5678);
    address internal constant NON_MEMBER = address(0x6789);

    /**
     * @dev Tests the full lifecycle of a proposal in TextDAO
     */
    function test_scenario() public startPrankWith("DEPLOYER_PRIV_KEY") {
        // Deploy DrinkDAO
        Schema.DeliberationConfig memory _config = Schema.DeliberationConfig({
            expiryDuration: 3 days,
            snapInterval: 24 hours,
            repsNum: 3000,
            quorumScore: 1
        });
        DrinkDAOFacade drinkDAO = DrinkDAOFacade(DrinkDAODeployer.deployWithCheats({
            mc: mc,
            admin: deployer,
            initialConfig: _config
        }));
        vm.stopPrank();

        // Add admins
        address[] memory _admins = new address[](2);
        _admins[0] = ADMIN1;
        _admins[1] = ADMIN2;
        vm.prank(deployer);
        drinkDAO.addAdmins(_admins);

        // Add admins as members
        address[] memory _initialMembers = new address[](3);
        _initialMembers[0] = deployer;
        _initialMembers[1] = ADMIN1;
        _initialMembers[2] = ADMIN2;
        vm.prank(deployer);
        drinkDAO.addMembers(_initialMembers);

        // Propose test header
        string memory _headerMetadataCid = "HeaderMetadataCid";
        vm.expectEmit();
        emit TextDAOEvents.HeaderCreated(0, 1, _headerMetadataCid);
        emit TextDAOEvents.RepresentativesAssigned(0, _initialMembers);
        emit TextDAOEvents.Proposed(0, MEMBER1, block.timestamp, block.timestamp + _config.expiryDuration, _config.snapInterval);

        vm.prank(ADMIN1);
        drinkDAO.propose(_headerMetadataCid, new Schema.Action[](0));

        // 3 days later
        vm.warp(block.timestamp + 3 days);

        // Propose poc header
        uint256 _expirationTime = block.timestamp + _config.expiryDuration;
        vm.expectEmit();
        emit TextDAOEvents.HeaderCreated(1, 1, _headerMetadataCid);
        emit TextDAOEvents.RepresentativesAssigned(1, _initialMembers);
        emit TextDAOEvents.Proposed(1, MEMBER1, block.timestamp, _expirationTime, _config.snapInterval);

        vm.prank(ADMIN2);
        uint256 _pid = drinkDAO.propose(_headerMetadataCid, new Schema.Action[](0));

        // Vote for header
        Schema.Vote memory _vote;
        _vote.rankedHeaderIds[0] = 1;
        // _vote.rankedHeaderIds[0] = 1;
        vm.prank(ADMIN1);
        drinkDAO.vote(_pid, _vote);

        // 2 hours later
        vm.warp(block.timestamp + 2 hours);

        uint256 _startTime = block.timestamp;

        // 1 hour later
        vm.warp(block.timestamp + 1 hours);

        // Add members
        address[] memory _members = new address[](3);
        _members[0] = MEMBER1;
        _members[1] = MEMBER2;
        _members[2] = MEMBER3;
        vm.prank(ADMIN1);
        drinkDAO.addReps(_pid, _members);

        // Extend expiration time
        vm.prank(ADMIN1);
        drinkDAO.extendExpirationTime(_pid, 3 days);

        // [1st day] Fork and Vote
        for (uint i = 0; i < 10; i++) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            string memory _textMetadataCid = string.concat("TextMetadataCid", vm.toString(i));
            _actions[0] = Schema.Action({ // Action to be approved
                funcSig: "createText(uint256,string)",
                abiParams: abi.encode(_pid, _textMetadataCid)
            });
            vm.expectEmit();
            emit TextDAOEvents.CommandCreated(_pid, i + 1, _actions);
            vm.prank(_members[i % 3]);
            drinkDAO.forkCommand(_pid, _actions);

            // Vote
            vm.prank(_members[i % 3]);
            Schema.Vote memory _vote;
            _vote.rankedCommandIds[0] = 0;
            // _vote.rankedCommandIds[i % 3] = 1;
            vm.expectEmit();
            emit TextDAOEvents.Voted(_pid, _members[i % 3], _vote);
            drinkDAO.vote(_pid, _vote);

            // 10 mins later
            vm.warp(block.timestamp + 10 minutes);
        }

        // 1st day end
        vm.warp(_startTime + 1 days);

        // 1st Snapshot
        vm.prank(ADMIN1);
        drinkDAO.tally(_pid);

        // [2nd day] Fork and Vote
        for (uint i = 0; i < 7; i++) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            string memory _textMetadataCid = string.concat("TextMetadataCid", vm.toString(i));
            _actions[0] = Schema.Action({ // Action to be approved
                funcSig: "createText(uint256,string)",
                abiParams: abi.encode(_pid, _textMetadataCid)
            });
            vm.expectEmit();
            emit TextDAOEvents.CommandCreated(_pid, i + 11, _actions);
            vm.prank(_members[i % 3]);
            drinkDAO.forkCommand(_pid, _actions);

            // Vote
            vm.prank(_members[i % 3]);
            Schema.Vote memory _vote;
            _vote.rankedCommandIds[0] = 4;
            // _vote.rankedCommandIds[(i + 10) % 3] = 1;
            vm.expectEmit();
            emit TextDAOEvents.Voted(_pid, _members[i % 3], _vote);
            drinkDAO.vote(_pid, _vote);

            // 10 mins later
            vm.warp(block.timestamp + 10 minutes);
        }

        // 2nd day end
        vm.warp(_startTime + 2 days);

        // 2nd Snapshot
        vm.prank(ADMIN1);
        drinkDAO.tally(_pid);

        // [3rd day] Fork and Vote
        for (uint i = 0; i < 12; i++) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            string memory _textMetadataCid = string.concat("TextMetadataCid", vm.toString(i));
            _actions[0] = Schema.Action({ // Action to be approved
                funcSig: "createText(uint256,string)",
                abiParams: abi.encode(_pid, _textMetadataCid)
            });
            vm.expectEmit();
            emit TextDAOEvents.CommandCreated(_pid, i + 18, _actions);
            vm.prank(_members[i % 3]);
            drinkDAO.forkCommand(_pid, _actions);

            // Vote
            vm.prank(_members[i % 3]);
            Schema.Vote memory _vote;
            _vote.rankedCommandIds[0] = 4;
            // _vote.rankedCommandIds[(i + 17) % 3] = 1;
            vm.expectEmit();
            emit TextDAOEvents.Voted(_pid, _members[i % 3], _vote);
            drinkDAO.vote(_pid, _vote);

            // 10 mins later
            vm.warp(block.timestamp + 10 minutes);
        }

        // 3rd day end
        vm.warp(_startTime + 3 days);

        // [4rd day] Fork and Vote
        for (uint i = 0; i < 3; i++) {
            Schema.Action[] memory _actions = new Schema.Action[](1);
            string memory _textMetadataCid = string.concat("TextMetadataCid", vm.toString(i));
            _actions[0] = Schema.Action({ // Action to be approved
                funcSig: "createText(uint256,string)",
                abiParams: abi.encode(_pid, _textMetadataCid)
            });
            vm.expectEmit();
            emit TextDAOEvents.CommandCreated(_pid, i + 30, _actions);
            vm.prank(_members[i % 3]);
            drinkDAO.forkCommand(_pid, _actions);

            // Vote
            vm.prank(_members[i % 3]);
            Schema.Vote memory _vote;
            _vote.rankedCommandIds[0] = 4;
            if (i == 3) {
                _vote.rankedCommandIds[0] = 4; // Vote for commandId=4
                _vote.rankedCommandIds[1] = 1; // Other votes can be adjusted
                _vote.rankedCommandIds[2] = 2; // Other votes can be adjusted
            } else {
                _vote.rankedCommandIds[0] = i + 1; // Default votes
                _vote.rankedCommandIds[1] = i + 2;
                _vote.rankedCommandIds[2] = i + 3;
            }
            vm.expectEmit();
            emit TextDAOEvents.Voted(_pid, _members[i % 3], _vote);
            drinkDAO.vote(_pid, _vote);

            // 10 mins later
            vm.warp(block.timestamp + 10 minutes);
        }

        console.log("block.timestamp", block.timestamp);
        console.log("time elapsed", (block.timestamp - _startTime) / 1 days);

        // Get top ids
        (uint[] memory _topHeaderIds, uint[] memory _topCommandIds) = drinkDAO.getCurrentTopIds(_pid);
        for (uint i = 0; i < _topHeaderIds.length; i++) {
            console.log("_topHeaderIds", _topHeaderIds[i]);
        }
        for (uint i = 0; i < _topCommandIds.length; i++) {
            console.log("_topCommandIds", _topCommandIds[i]);
        }

        // Get scores
        (uint[] memory _headerScores, uint[] memory _commandScores) = drinkDAO.getCurrentScores(_pid);
        // for (uint i = 0; i < _headerScores.length; i++) {
        //     console.log("_headerScores", _headerScores[i]);
        // }
        // for (uint i = 0; i < _commandScores.length; i++) {
        //     console.log("_commandScores", _commandScores[i]);
        // }

        // Get top scores
        (uint[] memory _topHeaderScores, uint[] memory _topCommandScores) = drinkDAO.getCurrentTopScores(_pid);
        for (uint i = 0; i < _topHeaderScores.length; i++) {
            console.log("_topHeaderScores", _topHeaderScores[i]);
        }
        for (uint i = 0; i < _topCommandScores.length; i++) {
            console.log("_topCommandScores", _topCommandScores[i]);
        }

        // Tally votes and then executed
        vm.expectEmit();
        emit TextDAOEvents.ProposalTallied(_pid, 1, 3);

        vm.prank(ADMIN1);
        drinkDAO.forceTally(_pid);

        vm.expectEmit();
        emit TextDAOEvents.TextCreatedByProposal(_pid, 0, "TextMetadataCid2");
        emit TextDAOEvents.ProposalExecuted(_pid, 3);
        vm.prank(ADMIN1);
        drinkDAO.execute(_pid);
    }
}
