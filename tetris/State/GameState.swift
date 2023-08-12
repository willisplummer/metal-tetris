//
//  GameState.swift
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

import Foundation
import simd

typealias GameStateStore = Store<GameState, GameAction>

enum Direction {
  case left, right, down

  func vector() -> float2 {
    switch self {
    case .down:
      return float2(0, -1)
    case .left:
      return float2(-1, 0)
    case .right:
      return float2(1, 0)
    }
  }
}

struct Block {
  var position: float2
  let color: float4

  func translate(_ vector: float2) -> Block {
    return Block(position: self.position + vector, color: self.color)
  }

  var x: Float {
    position.x
  }

  var y: Float {
    position.y
  }
}

enum  Shape: CaseIterable {
  case long, square, tee, el, jay, zee, ess
  func initialBlocks() -> [Block] {
    switch self {
    case .long:
      return [
        Block(position: float2(-1, 9), color: float4(0,0,1,1)),
        Block(position: float2(0, 9), color: float4(0,0,1,1)),
        Block(position: float2(1, 9), color: float4(0,0,1,1)),
        Block(position: float2(2, 9), color: float4(0,0,1,1))
      ]
    case .square:
      return [
        Block(position: float2(-1, 9), color: float4(1,1,0,1)),
        Block(position: float2(0, 9), color: float4(1,1,0,1)),
        Block(position: float2(-1, 10), color: float4(1,1,0,1)),
        Block(position: float2(0, 10), color: float4(1,1,0,1))
      ]
    case .tee:
      return [
        Block(position: float2(-1, 9), color: float4(1,0,0,1)),
        Block(position: float2(0, 9), color: float4(1,0,0,1)),
        Block(position: float2(1, 9), color: float4(1,0,0,1)),
        Block(position: float2(0, 10), color: float4(1,0,0,1))
      ]
    case .el:
      return [
        Block(position: float2(-1, 9), color: float4(0,1,0,1)),
        Block(position: float2(0, 9), color: float4(0,1,0,1)),
        Block(position: float2(0, 10), color: float4(0,1,0,1)),
        Block(position: float2(0, 11), color: float4(0,1,0,1))
      ]
    case .jay:
      return [
        Block(position: float2(1, 9), color: float4(0,1,1,1)),
        Block(position: float2(0, 9), color: float4(0,1,1,1)),
        Block(position: float2(0, 10), color: float4(0,1,1,1)),
        Block(position: float2(0, 11), color: float4(0,1,1,1))
      ]
    case .zee:
      return [
        Block(position: float2(0, 9), color: float4(0.5,0.5,0.5,1)),
        Block(position: float2(1, 9), color: float4(0.5,0.5,0.5,1)),
        Block(position: float2(1, 10), color: float4(0.5,0.5,0.5,1)),
        Block(position: float2(2, 10), color: float4(0.5,0.5,0.5,1))
      ]
    case .ess:
      return [
        Block(position: float2(1, 9), color: float4(0.5,1,0.5,1)),
        Block(position: float2(0, 9), color: float4(0.5,1,0.5,1)),
        Block(position: float2(0, 10), color: float4(0.5,1,0.5,1)),
        Block(position: float2(-1, 10), color: float4(0.5,1,0.5,1))
      ]
    }
  }
}

enum GameAction: Equatable {
  case move(Direction)
  case rotate
  case next
  case tick(Float)
  case restart
}

struct GameState {
  var activeBlocks: [Block]
  var lockedBlocks: [Block]

  var velocity: Float
  var timeSinceLastMove: Float

  var score: Int32
  var gameOver: Bool

  init() {
    activeBlocks = Shape.long.initialBlocks()
    lockedBlocks = []

    velocity = 2
    timeSinceLastMove = 0

    score = 0
    gameOver = false
  }
}

func gameReducer(state: GameState, action: GameAction) -> GameState {
  if (state.gameOver && action.self != .restart) {
    return state
  }
  var newState = state
  switch action {
  case .restart:
    newState = GameState()
    return newState
    
  case .move(let dir):
    let targetUpdate = applyMove(activeBlocks: state.activeBlocks, vector: dir.vector())
    if canMoveTo(targetUpdate.map{block in block.position}, lockedBlocks: state.lockedBlocks){
      newState.activeBlocks = targetUpdate
    }

  case .tick(let deltaTime):
    if state.gameOver == true {
      return state
    }

    newState.timeSinceLastMove += deltaTime * newState.velocity
    if newState.timeSinceLastMove < 1 {
      return newState
    }

    newState.timeSinceLastMove = 0

    let targetUpdate = applyMove(activeBlocks: state.activeBlocks, vector: Direction.down.vector())
    if canMoveTo(targetUpdate.map{block in block.position}, lockedBlocks: state.lockedBlocks){
      newState.activeBlocks = targetUpdate
    } else {
      newState.lockedBlocks = newState.lockedBlocks + newState.activeBlocks
      // TODO: clear full rows of locked blocks, lower all rows above it

      if (newState.lockedBlocks.contains{f2 in
        f2.y > 9
      }) {
        newState.gameOver = true
      } else {
        newState.activeBlocks = Shape.allCases.randomElement()!.initialBlocks()
      }
    }
  case .rotate:
  //    TODO: implement rotate
      return newState
  case .next:
    let activeBlocksFinalPos = getFinalPosition(activeBlocks: newState.activeBlocks, lockedBlocks: newState.lockedBlocks)
    newState.lockedBlocks = newState.lockedBlocks + activeBlocksFinalPos
    newState.activeBlocks = Shape.allCases.randomElement()!.initialBlocks()
    return newState
  }
  return newState
}

func applyMove(activeBlocks: [Block], vector: float2) -> [Block] {
  return activeBlocks.map{ block in
    return block.translate(vector)
  }
}

func posOverlapsLockedBlocks(targetPos: float2, lockedBlocks: [Block]) -> Bool {
  return lockedBlocks.contains{ block in
    block.position == targetPos
  }
}

func canMoveTo(_ targetPosition: [float2], lockedBlocks: [Block]) -> Bool {
  return !targetPosition.contains{pos in
    posOverlapsLockedBlocks(targetPos: pos, lockedBlocks: lockedBlocks)
    || pos.x < -10 || pos.x > 9 || pos.y < -10
  }
}

// just keep going down until we can't go down any further
func getFinalPosition(activeBlocks: [Block], lockedBlocks: [Block]) -> [Block] {
  let targetUpdate = applyMove(activeBlocks: activeBlocks, vector: Direction.down.vector())

  if !canMoveTo(targetUpdate.map{ block in block.position }, lockedBlocks: lockedBlocks){
    return activeBlocks
  }

  return getFinalPosition(activeBlocks: targetUpdate, lockedBlocks: lockedBlocks)
}

// previous implementation -- much more confusing and probably less efficient
//func getFinalPosition(activeBlocks: [Block], lockedBlocks: [Block]) -> [Block] {
//  // for each x of the activeShape get the lowest y
//  let lowestYAtEachXOfActiveShape = activeBlocks.reduce(Dictionary<Float, Float>.init(), { acc, block in
//    var mutatedAcc = acc
//    let previousLowestYAtX: Float? = mutatedAcc[block.position.x]
//    if previousLowestYAtX != nil {
//      mutatedAcc[block.position.x] = min(previousLowestYAtX!, block.position.y)
//    } else {
//      mutatedAcc[block.position.x] = block.position.y
//    }
//    return mutatedAcc
//  })
//
//  // for each x of the activeShape, find the lockedblock with highest y (or the bottom limit)
//  let highestYAtEachXOfLockedBlocks = lockedBlocks
//    // we only care about frozen blocks in the columns of the active shape
//    .filter { block in
//      lowestYAtEachXOfActiveShape.keys.contains(block.x)
//    }
//    // if there are higher y's above the piece, it would calculate a negative distance and go up
//    // so we eliminate any frozen blocks hanging over the piece
//    .filter { block in
//      lowestYAtEachXOfActiveShape[block.x]! > block.y
//    }
//    .reduce(Dictionary<Float, Float>.init(), { acc, block in
//      var mutatedAcc = acc
//      if lowestYAtEachXOfActiveShape[block.x] == nil {
//        return mutatedAcc // this should be a no-op after the filter for only blocks in active shape columns
//      }
//      let previousHighestYAtX: Float? = mutatedAcc[block.position.x]
//      if previousHighestYAtX != nil {
//        mutatedAcc[block.position.x] = max(previousHighestYAtX!, block.position.y)
//      } else {
//        mutatedAcc[block.position.x] = block.position.y
//      }
//      return mutatedAcc
//    })
//
//  let distancesToCollisions = lowestYAtEachXOfActiveShape.reduce([Float].init(), { acc, tuple in
//    let (x, lowestYOfActive) = tuple
//    let highestYOfLocked = highestYAtEachXOfLockedBlocks[x] ?? -11
//    let distance = lowestYOfActive - highestYOfLocked
//    return acc + [distance]
//  })
//
//  let minimumDistanceToCollision = (distancesToCollisions.min() ?? 1) - 1
//
//  return applyMove(activeBlocks: activeBlocks, vector: Direction.down.vector() * minimumDistanceToCollision)
//}