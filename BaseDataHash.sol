// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseDataHash {
    function hashText(
        string calldata text
    ) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text));
    }

    function hashBytes(
        bytes calldata data
    ) external pure returns (bytes32) {
        return keccak256(data);
    }

    function sameText(
        string calldata first,
        string calldata second
    ) external pure returns (bool) {
        return keccak256(abi.encodePacked(first))
            == keccak256(abi.encodePacked(second));
    }
}
