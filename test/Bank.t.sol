// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.15;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";

contract BankTest is Test {
    address wallet1;
    address wallet2;
    address wallet3;
    address wallet4;
    address wallet5;

    address owner;

    Bank bank;

    function setUp() public {
        wallet1 = makeAddr("wallet1");
        wallet2 = makeAddr("wallet2");
        wallet3 = makeAddr("wallet3");
        wallet4 = makeAddr("wallet4");
        wallet5 = makeAddr("wallet5");

        deal(wallet1, 10 ether);
        deal(wallet2, 10 ether);
        deal(wallet3, 10 ether);
        deal(wallet4, 10 ether);
        deal(wallet5, 10 ether);

        owner = makeAddr("owner");
        vm.startPrank(owner);
        bank = new Bank(3);
        vm.stopPrank();
    }

    function testDeposit() public {
        console.log(wallet1);
        console.log(wallet2);
        console.log(wallet3);

        vm.startPrank(wallet1);
        bank.deposit{value: 1 ether}();
        assertEq(bank.balanceOf(wallet1), 1 ether);
        address[] memory ranks1 = bank.getTopN();
        assertTrue(ranks1[0] == wallet1);
        vm.stopPrank();

        vm.startPrank(wallet2);
        bank.deposit{value: 4 ether}();
        address[] memory ranks2 = bank.getTopN();
        assertTrue(ranks2[0] == wallet2);
        vm.stopPrank();

        vm.startPrank(wallet3);
        bank.deposit{value: 2 ether}();
        address[] memory ranks3 = bank.getTopN();
        assertTrue(ranks3[0] == wallet2);
        assertTrue(ranks3[2] == wallet1);
        vm.stopPrank();

        vm.prank(wallet4);
        bank.deposit{value: 6 ether}();
        address[] memory ranks4 = bank.getTopN();
        assertTrue(ranks4[0] == wallet4);

        vm.prank(wallet4);
        bank.deposit{value: 1 ether}();
        address[] memory ranks5 = bank.getTopN();
        assertTrue(ranks5[0] == wallet4);

        vm.prank(wallet5);
        bank.deposit{value: 9 ether}();
        address[] memory accounts = bank.getTopN();
        assertTrue(accounts[0] == wallet5);
    }
}
