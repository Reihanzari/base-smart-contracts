// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMerkleVerifier {
    bytes32 public merkleRoot;

    function setRoot(bytes32 root) external {
        merkleRoot = root;
    }

    function verify(
        bytes32 leaf,
        bytes32[] calldata proof
    ) external view returns (bool) {
        bytes32 computed = leaf;

        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 sibling = proof[i];

            if (computed < sibling) {
                computed = keccak256(
                    abi.encodePacked(computed, sibling)
                );
            } else {
                computed = keccak256(
                    abi.encodePacked(sibling, computed)
                );
            }
        }

        return computed == merkleRoot;
    }
}
