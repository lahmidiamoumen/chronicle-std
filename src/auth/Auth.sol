// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

import {IAuth} from "./IAuth.sol";

/**
 * @title Auth Module
 *
 * @dev The `Auth` contract module provides a basic access control mechanism,
 *      where a set of addresses are granted access to protected functions.
 *      These addresses are said to be _auth'ed_.
 *
 *      Initially, the deployer address is the only address auth'ed. Through
 *      the `rely(address)` and `deny(address)` functions, auth'ed callers are
 *      able to grant/renounce auth to/from addresses.
 *
 *      This module is used throuhg inheritance. It will make available the
 *      modifier `auth`, which can be applied to functions to restrict their
 *      use to only auth'ed callers.
 */
abstract contract Auth is IAuth {
    /// @dev Mapping storing whether address is auth'ed.
    /// @custom:invariant Image of mapping is {0, 1}.
    ///                     ∀x ∊ Address: _wards[x] ∊ {0, 1}
    /// @custom:invariant Only deployer address authenticated after deployment.
    ///                     deployment → (∀x ∊ Address: _wards[x] == 1 → x == msg.sender)
    /// @custom:invariant Only functions `rely` and `deny` may mutate the mapping's state.
    ///                     ∀x ∊ Address: preTx(_wards[x]) != postTx(_wards[x])
    ///                                     → (msg.sig == "rely" ∨ msg.sig == "deny")
    /// @custom:invariant Mapping's state may only be mutated by authenticated caller.
    ///                     ∀x ∊ Address: preTx(_wards[x]) != postTx(_wards[x]) → _wards[msg.sender] = 1
    mapping(address => uint) private _wards;

    /// @dev List of addresses possibly being a ward.
    /// @dev May contain duplicates.
    /// @dev May contain addresses not being ward anymore.
    /// @custom:invariant Every address being a ward once is element of the list.
    ///                     ∀x ∊ Address: _wards[x] -> x ∊ _wardsTouched
    address[] private _wardsTouched;

    /// @dev Ensures caller is auth'ed.
    modifier auth() {
        if (_wards[msg.sender] == 0) revert NotAuthorized();
        _;
    }

    constructor() {
        _wards[msg.sender] = 1;
        _wardsTouched.push(msg.sender);

        // NOTE: Using address(0) as caller to keep invariant that no address
        //       can grant itself auth.
        emit AuthGranted(address(0), msg.sender);
    }

    /// @inheritdoc IAuth
    function rely(address who) external override(IAuth) auth {
        if (_wards[who] == 1) return;

        _wards[who] = 1;
        _wardsTouched.push(who);
        emit AuthGranted(msg.sender, who);
    }

    /// @inheritdoc IAuth
    function deny(address who) external override(IAuth) auth {
        if (_wards[who] == 0) return;

        _wards[who] = 0;
        emit AuthRenounced(msg.sender, who);
    }

    /// @inheritdoc IAuth
    function authed(address who) external view override(IAuth) returns (bool) {
        return _wards[who] == 1;
    }

    /// @inheritdoc IAuth
    /// @custom:invariant Only contains auth'ed addresses.
    ///                     ∀x ∊ authed(): _wards[x]
    /// @custom:invariant Contains all auth'ed addresses.
    ///                     ∀x ∊ _wards[x]: x ∊ authed()
    function authed()
        external
        view
        override(IAuth)
        returns (address[] memory)
    {
        // Initiate array with upper limit length.
        address[] memory wardsList = new address[](_wardsTouched.length);

        // Iterate through all possible wards.
        uint ctr;
        for (uint i; i < _wardsTouched.length; i++) {
            // Add address only if still ward.
            if (_wards[_wardsTouched[i]] == 1) {
                wardsList[ctr++] = _wardsTouched[i];
            }
        }

        // Set length of array to number of wards actually included.
        /// @solidity memory-safe-assembly
        assembly {
            mstore(wardsList, ctr)
        }

        return wardsList;
    }

    /// @inheritdoc IAuth
    function wards(address who) public view override(IAuth) returns (uint) {
        return _wards[who];
    }
}
