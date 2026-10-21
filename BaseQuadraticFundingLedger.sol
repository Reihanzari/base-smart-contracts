// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseQuadraticFundingLedger {

    uint256 public constant MAX_PROJECTS = 50;
    uint256 public constant MAX_CONTRIBUTORS_PER_PROJECT = 100;
    uint256 public constant MAX_ALLOCATION = 1e18;

    struct Round {
        address organizer;
        string title;
        uint256 deadline;
        bool active;
    }

    struct Project {
        address submitter;
        string title;
        uint256 totalAllocated;
    }

    mapping(uint256 => Round) private rounds;
    mapping(uint256 => Project[]) private projects;

    mapping(uint256 => mapping(uint256 => mapping(address => uint256)))
        public allocations;

    mapping(uint256 => mapping(uint256 => address[]))
        private contributors;

    mapping(uint256 => mapping(uint256 => mapping(address => bool)))
        private contributorAdded;

    uint256 public roundCount;

    event RoundCreated(
        uint256 indexed roundId,
        address indexed organizer,
        uint256 deadline
    );

    event ProjectAdded(
        uint256 indexed roundId,
        uint256 indexed projectId,
        address indexed submitter
    );

    event AllocationUpdated(
        uint256 indexed roundId,
        uint256 indexed projectId,
        address indexed contributor,
        uint256 amount
    );

    event RoundClosed(uint256 indexed roundId);

    function createRound(
        string calldata title,
        uint256 deadline
    ) external returns (uint256) {
        require(bytes(title).length > 0, "Empty title");
        require(deadline > block.timestamp, "Invalid deadline");

        uint256 id = roundCount;

        rounds[id] = Round({
            organizer: msg.sender,
            title: title,
            deadline: deadline,
            active: true
        });

        roundCount++;

        emit RoundCreated(id, msg.sender, deadline);

        return id;
    }

    function addProject(
        uint256 roundId,
        string calldata title
    ) external returns (uint256) {
        require(roundId < roundCount, "Invalid round");
        require(bytes(title).length > 0, "Empty title");

        Round storage round = rounds[roundId];

        require(round.active, "Round inactive");
        require(block.timestamp < round.deadline, "Round ended");
        require(round.organizer == msg.sender, "Not organizer");

        require(
            projects[roundId].length < MAX_PROJECTS,
            "Too many projects"
        );

        uint256 id = projects[roundId].length;

        projects[roundId].push(
            Project({
                submitter: msg.sender,
                title: title,
                totalAllocated: 0
            })
        );

        emit ProjectAdded(roundId, id, msg.sender);

        return id;
    }

    function allocate(
        uint256 roundId,
        uint256 projectId,
        uint256 amount
    ) external {
        require(roundId < roundCount, "Invalid round");
        require(projectId < projects[roundId].length, "Invalid project");

        Round storage round = rounds[roundId];

        require(round.active, "Round inactive");
        require(block.timestamp < round.deadline, "Round ended");
        require(amount > 0 && amount <= MAX_ALLOCATION, "Invalid amount");

        if (!contributorAdded[roundId][projectId][msg.sender]) {
            require(
                contributors[roundId][projectId].length <
                    MAX_CONTRIBUTORS_PER_PROJECT,
                "Too many contributors"
            );

            contributorAdded[roundId][projectId][msg.sender] = true;
            contributors[roundId][projectId].push(msg.sender);
        }

        uint256 previous = allocations[roundId][projectId][msg.sender];

        projects[roundId][projectId].totalAllocated -= previous;
        projects[roundId][projectId].totalAllocated += amount;

        allocations[roundId][projectId][msg.sender] = amount;

        emit AllocationUpdated(
            roundId,
            projectId,
            msg.sender,
            amount
        );
    }

    function closeRound(uint256 roundId) external {
        require(roundId < roundCount, "Invalid round");

        Round storage round = rounds[roundId];

        require(round.organizer == msg.sender, "Not organizer");
        require(round.active, "Already closed");
        require(block.timestamp >= round.deadline, "Round still active");

        round.active = false;

        emit RoundClosed(roundId);
    }

    function getProjectCount(
        uint256 roundId
    ) external view returns (uint256) {
        require(roundId < roundCount, "Invalid round");
        return projects[roundId].length;
    }

    function getProject(
        uint256 roundId,
        uint256 projectId
    )
        external
        view
        returns (
            address submitter,
            string memory title,
            uint256 totalAllocated
        )
    {
        require(roundId < roundCount, "Invalid round");
        require(projectId < projects[roundId].length, "Invalid project");

        Project memory project = projects[roundId][projectId];

        return (
            project.submitter,
            project.title,
            project.totalAllocated
        );
    }

    function getContributorCount(
        uint256 roundId,
        uint256 projectId
    ) external view returns (uint256) {
        require(roundId < roundCount, "Invalid round");
        require(projectId < projects[roundId].length, "Invalid project");

        return contributors[roundId][projectId].length;
    }

    function getMatchingIndex(
        uint256 roundId,
        uint256 projectId
    ) external view returns (uint256) {
        require(roundId < roundCount, "Invalid round");
        require(projectId < projects[roundId].length, "Invalid project");

        address[] storage list = contributors[roundId][projectId];
        uint256 sumRoots = 0;

        for (uint256 i = 0; i < list.length; i++) {
            uint256 amount = allocations[roundId][projectId][list[i]];
            sumRoots += _sqrt(amount);
        }

        return sumRoots * sumRoots;
    }

    function _sqrt(uint256 x) private pure returns (uint256) {
        if (x == 0) return 0;

        uint256 z = (x + 1) / 2;
        uint256 y = x;

        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }

        return y;
    }
}
