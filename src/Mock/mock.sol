// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../interface/IDataStore.sol";
import "../interface/IReader.sol";
import "../interface/IGMXOracle.sol";
import "../interface/IChainlinkOracle.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockDataStore is IDataStore {
    mapping(bytes32 => uint256) public store;

    function setUint(bytes32 key, uint256 value) public {
        store[key] = value;
    }

    function getUint(bytes32 key) external view returns (uint256) {
        return store[key];
    }
}

contract MockReader is IReader {

    address public marketToken;
    address public indexToken;
    address public longToken;
    address public shortToken;

    function getMarket(address, address marketID) external view returns (MarketProps memory) {
        require(marketID == marketToken, "Invalid Market");
        return MarketProps({
            marketToken: marketToken,
            indexToken: indexToken,
            longToken: longToken,
            shortToken: shortToken
        });
    }

    function setMarket(address marketID, address _indexToken, address _longToken, address _shortToken) external {
        marketToken = marketID;
        indexToken = _indexToken;
        longToken = _longToken;
        shortToken = _shortToken;
    }



    function getMarketInfo(address, MarketPrices memory, address) external pure returns (MarketInfo memory) {
        return MarketInfo({
            market: MarketProps({
                marketToken: address(0),
                indexToken: address(0),
                longToken: address(0),
                shortToken: address(0)
            }),

            borrowingFactorPerSecondForLongs: 1,
            borrowingFactorPerSecondForShorts: 1,
            baseFunding: BaseFundingValues({
                fundingFeeAmountPerSize: PositionType({
                    long: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    }),
                    short: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    })
                }),
                claimableFundingAmountPerSize: PositionType({
                    long: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    }),
                    short: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    })
                })
            }),
            nextFunding: GetNextFundingAmountPerSizeResult({
                longsPayShorts: true,
                fundingFactorPerSecond: 1,
                fundingFeeAmountPerSizeDelta: PositionType({
                    long: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    }),
                    short: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    })
                }),
                claimableFundingAmountPerSizeDelta: PositionType({
                    long: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    }),
                    short: CollateralType({
                        longToken: 0,
                        shortToken: 0
                    })
                })
            }),
            virtualInventory: VirtualInventory({
                virtualPoolAmountForLongToken : 0,
                virtualPoolAmountForShortToken : 0,
                virtualInventoryForPositions : 0
            }),
            isDisabled: false
        });
    }

    function getOpenInterestWithPnl(address, MarketProps memory, PriceProps memory, bool, bool) external pure returns (int256) {
        return 1000;
    }
}

contract MockGMXOracle is IGMXOracle {
    function getMarketTokenInfo(address, address, address, address, bytes32, bool) external pure returns (int256, IReader.MarketPoolValueInfoProps memory) {
        return (500, IReader.MarketPoolValueInfoProps({
            poolValue: 1000,
            longPnl: 50,
            shortPnl: 50,
            netPnl: 0,
            longTokenAmount: 50,
            shortTokenAmount: 50,
            longTokenUsd: 50,
            shortTokenUsd: 50,

            totalBorrowingFees: 50,
            borrowingFeePoolFactor: 50,

            impactPoolAmount: 50
        }));
    }
}

contract MockChainlinkOracle is IChainlinkOracle {
    function consult(address) external pure returns (int256, uint8) {
        return (500, 2);
    }
}
