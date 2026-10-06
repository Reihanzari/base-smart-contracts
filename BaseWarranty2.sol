// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseWarranty {

    struct Warranty {
        address owner;
        string productName;
        bytes32 serialHash;
        uint256 registeredAt;
        uint256 expiresAt;
        bool active;
    }

    mapping(bytes32 => Warranty) public warranties;

    event WarrantyRegistered(
        bytes32 indexed serialHash,
        address indexed owner,
        string productName,
        uint256 expiresAt
    );

    event WarrantyTransferred(
        bytes32 indexed serialHash,
        address indexed oldOwner,
        address indexed newOwner
    );

    event WarrantyRevoked(
        bytes32 indexed serialHash,
        address indexed owner
    );

    function registerWarranty(
        string calldata productName,
        bytes32 serialHash,
        uint256 durationSeconds
    ) external {
        require(
            bytes(productName).length > 0,
            "Empty product name"
        );

        require(
            serialHash != bytes32(0),
            "Invalid serial hash"
        );

        require(
            durationSeconds > 0,
            "Invalid duration"
        );

        require(
            warranties[serialHash].owner == address(0),
            "Warranty already exists"
        );

        uint256 expiration = block.timestamp + durationSeconds;

        warranties[serialHash] = Warranty({
            owner: msg.sender,
            productName: productName,
            serialHash: serialHash,
            registeredAt: block.timestamp,
            expiresAt: expiration,
            active: true
        });

        emit WarrantyRegistered(
            serialHash,
            msg.sender,
            productName,
            expiration
        );
    }

    function transferWarranty(
        bytes32 serialHash,
        address newOwner
    ) external {
        require(
            newOwner != address(0),
            "Invalid new owner"
        );

        Warranty storage warranty = warranties[serialHash];

        require(
            warranty.owner == msg.sender,
            "Not owner"
        );

        require(
            warranty.active,
            "Warranty inactive"
        );

        require(
            block.timestamp < warranty.expiresAt,
            "Warranty expired"
        );

        address oldOwner = warranty.owner;
        warranty.owner = newOwner;

        emit WarrantyTransferred(
            serialHash,
            oldOwner,
            newOwner
        );
    }

    function revokeWarranty(
        bytes32 serialHash
    ) external {
        Warranty storage warranty = warranties[serialHash];

        require(
            warranty.owner == msg.sender,
            "Not owner"
        );

        require(
            warranty.active,
            "Already inactive"
        );

        warranty.active = false;

        emit WarrantyRevoked(
            serialHash,
            msg.sender
        );
    }

    function isWarrantyValid(
        bytes32 serialHash
    ) external view returns (bool) {
        Warranty memory warranty = warranties[serialHash];

        return (
            warranty.owner != address(0) &&
            warranty.active &&
            block.timestamp < warranty.expiresAt
        );
    }

    function getWarranty(
        bytes32 serialHash
    )
        external
        view
        returns (
            address owner,
            string memory productName,
            bytes32 storedSerialHash,
            uint256 registeredAt,
            uint256 expiresAt,
            bool active
        )
    {
        Warranty memory warranty = warranties[serialHash];

        return (
            warranty.owner,
            warranty.productName,
            warranty.serialHash,
            warranty.registeredAt,
            warranty.expiresAt,
            warranty.active
        );
    }
}
