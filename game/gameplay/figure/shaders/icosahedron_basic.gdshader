shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;

uniform vec4 color : source_color = vec4(0.35, 0.85, 1.0, 1.0);
uniform float opacity : hint_range(0.0, 1.0) = 1.0;
uniform bool controlled = false;

varying vec3 barycentric;

void vertex() {
    // Dent meshes have one indexed triangle; expand vertices if shared meshes are introduced.
    barycentric = vec3(float(VERTEX_ID == 0), float(VERTEX_ID == 1), float(VERTEX_ID == 2));
}

void fragment() {
    // Screen-door fade is grainy but depth-correct for nested shells;
    // smooth blending needs explicit nested-shell transparency sorting.
    float threshold = fract(sin(dot(floor(FRAGCOORD.xy), vec2(12.9898, 78.233))) * 43758.5453);
    if (opacity <= threshold) discard;
    float facing = clamp(dot(NORMAL, VIEW), 0.0, 1.0);
    float rim = pow(1.0 - facing, 2.0);
    ALBEDO = color.rgb;
    vec3 edge_distance = barycentric / max(fwidth(barycentric), vec3(0.0001));
    float edge = controlled ? 1.0 - smoothstep(1.0, 2.0, min(edge_distance.x, min(edge_distance.y, edge_distance.z))) : 0.0;
    ALBEDO = mix(ALBEDO, vec3(0.04, 0.12, 0.18), edge);
    EMISSION = controlled ? color.rgb * rim * 0.15 : vec3(0.0);
    ROUGHNESS = 0.62;
}
