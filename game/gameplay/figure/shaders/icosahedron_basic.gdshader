shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.35, 0.85, 1.0, 1.0);

void fragment() {
    vec3 base_color = color.rgb;
    float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float rim = pow(1.0 - facing, 2.0);
    // ALBEDO = mix(base_color * 0.88, base_color, facing) + base_color * rim * 0.08;
    //ALBEDO = base_color;
    ALBEDO = color.rgb;
    ROUGHNESS = 0.62;
}
