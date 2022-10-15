// Lentil

import SwiftUI


// MARK: Colors

let col = Color(red: 0, green: 0, blue: 0)

struct Theme {
  struct Color {
    static let primaryRed: SwiftUI.Color =   SwiftUI.Color(red: 177/255, green: 15/255, blue: 15/255)
    static let systemRed: SwiftUI.Color =    SwiftUI.Color(red: 255/255, green: 59/255, blue: 48/255)
    static let systemBlue: SwiftUI.Color =   SwiftUI.Color(red: 0/255, green: 122/255, blue: 255/255)
    static let darkGrey: SwiftUI.Color =     SwiftUI.Color(red: 64/255, green: 64/255, blue: 64/255)
    static let lightGrey: SwiftUI.Color =    SwiftUI.Color(red: 112/255, green: 112/255, blue: 112/255)
    static let faintGray: SwiftUI.Color =    SwiftUI.Color(red: 242/255, green: 242/255, blue: 242/255)
    static let white: SwiftUI.Color =        SwiftUI.Color(red: 255/255, green: 255/255, blue: 255/255)
    static let shadow: SwiftUI.Color =       Theme.Color.lightGrey.opacity(0.2)
  }
  
  static let defaultRadius: CGFloat = 8.0
  static let defaultBorderWidth: CGFloat = 2.0
}

struct Constants_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      Group {
        Rectangle().fill(Theme.Color.primaryRed)
        Rectangle().fill(Theme.Color.systemRed)
        Rectangle().fill(Theme.Color.systemBlue)
        Rectangle().fill(Theme.Color.darkGrey)
        Rectangle().fill(Theme.Color.lightGrey)
        Rectangle().fill(Theme.Color.faintGray)
        Rectangle().fill(Theme.Color.white)
        Rectangle().fill(Theme.Color.shadow)
      }
    }
    .previewLayout(.fixed(width: 380, height: 800))
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
