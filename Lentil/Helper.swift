// Lentil

import Foundation

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
