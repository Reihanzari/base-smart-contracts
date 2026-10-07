// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseServiceRecord {

    enum State {
        Created,
        Active,
        Paused,
        Completed,
        Cancelled
    }

    struct Service {
        uint256 id;
        address owner;
        string name;
        uint256 createdAt;
        uint256 updatedAt;
        State state;
    }

    mapping(address => Service[]) public services;

    event ServiceCreated(
        address indexed owner,
        uint256 indexed serviceId,
        string name
    );

    event StateChanged(
        address indexed owner,
        uint256 indexed serviceId,
        State newState
    );

    function createService(
        string calldata name
    ) external {
        require(
            bytes(name).length > 0,
            "Empty name"
        );

        uint256 id = services[msg.sender].length;

        services[msg.sender].push(
            Service({
                id: id,
                owner: msg.sender,
                name: name,
                createdAt: block.timestamp,
                updatedAt: block.timestamp,
                state: State.Created
            })
        );

        emit ServiceCreated(
            msg.sender,
            id,
            name
        );
    }

    function setActive(
        uint256 serviceId
    ) external {
        _changeState(serviceId, State.Active);
    }

    function pauseService(
        uint256 serviceId
    ) external {
        _changeState(serviceId, State.Paused);
    }

    function completeService(
        uint256 serviceId
    ) external {
        _changeState(serviceId, State.Completed);
    }

    function cancelService(
        uint256 serviceId
    ) external {
        _changeState(serviceId, State.Cancelled);
    }

    function _changeState(
        uint256 serviceId,
        State newState
    ) internal {
        require(
            serviceId < services[msg.sender].length,
            "Invalid service"
        );

        Service storage service =
            services[msg.sender][serviceId];

        require(
            service.state != State.Completed,
            "Already completed"
        );

        require(
            service.state != State.Cancelled,
            "Already cancelled"
        );

        service.state = newState;
        service.updatedAt = block.timestamp;

        emit StateChanged(
            msg.sender,
            serviceId,
            newState
        );
    }

    function getServiceCount(
        address owner
    ) external view returns (uint256) {
        return services[owner].length;
    }

    function getService(
        address owner,
        uint256 serviceId
    )
        external
        view
        returns (
            uint256 id,
            string memory name,
            uint256 createdAt,
            uint256 updatedAt,
            State state
        )
    {
        require(
            serviceId < services[owner].length,
            "Invalid service"
        );

        Service memory service =
            services[owner][serviceId];

        return (
            service.id,
            service.name,
            service.createdAt,
            service.updatedAt,
            service.state
        );
    }
}
