// Lentil

import SwiftUI


struct PulsingDot: View {
  @State private var animationAmount = 1.0
  
  var body: some View {
    Circle()
      .frame(width: 12, height: 12)
      .foregroundColor(Theme.Color.lensLightGreen)
      .overlay(
        Circle()
          .stroke(Theme.Color.lensLightGreen)
          .scaleEffect(self.animationAmount * 1)
          .opacity(2 - self.animationAmount)
          .animation(
            .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
            value: self.animationAmount
          )
      )
      .onAppear { self.animationAmount = 2 }
  }
}


#if DEBUG
struct PulsingDot_Previews: PreviewProvider {
  static var previews: some View {
    PulsingDot()
  }
}
#endif
