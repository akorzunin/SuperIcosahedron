shader_type spatial;
render_mode cull_front, depth_test_disabled;

#include "cutplane.gdshaderinc"
#include "res://v2/shaders/shader_utils.gdshaderinc"

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec3 color : source_color = vec3(0.0, 1., 0.);

uniform bool enable = true;
// outline costumization
uniform float outline_thickness = 0.0; // how thick is the outline?

varying vec3 ver;

void vertex() {
    if (enable) {
        // VERTEX += NORMAL * outline_thickness; // apply the outlines thickness
        ver = VERTEX;
    }
}

void fragment() {
    if (enable) {
        float dist = cutplane_dist(cutplane, ver);
        bool a = dist > 0.;
        // 0.9 .. 0.64
        float r_sq = pow(ver.x, 2.) + pow(ver.y, 2.) + pow(ver.z, 2.);
        // 0.9 .. 0.8
        float c = length(ver);

        // ALBEDO = a ? mix(vec3(1. - smoothstep(0.51, 0.9, r_sq) * 1.), color,
        // 0.01) : vec3(0.); ALBEDO = a ? vec3(smoothstep(0.58, 0.9, r_sq)) :
        // vec3(0.);
        ALBEDO = color;
        ALPHA = a ? 0.7 : 0.;

    } else {
        ALPHA = .0;
    }
}
