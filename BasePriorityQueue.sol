// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BasePriorityQueue {

    struct Request {
        uint256 id;
        address creator;
        string description;
        uint8 priority;
        uint256 createdAt;
        bool completed;
    }

    Request[] public requests;

    event RequestCreated(
        uint256 indexed requestId,
        address indexed creator,
        uint8 priority,
        string description
    );

    event RequestCompleted(
        uint256 indexed requestId,
        address indexed creator
    );

    function createRequest(
        string calldata description,
        uint8 priority
    ) external {
        require(
            bytes(description).length > 0,
            "Empty description"
        );

        require(
            priority >= 1 && priority <= 5,
            "Priority must be 1-5"
        );

        uint256 requestId = requests.length;

        requests.push(
            Request({
                id: requestId,
                creator: msg.sender,
                description: description,
                priority: priority,
                createdAt: block.timestamp,
                completed: false
            })
        );

        emit RequestCreated(
            requestId,
            msg.sender,
            priority,
            description
        );
    }

    function completeRequest(
        uint256 requestId
    ) external {
        require(
            requestId < requests.length,
            "Invalid request"
        );

        Request storage request = requests[requestId];

        require(
            request.creator == msg.sender,
            "Not request creator"
        );

        require(
            !request.completed,
            "Already completed"
        );

        request.completed = true;

        emit RequestCompleted(
            requestId,
            msg.sender
        );
    }

    function highestOpenPriority()
        external
        view
        returns (
            uint256 requestId,
            uint8 priority
        )
    {
        bool found = false;
        uint256 bestId = 0;
        uint8 bestPriority = 0;

        for (uint256 i = 0; i < requests.length; i++) {
            if (!requests[i].completed) {
                if (!found || requests[i].priority > bestPriority) {
                    found = true;
                    bestId = requests[i].id;
                    bestPriority = requests[i].priority;
                }
            }
        }

        require(found, "No open requests");

        return (bestId, bestPriority);
    }

    function getRequest(
        uint256 requestId
    )
        external
        view
        returns (
            uint256 id,
            address creator,
            string memory description,
            uint8 priority,
            uint256 createdAt,
            bool completed
        )
    {
        require(
            requestId < requests.length,
            "Invalid request"
        );

        Request memory request = requests[requestId];

        return (
            request.id,
            request.creator,
            request.description,
            request.priority,
            request.createdAt,
            request.completed
        );
    }

    function totalRequests()
        external
        view
        returns (uint256)
    {
        return requests.length;
    }
}
