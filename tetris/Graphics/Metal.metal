//
//  Metal.metal
//  tetris
//
//  Created by Willis Plummer on 8/10/23.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float2 position [[attribute(0)]];
//  float4 color [[attribute(1)]];
};

struct VertexOut {
  float4 position [[position]];
  float4 color;
};

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  constant float2 &target_point [[buffer(11)]],
  constant float4 &color [[buffer(12)]]
) {
  float4 position = float4(in.position.x + target_point.x, in.position.y + target_point.y, 0, 10);
  VertexOut out {
    .position = position,
    .color = color
  };
  return out;
}

fragment float4 fragment_main(
                              VertexOut in [[stage_in]]
                              ) {
  return in.color;
}

