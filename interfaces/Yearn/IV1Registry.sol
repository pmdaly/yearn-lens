// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

interface IV1Registry {
    function getVaults() external view returns (address[] memory);

    function getVaultsLength() external view returns (uint256);
}
