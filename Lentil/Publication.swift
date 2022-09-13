// Lentil

import Foundation

struct Post: Identifiable, Equatable {
  let id: String
  let createdAt: Date
  
  let name: String
  let content: String
}
