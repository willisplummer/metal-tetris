//
//  ContentView.swift
//  snake
//
//  Created by Willis Plummer on 8/8/23.
//

import SwiftUI

let size: CGFloat = 400
struct ContentView: View {
  @EnvironmentObject var store: GameStateStore
//  let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

  var body: some View {
    VStack(alignment: .leading) {
      ZStack {
        MetalView()
          .border(Color.black, width: 2)
        Grid()
      }
        .frame(width: size, height: size)
      Text("Score: \(store.state.score)")
      store.state.gameOver ? AnyView(Text("Game Over - Press enter to restart")) : AnyView(EmptyView())
    }
    .padding()
  }
}

struct Grid: View {
  var cellSize: CGFloat = size / 20
  var body: some View {
    ZStack {
      HStack {
        ForEach(0..<Int(cellSize)) { _ in
          Spacer()
          Divider()
        }
      }
      VStack {
        ForEach(0..<Int(cellSize)) { _ in
          Spacer()
          Divider()
        }
      }
      HStack {
        ZStack {
          Divider()
          Divider()
          Divider()
        }
      }
      VStack {
        ZStack {
          Divider()
          Divider()
          Divider()
        }
      }
    }
  }
}


struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    Group {
      ContentView()
    }
  }
}
