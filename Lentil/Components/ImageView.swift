// Lentil
// Created by Laura and Cordt Zermin

import SwiftUI
import UIKit


struct ImageView: View {
  var image: Image
  var dismiss: () -> Void
  
  var body: some View {
    GeometryReader { proxy in
      self.image
        .resizable()
        .scaledToFit()
        .frame(width: proxy.size.width, height: proxy.size.height)
        .modifier(ImageModifier(contentSize: CGSize(width: proxy.size.width, height: proxy.size.height)))
    }
    .padding(.top, 1)
    .toolbar {
      ToolbarItem(placement: .navigationBarLeading) {
        BackButton { self.dismiss() }
      }
    }
    .toolbarBackground(.hidden, for: .navigationBar)
    .navigationBarBackButtonHidden(true)
    .tint(Theme.Color.white)
  }
}


struct ImageModifier: ViewModifier {
  private var contentSize: CGSize
  private var min: CGFloat = 1.0
  private var max: CGFloat = 3.0
  @State var currentScale: CGFloat = 1.0
  
  init(contentSize: CGSize) {
    self.contentSize = contentSize
  }
  
  var doubleTapGesture: some Gesture {
    TapGesture(count: 2).onEnded {
      if currentScale <= min { currentScale = max } else
      if currentScale >= max { currentScale = min } else {
        currentScale = ((max - min) * 0.5 + min) < currentScale ? max : min
      }
    }
  }
  
  func body(content: Content) -> some View {
    ScrollView(axes: [.horizontal, .vertical], showsIndicators: false) {
      content
        .frame(
          width: contentSize.width * currentScale,
          height: contentSize.height * currentScale,
          alignment: .center
        )
        .modifier(PinchToZoom(minScale: min, maxScale: max, scale: $currentScale))
    }
    .gesture(doubleTapGesture)
    .animation(.easeInOut, value: currentScale)
  }
}

class PinchZoomView: UIView {
  let minScale: CGFloat
  let maxScale: CGFloat
  var isPinching: Bool = false
  var scale: CGFloat = 1.0
  let scaleChange: (CGFloat) -> Void
  
  init(
    minScale: CGFloat,
    maxScale: CGFloat,
    currentScale: CGFloat,
    scaleChange: @escaping (CGFloat) -> Void
  ) {
    self.minScale = minScale
    self.maxScale = maxScale
    self.scale = currentScale
    self.scaleChange = scaleChange
    super.init(frame: .zero)
    let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(gesture:)))
    pinchGesture.cancelsTouchesInView = false
    addGestureRecognizer(pinchGesture)
  }
  
  required init?(coder: NSCoder) {
    fatalError()
  }
  
  @objc private func pinch(gesture: UIPinchGestureRecognizer) {
    switch gesture.state {
      case .began:
        isPinching = true
        
      case .changed, .ended:
        if gesture.scale <= minScale {
          scale = minScale
        }
        else if gesture.scale >= maxScale {
          scale = maxScale
        }
        else {
          scale = gesture.scale
        }
        scaleChange(scale)
        
      case .cancelled, .failed:
        isPinching = false
        scale = 1.0
        
      default:
        break
    }
  }
}

struct PinchZoom: UIViewRepresentable {
  let minScale: CGFloat
  let maxScale: CGFloat
  @Binding var scale: CGFloat
  @Binding var isPinching: Bool
  
  func makeUIView(context: Context) -> PinchZoomView {
    let pinchZoomView = PinchZoomView(
      minScale: minScale,
      maxScale: maxScale,
      currentScale: scale,
      scaleChange: { scale = $0 }
    )
    return pinchZoomView
  }
  
  func updateUIView(_ pageControl: PinchZoomView, context: Context) {}
}

struct PinchToZoom: ViewModifier {
  let minScale: CGFloat
  let maxScale: CGFloat
  @Binding var scale: CGFloat
  @State var anchor: UnitPoint = .center
  @State var isPinching: Bool = false
  
  func body(content: Content) -> some View {
    content
      .scaleEffect(scale, anchor: anchor)
      .animation(.spring(), value: isPinching)
      .overlay(PinchZoom(minScale: minScale, maxScale: maxScale, scale: $scale, isPinching: $isPinching))
  }
}


#if DEBUG
struct ImageView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      NavigationStack {ImageView(image: Image("crete")) {} }
      NavigationStack {ImageView(image: Image("lentilBeta")) {} }
      NavigationStack {ImageView(image: Image("munich")) {} }
    }
  }
}
#endif
