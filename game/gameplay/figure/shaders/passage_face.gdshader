shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, shadows_disabled;

uniform vec4 tint : source_color = vec4(0.65, 0.95, 1.0, 1.0);
uniform bool vortex = false;
uniform bool echo_waves = false;
uniform bool inversion_arrows = false;
uniform sampler2D noise_texture : repeat_enable, filter_linear_mipmap;

void fragment() {
    ALBEDO = tint.rgb;
    ALPHA = 0.22;
    if (echo_waves) {
        // Barycentric distance follows all three actual face boundaries.
        float edge = min(min(UV2.x, UV2.y), 1.0 - UV2.x - UV2.y) * 3.0;
        float travel = 1.0 - abs(mod(TIME * 0.65, 2.0) - 1.0);
        float wave = 1.0 - smoothstep(0.02, 0.10, abs(edge - travel));
        ALBEDO = tint.rgb * (0.65 + wave * 0.7);
        ALPHA = 0.22 + wave * 0.45;
    } else if (inversion_arrows) {
        float row = floor(UV.y * 6.0);
        float direction = mod(row, 2.0) * 2.0 - 1.0;
        vec2 cell = vec2(fract(UV.x * 5.0 - TIME * direction), fract(UV.y * 6.0)) - 0.5;
        cell.x *= direction;
        float head = 1.0 - smoothstep(0.04, 0.09, abs(cell.x + abs(cell.y) - 0.25));
        float shaft = (1.0 - smoothstep(0.04, 0.08, abs(cell.y))) * step(cell.x, 0.22);
        float arrow = max(head, shaft) * (1.0 - smoothstep(0.30, 0.40, abs(cell.x))) * (1.0 - smoothstep(0.27, 0.36, abs(cell.y)));
        ALBEDO = tint.rgb * (0.6 + arrow * 0.7);
        ALPHA = 0.22 + arrow * 0.4;
    } else if (vortex) {
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
