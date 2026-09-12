// SPDX-License-Identifier: MIT
pragma solidity ^0.8.34;

/// @title AddressConverter
/// @notice Перетворює текстовий запис Ethereum-адреси у тип address.
contract AddressConverter {
  error InvalidAddressLength(uint256 actualLength);
  error InvalidAddressPrefix();
  error InvalidHexCharacter(bytes1 character);

  /// @notice Перетворює рядок формату 0x + 40 шістнадцяткових символів у address.
  /// @param value Адреса у текстовому вигляді, наприклад "0x1234...abcd".
  /// @return Адреса у байтовому представленні Solidity (address).
  function stringToAddress(string memory value) public pure returns (address) {
    bytes memory characters = bytes(value);

    if (characters.length != 42) {
      revert InvalidAddressLength(characters.length);
    }

    if (
      characters[0] != "0" ||
      (characters[1] != "x" && characters[1] != "X")
    ) {
      revert InvalidAddressPrefix();
    }

    uint160 result;
    for (uint256 i = 2; i < characters.length; i++) {
      result = (result << 4) | _hexCharacterToUint(characters[i]);
    }

    return address(result);
  }

  function _hexCharacterToUint(bytes1 character) private pure returns (uint8) {
    uint8 code = uint8(character);

    if (code >= 48 && code <= 57) {
      return code - 48; // 0-9
    }

    if (code >= 65 && code <= 70) {
      return code - 55; // A-F
    }

    if (code >= 97 && code <= 102) {
      return code - 87; // a-f
    }

    revert InvalidHexCharacter(character);
  }
}
