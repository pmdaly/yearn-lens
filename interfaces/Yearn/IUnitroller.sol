// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IUnitroller {
    function getAllMarkets() external view returns (address[] memory);
}
