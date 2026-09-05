// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMessageBoard {
    struct Message {
        string text;
        uint256 time;
    }

    mapping(address => Message) public messages;

    uint256 public totalMessages;

    function postMessage(string calldata text) external {
        require(bytes(text).length > 0, "Empty message");
        require(bytes(text).length <= 280, "Message too long");

        messages[msg.sender] = Message({
            text: text,
            time: block.timestamp
        });

        totalMessages++;
    }

    function getMessage(address user)
        external
        view
        returns (string memory, uint256)
    {
        return (messages[user].text, messages[user].time);
    }
}
