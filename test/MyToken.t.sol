// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {MyToken} from "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address constant contractOwner = 0x636C16881D405cdE477f56546825c88862be5189;
     address constant alice = 0x001C7CA24BC0B0b81b2F9Ee69dEDD76995861C39;

    function setUp() public {
        console.log("This", address(this));
        token = new MyToken(contractOwner);
    }

    function testMint() public { 
        // Impersonate the owner to call mint function
        vm.prank(contractOwner);
        // mint tokens to Alice
        token.mint(alice, 10000000);
        console.log(alice);
        console.log(12345);
        // assert the balance
        assertEq(10000000, token.balanceOf(alice));
    }
}