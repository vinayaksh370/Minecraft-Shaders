#version 330 compatibility

// #define DRAW_SHADOW_MAP gcolor 

uniform float frameTimeCounter;
uniform sampler2D gcolor;
uniform sampler2D shadowcolor0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D colortex0;

#include "/settings.glsl"

// varying vec2 texcoord;
in vec2 texcoord;

/* RENDERTARGETS: 0 */ 
layout(location = 0) out vec4 color;

vec3 make_gray(vec3 color, float amount) {
	float average_color = dot(color.rgb, vec3(1/3.0)); 
	color = mix(color, vec3(average_color), amount);
	return color;
}

void main() {
	// vec3 color = texture2D(DRAW_SHADOW_MAP, texcoord).rgb; // legacy stuff
	
	vec2 uv = texcoord;

// /* DRAWBUFFERS:0 */
	//gl_FragData[0] = vec4(color, 1.0); //gcolor
	//gl_FragData[0] = vec4(1.0,0.0,0.0, 0.1); //gcolor
	// gl_FragData[0] = vec4(uv.yyy, 1.0);//gcolor
	// color = vec4(texcoord, 0.0, 1.0);//gcolor

	color = texture(colortex0, texcoord);
	float grey_scale = dot(color.rgb, vec3(1/3.0));

	// color.rgb = mix(color.rgb, vec3(grey_scale), 1);

	// if (grey_scale < 0.5) // turns black pixels red and white pixels green
	// if (texcoord.x < 0.5) // turns left half of screen red and right half green

	/*
		if (grey_scale < 0.33) {
			color.rgb = mix(color.rgb, vec3(1.,0.,0.), 0.5);
		} 
		else if(grey_scale < 0.66 && grey_scale > 0.33 ) {
			color.rgb = mix(color.rgb, vec3(0.,1.,0.), 0.5);
		} 
		else if(grey_scale < 0.99 && grey_scale > 0.66) {
			color.rgb = mix(color.rgb, vec3(0.,0.,1.), 0.5);
		}	
	*/

	// color.rgb = vec3(grey_scale);
	color.rgb = make_gray(color.rgb, INTENSITY);

	// color = texture(colortex0, texcoord);
}
