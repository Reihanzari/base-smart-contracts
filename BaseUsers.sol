// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseUsers {
    mapping(address => bool) public registered;
    
    uint256 public totalUsers;

    function register() external {
        require(!registered[msg.sender], "Already registered");

        registered[msg.sender] = true;
        totalUsers++;
    }

    function isRegistered(address user) external view returns (bool) {
        return registered[user];
    }
}
