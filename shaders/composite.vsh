#version 330 compatibility

out vec2 texcoord;

void main() {
	gl_Position = ftransform(); // vertex from model to clip space 
	texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	// uv coords map position of the vertex in the texture, used to sample texture
}