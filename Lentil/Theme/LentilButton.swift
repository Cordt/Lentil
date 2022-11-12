// Lentil

import SwiftUI


struct LentilButton: View {
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
          .textCase(.uppercase)
          .font(style: .button, color: self.foregroundColor)
          .padding([.top, .bottom], 10)
          .padding([.leading, .trailing], 24)
        if fullWidth { Spacer() }
      }
      .background(self.backgroundColor)
      .overlay(
        RoundedRectangle(cornerRadius: Theme.defaultRadius)
          .stroke(self.borderColor, lineWidth: Theme.defaultBorderWidth)
      )
      .cornerRadius(Theme.defaultRadius)
    }
  }
}

struct FloatingButton_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      LentilButton(title: "Active button") {}
      LentilButton(title: "Disabled button", disabled: true) {}
      LentilButton(title: "Secondary button", kind: .secondary) {}
      LentilButton(title: "Full width button", fullWidth: true) {}
    }
    .padding()
  }
}

