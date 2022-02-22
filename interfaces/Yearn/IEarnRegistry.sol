// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IEarnRegistry {
    function assets() external view returns (address[] memory);

    function numAssets() external view returns (uint256);
}
