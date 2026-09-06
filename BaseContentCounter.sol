// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseContentCounter {
    mapping(address => uint256) public contentCreated;

    uint256 public totalContent;

    function createContent() external {
        contentCreated[msg.sender]++;
        totalContent++;
    }

    function myContent() external view returns (uint256) {
        return contentCreated[msg.sender];
    }

    function getUserContent(address user)
        external
        view
        returns (uint256)
    {
        return contentCreated[user];
    }
}
