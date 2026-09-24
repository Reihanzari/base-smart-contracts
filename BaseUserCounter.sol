// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseUserCounter {

    mapping(address => uint256) public counts;

    uint256 public totalInteractions;

    event Interaction(
        address indexed user,
        uint256 count
    );

    function interact() external {
        counts[msg.sender]++;
        totalInteractions++;

        emit Interaction(
            msg.sender,
            counts[msg.sender]
        );
    }

    function getMyCount()
        external
        view
        returns (uint256)
    {
        return counts[msg.sender];
    }

    function getUserCount(address user)
        external
        view
        returns (uint256)
    {
        return counts[user];
    }
}
