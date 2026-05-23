#version 330 compatibility

uniform int renderStage; // for stars
uniform float viewHeight;
uniform float viewWidth;
uniform mat4 gbufferModelView;
uniform mat4 gbufferProjectionInverse;
uniform vec3 fogColor;
uniform vec3 skyColor;

#include "/settings.glsl"

varying vec4 starData; //rgb = star color, a = flag for weather or not this pixel is a star.

in vec4 glcolor;

const float sunPathRotation = 30.0;

float fogify(float x, float w) {
	return w / (x * x + w);
}

vec3 calcSkyColor(vec3 pos) {
	float upDot = dot(pos, gbufferModelView[1].xyz);
	return mix(skyColor, fogColor, fogify(max(upDot, 0.0), 0.25));
}

vec3 screenToView(vec3 screenPos) // screen spcae -> view space
{ 
	vec4 ndcPos = vec4(screenPos, 1.0) * 2.0 - 1.0; // Screen Coord => Normalized Device Coordinates ; [0,1] => [1, -1]
	vec4 tmp = gbufferProjectionInverse * ndcPos; // NDC => Clip Space
	return tmp.xyz / tmp.w; // Clip Space => View Space
}

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

void main() {
	// vec3 color;
	/*
		if (starData.a > 0.5) {
			color.rgb = starData.rgb;
		}
		else {
			vec4 pos = vec4(gl_FragCoord.xy / vec2(viewWidth, viewHeight) * 2.0 - 1.0, 1.0, 1.0);
			pos = gbufferProjectionInverse * pos;
			color.rgb = calcSkyColor(normalize(pos.xyz));
		}
	*/

	if (renderStage == MC_RENDER_STAGE_STARS) 
	{ // draw stars
		color = glcolor;
	} 
	else 
	{ // draw sky
		vec3 pos = screenToView(vec3(gl_FragCoord.xy / vec2(viewWidth, viewHeight), 1.0));
		color = vec4(calcSkyColor(normalize(pos)), 1.0);
	}

	#if BLACK_SKY == 1
		color.rgb =  vec3(0.0);
	#endif

	color = vec4(color.rgb, 1.0); //gcolor
}