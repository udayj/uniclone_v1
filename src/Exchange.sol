// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract Exchange {

    address public tokenAddress;

    constructor(address _tokenAddress) {

        require (_tokenAddress != address(0), "0 address not allowed");
        tokenAddress=_tokenAddress;
    }

    function addLiquidity(uint256 _tokenAmount) public payable {

        IERC20 token = IERC20(tokenAddress);
        token.transferFrom(msg.sender, address(this), _tokenAmount);
    }

    function getReserve() public view returns (uint256) {

        return IERC20(tokenAddress).balanceOf(address(this));
    }

    function getPriceToken() public view returns (uint256) {

        uint256 tokenReserve = getReserve();
        uint256 ethReserve = address(this).balance;
        return  (ethReserve*1000)/tokenReserve;
    }

    function getPrice(uint256 inputReserve, uint256 outputReserve) public pure returns(uint256) {

        require(inputReserve>0, "Input reserve cannot be 0");
        require(outputReserve>0, "Output reserve cannot be 0");
        return (inputReserve*1000)/outputReserve;
    }

    function getAmount(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve

    ) private pure returns(uint256) {

        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");
        return (inputAmount * outputReserve) / (inputReserve + inputAmount);
    }

    function getTokenAmount(uint256 _ethSold) public view returns (uint256) {
        require(_ethSold > 0, "ethSold is too small");

        uint256 tokenReserve = getReserve();
        return getAmount(_ethSold, address(this).balance, tokenReserve);
        
    }

    function getEthAmount(uint256 _tokenSold) public view returns (uint256) {
        require(_tokenSold > 0, "tokenSold is too small");

        uint256 tokenReserve = getReserve();
        return getAmount(_tokenSold, tokenReserve, address(this).balance);
    }

    function tokenToEthSwap(uint256 _tokenSold, uint256 _minEth) public {

        uint256 ethAmount = getEthAmount(_tokenSold);
        require(ethAmount > _minEth, "Slippage exceeds allowance");

        IERC20(tokenAddress).transferFrom(msg.sender,address(this),_tokenSold);

        payable(address(this)).transfer(ethAmount);
    }

    function ethToTokenSwap(uint256 _ethSold, uint256 _minToken) public {

        uint256 tokenAmount = getTokenAmount(_ethSold);
        require(tokenAmount > _minToken, "Slippage exceeds allowance");
        IERC20(tokenAddress).transfer(msg.sender,tokenAmount);
    }
}