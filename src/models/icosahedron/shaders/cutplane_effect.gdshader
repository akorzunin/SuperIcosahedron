shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;

uniform vec4 color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float bias = -1.5;
uniform float thickness = 0.02;

varying mat4 camera_matrix;

void vertex() {
    VERTEX += NORMAL * thickness;
    camera_matrix = VIEW_MATRIX;
}

void fragment() {
    vec4 screen_pixel_vertex = vec4(
        vec3(SCREEN_UV, textureLod(DEPTH_TEXTURE, SCREEN_UV, 0.0).x) * 2.0 -
            1.0,
        1.0);
    vec4 screen_pixel_coord = INV_PROJECTION_MATRIX * screen_pixel_vertex;
    screen_pixel_coord.xyz /= screen_pixel_coord.w;
    float depth = -screen_pixel_coord.z;

    float z = -VERTEX.z;

    ALBEDO = color.rgb;
    ALPHA = color.a * float(depth < z + bias);
    DEPTH = 0.00001;
}

// shader_type spatial;
// render_mode depth_draw_always;
//
// #include "cutplane.gdshaderinc"
// #include "res://src/shaders/shader_utils.gdshaderinc"
//
// uniform bool pulse_enabled = false;
// uniform bool colorflow_enbled = false;
// uniform bool cutplate_visible = true;
// uniform bool use_web_colors = false;
//
//// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
// uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
// uniform vec3 color = vec3(.0, 1., .0);
//
// varying vec3 ver;
//
// void vertex() {
//// Called for every vertex the material is visible on.
//// world_vertex = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
// ver = VERTEX;
//}
// vec4 when_eq(vec4 x, vec4 y) {
// return 1.0 - abs(sign(x - y));
//}
//
// void fragment() {
////ALBEDO = ALBEDO;
// if (cutplate_visible) {
// float dist = cutplane_dist(cutplane, ver);
// if (dist > .0) {
// discard;
//}
// vec4 col = vec4(1.,1.,0.,0.5);
//
// float border_dist = smoothstep(0.0, 0.1, -dist);
// vec3 a = ALBEDO;
// ALBEDO = vec3(0., 1. - border_dist, 0.);
// if ((1. - border_dist) > 0.) {
// ALPHA = 1.5;
// EMISSION = vec3(1. - border_dist);
//} else {
////discard;
////ALBEDO = a;
////ALPHA = ALPHA;
//}
//
//}
////if (OUTPUT_IS_SRGB) {
////ALBEDO = linear_to_srgb(color.rgb);
////} else {
//////ALBEDO = color.rgb;
////vec4 col = vec4(1.,1.,0.,0.5);
////ALBEDO = vec3(col.x, col.y - border_dist, col.z);
////
////}
//}
//
//// void light() {
//// Called for every pixel for every light affecting the material.
//// Uncomment to replace the default light processing function with this one.
////}
