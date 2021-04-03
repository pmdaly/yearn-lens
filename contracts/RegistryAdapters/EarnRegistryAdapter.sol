// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;
pragma experimental ABIEncoderV2;

import "../../interfaces/Yearn/EarnToken.sol";
import "../../interfaces/Yearn/IGenericRegistry.sol";
import "../../interfaces/Common/IOracle.sol";
import "../../interfaces/Common/IERC20.sol";

contract RegistryAdapterEarn {
    address public registryAddress;
    IOracle public oracle;

    struct Asset {
        string name;
        address id;
        string version;
        AssetMetadata metadata;
    }

    struct AssetMetadata {
        address controller;
        uint256 totalAssets;
        uint256 totalSupply;
        uint256 pricePerShare;
    }

    constructor(address _registryAddress, address _oracleAddress) {
        require(_registryAddress != address(0), "Missing registry address");
        registryAddress = _registryAddress;
        oracle = IOracle(_oracleAddress);
    }

    struct AdapterInfo {
        address id;
        string typeId;
        string categoryId;
        string subcategoryId;
    }

    function adapterInfo() public view returns (AdapterInfo memory) {
        return
            AdapterInfo({
                id: address(this),
                typeId: "earn",
                categoryId: "deposit",
                subcategoryId: "safe"
            });
    }

    function assetsAddresses() public view returns (address[] memory) {
        return IGenericRegistry(registryAddress).assets();
    }

    function assetsLength() public view returns (uint256) {
        return assetsAddresses().length;
    }

    function assetTvl(address earnTokenAddress) public view returns (uint256) {
        EarnToken earnToken = EarnToken(earnTokenAddress);
        uint256 valueInToken = earnToken.calcPoolValueInToken();
        address underlyingTokenAddress = earnToken.token();
        IERC20 underlyingToken = IERC20(underlyingTokenAddress);
        uint256 underlyingTokenDecimals = underlyingToken.decimals();
        uint256 usdcDecimals = 6;
        uint256 decimalsAdjustment = underlyingTokenDecimals - usdcDecimals;
        uint256 price = oracle.getPriceUsdcRecommended(underlyingTokenAddress);
        uint256 tvl;
        if (decimalsAdjustment > 0) {
            tvl =
                (valueInToken * price * (10**decimalsAdjustment)) /
                10**(decimalsAdjustment + underlyingTokenDecimals);
        } else {
            tvl = (valueInToken * price) / 10**usdcDecimals;
        }
        return tvl;
    }

    function asset(address id) public view returns (Asset memory) {
        EarnToken earnToken = EarnToken(id);
        string memory name = earnToken.name();
        uint256 totalAssets = earnToken.pool();
        uint256 totalSupply = earnToken.totalSupply();
        string memory version = "0.00";
        uint256 pricePerShare = 0;
        // uint256 tvl = getTvl(id);
        bool earnTokenHasShares = totalSupply != 0;
        if (earnTokenHasShares) {
            pricePerShare = earnToken.getPricePerFullShare();
        }
        AssetMetadata memory metadata =
            AssetMetadata({
                controller: id,
                totalAssets: totalAssets,
                totalSupply: totalSupply,
                pricePerShare: pricePerShare
            });
        return
            Asset({id: id, name: name, version: version, metadata: metadata});
    }

    function assets() external view returns (Asset[] memory) {
        address[] memory assetAddresses = assetsAddresses();
        uint256 numberOfAssets = assetAddresses.length;
        Asset[] memory _assets = new Asset[](numberOfAssets);
        for (uint256 i = 0; i < numberOfAssets; i++) {
            address assetAddress = assetAddresses[i];
            Asset memory _asset = asset(assetAddress);
            _assets[i] = _asset;
        }
        return _assets;
    }

    function assetsTvl() external view returns (uint256) {
        uint256 tvl;
        address[] memory assetAddresses = assetsAddresses();
        uint256 numberOfAssets = assetAddresses.length;
        for (uint256 i = 0; i < numberOfAssets; i++) {
            address assetAddress = assetAddresses[i];
            uint256 _assetTvl = assetTvl(assetAddress);
            tvl += _assetTvl;
        }
        return tvl;
    }
}
