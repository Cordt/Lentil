// Lentil

import SwiftUI


extension View {
  public func popup<PopupContent: View>(
    isPresented: Binding<Bool>,
    view: @escaping () -> PopupContent) -> some View {
      self.modifier(
        Popup(
          isPresented: isPresented,
          animation: Animation.spring(dampingFraction: 0.75),
          view: view)
      )
    }
}

struct Popup<PopupContent>: ViewModifier where PopupContent: View {
  
  init(
    isPresented: Binding<Bool>,
    animation: Animation = .linear,
    view: @escaping () -> PopupContent
  ) {
    self._isPresented = isPresented
    self.animation = animation
    self.view = view
  }
  
  /// Controls if the sheet should be presented or not
  @Binding var isPresented: Bool
  
  var animation: Animation
  
  /// The content to present
  var view: () -> PopupContent
  
  // MARK: - Private Properties
  /// The rect of the hosting controller
  @State private var presenterContentRect: CGRect = .zero
  
  /// The rect of popup content
  @State private var sheetContentRect: CGRect = .zero
  
  /// The offset when the popup is displayed
  private var displayedOffset: CGFloat {
    -presenterContentRect.midY + screenHeight/2
  }
  
  /// The offset when the popup is hidden
  private var hiddenOffset: CGFloat {
    if presenterContentRect.isEmpty {
      return 1000
    }
    return screenHeight - presenterContentRect.midY + sheetContentRect.height/2 + 5
  }
  
  /// The current offset, based on the "presented" property
  private var currentOffset: CGFloat {
    return isPresented ? displayedOffset : hiddenOffset
  }
  private var screenWidth: CGFloat {
    UIScreen.main.bounds.size.width
  }
  
  private var screenHeight: CGFloat {
    UIScreen.main.bounds.size.height
  }
  
  // MARK: - Content Builders
  public func body(content: Content) -> some View {
    ZStack {
      content
        .frameGetter($presenterContentRect)
    }
    .overlay(sheet())
  }
  
  func sheet() -> some View {
    ZStack {
      self.view()
        .simultaneousGesture(
          TapGesture().onEnded {
            dismiss()
          })
        .frameGetter($sheetContentRect)
        .frame(width: screenWidth)
        .offset(x: 0, y: currentOffset)
        .animation(self.animation, value: currentOffset)
    }
  }
  
  private func dismiss() {
    isPresented = false
  }
  
}

extension View {
  func frameGetter(_ frame: Binding<CGRect>) -> some View {
    modifier(FrameGetter(frame: frame))
  }
}

struct FrameGetter: ViewModifier {
  
  @Binding var frame: CGRect
  
  func body(content: Content) -> some View {
    content
      .background(
        GeometryReader { proxy -> AnyView in
          let rect = proxy.frame(in: .global)
          // This avoids an infinite layout loop
          if rect.integral != self.frame.integral {
            DispatchQueue.main.async {
              self.frame = rect
            }
          }
          return AnyView(EmptyView())
        }
      )
  }
}
