// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/Token.sol";
import "../src/Factory.sol";
import "../src/interfaces/IExchange.sol";

contract ExchangeTest is Test {

    IExchange exchange;
    Token token;
    Factory factory;
    function setUp() public {

        token = new Token("Sample Token","STK",100000);
        factory = new Factory();
        address exchangeAddress = factory.createExchange(address(token));
        exchange = IExchange(exchangeAddress);

    }

    function testBasicLiquidityFlow() public {
        
       uint256 initialBalance = token.balanceOf(address(this));
       token.approve(address(exchange),2000);
       console.log(address(this).balance);
       uint256 initialEthBalance = address(this).balance;
       uint256 liquidityMinted = exchange.addLiquidity{value: 1000}(2000);

       assertEq(liquidityMinted,1000);
       /*console.log(liquidityMinted);
       console.log(exchange.getReserve());
       console.log(exchange.getEthAmount(20));
       console.log(exchange.getTokenAmount(10));*/

       token.approve(address(exchange),20);
       exchange.tokenToEthSwap(20,9);
       uint256 newBalance = token.balanceOf(address(this));
       uint256 newEthBalance = address(this).balance;
       assertEq(newBalance,initialBalance-2000-20);
       assertEq(newEthBalance,initialEthBalance-1000+9);

       /*console.log(exchange.getReserve());
       console.log(exchange.getEthAmount(20));
       console.log(exchange.getTokenAmount(10));*/

       console.log(address(exchange).balance);

       (uint256 ethAmount, uint256 tokenAmount) = exchange.removeLiquidity(1000);
       console.log(ethAmount);
       console.log(tokenAmount);
       assertEq(exchange.getReserve(),0);
       assertEq(address(this).balance,newEthBalance+ethAmount);
       assertEq(ethAmount,991);

       assertEq(tokenAmount,2020);
       

       
    }

    receive() external payable {}
    fallback() external payable {}

}
