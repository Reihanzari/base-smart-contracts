// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseRoyaltySplitRegistry {

    uint256 public constant TOTAL_BPS = 10000;
    uint256 public constant MAX_RECIPIENTS = 20;

    mapping(address => mapping(uint256 => address[]))
        private recipients;

    mapping(address => mapping(uint256 => uint16[]))
        private sharesBps;

    mapping(address => mapping(uint256 => bool))
        public splitExists;

    event RoyaltySplitCreated(
        address indexed creator,
        uint256 indexed projectId,
        uint256 recipientCount
    );

    function createRoyaltySplit(
        uint256 projectId,
        address[] calldata recipientList,
        uint16[] calldata shareList
    ) external {
        require(
            !splitExists[msg.sender][projectId],
            "Split already exists"
        );

        require(
            recipientList.length > 0 &&
            recipientList.length <= MAX_RECIPIENTS,
            "Invalid recipient count"
        );

        require(
            recipientList.length == shareList.length,
            "Length mismatch"
        );

        uint256 totalBps = 0;

        for (uint256 i = 0; i < recipientList.length; i++) {
            require(
                recipientList[i] != address(0),
                "Invalid recipient"
            );

            require(
                shareList[i] > 0,
                "Share must be positive"
            );

            totalBps += shareList[i];

            for (uint256 j = 0; j < i; j++) {
                require(
                    recipientList[i] != recipientList[j],
                    "Duplicate recipient"
                );
            }
        }

        require(totalBps == TOTAL_BPS, "Shares must total 100 percent");

        for (uint256 i = 0; i < recipientList.length; i++) {
            recipients[msg.sender][projectId].push(
                recipientList[i]
            );

            sharesBps[msg.sender][projectId].push(
                shareList[i]
            );
        }

        splitExists[msg.sender][projectId] = true;

        emit RoyaltySplitCreated(
            msg.sender,
            projectId,
            recipientList.length
        );
    }

    function getSplit(
        address creator,
        uint256 projectId
    )
        external
        view
        returns (
            address[] memory recipientList,
            uint16[] memory shareList
        )
    {
        require(
            splitExists[creator][projectId],
            "Split not found"
        );

        return (
            recipients[creator][projectId],
            sharesBps[creator][projectId]
        );
    }

    function getRecipientCount(
        address creator,
        uint256 projectId
    ) external view returns (uint256) {
        return recipients[creator][projectId].length;
    }

    function getRecipientShare(
        address creator,
        uint256 projectId,
        uint256 index
    )
        external
        view
        returns (address recipient, uint16 shareBps)
    {
        require(
            splitExists[creator][projectId],
            "Split not found"
        );

        require(
            index < recipients[creator][projectId].length,
            "Invalid index"
        );

        return (
            recipients[creator][projectId][index],
            sharesBps[creator][projectId][index]
        );
    }
}
