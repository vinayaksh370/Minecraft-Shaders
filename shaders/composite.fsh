// Lighting Calculations

#version 330 compatibility

#include "lib/distort.glsl"
#include "settings.glsl"

uniform sampler2D depthtex0; // for getting depth value 

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;

uniform vec3 shadowLightPosition;     // return sun or moon position in view space 
uniform mat4 gbufferModelViewInverse; // for converting normals from view space to world/player space

in vec2 uv;

/*
const int colortex0Format = RGBA32F;
const int colortex2Format = R8;
*/

uniform sampler2D texture;
in vec3 normal;

/* RENDERTARGETS: 0,3 */
layout(location = 0) out vec4 color; 
layout(location = 3) out vec2 compositeUV;

const vec3 blocklightColor = vec3(1.0, 0.5, 0.08);
const vec3 skylightColor = vec3(0.05, 0.15, 0.3);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);



void main() {

	// Base Default Color from the color texture
	vec4 albedo = texture2D(colortex0, uv);
	// Gamma Correction
    albedo.rgb = pow(albedo.rgb, vec3(INITIAL_GAMMA)); 
    // albedo.rgb = pow(albedo.rgb, vec3(1/INITIAL_GAMMA)); 

	compositeUV = uv;

	float depth = texture2D(depthtex0, uv).r;
	if (depth == 1.0) {
  		// return;
		discard; 
	}

	vec2 lightMap = texture2D(colortex1, uv).rg;
	vec3 encodedNormal = texture2D(colortex2, uv).rgb;
	// decode normal from texture (do not shadow the vertex 'normal' input)
	vec3 decodedNormal = normalize((encodedNormal - 0.5) * 2.0); // convert back from 0..1 to -1..1

	vec3 lightVector = normalize(shadowLightPosition);
	vec3 worldLightVector = mat3(gbufferModelViewInverse) * lightVector; // convert shadow light position from view space to world space ... normalize to get unit vector
	
	float theta =  clamp(dot(worldLightVector, decodedNormal), 0.0, 1.0); // 0 = blockfacing away from light, 1 = block facing towards light
	
	vec3 blockLight = lightMap.r * blocklightColor; // blocklight is stored in the red channel of the lightmap
	vec3 skylight = lightMap.g * skylightColor;     // skylight is stored in the green channel of the lightmap
	vec3 ambient = ambientColor;
	vec3 sunlight = sunlightColor * theta * lightMap.g;

	// vec3 blockLight = lightMap.r * blocklightColor;
	// vec3 skyLight = lightMap.g * skylightColor;
	// vec3 ambient = ambientColor;
	// vec3 sunlight = sunlightColor * clamp(dot(worldLightVector, normal), 0.0, 1.0) * lightMap.g;

	// use the correctly named 'skylight' variable and decoded normal
	albedo.rgb *= blockLight + skylight + ambient + sunlight;

	// Debug

	// albedo.rgb = vec3(lightMap,0.0);
	// albedo.rgb = normal;
	// color = vec4(albedo.rgb, 1.0);
	// vec4 albedo = texture2D(texture, uv);
	// vec3 tormal = normal;
	// tormal = tormal * 0.5 + 0.5; // convert from -1 to 1 range to 0 to 1 range for visualization
	// Gamma Correction
    // albedo.rgb = pow(albedo.rgb, vec3(1/1.5)); // vec3(1.5)
    // color = albedo * vec4(tormal, 1.0);
    // color = vec4(tormal, 1.0);
    // albedo.rgb = normal;

	// color = vec4(albedo.rgb, 1.0);
	
	
	
	//Debug
	
	color = texture2D(colortex0, uv);
	
}