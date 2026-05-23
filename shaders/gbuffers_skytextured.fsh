#version 330 compatibility

#include "/settings.glsl"

uniform sampler2D texture;

varying vec2 texcoord;
varying vec4 glcolor;

void main() {
	vec4 color = texture2D(texture, texcoord) * glcolor;
	
// Red Sun
#if RED_SUN == 1
	if (color.a > 0.9999999) {
		color.rgb = vec3(1.,0.,0.);
	}
	else {
		discard;
	}
#endif

/* DRAWBUFFERS:0 */
	gl_FragData[0] = color; //gcolor
}