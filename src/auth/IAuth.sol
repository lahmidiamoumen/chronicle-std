// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IAuth {
    /// @notice Thrown by protected function if caller not auth'ed.
    error NotAuthorized();

    /// @notice Emitted when auth granted to address.
    /// @param by The address granted auth.
    /// @param to The address auth got granted to.
    event AuthGranted(address indexed by, address indexed to);

    /// @notice Emitted when auth renounced from address.
    /// @param by The address renounced auth.
    /// @param to The address auth got renounced from.
    event AuthRenounced(address indexed by, address indexed to);

    /// @notice Grants address `who` auth.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to grant auth.
    function rely(address who) external;

    /// @notice Renounces address `who`'s auth.
    /// @dev Only callable by auth'ed address.
    /// @param who The address to renounce auth.
    function deny(address who) external;

    /// @notice Returns whether address `who` is auth'ed.
    /// @param who The address to check.
    /// @return True if `who` is auth'ed.
    function authed(address who) external view returns (bool);

    /// @notice Returns full list of addresses granted auth.
    /// @dev May contain duplicates.
    /// @return List of addresses granted auth.
    function authed() external view returns (address[] memory);

    /// @notice Whether given address is auth'ed.
    /// @custom:deprecated Use `authed(address)(bool)` instead.
    /// @return 1 if address is auth'ed, 0 otherwise.
    function wards(address who) external view returns (uint);
}
