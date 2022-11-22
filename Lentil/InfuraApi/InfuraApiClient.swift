// Lentil
// Created by Laura and Cordt Zermin

import Alamofire
import Foundation
import UIKit


struct InfuraApi {
  struct InfuraIPFSResponse: Codable, Equatable {
    let Name: String
    let Hash: String
    let Size: String
  }
  
  static func authenticationHeader() -> HTTPHeader {
    let username = LentilEnvironment.shared.infuraProjectId
    let password = LentilEnvironment.shared.infuraApiSecretKey
    let loginString = "\(username):\(password)"
    let loginData = Data(loginString.utf8)
    let base64LoginString = loginData.base64EncodedString()
    return HTTPHeader(name: "Authorization", value: "Basic \(base64LoginString)")
  }
  
  static func upload<File: FormDataAppendable>(file: File) async throws -> InfuraIPFSResponse {
    try await withCheckedThrowingContinuation { continuation in
      AF.upload(
        multipartFormData: { formData in
          formData.append(
            file.data,
            withName: file.name,
            fileName: file.fileName,
            mimeType: file.fileMimeType
          )
        },
        to: LentilEnvironment.shared.infuraUrl,
        method: .post,
        headers: [InfuraApi.authenticationHeader()]
      )
      .validate(statusCode: 200..<300)
      .responseDecodable(of: InfuraIPFSResponse.self) { response in
        switch response.result {
          case .success(let ipfsResponse):
            continuation.resume(returning: ipfsResponse)
          case .failure(let error):
            continuation.resume(throwing: error)
        }
      }
    }
  }
  
  var uploadPublication: @Sendable (_ publicationFile: PublicationFile) async throws -> InfuraIPFSResponse
  var uploadImage: @Sendable (_ imageFile: ImageFile) async throws -> InfuraIPFSResponse
}
