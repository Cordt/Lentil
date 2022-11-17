// Lentil
// Created by Laura and Cordt Zermin

import SwiftUI


// MARK: Colors

let col = Color(red: 0, green: 0, blue: 0)

struct Theme {
  struct Color {
    static let primary: SwiftUI.Color =        SwiftUI.Color(red: 0/255, green: 210/255, blue: 188/255)
    static let secondary: SwiftUI.Color =      SwiftUI.Color(red: 157/255, green: 86/255, blue: 175/255)
    static let tertiary: SwiftUI.Color =       SwiftUI.Color(red: 251/255, green: 4/255, blue: 108/255)
    static let contrast: SwiftUI.Color =       SwiftUI.Color(red: 45/255, green: 41/255, blue: 76/255)
    static let lensGreen: SwiftUI.Color =      SwiftUI.Color(red: 0/255, green: 80/255, blue: 30/255)
    static let lensLightGreen: SwiftUI.Color = SwiftUI.Color(red: 171/255, green: 254/255, blue: 44/255)
    static let systemRed: SwiftUI.Color =      SwiftUI.Color(red: 255/255, green: 59/255, blue: 48/255)
    static let systemBlue: SwiftUI.Color =     SwiftUI.Color(red: 0/255, green: 122/255, blue: 255/255)
    static let white: SwiftUI.Color =          SwiftUI.Color(red: 255/255, green: 255/255, blue: 255/255)
    static let greyShade1: SwiftUI.Color =     SwiftUI.Color(red: 238/255, green: 240/255, blue: 240/255)
    static let greyShade2: SwiftUI.Color =     SwiftUI.Color(red: 158/255, green: 166/255, blue: 175/255)
    static let greyShade3: SwiftUI.Color =     SwiftUI.Color(red: 144/255, green: 144/255, blue: 144/255)
    static let greyShade4: SwiftUI.Color =     SwiftUI.Color(red: 69/255, green: 69/255, blue: 69/255)
    static let text: SwiftUI.Color =           SwiftUI.Color(red: 64/255, green: 64/255, blue: 64/255)
    static let shadow: SwiftUI.Color =         Theme.Color.greyShade3.opacity(0.2)
  }
  
  static let defaultRadius: CGFloat = 5.0
  static let defaultBorderWidth: CGFloat = 2.0
}

struct Constants_Preview: PreviewProvider {
  static var previews: some View {
    VStack {
      VStack {
        Rectangle().fill(Theme.Color.primary)
        Rectangle().fill(Theme.Color.secondary)
        Rectangle().fill(Theme.Color.tertiary)
        Rectangle().fill(Theme.Color.contrast)
      }
      VStack {
        Rectangle().fill(Theme.Color.lensGreen)
        Rectangle().fill(Theme.Color.lensLightGreen)
        Rectangle().fill(Theme.Color.systemRed)
        Rectangle().fill(Theme.Color.systemBlue)
      }
      VStack {
        Rectangle().fill(Theme.Color.white)
        Rectangle().fill(Theme.Color.greyShade1)
        Rectangle().fill(Theme.Color.greyShade2)
        Rectangle().fill(Theme.Color.greyShade3)
        Rectangle().fill(Theme.Color.greyShade4)
        Rectangle().fill(Theme.Color.text)
        Rectangle().fill(Theme.Color.shadow)
      }
    }
    .previewLayout(.fixed(width: 380, height: 800))
  }
}

func lentilGradient() -> LinearGradient {
  LinearGradient(
    gradient: Gradient(colors: [Theme.Color.primary, Theme.Color.secondary]),
    startPoint: .top,
    endPoint: .bottom
  )
}



// MARK: Fonts

struct PrimaryFont: ViewModifier {
  enum Style {
    case largeTitle, title
    case xLargeHeadline, largeHeadline, headline
    case button, label, bodyDetailed, body, bodyBold
    case annotation, annotationSmall
  }
  
  private var font: Font {
    switch self.style {
      case .largeTitle:       return Font.custom("DMSans-Bold", size: 40, relativeTo: .largeTitle)
      case .title:            return Font.custom("DMSans-Bold", size: 32, relativeTo: .title)
      case .xLargeHeadline:   return Font.custom("DMSans-Bold", size: 28, relativeTo: .title2)
      case .largeHeadline:    return Font.custom("DMSans-Medium", size: 24, relativeTo: .title3)
      case .headline:         return Font.custom("DMSans-Medium", size: 20, relativeTo: .headline)
      case .button:           return Font.custom("DMSans-Bold", size: 16, relativeTo: .body)
      case .label:            return Font.custom("DMSans-Bold", size: 16, relativeTo: .body)
      case .bodyDetailed:     return Font.custom("DMSans-Regular", size: 18, relativeTo: .body)
      case .body:             return Font.custom("DMSans-Regular", size: 14, relativeTo: .body)
      case .bodyBold:         return Font.custom("DMSans-Bold", size: 14, relativeTo: .body)
      case .annotation:       return Font.custom("DMSans-Regular", size: 12, relativeTo: .caption)
      case .annotationSmall:  return Font.custom("DMSans-Regular", size: 11, relativeTo: .caption2)
    }
  }
  
  var style: Style
  var color: Color
  
  func body(content: Content) -> some View {
    content
      .font(self.font)
      .foregroundColor(self.color)
  }
}

struct HighlightFont: ViewModifier {
  enum Style {
    case largeTitle, largeHeadline
  }
  
  private var font: Font {
    switch self.style {
      case .largeTitle:       return Font.custom("Righteous-Regular", size: 40, relativeTo: .largeTitle)
      case .largeHeadline:    return Font.custom("Righteous-Regular", size: 24, relativeTo: .title3)
    }
  }
  
  var style: Style
  var color: Color
  
  func body(content: Content) -> some View {
    content
      .font(self.font)
      .foregroundColor(self.color)
  }
}

extension View {
  func font(style: PrimaryFont.Style, color: Color = Theme.Color.text) -> some View {
    modifier(PrimaryFont(style: style, color: color))
  }
  
  func font(highlight style: HighlightFont.Style, color: Color = Theme.Color.text) -> some View {
    modifier(HighlightFont(style: style, color: color))
  }
}


// MARK: Line Aweseome Icons

enum Icon {
  case back, notification, settings, share
  case heart, heartFilled, comment, mirror, collect
  case twitter, website, nft
  case location, lens
  case follow, collection
  
  enum FontSize {
    case `default`, large, xlarge
    fileprivate var size: CGFloat {
      switch self {
        case .`default`:  return 16
        case .large:      return 21
        case .xlarge:     return 28
      }
    }
  }
  
  private func symbol() -> String {
    switch self {
      case .back:         return ""
      case .notification: return ""
      case .settings:     return ""
      case .share:        return ""
      case .heart:        return ""
      case .heartFilled:  return ""
      case .comment:      return ""
      case .mirror:       return ""
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
        return Text(self.symbol()).font(.custom("la-brands-400", size: fontSize.size, relativeTo: .callout))
        
      case .heart, .comment, .share:
        return Text(self.symbol()).font(.custom("la-regular-400", size: fontSize.size, relativeTo: .callout))
        
      default:
        return Text(self.symbol()).font(.custom("la-solid-900", size: fontSize.size, relativeTo: .callout))
    }
  }
}
