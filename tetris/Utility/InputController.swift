//
//  InputController.swift
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

import GameController

class InputController {
  struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
  }
  
    static let shared = InputController()
    var keysPressed: Set<GCKeyCode> = []
    private init() {
      let center = NotificationCenter.default
      center.addObserver(
        forName: .GCKeyboardDidConnect,
        object: nil,
        queue: nil) { notification in
          let keyboard = notification.object as? GCKeyboard
            keyboard?.keyboardInput?.keyChangedHandler
              = { _, _, keyCode, pressed in
            if pressed {
              self.keysPressed.insert(keyCode)
            } else {
              self.keysPressed.remove(keyCode)
            }
          }
      }

    #if os(macOS)
      NSEvent.addLocalMonitorForEvents(
        matching: [.keyUp, .keyDown]) { _ in nil }
    #endif
  }
}
