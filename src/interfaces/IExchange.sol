// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IExchange {

    function getTokenAmount(uint256 ethSold) external returns(uint256);
    function ethToTokenSwap(uint256 _minToken) external payable;
    function tokenToEthSwap(uint256 _tokenSold, uint256 _minEth) external;
    function addLiquidity(uint256 _tokenAmount) external payable returns(uint256);
    function getReserve() external view returns (uint256);
    function getEthAmount(uint256 _tokenSold) external view returns (uint256);
    function removeLiquidity(uint256 _liquidity) external returns(uint256,uint256);
    function tokenToTokenSwap(uint256 _tokensSold, uint256 _minTokensBought, address _tokenAddress) external;
}