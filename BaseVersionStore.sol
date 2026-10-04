// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseVersionStore {

    struct Version {
        string value;
        uint256 version;
        uint256 timestamp;
    }

    mapping(address => mapping(bytes32 => Version[])) public records;

    event VersionAdded(
        address indexed user,
        bytes32 indexed key,
        uint256 version,
        string value,
        uint256 timestamp
    );

    function setValue(
        bytes32 key,
        string calldata value
    ) external {
        require(
            key != bytes32(0),
            "Invalid key"
        );

        require(
            bytes(value).length > 0,
            "Empty value"
        );

        uint256 newVersion =
            records[msg.sender][key].length + 1;

        records[msg.sender][key].push(
            Version({
                value: value,
                version: newVersion,
                timestamp: block.timestamp
            })
        );

        emit VersionAdded(
            msg.sender,
            key,
            newVersion,
            value,
            block.timestamp
        );
    }

    function getLatest(
        address user,
        bytes32 key
    )
        external
        view
        returns (
            string memory value,
            uint256 version,
            uint256 timestamp
        )
    {
        require(
            records[user][key].length > 0,
            "No record"
        );

        Version memory latest =
            records[user][key][records[user][key].length - 1];

        return (
            latest.value,
            latest.version,
            latest.timestamp
        );
    }

    function getVersion(
        address user,
        bytes32 key,
        uint256 versionNumber
    )
        external
        view
        returns (
            string memory value,
            uint256 timestamp
        )
    {
        require(
            versionNumber > 0 &&
            versionNumber <= records[user][key].length,
            "Invalid version"
        );

        Version memory v =
            records[user][key][versionNumber - 1];

        return (
            v.value,
            v.timestamp
        );
    }

    function getVersionCount(
        address user,
        bytes32 key
    ) external view returns (uint256) {
        return records[user][key].length;
    }
}
