// Lentil

import SwiftUI


// MARK: Colors

enum ThemeColor {
  case primaryRed
  case systemRed, systemBlue
  case darkGrey, lightGrey, faintGray, white
  
  var color: Color {
    switch self {
      case .primaryRed:   return Color(red: 177/255, green: 15/255, blue: 15/255)
      case .systemRed:    return Color(red: 255/255, green: 59/255, blue: 48/255)
      case .systemBlue:   return Color(red: 0/255, green: 122/255, blue: 255/255)
      case .darkGrey:     return Color(red: 64/255, green: 64/255, blue: 64/255)
      case .lightGrey:    return Color(red: 112/255, green: 112/255, blue: 112/255)
      case .faintGray:    return Color(red: 242/255, green: 242/255, blue: 242/255)
      case .white:        return Color(red: 255/255, green: 255/255, blue: 255/255)
    }
  }
}


// MARK: Line Aweseome Icons

enum Icon {
  case back, notification, settings, share
  case upvote, downvote, comment, mirror, collect
  case twitter, website, nft
  case location, lens
  case follow, collection
  
  enum FontSize {
    case `default`, large
    fileprivate var size: CGFloat {
      switch self {
        case .default: return 16
        case .large: return 21
      }
    }
  }
  
  private func symbol() -> String {
    switch self {
      case .back:         return ""
      case .notification: return ""
      case .settings:     return ""
      case .share:        return ""
      case .upvote:       return ""
      case .downvote:     return ""
      case .comment:      return ""
      case .mirror:       return ""
      case .collect:      return ""
      case .twitter:      return ""
      case .website:      return ""
      case .nft:          return ""
      case .location:     return ""
      case .lens:         return ""
      case .follow:       return ""
      case .collection:   return ""
    }
  }
  
  func view(_ fontSize: FontSize = .default) -> Text {
    switch self {
      case .twitter, .lens, .collection:
        return Text(self.symbol()).font(.custom("la-brands-900", size: fontSize.size, relativeTo: .callout))
        
      default:
        return Text(self.symbol()).font(.custom("la-solid-900", size: fontSize.size, relativeTo: .callout))
    }
  }
}
