vec3 linear_to_srgb(vec3 _color) {
    // If going to srgb, clamp from 0 to 1.
    _color = clamp(_color, vec3(0.0), vec3(1.0));
    const vec3 a = vec3(0.055f);
    return mix(
        (vec3(1.0f) + a) * pow(_color.rgb, vec3(1.0f / 2.4f)) - a,
        12.92f * _color.rgb,
        lessThan(_color.rgb, vec3(0.0031308f))
    );
}

vec3 srgb_to_linear(vec3 _color) {
	return mix(
		pow((_color.rgb + vec3(0.055)) * (1.0 / (1.0 + 0.055)), vec3(2.4)),
		_color.rgb * (1.0 / 12.92),
		lessThan(_color.rgb, vec3(0.04045))
	);
}
