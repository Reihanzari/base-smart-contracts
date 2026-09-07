// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseMilestone {
    struct Milestone {
        string title;
        bool completed;
    }

    mapping(address => Milestone[]) public milestones;

    uint256 public totalMilestones;
    uint256 public completedMilestones;

    function addMilestone(string calldata title) external {
        require(bytes(title).length > 0, "Empty title");

        milestones[msg.sender].push(
            Milestone({
                title: title,
                completed: false
            })
        );

        totalMilestones++;
    }

    function completeMilestone(uint256 index) external {
        require(index < milestones[msg.sender].length, "Invalid index");
        require(!milestones[msg.sender][index].completed, "Already completed");

        milestones[msg.sender][index].completed = true;
        completedMilestones++;
    }

    function milestoneCount(address user)
        external
        view
        returns (uint256)
    {
        return milestones[user].length;
    }
}
