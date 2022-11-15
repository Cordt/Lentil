// Lentil

import SwiftUI
import UIKit

struct NavigationViewBackground: ViewModifier {
  var color: Color = Theme.Color.primary
  var accentColor: Color = Theme.Color.white
  
  func body(content: Content) -> some View {
    content
      .accentColor(self.accentColor)
      .onAppear {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        navBarAppearance.backgroundColor = UIColor(self.color)
        navBarAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
      }
  }
}

extension View {
  func navigationBarBackground(
    color: Color = Theme.Color.primary,
    accentColor: Color = Theme.Color.white)
  -> some View {
    modifier(NavigationViewBackground(color: color, accentColor: accentColor))
  }
}

extension UINavigationController: UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }
  
  public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
