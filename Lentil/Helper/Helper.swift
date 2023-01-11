// Lentil
// Created by Laura and Cordt Zermin

import Foundation
import CryptoKit
import SwiftUI


// MARK: View Extensions

struct Mirrored: ViewModifier {
  func body(content: Content) -> some View {
    content
      .rotationEffect(.degrees(180))
      .scaleEffect(x: -1, y: 1, anchor: .center)
  }
}

extension View{
  func mirrored() -> some View{
    self.modifier(Mirrored())
  }
}

// MARK: Image rendering

struct StoredImage {
  enum Kind: Equatable { case profile(_ handle: String), feed, cover }
  enum Resolution: Equatable { case display, storage }
}

fileprivate func data(from image: UIImage, for kind: StoredImage.Kind, and resolution: StoredImage.Resolution) -> Data? {
  let imageDimension: CGFloat
  switch kind {
    case .profile:
      switch resolution {
        case .display: imageDimension = 200
        case .storage: imageDimension = 400
      }
    case .feed:
      switch resolution {
        case .display: imageDimension = 600
        case .storage: imageDimension = 800
      }
    case .cover:
      switch resolution {
        case .display: imageDimension = 800
        case .storage: imageDimension = 1200
      }
  }
  return image
    .aspectFittedToDimension(imageDimension)
    .jpegData(compressionQuality: Theme.compressionQuality)
}

extension Data {
  func imageData(for kind: StoredImage.Kind, and resolution: StoredImage.Resolution) -> Data? {
    guard let image = UIImage(data: self)
    else { return nil}
    return data(from: image, for: kind, and: resolution)
  }
  
  func image(for kind: StoredImage.Kind, and resolution: StoredImage.Resolution) -> UIImage? {
    guard let imageData = self.imageData(for: kind, and: resolution)
    else { return nil }
    return UIImage(data: imageData)
  }
}

extension UIImage {
  fileprivate func aspectFittedToDimension(_ maxDimension: CGFloat) -> UIImage {
    // Adjust for device scale (affects UIImage)
    let screenScale = maxDimension / UIScreen.main.scale
    let aspectRatio = size.width/size.height
    var width: CGFloat
    var height: CGFloat
    if aspectRatio > 1 {
      width = screenScale
      height = screenScale / aspectRatio
    }
    else {
      width = screenScale * aspectRatio
      height = screenScale
    }
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: width, height: height), format: UIGraphicsImageRendererFormat.default())
    return renderer.image { _ in
      self.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
    }
  }
  
  func imageData(for kind: StoredImage.Kind, and resolution: StoredImage.Resolution) -> Data? {
    data(from: self, for: kind, and: resolution)
  }
  
  func image(for kind: StoredImage.Kind, and resolution: StoredImage.Resolution) -> UIImage? {
    guard let imageData = data(from: self, for: kind, and: resolution)
    else { return nil }
    return UIImage(data: imageData)
  }
}

// MARK: Numbers

func hexToDecimal(_ hexString: String) -> UInt64? {
  if hexString.count > 2, hexString[0..<2] == "0x" {
    return UInt64(hexString.dropFirst(2), radix: 16)
  }
  else {
    return UInt64(hexString, radix: 16)
  }
}


// MARK: Date conversion

func age(_ from: Date) -> String {
  switch from.timeIntervalSinceNow * -1 {
    case let timePassed where timePassed < 60:
      // Less than a minute
      if timePassed < 2 { return "1 second" }
      else { return "\(Int(timePassed)) seconds" }
      
    case let timePassed where timePassed < 60 * 60:
      // Less than an hour
      if timePassed < 60 * 2 { return "1 minute" }
      else { return "\(Int(floor(timePassed / 60.0))) minutes" }
      
    case let timePassed where timePassed < 60 * 60 * 24:
      // Less than a day
      if timePassed < 60 * 60 * 2 { return "1 hour" }
      else { return "\(Int(floor(timePassed / 60.0 / 60.0))) hours" }
      
      
    case let timePassed where timePassed < 60 * 60 * 48:
      // Less than 48 hours
      return "1 day"
      
    default:
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .none
      return formatter.string(from: from)
  }
}

func date(from: String) -> Date? {
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
  return formatter.date(from: from)
}


// MARK: String dynamic member lookup

extension String {
  subscript(value: Int) -> Character {
    self[index(at: value)]
  }
}

extension String {
  subscript(value: NSRange) -> Substring {
    self[value.lowerBound..<value.upperBound]
  }
}

extension String {
  subscript(value: CountableClosedRange<Int>) -> Substring {
    self[index(at: value.lowerBound)...index(at: value.upperBound)]
  }
  
  subscript(value: CountableRange<Int>) -> Substring {
    self[index(at: value.lowerBound)..<index(at: value.upperBound)]
  }
  
  subscript(value: PartialRangeUpTo<Int>) -> Substring {
    self[..<index(at: value.upperBound)]
  }
  
  subscript(value: PartialRangeThrough<Int>) -> Substring {
    self[...index(at: value.upperBound)]
  }
  
  subscript(value: PartialRangeFrom<Int>) -> Substring {
    self[index(at: value.lowerBound)...]
  }
}

fileprivate extension String {
  func index(at offset: Int) -> String.Index {
    index(startIndex, offsetBy: offset)
  }
}


// MARK: Profile

func profileGradient(from handle: String) -> some View {
  let handleHash = SHA256.hash(data: Data(handle.utf8))
  let hexValue = hexString(handleHash.makeIterator())
  let firstPart = hexValue[0..<4],
      secondPart = hexValue[4..<8],
      thirdPart = hexValue[8..<12],
      fourthPart = hexValue[12..<16],
      fifthPart = hexValue[16..<20],
      sixthPart = hexValue[20..<24],
      seventhPart = hexValue[24..<28],
      eighthPart = hexValue[28..<32],
      ninethPart = hexValue[32..<36]
  var scanner: Scanner!
  var value: Double = 0
  var colorValues: [Double] = []
  [firstPart, secondPart, thirdPart, fourthPart, fifthPart, sixthPart, seventhPart, eighthPart, ninethPart].forEach {
    scanner = Scanner(string: String("0x" + $0))
    scanner.scanHexDouble(&value)
    colorValues.append(value / 65_535)
  }
  let firstColor = Color(red: colorValues[0], green: colorValues[1], blue: colorValues[2])
  let secondColor = Color(red: colorValues[3], green: colorValues[4], blue: colorValues[5])
  let thirdColor = Color(red: colorValues[6], green: colorValues[7], blue: colorValues[8])
  return Circle()
    .fill(
      AngularGradient(
        colors: [firstColor, secondColor, thirdColor],
        center: .center
      )
    )
}

fileprivate func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
  return iterator.map { String(format: "%02x", $0) }.joined()
}

func simpleCount(from: Int) -> String {
  switch from {
    case 0 ..< 1000:
      return "\(from)"
    case 1_000 ..< 10_000:
      return "\(from)"
    case 10_000 ..< 100_000:
      return "\(from)"
    default:
      return "\(from)"
  }
}


// MARK: Logging

enum LogLevel: String {
  case info, debug, warn, error
  
  func prefixed(message: String) -> String {
    switch self {
      case .info:  return "[INFO] "  + message
      case .debug: return "[DEBUG] " + message
      case .warn:  return "[WARN] "  + message
      case .error: return "[ERROR] " + message
    }
  }
  
  func shouldLog() -> Bool {
    switch LentilEnvironment.shared.logLevel {
      case .info:  return true
      case .debug: return self == .warn  || self == .debug || self == .error
      case .warn:  return self == .debug || self == .error
      case .error: return self == .error
    }
  }
}

func log(_ text: String, level: LogLevel, error: Error) {
  #if DEBUG
  log(text, level: level, error: error.localizedDescription)
  #endif
}

func log(_ text: String, level: LogLevel, error: String? = nil) {
#if DEBUG
  if level.shouldLog() {
    var message = level.prefixed(message: text)
    if let error { message += ": \(error)" }
    print(message)
  }
#endif
}
