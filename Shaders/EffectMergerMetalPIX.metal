//
//  EffectMergerMetalPIX.metal
//  PixelsShaders
//
//  Created by Hexagons on 2018-09-07.
//  Copyright © 2017 Hexagons. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexOut{
    float4 position [[position]];
    float2 texCoord;
};

struct Uniforms{
    /*<uniforms>*/
};

fragment float4 effectMergerMetalPIX(VertexOut out [[stage_in]],
                                     texture2d<float>  inTexA [[ texture(0) ]],
                                     texture2d<float>  inTexB [[ texture(1) ]],
                                     const device Uniforms& in [[ buffer(0) ]],
                                     sampler s [[ sampler(0) ]]) {
    float pi = 3.14159265359;
    float u = out.texCoord[0];
    float v = out.texCoord[1];
    float2 uv = float2(u, v);
    
    float4 pixInA = inTexA.sample(s, uv);
    float4 pixInB = inTexB.sample(s, uv);
    
    float4 pix = 0.0;
    
    /*<code>*/
    
    return pix;
}


