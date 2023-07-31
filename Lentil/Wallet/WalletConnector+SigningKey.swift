// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP


extension WalletConnector: SigningKey {
  var address: String {
    return ""
  }
  
  func sign(_ data: Data) async throws -> XMTP.Signature {
    // First need to get signed data from publisher
//    let signatureData = try await self.signData(data)
    
    // then need to massage it to fit XMTP requirements
//    var signedMessage = try await self.signMessage(message: message)
//
//    // Strip leading 0x that we get back from `personal_sign`
//    if signedMessage.hasPrefix("0x"), signedMessage.count == 132 {
//      signedMessage = String(signedMessage.dropFirst(2))
//    }
//
//    guard let resultDataBytes = signedMessage.web3.bytesFromHex
//    else { throw WalletConnectorError.couldNotSignMessage }
//
//    var resultData = Data(resultDataBytes)
//
//    // Ensure we have a valid recovery byte
//    resultData[resultData.count - 1] = 1 - resultData[resultData.count - 1] % 2
    
    
    // Then turn it into an XMTP signature
//    var signature = XMTP.Signature()
//
//    signature.ecdsaCompact.bytes = signatureData[0 ..< 64]
//    signature.ecdsaCompact.recovery = UInt32(signatureData[64])
//
//    return signature
    fatalError("XMTP not integrated with wallet yet")
  }
  
  public func sign(message: String) async throws -> Signature {
    return try await sign(Data(message.utf8))
  }
}
