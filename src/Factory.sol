// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./Exchange.sol";

contract Factory {

    mapping (address => address) public tokenToExchange;

    function createExchange(address _tokenAddress) public returns(address){

        require(_tokenAddress!=address(0),"Cannot create exchange for 0 address");
        require(tokenToExchange[_tokenAddress]==address(0),"Exchange already exists");
        Exchange exchange = new Exchange(_tokenAddress);
        tokenToExchange[_tokenAddress]=address(exchange);
        return address(exchange);

    }

    function getExchange(address _tokenAddress) public view returns(address) {

        return tokenToExchange[_tokenAddress];
    }
}