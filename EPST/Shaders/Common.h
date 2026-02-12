#ifndef Common_h
#define Common_h

#include <simd/simd.h>

#if defined(__METAL_VERSION__)
typedef uint u32;
#else
#include <stdint.h>
typedef uint32_t u32;
#endif

typedef enum BufferIndices {
    VertexBuffer = 0,
    UniformsBuffer = 1,
    InformationBuffer = 2,
    MeshBuffer = 3,
    SimParamsBuffer = 4
} BufferIndices;

typedef struct {
    u32 Nx;
    u32 Ny;
} Mesh;

typedef struct {
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
} Uniforms;

typedef struct {
    float param;
} SimParams;

#endif /* Common_h */
