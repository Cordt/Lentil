// Lentil

import SwiftUI


struct FloatingButton: View {
  enum Kind {
    case primary, secondary
  }
  var title: String
  var kind: Kind = .primary
  var disabled: Bool = false
  var fullWidth: Bool = false
  var action: () -> ()
  
  var foregroundColor: Color {
    switch self.kind {
      case .primary:    return Theme.Color.white
      case .secondary:  return Theme.Color.primary
    }
  }
  var backgroundColor: Color {
    var color: Color
    switch self.kind {
      case .primary:    color = Theme.Color.primary
      case .secondary:  color = Theme.Color.white
    }
    return self.disabled ? color.opacity(0.5) : color
  }
  var borderColor: Color {
    switch self.kind {
      case .primary:    return .clear
      case .secondary:  return Theme.Color.primary
    }
  }
  
  var body: some View {
    Button(action: action) {
      HStack {
        if fullWidth { Spacer() }
        Text("\(title)")
          .font(.callout)
          .fontWeight(.medium)
          .padding([.top, .bottom], 12)
          .padding([.leading, .trailing], 16)
          .foregroundColor(self.foregroundColor)
        if fullWidth { Spacer() }
      }
      .background(self.backgroundColor)
      .overlay(
        RoundedRectangle(cornerRadius: Theme.defaultRadius)
          .stroke(self.borderColor, lineWidth: Theme.defaultBorderWidth)
      )
      .cornerRadius(Theme.defaultRadius)
      .shadow(color: Theme.Color.shadow, radius: 6.0, x: 6, y: 6)
    }
  }
}

struct FloatingButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      FloatingButton(title: "Active button") {}
      FloatingButton(title: "Disabled button", disabled: true) {}
      FloatingButton(title: "Secondary button", kind: .secondary) {}
      FloatingButton(title: "Full width button", fullWidth: true) {}
    }
    .padding()
  }
}

