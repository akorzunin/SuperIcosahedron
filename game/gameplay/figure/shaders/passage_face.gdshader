shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 tint : source_color = vec4(0.65, 0.95, 1.0, 1.0);
uniform bool vortex = false;
uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap;

void fragment() {
    ALBEDO = tint.rgb;
    ALPHA = 0.22;
    if (vortex) {
        vec2 p = UV * 2.0 - 1.0;
        float radius = length(p);
        float angle = atan(p.y, p.x) + radius * 9.0 + TIME * 1.4;
        // Cartesian sampling avoids a seam where the polar angle wraps.
        vec2 flow = vec2(cos(angle), sin(angle)) * radius * 1.8;
        float noise = texture(noise_texture, flow + vec2(TIME * 0.12)).r;
        float arms = 0.5 + 0.5 * sin(angle * 3.0 + noise * 4.0);
        float funnel = smoothstep(0.03, 0.18, radius) * (1.0 - smoothstep(0.65, 1.0, radius));
        float swirl = arms * funnel;
        ALBEDO = tint.rgb * mix(0.55, 1.25, swirl);
        ALPHA = 0.22 + swirl * 0.32;
    }
}
