shader_type spatial;
render_mode cull_front, depth_test_disabled, unshaded;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec3 color : source_color = vec3(0.0, 1., 0.);

uniform bool enable = true;
// outline costumization
uniform float outline_thickness = 0.0; // how thick is the outline?

uniform vec2 _center = vec2(0.5);
uniform float _zoom = 1.;
uniform float _repeat = 1.;
uniform float _speed = 1.;

varying vec3 ver;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D TEXTURE;

vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat)
{
    vec2 dir = uv - center;
    float radius = length(dir) * 2.0;
    float angle = atan(dir.y, dir.x) * 1.0/(3.1416 * 2.0);
    return mod(vec2(radius * zoom, angle * repeat), 1.0);
}

void vertex() {
    if (enable) {
         //VERTEX += BINORMAL * outline_thickness; // apply the outlines thickness
         //VERTEX += TANGENT * outline_thickness; // apply the outlines thickness
        ver = VERTEX;
    }
}

void fragment() {
    vec3 albedo_out;
    vec2 uv = UV;
    //uv.x += fract(TIME / TAU);
    vec2 polar_uv = polar_coordinates(uv, _center, _zoom, _repeat);
    polar_uv.x += fract(TIME * _speed);
    polar_uv.y += sin(TIME /2.);
    vec4 my_tex = texture(TEXTURE, polar_uv);
    vec4 currentColor = textureLod(screen_texture, SCREEN_UV, 0.0);
    if (enable) {
        float dist = cutplane_dist(cutplane, ver);
        bool a = dist > 0.;
        float c = length(ver);
        float b = my_tex.a;
        //albedo_out = vec3(b);
        //albedo_out = vec3(fract(uv*10.), 0.);
        //albedo_out = min(currentColor.rgb + vec3(0, b, 0.));
        albedo_out = currentColor.rgb + vec3(b, 0., 0.);
        ALBEDO = a ? albedo_out : currentColor.rgb;
        ALPHA = currentColor.a;
        //ALPHA = a ? 1. : 0.01;

    } else {
        ALBEDO = currentColor.rgb;
        //ALPHA = currentColor.a;
    }
}
