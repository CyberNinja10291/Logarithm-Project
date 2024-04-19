// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./interface/IGMXLens.sol";
import "./interface/IGMXOracle.sol";
import "./interface/IReader.sol";
import "./interface/IChainlinkOracle.sol";

contract GMXLens is IGMXLens {
    struct Config {
        address dataStore;
        address reader;
        address oracle;
    }
    Config public config;

    function setConfig(address _dataStore, address _reader, address _oracle, address _chainlinkOracle) external {
        config = Config({
            dataStore: _dataStore,
            reader: _reader,
            oracle: _oracle,
            chainlinkOracle: _chainlinkOracle
        });
    }

    function getMarketData(address marketID) external view returns (MarketDataState memory) {
        MarketProps memory marketInfo = IReader(config.reader).getMarket(config.dataStore, marketID);
        bytes32 pnlFactorType = keccak256(abi.encode("MAX_PNL_FACTOR_FOR_TRADERS"));
        bool maximize = true;
        (int256 marketTokenPrice, IReader.MarketPoolValueInfoProps memory marketPoolValueInfo) = IGMXOracle(config.oracle).getMarketTokenInfo(
            marketInfo.marketToken,
            marketInfo.indexToken,
            marketInfo.longToken,
            marketInfo.shortToken,
            pnlFactorType,
            maximize
        );

        function _getTokenPriceMinMaxFormatted(address token) internal view returns (uint256) {
            (int256 _price, uint8 _priceDecimals) = chainlinkOracle.consult(token);

            return _price.toUint256() * 10 ** (30 - IERC20Metadata(token).decimals() - _priceDecimals);
        }

        MarketDataState memory data = MarketDataState({
            marketToken: marketID,
            indexToken: marketInfo.indexToken,
            longToken: marketInfo.longToken,
            shortToken: marketInfo.shortToken,
            poolValue: marketPoolValueInfo.poolValue, // 30 decimals
            longTokenAmount: marketPoolValueInfo.longTokenAmount, // token decimals
            longTokenUsd: marketPoolValueInfo.longTokenUsd, // 30 decimals
            shortTokenAmount: marketPoolValueInfo.shortTokenAmount, // token decimals
            shortTokenUsd: marketPoolValueInfo.shortTokenUsd, // 30 decimals
            openInterestLong: 0, // 30 decimals
            openInterestShort: 0, // 30 decimals
            pnlLong: marketPoolValueInfo.longPnl, // 30 decimals
            pnlShort: marketPoolValueInfo.shortPnl, // 30 decimals
            netPnl: marketPoolValueInfo.netPnl, // 30 decimals
            borrowingFactorPerSecondForLongs: 0, // 30 decimals
            borrowingFactorPerSecondForShorts: 0, // 30 decimals
            longsPayShorts: true,
            fundingFactorPerSecond: 0, // 30 decimals
            fundingFactorPerSecondLongs: 0, // 30 decimals
            fundingFactorPerSecondShorts: 0, // 30 decimals
            reservedUsdLong: 0, // 30 decimals
            reservedUsdShort: 0, // 30 decimals
            maxOpenInterestUsdLong: 0, // 30 decimals
            maxOpenInterestUsdShort: 0 // 30 decimals
        });
        return data;
    }
}