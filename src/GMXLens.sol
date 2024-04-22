// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./interface/IGMXLens.sol";
import "./interface/IGMXOracle.sol";
import "./interface/IReader.sol";
import "./interface/IDataStore.sol";
import "./interface/IChainlinkOracle.sol";
import "./libraries/Keys.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
contract GMXLens is IGMXLens , Ownable {
    struct Config {
        address dataStore;
        address reader;
        address oracle;
        address chainlinkOracle;
    }
    Config public config;

    constructor(address initialOwner) Ownable(initialOwner) {}

    function setConfig(address _dataStore, address _reader, address _oracle, address _chainlinkOracle) external {
        config = Config({
            dataStore: _dataStore,
            reader: _reader,
            oracle: _oracle,
            chainlinkOracle: _chainlinkOracle
        });
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory) {
        IReader.MarketProps memory marketProps = IReader(config.reader).getMarket(config.dataStore, marketID);
        bytes32 pnlFactorType = keccak256(abi.encode("MAX_PNL_FACTOR_FOR_TRADERS"));
        bool maximize = true;
        (int256 marketTokenPrice, IReader.MarketPoolValueInfoProps memory marketPoolValueInfo) = IGMXOracle(config.oracle).getMarketTokenInfo(
            marketProps.marketToken,
            marketProps.indexToken,
            marketProps.longToken,
            marketProps.shortToken,
            pnlFactorType,
            maximize
        );

        IReader.MarketPrices memory marketPrices = getMarketPrices(marketProps);

        IReader.MarketInfo memory marketinfo = IReader(config.reader).getMarketInfo(config.dataStore, marketPrices, marketID);
        
        int256 openInterestLong = IReader(config.reader).getOpenInterestWithPnl(config.dataStore, marketProps, marketPrices.indexTokenPrice, true, false);
        int256 openInterestShort = IReader(config.reader).getOpenInterestWithPnl(config.dataStore, marketProps, marketPrices.indexTokenPrice, false, false);
        int256 maxOpenInterestUsdLong = IReader(config.reader).getOpenInterestWithPnl(config.dataStore, marketProps, marketPrices.indexTokenPrice, true, true);
        int256 maxOpenInterestUsdShort = IReader(config.reader).getOpenInterestWithPnl(config.dataStore, marketProps, marketPrices.indexTokenPrice, false, true);
        
        uint256 reservedUsdLong = getReservedUsd(config.dataStore, marketProps, marketPrices, true);
        uint256 reservedUsdShort = getReservedUsd(config.dataStore, marketProps, marketPrices, true);

        MarketDataState memory data = MarketDataState({
            marketToken: marketID,
            indexToken: marketProps.indexToken,
            longToken: marketProps.longToken,
            shortToken: marketProps.shortToken,
            poolValue: uint256(marketPoolValueInfo.poolValue), // 30 decimals
            longTokenAmount: marketPoolValueInfo.longTokenAmount, // token decimals
            longTokenUsd: marketPoolValueInfo.longTokenUsd, // 30 decimals
            shortTokenAmount: marketPoolValueInfo.shortTokenAmount, // token decimals
            shortTokenUsd: marketPoolValueInfo.shortTokenUsd, // 30 decimals
            openInterestLong: openInterestLong, // 30 decimals
            openInterestShort: openInterestShort, // 30 decimals
            pnlLong: marketPoolValueInfo.longPnl, // 30 decimals
            pnlShort: marketPoolValueInfo.shortPnl, // 30 decimals
            netPnl: marketPoolValueInfo.netPnl, // 30 decimals
            borrowingFactorPerSecondForLongs: marketinfo.borrowingFactorPerSecondForLongs, // 30 decimals
            borrowingFactorPerSecondForShorts: marketinfo.borrowingFactorPerSecondForShorts, // 30 decimals
            longsPayShorts: marketinfo.nextFunding.longsPayShorts,
            fundingFactorPerSecond: marketinfo.nextFunding.fundingFactorPerSecond, // 30 decimals
            fundingFactorPerSecondLongs: int256(marketinfo.nextFunding.fundingFactorPerSecond), // 30 decimals
            fundingFactorPerSecondShorts: int256(marketinfo.nextFunding.fundingFactorPerSecond), // 30 decimals
            reservedUsdLong: reservedUsdLong, // 30 decimals
            reservedUsdShort: reservedUsdShort, // 30 decimals
            maxOpenInterestUsdLong: uint256(maxOpenInterestUsdLong), // 30 decimals
            maxOpenInterestUsdShort: uint256(maxOpenInterestUsdShort) // 30 decimals
        });
        return data;
    }

    function getTokenPrice(address token) public view returns (uint256) {
        (int256 _price, uint8 _priceDecimals) = IChainlinkOracle(config.chainlinkOracle).consult(token);

        return uint256(_price) * 10 ** (30 - IERC20Metadata(token).decimals() - _priceDecimals);
    }

    function getReservedUsd(
        address dataStore,
        IReader.MarketProps memory market,
        IReader.MarketPrices memory prices,
        bool isLong
    ) internal view returns (uint256) {
        uint256 reservedUsd;
        if (isLong) {
            // for longs calculate the reserved USD based on the open interest and current indexTokenPrice
            // this works well for e.g. an ETH / USD market with long collateral token as WETH
            // the available amount to be reserved would scale with the price of ETH
            // this also works for e.g. a SOL / USD market with long collateral token as WETH
            // if the price of SOL increases more than the price of ETH, additional amounts would be
            // automatically reserved
            uint256 openInterestInTokens = getOpenInterestInTokens(dataStore, market, isLong);
            reservedUsd = openInterestInTokens * prices.indexTokenPrice.max;
        } else {
            // for shorts use the open interest as the reserved USD value
            // this works well for e.g. an ETH / USD market with short collateral token as USDC
            // the available amount to be reserved would not change with the price of ETH
            reservedUsd = getOpenInterest(dataStore, market, isLong);
        }

        return reservedUsd;
    }

    function getOpenInterest(
        address dataStore,
        IReader.MarketProps memory market
    ) internal view returns (uint256) {
        uint256 longOpenInterest = getOpenInterest(dataStore, market, true);
        uint256 shortOpenInterest = getOpenInterest(dataStore, market, false);

        return longOpenInterest + shortOpenInterest;
    }

    function getOpenInterest(
        address dataStore,
        IReader.MarketProps memory market,
        bool isLong
    ) internal view returns (uint256) {
        uint256 divisor = getPoolDivisor(market.longToken, market.shortToken);
        uint256 openInterestUsingLongTokenAsCollateral = getOpenInterest(dataStore, market.marketToken, market.longToken, isLong, divisor);
        uint256 openInterestUsingShortTokenAsCollateral = getOpenInterest(dataStore, market.marketToken, market.shortToken, isLong, divisor);

        return openInterestUsingLongTokenAsCollateral + openInterestUsingShortTokenAsCollateral;
    }

    function getOpenInterest(
        address dataStore,
        address market,
        address collateralToken,
        bool isLong,
        uint256 divisor
    ) internal view returns (uint256) {
        return IDataStore(dataStore).getUint(Keys.openInterestKey(market, collateralToken, isLong)) / divisor;
    }


    function getOpenInterestInTokens(
        address dataStore,
        IReader.MarketProps memory market,
        bool isLong
    ) internal view returns (uint256) {
        uint256 divisor = getPoolDivisor(market.longToken, market.shortToken);
        uint256 openInterestUsingLongTokenAsCollateral = getOpenInterestInTokens(dataStore, market.marketToken, market.longToken, isLong, divisor);
        uint256 openInterestUsingShortTokenAsCollateral = getOpenInterestInTokens(dataStore, market.marketToken, market.shortToken, isLong, divisor);

        return openInterestUsingLongTokenAsCollateral + openInterestUsingShortTokenAsCollateral;
    }

    function getOpenInterestInTokens(
        address dataStore,
        address market,
        address collateralToken,
        bool isLong,
        uint256 divisor
    ) internal view returns (uint256) {
        return IDataStore(dataStore).getUint(Keys.openInterestInTokensKey(market, collateralToken, isLong)) / divisor;
    }

    function getPoolDivisor(address longToken, address shortToken) internal pure returns (uint256) {
        return longToken == shortToken ? 2 : 1;
    }

    function getMarketPrices(IReader.MarketProps memory marketProps) public view returns (IReader.MarketPrices memory marketPrices) {
        uint256 longPrice = getTokenPrice(marketProps.longToken);
        uint256 shortPrice = getTokenPrice(marketProps.shortToken);
        uint256 indexPrice = getTokenPrice(marketProps.indexToken);
        marketPrices = IReader.MarketPrices({
            indexTokenPrice: IReader.PriceProps({
                max: indexPrice,
                min: indexPrice
            }),
            longTokenPrice: IReader.PriceProps({
                max: longPrice,
                min: longPrice
            }),
            shortTokenPrice: IReader.PriceProps({
                max: shortPrice,
                min: shortPrice
            })
        });
    }
}