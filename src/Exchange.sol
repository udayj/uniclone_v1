// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "./interfaces/IExchange.sol";

interface IFactory {

    function getExchange(address _tokenAddress) external returns(address);
}


contract Exchange is ERC20{

    address public tokenAddress;
    uint256 public fee=1;
    address public factoryAddress;

    constructor(address _tokenAddress) ERC20("Uni Token","UNI") {

        require (_tokenAddress != address(0), "0 address not allowed");
        tokenAddress=_tokenAddress;
        factoryAddress=msg.sender;
    }

    function addLiquidity(uint256 _tokenAmount) public payable returns(uint256) {

        
        IERC20 token = IERC20(tokenAddress);

        if (getReserve()==0){
            uint256 liquidity = address(this).balance;
            _mint(msg.sender,liquidity);
            token.transferFrom(msg.sender, address(this), _tokenAmount);
            return liquidity;
        }

        uint tokenAmount = (getReserve()*msg.value)/(address(this).balance-msg.value);
        require(_tokenAmount>=tokenAmount, "Insufficient token provided");

        uint256 liquidityMinted = (totalSupply()*msg.value)/(address(this).balance-msg.value);
        _mint(msg.sender,liquidityMinted);
        token.transferFrom(msg.sender,address(this),tokenAmount);
        return liquidityMinted;

    }

    function removeLiquidity(uint256 _liquidity) public returns(uint256,uint256){

        uint256 ethAmount = (address(this).balance*_liquidity)/totalSupply();
        uint256 tokenAmount = (getReserve()*_liquidity)/totalSupply();

        _burn(msg.sender,_liquidity);
        payable(msg.sender).transfer(ethAmount);
        IERC20(tokenAddress).transfer(msg.sender,tokenAmount);
        return (ethAmount,tokenAmount);

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

    ) private view returns(uint256) {

        require(inputReserve > 0 && outputReserve > 0, "invalid reserves");

        return (inputAmount*(100-fee) * outputReserve) / (inputReserve*100 + inputAmount*(100-fee));
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
        require(ethAmount >= _minEth, "Slippage exceeds allowance");

        IERC20(tokenAddress).transferFrom(msg.sender,address(this),_tokenSold);

        payable(msg.sender).transfer(ethAmount);
    }

    function ethToTokenSwap(uint256 _minToken) public payable {

        uint256 tokenAmount = getTokenAmount(msg.value);
        require(tokenAmount >= _minToken, "Slippage exceeds allowance");
        IERC20(tokenAddress).transfer(msg.sender,tokenAmount);
    }

    function tokenToTokenSwap(uint256 _tokensSold, uint256 _minTokensBought, address _tokenAddress) public {

        address exchangeAddress = IFactory(factoryAddress).getExchange(_tokenAddress);

        uint256 ethAmount = getEthAmount(_tokensSold);

        IExchange exchange = IExchange(exchangeAddress);
        uint256 tokenBought = exchange.getTokenAmount(ethAmount);

        require(tokenBought >= _minTokensBought, "Slippage allowance exceeded");

        IERC20(tokenAddress).transferFrom(msg.sender,address(this),_tokensSold);

        exchange.ethToTokenSwap{value:ethAmount}(_minTokensBought);
        IERC20(_tokenAddress).transfer(msg.sender,tokenBought);


    }
}