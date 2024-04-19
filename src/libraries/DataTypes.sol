// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library DataTypes {
    struct MarketProps {
        address marketToken;
        address indexToken;
        address longToken;
        address shortToken;
    }
}