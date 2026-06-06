#version 330 compatibility

uniform mat4 gbufferModelViewInverse; // Inverse of the modelview matrix used for the gbuffer pass, used to convert normals from view space to world/player space

out vec2 uv; //texcoord
out vec3 normal;

void main() {
	gl_Position = ftransform();
	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

	normal = gl_NormalMatrix * gl_Normal; // this gives us the normal in view space
	normal = mat3(gbufferModelViewInverse) * normal; // this converts the normal from view space to world/player space
}