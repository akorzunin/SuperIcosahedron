shader_type spatial;
render_mode cull_disabled;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

uniform bool pulse_enabled = false;
uniform bool colorflow_enbled = false;
uniform bool cutplate_visible = true;
uniform bool use_web_colors = false;

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec3 color = vec3(.0, 1., .0);

varying vec3 ver;

void vertex() {
    // Called for every vertex the material is visible on.
    // world_vertex = (INV_PROJECTION_MATRIX * vec4(VERTEX, 1.0)).xyz;
    ver = VERTEX;
}

void fragment() {
    if (cutplate_visible) {
        if (!render_cutplane(cutplane, ver)) {
            discard;
        }
    }
    if (use_web_colors) {
        ALBEDO = linear_to_srgb(color.rgb);
    } else {
        ALBEDO = color.rgb;
    }
}

// void light() {
// Called for every pixel for every light affecting the material.
// Uncomment to replace the default light processing function with this one.
//}
