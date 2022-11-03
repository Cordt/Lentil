// Lentil

import Apollo
import Foundation


enum LensTypedData {
  case setDefaultProfile
}

func typedData(from: JSONObject, for: LensTypedData) throws -> Data {
  var updatedTypedData = addPrimaryType(to: from, for: `for`)
  updatedTypedData = renameValue(in: updatedTypedData)
  updatedTypedData = traverse(dict: updatedTypedData, removing: "__typename")
  
  // Lens API doesn't provide the types for the domain
  switch `for` {
    case .setDefaultProfile:
      updatedTypedData = addDefaultProfileTypes(in: updatedTypedData)
  }
  
  return try JSONSerialization.data(withJSONObject: updatedTypedData)
}

fileprivate func addPrimaryType(to dict: Dictionary<AnyHashable, Any>, for: LensTypedData) -> Dictionary<AnyHashable, Any> {
  var updated = dict
  guard var types = updated["types"] as? Dictionary<AnyHashable, Any>
  else { return updated }
  
  types.removeValue(forKey: "__typename")
  for (key, _) in types {
    if let key = key as? String {
      updated["primaryType"] = key
    }
  }
  return updated
}

fileprivate func renameValue(in dict: Dictionary<AnyHashable, Any>) -> Dictionary<AnyHashable, Any> {
  var updated = dict
  for (key, value) in dict {
    if let key = key as? String, key == "value" {
      updated["message"] = value
      updated.removeValue(forKey: key)
    }
  }
  return updated
}

fileprivate func traverse(dict: Dictionary<AnyHashable, Any>, removing key: String) -> Dictionary<AnyHashable, Any> {
  var updated = dict
  for (currentKey, value) in dict {
    if let inner = value as? Array<Dictionary<AnyHashable, Any>> {
      var updatedInner = inner
      for innerDict in inner.enumerated() {
        updatedInner[innerDict.offset] = traverse(dict: innerDict.element, removing: key)
      }
      updated[currentKey] = updatedInner
    }
    else if let inner = value as? Dictionary<AnyHashable, Any> {
      var updatedInner = inner
      updatedInner = traverse(dict: inner, removing: key)
      updated[currentKey] = updatedInner
    }
    else {
      updated.removeValue(forKey: key)
    }
  }
  return updated
}

fileprivate func addDefaultProfileTypes(in dict: Dictionary<AnyHashable, Any>) -> Dictionary<AnyHashable, Any> {
  var updated = dict
  guard var types = updated["types"] as? Dictionary<AnyHashable, Any>
  else { return updated }
  
  types["EIP712Domain"] = [
    [
      "name": "name",
      "type": "string"
    ],
    [
      "name": "version",
      "type": "string"
    ],
    [
      "name": "chainId",
      "type": "uint256"
    ],
    [
      "name": "verifyingContract",
      "type": "address"
    ]
  ]
  updated["types"] = types
  return updated
}

#if DEBUG
let mockChallenge: Challenge = .init(
  message: """
  \nhttps://api-mumbai.lens.dev wants you to sign in with your Ethereum account:\n0xCCC25867F3241d6d697d2Faa78D387DBD3E9B1ff\n\nSign in with ethereum to lens\n\nURI: https://api-mumbai.lens.dev\nVersion: 1\nChain ID: 80001\nNonce: af577b6dc4072219\nIssued At: 2022-10-18T03:45:16.825Z\n
  """,
  expires: Date().addingTimeInterval(60*5)
)
let mockTypedData: Data = try! typedData(from: typedDataDictionary, for: .setDefaultProfile)
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
#endif
