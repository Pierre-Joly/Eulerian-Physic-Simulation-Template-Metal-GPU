#include <metal_stdlib>
using namespace metal;

#include "Common.h"
#include "ShaderDefs.h"

fragment float4 fragment_main(VertexOut in [[stage_in]],
                              constant Mesh& mesh [[buffer(MeshBuffer)]],
                              constant SimParams& params [[buffer(SimParamsBuffer)]],
                              device float* information [[buffer(InformationBuffer)]],
                              texture2d<float> gradientTexture [[texture(0)]],
                              sampler textureSampler [[sampler(0)]])
{
    uint x = min(uint(in.texCoord.x * mesh.Nx), mesh.Nx - 1);
    uint y = min(uint(in.texCoord.y * mesh.Ny), mesh.Ny - 1);
    uint idx = x + y * mesh.Nx;

    float informationNorm = information[idx] / (mesh.Nx + mesh.Ny);
    
    float t = clamp(informationNorm, 0.0, 1.0);
    float3 color = gradientTexture.sample(textureSampler, float2(t, 0.5)).rgb;

    return float4(color, 1.0);
}
