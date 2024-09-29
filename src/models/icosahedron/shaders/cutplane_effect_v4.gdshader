shader_type spatial;
render_mode cull_front, depth_test_disabled;

#include "cutplane.gdshaderinc"
#include "res://src/shaders/shader_utils.gdshaderinc"

// to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
//uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
uniform vec4 cutplane = vec4(-0.577, -0.577, -0.577, 0.794);
uniform vec3 color : source_color = vec3(0., 1., 0.);
uniform vec4 accent_color : source_color = vec4(0.26, 0.26, 0.26, 1.);

uniform bool enable = true;
// outline costumization
uniform float outline_thickness = 0.0; // how thick is the outline?

// for cutplane = vec4(-0.577, -0.577, -0.577, 0.794);
//uniform vec2 _center = vec2(0.1, 0.15);

// for cutplane = vec4(0.577, 0.577, 0.577, 0.794);
//uniform vec2 _center = vec2(0.37, 0.89);

uniform vec2 _center = vec2(0.11, 0.39);

uniform float _zoom = 2.85;
uniform float _repeat = 6.;
uniform float _speed = .35;
uniform float aaa = .35;
uniform float bbb = .35;

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
vec4 screen(vec4 base, vec4 blend){
    return 1.0 - (1.0 - base) * (1.0 - blend);
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
        vec4 ac = accent_color;
        //float b = 1. - my_tex.a;
        float d = 1. - smoothstep(.81, .9, c);
        float b = (1. - d * (1. - my_tex.a));
        vec3 overlay_color = 1. - abs(color - b);
        //albedo_out = vec3(b);
        //albedo_out = vec3(fract(uv*10.), 0.);
        //albedo_out = min(currentColor.rgb + vec3(0, b, 0.));
        albedo_out = min(color, overlay_color).rgb;
        //albedo_out = vec4(b).rgb;
        ALBEDO = a ? albedo_out : color.rgb;
        ALPHA = a ? currentColor.a : 0.0;
        //ALBEDO = color.rgb;
        //ALPHA = currentColor.a;

    } else {
        ALBEDO = currentColor.rgb;
        //ALPHA = currentColor.a;
    }
}
