// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "./lib/SERC20Library.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

abstract contract SERC20 is ERC20, Ownable {
    using SafeMath for uint256;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function sercBuyTax() public view returns (uint256[] memory) {
        return SERC20Library.getBuyTaxes();
    }

    function sercBuyTotalTax() public view returns (uint256) {
        return SERC20Library.getBuyTotalTax();
    }

    function sercSellTax() public view returns (uint256[] memory) {
        return SERC20Library.getSellTaxes();
    }

    function sercSellTotalTax() public view returns (uint256) {
        return SERC20Library.getSellTotalTax();
    }

    function sercMaxTx() public view returns (uint256) {
        return SERC20Library.getMaxTx();
    }

    function sercSetMaxTx(uint256 maxTx) external onlyOwner {
        SERC20Library.setMaxTx(maxTx);
    }

    function sercMaxWallet() public view returns (uint256) {
        return SERC20Library.getMaxWallet();
    }

    function sercSetMaxWallet(uint256 maxWallet) external onlyOwner {
        SERC20Library.setMaxWallet(maxWallet);
    }

    function sercIsBlacklisted(address addr) public view returns (bool) {
        return SERC20Library.getIsBlacklisted(addr);
    }

    function sercSetBlacklisted(address[] memory addrList, bool isBlacklisted)
        external
        onlyOwner
    {
        SERC20Library.setBlacklisted(addrList, isBlacklisted);
    }

    function sercTradingEnabled() public view returns (bool) {
        return SERC20Library.getTradingEnabled();
    }

    // This function can be overwritten to allow for more control over block ban etc.
    function sercSetTradingEnabled() public virtual onlyOwner {
        SERC20Library.setTradingEnabled();
    }
}
