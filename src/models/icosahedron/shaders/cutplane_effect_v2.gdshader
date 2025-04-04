shader_type spatial;
render_mode cull_disabled, depth_test_disabled;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec3 color : source_color = vec3(0.0, 1., 0.);

uniform bool enable = true;
// outline costumization
uniform float outline_thickness = 0.0; // how thick is the outline?

varying vec3 ver;

uniform sampler2D cutlane_tex;

uniform float uv_offset_x = 0.;
uniform float uv_offset_y = 0.;

uniform float ratio : hint_range(0.0, 1.0) = 0.1;

uniform float power = 3.0;

uniform float time_speed = 10.0;

uniform float max_speed = 90.0;

uniform vec2 uv_rot;

vec2 rotate(vec2 uv, vec2 pivot, float angle) {
    // clang-format off
    mat2 rotation = mat2(
        vec2(sin(angle), -cos(angle)),
        vec2(cos(angle), sin(angle))
    );
    // clang-format on

    uv -= pivot;
    uv = uv * rotation;
    uv += pivot;
    return uv;
}

uniform vec2 center;
uniform float strength : hint_range(-10, 10);
uniform float speed : hint_range(-10, 10);

vec2 vortex(vec2 uv, vec2 _center, float _strength, float _speed) {
    float t = sin(TIME);
    vec2 dir = uv - _center;
    float dist = length(dir);
    // float angle = atan(dir.y * (1. - abs(sin(TIME))), dir.x *
    // abs(sin(TIME)));
    float angle = atan(dir.y, dir.x) * 0.4;
    // if (angle)
    float radius = dist * _strength;
    float new_angle = angle + TIME * _speed;

    vec2 new_uv = _center + vec2(cos(new_angle), sin(new_angle)) * radius;

    return new_uv;
}

void vertex() {
    if (enable) {
        // VERTEX += NORMAL * outline_thickness; // apply the outlines thickness
        ver = VERTEX;
    }
}

void fragment() {
    vec2 uv = UV;
    vec2 new_uv = vortex(uv, center, strength, speed);

    vec4 tex = texture(cutlane_tex, new_uv);

    //
    // uv *= 2.0;
    // uv -= vec2(1.0);
    //
    // float len = length(uv);
    //
    // vec2 modified_uv = rotate(UV, uv_rot, TIME * time_speed);
    // float t = sin(TIME);
    // modified_uv.x += uv_offset_x;
    // modified_uv.y += uv_offset_y;
    // vec4 aaa = texture(cutlane_tex, modified_uv * 5.);
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
        // vec2 rotated_uv = rotate(UV, vec2(0.5), TIME);
        // ALBEDO = vec3(rotated_uv.g);
        ALBEDO = color * (1. - vec3(tex.a));
        // ALBEDO = vec3(tex.a);
        // ALPHA = a ? 0.7 : 0.;

    } else {
        ALPHA = .0;
    }
}
