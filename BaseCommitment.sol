// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCommitment {
    struct Commitment {
        bytes32 hash;
        uint256 createdAt;
        bool revealed;
    }

    mapping(address => Commitment) public commitments;

    function commit(bytes32 hashValue) external {
        commitments[msg.sender] = Commitment(
            hashValue,
            block.timestamp,
            false
        );
    }

    function reveal(bytes32 originalValue) external {
        require(
            commitments[msg.sender].hash == keccak256(abi.encodePacked(originalValue)),
            "Invalid reveal"
        );

        commitments[msg.sender].revealed = true;
    }

    function getCommitment(address user)
        external
        view
        returns (bytes32 hashValue, uint256 createdAt, bool revealed)
    {
        Commitment memory c = commitments[user];
        return (c.hash, c.createdAt, c.revealed);
    }
}
