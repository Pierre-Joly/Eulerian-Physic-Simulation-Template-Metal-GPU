#include <metal_stdlib>
using namespace metal;

#include "Common.h"
#include "Kernel.h"

kernel void initialize(device float* information [[buffer(InformationBuffer)]],
                       constant SimParams& params [[buffer(SimParamsBuffer)]],
                       constant Mesh& mesh [[buffer(MeshBuffer)]],
                       uint id [[thread_position_in_grid]])
{
    uint cellCount = mesh.Nx * mesh.Ny;
    if (id >= cellCount) {
        return;
    }

    information[id] = 0;
}
