//
//  Shaders.metal
//  MetalKitTest
//
//  Created by Harley-xk on 2019/3/28.
//  Copyright © 2019 Someone Co.,Ltd. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

//======================================
// Render Target Shaders
//======================================

struct Vertex {
    float4 position [[position]];
    float2 text_coord;
};

struct Uniforms {
    float4x4 scaleMatrix;
};

vertex Vertex vertex_render_target(constant Vertex *vertexes [[buffer(0)]],
                               constant Uniforms &uniforms [[buffer(1)]],
                               uint vid [[vertex_id]])
{
    Vertex out = vertexes[vid];
    out.position = uniforms.scaleMatrix * out.position;// * in.position;
    return out;
};

fragment float4 fragment_render_target(Vertex vertex_data [[stage_in]],
                                   texture2d<float> tex2d [[texture(0)]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = float4(tex2d.sample(textureSampler, vertex_data.text_coord));
    return color;
};

//======================================
// Point Shaders
//======================================

struct Point {
    float4 position [[position]];
    float4 color;
    float size [[point_size]];
};

vertex Point vertex_point_func(constant Point *points [[buffer(0)]],
                               constant Uniforms &uniforms [[buffer(1)]],
                               uint vid [[vertex_id]])
{
    Point out = points[vid];
    out.position = uniforms.scaleMatrix * out.position;// * in.position;
    return out;
};

fragment float4 fragment_point_func(Point point_data [[stage_in]],
                                    texture2d<float> tex2d [[texture(0)]],
                                    float2 pointCoord  [[point_coord]])
{
    constexpr sampler textureSampler(mag_filter::linear, min_filter::linear);
    float4 color = float4(tex2d.sample(textureSampler, pointCoord));
    return float4(point_data.color.rgb, color.a * point_data.color.a);
//    return color;
};
