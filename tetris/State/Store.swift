//
//  Stire.swift
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

import Foundation

typealias Reducer<State, Action> = (State, Action) -> State

class Store<State, Action>: ObservableObject {
  @Published private(set) var state: State
  private let reducer: Reducer<State, Action>
  private let queue = DispatchQueue(
    label: "com.willisplummer.Tetris.store",
    qos: .userInitiated)


  init(initial: State, reducer: @escaping Reducer<State, Action>) {
    self.state = initial
    self.reducer = reducer
  }

  func dispatch(_ action: Action) -> Void {
    queue.sync {
      self.dispatch(self.state, action)
    }
  }

  private func dispatch(_ currentState: State, _ action: Action) {
    let newState = reducer(currentState, action)
    state = newState
  }
}
