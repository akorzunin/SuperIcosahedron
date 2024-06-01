shader_type sky;

void sky() {
	// Called for every visible pixel in the sky background, as well as all pixels
	// in the radiance cubemap.
    COLOR = vec3(0.058823529411764705, 0.09019607843137255, 0.16470588235294117);
}
