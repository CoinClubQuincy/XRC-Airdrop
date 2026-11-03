// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "../../contracts/Airdrop.sol";

contract AirdropTest is Test {
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address carol = makeAddr("carol");
    SimpleToken token;
    Airdrop drop;

    function setUp() public {
        vm.startPrank(alice);
        token = new SimpleToken("Tok", "TOK", 1000);
        drop = new Airdrop("uri", address(token));
        token.transfer(address(drop), 1000);
        vm.stopPrank();
    }

    function test_ConstructorRejectsAZeroToken() public {
        vm.expectRevert("Token address is required");
        new Airdrop("uri", address(0));
    }

    function test_OnlyTheKeyHolderCanAddUsers() public {
        vm.prank(bob);
        vm.expectRevert("Caller is not owner");
        drop.AddUser(bob, 1);
    }

    function test_AddUserRejectsZeroAddressAndZeroAmount() public {
        vm.startPrank(alice);
        vm.expectRevert("User address is required");
        drop.AddUser(address(0), 1);
        vm.expectRevert("Amount is required");
        drop.AddUser(bob, 0);
        vm.stopPrank();
    }

    function test_AllocationCannotExceedTheContractBalance() public {
        vm.startPrank(alice);
        assertTrue(drop.AddUser(bob, 600));
        vm.expectRevert("Amount is more than is left to allocate");
        drop.AddUser(carol, 401);
        assertTrue(drop.AddUser(carol, 400));
        vm.stopPrank();
        assertEq(drop.TotalAlocated(), 1000);
        assertEq(drop.leftToBeAllocated(), 0);
    }

    function test_RedeemBeforeDeployReverts() public {
        vm.prank(alice);
        drop.AddUser(bob, 100);
        vm.prank(bob);
        vm.expectRevert("Airdrop status must be true");
        drop.RedeemAirdrop(0);
    }

    function test_DeployReturnsOnlyTheUnallocatedTokens() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        assertEq(token.balanceOf(alice), 900);
        assertEq(token.balanceOf(address(drop)), 100);
        vm.prank(bob);
        assertTrue(drop.RedeemAirdrop(0));
        assertEq(token.balanceOf(bob), 100);
    }

    function test_TokensAddedAfterTheLastEditAreReturnedToo() public {
        vm.startPrank(alice);
        SimpleToken other = new SimpleToken("Tok", "TOK", 1000);
        Airdrop second = new Airdrop("uri", address(other));
        other.transfer(address(second), 100);
        second.AddUser(bob, 100);
        other.transfer(address(second), 50);
        second.DeployAirDrop(true);
        vm.stopPrank();
        assertEq(other.balanceOf(address(second)), 100);
        assertEq(other.balanceOf(alice), 900);
    }

    function test_DeployWithFalseDoesNothing() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        assertFalse(drop.DeployAirDrop(false));
        vm.stopPrank();
        assertFalse(drop.AirDropStatus());
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(address(drop)), 1000);
        vm.prank(alice);
        assertTrue(drop.AddUser(carol, 100));
    }

    function test_CannotDeployTwice() public {
        vm.startPrank(alice);
        drop.DeployAirDrop(true);
        vm.expectRevert("Airdrop status must be false");
        drop.DeployAirDrop(true);
        vm.stopPrank();
    }

    function test_RedeemWithoutAClaimReturnsFalse() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        vm.prank(carol);
        assertFalse(drop.RedeemAirdrop(0));
    }

    function test_RedeemTwicePaysOnce() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        vm.startPrank(bob);
        assertTrue(drop.RedeemAirdrop(0));
        assertFalse(drop.RedeemAirdrop(0));
        vm.stopPrank();
        assertEq(token.balanceOf(bob), 100);
    }

    function test_RedeemPaysEveryEntryForTheCaller() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.AddUser(carol, 10);
        drop.AddUser(bob, 50);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        vm.prank(bob);
        assertTrue(drop.RedeemAirdrop(0));
        assertEq(token.balanceOf(bob), 150);
        vm.prank(carol);
        assertTrue(drop.RedeemAirdrop(0));
        assertEq(token.balanceOf(carol), 10);
    }

    function test_RedeemStartIndexSkipsEarlierEntries() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.AddUser(bob, 50);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        vm.startPrank(bob);
        assertTrue(drop.RedeemAirdrop(1));
        assertEq(token.balanceOf(bob), 50);
        assertTrue(drop.RedeemAirdrop(0));
        assertEq(token.balanceOf(bob), 150);
        vm.stopPrank();
    }

    function test_RemovedUserCannotRedeem() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.RemoveUser(0, false);
        drop.DeployAirDrop(true);
        vm.stopPrank();
        assertEq(token.balanceOf(alice), 1000);
        vm.prank(bob);
        assertFalse(drop.RedeemAirdrop(0));
    }

    function test_RemoveUserRejectsAnIndexOutOfRange() public {
        vm.prank(alice);
        vm.expectRevert("User does not exist");
        drop.RemoveUser(0, false);
    }

    function test_RemoveUserWithTrueChangesNothing() public {
        vm.startPrank(alice);
        drop.AddUser(bob, 100);
        drop.RemoveUser(0, false);
        drop.RemoveUser(0, true);
        vm.stopPrank();
        (, uint amount, bool exist) = drop.ViewUsers(0);
        assertEq(amount, 0);
        assertFalse(exist);
    }

    function testFuzz_PayoutsEqualTheBalance(uint64[5] memory amounts, uint8 removed) public {
        address[3] memory users = [bob, carol, makeAddr("dave")];
        SimpleToken t;
        Airdrop d;
        uint total;
        for (uint i = 0; i < 5; i++) {
            amounts[i] = uint64(bound(amounts[i], 1, type(uint64).max));
            total += amounts[i];
        }
        vm.startPrank(alice);
        t = new SimpleToken("Tok", "TOK", 0);
        vm.stopPrank();
        deal(address(t), alice, total + 7, true);
        vm.startPrank(alice);
        d = new Airdrop("uri", address(t));
        t.transfer(address(d), total + 7);
        for (uint i = 0; i < 5; i++) {
            assertTrue(d.AddUser(users[i % 3], amounts[i]));
        }
        d.RemoveUser(removed % 5, false);
        d.DeployAirDrop(true);
        vm.stopPrank();
        uint removedAmount = amounts[removed % 5];
        assertEq(t.balanceOf(alice), 7 + removedAmount);
        for (uint i = 0; i < 3; i++) {
            vm.prank(users[i]);
            d.RedeemAirdrop(0);
        }
        assertEq(t.balanceOf(address(d)), 0);
        assertEq(t.balanceOf(bob) + t.balanceOf(carol) + t.balanceOf(users[2]), total - removedAmount);
    }
}
