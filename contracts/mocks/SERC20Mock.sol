//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "hardhat/console.sol";

import "../SERC20.sol";

contract SERC20Mock is SERC20 {
    constructor() SERC20("SERC20MOCK", "SERC20MOCK") {
        uint256[] memory buyTaxes = new uint256[](2);
        // Dev Tax
        buyTaxes[0] = 8;

        // Liq Tax
        buyTaxes[1] = 2;

        uint256[] memory sellTaxes = new uint256[](2);
        // Dev Tax
        sellTaxes[0] = 8;

        // Liq Tax
        sellTaxes[1] = 2;

        uint256 defaultMaxTx = 10_000_000 * 1e18; // 1%
        uint256 defaultMaxWallet = 20_000_000 * 1e18; // 2%

        SERC20Library.init(
            buyTaxes,
            sellTaxes,
            20,
            defaultMaxTx,
            defaultMaxWallet,
            0xFABB0ac9d68B0B445fB7357272Ff202C5651694a,
            false
        );
    }

    function setBuyTax(uint256 buyDevTax, uint256 buyLiqTax)
        external
        onlyOwner
    {
        uint256[] memory buyTaxes = new uint256[](2);
        buyTaxes[0] = buyDevTax;
        buyTaxes[1] = buyLiqTax;

        SERC20Library.setTaxes(buyTaxes, true);
    }

    function setSellTax(uint256 sellDevTax, uint256 sellLiqTax)
        external
        onlyOwner
    {
        uint256[] memory sellTaxes = new uint256[](2);
        sellTaxes[0] = sellDevTax;
        sellTaxes[1] = sellLiqTax;

        SERC20Library.setTaxes(sellTaxes, false);
    }
}
