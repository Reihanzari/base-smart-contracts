// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseArrayQueue {
    string[] private items;

    uint256 public head;

    function add(string calldata item) external {
        items.push(item);
    }

    function next()
        external
        view
        returns (string memory)
    {
        require(head < items.length, "Queue is empty");
        return items[head];
    }

    function remove()
        external
        returns (string memory)
    {
        require(head < items.length, "Queue is empty");

        string memory item = items[head];
        head++;

        return item;
    }

    function remaining()
        external
        view
        returns (uint256)
    {
        return items.length - head;
    }
}
