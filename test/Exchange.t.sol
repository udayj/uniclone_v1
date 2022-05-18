// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Exchange.sol";
import "../src/Token.sol";

contract ExchangeTest is Test {

    Exchange exchange;
    Token token;
    function setUp() public {

        token = new Token("Sample Token","STK",100000);
        exchange=new Exchange(address(token));
    }

    function testAddLiquidity() public {
        
        uint balance=token.balanceOf(address(this));
        assertEq(balance,100000);
        token.approve(address(exchange),200);
        exchange.addLiquidity{value:100}(200);
        balance = token.balanceOf(address(this));
        assertEq(balance,100000-200);
        assertEq(token.balanceOf(address(exchange)),200);
        assertEq(address(exchange).balance,100);
        assertEq(exchange.getPriceToken(),500);
        console.log(exchange.getTokenAmount(100));
        console.log(exchange.getEthAmount(10));
    }
}
