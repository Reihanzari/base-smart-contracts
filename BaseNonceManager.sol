// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseNonceManager {
    mapping(address => uint256) public nonce;

    function useNonce(uint256 expected) external {
        require(nonce[msg.sender] == expected, "Invalid nonce");
        nonce[msg.sender]++;
    }

    function currentNonce(address user) external view returns (uint256) {
        return nonce[user];
    }

    function resetNonce(uint256 newNonce) external {
        require(newNonce >= nonce[msg.sender], "Cannot decrease");
        nonce[msg.sender] = newNonce;
    }
}
