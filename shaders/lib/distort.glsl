const int shadowMapResolution = 2048; 

const bool shadowTex0Nearest = true;   
const bool shadowTex1Nearest = true;   
const bool shadowColor0Nearest = true; 

#define SHADOW_RADIUS 1     // defines the total radius in which we sample (in pixels)
#define SHADOW_RANGE 6      // controls how many samples we take for every pixel we sample

// #define SHADOW_BIAS 0.1

vec3 distortShadowClipPos(vec3 shadowClipPos) // in shadowclipspace[-1,1] push pixels at edges away from origion [0,0]
{
    float distortionFactor = length(shadowClipPos.xy); // distance from the player in shadow clip space
    distortionFactor += 0.1; // very small distances can cause issues so we add this to slightly reduce the distortion

    // float factor = length(shadowClipPos.xy) + 0.1;
    // return vec3(shadowClipPos.xy / factor, shadowClipPos.z * 0.5);

    shadowClipPos.xy /= distortionFactor; // make that distance even greater by pushing it closer to the edge
    shadowClipPos.z *= 0.5; // increases shadow distance on the Z axis, which helps when the sun is very low in the sky
    return shadowClipPos;
}

// float computeBias(vec3 pos) {
//     float numerator = length(pos.xy) + 0.1;
//     numerator *= numerator;
//     return SHADOW_BIAS / shadowMapResolution * numerator / 0.1;
// }