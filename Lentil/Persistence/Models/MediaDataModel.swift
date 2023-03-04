// Lentil
// Created by Laura and Cordt Zermin

import Foundation


extension Model {
  struct MediaData: Equatable, Identifiable {
    var id: String { self.url }
    
    let url: String
    let data: Data
  }
}
