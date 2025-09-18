shader_type spatial;
render_mode cull_back;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

// Uniforms
uniform vec4 cutplane = vec4(-0.577, -0.577, -0.577, 0.794);
uniform vec3 color : source_color = vec3(0., 1., 0.);
uniform vec4 accent_color : source_color = vec4(0.26, 0.26, 0.26, 1.);
uniform vec4 glow_color : source_color = vec4(0.863, .988, 0.906, 1.);
uniform bool enable = true;

// Wave parameters
uniform float speed : hint_range(0, 5) = 1.0;
uniform float wave_width : hint_range(0, 1) = 0.1;
uniform float fade_factor : hint_range(0, 5) = 1.0;
uniform float rim_width : hint_range(0, 0.2) = 0.05;
uniform float pulse_width : hint_range(0, 10.) = 0.5;
uniform int num_pulses : hint_range(1, 10) = 3;

varying vec3 ver;
varying float dist;

void vertex() {
    if (enable) {
        ver = VERTEX;
        dist = -cutplane_dist(cutplane, ver);
    }
}

void fragment() {
    if (!enable) {
        discard;
    }

    // Precise distance calculation in fragment shader
    float actual_dist = -cutplane_dist(cutplane, ver);
    //if (actual_dist > 0.0) {
        //discard;
    //}
    float distance_from_edge = actual_dist;

    // Calculate wave position
    float pulse_progress = mod(TIME * speed, 1.0);
    float pulse_position = pulse_progress * cutplane.w;

    // Initialize total pulse effect
    float total_pulse = 0.0;

    // Calculate multiple pulses
    for(int i = 0; i < num_pulses; i++) {
        float offset = float(i) / float(num_pulses);
        float current_pulse = exp(-pow(abs(distance_from_edge + (pulse_progress - offset) * cutplane.w), pulse_width + 1.) / (wave_width * wave_width));
        total_pulse += current_pulse;
    }

    // Rim highlight at the edge
    float rim = 1.0 - smoothstep(0.0, rim_width, distance_from_edge);

    // Combine effects
    vec3 emission = (total_pulse + rim) * glow_color.rgb * glow_color.a;

    // Set final color
    ALBEDO = color;
    ALBEDO = vec3(0.);
    EMISSION = emission;
    //ALPHA = .0;
}



//
//uniform vec4 cutplane = vec4(-0.577, -0.577, -0.577, 0.794);
//uniform vec4 glow_color : source_color = vec4(0.863, 0.988, 0.906, 1.);
//uniform bool enable = true;
//uniform float hole_size = 1.0;
//uniform float wave_speed = 2.0;
//uniform float wave_frequency = 10.0;
//uniform float border_width = 0.15;
//uniform vec2 _center = vec2(0.11, 0.39);
//
//uniform float _zoom = 2.85;
//uniform float _repeat = 6.;
//uniform float _speed = .35;
//varying vec3 ver;
//varying float dist;
//
//float sdTriangle(vec2 p) {
    //const float k = sqrt(3.0);
    //p.x = abs(p.x) - 1.0;
    //if(p.x + k*p.y > 0.0)
        //p = vec2(p.x - k*p.y, -k*p.x - p.y)/2.0;
    //p.x -= clamp(p.x, -2.0, 0.0);
    //return -length(p)*sign(p.y);
//}
//vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
    //vec2 dir = uv - center;
    //float radius = length(dir) * 2.0;
    //float angle = atan(dir.y, dir.x) * 1.0 / (3.1416 * 2.0);
    //return mod(vec2(radius * zoom, angle * repeat), 1.0);
//}
//void vertex() {
    //if (enable) {
        //ver = VERTEX;
        //dist = -cutplane_dist(cutplane, ver);
    //}
//}
//
//void fragment() {
    //
    //if (enable && abs(dist) < 0.001) {
        //vec3 N = normalize(cutplane.xyz);
        //vec3 proj_pos = ver - dist * N;
        //vec3 center = -cutplane.w * N / dot(N, N);
        //vec3 local_pos = proj_pos - center;
        //
        //vec3 tangent = normalize(cross(N, abs(N.y) > 0.999 ? vec3(1,0,0) : vec3(0,1,0)));
        //vec3 bitangent = cross(N, tangent);
        //vec2 polar_uv = polar_coordinates(UV, _center, _zoom, _repeat);
        //vec2 uv = vec2(dot(local_pos, tangent), dot(local_pos, bitangent));
        ////uv = polar_uv;
        ////uv /= hole_size;
        //
        ////float d = sdTriangle(uv);
        //float d =dist;
        //if(d < 0.0) {
            //float distance_edge = -d * hole_size;
            //
            //// Base wave calculation
            //float wave = sin(distance_edge * wave_frequency - TIME * wave_speed);
            //float wave_abs = abs(wave);
            //float decay = exp(-distance_edge * 0.5);
            //
            //// Main wave body
            //float main_wave = smoothstep(0.3, 1.0, wave_abs) * decay;
            //
            //// Inner border calculation
            //float border = smoothstep(1.0 - border_width, 1.0, wave_abs) * decay;
            //border *= smoothstep(0.0, 0.2, distance_edge); // Fade border near center
            //
            //// Combine effects
            //float final_alpha = glow_color.a * (main_wave + border * 1.2);
            //vec3 final_emission = glow_color.rgb * (main_wave + border * 2.0);
            //
            //ALPHA = final_alpha;
            ////EMISSION = final_emission;
        //}
    //}
//}
