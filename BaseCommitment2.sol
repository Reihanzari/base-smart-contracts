// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCommitment {
    mapping(address => bytes32) public commitments;
    mapping(address => bool) public revealed;

    function commit(bytes32 hash) external {
        require(commitments[msg.sender] == bytes32(0), "Already committed");

        commitments[msg.sender] = hash;
    }

    function reveal(string calldata secret) external {
        require(commitments[msg.sender] != bytes32(0), "No commitment");
        require(
            commitments[msg.sender] == keccak256(abi.encodePacked(secret)),
            "Invalid secret"
        );

        revealed[msg.sender] = true;
    }

    function getCommitment(address user) external view returns (bytes32) {
        return commitments[user];
    }
}
