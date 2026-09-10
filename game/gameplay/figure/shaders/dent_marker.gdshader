shader_type spatial;
render_mode unshaded, cull_disabled, depth_test_disabled, depth_draw_never, shadows_disabled;

void vertex() {
    // Screen-sized billboard: readable as the shell grows, without filling the opening.
    vec4 center = PROJECTION_MATRIX * MODELVIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0);
    center.xy += VERTEX.xy * 28.0 / VIEWPORT_SIZE * center.w;
    POSITION = center;
}

void fragment() {
    float diamond = abs(UV.x - 0.5) + abs(UV.y - 0.5);
    float width = fwidth(diamond);
    float outer = 1.0 - smoothstep(0.46 - width, 0.46, diamond);
    float inner = smoothstep(0.25, 0.25 + width, diamond);
    ALPHA = outer * inner;
    float gold = smoothstep(0.28, 0.31, diamond) * (1.0 - smoothstep(0.40, 0.43, diamond));
    ALBEDO = mix(vec3(0.04, 0.07, 0.12), vec3(1.0, 0.78, 0.16), gold);
}
