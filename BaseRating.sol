// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseRating {
    struct Rating {
        uint256 totalScore;
        uint256 totalVotes;
    }

    mapping(uint256 => Rating) public ratings;

    function rate(uint256 itemId, uint8 score) external {
        require(score >= 1 && score <= 5, "Score must be 1-5");

        ratings[itemId].totalScore += score;
        ratings[itemId].totalVotes++;
    }

    function averageScore(uint256 itemId)
        external
        view
        returns (uint256)
    {
        if (ratings[itemId].totalVotes == 0) {
            return 0;
        }

        return ratings[itemId].totalScore / ratings[itemId].totalVotes;
    }
}
