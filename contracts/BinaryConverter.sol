// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/// @title BinaryConverter
/// @notice Перетворює число у двійковий рядок, розбитий на байти.
contract BinaryConverter {
  /// @notice Повертає двійкове представлення числа групами по 8 біт.
  /// @dev Нуль повертається як один байт: "00000000".
  /// @param value Невід'ємне ціле число типу uint256.
  /// @return Двійковий рядок, наприклад 25901 -> "01100101 00101101".
  function numberToBinary(uint256 value) public pure returns (string memory) {
    uint256 byteCount = 1;
    uint256 temporary = value;

    // Визначаємо мінімальну кількість байтів для запису числа.
    while (temporary > 255) {
      byteCount++;
      temporary >>= 8;
    }

    // Кожна група містить 8 символів; між сусідніми групами є пробіл.
    bytes memory result = new bytes(byteCount * 9 - 1);
    uint256 resultIndex;

    for (uint256 byteIndex = byteCount; byteIndex > 0; byteIndex--) {
      uint8 currentByte = uint8(value >> ((byteIndex - 1) * 8));

      for (uint256 bitIndex = 0; bitIndex < 8; bitIndex++) {
        uint256 mask = uint256(1) << (7 - bitIndex);
        result[resultIndex] = (uint256(currentByte) & mask) != 0 ? bytes1(0x31) : bytes1(0x30);
        resultIndex++;
      }

      if (byteIndex > 1) {
        result[resultIndex] = bytes1(0x20);
        resultIndex++;
      }
    }

    return string(result);
  }
}
