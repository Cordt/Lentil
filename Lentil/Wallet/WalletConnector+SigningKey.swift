// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import XMTP


extension WalletConnector: SigningKey {
  func sign(_ data: Data) async throws -> XMTP.Signature {
    let signatureData = try await self.signData(data)
    
    var signature = XMTP.Signature()
    
    signature.ecdsaCompact.bytes = signatureData[0 ..< 64]
    signature.ecdsaCompact.recovery = UInt32(signatureData[64])
    
    return signature
  }
  
  public func sign(message: String) async throws -> Signature {
    return try await sign(Data(message.utf8))
  }
}
