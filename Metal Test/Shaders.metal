#include "ShaderDefinitions.h"

#include <metal_stdlib>

using namespace metal;

struct VertexOut {
	float4 position [[ position ]];
	float4 color;
};

vertex VertexOut basic_vertex(const device Vertex *vertex_array [[ buffer(0) ]], constant Uniforms &uniforms [[ buffer(1) ]], unsigned int vid [[ vertex_id ]]) {
	Vertex in;
	in.position = vertex_array[vid].position;
	in.color = vertex_array[vid].color;
	
	VertexOut out;
	out.position = uniforms.projectionMatrix * uniforms.viewMatrix * uniforms.modelMatrix * float4(in.position, 1.0);
	out.color = in.color;
	return out;
}

fragment float4 basic_fragment(VertexOut interpolated [[ stage_in ]]) {
	return interpolated.color;
}
