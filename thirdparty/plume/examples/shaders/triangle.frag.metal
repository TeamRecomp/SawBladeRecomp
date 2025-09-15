#include <metal_stdlib>
using namespace metal;

// Vertex to fragment data
struct VertexOutput {
    float4 position [[position]];
    float4 color;
};

// Fragment shader
fragment float4 PSMain(VertexOutput in [[stage_in]]) {
    return in.color;
} 