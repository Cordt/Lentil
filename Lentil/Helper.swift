// Lentil

import Foundation
import CryptoKit
import SwiftUI

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


// MARK: Generated Profile picture

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
