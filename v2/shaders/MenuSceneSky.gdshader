shader_type sky;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
    COLOR = vec3(1., 1., 1.);
    //COLOR = vec3(0.023529411764705882, 0.3058823529411765, 0.23137254901960785);
}
