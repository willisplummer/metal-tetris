//
//  VertexDescriptor.swift
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor {
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float2
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0

    let stride = MemoryLayout<Float>.stride * 2
    vertexDescriptor.layouts[0].stride = stride
    return vertexDescriptor
  }
}
