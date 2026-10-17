// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCrossChainReceiptBook {

    struct Receipt {
        address registrar;
        address beneficiary;
        uint256 sourceChainId;
        bytes32 sourceTxHash;
        uint256 sourceLogIndex;
        bytes32 payloadHash;
        uint256 recordedAt;
        uint256 acknowledgedAt;
        bool acknowledged;
    }

    mapping(uint256 => Receipt) private receipts;

    mapping(bytes32 => uint256) private receiptIdPlusOne;

    uint256 public receiptCount;

    event ReceiptRecorded(
        uint256 indexed receiptId,
        address indexed beneficiary,
        uint256 sourceChainId,
        bytes32 sourceTxHash,
        uint256 sourceLogIndex,
        bytes32 payloadHash
    );

    event ReceiptAcknowledged(
        uint256 indexed receiptId,
        address indexed beneficiary,
        uint256 timestamp
    );

    function recordReceipt(
        address beneficiary,
        uint256 sourceChainId,
        bytes32 sourceTxHash,
        uint256 sourceLogIndex,
        bytes32 payloadHash
    ) external returns (uint256) {
        require(beneficiary != address(0), "Invalid beneficiary");
        require(sourceChainId > 0, "Invalid source chain");
        require(sourceTxHash != bytes32(0), "Invalid transaction hash");
        require(payloadHash != bytes32(0), "Invalid payload hash");

        bytes32 receiptKey = keccak256(
            abi.encode(
                sourceChainId,
                sourceTxHash,
                sourceLogIndex
            )
        );

        require(
            receiptIdPlusOne[receiptKey] == 0,
            "Receipt already recorded"
        );

        uint256 id = receiptCount;

        receipts[id] = Receipt({
            registrar: msg.sender,
            beneficiary: beneficiary,
            sourceChainId: sourceChainId,
            sourceTxHash: sourceTxHash,
            sourceLogIndex: sourceLogIndex,
            payloadHash: payloadHash,
            recordedAt: block.timestamp,
            acknowledgedAt: 0,
            acknowledged: false
        });

        receiptIdPlusOne[receiptKey] = id + 1;

        receiptCount++;

        emit ReceiptRecorded(
            id,
            beneficiary,
            sourceChainId,
            sourceTxHash,
            sourceLogIndex,
            payloadHash
        );

        return id;
    }

    function acknowledgeReceipt(
        uint256 receiptId
    ) external {
        require(receiptId < receiptCount, "Invalid receipt");

        Receipt storage receipt = receipts[receiptId];

        require(
            receipt.beneficiary == msg.sender,
            "Not beneficiary"
        );

        require(
            !receipt.acknowledged,
            "Already acknowledged"
        );

        receipt.acknowledged = true;
        receipt.acknowledgedAt = block.timestamp;

        emit ReceiptAcknowledged(
            receiptId,
            msg.sender,
            block.timestamp
        );
    }

    function findReceipt(
        uint256 sourceChainId,
        bytes32 sourceTxHash,
        uint256 sourceLogIndex
    )
        external
        view
        returns (
            bool exists,
            uint256 receiptId
        )
    {
        bytes32 receiptKey = keccak256(
            abi.encode(
                sourceChainId,
                sourceTxHash,
                sourceLogIndex
            )
        );

        uint256 storedValue = receiptIdPlusOne[receiptKey];

        if (storedValue == 0) {
            return (false, 0);
        }

        return (true, storedValue - 1);
    }

    function getReceipt(
        uint256 receiptId
    )
        external
        view
        returns (
            address registrar,
            address beneficiary,
            uint256 sourceChainId,
            bytes32 sourceTxHash,
            uint256 sourceLogIndex,
            bytes32 payloadHash,
            uint256 recordedAt,
            uint256 acknowledgedAt,
            bool acknowledged
        )
    {
        require(receiptId < receiptCount, "Invalid receipt");

        Receipt memory receipt = receipts[receiptId];

        return (
            receipt.registrar,
            receipt.beneficiary,
            receipt.sourceChainId,
            receipt.sourceTxHash,
            receipt.sourceLogIndex,
            receipt.payloadHash,
            receipt.recordedAt,
            receipt.acknowledgedAt,
            receipt.acknowledged
        );
    }
}
