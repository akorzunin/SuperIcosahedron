shader_type spatial;
render_mode cull_back, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.35, 0.85, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform bool controlled = false;

void fragment() {
    // Screen-door fade is grainy but depth-correct for nested shells;
    // smooth blending needs explicit nested-shell transparency sorting.
    float threshold = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
    if (opacity <= threshold) discard;
    float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float rim = pow(1.0 - facing, 2.0);
    ALBEDO = color.rgb;
    EMISSION = controlled ? color.rgb * rim * 0.15 : vec3(0.0);
    ROUGHNESS = 0.62;
}
