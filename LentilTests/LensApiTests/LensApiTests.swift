// LentilTests
// Created by Laura and Cordt Zermin

import Foundation
import Web3
import XCTest
@testable import Lentil

final class LentilApiTests: XCTestCase {
  
  func testTypedDataForSetProfileIsDecodedAndAmended() throws {
    let typedData = try typedData(from: typedDataDictionary, for: .setDefaultProfile)
    XCTAssertNotNil(typedData)
  }
}

let typedDataDictionary: [String: Any] =
[
  "__typename": "SetDefaultProfileEIP712TypedData",
  "types": [
    "__typename": "SetDefaultProfileEIP712TypedDataTypes",
    "SetDefaultProfileWithSig": [
      [
        "__typename": "EIP712TypedDataField",
        "name": "wallet", "type": "address"
      ],
      [
        "name": "profileId",
        "type": "uint256",
        "__typename": "EIP712TypedDataField"
      ],
      [
        "name": "nonce",
        "type": "uint256",
        "__typename": "EIP712TypedDataField"
      ],
      [
        "name": "deadline",
        "type": "uint256",
        "__typename": "EIP712TypedDataField"
      ]
    ]
  ],
  "domain": [
    "chainId": "80001",
    "name": "Lens Protocol Profiles",
    "version": "1",
    "__typename": "EIP712TypedDataDomain",
    "verifyingContract": "0x60Ae865ee4C725cd04353b5AAb364553f56ceF82"
  ],
  "value": [
    "deadline": "1665370643",
    "profileId": "0x3fc0",
    "wallet": "0x823A234Df5d302bA0371f2859554f727875B6EA0",
    "nonce": "0",
    "__typename": "SetDefaultProfileEIP712TypedDataValue"
  ]
]

let typedDataString = """
    {
      "types": {
        "SetDefaultProfileWithSig": [
          {
            "__typename": "EIP712TypedDataField",
            "name": "wallet",
            "type": "address"
          },
          {
            "name": "profileId",
            "type": "uint256",
            "__typename": "EIP712TypedDataField"
          },
          {
            "__typename": "EIP712TypedDataField",
            "name": "nonce",
            "type": "uint256"
          },
          {
            "name": "deadline",
            "__typename": "EIP712TypedDataField",
            "type": "uint256"
          }
        ],
        "__typename": "SetDefaultProfileEIP712TypedDataTypes"
      },
      "domain": {
        "chainId": "80001",
        "name": "Lens Protocol Profiles",
        "__typename": "EIP712TypedDataDomain",
        "version": "1",
        "verifyingContract": "0x60Ae865ee4C725cd04353b5AAb364553f56ceF82"
      },
      "__typename": "SetDefaultProfileEIP712TypedData",
      "value": {
        "__typename": "SetDefaultProfileEIP712TypedDataValue",
        "deadline": "1665367518",
        "profileId": "0x3fc0",
        "wallet": "0x823A234Df5d302bA0371f2859554f727875B6EA0",
        "nonce": "0"
      }
    }
    """
  .data(using: .utf8)!

let expected = """
  {
    "domain": {
      "name": "Lens Protocol Profiles",
      "version": "1",
      "verifyingContract": "0x60Ae865ee4C725cd04353b5AAb364553f56ceF82",
      "chainId": "80001"
    },
    "types": {
      "SetDefaultProfileWithSig": [
        {
        "name": "wallet",
        "type": "address"
        },
        {
        "name": "profileId",
        "type": "uint256"
        },
        {
        "name": "nonce",
        "type": "uint256"
        },
        {
        "type": "uint256",
        "name": "deadline"
        }
      ],
      "EIP712Domain": [
        {
        "type": "string",
        "name": "name"
        },
        {
        "name": "version",
        "type": "string"
        },
        {
        "name": "chainId",
        "type": "uint256"
        },
        {
        "name": "verifyingContract",
        "type": "address"
        }
      ]
    },
    "message": {
      "deadline": "1665370643",
      "profileId": "0x3fc0",
      "nonce": "0",
      "wallet": "0x823A234Df5d302bA0371f2859554f727875B6EA0"
    },
    "primaryType": "SetDefaultProfileEIP712TypedData"
  }
  """
