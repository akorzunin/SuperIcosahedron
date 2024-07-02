shader_type spatial;
render_mode cull_back;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

uniform bool enable = true;
// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec3 color : source_color = vec3(0., 0., 0.);
uniform float time_scale = 10.;
uniform sampler2D noise_pattern;

varying vec3 ver;
varying float dist;

void vertex() {
    if (enable) {
        ver = VERTEX;
        dist = cutplane_dist(cutplane, ver);
    }
}

void fragment() {
    if (enable) {
        float noiseValue = texture(noise_pattern, UV).x;
        bool a = dist > 0.;
        if (a) {
            discard;
        }
        float c = 1. - smoothstep(0., 2.5, clamp(-dist, 0.0, 1.0) * TAU);
        c = sin(c * TAU * 3. * noiseValue - TIME * time_scale) * c;
        ALBEDO = color;
        ALPHA = c;
    } else {
        ALPHA = .0;
    }
}
