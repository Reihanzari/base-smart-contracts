// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseCounterSet {

    mapping(address => mapping(uint256 => uint256)) public counters;

    event CounterIncreased(
        address indexed user,
        uint256 indexed counterId,
        uint256 amount,
        uint256 newValue
    );

    event CounterDecreased(
        address indexed user,
        uint256 indexed counterId,
        uint256 amount,
        uint256 newValue
    );

    function increase(
        uint256 counterId,
        uint256 amount
    ) external {
        require(amount > 0, "Amount must be greater than zero");

        counters[msg.sender][counterId] += amount;

        emit CounterIncreased(
            msg.sender,
            counterId,
            amount,
            counters[msg.sender][counterId]
        );
    }

    function decrease(
        uint256 counterId,
        uint256 amount
    ) external {
        require(amount > 0, "Amount must be greater than zero");

        require(
            counters[msg.sender][counterId] >= amount,
            "Insufficient counter"
        );

        counters[msg.sender][counterId] -= amount;

        emit CounterDecreased(
            msg.sender,
            counterId,
            amount,
            counters[msg.sender][counterId]
        );
    }

    function getCounter(
        address user,
        uint256 counterId
    ) external view returns (uint256) {
        return counters[user][counterId];
    }

    function getMyCounter(
        uint256 counterId
    ) external view returns (uint256) {
        return counters[msg.sender][counterId];
    }
}
