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
  // x * 2 is to account for the 1:2 aspect ratio
  // 0.05 is to scale it -- does that make sense
  float4 position = float4((in.position.x + target_point.x) * 0.05 * 2, (in.position.y + target_point.y) * 0.1, 0, 1);
  VertexOut out {
    .position = position,
    .color = color
  };
  return out;
}

// TODO: figure out how to apply both of these textures
fragment float4 fragment_color(
  VertexOut in [[stage_in]]
) {
  float4 color = in.color;
  color.w = 0.4;
  return color;
}

fragment float4 fragment_main(
  VertexOut in [[stage_in]],
  texture2d<float> baseColorTexture [[texture(0)]]
) {
  constexpr sampler textureSampler;

//  I need to transform the position from 2x2 coord grid with center at 0,0 to 1x1 with center at top left
// so translate y + 1, x+ 1 scale by 1/2
  float3 baseColor = baseColorTexture.sample( textureSampler,
                                              float2((in.position.x + 1) * 0.5,
                                                     (in.position.y - 1) * -0.5)
                                             ).rgb;

  return float4(baseColor, 1);
}

