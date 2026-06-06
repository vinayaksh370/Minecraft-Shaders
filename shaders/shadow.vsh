#version 330 compatibility

#include "lib/distort.glsl"


out vec2 uv;
out vec4 glcolor;

void main() {
	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	glcolor = gl_Color;
    gl_Position = ftransform();
	gl_Position.xyz = distortShadowClipPos(gl_Position.xyz);

	// #ifdef EXCLUDE_FOLIAGE
	// 	if (mc_Entity.x == 10000.0) {
	// 		gl_Position = vec4(10.0);
	// 	}
	// 	else {
	// #endif
	// 		gl_Position = ftransform();
	// 		// gl_Position.xyz = distort(gl_Position.xyz);
	// #ifdef EXCLUDE_FOLIAGE
	// 	}
	// #endif
}