// LentilTests
// Created by Laura and Cordt Zermin

import Foundation


class PredictableNumberGenerator: RandomNumberGenerator {
  func next() -> UInt64 {
    return 1
  }
}
