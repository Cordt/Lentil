// Lentil
// Created by Laura and Cordt Zermin

import SwiftUI


struct SignInWithLens: View {
  var action: () -> ()
  
  var body: some View {
    Button { action() } label: {
      HStack(spacing: 0) {
        Image("lens-logo")
          .resizable()
          .frame(width: 28, height: 35)
        Text("Sign in with Lens")
          .font(.subheadline)
      }
      .padding([.leading, .trailing], 12)
    }
    .background(Theme.Color.lensLightGreen)
    .cornerRadius(Theme.defaultRadius)
    .padding(0)
  }
}


struct SignInWithLens_Previews: PreviewProvider {
  static var previews: some View {
    SignInWithLens {}
  }
}
