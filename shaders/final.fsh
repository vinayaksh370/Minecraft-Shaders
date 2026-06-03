#version 330 compatibility

#include "lib/distort.glsl"

/*
const int colortex0Format = RGBA32F;
*/

uniform sampler2D colortex0;

in vec2 uv;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	// Base Default Color from the color texture
	vec3 albedo = texture(colortex0, uv).rgb;

	// Gamma Correction
    albedo.rgb = pow(albedo.rgb, vec3(1/2.2));
    // albedo.rgb = pow(albedo.rgb, vec3(1.5));

    color = vec4(albedo, 1.0);
}
