// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMigrationRegistry {

    enum MigrationStatus {
        Planned,
        InProgress,
        Completed,
        Cancelled
    }

    struct Migration {
        address maintainer;
        address oldAddress;
        address newAddress;
        bytes32 planHash;
        string title;
        string notes;
        uint256 createdAt;
        uint256 updatedAt;
        MigrationStatus status;
    }

    mapping(uint256 => Migration) private migrations;

    uint256 public migrationCount;

    event MigrationCreated(
        uint256 indexed migrationId,
        address indexed maintainer,
        address oldAddress,
        address newAddress,
        bytes32 planHash
    );

    event MigrationAddressUpdated(
        uint256 indexed migrationId,
        address newAddress
    );

    event MigrationNotesUpdated(
        uint256 indexed migrationId
    );

    event MigrationStatusChanged(
        uint256 indexed migrationId,
        MigrationStatus status
    );

    function createMigration(
        address oldAddress,
        address newAddress,
        bytes32 planHash,
        string calldata title,
        string calldata notes
    ) external returns (uint256) {
        require(oldAddress != address(0), "Invalid old address");
        require(newAddress != address(0), "Invalid new address");

        require(
            oldAddress != newAddress,
            "Addresses must differ"
        );

        require(planHash != bytes32(0), "Invalid plan hash");
        require(bytes(title).length > 0, "Empty title");

        uint256 id = migrationCount;

        migrations[id] = Migration({
            maintainer: msg.sender,
            oldAddress: oldAddress,
            newAddress: newAddress,
            planHash: planHash,
            title: title,
            notes: notes,
            createdAt: block.timestamp,
            updatedAt: block.timestamp,
            status: MigrationStatus.Planned
        });

        migrationCount++;

        emit MigrationCreated(
            id,
            msg.sender,
            oldAddress,
            newAddress,
            planHash
        );

        return id;
    }

    function updateNewAddress(
        uint256 migrationId,
        address newAddress
    ) external {
        require(
            migrationId < migrationCount,
            "Invalid migration"
        );

        Migration storage currentMigration = migrations[migrationId];

        require(
            currentMigration.maintainer == msg.sender,
            "Not maintainer"
        );

        require(
            currentMigration.status == MigrationStatus.Planned ||
            currentMigration.status == MigrationStatus.InProgress,
            "Migration is final"
        );

        require(newAddress != address(0), "Invalid new address");

        require(
            newAddress != currentMigration.oldAddress,
            "Addresses must differ"
        );

        currentMigration.newAddress = newAddress;
        currentMigration.updatedAt = block.timestamp;

        emit MigrationAddressUpdated(
            migrationId,
            newAddress
        );
    }

    function updateNotes(
        uint256 migrationId,
        string calldata notes
    ) external {
        require(
            migrationId < migrationCount,
            "Invalid migration"
        );

        Migration storage currentMigration = migrations[migrationId];

        require(
            currentMigration.maintainer == msg.sender,
            "Not maintainer"
        );

        require(
            currentMigration.status == MigrationStatus.Planned ||
            currentMigration.status == MigrationStatus.InProgress,
            "Migration is final"
        );

        currentMigration.notes = notes;
        currentMigration.updatedAt = block.timestamp;

        emit MigrationNotesUpdated(migrationId);
    }

    function setStatus(
        uint256 migrationId,
        MigrationStatus nextStatus
    ) external {
        require(
            migrationId < migrationCount,
            "Invalid migration"
        );

        Migration storage currentMigration = migrations[migrationId];

        require(
            currentMigration.maintainer == msg.sender,
            "Not maintainer"
        );

        MigrationStatus oldStatus = currentMigration.status;

        if (oldStatus == MigrationStatus.Planned) {
            require(
                nextStatus == MigrationStatus.InProgress ||
                nextStatus == MigrationStatus.Cancelled,
                "Invalid transition"
            );
        } else if (oldStatus == MigrationStatus.InProgress) {
            require(
                nextStatus == MigrationStatus.Completed ||
                nextStatus == MigrationStatus.Cancelled,
                "Invalid transition"
            );
        } else {
            revert("Migration is final");
        }

        currentMigration.status = nextStatus;
        currentMigration.updatedAt = block.timestamp;

        emit MigrationStatusChanged(
            migrationId,
            nextStatus
        );
    }

    function getMigration(
        uint256 migrationId
    )
        external
        view
        returns (
            address maintainer,
            address oldAddress,
            address newAddress,
            bytes32 planHash,
            string memory title,
            string memory notes,
            uint256 createdAt,
            uint256 updatedAt,
            MigrationStatus status
        )
    {
        require(
            migrationId < migrationCount,
            "Invalid migration"
        );

        Migration memory currentMigration = migrations[migrationId];

        return (
            currentMigration.maintainer,
            currentMigration.oldAddress,
            currentMigration.newAddress,
            currentMigration.planHash,
            currentMigration.title,
            currentMigration.notes,
            currentMigration.createdAt,
            currentMigration.updatedAt,
            currentMigration.status
        );
    }
}
