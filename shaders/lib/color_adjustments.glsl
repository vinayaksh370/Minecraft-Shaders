vec3 make_gray(vec3 color, float GrayscaleAmount) {
    float avgColor = color.r+color.g+color.b / 3.0; 
    return mix(color, vec3(avgColor), GrayscaleAmount);
}