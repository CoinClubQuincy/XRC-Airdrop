// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../contracts/Airdrop.sol";

/// Tests whose names start with test_KnownIssue pin current behaviour that is a defect.
contract AirdropTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    SimpleToken token;
    Airdrop drop;

    function setUp() public {
        vm.startPrank(alice);
        token = new SimpleToken("Tok", "TOK", 1000);
        drop = new Airdrop("uri", address(token));
        token.transfer(address(drop), 1000);
        vm.stopPrank();
    }

    function test_OnlyTheKeyHolderCanAddUsers() public {
        vm.prank(bob);
        vm.expectRevert("Caller is not owner");
        drop.AddUser(bob, 1);
    }

    function test_AllocationCannotExceedTheContractBalance() public {
        vm.prank(alice);
        assertFalse(drop.AddUser(bob, 1001));
    }

    function test_RedeemBeforeDeployReverts() public {
        vm.prank(alice);
        drop.AddUser(bob, 100);
        vm.prank(bob);
        vm.expectRevert("Airdrop status must be true");
        drop.RedeemAirdrop(0);
    }

    function test_WorkaroundRefreshTheRemainderBeforeDeploying() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.RemoveUser(type(uint).max, false);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        assertEq(token.balanceOf(alice), 900);
        vm.prank(bob);
        assertTrue(drop.RedeemAirdrop(0));
        assertEq(token.balanceOf(bob), 100);
    }

    function test_KnownIssue_DeployReturnsAllocatedTokensToTheOwner() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        assertEq(token.balanceOf(alice), 1000);
        assertEq(token.balanceOf(address(drop)), 0);
        vm.prank(bob);
        vm.expectRevert();
        drop.RedeemAirdrop(0);
    }

    function test_KnownIssue_DeployWithFalseStillSendsTokens() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.DeployAirDrop(false);
        vm.stopPrank();
        assertFalse(drop.AirDropStatus());
        assertEq(token.balanceOf(alice), 1000);
    }
}
