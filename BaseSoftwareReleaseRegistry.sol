// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseSoftwareReleaseRegistry {

    struct Project {
        string name;
        bytes32 repositoryHash;
        uint256 latestVersion;
        bool exists;
    }

    struct Release {
        bytes32 artifactHash;
        bytes32 manifestHash;
        bytes32 releaseNotesHash;
        uint256 publishedAt;
        bool exists;
    }

    mapping(address => mapping(bytes32 => Project))
        private projects;

    mapping(address => mapping(bytes32 => mapping(uint256 => Release)))
        private releases;

    event ProjectRegistered(
        address indexed publisher,
        bytes32 indexed projectId,
        string name,
        bytes32 repositoryHash
    );

    event ReleasePublished(
        address indexed publisher,
        bytes32 indexed projectId,
        uint256 version,
        bytes32 artifactHash,
        bytes32 manifestHash
    );

    function registerProject(
        bytes32 projectId,
        string calldata name,
        bytes32 repositoryHash
    ) external {
        require(projectId != bytes32(0), "Invalid project ID");
        require(bytes(name).length > 0, "Empty name");
        require(repositoryHash != bytes32(0), "Invalid repository hash");

        require(
            !projects[msg.sender][projectId].exists,
            "Project already exists"
        );

        projects[msg.sender][projectId] = Project({
            name: name,
            repositoryHash: repositoryHash,
            latestVersion: 0,
            exists: true
        });

        emit ProjectRegistered(
            msg.sender,
            projectId,
            name,
            repositoryHash
        );
    }

    function publishRelease(
        bytes32 projectId,
        uint256 version,
        bytes32 artifactHash,
        bytes32 manifestHash,
        bytes32 releaseNotesHash
    ) external {
        Project storage project = projects[msg.sender][projectId];

        require(project.exists, "Project not found");
        require(version > project.latestVersion, "Version must increase");
        require(artifactHash != bytes32(0), "Invalid artifact hash");
        require(manifestHash != bytes32(0), "Invalid manifest hash");

        releases[msg.sender][projectId][version] = Release({
            artifactHash: artifactHash,
            manifestHash: manifestHash,
            releaseNotesHash: releaseNotesHash,
            publishedAt: block.timestamp,
            exists: true
        });

        project.latestVersion = version;

        emit ReleasePublished(
            msg.sender,
            projectId,
            version,
            artifactHash,
            manifestHash
        );
    }

    function getProject(
        address publisher,
        bytes32 projectId
    )
        external
        view
        returns (
            string memory name,
            bytes32 repositoryHash,
            uint256 latestVersion,
            bool exists
        )
    {
        Project memory project = projects[publisher][projectId];

        return (
            project.name,
            project.repositoryHash,
            project.latestVersion,
            project.exists
        );
    }

    function getRelease(
        address publisher,
        bytes32 projectId,
        uint256 version
    )
        external
        view
        returns (
            bytes32 artifactHash,
            bytes32 manifestHash,
            bytes32 releaseNotesHash,
            uint256 publishedAt,
            bool exists
        )
    {
        Release memory r = releases[publisher][projectId][version];

        return (
            r.artifactHash,
            r.manifestHash,
            r.releaseNotesHash,
            r.publishedAt,
            r.exists
        );
    }
}
