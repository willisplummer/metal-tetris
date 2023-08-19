//
//  Material.swift
//  tetris
//
//  Created by Willis Plummer on 8/18/23.
//

import MetalKit

class Material {
  let texture: MTLTexture

  init(allocator: MTKTextureLoader, filename: String) {
    guard let materialURL = Bundle.main.url(forResource: filename, withExtension: "png") else {
      fatalError()
    }

    let textureLoaderOptions: [MTKTextureLoader.Option: Any] = [.origin: MTKTextureLoader.Origin.bottomLeft]

    do {
      texture = try allocator.newTexture(URL: materialURL, options: textureLoaderOptions)
    } catch {
      fatalError("couldnt load texture")
    }
  }
}
