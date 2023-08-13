//
//  ContentView.swift
//  snake
//
//  Created by Willis Plummer on 8/8/23.
//

import SwiftUI

let height: CGFloat = 400
let width: CGFloat = 200
// squares are 10*10, board is 10 wide by 20 high
// TODO: don't just hardcode this stuff

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
        .frame(width: width, height: height)
      Text("Score: \(store.state.score)")
      store.state.gameOver ? AnyView(Text("Game Over - Press enter to restart")) : AnyView(EmptyView())
    }
    .padding()
  }
}

struct Grid: View {
  var body: some View {
    ZStack {
      HStack {
        ForEach(0..<Int(10)) { _ in
          Spacer()
          Divider()
        }
      }
      VStack {
        ForEach(0..<Int(20)) { _ in
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
        .environmentObject(GameStateStore(initial: GameState(), reducer: gameReducer))
    }
  }
}
