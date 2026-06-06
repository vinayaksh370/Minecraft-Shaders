#version 330 compatibility

#include "settings.glsl"

uniform sampler2D colortex0;
uniform sampler2D depthtex0;
uniform sampler2D colortex2;

uniform mat4 gbufferProjectionInverse;

uniform float far;
uniform vec3 fogColor;

#define FOG_DENSITY 4

in vec2 uv;

/* RENDERTARGETS: 0 */
layout(location = 0) out vec4 color;

vec3 projectAndDivide(mat4 projectionMatrix, vec3 position) {
    vec4 homPos = projectionMatrix * vec4(position, 1.0);
    return homPos.xyz / homPos.w;
}

void main() {

    color = texture(colortex0, uv);

    float depth = texture(depthtex0, uv).r;

    // if (depth == 1.0) return;

    vec3 normal = texture(colortex2, uv).rgb;
    bool isTerrain = length(normal - vec3(0.5)) > 0.01;
    if (!isTerrain) return; // skip fog for clouds, sun, particles

    vec3 NDCPos = vec3(uv.xy, depth) * 2.0 - 1.0;
    vec3 viewPos = projectAndDivide(gbufferProjectionInverse, NDCPos);

    float dist = length(viewPos) / far;
    float fogFactor = exp(-FOG_DENSITY * (1.0 - dist));
    fogFactor = clamp(fogFactor, 0.0, 1.0);

    // if (depth < 0.99999){
        // albedo = mix(albedo, lessContrast, contrastFactor);
        color.rgb = mix(color.rgb, pow(fogColor, vec3(1.5)), fogFactor);
    // }

}

// #version 330 compatibility

// uniform sampler2D colortex0;
// uniform sampler2D colortex2;
// uniform sampler2D depthtex0;
// uniform float near, far;
// uniform float rainStrength;

// #define FOG_DENSITY 0.008
// #define RAIN_MODIFIER 0.011

// const float contrast = 1.25;
// const float brightness = 0.0;

// in vec2 uv;

// /* RENDERTARGETS: 0 */
// layout(location = 0) out vec4 color;

// float LinearDepth(float z) {
//     return 1.0 / ((1.0 - far / near) * z + (far / near));
// }

// float FogExp2(float viewDistance, float density) {
//     float factor = viewDistance * (density / sqrt(log(2.0)));
//     return exp2(-factor * factor);
// }

// void main() {
//     vec3 albedo = texture(colortex0, uv).rgb;
//     albedo = pow(albedo, vec3(1.0 / 1.5));

//     float mask = 1.0 - texture(colortex2, uv).r;
//     // color = vec4(vec3(mask), 1.0); // show mask as grayscale
// // return;
//     float depth = texture(depthtex0, uv).r;

//     float density = FOG_DENSITY + rainStrength * RAIN_MODIFIER;
//     depth = LinearDepth(depth);
//     float viewDistance = depth * far - near;

//     vec3 lessContrast = contrast * 0.33 * (albedo - 0.5) + 0.5 + brightness;
//     albedo = contrast * (albedo - 0.5) + 0.5 + brightness;

//     float contrastFactor = 1.0 - clamp(FogExp2(viewDistance, density), 0.0, 1.0);
//     contrastFactor *= mask;

//     if (depth < 0.99999)
//         albedo = mix(albedo, lessContrast, contrastFactor);

//     color = vec4(albedo, 1.0);
// }