// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
interface IReader {
    
    function getMarket(address dataStore, address key) external view returns (MarketProps memory);

    struct MarketInfo {
        MarketProps market;
        uint256 borrowingFactorPerSecondForLongs;
        uint256 borrowingFactorPerSecondForShorts;
        BaseFundingValues baseFunding;
        GetNextFundingAmountPerSizeResult nextFunding;
        VirtualInventory virtualInventory;
        bool isDisabled;
    }

    struct MarketPrices {
        PriceProps indexTokenPrice;
        PriceProps longTokenPrice;
        PriceProps shortTokenPrice;
    }

    struct MarketProps {
        address marketToken;
        address indexToken;
        address longToken;
        address shortToken;
    }

    struct PriceProps {
        uint256 min;
        uint256 max;
    }

    struct BaseFundingValues {
        PositionType fundingFeeAmountPerSize;
        PositionType claimableFundingAmountPerSize;
    }

    struct VirtualInventory {
        uint256 virtualPoolAmountForLongToken;
        uint256 virtualPoolAmountForShortToken;
        int256 virtualInventoryForPositions;
    }

    struct GetNextFundingAmountPerSizeResult {
        bool longsPayShorts;
        uint256 fundingFactorPerSecond;

        PositionType fundingFeeAmountPerSizeDelta;
        PositionType claimableFundingAmountPerSizeDelta;
    }

    struct PositionType {
        CollateralType long;
        CollateralType short;
    }

    struct CollateralType {
        uint256 longToken;
        uint256 shortToken;
    }

    struct MarketPoolValueInfoProps {
        int256 poolValue;
        int256 longPnl;
        int256 shortPnl;
        int256 netPnl;

        uint256 longTokenAmount;
        uint256 shortTokenAmount;
        uint256 longTokenUsd;
        uint256 shortTokenUsd;

        uint256 totalBorrowingFees;
        uint256 borrowingFeePoolFactor;

        uint256 impactPoolAmount;
    }

    function getMarketInfo(
        address dataStore,
        MarketPrices memory prices,
        address marketKey
    ) external view returns (MarketInfo memory);

    function getOpenInterestWithPnl(
        address dataStore,
        MarketProps memory market,
        PriceProps memory indexTokenPrice,
        bool isLong,
        bool maximize
    ) external view returns (int256);
}