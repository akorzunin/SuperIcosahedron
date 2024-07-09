shader_type spatial;
render_mode cull_disabled, depth_prepass_alpha, shadows_disabled;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

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
        float c = length(ver);
        ALBEDO = color;
        ALPHA = a ? 1. : 0.01;

    } else {
        ALBEDO = color;
        ALPHA = 1.0;
    }
}
