// Lentil

import Foundation
import CryptoKit
import SwiftUI

// MARK: Date conversion

func age(_ from: Date) -> String {
  let formatter = DateFormatter()
  formatter.dateStyle = .short
  formatter.timeStyle = .short
  return formatter.string(from: from)
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

func color(from handle: String) -> Color {
  let handleHash = SHA256.hash(data: Data(handle.utf8))
  let hexValue = hexString(handleHash.makeIterator())
  let firstPart = hexValue[0..<4], secondPart = hexValue[4..<8], thirdPart = hexValue[8..<12]
  var scanner: Scanner!
  var value: Double = 0
  var colorValues: [Double] = []
  [firstPart, secondPart, thirdPart].forEach {
    scanner = Scanner(string: String("0x" + $0))
    scanner.scanHexDouble(&value)
    colorValues.append(value / 65_535)
  }
  return Color(red: colorValues[0], green: colorValues[1], blue: colorValues[2])
}

fileprivate func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
  return iterator.map { String(format: "%02x", $0) }.joined()
}
