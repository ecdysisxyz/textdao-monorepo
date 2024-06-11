// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {MCTest} from "@devkit/Flattened.sol";

import {
    MemberJoinProtected,
    Storage,
    Schema
} from "bundle/textDAO/functions/protected/MemberJoinProtected.sol";
import {ProtectionBase} from "bundle/textDAO/functions/protected/ProtectionBase.sol";

contract MemberJoinProtectedTest is MCTest {

    function setUp() public {
        _use(MemberJoinProtected.memberJoin.selector, address(new MemberJoinProtected()));
    }

    function test_memberJoin_success(uint256 proposeTime, uint256 expiryTime, uint256 execTime, Schema.Member[] memory candidates) public {
        Storage.$Proposals().proposals[0].proposalMeta.createdAt = proposeTime;
        vm.assume(expiryTime >= proposeTime);
        Storage.$Proposals().config.expiryDuration = expiryTime - proposeTime;
        vm.assume(expiryTime < execTime);
        vm.warp(execTime);

        Storage.$Proposals().proposals[0].proposalMeta.cmdRank.push();

        MemberJoinProtected(address(this)).memberJoin({
            pid: 0,
            candidates: candidates
        });

        for (uint i; i < candidates.length; ++i) {
            assertEq(
                keccak256(abi.encode(candidates[i])),
                keccak256(abi.encode(Storage.$Members().members[i]))
            );
        }
        assertEq(candidates.length, Storage.$Members().nextMemberId);
    }

    function test_memberJoin_revert_notExpiredYet(uint256 proposeTime, uint256 expiryTime, uint256 execTime) public {
        Storage.$Proposals().proposals[0].proposalMeta.createdAt = proposeTime;
        vm.assume(expiryTime >= proposeTime);
        Storage.$Proposals().config.expiryDuration = expiryTime - proposeTime;
        vm.assume(execTime <= expiryTime);
        vm.warp(execTime);

        vm.expectRevert(ProtectionBase.ProposalNotExpiredYet.selector);
        MemberJoinProtected(address(this)).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

    function test_memberJoin_revert_notTalliedYet() public {
        vm.expectRevert(ProtectionBase.ProposalNotTalliedYet.selector);
        MemberJoinProtected(address(this)).memberJoin({
            pid: 0,
            candidates: new Schema.Member[](1)
        });
    }

}
