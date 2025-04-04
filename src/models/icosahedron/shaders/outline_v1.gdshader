shader_type spatial;
render_mode unshaded, cull_front;

uniform bool enable = false;

uniform sampler2D screen_texture : hint_screen_texture,
                                   repeat_disable,
                                   filter_nearest;

// outline costumization
uniform float outline_thickness = 0.05;
uniform vec4 color : source_color = vec4(0., 1., 0., 1.);
uniform vec4 accent_color : source_color = vec4(0.26, 0.26, 0.26, 1.);

// pulse customization
uniform float pulse_speed = 12.;
uniform float pulse_amplitude = 2.;

varying vec3 ver;

void vertex() {
    if (enable) {
        float t = sin(TIME * pulse_speed) / pulse_amplitude + 1.;
        VERTEX += VERTEX * (outline_thickness * t);
    }
}

// TODO: move to inc file
vec4 color_burn(vec4 base, vec4 blend) { return 1.0 - (1.0 - base) / blend; }

vec4 darken(vec4 base, vec4 blend) { return min(base, blend); }

void fragment() {
    if (enable) {
        ALBEDO = min(color, accent_color).rgb;
    } else {
        vec4 currentColor = textureLod(screen_texture, SCREEN_UV, 0.0);
        ALBEDO = currentColor.rgb;
    }
}
