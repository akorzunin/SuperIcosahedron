shader_type sky;
// tw.sky._200
uniform vec3 bg_color = vec3(0.729, 0.902, 0.992);

void sky() {
    // Called for every visible pixel in the sky background, as well as all
    // pixels in the radiance cubemap.
    COLOR = bg_color;
}
