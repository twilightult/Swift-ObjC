#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float3 position [[attribute(0)]];
    float2 uv       [[attribute(1)]];
    float  face     [[attribute(2)]];
};

struct VertexOut {
    float4 position [[position]];
    float2 uv;
    float  face;
};

vertex VertexOut vs_main(VertexIn in [[stage_in]],
                         constant float4x4 &mvp [[buffer(1)]]) {
    VertexOut out;
    out.position = mvp * float4(in.position, 1.0);
    out.uv = in.uv;
    out.face = in.face;
    return out;
}

fragment float4 fs_main(VertexOut in [[stage_in]],
                        texture2d<float> top  [[texture(0)]],
                        texture2d<float> dirt [[texture(1)]],
                        texture2d<float> side [[texture(2)]],
                        sampler s [[sampler(0)]]) {
    float4 c;
    float shade = 0.80;
    if (in.face < 0.5) {
        c = top.sample(s, in.uv);
        shade = 1.0;
    } else if (in.face < 1.5) {
        c = dirt.sample(s, in.uv);
        shade = 0.60;
    } else {
        c = side.sample(s, in.uv);
    }
    return float4(c.rgb * shade, c.a);
}
