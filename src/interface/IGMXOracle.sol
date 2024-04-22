// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./IReader.sol";

interface IGMXOracle {
  function getMarketTokenInfo(
    address marketToken,
    address indexToken,
    address longToken,
    address shortToken,
    bytes32 pnlFactorType,
    bool maximize
  ) external view returns (int256, IReader.MarketPoolValueInfoProps memory);
}