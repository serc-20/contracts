// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";

library SERC20Library {
    using SafeMath for uint256;

    struct Settings {
        uint256[] buyTaxes;
        uint256 buyTotalTax;
        uint256[] sellTaxes;
        uint256 sellTotalTax;
        uint256 taxThreshold;
        bool tradingEnabled;
        uint256 tradingEnabledAt;
        uint256 maxTx;
        uint256 maxWallet;
        address pair;
        bool pairSet;
        IUniswapV2Router02 router;
        bool routerSet;
        mapping(address => bool) blacklist;
    }

    function serc20Storage() private pure returns (Settings storage settings) {
        bytes32 position = keccak256("serc20.settings.storage");
        assembly {
            settings.slot := position
        }
    }

    function init(
        uint256[] memory buyTaxes,
        uint256[] memory sellTaxes,
        uint256 taxThreshold,
        uint256 maxTx,
        uint256 maxWallet,
        address router,
        bool tradingEnabled
    ) internal {
        Settings storage settings = serc20Storage();
        settings.buyTaxes = buyTaxes;
        settings.sellTaxes = sellTaxes;
        settings.taxThreshold = taxThreshold;

        setRouter(router);

        setMaxWallet(maxWallet);
        setMaxTx(maxTx);

        require(
            taxThreshold <= 30,
            "sERC20: Tax threshold can not be set higher than 30%"
        );

        setTaxes(buyTaxes, true);
        setTaxes(sellTaxes, false);

        settings.tradingEnabled = tradingEnabled;
    }

    function getMaxTx() internal view returns (uint256) {
        return serc20Storage().maxTx;
    }

    function setMaxTx(uint256 maxTx) internal {
        uint256 currentMaxTx = serc20Storage().maxTx;

        require(
            maxTx >= currentMaxTx,
            "sERC20: Can not lower the max tx amount"
        );

        require(
            maxTx <= serc20Storage().maxWallet,
            "sERC20: Can not set max tx higher than the max wallet"
        );

        serc20Storage().maxTx = maxTx;
    }

    function getMaxWallet() internal view returns (uint256) {
        return serc20Storage().maxWallet;
    }

    function setMaxWallet(uint256 maxWallet) internal {
        uint256 currentMaxWallet = serc20Storage().maxWallet;

        require(
            maxWallet >= currentMaxWallet,
            "sERC20: Can not lower the max wallet amount"
        );

        require(
            maxWallet >= serc20Storage().maxTx,
            "sERC20: Can not set max wallet lower than the max tx"
        );

        serc20Storage().maxWallet = maxWallet;
    }

    function getBuyTaxes() internal view returns (uint256[] memory) {
        return serc20Storage().buyTaxes;
    }

    function getBuyTotalTax() internal view returns (uint256) {
        return serc20Storage().buyTotalTax;
    }

    function getSellTaxes() internal view returns (uint256[] memory) {
        return serc20Storage().sellTaxes;
    }

    function getSellTotalTax() internal view returns (uint256) {
        return serc20Storage().sellTotalTax;
    }

    function setTaxes(uint256[] memory taxes, bool isBuy) internal {
        verifiyTaxes(taxes, isBuy);

        uint256 total = 0;

        if (isBuy) {
            serc20Storage().buyTaxes = taxes;

            for (uint256 i = 0; i < taxes.length; i++) {
                total += taxes[i];
            }

            serc20Storage().buyTotalTax = total;
        } else {
            serc20Storage().sellTaxes = taxes;

            for (uint256 i = 0; i < taxes.length; i++) {
                total += taxes[i];
            }

            serc20Storage().sellTotalTax = total;
        }
    }

    function verifiyTaxes(uint256[] memory taxes, bool isBuy) internal view {
        uint256 total = 0;

        for (uint256 i = 0; i < taxes.length; i++) {
            total += taxes[i];
        }

        uint256[] memory taxesToRead;

        if (isBuy) {
            taxesToRead = getSellTaxes();
        } else {
            taxesToRead = getBuyTaxes();
        }

        for (uint256 i = 0; i < taxesToRead.length; i++) {
            total += taxesToRead[i];
        }

        uint256 taxThreshold = getTaxThreshold();

        require(
            total <= taxThreshold,
            string(
                abi.encodePacked(
                    "sERC20: Round trip tax rate can not be set higher than ",
                    Strings.toString(taxThreshold),
                    "%"
                )
            )
        );
    }

    function getTaxThreshold() internal view returns (uint256) {
        return serc20Storage().taxThreshold;
    }

    function getPair() internal view returns (address) {
        return serc20Storage().pair;
    }

    function getRouter() internal view returns (IUniswapV2Router02) {
        return serc20Storage().router;
    }

    function setRouter(address addr) internal {
        require(
            !serc20Storage().routerSet && !serc20Storage().pairSet,
            "sERC20: Can not set router after initialisation"
        );

        require(addr != address(0), "sERC20: Can not set router to 0 address");

        require(
            addr != address(0x000000000000000000000000000000000000dEaD),
            "sERC20: Can not set router to NULL address"
        );

        require(
            addr != address(this),
            "sERC20: Can not set router to contract address"
        );

        require(
            !getIsBlacklisted(addr),
            "sERC20: Can not set router to a blacklisted address"
        );

        IUniswapV2Router02 router = IUniswapV2Router02(addr);
        address pair = IUniswapV2Factory(router.factory()).createPair(
            address(this),
            router.WETH()
        );

        require(
            !getIsBlacklisted(pair),
            "sERC20: Can not set pair to a blacklisted address"
        );

        serc20Storage().router = router;
        serc20Storage().routerSet = true;

        serc20Storage().pair = pair;
        serc20Storage().pairSet = true;
    }

    function getIsBlacklisted(address addr) internal view returns (bool) {
        return serc20Storage().blacklist[addr];
    }

    function setBlacklisted(address[] memory addrList, bool isBlacklisted) internal {
        if (getTradingEnabled()) {
            require(
                block.timestamp <=
                    serc20Storage().tradingEnabledAt + 10 minutes,
                "sERC20: Can not blacklist more than 10 minutes after trading has been enabled"
            );
        }

        address pair = getPair();
        address router = address(getRouter());
        for (uint256 i = 0; i < addrList.length; i++) {
            require(
                pair != addrList[i],
                "sERC20: Can not blacklist the pair address"
            );
            require(
                router != addrList[i],
                "sERC20: Can not blacklist the router address"
            );
            require(
                address(this) != addrList[i],
                "sERC20: Can not blacklist the contract address"
            );
            serc20Storage().blacklist[addrList[i]] = isBlacklisted;
        }
    }

    function getTradingEnabled() internal view returns (bool) {
        return serc20Storage().tradingEnabled;
    }

    function setTradingEnabled() internal {
        require(!getTradingEnabled(), "sERC20: Trading is already enabled");

        serc20Storage().tradingEnabledAt = block.timestamp;
        serc20Storage().tradingEnabled = true;
    }
}
