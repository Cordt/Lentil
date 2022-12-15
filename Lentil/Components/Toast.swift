// Lentil
// Created by Laura and Cordt Zermin

import SwiftUI


struct Toast: Equatable {
  enum Duration {
    case short, medium, long
  }
  var message: String
  var duration: Duration = .short
  fileprivate var durationTime: Double {
    switch self.duration {
      case .short:  return 2.0
      case .medium: return 3.0
      case .long:   return 4.0
    }
  }
}

struct ToastView: View {
  let message: String
  
  var body: some View {
    Text(self.message)
      .font(style: .body, color: Theme.Color.white)
      .foregroundColor(Color.black.opacity(0.6))
      .padding()
      .background(Theme.Color.greyShade3)
      .cornerRadius(8)
      .shadow(color: Theme.Color.shadow, radius: 5, x: 0, y: 2)
      .padding(.horizontal, 20)
  }
}

struct ToastModifier: ViewModifier {
  @Binding var toast: Toast?
  @State private var workItem: DispatchWorkItem?
  
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .overlay(
        ZStack {
          mainToastView()
            .offset(y: -30)
        }.animation(.spring(), value: toast)
      )
      .onChange(of: toast) { value in
        showToast()
      }
  }
  
  @ViewBuilder func mainToastView() -> some View {
    if let toast {
      VStack {
        Spacer()
        ToastView(message: toast.message)
      }
      .transition(.move(edge: .bottom))
    }
  }
  
  private func showToast() {
    guard let toast
    else { return }
    
    UIImpactFeedbackGenerator(style: .light)
      .impactOccurred()
    
    if toast.durationTime > 0 {
      workItem?.cancel()
      
      let task = DispatchWorkItem {
        dismissToast()
      }
      
      workItem = task
      DispatchQueue.main.asyncAfter(deadline: .now() + toast.durationTime, execute: task)
    }
  }
  
  private func dismissToast() {
    withAnimation {
      toast = nil
    }
    
    workItem?.cancel()
    workItem = nil
  }
}

extension View {
  func toastView(toast: Binding<Toast?>) -> some View {
    self.modifier(ToastModifier(toast: toast))
  }
}

#if DEBUG
struct ToastView_Previews: PreviewProvider {
  static var previews: some View {
    Theme.Color.primary
      .ignoresSafeArea()
      .toastView(
        toast: .constant(
          Toast(
            message: "Default Profile could not be loaded. Did you claim your Lens Handle with this wallet?")
        )
      )
  }
}
#endif
