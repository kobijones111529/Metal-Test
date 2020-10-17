#ifndef ShaderDefinitions_h
#define ShaderDefinitions_h

#include <simd/simd.h>

struct Vertex {
	vector_float3 position;
	vector_float4 color;
};

struct Uniforms {
	simd_float4x4 projectionMatrix;
	simd_float4x4 viewMatrix;
	simd_float4x4 modelMatrix;
};

#endif /* ShaderDefinitions_h */
