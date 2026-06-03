#version 330 compatibility

out vec2 uv; //texcoord

void main() {
	gl_Position = ftransform();
	uv = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
}
