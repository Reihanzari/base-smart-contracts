// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract BaseAddressInspector {
    function isContract(address account)
        external
        view
        returns (bool)
    {
        return account.code.length > 0;
    }

    function codeSize(address account)
        external
        view
        returns (uint256)
    {
        return account.code.length;
    }

    function codeHash(address account)
        external
        view
        returns (bytes32)
    {
        return account.codehash;
    }
}
