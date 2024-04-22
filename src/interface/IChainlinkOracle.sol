// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

interface IChainlinkOracle {
  function consult(address token) external view returns (int256 price, uint8 decimals);
}