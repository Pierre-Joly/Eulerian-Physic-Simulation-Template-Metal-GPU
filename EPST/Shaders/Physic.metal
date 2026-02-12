#include <metal_stdlib>
using namespace metal;

#include "Common.h"
#include "Kernel.h"

kernel void physic(device float* information [[buffer(InformationBuffer)]],
                        constant SimParams& params [[buffer(SimParamsBuffer)]],
                        constant Mesh& mesh [[buffer(MeshBuffer)]],
                        uint id [[thread_position_in_grid]])
{
    uint cellCount = mesh.Nx * mesh.Ny;
    if (id >= cellCount) return;

    uint x = id % mesh.Nx;
    uint y = id / mesh.Nx;

    information[id] = float(x + y);
}
