// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseTimeTracker {

    struct Session {
        uint256 projectId;
        uint256 startedAt;
        uint256 endedAt;
        uint256 duration;
    }

    mapping(address => Session[]) private sessions;

    mapping(address => bool) public sessionActive;

    mapping(address => uint256) private activeSessionIndex;

    mapping(address => mapping(uint256 => uint256))
        public totalTimeByProject;

    event SessionStarted(
        address indexed user,
        uint256 indexed sessionId,
        uint256 indexed projectId,
        uint256 timestamp
    );

    event SessionStopped(
        address indexed user,
        uint256 indexed sessionId,
        uint256 indexed projectId,
        uint256 duration,
        uint256 timestamp
    );

    function startSession(uint256 projectId) external {
        require(!sessionActive[msg.sender], "Session already active");

        uint256 sessionId = sessions[msg.sender].length;

        sessions[msg.sender].push(
            Session({
                projectId: projectId,
                startedAt: block.timestamp,
                endedAt: 0,
                duration: 0
            })
        );

        activeSessionIndex[msg.sender] = sessionId;
        sessionActive[msg.sender] = true;

        emit SessionStarted(
            msg.sender,
            sessionId,
            projectId,
            block.timestamp
        );
    }

    function stopSession() external {
        require(sessionActive[msg.sender], "No active session");

        uint256 sessionId = activeSessionIndex[msg.sender];

        Session storage current = sessions[msg.sender][sessionId];

        uint256 duration = block.timestamp - current.startedAt;

        current.endedAt = block.timestamp;
        current.duration = duration;

        totalTimeByProject[msg.sender][current.projectId] += duration;

        sessionActive[msg.sender] = false;
        delete activeSessionIndex[msg.sender];

        emit SessionStopped(
            msg.sender,
            sessionId,
            current.projectId,
            duration,
            block.timestamp
        );
    }

    function getSessionCount(
        address user
    ) external view returns (uint256) {
        return sessions[user].length;
    }

    function getSession(
        address user,
        uint256 sessionId
    )
        external
        view
        returns (
            uint256 projectId,
            uint256 startedAt,
            uint256 endedAt,
            uint256 duration,
            bool isActive
        )
    {
        require(
            sessionId < sessions[user].length,
            "Invalid session"
        );

        Session memory current = sessions[user][sessionId];

        bool active =
            sessionActive[user] &&
            activeSessionIndex[user] == sessionId;

        return (
            current.projectId,
            current.startedAt,
            current.endedAt,
            current.duration,
            active
        );
    }

    function getActiveSession(
        address user
    )
        external
        view
        returns (
            bool active,
            uint256 projectId,
            uint256 startedAt
        )
    {
        if (!sessionActive[user]) {
            return (false, 0, 0);
        }

        Session memory current =
            sessions[user][activeSessionIndex[user]];

        return (
            true,
            current.projectId,
            current.startedAt
        );
    }
}
