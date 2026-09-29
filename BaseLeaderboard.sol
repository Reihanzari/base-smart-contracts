// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseLeaderboard {

    mapping(address => uint256) public scores;

    uint256 public totalPlayers;

    event ScoreAdded(
        address indexed player,
        uint256 amount,
        uint256 newScore
    );

    function addScore(uint256 amount) external {
        require(amount > 0, "Invalid amount");

        if (scores[msg.sender] == 0) {
            totalPlayers++;
        }

        scores[msg.sender] += amount;

        emit ScoreAdded(
            msg.sender,
            amount,
            scores[msg.sender]
        );
    }

    function getScore(
        address player
    ) external view returns (uint256) {
        return scores[player];
    }

    function getMyScore()
        external
        view
        returns (uint256)
    {
        return scores[msg.sender];
    }
}
