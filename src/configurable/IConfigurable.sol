// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.4;

interface IConfigurable {
    /// @notice Thrown if file `file` invalid.
    error InvalidFile(bytes32 file);

    /// @notice Thrown if value `value` for file `file` invalid.
    error InvalidValueFiled(bytes32 file, bytes value);

    /// @notice Emitted when value filed.
    /// @param file The file.
    /// @param value The value filed.
    event Filed(bytes32 file, bytes value);

    /// @notice Files `file` with value `value`.
    /// @param file The file.
    /// @param value The value to file.
    function file(bytes32 file, bytes calldata value) external;
}
