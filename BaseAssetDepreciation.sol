// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAssetDepreciation {

    struct Asset {
        address owner;
        string name;
        uint256 purchaseValue;
        uint256 salvageValue;
        uint256 usefulLifeSeconds;
        uint256 acquiredAt;
        bool retired;
        bool exists;
    }

    mapping(uint256 => Asset) private assets;

    uint256 public assetCount;

    event AssetRegistered(
        uint256 indexed assetId,
        address indexed owner,
        string name,
        uint256 purchaseValue,
        uint256 salvageValue
    );

    event AssetRetired(
        uint256 indexed assetId,
        address indexed owner
    );

    function registerAsset(
        string calldata name,
        uint256 purchaseValue,
        uint256 salvageValue,
        uint256 usefulLifeSeconds
    ) external returns (uint256) {
        require(bytes(name).length > 0, "Empty name");
        require(purchaseValue > 0, "Invalid purchase value");

        require(
            purchaseValue <= type(uint128).max,
            "Value too large"
        );

        require(
            salvageValue <= purchaseValue,
            "Salvage exceeds cost"
        );

        require(usefulLifeSeconds > 0, "Invalid useful life");

        require(
            usefulLifeSeconds <= 100 * 365 days,
            "Useful life too long"
        );

        uint256 id = assetCount;

        assets[id] = Asset({
            owner: msg.sender,
            name: name,
            purchaseValue: purchaseValue,
            salvageValue: salvageValue,
            usefulLifeSeconds: usefulLifeSeconds,
            acquiredAt: block.timestamp,
            retired: false,
            exists: true
        });

        assetCount++;

        emit AssetRegistered(
            id,
            msg.sender,
            name,
            purchaseValue,
            salvageValue
        );

        return id;
    }

    function retireAsset(
        uint256 assetId
    ) external {
        require(assetId < assetCount, "Invalid asset");

        Asset storage asset = assets[assetId];

        require(asset.owner == msg.sender, "Not asset owner");
        require(!asset.retired, "Already retired");

        asset.retired = true;

        emit AssetRetired(assetId, msg.sender);
    }

    function getBookValue(
        uint256 assetId
    ) public view returns (uint256) {
        require(assetId < assetCount, "Invalid asset");

        Asset memory asset = assets[assetId];

        uint256 cost = asset.purchaseValue;
        uint256 salvage = asset.salvageValue;

        if (
            asset.retired ||
            block.timestamp >= asset.acquiredAt + asset.usefulLifeSeconds
        ) {
            return salvage;
        }

        uint256 elapsed = block.timestamp - asset.acquiredAt;

        uint256 depreciated =
            ((cost - salvage) * elapsed) /
            asset.usefulLifeSeconds;

        return cost - depreciated;
    }

    function getDepreciatedAmount(
        uint256 assetId
    ) external view returns (uint256) {
        require(assetId < assetCount, "Invalid asset");

        Asset memory asset = assets[assetId];

        return asset.purchaseValue - getBookValue(assetId);
    }

    function getAsset(
        uint256 assetId
    )
        external
        view
        returns (
            address owner,
            string memory name,
            uint256 purchaseValue,
            uint256 salvageValue,
            uint256 usefulLifeSeconds,
            uint256 acquiredAt,
            bool retired
        )
    {
        require(assetId < assetCount, "Invalid asset");

        Asset memory a = assets[assetId];

        return (
            a.owner,
            a.name,
            a.purchaseValue,
            a.salvageValue,
            a.usefulLifeSeconds,
            a.acquiredAt,
            a.retired
        );
    }
}
