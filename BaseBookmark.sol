// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseBookmark {
    mapping(address => mapping(uint256 => bool)) public bookmarked;

    mapping(address => uint256) public bookmarkCount;

    function addBookmark(uint256 itemId) external {
        require(!bookmarked[msg.sender][itemId], "Already bookmarked");

        bookmarked[msg.sender][itemId] = true;
        bookmarkCount[msg.sender]++;
    }

    function removeBookmark(uint256 itemId) external {
        require(bookmarked[msg.sender][itemId], "Not bookmarked");

        bookmarked[msg.sender][itemId] = false;
        bookmarkCount[msg.sender]--;
    }

    function hasBookmark(address user, uint256 itemId)
        external
        view
        returns (bool)
    {
        return bookmarked[user][itemId];
    }
}
