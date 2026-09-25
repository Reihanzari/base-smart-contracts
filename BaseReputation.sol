// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseReputation {

    address public owner;

    mapping(address => uint256) public reputation;

    uint256 public totalPoints;

    event PointsAdded(
        address indexed user,
        uint256 amount,
        uint256 newBalance
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function addPoints(
        address user,
        uint256 amount
    ) external onlyOwner {

        require(user != address(0), "Invalid user");
        require(amount > 0, "Invalid amount");

        reputation[user] += amount;
        totalPoints += amount;

        emit PointsAdded(
            user,
            amount,
            reputation[user]
        );
    }

    function getReputation(address user)
        external
        view
        returns (uint256)
    {
        return reputation[user];
    }
}
