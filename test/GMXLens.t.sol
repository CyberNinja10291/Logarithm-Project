// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import "forge-std/console.sol";
import {GMXLens} from "../src/GMXLens.sol";
import {MyToken} from "../src/MyToken.sol";
import {MockDataStore, MockReader, MockGMXOracle, MockChainlinkOracle} from "../src/Mock/mock.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract GMXLensTest is Test {
    GMXLens public gmxLens;
    MockDataStore public dataStore;
    MockReader public reader;
    MockGMXOracle public gmxOracle;
    MockChainlinkOracle public chainlinkOracle;

    MyToken public marketToken;
    MyToken public indexToken;
    MyToken public longToken;
    MyToken public shortToken;
    address constant contractOwner = 0x636C16881D405cdE477f56546825c88862be5189;
    function setUp() public {
        console.log("This", address(this));
        dataStore = new MockDataStore();
        reader = new MockReader();
        gmxOracle = new MockGMXOracle();
        chainlinkOracle = new MockChainlinkOracle();
        gmxLens = new GMXLens(contractOwner);
        gmxLens.setConfig(address(dataStore), address(reader), address(gmxOracle), address(chainlinkOracle));
        marketToken = new MyToken(address(this));
        longToken = new MyToken(address(this));
        shortToken = new MyToken(address(this));
        indexToken = new MyToken(address(this));
        reader.setMarket(address(marketToken), address(indexToken), address(longToken), address(shortToken));
    }

    function testSetConfig() public {
        GMXLens.Config memory config;
         (config.dataStore, config.reader, config.oracle, config.chainlinkOracle) = gmxLens.config();
        // Check that the configuration was set correctly
        assertEq(address(config.dataStore), address(dataStore), "DataStore address should match");
        assertEq(address(config.reader), address(reader), "Reader address should match");
        assertEq(address(config.oracle), address(gmxOracle), "Oracle address should match");
        assertEq(address(config.chainlinkOracle), address(chainlinkOracle), "ChainlinkOracle address should match");
    }

    function testGetMarketData() public {
        address marketID = address(marketToken);

        GMXLens.MarketDataState memory marketData = gmxLens.getMarketData(marketID);
        assertEq(marketData.marketToken, marketID, "Market ID should match the input");
        assertEq(marketData.indexToken, address(indexToken), "Index token should match mock");
        assertEq(marketData.longToken, address(longToken), "Long token should match mock");
        assertEq(marketData.shortToken, address(shortToken), "Short token should match mock");
    }

}