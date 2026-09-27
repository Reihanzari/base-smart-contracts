// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBadge {

    mapping(address => mapping(uint256 => bool)) public hasBadge;
    mapping(address => uint256) public badgeCount;

    event BadgeGranted(
        address indexed user,
        uint256 indexed badgeId
    );

    function grantBadge(
        address user,
        uint256 badgeId
    ) external {
        require(user != address(0), "Invalid user");
        require(!hasBadge[user][badgeId], "Badge already exists");

        hasBadge[user][badgeId] = true;
        badgeCount[user]++;

        emit BadgeGranted(user, badgeId);
    }

    function checkBadge(
        address user,
        uint256 badgeId
    ) external view returns (bool) {
        return hasBadge[user][badgeId];
    }

    function getBadgeCount(address user)
        external
        view
        returns (uint256)
    {
        return badgeCount[user];
    }
}
