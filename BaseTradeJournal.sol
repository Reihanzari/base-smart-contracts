// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTradeJournal {

    enum TradeSide {
        Buy,
        Sell,
        Other
    }

    struct TradeRecord {
        address asset;
        TradeSide side;
        uint256 quantity;
        uint256 pricePerUnit;
        bytes32 referenceHash;
        string note;
        uint256 timestamp;
    }

    mapping(address => TradeRecord[]) private tradeRecords;

    event TradeRecorded(
        address indexed trader,
        uint256 indexed tradeId,
        address indexed asset,
        TradeSide side,
        uint256 quantity,
        uint256 pricePerUnit,
        bytes32 referenceHash
    );

    function recordTrade(
        address asset,
        TradeSide side,
        uint256 quantity,
        uint256 pricePerUnit,
        bytes32 referenceHash,
        string calldata note
    ) external {
        require(asset != address(0), "Invalid asset");
        require(quantity > 0, "Invalid quantity");
        require(pricePerUnit > 0, "Invalid price");

        uint256 tradeId = tradeRecords[msg.sender].length;

        tradeRecords[msg.sender].push(
            TradeRecord({
                asset: asset,
                side: side,
                quantity: quantity,
                pricePerUnit: pricePerUnit,
                referenceHash: referenceHash,
                note: note,
                timestamp: block.timestamp
            })
        );

        emit TradeRecorded(
            msg.sender,
            tradeId,
            asset,
            side,
            quantity,
            pricePerUnit,
            referenceHash
        );
    }

    function getTradeCount(
        address trader
    ) external view returns (uint256) {
        return tradeRecords[trader].length;
    }

    function getTrade(
        address trader,
        uint256 tradeId
    )
        external
        view
        returns (
            address asset,
            TradeSide side,
            uint256 quantity,
            uint256 pricePerUnit,
            bytes32 referenceHash,
            string memory note,
            uint256 timestamp
        )
    {
        require(
            tradeId < tradeRecords[trader].length,
            "Invalid trade ID"
        );

        TradeRecord memory record = tradeRecords[trader][tradeId];

        return (
            record.asset,
            record.side,
            record.quantity,
            record.pricePerUnit,
            record.referenceHash,
            record.note,
            record.timestamp
        );
    }
}
