// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseWarranty {
    struct Warranty {
        uint256 startDate;
        uint256 duration;
        bool active;
    }

    mapping(uint256 => Warranty) public warranties;

    function createWarranty(
        uint256 productId,
        uint256 startDate,
        uint256 duration
    ) external {
        warranties[productId] = Warranty(
            startDate,
            duration,
            true
        );
    }

    function cancelWarranty(uint256 productId) external {
        warranties[productId].active = false;
    }

    function isValid(uint256 productId)
        external
        view
        returns (bool)
    {
        Warranty memory warranty = warranties[productId];

        if (!warranty.active) {
            return false;
        }

        return block.timestamp <= warranty.startDate + warranty.duration;
    }
}
