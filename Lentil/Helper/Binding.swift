// Lentil
// Created by Laura and Cordt Zermin

import CasePaths
import SwiftUI


extension Binding {
  func `case`<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Case?>
  where Value == Enum? {
    .init(
      get: { self.wrappedValue.flatMap(casePath.extract(from:)) },
      set: { newValue, transaction in
        self.transaction(transaction).wrappedValue = newValue.map(casePath.embed)
      }
    )
  }
  
  func isPresent<Wrapped>() -> Binding<Bool>
  where Value == Wrapped? {
    .init(
      get: { self.wrappedValue != nil },
      set: { isPresent, transaction in
        if !isPresent {
          self.transaction(transaction).wrappedValue = nil
        }
      }
    )
  }
  
  func isPresent<Enum, Case>(_ casePath: CasePath<Enum, Case>) -> Binding<Bool>
  where Value == Enum? {
    self.case(casePath).isPresent()
  }
}
