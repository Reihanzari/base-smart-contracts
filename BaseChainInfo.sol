// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseChainInfo {
    function getChainId() external view returns (uint256) {
        return block.chainid;
    }

    function getBlockNumber() external view returns (uint256) {
        return block.number;
    }

    function getTimestamp() external view returns (uint256) {
        return block.timestamp;
    }

    function getBaseFee() external view returns (uint256) {
        return block.basefee;
    }

    function getPrevRandao() external view returns (uint256) {
        return block.prevrandao;
    }
}
