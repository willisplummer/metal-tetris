//
//  MetalView.swift
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

import SwiftUI
import MetalKit

struct MetalView: View {
  @EnvironmentObject var store: GameStateStore

  @State private var renderer: Renderer?
  @State private var metalView = MTKView()
  var body: some View {
    VStack {
      MetalViewRepresentable(
        renderer: renderer,
        metalView: $metalView,
        gameState: store.state)
        .onAppear {
          renderer = Renderer(
            metalView: metalView,
            store: store)
        }
    }
  }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias MyMetalView = NSView
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias MyMetalView = UIView
#endif

struct MetalViewRepresentable: ViewRepresentable {
  @EnvironmentObject var store: GameStateStore

  let renderer: Renderer?
  @Binding var metalView: MTKView
  let gameState: GameState

  #if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    return metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
  #elseif os(iOS)
  func makeUIView(context: Context) -> MTKView {
    metalView
  }

  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
  #endif

  func updateMetalView() {
    renderer?.store = store
  }
}

struct MetalView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView()
      Text("Metal View")
    }
  }
}
