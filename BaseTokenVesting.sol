// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IERC20Vesting {
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function transfer(
        address to,
        uint256 amount
    ) external returns (bool);
}

contract BaseTokenVesting {
    struct Schedule {
        address token;
        address beneficiary;
        uint256 totalAmount;
        uint256 released;
        uint256 start;
        uint256 cliff;
        uint256 duration;
    }

    uint256 public scheduleCount;

    mapping(uint256 => Schedule) public schedules;

    function createSchedule(
        address token,
        address beneficiary,
        uint256 amount,
        uint256 start,
        uint256 cliff,
        uint256 duration
    ) external {
        require(token != address(0), "Invalid token");
        require(beneficiary != address(0), "Invalid beneficiary");
        require(amount > 0, "Invalid amount");
        require(duration > 0, "Invalid duration");
        require(cliff >= start, "Invalid cliff");
        require(cliff <= start + duration, "Cliff too long");

        require(
            IERC20Vesting(token).transferFrom(
                msg.sender,
                address(this),
                amount
            ),
            "Transfer failed"
        );

        schedules[scheduleCount] = Schedule({
            token: token,
            beneficiary: beneficiary,
            totalAmount: amount,
            released: 0,
            start: start,
            cliff: cliff,
            duration: duration
        });

        scheduleCount++;
    }

    function vestedAmount(
        uint256 id
    ) public view returns (uint256) {
        Schedule memory s = schedules[id];

        if (block.timestamp < s.cliff) {
            return 0;
        }

        if (block.timestamp >= s.start + s.duration) {
            return s.totalAmount;
        }

        return
            (s.totalAmount * (block.timestamp - s.start))
            / s.duration;
    }

    function releasableAmount(
        uint256 id
    ) external view returns (uint256) {
        uint256 vested = vestedAmount(id);
        Schedule memory s = schedules[id];

        return vested - s.released;
    }

    function release(uint256 id) external {
        Schedule storage s = schedules[id];

        require(
            msg.sender == s.beneficiary,
            "Not beneficiary"
        );

        uint256 vested = vestedAmount(id);
        uint256 amount = vested - s.released;

        require(amount > 0, "Nothing to release");

        s.released += amount;

        require(
            IERC20Vesting(s.token).transfer(
                s.beneficiary,
                amount
            ),
            "Transfer failed"
        );
    }
}
