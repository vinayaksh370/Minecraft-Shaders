#version 330 compatibility

/*
const int colortex0Format = RGBA32F;
const int colortex2Format = R8;
*/

#include "settings.glsl"
#include "lib/color_adjustments.glsl"
#include "lib/distort.glsl"

uniform sampler2D depthtex0;  
uniform sampler2D lightmap;
uniform sampler2D gtexture;
uniform vec3 shadowLightPosition;     // return sun or moon position in view space 
uniform float alphaTestRef = 0.1;

uniform vec2 colortex3; // uv from composite

uniform sampler2D shadowtex0;   // contains everything that casts a shadow
uniform sampler2D shadowtex1;   // contains only things which are fully opaque and cast a shadow
uniform sampler2D shadowcolor0; // contains the color (including how transparent it is) of things which cast a shadow.

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D noisetex;
uniform float viewWidth, viewHeight;

in vec4 shadowClipPos;
in vec2 lmcoord;
in vec2 uv;
in vec4 glcolor;
in vec3 normal;

in vec4 shadowPos;  // add this

// values stored to colortex0, colortex1, colortex2 respectively
/* RENDERTARGETS: 0,1,2 */ 
layout(location = 0) out vec4 color;
layout(location = 1) out vec4 lightmapData;
layout(location = 2) out vec4 encodedNormal; // textures can only store value from 0 to 1, so we encode the normal from -1 to 1 to 0 to 1

const vec3 blocklightColor = vec3(0.98f, 0.68f, 0.55f);
const vec3 skylightColor = vec3(0.05, 0.15, 0.4);
const vec3 sunlightColor = vec3(1.0);
const vec3 ambientColor = vec3(0.1);

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position){
  vec4 homPos = projectionMatrix * vec4(position, 1.0);
  return homPos.xyz / homPos.w;
}

vec3 getShadow(vec3 shadowScreenPos, vec2 lm) {
    float transparentShadow = step(shadowScreenPos.z, texture(shadowtex0, shadowScreenPos.xy).r);
    if (transparentShadow == 1.0) {
        return vec3(1.0); // nothing blocking, full sunlight
    }
    float opaqueShadow = step(shadowScreenPos.z, texture(shadowtex1, shadowScreenPos.xy).r);
    if (opaqueShadow == 0.0) {
        return vec3(0.0); // opaque blocker, full shadow
    }
    vec4 shadowColor = texture(shadowcolor0, shadowScreenPos.xy);
    // return shadowColor.rgb * (1.0 - shadowColor.a);

	vec3 colorTint = mix(vec3(1.0), shadowColor.rgb, shadowColor.a); // intensity based on opacity
    colorTint = mix(colorTint, vec3(1.0), lm.r); // reduce effect where block light is strong
	// colorTint = mix(colorTint, vec3(1.0), 0.0); // no block light information available
    return colorTint; // full light but tinted
}

vec4 getNoise(vec2 coord) {
    ivec2 screenCoord = ivec2(coord * vec2(viewWidth, viewHeight));
    ivec2 noiseCoord = screenCoord % 64;
    return texelFetch(noisetex, noiseCoord, 0);
}

vec3 getSoftShadow(vec4 clipPos, vec2 lm) {
    float noise = getNoise(uv).r;
    float theta = noise * radians(360.0);
    float cosTheta = cos(theta);
    float sinTheta = sin(theta);
    mat2 rotation = mat2(cosTheta, -sinTheta, sinTheta, cosTheta);

    vec3 shadowAccum = vec3(0.0);
    const int samples = SHADOW_RANGE * SHADOW_RANGE * 4;

    for (int x = -SHADOW_RANGE; x < SHADOW_RANGE; x++) {
        for (int y = -SHADOW_RANGE; y < SHADOW_RANGE; y++) {
            vec2 offset = vec2(x, y) * SHADOW_RADIUS / float(SHADOW_RANGE);
            offset = rotation * offset;// * 0.8;
            offset /= shadowMapResolution;

            vec4 offsetClipPos = clipPos + vec4(offset, 0.0, 0.0);
            offsetClipPos.xyz /= offsetClipPos.w;
            offsetClipPos.xyz = distortShadowClipPos(offsetClipPos.xyz);
            offsetClipPos.z -= 0.001;
            vec3 shadowScreenPos = offsetClipPos.xyz * 0.5 + 0.5;

            shadowAccum += getShadow(shadowScreenPos, lm);
        }
    }
    return shadowAccum / float(samples);
}

void main() 
{
	color = texture(gtexture, uv) * glcolor; // load texture + biome tint
	vec2 lm = lmcoord;
	
	lightmapData = vec4(lm, 0.0, 1.0);
	// encodedNormal = vec4(normal * 0.5 + 0.5, 1.0); // -1 to 1 to 0 to 1
	encodedNormal = vec4(1.0);
	
	#if LIGHTING_STYLE == 0
		// default minecraft lightmap lighting
		color *= texture(lightmap, lm);
	#endif
	
	#if LIGHTING_STYLE == 1
		// custom lighting, for testing
		/*
			// color.rgb = glcolor.rgb;
			vec3 torch_color = vec3(1.0, 0.0, 0.0);
			vec3 skycolor = vec3(0.0, 1.0, 1.0);
			color.rgb *= torch_color * lm.x + skycolor * lm.y; // mix torch and sky color based on lightmap values
		*/x
		/*
			vec3 lightPos = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition); // in world space
			vec3 worldNormal = normalize(normal); 

			vec3 ambientLight = vec3(0.1);
			vec3 torch_color = vec3(1.0, 0.0, 0.8);

			float lightDot =  clamp(dot(lightPos, worldNormal), 0.0, 1.0); // 0 = blockfacing away from light, 1 = block facing towards light
			lightDot = pow(lightDot, 1.5); // make the light falloff sharper, for testing
			vec3 diffuse = vec3(lightDot);
			vec3 torchLight = torch_color * lm.x; // modulate torch light by lightmap value and diffuse term

			// color *= texture(lightmap, lm);

			color.rgb *= (ambientLight + torchLight + (texture(lightmap, lm).g * lm.g) + lightDot); // modulate color by angle to light source
		*/
		/*
			vec3 worldNormal = normalize(normal); 
			lightDot = pow(lightDot, 1.5); // make the light falloff sharper, for testing
			vec3 diffuse = vec3(lightDot);
			vec3 torchLight = torch_color * lm.x; // modulate torch light by lightmap value and diffuse term
			vec3 ambientLight = vec3(0.3);
			vec3 torch_color = vec3(1.0, 0.0, 0.8);
			color.rgb *= (ambientLight + torchLight + (lightDot));//+ (texture(lightmap, lm).g * lm.g) + lightDot); // modulate color by angle to light source
			color.rgb = color.rgb * ((texture(lightmap, lm).g * lm.g) + torchLight + lightDot);//+ (texture(lightmap, lm).g * lm.g) + lightDot); // modulate color by angle to light source
		*/
	#endif
	
	#if LIGHTING_STYLE == 2

		vec3 lightPos = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition); // in world space
		float lightDot =  clamp(dot(lightPos, normal), 0.0, 1.0); // 0 = blockfacing away from light, 1 = block facing towards light

		vec4 lmSample = texture(lightmap, lm);
		
		vec3 blockLight = lm.r * blocklightColor; // blocklight is stored in the red channel of the lightmap
		// vec3 blockLight = lmSample.r * blocklightColor; // blocklight is stored in the red channel of the lightmap

		vec3 skylight = lm.g * skylightColor;     // skylight is stored in the green channel of the lightmap
		// vec3 skylight = lmSample.g * skylightColor;     // skylight is stored in the green channel of the lightmap

		vec3 ambient = ambientColor;
		vec3 sunlight = sunlightColor * lightDot * lm.g;

		// color *= texture(lightmap, lm);// color *= texture(lightmap, lm);
		
		color.rgb *= + ambient + blockLight + skylight + sunlight;

		// color.rgb = glcolor.rgb;

	#endif

	#if LIGHTING_STYLE == 3

	vec3 lightPos = normalize(mat3(gbufferModelViewInverse) * shadowLightPosition);
	float lightDot = clamp(dot(lightPos, normal), 0.0, 1.0);

	vec3 blockLight = lm.r * blocklightColor;
	vec3 skylight   = lm.g * skylightColor;
	vec3 ambient    = ambientColor;

	// float shadow = 0.0;
	vec3 shadow = vec3(0.0);
	if (lightDot > 0.0) {  // only check shadow map if facing the sun
		// shadow = step(shadowPos.z, texture(shadowtex0, shadowPos.xy).r);
		// shadow = getShadow(shadowPos.xyz, lm);
		shadow = getSoftShadow(shadowClipPos, lm);
	}

	vec3 sunlight = sunlightColor * lightDot *  shadow;
	
	color.rgb *= ambient + blockLight + skylight + sunlight;
	// color.rgb *=  sunlight;
	// color.rgb = vec3(shadowPos.xy, 0.0);


	#endif
	
	if (color.a < alphaTestRef) { // alpha test
  		discard; // don't bother writing
	}

	// Debug
	// vec4 vcolor = vec4(1.,1.,1.,0.3); // vertex color, used for biome tinting
	// color = texture(gtexture, uv) * vcolor; // biome tint
	// color.rgb = normal;

	color.rgb = make_gray(color.rgb, GRAY_SCALE); // desaturate for testing
}