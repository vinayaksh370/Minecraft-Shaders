#version 330 compatibility

#include "lib/distort.glsl"
#include "settings.glsl"

// This declaration is for iris to read and set the buffer...prevents loss of color values if you write linear colors to colortex [they take gamma corrected values usually]
/*
const int colortex0Format = RGBA32F;
const float shadowDistanceRenderMul = 1.0;
*/

uniform sampler2D colortex0;

in vec2 uv;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	// Base Default Color from the color texture
	vec3 albedo = texture(colortex0, uv).rgb;

	// Gamma Correction
    albedo.rgb = pow(albedo.rgb, vec3(1/FINAL_GAMMA));
    // albedo.rgb = pow(albedo.rgb, vec3(FINAL_GAMMA));

    color = vec4(albedo, 1.0);
}