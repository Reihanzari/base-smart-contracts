// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCommitment {

    struct Commitment {
        address creator;
        bytes32 dataHash;
        bool revealed;
        uint256 createdAt;
    }

    mapping(uint256 => Commitment) public commitments;

    uint256 public totalCommitments;

    event CommitmentCreated(
        uint256 indexed id,
        address indexed creator,
        bytes32 dataHash
    );

    event CommitmentRevealed(
        uint256 indexed id,
        address indexed creator
    );

    function createCommitment(bytes32 dataHash) external {
        require(
            dataHash != bytes32(0),
            "Invalid hash"
        );

        uint256 id = totalCommitments;

        commitments[id] = Commitment({
            creator: msg.sender,
            dataHash: dataHash,
            revealed: false,
            createdAt: block.timestamp
        });

        totalCommitments++;

        emit CommitmentCreated(
            id,
            msg.sender,
            dataHash
        );
    }

    function revealCommitment(
        uint256 id,
        string calldata data,
        string calldata salt
    ) external {
        Commitment storage c = commitments[id];

        require(
            c.creator == msg.sender,
            "Not creator"
        );

        require(
            !c.revealed,
            "Already revealed"
        );

        bytes32 calculatedHash =
            keccak256(
                abi.encodePacked(data, salt)
            );

        require(
            calculatedHash == c.dataHash,
            "Hash mismatch"
        );

        c.revealed = true;

        emit CommitmentRevealed(
            id,
            msg.sender
        );
    }

    function verifyCommitment(
        uint256 id,
        string calldata data,
        string calldata salt
    ) external view returns (bool) {
        return
            keccak256(
                abi.encodePacked(data, salt)
            ) == commitments[id].dataHash;
    }
}
