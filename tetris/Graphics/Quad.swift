//
//  Square.swift
//  tetris
//
//  Created by Willis Plummer on 8/8/23.
//

import MetalKit

struct Quad {
  var vertices: [Float] = [
    0, 0,
    0, 1,
     1, 1,
     1, 0
  ]

  var indices: [UInt16] = [
    0, 1, 2,
    2, 3, 0
  ]

  let vertexBuffer: MTLBuffer
  let indexBuffer: MTLBuffer

  init(device: MTLDevice) {
    guard let vertexBuffer = device.makeBuffer(
      bytes: &vertices,
      length: MemoryLayout<Float>.stride * vertices.count,
      options: []) else {
      fatalError("Unable to create quad vertex buffer")
    }
    self.vertexBuffer = vertexBuffer

    guard let indexBuffer = device.makeBuffer(
      bytes: &indices,
      length: MemoryLayout<UInt16>.stride * indices.count,
      options: []) else {
      fatalError("Unable to create quad index buffer")
    }
    self.indexBuffer = indexBuffer
  }
}
