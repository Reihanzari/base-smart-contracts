// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseArrayAnalyzer {
    function sum(
        uint256[] calldata values
    ) external pure returns (uint256 total) {
        for (uint256 i = 0; i < values.length; i++) {
            total += values[i];
        }
    }

    function average(
        uint256[] calldata values
    ) external pure returns (uint256) {
        require(values.length > 0, "Empty array");

        uint256 total = 0;

        for (uint256 i = 0; i < values.length; i++) {
            total += values[i];
        }

        return total / values.length;
    }

    function minimum(
        uint256[] calldata values
    ) external pure returns (uint256) {
        require(values.length > 0, "Empty array");

        uint256 result = values[0];

        for (uint256 i = 1; i < values.length; i++) {
            if (values[i] < result) {
                result = values[i];
            }
        }

        return result;
    }

    function maximum(
        uint256[] calldata values
    ) external pure returns (uint256) {
        require(values.length > 0, "Empty array");

        uint256 result = values[0];

        for (uint256 i = 1; i < values.length; i++) {
            if (values[i] > result) {
                result = values[i];
            }
        }

        return result;
    }
}
