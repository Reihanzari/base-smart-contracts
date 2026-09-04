// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseGuestCounter {
    mapping(address => uint256) public visits;

    uint256 public totalVisits;
    uint256 public uniqueVisitors;

    mapping(address => bool) private knownVisitor;

    function visit() external {
        visits[msg.sender]++;
        totalVisits++;

        if (!knownVisitor[msg.sender]) {
            knownVisitor[msg.sender] = true;
            uniqueVisitors++;
        }
    }

    function myVisits() external view returns (uint256) {
        return visits[msg.sender];
    }
}
