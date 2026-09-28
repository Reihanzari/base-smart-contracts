// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseFavorite {

    mapping(address => mapping(uint256 => bool)) public favorite;

    mapping(uint256 => uint256) public favoriteCount;

    event FavoriteAdded(
        address indexed user,
        uint256 indexed itemId
    );

    event FavoriteRemoved(
        address indexed user,
        uint256 indexed itemId
    );

    function addFavorite(uint256 itemId) external {
        require(
            !favorite[msg.sender][itemId],
            "Already favorite"
        );

        favorite[msg.sender][itemId] = true;
        favoriteCount[itemId]++;

        emit FavoriteAdded(
            msg.sender,
            itemId
        );
    }

    function removeFavorite(uint256 itemId) external {
        require(
            favorite[msg.sender][itemId],
            "Not favorite"
        );

        favorite[msg.sender][itemId] = false;
        favoriteCount[itemId]--;

        emit FavoriteRemoved(
            msg.sender,
            itemId
        );
    }

    function isFavorite(
        address user,
        uint256 itemId
    ) external view returns (bool) {
        return favorite[user][itemId];
    }

    function getFavoriteCount(
        uint256 itemId
    ) external view returns (uint256) {
        return favoriteCount[itemId];
    }
}
