// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// Storage
import {Storage, Schema} from "bundle/textdao/storages/Storage.sol";
import {TextDAOEvents} from "bundle/textdao/interfaces/TextDAOEvents.sol";
import {DeliberationLib} from "bundle/textdao/utils/DeliberationLib.sol";
import {ProposalLib} from "bundle/textdao/utils/ProposalLib.sol";
import {RCVLib} from "bundle/textdao/utils/RCVLib.sol";
import {MemberLib} from "bundle/textdao/utils/MemberLib.sol";
// Interfaces
import {IExecute} from "bundle/textdao/interfaces/TextDAOFunctions.sol";
// Access Control
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract OnlyAdminCheats is Initializable {
    using DeliberationLib for Schema.Deliberation;
    using ProposalLib for Schema.Proposal;
    using RCVLib for Schema.Proposal;
    using RCVLib for uint[];
    using MemberLib for Schema.Members;

    modifier onlyAdmin() {
        bool _isAdmin;
        for (uint i; i < Storage.Admins().admins.length; ++i) {
            if (msg.sender == Storage.Admins().admins[i]) {
                _isAdmin = true;
                break;
            }
        }
        require(_isAdmin, "You are not the admin");
        _;
    }

    function initialize(address admin, Schema.DeliberationConfig calldata config) external initializer {
        Storage.Admins().admins.push(admin);
        Storage.Deliberation().config = config;
        emit TextDAOEvents.DeliberationConfigUpdated(config);
    }

    function addAdmins(address[] memory newAdmins) external onlyAdmin() {
        for (uint i; i < newAdmins.length; ++i) {
            Storage.Admins().admins.push(newAdmins[i]);
        }
    }

    // function forceAddAdmin(address admin) external {
    //     Storage.Admins().admins.push(admin);
    // }

    function addMembers(address[] memory newMembers) external onlyAdmin {
        for (uint i; i < newMembers.length; ++i) {
            Storage.Members().addMember(Schema.Member({
                addr: newMembers[i],
                metadataCid: ""
            }));
        }
    }

    function addReps(uint pid,address[] memory newMembers) external onlyAdmin {
        for (uint i; i < newMembers.length; ++i) {
            Storage.Members().addMember(Schema.Member({
                addr: newMembers[i],
                metadataCid: ""
            }));
            Storage.Deliberation().getProposal(pid).meta.reps.push(newMembers[i]);
        }
    }

    function updateConfig(Schema.DeliberationConfig calldata newConfig) external onlyAdmin {
        Storage.Deliberation().config = newConfig;
        emit TextDAOEvents.DeliberationConfigUpdated(newConfig);
    }

    // function transferAdmin(address newAdmin) external onlyAdmin { // TODO revokeAdmin
    //     Schema.Member storage $member = Storage.Members().members[0];
    //     $member.addr = newAdmin;
    //     emit TextDAOEvents.MemberUpdated(0, newAdmin, $member.metadataCid);
    // }

    function forceTally(uint pid) external onlyAdmin {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);

        (uint[] memory _headerScores, uint[] memory _commandScores) = $proposal.calcRCVScores();

        uint[] memory _topHeaderIds = _headerScores.findTopScorer();
        uint[] memory _topCommandIds = _commandScores.findTopScorer();

        // If there's a tie or no votes, extend the expiration time and emit an event
        if (_topHeaderIds.length == 0 ||    // no votes for header
            _topCommandIds.length == 0 ||   // no votes for command
            _topHeaderIds.length > 1 || // there's a tie header
            _topCommandIds.length > 1   // there's a tie command
        ) {
            $proposal.meta.expirationTime += Storage.Deliberation().config.expiryDuration;
            emit TextDAOEvents.ProposalTalliedWithTie(pid, $proposal.calcCurrentEpoch(), _topHeaderIds, _topCommandIds, $proposal.meta.expirationTime);
        } else {
            // Approve the winning header and command
            $proposal.approveHeader(_topHeaderIds[0]);
            $proposal.approveCommand(_topCommandIds[0]);
            emit TextDAOEvents.ProposalTallied(pid, _topHeaderIds[0], _topCommandIds[0]);
        }
    }

    function getCurrentTopIds(uint pid) external view returns(uint[] memory topHeaderIds, uint[] memory topCommandIds) {
        (uint[] memory _headerScores, uint[] memory _commandScores) = Storage.Deliberation().getProposal(pid).calcRCVScores();
        return (_headerScores.findTopScorer(), _commandScores.findTopScorer());
    }

    function getCurrentScores(uint pid) external view returns(uint[] memory headerScores, uint[] memory commandScores) {
        return Storage.Deliberation().getProposal(pid).calcRCVScores();
    }

    function getCurrentTopScores(uint pid) external view returns(uint[] memory topHeaderScores, uint[] memory topCommandScores) {
        (uint[] memory _headerScores, uint[] memory _commandScores) = Storage.Deliberation().getProposal(pid).calcRCVScores();
        uint[] memory _topHeaderIds = _headerScores.findTopScorer();
        uint[] memory _topCommandIds = _commandScores.findTopScorer();

        topHeaderScores = new uint[](_topHeaderIds.length);
        topCommandScores = new uint[](_topCommandIds.length);

        for (uint i; i < _topHeaderIds.length; ++i) {
            topHeaderScores[i] = _headerScores[_topHeaderIds[i]];
        }

        for (uint i; i < _topCommandIds.length; ++i) {
            topCommandScores[i] = _commandScores[_topCommandIds[i]];
        }
    }

    function extendExpirationTime(uint pid, uint timeToExtend) external onlyAdmin {
        Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);
        $proposal.meta.expirationTime = block.timestamp + timeToExtend;

        uint[] memory _topHeaderIds;
        uint[] memory _topCommandIds;
        emit TextDAOEvents.ProposalTalliedWithTie(pid, $proposal.calcCurrentEpoch(), _topHeaderIds, _topCommandIds, $proposal.meta.expirationTime);
    }

    function forceApprove(uint pid, uint commandId) public onlyAdmin {
        Storage.Deliberation().getProposal(pid).approveCommand(commandId);
        emit TextDAOEvents.ProposalTallied(pid, 0, commandId);
    }

    function forceApproveAndExecute(uint pid, uint commandId) external onlyAdmin {
        forceApprove(pid, commandId);
        // Execute the approved command
        IExecute(address(this)).execute(pid);
    }

    // function forceApprove(uint pid, uint headerId, uint commandId) public onlyAdmin {
    //     Schema.Proposal storage $proposal = Storage.Deliberation().getProposal(pid);
    //     $proposal.approveHeader(headerId);
    //     $proposal.approveCommand(commandId);
    //     emit TextDAOEvents.ProposalTallied(pid, headerId, commandId);
    // }

    // function forceApproveAndExecute(uint pid, uint headerId, uint commandId) external onlyAdmin {
    //     forceApprove(pid, headerId, commandId);
    //     // Execute the approved command
    //     IExecute(address(this)).execute(pid);
    // }
}


// if no top header
//   if no top command = tie
//   else if more than two top command = tie
//   else if one top command = approve only top command
// else if one top header
//   if no top command = approve only top header
//   else if more than two top command = tie
//   else if one top command = approve both
// else if more than two top header = totally tie
//   if no top command = totally tie
//   else if more than two top command = tie
//   else if one top command = tie
