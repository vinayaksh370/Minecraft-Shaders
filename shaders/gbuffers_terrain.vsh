#version 330 compatibility

uniform mat4 gbufferModelViewInverse; 
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

out vec2 lmcoord;
out vec2 uv;
out vec4 glcolor;
out vec3 normal;
out vec4 shadowPos; 

out vec4 shadowClipPos; 

#include "lib/distort.glsl"

void main() {
	gl_Position = ftransform();
	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	glcolor = gl_Color;

	normal = normalize(gl_NormalMatrix * gl_Normal);
	normal = mat3(gbufferModelViewInverse) * normal;

	// transform vertex position into shadow space directly
	vec4 viewPos = gl_ModelViewMatrix * gl_Vertex;
	vec4 playerPos = gbufferModelViewInverse * viewPos;
	shadowClipPos = shadowProjection * (shadowModelView * playerPos);

	shadowPos = shadowClipPos;
	shadowPos.xyz /= shadowPos.w;
	shadowPos.xyz = distortShadowClipPos(shadowPos.xyz);
	shadowPos.z -= 0.001;
	shadowPos.xyz = shadowPos.xyz * 0.5 + 0.5;    // to 0-1 range


	// float bias = computeBias(shadowPos.xyz);   // compute before distort
    // shadowPos.z -= bias;                       // apply bias after distort
}