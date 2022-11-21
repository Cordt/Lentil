// Lentil
// Created by Laura and Cordt Zermin

import Alamofire
import Foundation
import UIKit


protocol FormDataAppendable {
  var data: Data { get }
  var name: String { get }
  var fileName: String { get }
  var fileMimeType: String? { get }
}

struct TextFile: FormDataAppendable {
  var data: Data { self.text }
  var fileMimeType: String? { nil }
  
  let text: Data
  let name: String
  let fileName: String
  
  init?(text: String) {
    guard let textData = text.data(using: .utf8)
    else { return nil }
    let name = "lentil-" + UUID().uuidString
    
    self.text = textData
    self.name = name
    self.fileName = name + ".txt"
  }
}

struct ImageFile: FormDataAppendable {
  enum ImageMimeType: String {
    case gif = "image/gif"
    case jpeg = "image/jpeg"
    case png = "image/png"
    case tiff = "image/tiff"
    case xMsBmp = "image/x-ms-bmp"
    case svgXml = "image/svg+xml"
    case webp = "image/webp"
  }
  
  var data: Data { self.image }
  var fileMimeType: String? { self.mimeType.rawValue }
  
  let image: Data
  let mimeType: ImageMimeType
  let name: String
  let fileName: String
  
  init(image: UIImage, mimeType: ImageMimeType) {
    let imageData = image.jpegData(compressionQuality: 0.75)!
    let name = "lentil-" + UUID().uuidString
    
    self.image = imageData
    self.mimeType = mimeType
    self.name = name
    self.fileName = name + ImageFile.fileExtension(for: mimeType)
  }
  
  private static func fileExtension(for mimeType: ImageMimeType) -> String {
    switch mimeType {
      case .gif:    return ".gif"
      case .jpeg:   return ".jpeg"
      case .png:    return ".png"
      case .tiff:   return ".tiff"
      case .xMsBmp: return ".xMsBmp"
      case .svgXml: return ".svgXml"
      case .webp:   return ".webp"
    }
  }
}

struct InfuraApi {
  struct InfuraIPFSResponse: Codable {
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
  
  var uploadText: @Sendable (_ textFile: TextFile) async throws -> InfuraIPFSResponse
  var uploadImage: @Sendable (_ imageFile: ImageFile) async throws -> InfuraIPFSResponse
}
