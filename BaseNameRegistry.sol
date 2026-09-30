// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseNameRegistry {

    mapping(address => string) public names;
    mapping(bytes32 => address) public nameOwners;

    event NameRegistered(
        address indexed user,
        string name
    );

    function registerName(string calldata name) external {
        require(bytes(name).length > 0, "Empty name");
        require(bytes(names[msg.sender]).length == 0, "Name already set");

        bytes32 nameHash = keccak256(bytes(name));

        require(
            nameOwners[nameHash] == address(0),
            "Name already taken"
        );

        names[msg.sender] = name;
        nameOwners[nameHash] = msg.sender;

        emit NameRegistered(msg.sender, name);
    }

    function getName(address user)
        external
        view
        returns (string memory)
    {
        return names[user];
    }

    function ownerOfName(string calldata name)
        external
        view
        returns (address)
    {
        return nameOwners[keccak256(bytes(name))];
    }
}
