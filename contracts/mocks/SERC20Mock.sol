//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../SERC20.sol";

contract SERC20Mock is SERC20 {
    constructor()
        SERC20(
            "SERC20MOCK",
            "SERC20MOCK",
            0xFABB0ac9d68B0B445fB7357272Ff202C5651694a,
            15,
            15
        )
    {
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

        _sercSetTaxes(buyTaxes, true);
        _sercSetTaxes(sellTaxes, false);

        /*
            _mint is an internal function in ERC20.sol that is only called here,
            and CANNOT be called ever again
        */
        _mint(msg.sender, 1_000_000_000 * 1e18);
    }

    function setBuyTax(uint256 _buyDevTax, uint256 _buyLiqTax)
        external
        onlyOwner
    {
        uint256[] memory buyTaxes = new uint256[](2);
        buyTaxes[0] = _buyDevTax;
        buyTaxes[1] = _buyLiqTax;

        _sercSetTaxes(buyTaxes, true);
    }

    function setSellTax(uint256 _sellDevTax, uint256 _sellLiqTax)
        external
        onlyOwner
    {
        uint256[] memory sellTaxes = new uint256[](2);
        sellTaxes[0] = _sellDevTax;
        sellTaxes[1] = _sellLiqTax;

        _sercSetTaxes(sellTaxes, false);
    }
}
