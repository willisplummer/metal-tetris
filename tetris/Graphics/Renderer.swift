//
//  Renderer.swift
//  tetris
//
//  Created by Willis Plummer on 8/8/23.
//

import MetalKit

// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var store: GameStateStore
  var pipelineState: MTLRenderPipelineState!
  var lastTime: Double = CFAbsoluteTimeGetCurrent()

  lazy var scene = GameScene(store: store)
  lazy var quad: Quad = {
    Quad(device: Renderer.device)
  }()

  init(metalView: MTKView, store: GameStateStore) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
        fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device

    // create the shader function library
    let library = device.makeDefaultLibrary()
    Self.library = library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction =
      library?.makeFunction(name: "fragment_main")

    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat =
      metalView.colorPixelFormat
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout

    do {
      pipelineState =
      try device.makeRenderPipelineState(
        descriptor: pipelineDescriptor)
      pipelineDescriptor.vertexFunction = vertexFunction
      pipelineState =
        try device.makeRenderPipelineState(
          descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    self.store = store
    super.init()
    metalView.clearColor = MTLClearColor(
      red: 1.0,
      green: 1.0,
      blue: 0.9,
      alpha: 1.0)

    metalView.delegate = self
    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(
    _ view: MTKView,
    drawableSizeWillChange size: CGSize
  ) {}
  
  func renderSquare(position: float2, color: float4, encoder: MTLRenderCommandEncoder) {
    // define the basic set of vertices and indices for a square + tell the graphics engine to render that
    encoder.setVertexBuffer(
      quad.vertexBuffer,
      offset: 0,
      index: 0)

    // i just pass the desired pos on 10x10 grid to the gpu and have it translate the square
    encoder.setVertexBytes(
      [position.x, position.y],
      length: MemoryLayout<Float>.stride * 2,
      index: 11)

    encoder.setVertexBytes(
      [color.x, color.y, color.z, color.w],
      length: MemoryLayout<Float>.stride * 4,
      index: 12)

    encoder.drawIndexedPrimitives(
      type: .triangleStrip,
      indexCount: quad.indices.count,
      indexType: .uint16,
      indexBuffer: quad.indexBuffer,
      indexBufferOffset: 0)
  }

  func renderBlocks(encoder: MTLRenderCommandEncoder) {
    encoder.setRenderPipelineState(pipelineState)

    (store.state.lockedBlocks + store.state.activeBlocks).forEach({ block in
      renderSquare(position: block.position, color: block.color, encoder: encoder)
    })
  }

  func draw(in view: MTKView) {
    guard
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
        return
    }

    // game loop
    let currentTime = CFAbsoluteTimeGetCurrent()
    let deltaTime = Float(currentTime - lastTime)
    lastTime = currentTime
    scene.update(deltaTime: deltaTime)
    // end game loop

    renderBlocks(encoder: renderEncoder)

    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
