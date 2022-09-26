// Lentil

import CoreImage
import SwiftUI


struct EasedDelay: AsyncSequence, AsyncIteratorProtocol {
  typealias Element = Int
  
  let velocity: Float = 35
  let maxDelay: Float = 1.0
  
  private var velocityFactor: Float { 1.0 / velocity }
  private let steps: Int = 40
  private var current = 0
  
  // 0...50...0
  var normalisedStep: Int {
    if self.current < 20 {
      return Int(Float(self.current) / 40.0 * 100)
    } else {
      return Int(Float(40 - self.current) / 40.0 * 100)
    }
  }
  
  mutating func next() async throws -> Int? {
    guard !Task.isCancelled,
          current < steps
    else { return nil }
    
    // Implements
    // f(x) = - 0.25(x-2)^2+1
    // with roots x = 0 || x = 4
    let step: Float = Float(current) / 10.0
    let delay: Float = (self.maxDelay - (-(0.25 * self.maxDelay) * pow((step - 2.0), 2)) + (1 * self.maxDelay)) * velocityFactor
    guard delay > 0
    else { return nil }
    try await Task.sleep(nanoseconds: UInt64(delay * Float(NSEC_PER_SEC)))
    
    current += 1
    return normalisedStep
  }
  
  func makeAsyncIterator() -> EasedDelay {
    self
  }
}

// Thank you Rob 🙏 - https://stackoverflow.com/a/43010051
struct RGBA32: Equatable {
  private var color: UInt32
  
  var redComponent: UInt8 {
    return UInt8((color >> 24) & 255)
  }
  
  var greenComponent: UInt8 {
    return UInt8((color >> 16) & 255)
  }
  
  var blueComponent: UInt8 {
    return UInt8((color >> 8) & 255)
  }
  
  var alphaComponent: UInt8 {
    return UInt8((color >> 0) & 255)
  }
  
  init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8) {
    let red   = UInt32(red)
    let green = UInt32(green)
    let blue  = UInt32(blue)
    let alpha = UInt32(alpha)
    color = (red << 24) | (green << 16) | (blue << 8) | (alpha << 0)
  }
  
  private func jittered(of original: Int, maxDeviation: Int, damping: CGFloat) -> Int {
    let halfInterval = maxDeviation / 2
    var result = 0
    if original + halfInterval > 255 {
      let spillOver = original + halfInterval - 255
      result = Int.random(in: original - halfInterval - spillOver...255)
    }
    else if original - halfInterval < 0 {
      let spillOver = (original - halfInterval) * -1
      result = Int.random(in: 0...original + halfInterval + spillOver)
    }
    else {
      result = Int.random(in: original - halfInterval...original + halfInterval)
    }
    return Int((1.0 - damping) * CGFloat(result))
  }
  
  mutating func jitter(strength: CGFloat, damping: CGFloat) {
    let maxDeviation = Int(strength * 255.0)
    let red   = self.jittered(of: Int(self.redComponent), maxDeviation: maxDeviation, damping: damping)
    let green = self.jittered(of: Int(self.greenComponent), maxDeviation: maxDeviation, damping: damping)
    let blue  = self.jittered(of: Int(self.blueComponent), maxDeviation: maxDeviation, damping: damping)
    let alpha = self.jittered(of: Int(self.alphaComponent), maxDeviation: maxDeviation, damping: damping)
    self.color = (UInt32(red) << 24) | (UInt32(green) << 16) | (UInt32(blue) << 8) | (UInt32(alpha) << 0)
  }
  
  static let red     = RGBA32(red: 255, green: 0,   blue: 0,   alpha: 255)
  static let green   = RGBA32(red: 0,   green: 255, blue: 0,   alpha: 255)
  static let blue    = RGBA32(red: 0,   green: 0,   blue: 255, alpha: 255)
  static let white   = RGBA32(red: 255, green: 255, blue: 255, alpha: 255)
  static let black   = RGBA32(red: 0,   green: 0,   blue: 0,   alpha: 255)
  static let magenta = RGBA32(red: 255, green: 0,   blue: 255, alpha: 255)
  static let yellow  = RGBA32(red: 255, green: 255, blue: 0,   alpha: 255)
  static let cyan    = RGBA32(red: 0,   green: 255, blue: 255, alpha: 255)
  
  static let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
  
  static func ==(lhs: RGBA32, rhs: RGBA32) -> Bool {
    return lhs.color == rhs.color
  }
}

func slice(image: UIImage, into howMany: Int) -> [UIImage] {
  let width: CGFloat
  let height: CGFloat
  
  switch image.imageOrientation {
    case .left, .leftMirrored, .right, .rightMirrored:
      width = image.size.height
      height = image.size.width
    default:
      width = image.size.width
      height = image.size.height
  }
  
  let tileWidth = Int(width / CGFloat(howMany))
  let tileHeight = Int(height / CGFloat(howMany))
  
  let scale = Int(image.scale)
  var images = [UIImage]()
  
  let cgImage = image.cgImage!
  
  var adjustedHeight = tileHeight
  
  var y = 0
  for row in 0 ..< howMany {
    if row == (howMany - 1) {
      adjustedHeight = Int(height) - y
    }
    var adjustedWidth = tileWidth
    var x = 0
    for column in 0 ..< howMany {
      if column == (howMany - 1) {
        adjustedWidth = Int(width) - x
      }
      let origin = CGPoint(x: x * scale, y: y * scale)
      let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
      let tileCgImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
      images.append(UIImage(cgImage: tileCgImage, scale: image.scale, orientation: image.imageOrientation))
      x += tileWidth
    }
    y += tileHeight
  }
  return images
}

func jitter(in image: UIImage, strength: CGFloat, damping: CGFloat) -> UIImage? {
  guard let inputCGImage = image.cgImage
  else {
    print("[ERROR] Image could not be converted to a core graphics image")
    return nil
  }
  guard strength <= 1.0, strength >= 0.0,
        damping <= 1.0, damping >= 0.0
  else {
    print("[ERROR] Jitter strength must be between 0 to 1")
    return nil
  }
  
  let colorSpace       = CGColorSpaceCreateDeviceRGB()
  let width            = inputCGImage.width
  let height           = inputCGImage.height
  let bytesPerPixel    = 4
  let bitsPerComponent = 8
  let bytesPerRow      = bytesPerPixel * width
  let bitmapInfo       = RGBA32.bitmapInfo
  
  guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
    print("[ERROR] Unable to create core graphics context")
    return nil
  }
  context.draw(inputCGImage, in: CGRect(x: 0, y: 0, width: width, height: height))
  
  guard let buffer = context.data else {
    print("[ERROR] Unable to get core graphics context data")
    return nil
  }
  
  let pixelBuffer = buffer.bindMemory(to: RGBA32.self, capacity: width * height)
  
  for row in 0 ..< Int(height) {
    for column in 0 ..< Int(width) {
      let offset = row * width + column
      if pixelBuffer[offset].alphaComponent != 0 {
        pixelBuffer[offset].jitter(strength: strength, damping: damping)
      }
    }
  }
  
  let outputCGImage = context.makeImage()!
  let outputImage = UIImage(cgImage: outputCGImage, scale: image.scale, orientation: image.imageOrientation)
  
  return outputImage
}
