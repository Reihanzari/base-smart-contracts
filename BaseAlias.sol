// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAlias {

    mapping(address => mapping(bytes32 => bool)) public hasAlias;
    mapping(bytes32 => address) public aliasOwner;

    mapping(address => uint256) public aliasCount;

    event AliasAdded(
        address indexed user,
        string aliasName
    );

    event AliasRemoved(
        address indexed user,
        string aliasName
    );

    function addAlias(
        string calldata aliasName
    ) external {
        require(bytes(aliasName).length > 0, "Empty alias");

        bytes32 aliasHash = keccak256(bytes(aliasName));

        require(
            aliasOwner[aliasHash] == address(0),
            "Alias already taken"
        );

        aliasOwner[aliasHash] = msg.sender;
        hasAlias[msg.sender][aliasHash] = true;
        aliasCount[msg.sender]++;

        emit AliasAdded(
            msg.sender,
            aliasName
        );
    }

    function removeAlias(
        string calldata aliasName
    ) external {
        bytes32 aliasHash = keccak256(bytes(aliasName));

        require(
            hasAlias[msg.sender][aliasHash],
            "Alias not owned"
        );

        delete hasAlias[msg.sender][aliasHash];
        delete aliasOwner[aliasHash];

        aliasCount[msg.sender]--;

        emit AliasRemoved(
            msg.sender,
            aliasName
        );
    }

    function getAliasOwner(
        string calldata aliasName
    ) external view returns (address) {
        return aliasOwner[keccak256(bytes(aliasName))];
    }

    function ownsAlias(
        address user,
        string calldata aliasName
    ) external view returns (bool) {
        return hasAlias[user][keccak256(bytes(aliasName))];
    }
}
