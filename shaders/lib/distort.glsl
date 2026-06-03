const int shadowMapResolution = 2048; 

const bool shadowTex0Nearest = true;   // \/\/\/\/
const bool shadowTex1Nearest = true;   // we only have one shadow texture, so we can just use the same variable for both
const bool shadowColor0Nearest = true; // we only have one color texture for shadows, so we can just use the same variable for it

#define SHADOW_RADIUS 1
#define SHADOW_RANGE 4

vec3 distortShadowClipPos(vec3 shadowClipPos) 
{
    float distortionFactor = length(shadowClipPos.xy); // the further from the center, the more distortion we apply
    distortionFactor += 0.1; // to avoid division by zero

    shadowClipPos.xy /= distortionFactor; // distort more as we get further from the center
    shadowClipPos.z *= 0.5; // reduce depth to create a softer shadow

    return shadowClipPos;
}

