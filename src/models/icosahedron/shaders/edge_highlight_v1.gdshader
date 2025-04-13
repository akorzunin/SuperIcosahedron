 shader_type spatial;
 render_mode cull_back;

 #include "cutplane.gdshaderinc"
 #include "res://src/shaders/shader_utils.gdshaderinc"

 uniform bool enable = false;
 // to get vac coord a= sin^2(angle), b = sin(angle)*cos(angle)
 uniform vec4 cutplane = vec4(-0.577, -0.577, 0.577, 0.794);
 uniform vec3 color : source_color = vec3(0., .5, 0.);
 uniform float time_scale = 10.;
 uniform sampler2D PULSE_TEXTURE;

 varying vec3 ver;
 varying vec3 nor;
 varying float dist;

 uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 glow_color : source_color = vec4(0.863,
      0.988,
      0.906, 1.);

 vec2 polar_coordinates(vec2 uv, vec2 center, float zoom, float repeat) {
     vec2 dir = uv - center;
     float radius = length(dir) * 2.0;
     float angle = atan(dir.y, dir.x) * 1.0/(PI * 1.0);
     return mod(vec2(radius * zoom, angle * repeat), 1.0);
 }

 void vertex() {
     if (enable) {
         ver = VERTEX;
         nor = NORMAL;
         dist = cutplane_dist(cutplane, ver);
     }
 }
 uniform vec2 _center = vec2(0.37, 0.89);
 uniform float _zoom = 2.85;
 uniform float _repeat = 6.;

 uniform float _speed = .35;
 //uniform float  scale_dist: hint_range(0, 1.) = .5 ;
 //uniform float  scale_dist: hint_range(-1, 1.) = .5 ;
 uniform float  scale_dist: hint_range(0., 2.) = .5 ;

uniform float A = 1.;
uniform float F = 1.;
//uniform float brightness = 1.;
//uniform float contrast = 1.;
//uniform float saturation = 1.;
vec3 color_burn(vec3 base, vec3 blend) { return 1.0 - (1.0 - base) / blend; }

// Pulse control parameters
uniform float pulse_speed = 1.0;
uniform float max_distance = 3.0;
uniform float pulse_width = 1.;
uniform float falloff = 1.4;

 void fragment() {
     vec2 uv = UV;

     float c = 1. - smoothstep(0., 2.5, clamp(-dist, 0.0, 1.0) * TAU);
     //c = sin(c * TAU * 3. - TIME * time_scale) * c;
     float pog = 0.794 * 2.;
     vec4 currentColor = textureLod(screen_texture, SCREEN_UV, 0.0);
    //currentColor.rgb = mix(vec3(0.0), currentColor.rgb, brightness);
    //currentColor.rgb = mix(vec3(0.5), currentColor.rgb, contrast);
    //currentColor.rgb = mix(vec3(dot(vec3(1.0), currentColor.rgb) * 0.33333), currentColor.rgb, saturation);
     //float ooo = (-dist + TIME / 10.) * step(-dist, pog) * .9;
     //float ooo = (dist) * step(-dist, pog) * .9;
     uv = polar_coordinates(uv, _center, _zoom, _repeat);
     //uv.x += ooo;
     //uv.y += ooo;
     //uv.x += 0.;
     //uv.y += TIME;
    bool a = dist > 0.;
     if (enable) {
        vec3 cc = vec3(0.);
         float tex = texture(PULSE_TEXTURE, uv).x;
        vec3 t = texture(PULSE_TEXTURE, uv).xyz;
         bool b = dist < 0.;

        // Calculate pulse position
        float pulse_time = fract(TIME * pulse_speed) * 1.5;
        //pulse_time = scale_dist;
        float pulse_pos = -max_distance * (1.0 - pulse_time);

        // Calculate pulse intensity
        float dist_diff = abs(dist - pulse_pos);
        float intensity = 1.0 - smoothstep(-2.0, pulse_width, dist_diff);


        // Add noise variation
        vec2 uv = UV; // Adjust UV coordinates if needed
        float noise = texture(PULSE_TEXTURE, uv).r;
        // Add distance-based falloff
        intensity *= exp(-pulse_pos * falloff * noise);
        //intensity *= mix(0.0, 1.2, noise);

        // Create final emission effect
        EMISSION += glow_color.rgb * intensity * smoothstep(0.1, 0.5, intensity);

        // Optional: Add surface glow
        cc = mix(color, glow_color.rgb, intensity * 0.5);
        ALBEDO = cc;
        ALPHA = a ? 0. : 1.;
     } else {
         ALPHA = 0.;
     }
 }
